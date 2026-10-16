from collections.abc import Callable

import igraph as ig
import numpy as np

from .config import NULL_MODEL_COPIES, RANDOM_SEED, REWIRE_SWAPS_PER_EDGE


def rewired_copy(graph: ig.Graph, swaps_per_edge: int = REWIRE_SWAPS_PER_EDGE) -> ig.Graph:
    raise NotImplementedError


def null_distribution(
    graph: ig.Graph,
    metric: Callable[[ig.Graph], float],
    copies: int = NULL_MODEL_COPIES,
    seed: int = RANDOM_SEED,
) -> np.ndarray:
    raise NotImplementedError


def z_score(observed: float, null_values: np.ndarray) -> float:
    raise NotImplementedError
