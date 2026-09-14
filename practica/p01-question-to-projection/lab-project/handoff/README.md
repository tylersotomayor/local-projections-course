# The Explorer handoff

The last section of the
[Shock-to-Response Explorer](../../../../interactives/01-shock-to-response-explorer.qmd),
"Transfer to Stata," turns what you did in the browser into three files. Put
them in this folder, replacing the sample, and run `do master.do`; the last
step, `handoff/check_handoff.do`, reruns in Stata what the browser computed.

## What the Explorer exports

| File | What it holds |
|---|---|
| `l01-explorer-handoff.json` | Your predictions for Labs 1–3, your Lab 4 hypothesis, the settings of all four labs when you downloaded it, the browser's numbers for those settings, and the Stata lines that check them (`stata_checks`) |
| `hand_table.csv` | The twelve-period economy (`t s v y`), written exactly as Stata's `export delimited` writes it |
| `onedraw_rho09_seed2.csv` or `onedraw_rho05_seed2.csv` | The draw Lab 3 used (`t s v y`), chosen by its $\rho$ setting |

The record is `JSON.stringify(record, null, 2)`: one key or array element per
line. The entries that feed Stata:

| Key | Meaning |
|---|---|
| `lab2.settings.h`, `.control_y_lag`, `.single_episode` | Lab 2's horizon, whether $y_{t-1}$ was included, and whether only the $t=5$ intervention was kept |
| `lab2.T_h`, `lab2.beta_h` | The browser's row count and slope for those settings (slope rounded to six decimals) |
| `lab3.settings.rho`, `.T`, `.control_y_lag`; `lab3.file` | Lab 3's draw, the first $T$ periods used, and the control choice |
| `lab3.beta_h`, `lab3.T_h` | Thirteen slopes and row counts, $h=0,\dots,12$ |
| `lab4.settings.h`, `.controls`, `.rows` | Lab 4's horizon, `toy` (one lag of $y$) or `rz` (four lags each of news, $y$, $g$), and `full`, `drop1941q4`, `drop1950q3`, `dropboth`, or `from1947q1` |
| `lab4.stored.beta_h`, `.T_h`, `.beta_h_full_sample`, `.T_h_full_sample` | The stored Stata estimates the browser displayed |
| `lab4.hypothesis` | Your written hypothesis about the $h=8$ estimate without 1950Q3 |

## How the project uses it

- **Tasks 1–2** read `handoff/hand_table.csv` when its SHA-256 equals that of
  `data/raw/hand_table.csv`; otherwise they read `data/raw` and say so.
- **Task 3** reads `handoff/onedraw_rho09_seed2.csv` when its values equal the
  shipped draw's.
- **Task 5** prints your Lab 4 hypothesis beside the $h=8$ estimate with and
  without 1950Q3.
- **`check_handoff.do`** reruns every entry above: the Lab 2 regression (row
  count exact, slope within $10^{-6}$), all thirteen Lab 3 regressions, and the
  Lab 4 regression from `RZDAT.xlsx` once Task 5 has downloaded it. It then
  sets the hypothesis against the estimate: the direction (raise, lower,
  unchanged) is read from your words and the first decimal number is taken as
  your predicted value. The verdict is recorded, not graded, in
  `output/handoff-check.csv`; a refuted prediction is a result.

## The sample shipped here

Written by the Explorer's own code (see `data/PROVENANCE.md`, section 5) with
these settings:

| Lab | Settings |
|---|---|
| 1 | intervention at $t=5$ on, $\theta_0=1$, $\rho=0.9$ |
| 2 | $h=2$, no control, all interventions ($T_h=9$, slope 2.050024) |
| 3 | $\rho=0.9$, $T=200$, control on, band shown |
| 4 | $h=8$, one lag of $y$, without 1950Q3 (stored estimate 0.433969 on 495 rows) |

Its Lab 4 hypothesis predicts that dropping 1950Q3 lowers the estimate to about
0.30. The check refutes it: the estimate rises from 0.361906 to 0.433969.
