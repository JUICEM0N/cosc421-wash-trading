from washtrading.cli import exchange_args
from washtrading.config import TABLES_DIR
from washtrading.temporal import before_after, temporal_table


def main():
    args = exchange_args("RQ5: monthly network metrics and the IDEX KYC comparison")
    TABLES_DIR.mkdir(parents=True, exist_ok=True)
    for exchange in args.exchange:
        monthly = temporal_table(exchange)
        monthly.to_csv(TABLES_DIR / f"{exchange}_monthly_metrics.csv", index=False)
        if exchange == "IDEX":
            before_after(monthly).to_csv(TABLES_DIR / "IDEX_kyc_before_after.csv", index=False)


if __name__ == "__main__":
    main()
