partners <- function(g) ego_size(g, order = 1, mode = "all", mindist = 1)

degree_table <- function(g) {
  data.table(
    account = V(g)$name,
    in_degree = degree(g, mode = "in", loops = FALSE),
    out_degree = degree(g, mode = "out", loops = FALSE),
    partners = partners(g),
    trades = strength(g, mode = "all", loops = FALSE),
    usd_volume = strength(g, mode = "all", loops = FALSE, weights = E(g)$usd_volume)
  )
}

average_partners <- function(g) if (vcount(g)) mean(partners(g)) else NA_real_

graph_density <- function(g) if (vcount(g) > 1) edge_density(g, loops = FALSE) else NA_real_

graph_reciprocity <- function(g) if (ecount(g)) reciprocity(g, ignore.loops = TRUE) else NA_real_

trades_per_partner <- function(g) strength(g, mode = "all", loops = FALSE) / pmax(partners(g), 1)

account_reciprocity <- function(g) {
  edges <- as_edgelist(g, names = FALSE)
  mutual <- which_mutual(g, loops = FALSE)
  tabulate(edges[mutual, 1], nbins = vcount(g)) / pmax(partners(g), 1)
}

account_betweenness <- function(g, cutoff = -1) {
  betweenness(g, directed = TRUE, weights = NA, normalized = TRUE, cutoff = cutoff)
}

account_pagerank <- function(g) page_rank(g, directed = TRUE)$vector

account_coreness <- function(g) coreness(g, mode = "all")

strong_components <- function(g) components(g, mode = "strong")

largest_scc_share <- function(g) if (vcount(g)) max(strong_components(g)$csize) / vcount(g) else NA_real_

in_largest_scc <- function(g) {
  comp <- strong_components(g)
  comp$csize[comp$membership] == max(comp$csize) & max(comp$csize) > 1
}

graph_clustering <- function(g) {
  if (vcount(g) < 3) return(NA_real_)
  transitivity(as_undirected(g, mode = "collapse"), type = "global")
}

degree_assortativity <- function(g) {
  if (ecount(g) < 2) return(NA_real_)
  assortativity_degree(g, directed = TRUE)
}

graph_summary <- function(g) {
  data.table(
    nodes = vcount(g),
    edges = ecount(g),
    trades = sum(E(g)$weight),
    usd_volume = sum(E(g)$usd_volume),
    average_partners = average_partners(g),
    density = graph_density(g),
    reciprocity = graph_reciprocity(g),
    largest_scc_share = largest_scc_share(g),
    clustering = graph_clustering(g),
    assortativity = degree_assortativity(g)
  )
}

account_summary <- function(g, betweenness_cutoff = NULL) {
  accounts <- degree_table(g)
  accounts[, `:=`(
    trades_per_partner = trades / pmax(partners, 1),
    reciprocity = account_reciprocity(g),
    pagerank = account_pagerank(g),
    coreness = account_coreness(g),
    in_largest_scc = in_largest_scc(g)
  )]
  if (!is.null(betweenness_cutoff)) accounts[, betweenness := account_betweenness(g, betweenness_cutoff)]
  accounts[]
}
