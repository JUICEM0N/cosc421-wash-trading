from washtrading.cli import exchange_args
from washtrading.config import labels_path
from washtrading.labels import label_exchange, validation_summary


def main():
    args = exchange_args("Label wash trades with SCC counting and volume matching")
    for exchange in args.exchange:
        labelled = label_exchange(exchange)
        labelled.to_parquet(labels_path(exchange), index=False)
        print(exchange, validation_summary(labelled, exchange))


if __name__ == "__main__":
    main()
