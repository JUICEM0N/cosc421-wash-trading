import argparse

from .config import EXCHANGES


def exchange_args(description: str) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("--exchange", choices=EXCHANGES, nargs="+", default=list(EXCHANGES))
    return parser.parse_args()
