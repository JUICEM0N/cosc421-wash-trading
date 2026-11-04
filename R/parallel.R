WORKERS <- max(1, parallel::detectCores() - 2)

parallel_map <- function(items, f, ..., workers = WORKERS) {
  if (workers < 2 || length(items) < 2) return(lapply(items, f, ...))
  cluster <- parallel::makeCluster(min(workers, length(items)))
  on.exit(parallel::stopCluster(cluster))
  parallel::clusterCall(cluster, setwd, getwd())
  parallel::clusterEvalQ(cluster, source("R/setup.R"))
  parallel::parLapplyLB(cluster, items, f, ..., chunk.size = 1)
}

largest_first <- function(graphs) graphs[order(-vapply(graphs, ecount, numeric(1)))]
