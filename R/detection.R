DETECTION_FEATURES <- c(trades_per_partner = 1, isolation = 1, coreness = 1, betweenness = -1,
                        reciprocity = 1, in_largest_scc = 1)
LABEL_DERIVED_FEATURES <- c("reciprocity", "in_largest_scc")

account_features <- function(exchange) {
  accounts <- read_fst(accounts_path(exchange), as.data.table = TRUE)
  communities <- read_fst(isolation_path(exchange), columns = c("account", "isolation", "community_size"),
                          as.data.table = TRUE)
  features <- communities[accounts, on = "account"]
  features[, `:=`(betweenness = fcoalesce(betweenness, 0), in_largest_scc = as.numeric(in_largest_scc))]
  features[self_trader == FALSE | wash == TRUE]
}

detection_score <- function(features, exclude = character()) {
  chosen <- setdiff(names(DETECTION_FEATURES), exclude)
  ranks <- vapply(chosen, function(feature) {
    frank(DETECTION_FEATURES[[feature]] * features[[feature]], ties.method = "average", na.last = "keep")
  }, numeric(nrow(features)))
  rowMeans(matrix(ranks, nrow = nrow(features)), na.rm = TRUE) / nrow(features)
}

evaluate <- function(scores, labels, top_k = sum(labels)) {
  positives <- sum(labels)
  negatives <- length(labels) - positives
  ranks <- frank(scores, ties.method = "average")
  ordered <- labels[order(scores, decreasing = TRUE)]
  hits <- sum(ordered[seq_len(top_k)])
  data.table(
    accounts = length(labels),
    wash_accounts = positives,
    auc = (sum(ranks[labels]) - positives * (positives + 1) / 2) / (positives * negatives),
    average_precision = mean((cumsum(ordered) / seq_along(ordered))[ordered]),
    top_k = top_k,
    precision_at_k = hits / top_k,
    recall_at_k = hits / positives
  )
}

new_candidates <- function(features, scores, labels, top_k = 20) {
  ranked <- features[, score := scores][labels == FALSE][order(-score)]
  ranked[seq_len(min(top_k, .N)), .(account, score, trades, partners, trades_per_partner, reciprocity,
                                     isolation, coreness, betweenness, tokens, usd_volume)]
}

score_variants <- function() {
  features <- names(DETECTION_FEATURES)
  c(
    list(all_features = character(), without_label_derived = LABEL_DERIVED_FEATURES),
    setNames(lapply(features, function(feature) setdiff(features, feature)), paste0("only_", features))
  )
}

detection_results <- function(exchange) {
  features <- account_features(exchange)
  populations <- list(all_accounts = features, active_accounts = features[active == TRUE])
  variants <- score_variants()

  evaluation <- rbindlist(lapply(names(populations), function(population) {
    pool <- populations[[population]]
    scored <- lapply(names(variants), function(variant) {
      cbind(population = population, score = variant, evaluate(detection_score(pool, variants[[variant]]), pool$wash))
    })
    baseline <- cbind(population = population, score = "trade_count_baseline", evaluate(pool$trades, pool$wash))
    rbindlist(c(scored, list(baseline)))
  }))

  pool <- copy(populations$active_accounts)
  candidates <- new_candidates(pool, detection_score(pool, LABEL_DERIVED_FEATURES), pool$wash)
  list(evaluation = evaluation, candidates = candidates)
}
