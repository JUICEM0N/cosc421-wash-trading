import igraph as ig
import pandas as pd

from .config import POSITION_MARGIN, SCC_THRESHOLD, WASH_WINDOWS_SECONDS


def iterative_scc_counts(graph: ig.Graph) -> dict[frozenset, int]:
    raise NotImplementedError


def candidate_sccs(counts: dict[frozenset, int], threshold: int = SCC_THRESHOLD) -> list[frozenset]:
    raise NotImplementedError


def net_positions(trades: pd.DataFrame) -> dict[str, float]:
    raise NotImplementedError


def match_volumes(trades: pd.DataFrame, margin: float = POSITION_MARGIN) -> pd.Index:
    raise NotImplementedError


def label_token(
    trades: pd.DataFrame,
    candidates: list[frozenset],
    windows: tuple[int, ...] = WASH_WINDOWS_SECONDS,
    margin: float = POSITION_MARGIN,
) -> pd.Series:
    raise NotImplementedError


def label_exchange(exchange: str) -> pd.DataFrame:
    raise NotImplementedError


def wash_accounts(labelled: pd.DataFrame) -> set[str]:
    raise NotImplementedError


def validation_summary(labelled: pd.DataFrame, exchange: str) -> dict:
    raise NotImplementedError
