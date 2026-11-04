source("R/setup.R")

for (path in download_all()) cat(path, "\n")
