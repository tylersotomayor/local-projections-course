# Data provenance · Practicum 01 lab project

Every input the lab project reads, where it came from, and on what terms it
travels with the project. Built and checked on 2026-09-13 with StataNow/SE 19.5
(editor decision D1). SHA-256 values come from `shasum -a 256`, the course
convention (D35). `tests/checks.do` asserts the values in sections 1–3 before
anything else runs. The sample handoff files of section 5 are there to be
replaced by your own, so their values are recorded but not asserted.

## 1. Simulated inputs (shipped in `data/raw/`)

The course generated these files; they contain no third-party data. They are
the same observations the [Shock-to-Response Explorer](../../../../interactives/01-shock-to-response-explorer.qmd)
displays in Labs 2 and 3, so a coefficient computed in the browser and in
Stata on them agrees to at least six decimals.

| File | Contents | How it was made | SHA-256 |
|---|---|---|---|
| `hand_table.csv` | 12 rows; `t`, `s` (0–1 intervention), `v` (disturbance rounded to 0.1, float), `y` (double) from $y_t=0.5\,y_{t-1}+s_t+v_t$, $y_0=0$ | `make_sim_data.do`, section 1: `set seed 1`, all `v` drawn before `s` | `d58b48a56e73d38c682ee621250d25c64ce542bc11c73c73da281edb8a98041f` |
| `onedraw_rho05_seed2.csv` | 200 rows; `t`, `s`, `v`, `y` (float) from $y_t=0.5\,y_{t-1}+s_t+v_t$ | `make_sim_data.do`, section 2: `set seed 2`, 300 periods, `s` before `v`, first 100 dropped | `5c85f2054698ca65681045ec0e8092460ae44e10867e30a23dc6f242b47232cd` |
| `onedraw_rho09_seed2.csv` | 200 rows; the same draws with $\rho=0.9$ | as above | `202051448cb02e7ab55f5cf0af399a76d29969b4de6cdb0a2d0699e725aa34cb` |

- **Version and vintage.** Written once on 2026-09-13; seeds fixed before any
  estimate was computed (D32). `tests/checks.do` reruns `make_sim_data.do`
  into a temporary folder and asserts that all three files come back byte for
  byte, so the shipped copies are never modified in place.
- **Terms.** Part of the public course repository. The repository records no
  separate license for them as of 2026-09-13.

## 2. The authors' replication files (shipped in `vendor/jel-code/`)

| Field | Value |
|---|---|
| Source | Jordà and Taylor (2025), "Local Projections," *Journal of Economic Literature* 63(1), 59–110; repository https://github.com/ojorda/JEL-Code |
| Version | commit `655696c1c576b7537c5a939d2c261f0a111ae663`; the supplied `LP_JEL_Replication.zip` is byte-identical |
| Retrieved | 2026-09-13, 16:23 UTC |
| Files | `SSBias_IntcpYLagdiffN_95.do`, `all-simulate.do`, `SSBias_IntcpYLagdiffN_95.dta` (the authors' 10,000-draw means, saved October 29, 2023), `LICENSE` |
| License | CC0 1.0 Universal; redistribution permitted without condition (D5) |
| Third-party material | none in these files (Example 1 simulates its data) |
| Course change | 2026-09-14: the `cap cd` commands naming the authors' own folders (lines 5 and 7 of `SSBias_IntcpYLagdiffN_95.do`, lines 7 and 9 of `all-simulate.do`) are commented out, so that the archive holds no absolute path. They failed silently elsewhere, so the scripts run as before; `vendor/jel-code/SOURCE.md` records both hashes |

Hashes are in `vendor/jel-code/SOURCE.md`.

## 3. Benchmarks (shipped in `replication/benchmark/`)

| File | Source | SHA-256 |
|---|---|---|
| `REP01-levels-lp.csv` | The course's validated REP01 benchmark: the authors' script at 500 draws in Stata/SE 18.5; producing lines in `REP01-levels-lp.README.md` | `1899da92df8a682ec9e13a45c7d9bebf307d2ccce78e71f31d4e9eb135ccdb30` |
| `REP01-author-R200-v195.csv` | The authors' script, unchanged, at 200 draws in StataNow/SE 19.5, 2026-09-13 | `72cea43bb335f4c572c1ab3fcc97d8ec1a740278ae059593f447edf5341346c5` |

Both hold derived Monte Carlo means from CC0 code and ship with the project.

## 4. Ramey and Zubairy (2018): fetched by script, not shipped

Task 5 of the problem set and Lab 4 of the handoff check use Ramey and Zubairy's
quarterly U.S. data.

| Field | Value |
|---|---|
| Source | Ramey and Zubairy (2018), "Government Spending Multipliers in Good Times and in Bad: Evidence from US Historical Data," *Journal of Political Economy* 126(2), 850–901 |
| Author page | https://sites.google.com/site/sarahzubairy/research |
| Archive link | https://drive.google.com/file/d/0Bx--MzAt0xM-VklPRWZMcXN3c1k/view?resourcekey=0-f55VTU8E6JWk1Xn8dMZnQA |
| Version | February 2018 replication package (`Ramey_Zubairy_replication_codes.zip`); `jordagk.do` dated February 24, 2018 and describing the data file as updated April 7, 2016; the workbook's readme sheet is dated November 21, 2016 |
| Files | `RZDAT.xlsx` (sheet `rzdat`), SHA-256 `b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120`; `rzdatnew.csv`, SHA-256 `433ba651f862ec40c5ebee3a533dbd93e2a91011c27fa3e486b4644b9be2d8af` |
| Coverage used | 1889Q1–2015Q4 after dropping earlier rows (508 quarters); `news` recorded from 1890Q1 (504 quarters) |
| Variables used | `quarter`, `rgdp` and `rgdp_pott6` (billions of chained 2009 dollars, annual rate), `pgdp` (GDP deflator), `news` (billions of nominal dollars), `ngov` (nominal government spending) |
| License | none stated in the package or on the author page |
| Redistribution | not redistributed: the project ships `data/raw/get_rz.do` instead (D5, D35) |

**Automatic route.** `do data/raw/get_rz.do` downloads the package from the
archive link above, unzips it in Stata's temporary folder, copies the two files
into `data/raw/`, and stops unless both SHA-256 values match. On 2026-09-13 a
first test downloaded the 990,729-byte zip in 5.0 seconds and both checksums
matched. The instructor build used the same route: its first run downloaded and
verified the files, and its final run found them in `data/raw/` and verified
both checksums again. A run of the student archive in an empty folder
downloaded and verified them once more.

**Manual route**, if the download fails (Google Drive sometimes interposes a
confirmation page):

1. Open https://sites.google.com/site/sarahzubairy/research and download the
   replication codes for Ramey and Zubairy (2018, *JPE*), or use the archive
   link above.
2. Unzip `Ramey_Zubairy_replication_codes.zip`.
3. Copy `RZDAT.xlsx` and `rzdatnew.csv` from that folder into `data/raw/`.
4. Run `do data/raw/get_rz.do` again; it verifies both checksums before any
   analysis reads the data.

`.gitignore` keeps both files out of version control, and the student archive
is built without them. The browser lab embeds only estimates computed from
these data, never data rows (D33).

## 5. The sample handoff record (shipped in `handoff/`)

`l01-explorer-handoff.json`, `hand_table.csv`, and `onedraw_rho09_seed2.csv`
were written on 2026-09-13 by the Explorer's own functions
(`labHandoff`, `labHandTableCsv`, `labDrawCsv`), extracted from
`interactives/01-shock-to-response-explorer.qmd` and run in Node.js with the
settings listed in `handoff/README.md`. The predictions in the record are
marked "Sample record"; they illustrate the format and are not answers. On
2026-09-14 the Lab 1 prediction was reworded to call θ₀ the impact response
(editor decision D55), which is why the record's SHA-256 differs from the one
the Explorer's functions wrote that day.

| File | SHA-256 |
|---|---|
| `l01-explorer-handoff.json` | `804b9e8f7c1028b7e080f246a7b0856a89ec87a8dfe09de3957aedb1438e9d34` |
| `hand_table.csv` | `d58b48a56e73d38c682ee621250d25c64ce542bc11c73c73da281edb8a98041f` (identical to `data/raw/hand_table.csv`) |
| `onedraw_rho09_seed2.csv` | `d310002a7eb476f664729e286a41b8e72d11c33da9d90f08b349556364e90de6` (the browser writes `0.678` where Stata writes `.678`; the values are identical) |
