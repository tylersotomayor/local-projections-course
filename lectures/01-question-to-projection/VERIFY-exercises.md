# Lecture 01 exercises: adversarial re-solve

Scope: `lectures/01-question-to-projection/exercises.qmd`, all ten exercises,
checked against `_body.qmd`, the brief's assessment map (§5), the authoring
guide's hint and solution standards, and editor decisions D2, D5, D26, D32,
D35, and D53. Run on September 13, 2026.

## Method

1. I read each Problem block alone, with its hint and solution unread, and
   solved it independently. Pencil exercises were done in exact rational
   arithmetic (`python3`, `fractions`); Stata exercises with my own do-files in
   StataNow/SE 19.5 batch mode. Scratch: `build-01/resolve/`, in a session-local scratch folder that is not
   published
   (`pencil.py`, `ex4/`, `ex6/`, `ex7/`, `ex9/`).
2. Only then did I read the hint and solution and compare.
3. I extracted every Stata block in the solutions verbatim and ran it in a
   lab-project layout (`resolve/provided/`, with `data/raw/` and `output/`).
4. Side claims in the solutions were checked in `resolve/claims/`: float-storage
   slopes, control coefficients, MCSE ratios, 5–95 bands, benchmark provenance,
   and the unrounded Korea numbers.
5. Data. `RZDAT.xlsx` is a copy of
   `replication-packages/pilots/REP04/source/rzdat.xlsx` (SHA-256
   `b2d85087…8c6120`, equal to the value in `get_rz.do`), and `rzdatnew.csv`
   has SHA-256 `433ba651…e2d8af`. The seed-2 draw is
   `design-01/lecture/onedraw_rho09_seed2.csv` (planning scratch folder); regenerating it from the
   design stated in the notes matches it to eight decimals.

Every batch log was grepped for `^r\([0-9]+\);`: none. The logs written by
`log using` contain no serial-number line. No log is quoted here.

**Result.** Ten exercises re-solved. Nine defects fixed in `exercises.qmd`, in
Exercises 2, 5, 7 (five), 9, and 10. All four Stata solutions run and every
assertion passes. The audit passes on a scratch copy with stub slides, and the
solutions page renders with no unresolved references.

## One row per exercise

| Ex. | Independent answer | Provided answer | Verdict | Fix |
|---|---|---|---|---|
| 1 | $y^c_{5..8}=-1.66875,-0.634375,1.7828125,-0.40859375$; gaps 1, 0.5, 0.25, 0.125; $y_t-y_4=-0.73125,-0.196875,1.9703125,-0.34609375$; counterfactual change $-1.73125,-0.696875,1.7203125,-0.47109375$; sign wrong at $t=5,6,8$; overstatement 7.88125 at $t=7$; gaps unchanged with $v\equiv0$ | Same, exact. Its wrong-counterfactual example (every $s_t=0$) gives 1.0625, 0.53125, 0.265625, 0.1328125, which is correct | Correct; hint gives a first move, no numbers | None |
| 2 | $y_{t+h}=\rho^{h+1}y_{t-1}+\sum_{j=0}^h\rho^{h-j}(\theta_0s_{t+j}+v_{t+j})$; $\theta_h=\theta_0\rho^h$; $\mu_h=0$, $\beta_h=\theta_0\rho^h$, $\gamma_h=\rho^{h+1}$; orthogonality from A2–A4; $\theta_4=0.6561$, $\theta_7=0.4782969$, first $h$ below one half is 7 | Same; $\ln0.5/\ln0.9=6.58$; slip $\mathbb E[s_tu_{t,h}]=\theta_0\rho^h\sigma_s^2$ correct | Numbers correct. The step "only one set of coefficients" satisfies the conditions was stated without its condition (regressors vary, no exact collinearity), which the notes state | Added the condition and why it holds here ($\sigma_s^2>0$ by A2; $y_{t-1}$ varies and is uncorrelated with $s_t$ by A2, A3) |
| 3 | Rows 2–12, 2–11, 2–10; $T_h=11,10,9=12-h-1$; intervention rows 5, 10, 12 / 5, 10 / 5, 10; $\bar y_1=1.264208984375,-0.034912109375,2.2825439453125$; $\bar y_0=0.64688720703125,0.948443603515625,0.23251953125$; $\hat\beta_h=0.61732177734375,-0.983355712890625,2.0500244140625$; row 4's outcome $y_5=-0.66875$ contains $s_5$ | Same. Its checks hold: $24/11$ and $1.346883877841$; $3/8=0.375$ from rows 4, 9, 11; the mean-of-all-rows slip gives 0.448961 | Correct | None |
| 4 | Own do-file (double): $T_h=11-h$ in both regressions, same rows, no-control slope equals $\bar y_1-\bar y_0$; with $y_{t-1}$: 0.57566739, $-1.05040519$, 2.15302246 | Do-file runs, all assertions pass, and the listing matches the log. Float storage gives 0.61732179, $-0.98335569$, 2.05002437; $\hat\gamma_h=-0.061075,-0.114924,0.232679$; dropping `if t >= 2` gives 0.77626954 on 12 rows | Correct | None |
| 5 | $\hat\beta_h=-1.6323974609375,-0.98460829,1.512823486328125$; $h=0$ split $1+(0.03125-1.7-0.9636474609375)$. With the original column, row 5 is the only intervention row at every $h=3,\dots,7$ (slopes $-1.199853515625,-0.3652588,0.9282520,-1.1444458,1.6483236$ on 8, 7, 6, 5, 4 rows); at $h=8$ no intervention row remains and Stata omits `s` | (a)–(c) same; (d) gives $h=3$ and $-1.199853515625$ | (d) was wrong as posed: "At one horizon … Which horizon" has five correct answers, and the solution named one | (d) now asks for the first horizon and its slope; the solution adds $h=4$–7 and the undefined slope at $h=8$ |
| 6 | $T_h=199-h$; $\hat\beta_0=0.878940$, $\hat\beta_{12}=-0.293297$; all 13 estimates below $\theta_h$; Python least squares on the CSV agrees to six decimals | Do-file runs (about 2 s), all assertions pass, and the listing matches the log. Its claims check: shortfall 0.0074–0.197 through $h=8$ ("0.01 to 0.20"), 0.19 at $h=8$ rising to 0.58 at $h=12$; the caption fills all four slots | Correct (see open issue 1 on the shipped CSV) | None |
| 7 | Own do-file ($R=200$, seed 3, 40.7 s): at $\rho=0.9$, $h=8$, mean 0.37033659 and sd 0.21122564. Gaps beyond two MCSE: at $\rho=0.9$, $h=2$ (2.16), 4 (2.10), and 5–12 (2.89–4.03); at $\rho=0.5$, $h=2$ (2.21), 5 (2.76), 7 (2.02), 8 (2.51). Ratio of no-control to control sd: 3.07 falling to 1.12 at $\rho=0.9$; 1.35, 1.13, 1.07, 1.03, then within 1% at $\rho=0.5$. The Exercise 6 sample lies inside [0.0608, 0.6944] at $h=8$ and below $-0.1138$ at $h=12$ | Do-file runs in 27.4 s, all assertions pass, and its table matches to four decimals. (b) cited only $h=4$ and $h\ge5$ at $\rho=0.9$ and dismissed $\rho=0.5$; (c) said the control matters "only at impact" at $\rho=0.5$ | Five defects. (i) The stem did not pin the draw order, which the $10^{-6}$ assertion depends on; float or double $y$ and $y_0=0$ or $y_1=0$ do not matter. (ii) The stem did not say which rows the no-control regression uses: $200-h$ rows give 0.9690 at $\rho=0.9$, $h=0$, and $199-h$ give 0.9694. (iii) The hint repeated the stem. (iv) (b) omitted $h=2$ at $\rho=0.9$ and three of the four exceedances at $\rho=0.5$, and gave no decision rule. (v) (c) "only at impact" contradicts the ratios 1.13 and 1.07 | Stem now states $y_0=0$, `generate s` then `generate v` over all 300 periods, $199-h$ and $200-h$ rows. Hint now points to posting `e(N)` and to $\rho^{2(h+1)}\operatorname{Var}(y)$ for (c). (b) rewritten with a two-MCSE rule and complete lists, one paragraph per $\rho$. (c) now reads "most at impact, a little at $h=1$ and $h=2$ (1.13, 1.07)" |
| 8 | $\operatorname{Corr}(u_{t,1},u_{t+1,1})=\rho/(2+\rho^2)$, 0.2222 at 0.5; shared terms 3, 1, 0; variance $2+2\rho^2+\rho^4=2.5625$; correlations $18/41=0.4390$, $4/41=0.0976$, 0; the windows do not overlap beyond $h$; $\mathbb E[s_t]\,\mathbb E[\cdot]=0$ | Same. Its omitted-interventions slip gives 0.4762, and its $\rho=0.9$ values are 0.3203, 0.5914, 0.1894; both correct | Correct | None |
| 9 | 564 rows in the sheet, 508 from 1889Q1; $s_t$ nonmissing for 504 quarters (1890Q1–2015Q4, since `news` is missing in 1889), nonzero in 108; $T_h=504-h$; $\hat\beta_8=0.361906$, $\hat\beta_{10}=0.404210$ (peak), $\hat\beta_{20}=0.079552$. Shares 0.261211, 0.195838, 0.100897, 0.086893, 0.074496, 0.061734 (cumulative 0.457049, 0.644839, 0.781069). Without 1950Q3, 0.433969 on 495 rows, so the estimate rises | Do-file runs, `get_rz.do` verifies both hashes, all assertions pass, and the listing matches the log. The Ramey–Zubairy controls check gives 0.29376385 on 490 rows, equal to REP04 `irf_gdp_linear` at $h=10$ (`jordagk.do` lines 253–386 and 398–417, as the benchmark CSV records) | Numbers correct. (c) never said which $T$ to use. With $T=508$ (series length, the ledger's $T$), the formula gives $507-h$, more rows, not "one fewer" | (c) now says the formula is "applied with $T=504$ quarters of news and $p=1$" |
| 10 | From the six-decimal inputs: realized changes 0.028072, 0.061431, 0.078712; scaled 0.048194, 0.155504, 0.242556. From the unrounded data: 0.028072, 0.061430, 0.078712 and 0.048194, 0.155503, 0.242556. Ratios 1.72, 2.53, 3.08; implied counterfactual change at $h=10$ is $-0.163844$; with the Ramey–Zubairy controls the scaled value is 0.176280 | The four-decimal table is identical from either source, and the six-decimal values are labeled "from the unrounded data". Its reasons check out, as does the units slip (24.26) | Numbers correct. The hint's second sentence ("compares a single path with itself at two dates") answered (b) | Hint rewritten as a first move: write each number as a difference of dated outcomes on named paths, plus a direction for (c) |

## Checks across the set

- **Tags.** The `[core, pencil]` form matches the template and the reference
  workshop. Every exercise carries the brief's §5 tags. Exercise 7 stays
  `[computational]` rather than `[extra]` (D26, D53): the provided do-file took
  27.4 s at $R=200$ in 19.5, against the solution comment's 27.3 and 27.8 s.
- **Duplicated arithmetic.** Exercises 3 and 4 share their no-control slopes on
  purpose: Exercise 4 asserts Exercise 3's numbers in code. Exercise 7(d) reads
  Exercise 6's estimates, and Exercise 10 reads Exercise 9's estimates and its
  drop-1950Q3 result; both use them as inputs to interpretation, not as repeated
  computation. Exercises 1, 3, 5(b) at $h=0$, and 8(a) retrace calculations the
  body works in full, and the body links each exercise at that point. That is
  retracing by design, so nothing changed.
- **Taught before tested.** Everything the exercises ask for appears in
  `_body.qmd`. Frisch–Waugh–Lovell, used in Exercise 4's explanation, appears
  only in the footnote on regression weights with controls. The MCSE and the
  5–95 band, used in Exercise 7, are footnotes too.
- **Hints.** Beyond the Exercise 7 and 10 hints fixed above, every hint gives a
  first move or a representation and no final number.
- **Edits and voice.** The new sentences keep the file's register. They add no
  announcements and no new notation; "gap between the mean estimate and
  $\theta_h$" avoids introducing a symbol for a Monte Carlo mean.

## Runs

| Do-file | What it is | Outcome |
|---|---|---|
| `resolve/provided/ex04_provided_0.do` | Exercise 4 solution, verbatim | No error line; "Exercise 4: all assertions passed" |
| `resolve/provided/ex06_provided_0.do` | Exercise 6 solution, verbatim | No error line; all assertions passed; graph exported |
| `resolve/provided/ex07_provided_0.do` | Exercise 7 solution, verbatim | No error line; all assertions passed; 27.4 s |
| `resolve/provided/ex09_provided_0.do` | Exercise 9 solution, verbatim, with `get_rz.do` | No error line; hashes verified; all assertions passed |
| `resolve/ex4/ex4_mine.do`, `ex6/ex6_mine.do`, `ex7/ex7_mine.do`, `ex9/ex9_mine.do` | Independent solutions | No error lines; my own assertions pass |
| `resolve/claims/claims.do`, `verify2.do` | Side claims (float storage, $\hat\gamma_h$, start value and storage of $y$ in Exercise 7, unrounded Korea numbers, the full Exercise 7 summary, the Exercise 5 horizons 3–8) | No error lines; numbers as quoted in the table |
| `resolve/pencil.py` | Exact arithmetic for Exercises 1, 2(d), 3, 5, 8, 10 | Matches the provided exact values |

The rows of the notes' no-control Monte Carlo come from
`design-01/l01-sim/mc-ar1-v2.do` (planning scratch folder): line 29 runs `reg F\`h'.y s` with no row
restriction, so $200-h$ rows. The new stem wording and the solution's table
follow that design.

## After the edits

- `python3 scripts/audit_session.py lectures/01-question-to-projection
  --playground interactives/01-shock-to-response-explorer.qmd` on the
  repository returns FAIL with a single error: "missing required files:
  slides.qmd". The slides stage has not run, and the script stops there. On a
  scratch copy with a stub `slides.qmd` (`build-01/audit-copy-exercises/`) it
  returns PASS. That includes "all 10 exercises have one ID, hint, and detailed
  solution" and "47 explicit cross-references resolve to unique targets".
- `quarto render lectures/01-question-to-projection/solutions.qmd --to html`
  exits 0 with no warning lines. The page has no unresolved `?@` references,
  and every edited passage appears in the rendered page.
- The only file changed in the public repository, outside the render output,
  is `exercises.qmd`. The pre-edit copy is
  `build-01/resolve/exercises.qmd.before`.

## Open issues

1. **The Practicum 01 lab project is empty.** Exercise 6 cites
   `data/raw/onedraw_rho09_seed2.csv` and Exercise 9 cites
   `data/raw/get_rz.do`; neither exists yet in
   `practica/p01-question-to-projection/lab-project/`. Both solutions were run
   with stand-ins: the design CSV (SHA-256
   `202051448cb02e7ab55f5cf0af399a76d29969b4de6cdb0a2d0699e725aa34cb`) and
   `shared/stata/get_rz.do`. The practicum stage must ship that exact CSV, or
   rerun Exercise 6's $10^{-6}$ assertions against whatever it ships.
2. **Audit on the repository** fails until `slides.qmd` exists.
3. **Brief in the public directory.** `lectures/01-question-to-projection/BRIEF.md`
   in the public repository is byte-identical to this directory's `BRIEF.md`.
   This stage's instructions route planning briefs to a private directory, while
   `AGENTS.md` and D54 describe everything as public. The editor should decide.
   The file was not touched; it is outside this stage's write scope.

## Resolved after this pass, September 14, 2026

Two items forwarded above are settled by later editor decisions and are not
open: the publication boundary (D54 makes briefs, logs, and solutions public,
so `BRIEF.md` stays in the lecture directory), and the audit script name
(AGENTS.md now names `scripts/audit_session.py`).
