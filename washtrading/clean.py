import pandas as pd

from .config import DEFAULT_TOKEN_DECIMALS, ETH_ADDRESS


def rescale_amounts(trades: pd.DataFrame, decimals: dict[str, int], exchange: str) -> pd.DataFrame:
    raise NotImplementedError


def derive_idex_filled_amounts(trades: pd.DataFrame) -> pd.DataFrame:
    raise NotImplementedError


def standardise_columns(trades: pd.DataFrame, exchange: str) -> pd.DataFrame:
    raise NotImplementedError


def keep_eth_token_trades(trades: pd.DataFrame) -> pd.DataFrame:
    raise NotImplementedError


def orient_seller_to_buyer(trades: pd.DataFrame) -> pd.DataFrame:
    raise NotImplementedError


def add_usd_volume(trades: pd.DataFrame, prices: pd.DataFrame) -> pd.DataFrame:
    raise NotImplementedError


def clean_exchange(exchange: str) -> pd.DataFrame:
    raise NotImplementedError


def cleaning_summary(raw: pd.DataFrame, cleaned: pd.DataFrame) -> dict:
    raise NotImplementedError
