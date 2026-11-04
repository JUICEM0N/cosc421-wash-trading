source("R/setup.R")

dir.create(TABLES_DIR, recursive = TRUE, showWarnings = FALSE)
for (exchange in exchange_args("RQ2: Louvain and Infomap communities against the wash labels")) {
  result <- community_table(exchange)
  fwrite(result$tokens, table_path(exchange, "communities"))
  fwrite(result$overall, table_path(exchange, "community_summary"))
  write_fst(result$accounts, isolation_path(exchange))
  cat(exchange, "\n")
  print(result$overall)
  print(result$tokens[, lapply(.SD, median), by = method,
                      .SDcols = c("communities", "modularity", "nmi", "wash_purity", "wash_isolation", "organic_isolation")])
}
