import igraph as ig
import pandas as pd


def degree_table(graph: ig.Graph) -> pd.DataFrame:
    raise NotImplementedError


def average_degree(graph: ig.Graph) -> float:
    raise NotImplementedError


def density(graph: ig.Graph) -> float:
    raise NotImplementedError


def reciprocity(graph: ig.Graph) -> float:
    raise NotImplementedError


def trades_per_partner(graph: ig.Graph) -> pd.Series:
    raise NotImplementedError


def betweenness(graph: ig.Graph) -> pd.Series:
    raise NotImplementedError


def pagerank(graph: ig.Graph) -> pd.Series:
    raise NotImplementedError


def largest_scc_share(graph: ig.Graph) -> float:
    raise NotImplementedError


def coreness(graph: ig.Graph) -> pd.Series:
    raise NotImplementedError


def clustering(graph: ig.Graph) -> float:
    raise NotImplementedError


def degree_assortativity(graph: ig.Graph) -> float:
    raise NotImplementedError


def graph_summary(graph: ig.Graph) -> dict:
    raise NotImplementedError


def account_summary(graph: ig.Graph) -> pd.DataFrame:
    raise NotImplementedError
