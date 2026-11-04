iterative_scc_counts <- function(edges) {
  found <- list()
  previous <- 0
  for (level in sort(unique(edges$weight))) {
    edges <- edges[weight >= level]
    if (!nrow(edges)) break
    nodes <- unique(c(edges$from, edges$to))
    f <- match(edges$from, nodes)
    t <- match(edges$to, nodes)
    comp <- components(make_graph(as.vector(rbind(f, t)), n = length(nodes)), mode = "strong")
    group <- comp$membership
    group[comp$csize[group] < 2] <- NA
    if (all(is.na(group))) break

    in_scc <- !is.na(group)
    members <- split(nodes[in_scc], group[in_scc])
    found[[length(found) + 1]] <- data.table(
      scc = unname(vapply(members, function(m) paste(sort(m), collapse = " "), "")),
      occurrence = level - previous
    )
    previous <- level
    edges <- edges[!is.na(group[f]) & group[f] == group[t]]
  }
  rbindlist(found)
}

candidate_sccs <- function(counts, threshold = SCC_THRESHOLD) {
  candidates <- counts[occurrence >= threshold]
  candidates[, `:=`(scc_id = .I, members = lapply(strsplit(scc, " ", fixed = TRUE), as.integer))]
  candidates[, size := lengths(members)][]
}

wash_prefix_length <- function(amount, buyer, seller, margin = POSITION_MARGIN) {
  n <- length(amount)
  if (n < 2) return(0L)
  accounts <- unique(c(buyer, seller))
  rows <- seq_len(n)
  flow <- matrix(0, n, length(accounts))
  flow[cbind(rows, match(buyer, accounts))] <- amount
  flow[cbind(rows, match(seller, accounts))] <- -amount
  position <- abs(apply(flow, 2, cumsum))
  worst <- do.call(pmax, lapply(seq_along(accounts), function(j) position[, j]))
  matched <- worst <= margin * cumsum(amount) / rows
  matched[1] <- FALSE
  if (any(matched)) max(which(matched)) else 0L
}

match_volumes <- function(trades, window, start, margin = POSITION_MARGIN) {
  trades <- trades[order(trade_id)]
  trades[, bucket := (timestamp - start) %/% window]
  trades[, wash := seq_len(.N) <= wash_prefix_length(amount_token, b, s, margin), by = .(token, bucket)]
  trades[wash == TRUE, trade_id]
}

label_exchange <- function(exchange, threshold = SCC_THRESHOLD, windows = WASH_WINDOWS_SECONDS,
                           margin = POSITION_MARGIN) {
  trades <- load_trades(exchange, c("trade_id", "timestamp", "day", "month", "token", "seller", "buyer",
                                    "amount_token", "usd", "self_trade"))
  accounts <- sort(unique(c(trades$seller, trades$buyer)))
  trades[, `:=`(s = match(seller, accounts), b = match(buyer, accounts))]

  weights <- trades[self_trade == FALSE, .(weight = .N), by = .(token, from = s, to = b)]
  per_token <- split(weights, by = "token", keep.by = FALSE)
  counts <- rbindlist(lapply(per_token[intersect(unique(trades$token), names(per_token))], iterative_scc_counts))
  candidates <- candidate_sccs(counts[, .(occurrence = sum(occurrence)), by = scc], threshold)

  pool <- trades[self_trade == FALSE & s %in% unlist(candidates$members) & b %in% unlist(candidates$members),
                 .(trade_id, timestamp, token, s, b, amount_token)]
  setkey(pool, s)
  wash_window <- rep(NA_real_, nrow(trades))
  wash_scc <- rep(NA_integer_, nrow(trades))
  start <- min(trades$day)

  for (window in windows) {
    for (i in seq_len(nrow(candidates))) {
      members <- candidates$members[[i]]
      scc_trades <- pool[.(members), nomatch = NULL][b %in% members & is.na(wash_window[trade_id])]
      if (nrow(scc_trades) < 2) next
      ids <- match_volumes(scc_trades, window, start, margin)
      wash_window[ids] <- window
      wash_scc[ids] <- candidates$scc_id[i]
    }
  }

  trades[, `:=`(wash = !is.na(wash_window), wash_window = wash_window, scc_id = wash_scc, s = NULL, b = NULL)]
  candidates[, accounts := vapply(members, function(m) paste(accounts[m], collapse = " "), "")]
  list(trades = trades, candidates = candidates[, .(scc_id, size, occurrence, accounts)])
}

load_labels <- function(exchange, columns = NULL) read_fst(labels_path(exchange), columns = columns, as.data.table = TRUE)

wash_accounts <- function(labelled, include_self_trades = FALSE) {
  chosen <- if (include_self_trades) labelled[wash | self_trade] else labelled[wash == TRUE]
  unique(c(chosen$seller, chosen$buyer))
}

validation_summary <- function(labelled, exchange, candidates) {
  labelled[, .(
    exchange = exchange,
    trades = .N,
    candidate_sccs = nrow(candidates),
    wash_trades = sum(wash),
    wash_trade_share = mean(wash),
    usd_volume = sum(usd),
    wash_usd = sum(usd[wash]),
    wash_usd_share = sum(usd[wash]) / sum(usd),
    self_trades = sum(self_trade),
    self_trade_usd = sum(usd[self_trade]),
    wash_tokens = uniqueN(token[wash]),
    wash_accounts = length(wash_accounts(labelled)),
    self_trade_accounts = uniqueN(seller[self_trade]),
    wash_or_self_accounts = length(wash_accounts(labelled, include_self_trades = TRUE)),
    published_wash_accounts = PUBLISHED_WASH_ACCOUNTS[[exchange]]
  )]
}
