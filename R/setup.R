suppressWarnings(suppressPackageStartupMessages({
  library(data.table)
  library(fstcore)
  library(fst)
  library(igraph)
  library(ggplot2)
  library(ggraph)
}))

for (module in setdiff(list.files("R", pattern = "\\.R$", full.names = TRUE), "R/setup.R")) {
  source(module)
}
