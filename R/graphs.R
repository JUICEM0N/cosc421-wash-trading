collapse_edges <- function(trades, by = character()) {
  trades[, .(n_trades = .N, token_volume = sum(amount_token), eth_volume = sum(amount_eth), usd_volume = sum(usd)),
         by = c(by, "seller", "buyer")]
}

token_edges <- function(trades) collapse_edges(trades, "token")
account_edges <- function(trades) collapse_edges(trades)[, token_volume := NULL][]
monthly_edges <- function(trades) collapse_edges(trades, "month")[, token_volume := NULL][]

edge_graph <- function(edges, keep_self_trades = FALSE) {
  if (!keep_self_trades) edges <- edges[seller != buyer]
  graph_from_data_frame(edges[, .(seller, buyer, weight = n_trades, eth_volume, usd_volume)], directed = TRUE)
}

token_graph <- function(edges, chosen_token, keep_self_trades = FALSE) {
  edge_graph(edges[token == chosen_token], keep_self_trades)
}

account_graph <- function(edges, keep_self_trades = FALSE) edge_graph(edges, keep_self_trades)

split_graphs <- function(edges, by, min_trades = 1, keep_self_trades = FALSE) {
  totals <- edges[, .(n_trades = sum(n_trades)), by = by][n_trades >= min_trades]
  parts <- split(edges[totals[, ..by], on = by], by = by, keep.by = FALSE)
  lapply(parts, edge_graph, keep_self_trades = keep_self_trades)
}

token_graphs <- function(edges, min_trades = 1, keep_self_trades = FALSE) {
  split_graphs(edges, "token", min_trades, keep_self_trades)
}

monthly_snapshots <- function(edges, keep_self_trades = FALSE) {
  graphs <- split_graphs(edges, "month", keep_self_trades = keep_self_trades)
  graphs[order(names(graphs))]
}

save_edges <- function(edges, exchange, scope) write_fst(edges, edges_path(exchange, scope))
load_edges <- function(exchange, scope) read_fst(edges_path(exchange, scope), as.data.table = TRUE)
