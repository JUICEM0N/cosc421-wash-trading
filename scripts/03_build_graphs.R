source("R/setup.R")

dir.create(TABLES_DIR, recursive = TRUE, showWarnings = FALSE)
for (exchange in exchange_args("Build the token, account and monthly edge lists")) {
  trades <- load_trades(exchange, c("token", "month", "seller", "buyer", "amount_token", "amount_eth", "usd"))
  tokens <- token_edges(trades)
  accounts <- account_edges(trades)
  months <- monthly_edges(trades)
  save_edges(tokens, exchange, "token")
  save_edges(accounts, exchange, "account")
  save_edges(months, exchange, "monthly")

  overview <- rbind(
    cbind(scope = "account", graph_summary(account_graph(accounts))),
    cbind(scope = "account_with_self_trades", graph_summary(account_graph(accounts, keep_self_trades = TRUE))),
    fill = TRUE
  )
  overview[, `:=`(token_graphs = uniqueN(tokens$token), monthly_snapshots = uniqueN(months$month))]
  fwrite(overview, table_path(exchange, "graph_overview"))
  cat(exchange, "\n")
  print(overview)
}
