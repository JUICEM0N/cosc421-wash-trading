source("R/setup.R")

dir.create(TABLES_DIR, recursive = TRUE, showWarnings = FALSE)
for (exchange in exchange_args("RQ4: network-metric detection score")) {
  result <- detection_results(exchange)
  fwrite(result$evaluation, table_path(exchange, "detection_evaluation"))
  fwrite(result$candidates, table_path(exchange, "new_candidates"))
  cat(exchange, "\n")
  print(result$evaluation[, .(population, score, wash_accounts, auc, average_precision, precision_at_k)])
}
