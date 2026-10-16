from pathlib import Path

import igraph as ig
import pandas as pd


def degree_distribution(degrees: pd.DataFrame, path: Path) -> None:
    raise NotImplementedError


def strength_vs_degree(accounts: pd.DataFrame, path: Path) -> None:
    raise NotImplementedError


def reciprocity_vs_null(tokens: pd.DataFrame, path: Path) -> None:
    raise NotImplementedError


def token_network(graph: ig.Graph, wash_accounts: set[str], path: Path) -> None:
    raise NotImplementedError


def monthly_metrics(monthly: pd.DataFrame, path: Path) -> None:
    raise NotImplementedError


def make_figures(exchange: str) -> list[Path]:
    raise NotImplementedError
