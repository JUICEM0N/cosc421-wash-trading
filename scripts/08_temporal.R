source("R/setup.R")

dir.create(TABLES_DIR, recursive = TRUE, showWarnings = FALSE)
for (exchange in exchange_args("RQ5: monthly network metrics and the IDEX KYC comparison")) {
  monthly <- temporal_table(exchange)
  fwrite(monthly, table_path(exchange, "monthly_metrics"))
  comparison <- before_after(monthly)
  fwrite(comparison, table_path(exchange, "kyc_before_after"))
  cat(exchange, if (exchange != "IDEX") "(control, no KYC change)", "\n")
  print(comparison[, .(metric, before_mean, after_mean, relative_change, level_change_p)])
}
