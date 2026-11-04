derive_idex_filled_amounts <- function(trades) {
  trades[, `:=`(amountBought = amount, amountSold = amount * amountSell / amountBuy)]
}

standardise_columns <- function(trades, exchange) {
  if (exchange == "IDEX") {
    derive_idex_filled_amounts(trades)
    trades <- trades[, .(tx_hash = transaction_hash, block = block_number, timestamp, status,
                         maker, taker, token_buy = tokenBuy, token_sell = tokenSell,
                         amount_bought = amountBought, amount_sold = amountSold)]
  } else {
    trades <- trades[, .(tx_hash = transaction_hash, block = block_number, timestamp, status = 1,
                         maker = get, taker = give, token_buy = tokenGet, token_sell = tokenGive,
                         amount_bought = amountGet, amount_sold = amountGive)]
  }
  for (column in c("maker", "taker", "token_buy", "token_sell")) set(trades, j = column, value = tolower(trades[[column]]))
  trades
}

keep_eth_token_trades <- function(trades) {
  trades[(token_buy == ETH_ADDRESS) != (token_sell == ETH_ADDRESS)]
}

rescale_amounts <- function(trades, decimals) {
  scale <- function(tokens) {
    places <- decimals$decimals[match(tokens, decimals$address)]
    10^fcoalesce(places, DEFAULT_TOKEN_DECIMALS)
  }
  trades[, `:=`(amount_bought = amount_bought / scale(token_buy), amount_sold = amount_sold / scale(token_sell))]
}

orient_seller_to_buyer <- function(trades) {
  trades[, maker_pays_eth := token_sell == ETH_ADDRESS]
  trades[, `:=`(
    token = fifelse(maker_pays_eth, token_buy, token_sell),
    buyer = fifelse(maker_pays_eth, maker, taker),
    seller = fifelse(maker_pays_eth, taker, maker),
    amount_token = fifelse(maker_pays_eth, amount_bought, amount_sold),
    amount_eth = fifelse(maker_pays_eth, amount_sold, amount_bought)
  )]
}

add_usd_volume <- function(trades, prices) {
  trades[, day := floor(timestamp / 86400) * 86400]
  trades[prices, eth_usd := i.eth_usd, on = "day"]
  trades[, usd := amount_eth * eth_usd]
  months <- unique(trades[, .(day)])[, month := format(as.POSIXct(day, tz = "UTC"), "%Y-%m")]
  trades[months, month := i.month, on = "day"]
}

trade_counts <- function(trades, stage) {
  data.table(
    stage = stage,
    trades = nrow(trades),
    traders = uniqueN(c(trades$maker, trades$taker)),
    tokens = uniqueN(setdiff(c(trades$token_buy, trades$token_sell), ETH_ADDRESS))
  )
}

cleaning_summary <- function(raw, cleaned) {
  rbind(
    raw,
    data.table(
      stage = "cleaned",
      trades = nrow(cleaned),
      traders = uniqueN(c(cleaned$seller, cleaned$buyer)),
      tokens = uniqueN(cleaned$token)
    ),
    data.table(
      stage = "self_trades",
      trades = sum(cleaned$self_trade),
      traders = uniqueN(cleaned[self_trade == TRUE, seller]),
      tokens = uniqueN(cleaned[self_trade == TRUE, token])
    )
  )
}

clean_exchange <- function(exchange) {
  trades <- standardise_columns(load_raw_trades(exchange), exchange)
  counts <- trade_counts(trades, "raw")

  trades <- trades[status == 1 & complete.cases(trades)]
  trades <- keep_eth_token_trades(trades)
  counts <- rbind(counts, trade_counts(trades, "eth_token"))

  rescale_amounts(trades, load_token_decimals())
  orient_seller_to_buyer(trades)
  add_usd_volume(trades, load_eth_prices())
  trades <- trades[is.finite(amount_token) & is.finite(amount_eth) & amount_token > 0 & amount_eth > 0 & !is.na(usd)]

  setorder(trades, timestamp, block)
  trades[, `:=`(trade_id = .I, self_trade = seller == buyer)]
  trades <- trades[, .(trade_id, tx_hash, block, timestamp, day, month, token, seller, buyer,
                       amount_token, amount_eth, eth_usd, usd, self_trade)]
  list(trades = trades, summary = cleaning_summary(counts, trades))
}
