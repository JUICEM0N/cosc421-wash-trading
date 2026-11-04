ACTIVE_ACCOUNT_MIN_TRADES <- 10

token_wash_summary <- function(labelled) {
  labelled[, .(
    all_trades = .N,
    wash_trades = sum(wash),
    wash_trade_share = mean(wash),
    wash_usd_share = sum(usd[wash]) / sum(usd),
    self_trades = sum(self_trade)
  ), by = token][, has_wash := wash_trades > 0][]
}

token_profile <- function(g, min_trades_for_nulls = NULL_MODEL_MIN_TRADES) {
  row <- graph_summary(g)
  if (row$trades >= min_trades_for_nulls && ecount(g) >= 3) row <- cbind(row, null_comparison(g))
  row
}

token_profiles <- function(exchange, min_trades_for_nulls = NULL_MODEL_MIN_TRADES) {
  graphs <- largest_first(token_graphs(load_edges(exchange, "token")))
  rows <- parallel_map(graphs, token_profile, min_trades_for_nulls = min_trades_for_nulls)
  profiles <- rbindlist(rows, fill = TRUE, idcol = "token")
  wash <- token_wash_summary(load_labels(exchange, c("token", "usd", "wash", "self_trade")))
  wash[profiles, on = "token"]
}

token_betweenness <- function(graphs) {
  rows <- parallel_map(largest_first(graphs), function(g) {
    if (ecount(g) == 0) return(NULL)
    data.table(account = V(g)$name, betweenness = account_betweenness(g))
  })
  rbindlist(rows)[, .(betweenness = max(betweenness), tokens = .N), by = account]
}

account_profiles <- function(exchange) {
  accounts <- account_summary(account_graph(load_edges(exchange, "account")))
  bridging <- token_betweenness(token_graphs(load_edges(exchange, "token")))
  accounts <- bridging[accounts, on = "account"]

  labelled <- load_labels(exchange, c("seller", "buyer", "wash", "self_trade"))
  accounts[, `:=`(
    wash = account %chin% wash_accounts(labelled),
    self_trader = account %chin% labelled[self_trade == TRUE, seller],
    active = trades >= ACTIVE_ACCOUNT_MIN_TRADES
  )][]
}

group_comparison <- function(data, metrics, level, population) {
  rbindlist(lapply(metrics, function(metric) {
    x <- data[[metric]]
    wash <- x[data$wash & !is.na(x)]
    organic <- x[!data$wash & !is.na(x)]
    if (length(wash) < 2 || length(organic) < 2) return(NULL)
    data.table(
      level = level, population = population, metric = metric,
      n_wash = length(wash), n_organic = length(organic),
      median_wash = median(wash), median_organic = median(organic),
      mean_wash = mean(wash), mean_organic = mean(organic),
      wilcoxon_p = suppressWarnings(wilcox.test(wash, organic)$p.value)
    )
  }))
}

compare_wash_vs_organic <- function(tokens, accounts) {
  token_metrics <- c("average_partners", "density", "reciprocity", "largest_scc_share", "clustering",
                     "assortativity", "reciprocity_z", "clustering_z", "largest_scc_share_z")
  account_metrics <- c("partners", "trades", "trades_per_partner", "usd_volume", "reciprocity",
                       "pagerank", "coreness", "betweenness", "tokens")
  tokens <- copy(tokens)[, wash := has_wash]
  eligible <- tokens[all_trades >= NULL_MODEL_MIN_TRADES]
  accounts <- accounts[self_trader == FALSE | wash == TRUE]
  rbind(
    group_comparison(eligible, token_metrics, "token", paste0("tokens with >= ", NULL_MODEL_MIN_TRADES, " trades")),
    group_comparison(accounts, account_metrics, "account", "all accounts"),
    group_comparison(accounts[active == TRUE], account_metrics, "account",
                     paste0("accounts with >= ", ACTIVE_ACCOUNT_MIN_TRADES, " trades"))
  )
}
