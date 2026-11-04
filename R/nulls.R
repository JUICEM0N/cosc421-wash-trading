NULL_METRICS <- list(
  reciprocity = graph_reciprocity,
  clustering = graph_clustering,
  largest_scc_share = largest_scc_share
)

rewired_copy <- function(g, swaps_per_edge = REWIRE_SWAPS_PER_EDGE) {
  rewire(g, keeping_degseq(loops = FALSE, niter = swaps_per_edge * ecount(g)))
}

null_distribution <- function(g, metrics = NULL_METRICS, copies = NULL_MODEL_COPIES, seed = RANDOM_SEED) {
  set.seed(seed)
  values <- vapply(seq_len(copies), function(i) {
    copy <- rewired_copy(g)
    vapply(metrics, function(metric) metric(copy), numeric(1))
  }, numeric(length(metrics)))
  matrix(values, nrow = copies, byrow = TRUE, dimnames = list(NULL, names(metrics)))
}

z_score <- function(observed, null_values) {
  spread <- sd(null_values, na.rm = TRUE)
  if (is.na(spread) || spread == 0) return(NA_real_)
  (observed - mean(null_values, na.rm = TRUE)) / spread
}

null_comparison <- function(g, metrics = NULL_METRICS, copies = NULL_MODEL_COPIES, seed = RANDOM_SEED) {
  nulls <- null_distribution(g, metrics, copies, seed)
  observed <- vapply(metrics, function(metric) metric(g), numeric(1))
  row <- list()
  for (name in names(metrics)) {
    row[[paste0(name, "_null_mean")]] <- mean(nulls[, name], na.rm = TRUE)
    row[[paste0(name, "_z")]] <- z_score(observed[[name]], nulls[, name])
  }
  as.data.table(row)
}
