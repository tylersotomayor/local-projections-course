# REP01 benchmarks

Two reference files, each compared with `replication/rep01.do`'s own means at
an absolute tolerance of $10^{-6}$ when the draw counts match.

## REP01-levels-lp.csv

The course benchmark for REP01, copied unchanged from the course's replication
infrastructure (`replication-packages/benchmarks/REP01-levels-lp.csv`, with its
provenance note `REP01-levels-lp.README.md` beside it here).

- Produced by the authors' `Example1_LongDifferences/SSBias_IntcpYLagdiffN_95.do`,
  lines 83–89 (levels regressions), 125–128 and 139–140 (stored draws and
  Monte Carlo mean), driven by `all-simulate.do` lines 18–44 with one change:
  line 19, `nreps` 10,000 → 500.
- Software: Stata/SE 18.5.
- Columns used: `horizon`, `coefficient` (the mean of 500 draws), `true_response`
  ($0.95^h$ as stored in float), `n` ($99-h$, derived from the construction; the
  authors store no `e(N)`).
- Standard errors are blank because the authors' code keeps none.
- SHA-256 `1899da92df8a682ec9e13a45c7d9bebf307d2ccce78e71f31d4e9eb135ccdb30`.

## REP01-author-R200-v195.csv

The authors' script at the student default of 200 draws, so that a student
run can be checked exactly.

- Produced on 2026-09-13 in StataNow/SE 19.5 by the authors'
  `SSBias_IntcpYLagdiffN_95.do` as they ship it (the copy in `vendor/jel-code/`
  differs only in its commented-out `cap cd` lines), with
  `global nobs 100` and `global nreps 200` set beforehand, then
  `keep t rl rt`, `rename t h`, and `export delimited h rl rt, datafmt` with
  `%12.8f` formats.
- Columns: `h`, `rl` (mean of the levels-LP estimates over 200 draws), `rt`
  (true response).
- The same values came out of an earlier independent run of the same script
  (the Lecture 01 planning run); the largest difference was 0.
- SHA-256 `72cea43bb335f4c572c1ab3fcc97d8ec1a740278ae059593f447edf5341346c5`.
