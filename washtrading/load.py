import pandas as pd

from .config import RAW_DIR, TRADE_FILES

IDEX_COLUMNS = [
    "transaction_hash",
    "status",
    "block_number",
    "timestamp",
    "amountBuy",
    "amountSell",
    "amount",
    "tokenBuy",
    "tokenSell",
    "maker",
    "taker",
]

ETHERDELTA_COLUMNS = [
    "transaction_hash",
    "block_number",
    "timestamp",
    "tokenGet",
    "amountGet",
    "tokenGive",
    "amountGive",
    "get",
    "give",
]

RAW_COLUMNS = {"IDEX": IDEX_COLUMNS, "EtherDelta": ETHERDELTA_COLUMNS}


def load_raw_trades(exchange: str, columns: list[str] | None = None) -> pd.DataFrame:
    raise NotImplementedError


def load_token_decimals() -> dict[str, int]:
    raise NotImplementedError


def load_eth_prices() -> pd.DataFrame:
    raise NotImplementedError


def load_trades(exchange: str, columns: list[str] | None = None) -> pd.DataFrame:
    raise NotImplementedError
