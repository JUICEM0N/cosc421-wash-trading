import igraph as ig
import pandas as pd


def louvain(graph: ig.Graph) -> ig.VertexClustering:
    raise NotImplementedError


def infomap(graph: ig.Graph) -> ig.VertexClustering:
    raise NotImplementedError


def modularity(graph: ig.Graph, clustering: ig.VertexClustering) -> float:
    raise NotImplementedError


def normalized_mutual_information(clustering: ig.VertexClustering, labels: pd.Series) -> float:
    raise NotImplementedError


def purity(clustering: ig.VertexClustering, labels: pd.Series) -> float:
    raise NotImplementedError


def community_isolation(graph: ig.Graph, clustering: ig.VertexClustering) -> pd.Series:
    raise NotImplementedError


def community_table(exchange: str) -> pd.DataFrame:
    raise NotImplementedError
