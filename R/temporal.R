ITS_WINDOW_MONTHS <- 12
TEMPORAL_METRICS <- c("nodes", "trades", "average_partners", "density", "reciprocity", "largest_scc_share",
                      "clustering", "modularity", "wash_trade_share", "wash_usd_share", "self_trade_share")

monthly_metrics <- function(snapshots) {
  rbindlist(lapply(names(snapshots), function(month) {
    g <- snapshots[[month]]
    cbind(month = month, graph_summary(g), modularity = community_modularity(g, louvain(g)))
  }))
}

monthly_wash_share <- function(labelled) {
  labelled[, .(
    wash_trade_share = mean(wash),
    wash_usd_share = sum(usd[wash]) / sum(usd),
    self_trade_share = mean(self_trade),
    self_trade_usd_share = sum(usd[self_trade]) / sum(usd)
  ), by = month]
}

interrupted_series <- function(y, index) {
  data <- data.frame(y = y, t = index, post = as.numeric(index > 0), t_post = pmax(index, 0))
  coefficients <- tryCatch(summary(lm(y ~ t + post + t_post, data = data))$coefficients, error = function(e) NULL)
  pick <- function(term, column) if (!is.null(coefficients) && term %in% rownames(coefficients)) coefficients[term, column] else NA_real_
  list(level_change = pick("post", 1), level_change_p = pick("post", 4),
       slope_change = pick("t_post", 1), slope_change_p = pick("t_post", 4))
}

before_after <- function(monthly, event_month = KYC_MONTH, window = KYC_WINDOW_MONTHS,
                         its_window = ITS_WINDOW_MONTHS) {
  monthly <- monthly[order(month)]
  monthly[, index := seq_len(.N) - match(event_month, month)]
  near <- monthly[index != 0 & abs(index) <= its_window]
  rbindlist(lapply(intersect(TEMPORAL_METRICS, names(monthly)), function(metric) {
    y <- monthly[[metric]]
    before <- mean(y[monthly$index %between% c(-window, -1)])
    after <- mean(y[monthly$index %between% c(1, window)])
    c(list(metric = metric, before_mean = before, after_mean = after, change = after - before,
           relative_change = (after - before) / abs(before)),
      interrupted_series(near[[metric]], near$index))
  }))
}

temporal_table <- function(exchange) {
  metrics <- monthly_metrics(monthly_snapshots(load_edges(exchange, "monthly")))
  wash <- monthly_wash_share(load_labels(exchange, c("month", "usd", "wash", "self_trade")))
  wash[metrics, on = "month"][order(month)]
}
