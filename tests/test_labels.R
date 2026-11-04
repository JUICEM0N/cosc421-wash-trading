source("R/setup.R")

ring <- data.table(from = c(1L, 2L, 3L, 4L), to = c(2L, 3L, 1L, 1L), weight = c(150L, 150L, 150L, 3L))
counts <- iterative_scc_counts(ring)[, .(occurrence = sum(occurrence)), by = scc]
stopifnot(identical(counts$scc, "1 2 3"), counts$occurrence == 150)

nested <- data.table(from = c(1L, 2L, 2L, 3L), to = c(2L, 1L, 3L, 2L), weight = c(200L, 200L, 5L, 5L))
counts <- iterative_scc_counts(nested)[, .(occurrence = sum(occurrence)), by = scc]
stopifnot(counts[scc == "1 2 3", occurrence] == 5, counts[scc == "1 2", occurrence] == 195)

one_way <- data.table(from = c(1L, 2L), to = c(2L, 3L), weight = c(500L, 500L))
stopifnot(nrow(iterative_scc_counts(one_way)) == 0)

stopifnot(wash_prefix_length(c(10, 10, 10), buyer = c("b", "c", "a"), seller = c("a", "b", "c")) == 3)
stopifnot(wash_prefix_length(c(10, 10, 10, 4), buyer = c("b", "c", "a", "b"), seller = c("a", "b", "c", "a")) == 3)
stopifnot(wash_prefix_length(c(10, 10), buyer = c("b", "c"), seller = c("a", "b")) == 0)
stopifnot(wash_prefix_length(c(10, 9.95), buyer = c("b", "a"), seller = c("a", "b")) == 2)
stopifnot(wash_prefix_length(c(10, 9), buyer = c("b", "a"), seller = c("a", "b")) == 0)

trades <- data.table(
  trade_id = 1:6,
  timestamp = c(0, 600, 1200, 4000, 4100, 90000),
  token = "x",
  s = c(1L, 2L, 3L, 1L, 2L, 1L),
  b = c(2L, 3L, 1L, 2L, 1L, 2L),
  amount_token = c(5, 5, 5, 7, 7, 3)
)
stopifnot(identical(match_volumes(trades, window = 3600, start = 0), 1:5))

cat("label tests passed\n")
