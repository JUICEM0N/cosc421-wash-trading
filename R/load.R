RAW_COLUMNS <- list(
  IDEX = c("transaction_hash", "status", "block_number", "timestamp", "amountBuy", "amountSell",
           "amount", "tokenBuy", "tokenSell", "maker", "taker"),
  EtherDelta = c("transaction_hash", "block_number", "timestamp", "tokenGet", "amountGet",
                 "tokenGive", "amountGive", "get", "give")
)

AMOUNT_COLUMNS <- c("amountBuy", "amountSell", "amount", "amountGet", "amountGive")

load_raw_trades <- function(exchange, columns = RAW_COLUMNS[[exchange]]) {
  types <- ifelse(columns %in% c("timestamp", "block_number", "status"), "numeric", "character")
  trades <- fread(file.path(RAW_DIR, TRADE_FILES[[exchange]]), select = setNames(types, columns),
                  integer64 = "double", showProgress = FALSE)
  for (column in intersect(columns, AMOUNT_COLUMNS)) set(trades, j = column, value = as.numeric(trades[[column]]))
  trades
}

load_token_decimals <- function() {
  tokens <- jsonlite::fromJSON(file.path(RAW_DIR, "token_decimals.json"), simplifyVector = FALSE)
  decimals <- rbindlist(lapply(tokens, function(token) {
    list(address = tolower(token$address %||% NA_character_), decimals = as.numeric(token$decimals %||% NA))
  }))
  unique(decimals[!is.na(address) & !is.na(decimals)], by = "address")
}

load_eth_prices <- function() {
  prices <- fread(file.path(RAW_DIR, "EtherDollarPrice.csv"), col.names = c("date", "day", "eth_usd"))
  prices[, .(day = as.numeric(day), eth_usd = as.numeric(eth_usd))]
}

load_trades <- function(exchange, columns = NULL) {
  read_fst(trades_path(exchange), columns = columns, as.data.table = TRUE)
}
