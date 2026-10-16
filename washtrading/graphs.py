from collections.abc import Iterator
from pathlib import Path

import igraph as ig
import pandas as pd


def token_graph(trades: pd.DataFrame, token: str, keep_self_trades: bool = True) -> ig.Graph:
    raise NotImplementedError


def token_graphs(trades: pd.DataFrame, min_trades: int = 1) -> Iterator[tuple[str, ig.Graph]]:
    raise NotImplementedError


def account_graph(trades: pd.DataFrame, keep_self_trades: bool = True) -> ig.Graph:
    raise NotImplementedError


def monthly_snapshots(trades: pd.DataFrame) -> Iterator[tuple[str, ig.Graph]]:
    raise NotImplementedError


def collapse_multi_edges(graph: ig.Graph) -> ig.Graph:
    raise NotImplementedError


def save_graph(graph: ig.Graph, path: Path) -> None:
    raise NotImplementedError


def load_graph(path: Path) -> ig.Graph:
    raise NotImplementedError


def load_token_graphs(exchange: str) -> Iterator[tuple[str, ig.Graph]]:
    raise NotImplementedError


def load_monthly_snapshots(exchange: str) -> Iterator[tuple[str, ig.Graph]]:
    raise NotImplementedError
