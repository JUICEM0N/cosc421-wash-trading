from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = ROOT / "data" / "raw"
PROCESSED_DIR = ROOT / "data" / "processed"
FIGURES_DIR = ROOT / "outputs" / "figures"
TABLES_DIR = ROOT / "outputs" / "tables"

ZENODO_FILES_URL = "https://zenodo.org/records/4540223/files"
RAW_FILES = {
    "IDEXTrades.csv": "497b9c3622c47d51d7db1119fbd49b78",
    "EtherDeltaTrades.csv": "0c5c6c9a05c2833b82095503254fccb5",
    "EtherDollarPrice.csv": "b47e050a7e3a7a828af19acd717c70eb",
    "token_decimals.json": "9edd0f4213fc9feaaf1a5303d004adce",
}

EXCHANGES = ("IDEX", "EtherDelta")
TRADE_FILES = {"IDEX": "IDEXTrades.csv", "EtherDelta": "EtherDeltaTrades.csv"}
ETH_ADDRESS = "0x0000000000000000000000000000000000000000"
DEFAULT_TOKEN_DECIMALS = 18

SCC_THRESHOLD = 100
POSITION_MARGIN = 0.01
WASH_WINDOWS_SECONDS = (3600, 86400, 604800)

NULL_MODEL_COPIES = 100
NULL_MODEL_MIN_TRADES = 50
REWIRE_SWAPS_PER_EDGE = 10

KYC_MONTH = "2019-07"
KYC_WINDOW_MONTHS = 3

RANDOM_SEED = 421


def exchange_dir(exchange: str) -> Path:
    return PROCESSED_DIR / exchange


def trades_path(exchange: str) -> Path:
    return exchange_dir(exchange) / "trades.parquet"


def graphs_dir(exchange: str) -> Path:
    return exchange_dir(exchange) / "graphs"


def labels_path(exchange: str) -> Path:
    return exchange_dir(exchange) / "wash_trades.parquet"
