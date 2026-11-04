md5_matches <- function(path, expected_md5) {
  file.exists(path) && unname(tools::md5sum(path)) == expected_md5
}

download_file <- function(name, expected_md5) {
  target <- file.path(RAW_DIR, name)
  if (md5_matches(target, expected_md5)) return(target)

  options(timeout = max(7200, getOption("timeout")))
  download.file(sprintf("%s/%s?download=1", ZENODO_FILES_URL, name), target, mode = "wb")

  if (!md5_matches(target, expected_md5)) {
    stop("Checksum mismatch for ", name, ", delete it and download again", call. = FALSE)
  }
  target
}

download_all <- function() {
  dir.create(RAW_DIR, recursive = TRUE, showWarnings = FALSE)
  unname(mapply(download_file, names(RAW_FILES), RAW_FILES))
}
