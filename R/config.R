RAW_DIR <- file.path("data", "raw")
PROCESSED_DIR <- file.path("data", "processed")
FIGURES_DIR <- file.path("outputs", "figures")
TABLES_DIR <- file.path("outputs", "tables")

ZENODO_FILES_URL <- "https://zenodo.org/records/4540223/files"
RAW_FILES <- c(
  IDEXTrades.csv = "497b9c3622c47d51d7db1119fbd49b78",
  EtherDeltaTrades.csv = "0c5c6c9a05c2833b82095503254fccb5",
  EtherDollarPrice.csv = "b47e050a7e3a7a828af19acd717c70eb",
  token_decimals.json = "9edd0f4213fc9feaaf1a5303d004adce"
)

EXCHANGES <- c("IDEX", "EtherDelta")
TRADE_FILES <- c(IDEX = "IDEXTrades.csv", EtherDelta = "EtherDeltaTrades.csv")
ETH_ADDRESS <- "0x0000000000000000000000000000000000000000"
DEFAULT_TOKEN_DECIMALS <- 18

SCC_THRESHOLD <- 100
POSITION_MARGIN <- 0.01
WASH_WINDOWS_SECONDS <- c(3600, 86400, 604800)
PUBLISHED_WASH_ACCOUNTS <- c(IDEX = 659, EtherDelta = 5533)

NULL_MODEL_COPIES <- 100
NULL_MODEL_MIN_TRADES <- 50
REWIRE_SWAPS_PER_EDGE <- 10

KYC_MONTH <- "2019-07"
KYC_WINDOW_MONTHS <- 3

RANDOM_SEED <- 421

exchange_dir <- function(exchange) file.path(PROCESSED_DIR, exchange)
trades_path <- function(exchange) file.path(exchange_dir(exchange), "trades.fst")
edges_path <- function(exchange, scope) file.path(exchange_dir(exchange), paste0("edges_", scope, ".fst"))
labels_path <- function(exchange) file.path(exchange_dir(exchange), "wash_trades.fst")
sccs_path <- function(exchange) file.path(exchange_dir(exchange), "candidate_sccs.fst")
accounts_path <- function(exchange) file.path(exchange_dir(exchange), "account_profiles.fst")
isolation_path <- function(exchange) file.path(exchange_dir(exchange), "account_communities.fst")
table_path <- function(exchange, name) file.path(TABLES_DIR, paste0(exchange, "_", name, ".csv"))
figure_path <- function(exchange, name) file.path(FIGURES_DIR, paste0(exchange, "_", name, ".png"))
