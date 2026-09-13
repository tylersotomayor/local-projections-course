# P{{N}} lab project — {{PRACTICUM_TITLE}}

The runnable companion to **Practicum {{N}}** of *Local Projections: From First
Principles to Empirical Research*. Tested in batch with StataNow/SE 19.5.

## Setup

```stata
ssc install coefplot, replace   // if not installed
cd "p{{N}}-{{SLUG_REST}}-lab"
do master.do
```

`master.do` runs `tests/checks.do` (network-free assertions on the data and
the helper programs), then `replication/rep{{N}}.do`, then
`starter/pset.do` if you have completed it, or `solution/pset_solution.do`
when called with the `solution` argument. Every output lands in `output/`
with a log. Expected runtime: {{RUNTIME}}.

## Layout

```text
p{{N}}-{{SLUG_REST}}-lab/
├── master.do
├── README.md
├── data/
│   ├── raw/                 # untouched inputs
│   └── PROVENANCE.md        # source, version, vintage, license, terms
├── replication/rep{{N}}.do  # reproduces the target
├── starter/pset.do          # the problem set with TASK markers
├── solution/pset_solution.do
├── tests/checks.do          # assertions master.do runs first
├── handoff/                 # where the browser lab's exported record goes
└── output/                  # generated; safe to delete
```

## Provenance

See `data/PROVENANCE.md`. Published data are redistributed only where the
original package permits it; otherwise the file documents the acquisition
steps and `data/raw/` contains a script that performs them.

## What "done" means

The replication reproduces the target within the stated tolerance; every
assertion in `tests/checks.do` and in the solution passes; the interpretation
record answers estimand, assumptions, units, uncertainty, and limitations.
