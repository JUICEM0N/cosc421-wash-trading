from washtrading.cli import exchange_args
from washtrading.communities import community_table
from washtrading.config import TABLES_DIR


def main():
    args = exchange_args("RQ2: Louvain and Infomap communities against the wash labels")
    TABLES_DIR.mkdir(parents=True, exist_ok=True)
    for exchange in args.exchange:
        table = community_table(exchange)
        table.to_csv(TABLES_DIR / f"{exchange}_communities.csv", index=False)


if __name__ == "__main__":
    main()
