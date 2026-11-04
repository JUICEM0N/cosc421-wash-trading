INK <- list(primary = "#0b0b0b", secondary = "#52514e", muted = "#898781", grid = "#e1e0d9",
            axis = "#c3c2b7", surface = "#fcfcfb")
GROUP_COLOURS <- c("Other accounts" = "#2a78d6", "Wash-trading accounts" = "#eb6834")
TOKEN_COLOURS <- c("Tokens without wash trades" = "#2a78d6", "Tokens with wash trades" = "#eb6834")
DENSITY_RAMP <- c("#cde2fb", "#104281")
MONTHLY_PANELS <- c(
  reciprocity = "Reciprocity",
  largest_scc_share = "Largest SCC share of accounts",
  modularity = "Modularity (Louvain)",
  clustering = "Clustering coefficient",
  wash_usd_share = "Wash trade share of USD volume",
  self_trade_usd_share = "Self-trade share of USD volume"
)

theme_report <- function() {
  theme_minimal(base_size = 9) +
    theme(
      plot.background = element_rect(fill = INK$surface, colour = NA),
      panel.grid.major = element_line(colour = INK$grid, linewidth = 0.25),
      panel.grid.minor = element_blank(),
      axis.line = element_line(colour = INK$axis, linewidth = 0.3),
      axis.text = element_text(colour = INK$muted),
      axis.title = element_text(colour = INK$secondary),
      plot.title = element_text(colour = INK$primary, face = "bold"),
      plot.subtitle = element_text(colour = INK$secondary),
      plot.caption = element_text(colour = INK$muted, hjust = 0),
      legend.position = "top",
      legend.justification = "left",
      legend.title = element_blank(),
      legend.text = element_text(colour = INK$secondary),
      strip.text = element_text(colour = INK$primary, face = "bold", hjust = 0)
    )
}

save_figure <- function(plot, path, width = 6.5, height = 4) {
  ggsave(path, plot, width = width, height = height, dpi = 200, bg = INK$surface)
  path
}

label_share <- function(x) paste0(formatC(x * 100, format = "fg", digits = 2), "%")

account_group <- function(wash)factor(ifelse(wash, "Wash-trading accounts", "Other accounts"), levels = names(GROUP_COLOURS))

complementary_cdf <- function(values) {
  sorted <- sort(values)
  levels <- unique(sorted)
  data.table(value = levels, share = 1 - (match(levels, sorted) - 1) / length(sorted))
}

degree_distribution <- function(accounts, path, exchange) {
  ccdf <- accounts[, complementary_cdf(partners), by = .(group = account_group(wash))]
  plot <- ggplot(ccdf, aes(value, share, colour = group)) +
    geom_step(linewidth = 0.7) +
    scale_x_log10(labels = scales::label_comma()) +
    scale_y_log10(labels = label_share) +
    scale_colour_manual(values = GROUP_COLOURS) +
    labs(title = paste(exchange, "trading partners per account"),
         subtitle = "Share of accounts with at least this many distinct partners",
         x = "Distinct trading partners", y = "Share of accounts") +
    theme_report()
  save_figure(plot, path)
}

strength_vs_degree <- function(accounts, path, exchange) {
  organic <- accounts[wash == FALSE]
  wash <- accounts[wash == TRUE]
  plot <- ggplot(mapping = aes(partners, trades)) +
    geom_bin_2d(data = organic, bins = 60) +
    scale_fill_gradient(low = DENSITY_RAMP[1], high = DENSITY_RAMP[2], trans = "log10",
                        labels = scales::label_comma(), name = "Other accounts") +
    geom_abline(slope = 1, intercept = 0, colour = INK$muted, linewidth = 0.3) +
    geom_point(data = wash, aes(shape = "Wash-trading accounts"), fill = GROUP_COLOURS[["Wash-trading accounts"]],
               colour = INK$surface, size = 2, stroke = 0.5) +
    scale_shape_manual(values = 21, name = NULL) +
    scale_x_log10(labels = scales::label_comma()) +
    scale_y_log10(labels = scales::label_comma()) +
    annotate("text", x = 300, y = 120, label = "1 trade per partner", hjust = 0, vjust = 1,
             colour = INK$muted, size = 2.6) +
    labs(title = paste(exchange, "trades against trading partners"),
         subtitle = "Wash traders make many trades with few partners",
         x = "Distinct trading partners", y = "Trades") +
    theme_report() +
    theme(legend.title = element_text(colour = INK$secondary, size = 8))
  save_figure(plot, path)
}

reciprocity_vs_null <- function(tokens, path, exchange) {
  data <- tokens[!is.na(reciprocity_null_mean)]
  data[, group := factor(ifelse(has_wash, "Tokens with wash trades", "Tokens without wash trades"),
                         levels = names(TOKEN_COLOURS))]
  plot <- ggplot(data[order(group)], aes(reciprocity_null_mean, reciprocity, fill = group)) +
    geom_abline(slope = 1, intercept = 0, colour = INK$muted, linewidth = 0.3) +
    geom_point(shape = 21, colour = INK$surface, size = 1.8, stroke = 0.4) +
    scale_fill_manual(values = TOKEN_COLOURS) +
    scale_x_sqrt(labels = scales::label_percent()) +
    scale_y_sqrt(labels = scales::label_percent()) +
    labs(title = paste(exchange, "reciprocity against degree-preserving random networks"),
         subtitle = paste0("One point per token with at least ", NULL_MODEL_MIN_TRADES,
                           " trades; points above the line are more reciprocal than chance"),
         x = paste("Mean reciprocity of", NULL_MODEL_COPIES, "rewired copies"), y = "Observed reciprocity") +
    theme_report()
  save_figure(plot, path)
}

wash_neighbourhood <- function(graph, wash_members, max_nodes = 300) {
  wash <- intersect(V(graph)$name, wash_members)
  neighbours <- unique(unlist(lapply(adjacent_vertices(graph, wash, mode = "all"), names)))
  keep <- union(wash, neighbours)
  if (length(keep) > max_nodes) {
    ranked <- setdiff(names(sort(strength(graph, keep), decreasing = TRUE)), wash)
    keep <- union(wash, head(ranked, max_nodes - length(wash)))
  }
  induced_subgraph(graph, keep)
}

token_network <- function(graph, wash_members, path, exchange, token) {
  g <- wash_neighbourhood(graph, wash_members)
  V(g)$group <- account_group(V(g)$name %chin% wash_members)
  V(g)$trades <- strength(g, mode = "all")
  set.seed(RANDOM_SEED)
  plot <- ggraph(g, layout = "fr") +
    geom_edge_link(aes(edge_width = log10(weight + 1)), colour = INK$axis, alpha = 0.6, show.legend = FALSE) +
    scale_edge_width(range = c(0.15, 1.2)) +
    geom_node_point(aes(fill = group, size = log10(trades + 1)), shape = 21, colour = INK$surface, stroke = 0.4) +
    scale_fill_manual(values = GROUP_COLOURS) +
    scale_size(range = c(1.5, 5.5), guide = "none") +
    labs(title = paste(exchange, "wash-trading accounts and their trading partners"),
         subtitle = paste0("Token ", substr(token, 1, 10), "..., node size shows trades, edges join accounts that traded"),
         caption = "Only the wash-trading accounts and their direct partners in this token are shown") +
    theme_report() +
    theme(axis.line = element_blank(), axis.text = element_blank(), axis.title = element_blank(),
          panel.grid.major = element_blank()) +
    guides(fill = guide_legend(override.aes = list(size = 3)))
  save_figure(plot, path, width = 6.5, height = 5.5)
}

monthly_metrics_plot <- function(monthly, path, exchange) {
  data <- melt(monthly, id.vars = "month", measure.vars = names(MONTHLY_PANELS), variable.name = "metric")
  data[, `:=`(date = as.IDate(paste0(month, "-01")), metric = factor(MONTHLY_PANELS[as.character(metric)], levels = MONTHLY_PANELS))]
  kyc <- as.IDate(paste0(KYC_MONTH, "-01"))
  plot <- ggplot(data, aes(date, value)) +
    geom_vline(xintercept = kyc, colour = INK$muted, linewidth = 0.3) +
    geom_line(colour = GROUP_COLOURS[["Other accounts"]], linewidth = 0.7) +
    facet_wrap(~metric, ncol = 2, scales = "free_y") +
    scale_x_date(date_labels = "%Y") +
    labs(title = paste(exchange, "network structure by month"),
         subtitle = "Vertical line marks July 2019, when IDEX introduced identity verification (KYC)",
         x = NULL, y = NULL) +
    theme_report()
  save_figure(plot, path, width = 6.5, height = 6)
}

make_figures <- function(exchange) {
  dir.create(FIGURES_DIR, recursive = TRUE, showWarnings = FALSE)
  accounts <- read_fst(accounts_path(exchange), as.data.table = TRUE)[self_trader == FALSE | wash == TRUE]
  tokens <- fread(table_path(exchange, "token_profiles"))
  monthly <- fread(table_path(exchange, "monthly_metrics"), colClasses = list(character = "month"))

  labelled <- load_labels(exchange, c("token", "seller", "buyer", "wash"))
  members <- wash_members_by_token(labelled)
  busiest <- labelled[wash == TRUE, .N, by = token][order(-N)]$token[1]

  c(
    degree_distribution(accounts, figure_path(exchange, "degree_distribution"), exchange),
    strength_vs_degree(accounts, figure_path(exchange, "strength_vs_degree"), exchange),
    reciprocity_vs_null(tokens, figure_path(exchange, "reciprocity_vs_null"), exchange),
    token_network(token_graph(load_edges(exchange, "token"), busiest), members[[busiest]],
                  figure_path(exchange, "token_network"), exchange, busiest),
    monthly_metrics_plot(monthly, figure_path(exchange, "monthly_metrics"), exchange)
  )
}
