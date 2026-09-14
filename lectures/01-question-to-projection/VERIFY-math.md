# Lecture 01 — mathematical verification

Adversarial verification of `lectures/01-question-to-projection/_body.qmd` and
`glossary.qmd` in the public course repository, run on 2026-09-13 against the
BRIEF's §6 "Derivations to verify", the notation ledger, and the editor
decisions. Every displayed equation was re-derived from A1–A4 as the chapter
states them. Every quoted number was recomputed at full precision, in exact
rational arithmetic where the inputs are exact decimals. Literature and data
claims were checked against the papers and files named in §4.

Verdict vocabulary: **verified** (re-derived or recomputed and found correct),
**corrected** (wrong or imprecise; the before and after text is in §5),
**disputed** (defensible as written but worth an authorial look; left
unchanged, reasoning given).

## 0. Outcome

| Item | Count |
|---|---:|
| Displayed equations re-derived (15 labeled, 11 unlabeled) | 26 |
| Inline derivations re-derived (variance, weights, induction, SD approximation, …) | 12 |
| Distinct numeric tokens in the body recomputed or traced to a check | 236 |
| Automated Python checks passing (130 + 148 + 42 + 7 + 1) | 328 |
| Stata `assert` statements passing (`verify_l01.do` 18, figure do-file 8) | 26 |
| Further Stata outputs compared with the notes (slopes, storage variants, seed-4 coefficients and autocorrelations, rebuilt Monte Carlo cells) | 71 |
| Corrections applied to `_body.qmd` | 21 |
| Corrections applied to `glossary.qmd` | 2 |
| Disputed, left unchanged | 6 |

No displayed equation was wrong. The corrections concern:
- conditions stated too weakly or too strongly: the score autocorrelation, the
  large-sample SD approximation, the role of lagged interventions, the
  "only if" in the identification list, and two glossary definitions;
- one misattributed assumption, where A2 alone was credited with
  $\operatorname{Cov}(s_t,y_{t-1})=0$;
- an index range in the orthogonality check;
- an example that did not illustrate "at most MA($h$)";
- a row count behind one quoted number (0.219 should be 0.218);
- four factual or provenance slips: the news start year, the war-quarter
  label, the data date, and Practicum 01's scope;
- two storage and wording details.

## 1. Scripts and runs

All scratch work is in
`build-01/verify/`, a session-local scratch folder that is not published.
Nothing there is part of the deliverable.

| Script | What it checks | Result |
|---|---|---|
| `v1_exact.py` | Hand table (y, counterfactual, gaps, changes, four-decimal ties away from zero) in exact rationals; every group sum, mean, OLS slope with and without $y_{t-1}$, one-episode slope; symbolic (sympy) forward substitution for $h\le6$, $\partial y_{t+h}/\partial s_t$, residual recursion, one-episode and difference-in-means algebra; $\theta_h$ and figure numbers; variance arithmetic; brute-force residual autocovariance against @eq-l01-residual-acov for $h\le20$, $k\le23$ over 24 parameter sets; monotonicity in $h$ and $\rho$ (exact rationals plus an analytic derivative) | 130 pass, 0 fail (`v1_exact.out`) |
| `v2_data.py` | RZDAT: sample, units, Korea numbers, 21 toy LPs against the figure CSV, 21 RZ-control LPs against REP04 `irf_gdp_linear` at $10^{-6}$, the variation-share table, drop-one tests; shipped seed-2 draw: recursion, 13 LPs, signs, shortfalls, band position; stored seed-3 Monte Carlo: table values, summary CSV, bias, MCSE, percentile definitions | 148 pass, 0 fail (`v2_data.out`); the first run's single failure was the check's own assumption (identical rows in both regressions) and became finding F06 |
| `v3_asymptotics.py` | Score autocovariances with and without the control in a $T=3\times10^6$ sample; sampling spread of $\hat\beta_h$ ($R=2000$, $T=2000$) against three large-sample formulas | 42 pass, 0 fail (`v3_asymptotics.out`) |
| `verify_l01.do` (log `verify_l01_out.txt`) | Hand table from the stated Stata design (seed 1, `v` then `s`); float and double storage variants; both code blocks in the notes run verbatim; seed-2 draw regenerated from the stated design and compared with the shipped CSV; seed-4 $T=100{,}000$ coefficients and residual autocorrelations | no error lines; all asserts pass |
| `mc_verify.do` (log `mc_verify_out.txt`) | Seed-3 Monte Carlo rebuilt from the design stated in the notes ($R=500$, both $\rho$, both regressions, $h=0..12$) | 68 s; matches the stored summary to $5\times10^{-7}$ and every row of @tbl-l01-control-precision (`v4_mc_compare.out`) |
| `roundtrip.do` (log `roundtrip_out.txt`) | Default `export delimited` / `import delimited` of the float hand table, then the notes' first code block | reproduces 0.61732179, −0.98335569, 2.05002437 |
| `fc_copy.do` (copy of `figures/fig-l01-first-contact-data.do`) | Its own asserts (504/500 rows, 0.080313, 0.404210, REP04 0.050987698 and 0.29376385, peak at $h=10$) | asserts pass; output CSV byte-identical to `figures/fig-l01-first-contact.csv` |
| `v5_units.out` (inline Python) | `pgdp` averages 1.000 over 2009; `ngdp = rgdp × pgdp` exactly after 1947; 2015Q4 real GDP 16,470.6 | pass |
| `apply_fixes.py`, `reflow.py` | Apply the 23 corrections atomically (each old string asserted to occur once), then rewrap lines longer than 90 characters | applied |

Planning evidence reused from the planning scratch folder `design-01/`: all 21 logs were grepped for
`^r\([0-9]+\);` and none has an error line. Batch-mode logs (`*.log`) carry
the licence banner and were neither quoted nor copied. The `log using`
outputs (`*_out.txt`) were grepped for the licence banner's serial-number line, with zero hits.
Software: StataNow/SE 19.5; Python 3.11.8 with numpy 1.26.4, pandas 2.2.3,
scipy 1.11.4, sympy 1.14.0. Data: `replication-packages/pilots/REP04/source/rzdat.xlsx`,
SHA-256 `b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120`
(identical to `design-01/rz/RZDAT.xlsx`); read-only, copied to scratch for the
figure do-file.

## 2. Displayed equations and derivations

Line references are to the corrected `_body.qmd`. "Symbolic" means sympy;
"exact" means rational arithmetic.

| # | Location | Equation or derivation | How checked | Verdict |
|---|---|---|---|---|
| E1 | §question | @eq-l01-causal-response, $\theta_h=y_{t+h}-y^{c}_{t+h}$ | Both terms dated $t+h$; units of $y$ per unit of $s$. Date-free under A1: switching off the $t=10$ intervention instead of $t=5$ gives gaps 1, 0.5, 0.25 (exact) | verified |
| E2 | §question | @eq-l01-change-decomposition | Add-and-subtract identity; needs $y_{t-1}$ common to both paths, which the timing paragraph supplies. Reading ("agrees with $\theta_h$ only when the second bracket is zero", i.e. $y^{c}_{t+h}=y_{t-1}$) correct | verified |
| E3 | §question | Twelve-period rule $y_t=0.5y_{t-1}+s_t+v_t$, $y_0=0$ | Stata regeneration (seed 1, `v` then `s`) reproduces all twelve $v_t$ to $10^{-6}$ and $s_t=1$ exactly at $t=1,5,10,12$ | verified |
| E4 | §smallest-model | @eq-l01-toy | Units and reading ("carry forward $\rho$, add $\theta_0$ per unit, add $v_t$") | verified |
| E5 | §smallest-model | $h=1$ aligned substitution | Symbolic | verified |
| E6 | §smallest-model | $h=2$ substitution | Symbolic | verified |
| E7 | §smallest-model | @eq-l01-forward | Symbolic for $h=0,\dots,6$; induction step re-derived. "After $h+1$ steps" counts applications of the rule (dates $t,\dots,t+h$), which is $h$ substitutions; see disputed item X5 | verified |
| E8 | §smallest-model | @eq-l01-theta, $\theta_h=\theta_0\rho^h$ | $\partial y_{t+h}/\partial s_t=\theta_0\rho^h$ symbolically; gap unchanged when all $v_t$ are replaced (exact); limits $\rho=0$, $\rho\to1$, $\rho<0$ | verified |
| E9 | §two-clocks | $h\mapsto\theta_h$ | Definition | verified |
| E10 | §model-to-regression | @eq-l01-projection | First-order conditions of $\min\mathbb E[(y_{t+h}-a-bs_t-cy_{t-1})^2]$ are the three moment conditions; uniqueness needs a nonsingular second-moment matrix, which is the prose's proviso | verified |
| E11 | §model-to-regression | @eq-l01-residual | Forward equation minus the proposal; $u_{t,0}=v_t$ | verified |
| E12 | §model-to-regression | Condition 1 (mean zero) | A2, A3 | verified |
| E13 | §model-to-regression | Condition 2, $\mathbb E[s_tu_{t,h}]=0$ | Correct, but the index range "with $j\ge1$" was attached to both kinds of term, and $u_{t,h}$ contains $v_t$ ($j=0$) | corrected (F04) |
| E14 | §model-to-regression | Condition 3, $\mathbb E[y_{t-1}u_{t,h}]=0$ | Backward sum converges in mean square under A4; independence under A2 and A3 | verified |
| E15 | §model-to-regression | @eq-l01-lp-toy | Follows from E10–E14. Seed-4 $T=100{,}000$ estimates reproduced in Stata; largest gap 0.0082 ($\hat\gamma_8$) | verified |
| E16 | §model-to-regression | @eq-l01-lp | Matches the ledger's canonical regression | verified |
| E17 | §model-to-regression | Nonzero intervention mean changes only $\mu_h$ | Write $u=\tilde u+\mathbb E[u]$; $\tilde u$ has mean zero and is independent of $s_t$ and $y_{t-1}$, so $\beta_h=\theta_0\rho^h$ and $\gamma_h=\rho^{h+1}$ are unchanged | verified |
| E18 | §model-to-regression | Omitting $y_{t-1}$ leaves $\beta_h$ unchanged; residual variance gains $\rho^{2(h+1)}\operatorname{Var}(y)$ | Omitted-variable formula with $\operatorname{Cov}(s_t,y_{t-1})=0$. That covariance needs A3 as well as A2, since $y_{t-1}$ contains past $v$ | verified; attribution corrected (F02, F08) |
| E19 | §model-to-regression and A4 | $\operatorname{Var}(y)=(\theta_0^2\sigma_s^2+\sigma_v^2)/(1-\rho^2)$ | Stationary variance equation | verified |
| E20 | §model-to-regression | Large-sample SD of $\hat\beta_h$ is the residual SD over $\sigma_s\sqrt{T_h}$, "because $s_t$ is independent of every term in either residual" | True with the control at every $h$, and without it at $h=0$. Without the control at $h\ge1$ the error $e_{t,h}=u_{t,h}+\rho^{h+1}y_{t-1}$ gives $\operatorname{Cov}(s_te_{t,h},s_{t+k}e_{t+k,h})=\theta_0^2\rho^{2h}\sigma_s^4$ for $1\le k\le h$: $e_{t,h}$ contains $s_{t+k}$ with weight $\theta_0\rho^{h-k}$, $e_{t+k,h}$ contains $s_t$ with weight $\theta_0\rho^{h+k}$, and independence removes every other term. A $T=3\times10^6$ sample gives 0.808 against 0.810 ($h=1$) and 0.424–0.434 against 0.4305 ($h=4$). With $R=2000$, $T=2000$ and $\rho=0.9$, $h=4$, no control, $\mathrm{sd}\times\sqrt{T_h}=3.686$; the naive formula gives 3.177 and the corrected one 3.680. The notes use the formula only at $h=0$, where it holds. The row count behind 0.219 was also wrong: the Monte Carlo's no-control regressions use $200-h$ rows | corrected (F06, F07) |
| E21 | §many-shock-dates | @eq-l01-ols-slope; $\sum\omega_t=0$, $\sum\omega_ts_t=1$ | Algebra | verified |
| E22 | §many-shock-dates | FWL footnote | Numerator and denominator both use the residualized $s_t$; $\sum\tilde s_ty_{t+h}=\sum\tilde s_t\tilde y_{t+h}$ | verified |
| E23 | §many-shock-dates | @eq-l01-estimation-error | Substitution using the two weight properties | verified |
| E24 | §many-shock-dates | One-episode weights: $\bar s=1/n$, $\sum(s_t-\bar s)^2=(n-1)/n$, weights $1$ and $-1/(n-1)$ | Symbolic | verified |
| E25 | §many-shock-dates | @eq-l01-one-episode and $\hat\beta_h=\theta_h+(\rho^{h+1}y_{\tau-1}+u_{\tau,h}-\bar y_{\text{others}})$ | Uses @eq-l01-forward with $\theta_0=s_\tau=1$ | verified |
| E26 | §many-shock-dates | $\hat\beta_0=-0.66875-0.9636474609375=-1.6323974609375$ | Exact; OLS with a single-row indicator equals it exactly | verified |
| E27 | §rows-by-hand | @eq-l01-sample-size, $T_h=T-h-p$ | Rows $p+1,\dots,T-h$. The RZ adjustment (a lag costs no row when the lagged series starts earlier) gives $504-h$, reproduced | verified |
| E28 | §rows-by-hand | Difference-in-means denominator $n_1n_0/n$ and numerator $(n_1n_0/n)(\bar y_1-\bar y_0)$ | Symbolic | verified |
| E29 | §rows-by-hand | @eq-l01-diff-means; intercept $=\bar y_0$ | Exact OLS on the hand rows | verified |
| E30 | §first-contact | $s_t=\texttt{news}_t/(\texttt{rgdp\_pott6}_{t-1}\texttt{pgdp}_{t-1})$ | Matches `jordagk.do` line 94 and RZ (2018) note 17 (lagged deflator); 504 nonmissing values | verified |
| E31 | §residual | $u_{t,1}$ and $u_{t+1,1}$; covariance $\rho$, variance $2+\rho^2$ | Correct for $\theta_0=\sigma_s=\sigma_v=1$; "with unit variances" omitted $\theta_0$ | corrected wording (F11, F12) |
| E32 | §residual | Shared-term counting; @eq-l01-residual-acov | Brute-force coefficient overlap against the closed form, $h\le20$, $k\le23$, $\rho\in\{-0.7,0,0.3,0.5,0.9,0.95\}$, $\theta_0\in\{1,1.7\}$, $(\sigma_s,\sigma_v)\in\{(1,1),(0.8,1.3)\}$: largest difference $<10^{-10}$. $h=2$ special cases symbolic; $k>h$ zero | verified |
| E33 | §residual | "Correlation grows with the horizon … and with persistence" | Exact rationals on a grid ($\rho=0.05,\dots,0.95$; $h\le20$; all $k\le h$). For lag 1, analytically: the ratio over $\rho$ is $(2-ac)/(2-a\rho^2c)$ with $a=\rho^{2h-2}$ and $c=1+\rho^2$, and its derivative in $a$ is $-2c(1-\rho^2)/\text{den}^2<0$ | verified |
| E34 | §residual | MA($h$) footnote | Definition correct. The "at most" example ($h=0$, $u_{t,0}=v_t$) has order equal to $h$, so it illustrates nothing; $\rho=0$, $h\ge1$ gives order 0 | corrected (F13) |
| E35 | §residual | $u_{t,h+1}=\rho u_{t,h}+v_{t+h+1}+\theta_0s_{t+h+1}$ | Symbolic | verified |
| E36 | §residual | Products $s_tu_{t,h}$ uncorrelated across rows | Derivation re-checked; long sample: every lag-$k$ autocovariance within 3 standard errors of zero for $h=1,2,4$ | verified |
| E37 | §residual | Preview: "zero because $s_t$ is unpredictable" | Unpredictability from the past is not sufficient. Zero autocorrelation also needs $s_t$ independent of the later terms in both products, and needs the residual to exclude earlier interventions, which the control $y_{t-1}$ ensures. Without the control the products are autocorrelated (E20). This is the Montiel Olea–Plagborg-Møller lag-augmentation mechanism | corrected (F14) |
| E38 | §smallest-model, burn-in footnote | Variance from $y_0=0$ | $\operatorname{Var}(y_t)=\text{LR}\,(1-\rho^{2t})$, symbolic. "Falls short … by the factor $\rho^{2t}$" reads as $\text{LR}\,\rho^{2t}$. $0.9^{200}=7.06\times10^{-10}$ | corrected wording (F03) |

## 3. Assumptions A1–A4

| Assumption | Check | Verdict |
|---|---|---|
| A1 | Statement, meaning, uses, and kind are consistent with E1, E7, E8. "Without it … averages different responses with weights the researcher did not choose (Lectures 9 and 10)" matches Kolesár–Plagborg-Møller: with an observed shock, a linear LP returns a weighted average of marginal effects whose weights depend on the shock distribution | verified |
| A2 | Meaning and kind correct. "Used in … $\operatorname{Cov}(s_t,y_{t-1})=0$" credited A2 alone, but the step also needs A3. The "Without it" sentence gave lagged interventions as a remedy for $s_t$ forecasting later interventions. With $s_t=\phi s_{t-1}+e_t$ and lags of $s$ among the controls, the coefficient uses the innovation $e_t$, which still forecasts $s_{t+j}$ with weight $\phi^j$, so the absorption remains. Lags do remove the predictable part of $s_t$; Ramey and Zubairy include them "to control for any serial correlation in the news variable" (JPE p. 8) | corrected (F02) |
| A3 | Serially correlated disturbances that stay independent of $s$: $s_t$ is uncorrelated with both $y_{t-1}$ and the error, so $\beta_h=\operatorname{Cov}(y_{t+h},s_t)/\operatorname{Var}(s_t)=\theta_h$. $y_{t-1}$ now forecasts $v_t,\dots$, so $\gamma_h=\rho^{h+1}+\operatorname{Cov}(u_{t,h},y_{t-1})/\operatorname{Var}(y_{t-1})\ne\rho^{h+1}$. Both claims correct | verified |
| A4 | $\lvert\rho\rvert<1$; variance formula (E19); with $\rho=1$ the response formula gives $\theta_h=\theta_0$ and $\operatorname{Var}(y_t)$ grows with $t$ | verified |

## 4. Numbers, tables, and figures

| Where | Quoted | Recomputed | Verdict |
|---|---|---|---|
| Opening | 179.4 billion dollars of news in 1950Q3 | `news` = 179.4 | verified |
| Opening | 0.600 of the previous quarter's nominal trend GDP, annual rate | 0.600073; denominator `rgdp_pott6`×`pgdp` in 1950Q2 = 298.963 | verified |
| Opening | 2.75 percent below trend (1950Q2), 5.12 above (1953Q1), rise 7.87 points, ten quarters after 1950Q3 | 0.972500, 1.051212, 0.078712; 10 quarters | verified |
| @tbl-l01-hand-table | 48 displayed values ($y_t$, $y^{c}_t$, gap, $y_t-y_4$) | Exact rationals, rounded to four decimals with ties away from zero; the gap column is exact | verified |
| §question prose | $y_5=-0.66875$, $y^{c}_5=-1.66875$, fall of 0.73125; changes −0.196875, 1.9703125, −0.34609375 | exact | verified |
| §question prose | $1.9703125=0.25+1.7203125$, "most of it the disturbance $v_7=2.1$" | $1.7203125=2.1-0.3171875-0.0625$, so $v_7$ is larger than the whole change | split verified; wording corrected (F01) |
| §question prose | "nearly eightfold" at $t=7$; wrong sign at $t=5$ | 7.88; −0.731 against 1 | verified |
| @fig-l01-realized-counterfactual caption, alt text | 1, 0.5, 0.25, 0.125; −0.731; 1.970 | exact | verified |
| §two-clocks | Switching off $t=10$: gaps 1, 0.5, 0.25 | exact | verified |
| @fig-l01-persistence caption, alt text; prose | 0.0078 and 0.478 at $h=7$; $\rho=0.9$ first below half at $h=7$; $\rho=0.5$ exactly half at $h=1$; near zero by $h=5$; near 0.3 at $h=12$ | 0.0078125, 0.478297, 7, 0.5, 0.03125, 0.2824 | verified |
| §model-to-regression | Seed-4 $T=100{,}000$: $\hat\beta_h$ 0.9985, 0.9013, 0.8117, 0.6498, 0.4249; $\hat\gamma_h$ 0.8990, 0.8068, 0.7235, 0.5825, 0.3792; all within 0.01 | Stata rerun identical; largest gap 0.0082 | verified |
| §model-to-regression | $\operatorname{Var}(y)=10.53$; $1+0.81\times10.53=9.53$; $1/\sqrt{199}=0.071$ | 10.526, 9.526, 0.0709 | verified |
| §model-to-regression | $\sqrt{9.53}/\sqrt{199}=0.219$ "without it" | The Monte Carlo's no-control regression uses $200-h$ rows in every replication, so $\sqrt{9.526/200}=0.218$; the formula itself holds at $h=0$ only (E20) | corrected (F06, F07) |
| §model-to-regression | $\rho=0.5$, $h=4$: added variance 0.003 | 0.00260 | verified |
| @tbl-l01-control-precision | 24 cells | Stored draws (first 500 replications) and a Stata rebuild from the stated design both reproduce every cell | verified |
| §model-to-regression prose | "a factor of three"; gaps "larger than simulation noise" | 2.97; no control $h=0$: 3.4 MCSE; with control $h=4$: 3.0, $h=8$: 3.3 | verified |
| @tbl-l01-hand-slopes and prose | $T_h$ 11, 10, 9; rows; treated rows; $\bar y_1$, $\bar y_0$, slopes; sums 3.792626953125, 5.17509765625, −0.06982421875, 7.587548828125, 4.565087890625, 1.62763671875 | exact; with-control slopes 0.575667, −1.050405, 2.153022 from exact OLS and Stata | verified |
| §rows-by-hand | Stata returns 0.61732179, −0.98335569, 2.05002437 | Reproduced on float data and after a Stata-default CSV round trip | verified (see X4) |
| Float footnote | 0.9 held as 0.89999998; "Declaring the variable `double` removes the gap" | 0.8999999762. `v` double with `y` float gives 0.6173217713 (gap remains); both double gives 0.6173217773 | first verified; second corrected (F09) |
| §rows-by-hand prose | 0.62 against 1; wrong sign; "eight times too large" | 0.617; −0.983; 8.20 | verified |
| One episode | 9.636474609375; mean 0.9636474609375; −1.6323974609375 $=1+(0.03125-1.7-0.9636474609375)$; −0.984608; 1.512823; "wrong sign twice and six times too large once" | exact; 6.05 | verified |
| One draw (§response-graph) | $T_h=199-h$; $\hat\beta_0=0.878940$, $\hat\beta_4=0.548477$, $\hat\beta_8=0.240595$, $\hat\beta_{12}=-0.293297$; $\theta_h$ 1, 0.6561, 0.4305, 0.2824 | Python on the shipped CSV (to $2\times10^{-6}$); the notes' loop in Stata passes its asserts. The shipped CSV equals a regeneration from the stated design (largest difference $7.5\times10^{-9}$, print precision) | verified |
| One draw | "Every one of the thirteen estimates is below its target"; shortfall grows steadily from 0.19 to 0.58; turns negative after ten periods | gaps −0.121 … −0.576; shortfalls 0.1899, 0.2571, 0.3775, 0.4310, 0.5757; negative at $h=10,11,12$ | verified |
| One draw | Band at $h=8$ 0.047–0.793 | 0.046705, 0.792668 | verified |
| One draw | Inside the band through $h=10$, below at 11 and 12, a hair below at $h=0$ | Below by 0.0004 at $h=0$ (also below the 25th order statistic, so robust to the percentile definition); inside for $h=1..10$; below at 11 and 12. The old sentence contradicted itself at $h=0$ | numbers verified; wording corrected (F10) |
| Monte Carlo centring | $\rho=0.5$ within 0.014; $\rho=0.9$ short by 0.026, 0.033, 0.049; MCSE $0.224580/\sqrt{500}=0.010$; "almost five times" | largest 0.01333 ($h=9$); −0.02627, −0.03321, −0.04889; 0.010044; 4.87 | verified |
| @tbl-l01-residual-ac | 10 formula values, 10 simulated values | Exact formula; Stata rerun reproduces every simulated value | verified |
| §first-contact | 508 quarters; $y$ averages 0.987; chained 2009 dollars at an annual rate | 508; 0.98687; `pgdp` averages 1.000 over 2009; `ngdp`=`rgdp`×`pgdp` exactly; 2015Q4 real 16,470.6, nominal 18,164.8 | verified |
| §first-contact | `newsy` nonmissing 1890Q1–2015Q4 (504), nonzero in 108, mean 0.007222, sd 0.059728, largest 0.691893 (1941Q4) and 0.600073 (1950Q3) | all reproduced | verified |
| §first-contact | $T_h=504-h$; $\hat\beta$ 0.080313, 0.259141, 0.361906, 0.404210 (peak at $h=10$), 0.0796 | Python and the figure do-file; figure CSV identical | verified |
| @fig-l01-first-contact caption, alt text | 0.404 at $h=10$; 0.294 with RZ controls; "numerically $\hat\beta_h$" read in percent of trend GDP per news worth 1 percent | $0.01\times\hat\beta_h\times100=\hat\beta_h$ | verified |
| §first-contact | RZ controls: $T_h=500-h$; 0.0510, 0.2938, 0.0671; equal to REP04 `irf_gdp_linear` | All 21 horizons within $10^{-6}$ of the benchmark, with identical $n$ | verified |
| §first-contact | "The peak falls by about a quarter" | 27.3 percent | verified |
| @tbl-l01-news-variation | Six rows of news, share, cumulative share on the $h=8$ sample (496 rows, 1890Q1–2013Q4) | 0.261211/0.261211, 0.195838/0.457049, 0.100897/0.557946, 0.086893/0.644839, 0.074496/0.719335, 0.061734/0.781069. Over all 504 quarters two entries would round differently (0.1959, 0.6450), so the stated sample is the right one | verified |
| §first-contact | 45.7, 64.5, 78.1 percent | 45.705, 64.484, 78.107 | verified |
| §first-contact | $h=8$: 0.3619; without 1950Q3 0.4340 (moves 0.072); without 1941Q4 0.3443; without both 0.4451; from 1947Q1 0.0587 on 268 rows | 0.361906; 0.433969 ($N=495$), 0.07206; 0.344264; 0.445118; 0.058668 ($N=268$) | verified |
| §first-contact | "Removing Korea's news quarter raises the estimate" | 1950Q3 has $h=8$ residual −0.174 and purged news +0.592, so deleting it raises the slope | verified |
| §first-contact list | 46 percent; 0.07; 69 percent, 69 times | 45.7; 0.072; 0.6919 | verified |
| §handoff | 0.0787; $0.600073\times0.404210=0.2426$, "three times larger" | 0.078712; 0.242556; 3.08 | verified |

## 5. Corrections applied, before and after

Text is whitespace-normalized; the files were rewrapped after the replacements.

### F01 — §question, t=7 decomposition (`_body.qmd`)

- **Before:** 1.7203125$, most of it the disturbance $v_7=2.1$. Reading
- **After:** 1.7203125$, which the disturbance $v_7=2.1$ more than accounts for. Reading
- **Why:** $y^{c}_7-y_4=1.7203125=2.1-0.3171875-0.0625$. The disturbance does not supply most of the change; it is larger than all of it.

### F02 — A2, Used in / Without it (`_body.qmd`)

- **Before:** interventions inside $u_{t,h}$, and the step $\operatorname{Cov}(s_t,y_{t-1})=0$, which makes the lagged outcome optional for the estimand. *Without it.* If interventions are serially correlated, $s_t$ forecasts the later interventions in $u_{t,h}$ and its coefficient absorbs their effects along with its own; this is one reason empirical specifications, Ramey and Zubairy's among them, include lags of the intervention as controls. If $\sigma_s^2=0$ there is no variation to estimate from.
- **After:** interventions inside $u_{t,h}$, and, together with [A3](#assumption-l01-a3), the step $\operatorname{Cov}(s_t,y_{t-1})=0$, which makes the lagged outcome optional for the estimand. *Without it.* If interventions are serially correlated, $s_t$ forecasts the later interventions in $u_{t,h}$ and its coefficient absorbs their effects along with its own. Lagged interventions among the controls, as in Ramey and Zubairy's specification, remove the part of $s_t$ that earlier interventions predict, but they cannot stop $s_t$ from forecasting the interventions that follow it. If $\sigma_s^2=0$ there is no variation to estimate from.
- **Why:** (i) $\operatorname{Cov}(s_t,y_{t-1})=0$ needs A3 as well as A2, because $y_{t-1}$ contains past disturbances. (ii) The old sentence offered lagged interventions as a remedy for $s_t$ forecasting later interventions. Lags remove the predictable part of $s_t$, but its innovation still forecasts later interventions (with weight $\phi^j$ for an AR(1) intervention), so the absorption remains. Ramey and Zubairy include the lags "to control for any serial correlation in the news variable" (JPE 2018, p. 8).

### F03 — §smallest-model, burn-in footnote (`_body.qmd`)

- **Before:** the variance of $y_t$ falls short of its long-run value by the factor $\rho^{2t}$.
- **After:** the variance of $y_t$ is its long-run value times $1-\rho^{2t}$.
- **Why:** $\operatorname{Var}(y_t)=\text{LR}\,(1-\rho^{2t})$. "Falls short by the factor $\rho^{2t}$" reads as $\text{LR}\cdot\rho^{2t}$.

### F04 — §model-to-regression, condition 2 (`_body.qmd`)

- **Before:** terms of the form $s_tv_{t+j}$ and $s_ts_{t+j}$ with $j\ge1$. Terms of the
- **After:** terms of the form $s_tv_{t+j}$ with $j\ge0$ and $s_ts_{t+j}$ with $j\ge1$. Terms of the
- **Why:** $u_{t,h}$ contains $v_t$, so the disturbance terms start at $j=0$.

### F05 — §model-to-regression, What Made the Coefficient Causal (`_body.qmd`)

- **Before:** small interventions therefore differ, on average, only through $s_t$ itself and through $y_{t-1}$, which the regression adjusts for. The counterfactual is
- **After:** small interventions therefore differ, on average, only through $s_t$ itself; the regression also adjusts for differences in $y_{t-1}$ that arise by chance. The counterfactual is
- **Why:** Under A2 and A3, $y_{t-1}$ is independent of $s_t$. Dates with large and small interventions do not differ in $y_{t-1}$ on average; the control adjusts for differences within a sample.

### F06 — §model-to-regression, Why Include the Lagged Outcome? (`_body.qmd`)

- **Before:** Because $s_t$ is independent of every term in either residual, the standard deviation of $\hat\beta_h$ in large samples is approximately the residual standard deviation divided by $\sigma_s\sqrt{T_h}$. With 199 rows that gives $1/\sqrt{199}=0.071$ with the control and $\sqrt{9.53}/\sqrt{199}=0.219$ without it.
- **After:** At $h=0$, $s_t$ is independent of every term in either residual and neither residual contains a later intervention, so the standard deviation of $\hat\beta_0$ in large samples is approximately the residual standard deviation divided by $\sigma_s\sqrt{T_0}$. The regression with the control has 199 rows, and the one without it can also use the first period, which gives $1/\sqrt{199}=0.071$ with the control and $\sqrt{9.53}/\sqrt{200}=0.218$ without it.
- **Why:** The approximation holds with the control at every $h$, but without it only at $h=0$. At $h\ge1$ the products $s_te_{t,h}$ have autocovariance $\theta_0^2\rho^{2h}\sigma_s^4$ at lags $1,\dots,h$ (E20, confirmed by simulation). The notes use the formula only at $h=0$. The Monte Carlo's no-control regression uses $200-h$ rows, so the large-sample value is $\sqrt{9.53/200}=0.218$.

### F07 — same paragraph group (`_body.qmd`)

- **Before:** close to the large-sample values 0.219 and 0.071.
- **After:** close to the large-sample values 0.218 and 0.071.
- **Why:** Carries F06's 0.218 into the comparison with the table.

### F08 — same subsection, closing paragraph (`_body.qmd`)

- **Before:** [A2](#assumption-l01-a2) makes $s_t$ unrelated to $y_{t-1}$. An intervention
- **After:** [A2](#assumption-l01-a2) and [A3](#assumption-l01-a3) make $s_t$ unrelated to $y_{t-1}$. An intervention
- **Why:** Same attribution as F02(i).

### F09 — §rows-by-hand, floating-point footnote (`_body.qmd`)

- **Before:** place. Declaring the variable `double` removes the gap.]
- **After:** place. Declaring both `v` and `y` as `double` removes the gap.]
- **Why:** With `v` double and `y` float Stata still returns 0.61732177 at eight decimals, against the exact 0.6173217773. Both double gives the exact value.

### F10 — §response-graph, band paragraph (`_body.qmd`)

- **Before:** value in that range. This sample stays inside the band through $h=10$, falls below it at $h=11$ and $h=12$, and sits a hair below its lower edge at $h=0$.
- **After:** value in that range. This sample sits a hair below the band's lower edge at $h=0$, stays inside it from $h=1$ through $h=10$, and falls below it at $h=11$ and $h=12$.
- **Why:** The old sentence placed the sample inside the band through $h=10$ and also below it at $h=0$.

### F11 — §residual, h=1 covariance (`_body.qmd`)

- **Before:** Every other term is distinct and independent. With unit variances, the covariance
- **After:** Every other term is distinct and independent. With $\theta_0=\sigma_s=\sigma_v=1$, the covariance
- **Why:** The variance $2+\rho^2$ uses $\theta_0^2\sigma_s^2=1$ as well as $\sigma_v^2=1$.

### F12 — §residual, h=2 special case (`_body.qmd`)

- **Before:** With unit variances and $h=2$, the variance
- **After:** With $\theta_0=\sigma_s=\sigma_v=1$ and $h=2$, the variance
- **Why:** Same as F11.

### F13 — §residual, MA(h) footnote (`_body.qmd`)

- **Before:** allows for weights that happen to be zero, as at $h=0$, where $u_{t,0}=v_t$.]
- **After:** allows for weights that happen to be zero: with $\rho=0$ and $h\ge1$, for example, $u_{t,h}=v_{t+h}+\theta_0s_{t+h}$ is uncorrelated with its neighbours.]
- **Why:** At $h=0$ the order equals $h$, so the example shows no order below $h$. With $\rho=0$, $u_{t,h}$ is uncorrelated at every lag for all $h\ge1$.

### F14 — §residual, What This Does and Does Not Imply (`_body.qmd`)

- **Before:** autocorrelation of $s_tu_{t,h}$, which in this economy is zero because $s_t$ is unpredictable, and it examines what changes when the intervention is not [@montieloleaplagborgmoller2021].
- **After:** autocorrelation of $s_tu_{t,h}$, which in this economy is zero because $s_t$ is independent of everything else in both products and the control $y_{t-1}$ keeps earlier interventions out of the residual, and it examines what changes when either fails [@montieloleaplagborgmoller2021].
- **Why:** Unpredictability from the past is not enough. Zero autocorrelation of $s_tu_{t,h}$ uses independence of $s_t$ from the later terms in both products, plus a residual free of earlier interventions, which the control $y_{t-1}$ ensures. Without the control the products are autocorrelated at $h\ge1$ (E20). This is the Montiel Olea–Plagborg-Møller lag-augmentation mechanism. Their January 13, 2026 corrigendum changes only Assumption 3's $G$ matrix and the proof of Lemma A.6, so it does not affect the preview. The sentence stays a single labeled preview (D43).

### F15 — §first-contact, data provenance (`_body.qmd`)

- **Before:** replication package, whose data comment is dated April 7, 2016 [@rameyzubairy2018].
- **After:** replication package [@rameyzubairy2018]. The workbook's readme sheet is dated November 21, 2016, and the package's `jordagk.do` describes the file as updated April 7, 2016.
- **Why:** The workbook's own readme sheet reads "Revised November 21, 2016"; April 7, 2016 is the comment at `jordagk.do` line 10.

### F16 — §first-contact, military-news footnote (`_body.qmd`)

- **Before:** series used here extends it back to 1889 [@rameyzubairy2018].
- **After:** version used here begins in 1890 [@rameyzubairy2018].
- **Why:** In RZDAT, `news` is missing before 1890Q1. The data set starts in 1889; the news series does not.

### F17 — §first-contact, variation shares (`_body.qmd`)

- **Before:** the first quarter of the Korean War supply 45.7
- **After:** the first full quarter of the Korean War supply 45.7
- **Why:** The war began on June 25, 1950, in 1950Q2, so 1950Q3 is its first full quarter.

### F18 — §first-contact, What Has Not Yet Been Argued, item 3 (`_body.qmd`)

- **Before:** 3. *Identification.* The coefficient equals $\theta_h$ only if the news is an observed shock in the sense of [A2](#assumption-l01-a2) and [A3](#assumption-l01-a3): unpredictable from the past and unrelated to the taxes, monetary policy, controls, and war that arrived with it.
- **After:** 3. *Identification.* The argument that equated the coefficient with $\theta_h$ required the news to be an observed shock in the sense of [A2](#assumption-l01-a2) and [A3](#assumption-l01-a3): unpredictable from the past and unrelated to the taxes, monetary policy, price controls, and war that arrived with it.
- **Why:** "Only if" asserts necessity. A2 and A3 are the sufficient conditions this lecture's argument used, and Lecture 3 shows that conditional versions can suffice. "Controls" became "price controls" so it cannot be read as regression controls.

### F19 — §handoff (`_body.qmd`)

- **Before:** Yet $y_{t-1}$ also sits on the right-hand side of every regression we ran.
- **After:** Yet $y_{t-1}$ also sits on the right-hand side of the regression behind every response graph we drew.
- **Why:** The hand-table, one-episode and no-control Monte Carlo regressions omit $y_{t-1}$.

### F20 — Further Reading, Jordà–Taylor (`_body.qmd`)

- **Before:** example, a Monte Carlo comparison of levels and long differences, is reproduced at a reduced number of draws in Practicum 01 and returns in Lecture 2.
- **After:** example, a Monte Carlo comparison of levels and long differences, returns in Lecture 2; Practicum 01 reproduces its levels curve at a reduced number of draws.
- **Why:** REP01 targets the levels-LP mean response of Jordà–Taylor Figure 1a. The long-difference curves belong to REP02 (BRIEF §8.1; MANIFEST, REP01).

### F21 — Further Reading, Ramey–Zubairy (`_body.qmd`)

- **Before:** - @rameyzubairy2018 extends the news series to 1889 and supplies the quarterly data of @sec-l01-first-contact, which return in Lectures 2, 4, 9, and 13.
- **After:** - @rameyzubairy2018 builds quarterly U.S. data back to 1889, with the news series from 1890, and supplies the data of @sec-l01-first-contact, which return in Lectures 2, 4, 9, and 13.
- **Why:** Same as F16.

### G01 — glossary, Observed shock (`glossary.qmd`)

- **Before:** When the intervention is an observed shock, the local-projection coefficient on it equals the causal response in population.
- **After:** When the intervention is an observed shock and its effects are linear and the same at every date, the local-projection coefficient on it equals the causal response in population.
- **Why:** Outside a linear, time-invariant economy an observed shock yields a weighted average of responses (Kolesár–Plagborg-Møller; Lectures 9–10), not the causal response.

### G02 — glossary, Projection coefficient (`glossary.qmd`)

- **Before:** becomes a causal response only when assumptions about how the intervention arises make the projection error unrelated to it.
- **After:** becomes a causal response only when assumptions about how the intervention arises make it unrelated to everything else, beyond the controls, that moves the outcome.
- **Why:** A projection error is uncorrelated with every regressor by construction, so the old condition was vacuous. The causal condition concerns everything else that moves the outcome.

## 6. Disputed, left unchanged

- **X1. Which object is "the estimand".** The notes say the estimand "here … is
  $\theta_h$", while the ledger calls $\beta_h$ "the LP estimand". Every
  statement in this lecture holds under either reading, because
  $\beta_h=\theta_h$ in this economy. The course-wide usage is an authorial
  choice.
- **X2. Timing of $\mathbf w_t$ in @tbl-l01-notation.** The table says "dated
  $t-1$ or earlier"; the ledger says "dated $t$ or earlier", which allows
  Lecture 3's recursive exception. The table is correct for Lecture 1, so
  alignment is an authorial choice.
- **X3. "Most of what the full-sample coefficient reports comes from before
  1947."** From 1947Q1 the coefficient is 0.0587 against 0.3619 on the full
  sample. That later sample still contains 1950Q3 and 1950Q4, so the sentence
  is a reading, not an identity. It is defensible.
- **X4. The eighth decimal of Stata's slopes after the CSV code block.** The
  quoted 0.61732179, −0.98335569 and 2.05002437 reproduce from the float design
  and from a Stata-default `export delimited`. A CSV holding exact decimals,
  read with `import delimited`, gives 0.61732178, −0.98335575 and 2.05002448.
  The notes are correct if Lab 2 and STA01 write `hand_table.csv` with Stata
  defaults; forwarded.
- **X5. "After $h+1$ steps."** This counts applications of the rule, which is
  $h$ substitutions. It is defensible as written.
- **X6. The Stock–Watson sentence.** Stock and Watson define
  $E_t[Y_{t+h}\mid\varepsilon_{1,t}=1]-E_t[Y_{t+h}\mid\varepsilon_{1,t}=0]$
  (EJ 2018, p. 921). The notes' $\theta_h$ is a realized gap. The two are equal
  under A1 because the gap is nonrandom, so "the sense in which" is accurate.

## 7. Adversarial checklist items and Lecture 1

- **Residual MA structure and inference:** E20, E32–E37, F06, F13, F14.
- **Same-regressor equivalence:** appears only as the handoff question; no
  claim is made.
- **Identification stated too strongly or too weakly:** F02, F05, F08, F18, G01,
  G02.
- **LP-IV ratio and multiplier normalizations:** forward references only. The
  REP04 comparison uses the OLS GDP responses, which match `irf_gdp_linear`.
- **Lag augmentation:** previewed; the mechanism is verified in E20 and E37.
- **Sup-$t$ band:** absent. The simulation band is correctly labeled as not a
  confidence interval.
- **LP–VAR equivalence:** the footnote paraphrases Jordà's motivation (the
  abstract quote checks verbatim); no equivalence is claimed.
- **Smoothing:** absent.
- **Interacted LP with an endogenous state:** A1's forward reference only.
- **Kolesár–Plagborg-Møller weights:** A1's forward reference (verified) and G01.
- **Time fixed effects, LP-DiD clean controls and weighting, counterfactual
  policy invariance:** absent.

## 8. Forwarded open issues

1. **Publication boundary.** A byte-identical copy of this lecture's BRIEF.md
   sits in the public `lectures/01-question-to-projection/`. `editor-decisions.md`
   D54 and AGENTS.md say briefs and verification logs are public, while this
   stage's instructions place them only in a private directory. The editor
   should decide and remove one copy.
2. **Downstream wording.** The corrected wording must reach the slides, the
   Explorer, STA01 and `PROVENANCE.md`:
   - BRIEF §1 item 8, §9 slide 10 and the course spine say the residual
     "is zero because $s_t$ is unpredictable" (see F14);
   - "extends the news series to 1889" (F16, F21);
   - "data comment April 7, 2016" (F15; also in `ORIGINAL-SOURCE.md`, which
     omits the workbook's November 21, 2016 revision).
3. **Unequal Monte Carlo rows.** The no-control regressions use $200-h$ rows and
   the controlled ones $199-h$. The hand section and the BRIEF's controlled
   experiment ("add or remove $y_{t-1}$ on the same rows") hold rows fixed.
   Either restrict the no-control regressions to $t\ge2$ (the no-control table
   columns would shift slightly) or keep the current note (F06).
4. **Optional footnote.** One could note that without the control the scores
   $s_te_{t,h}$ are autocorrelated at $h\ge1$, so the large-sample SD formula
   understates the spread (by about 16 percent at $\rho=0.9$, $h=4$). It would
   seed Lecture 5's lag-augmentation argument. This is an authorial call under
   D43.
5. **X1, X2 and X4 above.**
6. **Audit script name.** AGENTS.md names `scripts/audit_lecture.py`, but the
   repository has `scripts/audit_session.py`. On this lecture it currently fails
   only on the missing `solutions.qmd` and `slides.qmd`, which later stages
   create.

## Resolved after this pass, September 14, 2026

Two items forwarded above are settled by later editor decisions and are not
open: the publication boundary (D54 makes briefs, logs, and solutions public,
so `BRIEF.md` stays in the lecture directory), and the audit script name
(AGENTS.md now names `scripts/audit_session.py`).
