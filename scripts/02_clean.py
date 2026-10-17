from washtrading.clean import clean_exchange
from washtrading.cli import exchange_args
from washtrading.config import exchange_dir, trades_path


def main():
    args = exchange_args("Clean raw trades and add USD volume")
    for exchange in args.exchange:
        exchange_dir(exchange).mkdir(parents=True, exist_ok=True)
        trades = clean_exchange(exchange)
        trades.to_parquet(trades_path(exchange), index=False)
        print(exchange, len(trades), "trades kept")


if __name__ == "__main__":
    main()
