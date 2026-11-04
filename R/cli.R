exchange_args <- function(description) {
  args <- commandArgs(trailingOnly = TRUE)
  if (any(args %in% c("-h", "--help"))) {
    cat(description, "\n\nOptions:\n  --exchange", paste(EXCHANGES, collapse = " "), "\n")
    quit(save = "no", status = 0)
  }
  flag <- match("--exchange", args)
  if (is.na(flag)) return(EXCHANGES)
  chosen <- args[-seq_len(flag)]
  chosen <- chosen[seq_len(match(TRUE, startsWith(chosen, "--"), nomatch = length(chosen) + 1) - 1)]
  if (!length(chosen) || !all(chosen %in% EXCHANGES)) {
    stop("--exchange takes one or more of: ", paste(EXCHANGES, collapse = ", "), call. = FALSE)
  }
  chosen
}
