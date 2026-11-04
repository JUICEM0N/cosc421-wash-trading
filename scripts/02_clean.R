source("R/setup.R")

dir.create(TABLES_DIR, recursive = TRUE, showWarnings = FALSE)
for (exchange in exchange_args("Clean raw trades and add USD volume")) {
  dir.create(exchange_dir(exchange), recursive = TRUE, showWarnings = FALSE)
  cleaned <- clean_exchange(exchange)
  write_fst(cleaned$trades, trades_path(exchange))
  fwrite(cleaned$summary, table_path(exchange, "cleaning_summary"))
  cat(exchange, "\n")
  print(cleaned$summary)
}
