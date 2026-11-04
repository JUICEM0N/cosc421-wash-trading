# Detecting Wash Trading in Cryptocurrency Trading Networks

COSC 421 term project by Jonah Marvin and Sebastian Csizmazia.

We build trade networks from the IDEX and EtherDelta trade histories released by Victor and Weintraud (2021), label wash trading with their method, and test whether standard network metrics can pick out the accounts behind it.

## Setup

R 4.5 or newer. Open `cosc421-wash-trading.Rproj` in RStudio, or work from the project root in a terminal, then install the packages once:

```
Rscript install.R
```

## Data

```
Rscript scripts/01_download.R
```

This downloads four files from [Zenodo record 4540223](https://zenodo.org/records/4540223) into `data/raw` (about 3.2 GB) and checks each one against its published checksum. Data files are not tracked by git.

| File | Contents |
| --- | --- |
| IDEXTrades.csv | All IDEX trades, Sep 2017 to May 2020 |
| EtherDeltaTrades.csv | All EtherDelta trades, Feb 2017 to May 2020 |
| EtherDollarPrice.csv | Daily ETH to USD price |
| token_decimals.json | Decimal places for each token |

## Pipeline

Run the scripts in order from the project root. Each step reads what the step before it wrote to `data/processed`.

| Script | What it does |
| --- | --- |
| 01_download.R | Download the raw data |
| 02_clean.R | Rescale token amounts, keep ETH to token trades, add USD volume |
| 03_build_graphs.R | Build the token, account and monthly edge lists |
| 04_label.R | Label wash trades with SCC counting and volume matching |
| 05_profile.R | RQ1 and RQ3: reciprocity, trades per partner, centrality, null models |
| 06_communities.R | RQ2: Louvain, Infomap and agreement with the labels |
| 07_detection.R | RQ4: detection score and evaluation |
| 08_temporal.R | RQ5: monthly metrics and the July 2019 KYC comparison |
| 09_figures.R | Figures for the reports |

Steps 02 to 09 take `--exchange IDEX`, `--exchange EtherDelta`, or both by default, for example:

```
Rscript scripts/04_label.R --exchange EtherDelta
```

Method parameters (SCC threshold, position margin, time windows, null model settings) are in `R/config.R`.

`Rscript tests/test_labels.R` checks the labelling on small hand-built trade sets.

## Layout

| Folder | Contents |
| --- | --- |
| R | Project code, one file per stage |
| scripts | Pipeline steps |
| tests | Checks for the labelling method |
| data/raw | Downloaded files |
| data/processed | Cleaned trades, edge lists and labels for each exchange |
| outputs/figures | Figures for the reports |
| outputs/tables | Tables for the reports |
| notebooks | Exploration |
| reports | Proposal, progress report and final report |

## Notes

The original authors recommend at least 32 GB of RAM for the full IDEX label pass. Steps read only the columns they need from `data/processed`, and the labelling works through one token at a time.

## Reference

Victor, F. and Weintraud, A. M. (2021). Detecting and Quantifying Wash Trading on Decentralized Cryptocurrency Exchanges. Proceedings of the Web Conference 2021. [Paper](https://arxiv.org/abs/2102.07001), [data](https://zenodo.org/records/4540223), [code](https://github.com/friedhelmvictor/lob-dex-wash-trading-paper).
