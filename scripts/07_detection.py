from washtrading.cli import exchange_args
from washtrading.config import TABLES_DIR
from washtrading.detection import detection_results


def main():
    args = exchange_args("RQ4: network-metric detection score")
    TABLES_DIR.mkdir(parents=True, exist_ok=True)
    for exchange in args.exchange:
        evaluation, candidates = detection_results(exchange)
        evaluation.to_csv(TABLES_DIR / f"{exchange}_detection_evaluation.csv", index=False)
        candidates.to_csv(TABLES_DIR / f"{exchange}_new_candidates.csv", index=False)


if __name__ == "__main__":
    main()
