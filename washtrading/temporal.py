import igraph as ig
import pandas as pd

from .config import KYC_MONTH, KYC_WINDOW_MONTHS


def monthly_metrics(snapshots: dict[str, ig.Graph]) -> pd.DataFrame:
    raise NotImplementedError


def monthly_wash_share(labelled: pd.DataFrame) -> pd.Series:
    raise NotImplementedError


def before_after(
    monthly: pd.DataFrame,
    event_month: str = KYC_MONTH,
    window: int = KYC_WINDOW_MONTHS,
) -> pd.DataFrame:
    raise NotImplementedError


def temporal_table(exchange: str) -> pd.DataFrame:
    raise NotImplementedError
