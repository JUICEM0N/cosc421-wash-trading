import pandas as pd

LABEL_DERIVED_FEATURES = ("reciprocity", "in_largest_scc")


def account_features(exchange: str) -> pd.DataFrame:
    raise NotImplementedError


def detection_score(features: pd.DataFrame, exclude: tuple[str, ...] = ()) -> pd.Series:
    raise NotImplementedError


def evaluate(scores: pd.Series, labels: pd.Series, top_k: int | None = None) -> dict:
    raise NotImplementedError


def new_candidates(scores: pd.Series, labels: pd.Series, top_k: int = 20) -> pd.DataFrame:
    raise NotImplementedError


def detection_results(exchange: str) -> tuple[pd.DataFrame, pd.DataFrame]:
    raise NotImplementedError
