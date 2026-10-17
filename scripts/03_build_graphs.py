from washtrading.cli import exchange_args
from washtrading.config import graphs_dir
from washtrading.graphs import account_graph, monthly_snapshots, save_graph, token_graphs
from washtrading.load import load_trades


def main():
    args = exchange_args("Build token graphs, the account graph and monthly snapshots")
    for exchange in args.exchange:
        trades = load_trades(exchange)
        out = graphs_dir(exchange)
        for token, graph in token_graphs(trades):
            save_graph(graph, out / "tokens" / f"{token}.pkl")
        save_graph(account_graph(trades), out / "accounts.pkl")
        for month, graph in monthly_snapshots(trades):
            save_graph(graph, out / "monthly" / f"{month}.pkl")


if __name__ == "__main__":
    main()
