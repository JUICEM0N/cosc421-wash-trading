import pandas as pd

from .config import NULL_MODEL_MIN_TRADES


def token_profiles(exchange: str, min_trades_for_nulls: int = NULL_MODEL_MIN_TRADES) -> pd.DataFrame:
    raise NotImplementedError


def account_profiles(exchange: str) -> pd.DataFrame:
    raise NotImplementedError


def compare_wash_vs_organic(tokens: pd.DataFrame, accounts: pd.DataFrame) -> pd.DataFrame:
    raise NotImplementedError
