source("R/setup.R")

dir.create(TABLES_DIR, recursive = TRUE, showWarnings = FALSE)
for (exchange in exchange_args("RQ1 and RQ3: structural profile of wash and organic trading")) {
  tokens <- token_profiles(exchange)
  accounts <- account_profiles(exchange)
  fwrite(tokens, table_path(exchange, "token_profiles"))
  write_fst(accounts, accounts_path(exchange))
  comparison <- compare_wash_vs_organic(tokens, accounts)
  fwrite(comparison, table_path(exchange, "profile_comparison"))
  cat(exchange, "\n")
  print(comparison[, .(level, population, metric, median_wash, median_organic, wilcoxon_p)])
}
