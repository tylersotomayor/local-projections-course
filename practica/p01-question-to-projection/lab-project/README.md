# P01 lab project — Recover the Basic LP Estimator

The runnable companion to **Practicum 01** of *Local Projections: From First
Principles to Empirical Research*: replication lab REP01, Stata problem set
STA01, and the handoff from the Shock-to-Response Explorer. Tested in batch
with StataNow/SE 19.5.

## Setup

No user-written commands are needed; everything runs on built-in Stata.

```stata
cd "lab-project"
do master.do
```

`master.do` runs `tests/checks.do` (network-free assertions on the data and
the helper programs), then `replication/rep01.do`, then `starter/pset.do`,
then `handoff/check_handoff.do`. The first failed check stops the run. Every
output lands in `output/` with a log, and `output/assertions.csv` lists every
check and its result. Expected runtime in StataNow/SE 19.5 with the defaults:
about 30 seconds for the checks and REP01, and about 30 seconds more for a
completed problem set, including Task 5's download of the Ramey–Zubairy data.
The instructor build, with `R = 500`, took 137 seconds.

The solved problem set is included, as `solution/pset_solution.do`. Open it
after you have attempted every task. `do master.do solution` runs it in place
of `starter/pset.do`, at `R = 500` unless you set `R` yourself.

While you work on the problem set, run `do starter/pset.do` on its own from
this folder.

## Layout

```text
lab-project/
├── master.do
├── README.md
├── data/
│   ├── raw/                     # untouched inputs
│   │   ├── hand_table.csv       # the Lecture 01 hand table (seed 1)
│   │   ├── onedraw_rho05_seed2.csv
│   │   ├── onedraw_rho09_seed2.csv
│   │   ├── make_sim_data.do     # regenerates the three CSV files
│   │   └── get_rz.do            # fetches and verifies the Ramey-Zubairy data
│   └── PROVENANCE.md            # source, version, vintage, license, terms
├── helpers/lp_helpers.do        # lp_assert, lp_close, lp_sha256, lp_json_get
├── replication/
│   ├── rep01.do                 # reproduces the target
│   └── benchmark/               # the two reference files and their provenance
├── vendor/jel-code/             # the authors' CC0 files; only their folder paths are commented out
├── starter/pset.do              # the problem set with TASK markers
├── solution/pset_solution.do    # the solved problem set; open it after your attempt
├── tests/checks.do              # assertions master.do runs first
├── handoff/                     # the Explorer's record (a sample ships), its check, README
└── output/                      # generated; safe to delete
```

## Globals

| Global | Default | Effect |
|---|---|---|
| `R` | 200 (500 with `do master.do solution`) | Monte Carlo draws in REP01 and Task 4 (editor decision D2) |
| `AUTHOR_CHECK` | 1 | also runs the authors' script at the same `R` and compares it with `rep01.do` |

Set them before running, for example `global R 500` then `do master.do`.

## Provenance

See `data/PROVENANCE.md`. Published data are redistributed only where the
original package permits it. The authors' Example 1 files are CC0 and ship in
`vendor/jel-code/`. Ramey and Zubairy state no redistribution license, so
`data/raw/get_rz.do` downloads their February 2018 package from the authors'
link, checks the SHA-256 of `RZDAT.xlsx` and `rzdatnew.csv`, and prints the
manual steps if the download fails.

## What "done" means

The replication reproduces the target within the stated tolerance: every mean
within 1e-6 of the reference with the same number of draws, and within three
Monte Carlo standard errors of the authors' 10,000-draw means. Every assertion
in `tests/checks.do`, `replication/rep01.do`, `starter/pset.do`, and
`handoff/check_handoff.do` passes, and `output/master.log` ends in
`MASTER COMPLETE`. The interpretation record answers estimand, assumptions,
units, uncertainty, and limitations.
