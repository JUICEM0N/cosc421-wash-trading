source("R/setup.R")

dir.create(TABLES_DIR, recursive = TRUE, showWarnings = FALSE)
for (exchange in exchange_args("Label wash trades with SCC counting and volume matching")) {
  labelled <- label_exchange(exchange)
  write_fst(labelled$trades, labels_path(exchange))
  write_fst(labelled$candidates, sccs_path(exchange))
  summary <- validation_summary(labelled$trades, exchange, labelled$candidates)
  fwrite(summary, table_path(exchange, "label_validation"))
  print(t(summary))
}
