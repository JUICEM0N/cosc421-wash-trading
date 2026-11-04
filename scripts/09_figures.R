source("R/setup.R")

for (exchange in exchange_args("Figures for the reports")) {
  for (path in make_figures(exchange)) cat(path, "\n")
}
