from washtrading.cli import exchange_args
from washtrading.config import TABLES_DIR, exchange_dir
from washtrading.profile import account_profiles, compare_wash_vs_organic, token_profiles


def main():
    args = exchange_args("RQ1 and RQ3: structural profile of wash and organic trading")
    TABLES_DIR.mkdir(parents=True, exist_ok=True)
    for exchange in args.exchange:
        tokens = token_profiles(exchange)
        accounts = account_profiles(exchange)
        tokens.to_csv(TABLES_DIR / f"{exchange}_token_profiles.csv", index=False)
        accounts.to_parquet(exchange_dir(exchange) / "account_profiles.parquet", index=False)
        comparison = compare_wash_vs_organic(tokens, accounts)
        comparison.to_csv(TABLES_DIR / f"{exchange}_profile_comparison.csv", index=False)


if __name__ == "__main__":
    main()
