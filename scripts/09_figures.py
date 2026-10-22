from washtrading.cli import exchange_args
from washtrading.config import FIGURES_DIR
from washtrading.plots import make_figures


def main():
    args = exchange_args("Figures for the reports")
    FIGURES_DIR.mkdir(parents=True, exist_ok=True)
    for exchange in args.exchange:
        for path in make_figures(exchange):
            print(path)


if __name__ == "__main__":
    main()
