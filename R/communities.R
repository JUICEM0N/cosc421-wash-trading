undirected_weighted <- function(g) {
  as_undirected(g, mode = "collapse", edge.attr.comb = list(weight = "sum", "ignore"))
}

louvain <- function(g, seed = RANDOM_SEED) {
  set.seed(seed)
  membership(cluster_louvain(undirected_weighted(g)))
}

infomap <- function(g, seed = RANDOM_SEED) {
  set.seed(seed)
  membership(cluster_infomap(g, e.weights = E(g)$weight, modularity = FALSE))
}

community_modularity <- function(g, membership) {
  ug <- undirected_weighted(g)
  modularity(ug, membership, weights = E(ug)$weight)
}

normalized_mutual_information <- function(membership, labels) {
  compare(as.integer(membership), as.integer(labels) + 1L, method = "nmi")
}

purity <- function(membership, labels) {
  sum(tapply(labels, membership, function(x) max(sum(x), sum(!x)))) / length(labels)
}

wash_share_of_community <- function(membership, labels) ave(as.numeric(labels), membership)

community_isolation <- function(g, membership) {
  ug <- undirected_weighted(g)
  ends <- ends(ug, E(ug), names = FALSE)
  internal <- membership[ends[, 1]] == membership[ends[, 2]]
  inside <- tapply(E(ug)$weight[internal], factor(membership[ends[internal, 1]], levels = unique(membership)), sum)
  total <- tapply(strength(ug), factor(membership, levels = unique(membership)), sum)
  isolation <- fcoalesce(as.numeric(2 * inside / total), 0)
  isolation[match(membership, unique(membership))]
}

partition_summary <- function(g, membership, labels) {
  share <- wash_share_of_community(membership, labels)
  isolation <- community_isolation(g, membership)
  data.table(
    communities = uniqueN(membership),
    modularity = community_modularity(g, membership),
    nmi = normalized_mutual_information(membership, labels),
    purity = purity(membership, labels),
    wash_purity = mean(share[labels]),
    wash_majority_share = mean(share[labels] >= 0.5),
    wash_communities = uniqueN(membership[labels]),
    wash_isolation = mean(isolation[labels]),
    organic_isolation = mean(isolation[!labels])
  )
}

token_communities <- function(g, wash_members) {
  labels <- V(g)$name %chin% wash_members
  rbind(
    cbind(method = "louvain", partition_summary(g, louvain(g), labels)),
    cbind(method = "infomap", partition_summary(g, infomap(g), labels))
  )
}

wash_members_by_token <- function(labelled) {
  members <- labelled[wash == TRUE, .(account = c(seller, buyer)), by = token]
  split(members$account, members$token)
}

account_communities <- function(g) {
  membership <- louvain(g)
  data.table(
    account = V(g)$name,
    community = membership,
    community_size = as.vector(table(membership)[as.character(membership)]),
    isolation = community_isolation(g, membership)
  )
}

community_table <- function(exchange) {
  labelled <- load_labels(exchange, c("token", "seller", "buyer", "wash"))
  members <- wash_members_by_token(labelled)
  edges <- load_edges(exchange, "token")
  tokens <- rbindlist(lapply(names(members), function(token) {
    g <- token_graph(edges, token)
    cbind(token = token, nodes = vcount(g), wash_accounts = sum(V(g)$name %chin% members[[token]]),
          token_communities(g, members[[token]]))
  }))

  g <- account_graph(load_edges(exchange, "account"))
  accounts <- account_communities(g)
  wash <- accounts$account %chin% wash_accounts(labelled)
  overall <- cbind(scope = "account graph", method = "louvain", partition_summary(g, accounts$community, wash))
  list(tokens = tokens, accounts = accounts, overall = overall)
}
