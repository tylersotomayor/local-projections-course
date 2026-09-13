# Lecture 02 brief — Levels, differences, cumulative responses, and units

Planning brief for `lectures/02-transformations-and-units/`, the Transformation Workbench (`interactives/02-transformation-workbench.qmd`) and `practica/p02-transformations-and-units/`. Binding sources: editor decisions D1, D2, D5 and D11 (cited where applied), the course spine's Lecture 2 entry, the notation ledger (§2), and the terminology plan (row 02). Every number below comes from a run log, a benchmark CSV, or a derivation in §6. Scratch evidence: `design-02/` (anchor, RZ, jt-ex1, brief-checks). All runs are StataNow/SE 19.5 unless marked 18.5.

## 1. Session brief

**Opening situation.** One dataset gives four numbers for "the response of output to military-spending news". Ramey and Zubairy's (2018) quarterly U.S. data run from 1889Q1 to 2015Q4, with GDP and news both divided by trend GDP. Estimated by OLS with four lags of news, GDP and spending, they give:

- **0.29.** The peak of the level response, reached 10 quarters out: GDP rises by 0.29 percent of trend GDP per unit of news worth 1 percent of trend GDP.
- **1.76.** The same peak scaled to a one-standard-deviation news shock (5.97 percent of trend GDP).
- **3.53.** The sum of the level responses through quarter 20.
- **0.73.** That sum divided by the matching sum for spending (`design-02/RZ/l02-rz-checks.log`, R2–R3).

The spine's placeholder pair "0.8 versus 3.1" is replaced by these computed numbers. None of the four contradicts another. A reader who cannot say what each axis measures will think they do.

**Decision or empirical question.** When a researcher replaces $y_{t+h}$ with $y_{t+h}-y_{t-1}$, $\Delta y_{t+h}$, or $\sum_{j=0}^{h}y_{t+j}$, or rescales $s_t$, does the estimand change, or only its labeling? The operational version asks, for a published comparison of two response graphs, which ingredients differ between them: the dependent variable, the regressors, the rows, or the units of the intervention.

**Target student and prerequisites.** Lecture 1 graduates, who write $y_{t+h}=\mu_h+\beta_h s_t+\gamma_h y_{t-1}+u_{t,h}$, derive $\theta_h=\theta_0\rho^h$, build leads and lags with `tsset`, and read a response graph. From the readiness exercise: OLS normal equations in matrix form (for the three-line proof); logs, percent, and percentage points; Stata loops, `postfile`, and `assert`.

**Learning outcomes (five).**
1. State the question each of the four dependent variables answers. Give the units of $\beta_h$ for each and its population value in the AR(1) economy.
2. Prove that subtracting an included regressor from the dependent variable leaves every other OLS coefficient and every residual unchanged. Verify it with an automated assertion. Name the two conditions: identical regressors and identical rows.
3. Use the telescoping identity to link long-difference and period-change LPs. Explain why the sums agree exactly on a common sample and not on horizon-specific samples. Distinguish the accumulated change ($=$ the level response) from the accumulated level ($=B_h$).
4. Convert a response between percent, percentage points, log points, and ratio-to-trend units. Show that rescaling $s_t$ by a constant rescales $\hat\beta_h$ and leaves the response to the same economic intervention unchanged. Label every axis with units and accumulation convention.
5. Diagnose a published levels-versus-long-differences comparison (Jordà–Taylor Example 1) by listing which ingredients differ. Reproduce it at a stated reduced $R$ and label the result a statistical reproduction.

**Anchor examples.**

*A. The hand table (Lecture 1's, unchanged).* Lecture 1's twelve-period economy, reused exactly (Lecture 1 anchor A, `hand_table_final.csv`): seed 1, $\rho=0.5$, $\theta_0=1$, $T=12$, $y_0=0$, generated in Stata as `gen v = round(rnormal(),0.1)` and then `gen s = rbinomial(1,0.3)`, so the intervention dates are $t=1,5,10,12$. Regression rows are $t\ge2$, as in Lecture 1. The table is read aloud; computations use its exact decimals:

| $t$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $s_t$ | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| $v_t$ | 0.9 | 0.5 | 0.6 | −0.6 | −1.7 | 0.2 | 2.1 | −1.3 | 0.8 | 0.6 | −0.9 | 1.5 |
| $y_t$ | 1.9000 | 1.4500 | 1.3250 | 0.0625 | −0.6688 | −0.1344 | 2.0328 | −0.2836 | 0.6582 | 1.9291 | 0.0646 | 2.5323 |

At $h=1$ the regression uses rows $t=2,\dots,11$ ($T_1=10$). With $y_{t-1}$ included, both regressions give $\hat\mu_1=1.05690624$ and $\hat\beta_1=-1.05040519$ (Lecture 1's $-1.050405$; twelve rows test the algebra, not the estimate, since $\theta_1=0.5$). The coefficient on $y_{t-1}$ is $-0.11492433$ for levels and $-1.11492433$ for the long difference, and both have RSS $9.69221319$. Dropping $y_{t-1}$ from the long-difference regression moves $\hat\beta_1$ to $-0.39993286$ (`anchor/l02-derivations-l01table.log`, D1; its do-file asserts the table against Lecture 1's CSV).

*B. One simulated path under four transformations.* This is Lecture 1's seed-2 stream, $s_t,v_t\sim N(0,1)$. The first 100 of 300 draws are burn-in, leaving $T=200$. Settings: $\rho\in\{0.5,0.9\}$, $\theta_0=1$, controls $(1,y_{t-1})$, $H=12$. The innovation stream ships as `seed2_innovations_300.csv` (columns $t,s,v$, all 300 periods). It is the same stream as Lecture 1's `onedraw_rho05_seed2.csv` and `onedraw_rho09_seed2.csv`: rows $t=101,\dots,300$ here are rows $t=1,\dots,200$ there, with identical $s$ and $v$ (maximum difference 0), and rows 1–100 are the burn-in those files omit, which a rebuild of $y$ at another $\rho$ needs. The float rebuild matches Lecture 1's draw exactly; a double rebuild differs by at most $4.3\times10^{-7}$. Estimates for all four transformations, on horizon-specific rows and on the common sample $\mathcal T_{12}$ ($T=187$), are in `anchor/l02_fourtrans_rho{05,09}_seed2.csv`.

*C. Jordà–Taylor (2025) Example 1.* Frozen at JEL-Code commit `655696c`, CC0 license.

- **Design.** $y_t=\rho y_{t-1}+s_t+v_t$ with $s_t$=`vy` and $v_t$=`e`, both $N(0,1)$. Seed 12345, burn-in 500, $T=100$, $\rho\in\{0.95,1.00\}$, $h=0,\dots,10$.
- **The two models compared.** The levels LP regresses $y_{t+h}$ on $(1,s_t,y_{t-1})$. The long-difference LP regresses $y_{t+h}-y_{t-1}$ on $(1,s_t)$ only.
- **Replication counts.** Published: $R=10{,}000$. Course benchmark: $R=500$ (Stata 18.5). Student default: $R=200$ (D2).

*D. The fiscal anchor.* `RZDAT.xlsx`, sheet `rzdat`: 508 quarters, 1889Q1–2015Q4. Variables follow `jordagk.do` lines 95 and 104–105:

- $y_t$ = `rgdp/rgdp_pott6`;
- $g_t$ = `(ngov/pgdp)/rgdp_pott6`;
- $s_t$ = `newsy` = `news/(L.rgdp_pott6*L.pgdp)`, which is zero in 396 of 504 quarters and has s.d. 0.05973.

Cumulative variables are `f`i'cumuly` (lines 126–145). The linear control set is `L(1/4)` of newsy, $y$ and $g$. Level LPs have $T_h=500-h$ and run 1891Q1–2015Q4 at $h=0$; the common sample $\mathcal T_{20}$ has 480 rows, 1891Q1–2010Q4. The data are fetched by acquisition script, not shipped (D5).

**Smallest useful model.** Lecture 1's AR(1), $y_t=\rho y_{t-1}+\theta_0 s_t+v_t$, with $s_t$ i.i.d. and independent of $v$, and $\theta_0=1$. Substituting forward gives
$$y_{t+h}=\theta_h s_t+\rho^{h+1}y_{t-1}+\sum_{j=1}^{h}\rho^{h-j}(s_{t+j}+v_{t+j})+\rho^h v_t,\qquad\theta_h=\rho^h.$$
Subtracting $y_{t-1}$ changes only the coefficient on $y_{t-1}$, to $\rho^{h+1}-1$. The period-change LP has population coefficient $\theta_h-\theta_{h-1}=\rho^{h-1}(\rho-1)$ for $h\ge1$. The accumulated-level LP has $B_h=\sum_{j\le h}\theta_j=(1-\rho^{h+1})/(1-\rho)$. At $\rho=0.5$ and $h=0,1,2,3$ the three sequences are:

| Transformation | $h=0$ | $h=1$ | $h=2$ | $h=3$ |
|---|---|---|---|---|
| Level, $\theta_h$ | 1 | 0.5 | 0.25 | 0.125 |
| Period change, $\theta_h-\theta_{h-1}$ | 1 | −0.5 | −0.25 | −0.125 |
| Accumulated level, $B_h$ | 1 | 1.5 | 1.75 | 1.875 |

Everything in the lecture is this model with the dependent variable, the regressor set, the rows, or the units changed one at a time.

**Dependency chain of sections** (spine order preserved; titles refined).
1. `#sec-l02-four-outcomes` *Four dependent variables, four questions.* $y_{t+h}$, $y_{t+h}-y_{t-1}$, $\Delta y_{t+h}$ and $\sum_{j\le h}y_{t+j}$ ask where $y$ is at $h$, how far it has moved since $t-1$, how much it changed in period $t+h$, and how much in total through $h$, and the AR(1) gives each a closed-form coefficient with its own units.
2. `#sec-l02-same-regressor` *The same-regressor equivalence.* If $y_{t-1}$ is column $k$ of $\mathbf X$ and the rows are identical, $(\mathbf X'\mathbf X)^{-1}\mathbf X'(\mathbf y-\mathbf X\mathbf e_k)=\hat{\mathbf b}-\mathbf e_k$, so only the coefficient on $y_{t-1}$ moves (by exactly one) and the residuals are unchanged, as the hand table shows to eight decimals.
3. `#sec-l02-telescoping` *The telescoping identity and the rows it needs.* $y_{t+h}-y_{t-1}=\sum_{j=0}^{h}\Delta y_{t+j}$ holds row by row, and because OLS is linear in the dependent variable the period-change coefficients sum to the long-difference coefficient on a common sample but not on horizon-specific rows (hand table, $h=2$: $2.6226$ versus $2.1530$).
4. `#sec-l02-accumulation` *Accumulating changes is not accumulating levels.* Summing period-change responses returns the level response and summing level responses returns $B_h$, the total a multiplier needs ($-0.2933$ versus $4.1493$ on the seed-2 draw at $\rho=0.9$, $h=12$, common sample).
5. `#sec-l02-units` *Percent, percentage points, logs, and the size of the shock.* Percent comes from $100\log$ with an error that grows with the change (§6 D8), percentage points are differences of rates, and rescaling $s_t$ by $\Xi_s$ divides $\hat\beta_h$ by $\Xi_s$, so a one-standard-deviation normalization multiplies it by $\sigma_s$.
6. `#sec-l02-when-it-fails` *When the comparison changes two things.* Jordà–Taylor's long-difference LP omits $y_{t-1}$, so its smaller bias comes from dropping a control rather than from transforming the outcome: adding $y_{t-1}$ back reproduces the levels LP draw by draw, and the remaining bias at $\rho=1$ is the intercept's $O(h/T_h)$ effect, which vanishes without an intercept (1.015 at $h=10$ on the same 500 draws), while the levels LP's extra shortfall is exactly $(\hat\gamma_h-1)\hat\beta^{\mathrm{lag}}_h$ in every sample (D10). Lecture 1's design C gap ($-0.026$, $-0.033$ and $-0.049$ at $h=4,8,12$ for $\rho=0.9$, $T=200$; MC s.e. about 0.010; `design-01/brief/mc_toy_R500_summary.csv`) is this small-sample bias in a levels LP with an intercept (footnote 8, which points to the demeaning footnote 5).
7. `#sec-l02-samples` *Common versus horizon-specific samples.* Fixing $\mathcal T_H$ at every $h$ makes responses additive and comparable at a cost in rows (RZ: 500 rows at $h=0$ against 480 on $\mathcal T_{20}$, cumulative gap up to 0.0168), so the choice is recorded, not defaulted.
8. `#sec-l02-fiscal-units` *Reading the fiscal anchor's axes.* Dividing GDP, spending and news by trend GDP puts responses in percent of trend GDP per news worth 1 percent of trend GDP, sums in percent-of-trend-GDP quarters, and their ratio in no units at all (0.726344 on varying samples, 0.7295 on $\mathcal T_{20}$; D11).
9. `#sec-l02-summary` *What a transformation decides and what it does not.* The dependent variable, regressors, rows and units define what is analyzed, and none of them establishes that $s_t$ is uncorrelated with what else moves $y_{t+h}$.

**Central notation** (ledger symbols, no reassignment).

- **Ledger symbols used:** $\Delta y_t$, $y_{t+h}-y_{t-1}$, $B_h$ and $\hat B_h$, $\beta^Y_h$ and $\beta^G_h$, $M_H$, $\sigma_s$, $\rho$, $R$, $\mathcal T_h$ and $T_h$, and $\gamma_h$ (scalar when $\mathbf w_t=y_{t-1}$).
- **New local symbols** (flagged in §10): $\beta^{\mathrm{LD}}_h$, $\beta^{\Delta}_h$, $\beta^{\Sigma}_h$ are the coefficients on $s_t$ when the dependent variable is the long difference, the period change, and the accumulated level. Plain $\beta_h$ stays the levels coefficient. $\hat\beta^{\mathrm{lag}}_h$ is the in-sample coefficient on $s_t$ with $y_{t-1}$ on the left over $\mathcal T_h$ (population value 0; D10).
- **Other local notation:** $\mathbf X$ and $\mathbf x_t$ are the regressor matrix and row; $\mathbf e_k$ is the unit vector selecting regressor $k$; $\Xi_s$ is the rescaling constant for $s_t$. Reserved letters are avoided: D20 gives $c$ to the Gaussian width and $\kappa$, $\tau$ to Lecture 7's moving-average coefficients, and ledger §5 gives $\delta_k$ to Lecture 8. $\chi$ (kept for $\chi^2$) and $\varsigma$ (Lecture 3's proxy noise) are passed over too.
- **Not used:** $c$, $\kappa$, $\tau$, $\delta$, $\lambda$, $e$ (the JT code's `e` is written $v_t$).

**Glossary terms** (row 02 of the terminology plan; all 16 owned keys). The one-line drafts are the definition column of §3 and are not repeated here: `level-response`, `long-difference`, `first-difference`, `cumulative-response`, `same-regressor-equivalence`, `telescoping-identity`, `percentage-point`, `percent-change`, `log-approximation`, `shock-normalization`, `common-sample`, `horizon-specific-sample`, `trend-normalization`, `small-sample-bias`, `monte-carlo-simulation`, `statistical-reproduction`. Keys owned elsewhere appear only as prose, linked to their owners: `persistence` and `autoregressive-process` (L1), `cumulative-multiplier` (L4), `monte-carlo-uncertainty` (L5).

**Likely explanatory footnotes.**
1. Why $100\log$ is called "percent" and when the gap matters (§6 D8 table).
2. Stata's `F`h'.L.y` equals $y_{t+h-1}$, so JT's `df`h'y` is $\Delta y_{t+h}$.
3. Float storage in `jordagk.do`: assert float variables at $10^{-6}$, not $10^{-10}$ (evidence row in §4).
4. Monte Carlo standard error $\mathrm{sd}/\sqrt R$, which Lecture 5 treats as a named concept.
5. The demeaning bias at $\rho=1$ (formula in §6 D9).
6. D7 calls Lecture 3's object "the cumulative response of log shelter prices": it is the level response of the log price and the accumulated response of inflation.
7. Gordon–Krenn potential GDP (`rgdp_pott6`) versus CBO potential (`rgdp_potcbo`, `jordagk.do` line 91).
8. Lecture 1's design C gap, decomposed with D10 at $g=\rho^{h+1}$ on Lecture 1's seed-3 draws: at $h=12$ the $-0.0489$ shortfall is $-0.0327$ from the intercept (MC s.e. 0.0099; see footnote 5 and D10's weighted D9 counting, $-0.0370$) plus $-0.0162$ from estimating $\gamma_h$ (MC s.e. 0.0022) (`anchor/l02-designC-decomp.log`).

**Candidate figures** (spine's four; D24: each answers one question a table cannot).

| Label | Question | Lesson | Generating data |
|---|---|---|---|
| `fig-l02-four-transformations` | What do four dependent variables return on one draw? | Level and long difference coincide; the period change is the slope of the level response; the accumulated level climbs toward $1/(1-\rho)$ | `l02_fourtrans_rho{05,09}_seed2.csv` (estimates) with $\rho^h$, $\rho^h-\rho^{h-1}$, $(1-\rho^{h+1})/(1-\rho)$ overlaid; 2×4 small multiples |
| `fig-l02-equivalence-fits` | When $y_{t-1}$ is subtracted, what changes in the fit? | Fitted values shift by exactly $y_{t-1}$; residuals are identical row by row | `anchor/hand_h1_fits_l01.csv` (Lecture 1's hand table, $h=1$, rows 2–11) |
| `fig-l02-jt-bias` | Does the long-difference LP really have less bias? | The caption gives the reason: the gap closes completely when $y_{t-1}$ is added back; at $\rho=1$ the remaining bias tracks $-[h-h(h+1)/2T_h]/(T_h-1)$ | REP02 CSV ($R=500$); course harness on the same draws for the $y_{t-1}$ and no-intercept variants, with $\pm2$ MC s.e. (`l02_jt_mc_regressors.csv`, `l02_jt_mc_ovb_{95,100}.csv`); authors' stored $R=10{,}000$ means as a labeled reference |
| `fig-l02-three-axes` | Is it one response or three? | The same RZ output response read per unit news, per one-s.d. news, and accumulated | `RZ/l02_rz_responses.csv` (`bY`, `bY_pct_per_sd`, `BY`) |

**Exercise capabilities to test.** Units and population values of four transformations; proving and breaking the equivalence; assertions for telescoping and additivity; unit conversion; RZ cumulative variables at the right float tolerance; an ingredient-by-ingredient diagnosis of the JT comparison; a labeled reduced Monte Carlo.

**Candidate controlled experiments.** Each changes one ingredient with the data fixed: $y_{t-1}$ in or out; common or horizon-specific rows; accumulated change or accumulated level; $\Xi_s$; JT's intercept at $\rho=1$ (course harness, same draws); $\rho$ from 0.5 to 0.9 on the same innovations.

**Deliberately postponed.**

- **Lecture 3:** whether any of these regressions is causal, and which controls belong.
- **Lecture 4:** LP-IV, and the one-step multiplier with its instrument.
- **Lecture 5:** standard errors (including those of long-difference LPs), persistence and lag augmentation, and Monte Carlo uncertainty as a concept.
- **Lecture 6:** the standard error of $\hat B_h$, which needs the cross-horizon covariance.
- **Lecture 7:** small-sample bias of LPs versus VARs.

**Question handed on.** Every regression in this lecture is a statement about a projection. Which of them, if any, estimates what would have happened without the intervention? Lecture 3 opens on a dependent variable this lecture has taught students to read: IJK `Figure4.do` regresses $100\log$ shelter PCE price in long differences (lines 30, 60) on the Bauer–Swanson surprise with 12 lags each of $\Delta y$, the funds rate and unemployment (lines 73–74). There is no $y_{t-1}$, so §2 says it is not a relabeled levels LP. What its controls are for is the identification question.

## 2. Concept and notation ledger

Ledger symbols keep their ledger meaning. Rows marked *local* are new to this lecture; §10 asks the editor to confirm the local superscripts.

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $y_t$ | Outcome | scalar | $t$ | stated per anchor: simulated units; ratio to trend GDP (RZ); $100\log$ price (L3) | §1 | all |
| $s_t$ | Intervention variable | scalar | $t$ | simulated: s.d. 1; RZ `newsy`: share of lagged trend nominal GDP | §1 | all |
| $\Delta y_{t+h}$ | Period change, $y_{t+h}-y_{t+h-1}$ | scalar | change during $t+h$ | units of $y$ per period | §1 | L3 controls ($\Delta y$ lags), L5 |
| $y_{t+h}-y_{t-1}$ | Long difference from the last pre-intervention value | scalar | $t-1\to t+h$ | units of $y$ | §1 | L3 (IJK), L6, L8 (JT Ex. 6) |
| $\sum_{j=0}^{h}y_{t+j}$ | Accumulated level (RZ `f`h'cumuly`) | scalar | $t\to t+h$ | units of $y$ × periods | §1 | L4 multiplier numerator |
| $\beta_h$ | Levels LP coefficient on $s_t$ | scalar | row $t$, horizon $h$ | units of $y$ per unit of $s$ | §1 | all |
| $\beta^{\mathrm{LD}}_h$ *(local)* | Coefficient on $s_t$ with $y_{t+h}-y_{t-1}$ on the left | scalar | as $\beta_h$ | as $\beta_h$ | §1 | §6, REP02 |
| $\beta^{\Delta}_h$ *(local)* | Coefficient on $s_t$ with $\Delta y_{t+h}$ on the left | scalar | as $\beta_h$ | units of $y$ per period per unit of $s$ | §1 | §3, §4 |
| $\beta^{\Sigma}_h$ *(local)* | Coefficient on $s_t$ with $\sum_{j\le h}y_{t+j}$ on the left | scalar | as $\beta_h$ | units of $y$ × periods per unit of $s$ | §1 | §4, §7; equals $B_h$ on $\mathcal T_H$ |
| $\hat\beta^{\mathrm{lag}}_h$ *(local)* | In-sample coefficient on $s_t$ in the regression of $y_{t-1}$ on $(1,s_t)$ over $\mathcal T_h$; population value 0 | scalar | row $t$, rows $\mathcal T_h$ | units of $y$ per unit of $s$ | §6 D10 | none |
| $\theta_h$ | Causal response; $\rho^h\theta_0$ in the AR(1) | scalar | horizon $h$ | as $\beta_h$ | L1 | all |
| $B_h$, $\hat B_h$ | Cumulative response $\sum_{j\le h}\beta_j$ | scalar | through $h$ | as $\beta^{\Sigma}_h$ | §4 | L4, L6 (variance), L9 |
| $\gamma_h$ | Coefficient on $y_{t-1}$ (scalar case of $\boldsymbol\gamma_h$) | scalar | $t-1$ | units of $y$ per unit of $y$ | §2 | L3, L5 |
| $\mathbf X$, $\mathbf x_t$ *(local)* | Regressor matrix $T_h\times k$ and its row $t$ | $T_h\times k$, $k\times1$ | row $t$ | mixed | §2 | L3 (FWL) |
| $\mathbf e_k$ *(local)* | Unit vector selecting column $k$ of $\mathbf X$ | $k\times1$ | n/a | none | §2 | none |
| $\hat{\mathbf b}$ *(local)* | Full OLS coefficient vector $(\hat\mu_h,\hat\beta_h,\hat\gamma_h)'$ | $k\times1$ | horizon $h$ | mixed | §2 | L3 |
| $\Xi_s$ *(local)* | Rescaling constant: $\tilde s_t=\Xi_s s_t$ | scalar | none | units of $\tilde s$ per unit of $s$ | §5 | STA02 task 4 |
| $\sigma_s$ | Standard deviation of $s_t$ | scalar | sample stated | units of $s$ | §5 | L4, L9 |
| $\rho$ | AR(1) persistence | scalar | none | none | §1 | L5, L7 |
| $\mathcal T_h$, $T_h$ | Horizon-$h$ rows and count | set, integer | horizon $h$ | rows | §3 | all |
| $\mathcal T_H$ | Common sample | set | fixed across $h$ | rows | §7 | L6, L4 |
| $\beta^Y_h$, $\beta^G_h$ | Output and spending responses | scalar | horizon $h$ | percent of trend GDP per news worth 1 percent of trend GDP | §8 | L4, L9 |
| $M_H$ | $B^Y_H/B^G_H$ | scalar | through $H$ | dimensionless | §8 (reading only) | L4 (owner of the concept) |
| $R$ | Monte Carlo replications | integer | none | draws | §6 | L5–L7 |

## 3. Terminology ledger

All 16 owned keys are marked once. Other lectures' keys appear as prose.

| Phrase | Treatment | Key | One-sentence definition | First marked section |
|---|---|---|---|---|
| level response | glossary | `level-response` | The coefficient on $s_t$ with $y_{t+h}$ on the left: where the outcome stands at $h$, in units of $y$ per unit of $s$. | `#sec-l02-four-outcomes` |
| long difference | glossary | `long-difference` | $y_{t+h}-y_{t-1}$, whose LP coefficient equals the level response only when $y_{t-1}$ is a regressor. | `#sec-l02-four-outcomes` |
| first difference | glossary | `first-difference` | $\Delta y_t$; as a dependent variable it gives the response of the one-period change. | `#sec-l02-four-outcomes` |
| cumulative response | glossary | `cumulative-response` | $B_h=\sum_{j\le h}\beta_j$, the total through $h$. | `#sec-l02-four-outcomes` |
| same-regressor equivalence | glossary | `same-regressor-equivalence` | Subtracting an included regressor from $y$ changes only that coefficient, by one, given identical regressors and rows. | `#sec-l02-same-regressor` |
| telescoping identity | glossary | `telescoping-identity` | $y_{t+h}-y_{t-1}=\sum_{j=0}^{h}\Delta y_{t+j}$ row by row. | `#sec-l02-telescoping` |
| common sample | glossary | `common-sample` | One row set $\mathcal T_H$ at every horizon, which makes LPs additive across $h$. | `#sec-l02-telescoping` |
| horizon-specific sample | glossary | `horizon-specific-sample` | All rows available at each $h$, so neighbouring estimates use different data. | `#sec-l02-telescoping` |
| percent change | glossary | `percent-change` | $100(x_1-x_0)/x_0$, which LPs approximate by $100\Delta\log x$. | `#sec-l02-units` |
| percentage point | glossary | `percentage-point` | The unit of a difference of two rates. | `#sec-l02-units` |
| log approximation | glossary | `log-approximation` | $100\log(1+g)\approx100g$; the error is −0.47 at 10 percent and −10.24 at −38.7 percent, so large responses are converted, not read off. | `#sec-l02-units` |
| shock normalization | glossary | `shock-normalization` | The units chosen for $s_t$; they rescale $\hat\beta_h$ without changing the response to a given intervention. | `#sec-l02-units` |
| small-sample bias | glossary | `small-sample-bias` | Mean of an estimator at fixed $T$ minus its population value; it can differ between specifications that share an estimand. | `#sec-l02-when-it-fails` |
| Monte Carlo simulation | glossary | `monte-carlo-simulation` | $R$ seeded draws from a known design, summarized; its averages carry simulation error of order sd$/\sqrt R$. | `#sec-l02-when-it-fails` |
| statistical reproduction | glossary | `statistical-reproduction` | A reduced or re-seeded rerun that can match a pattern but not published digits. | `#sec-l02-when-it-fails` |
| trend normalization | glossary | `trend-normalization` | Dividing by trend output so that responses share units and ratios are dimensionless. | `#sec-l02-fiscal-units` |
| accumulated change / accumulated level | prose | none | Two phrases the notes contrast every time; no key (§10). | `#sec-l02-accumulation` |
| log points | footnote | none | $100\times$ a log difference; approximately percent. | `#sec-l02-units` |
| float storage | footnote | none | Stata `float` holds about 7 digits, so assertions on float variables use $10^{-6}$. | `#sec-l02-fiscal-units` |
| demeaning bias | footnote | none | The $O(h/T_h)$ bias from the intercept when the regressand contains the regressor's future neighbours. | `#sec-l02-when-it-fails` |
| Monte Carlo standard error | footnote (L5 owns `monte-carlo-uncertainty`) | none | $\mathrm{sd}/\sqrt R$. | `#sec-l02-when-it-fails` |

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| One dataset yields 0.29, 1.76, 3.53 and 0.73 | RZ OLS level LP peak `bY`=0.2938 at $h=10$; $100\sigma_s\cdot$`bY`=1.755; $B_{20}$=3.5327; two-step ratio 0.726344 | prose + table | `RZ/l02-rz-checks.log` R2, R3; `junk2step.csv` | computed | `#sec-l02-four-outcomes` opener |
| Four transformations have distinct population coefficients | closed forms with a $T=100{,}000$ check (§6 D4, D6) | equation + table | `anchor/l02-extra-checks.log` (ii) | computed | `eq-l02-four-populations` |
| One draw under four transformations | seed 2, $T=200$, $H=12$ | figure | `l02_fourtrans_rho{05,09}_seed2.csv` | data ready; TikZ to build | `fig-l02-four-transformations` |
| Same-regressor equivalence | §6 D1 (hand table; seed-2 draw; RZ at $h=4$) | derivation + figure | `l02-derivations-l01table.log` D1; `l02-derivations.log` D6 | computed | `eq-l02-equivalence`, `fig-l02-equivalence-fits` |
| Dropping $y_{t-1}$ breaks it | §6 D1 | table | `l02-derivations-l01table.log` D1 | computed | `tbl-l02-break` |
| Telescoping + common sample ⇒ additivity | §6 D2–D3 | table | `l02-derivations-l01table.log` D2–D3 | computed | `eq-l02-telescoping` |
| Accumulated change ≠ accumulated level | §6 D4 | table + figure | D6 | computed | `tbl-l02-accumulate` |
| Log approximation errors | §6 D8 | table | D8 | computed | `tbl-l02-logs` |
| RZ trend ratio: $100\ln y$ vs $100(y-1)$ | 1933Q1 −48.988 vs −38.730; 2009Q2 −3.367 vs −3.311 | table | `l02-rz-checks.log` R3 | computed | `#sec-l02-fiscal-units` |
| Rescaling | §6 D5 | prose | `l02-derivations-l01table.log` D5; R4 | computed | `#sec-l02-units` |
| JT long difference omits $y_{t-1}$ | `SSBias_IntcpYLagdiffN_95.do` line 87 vs line 108 | code excerpt | frozen package | verified | `#sec-l02-when-it-fails` |
| Adding $y_{t-1}$ reproduces levels draw by draw | §6 D7 | prose + figure | `jt-ex1/l02-jt-mc-regressors.log` | computed | `fig-l02-jt-bias` |
| The levels–long-difference gap is $(\hat\gamma_h-1)\hat\beta^{\mathrm{lag}}_h$ | §6 D10: identity to $2.8\times10^{-15}$ in every draw; $\rho=1$, $h=10$: gap 0.2684, of which 0.0272 is covariance | derivation + table | `jt-ex1/l02-jt-mc-ovb-summary.log`; `l02_jt_mc_ovb_{95,100}.csv` | computed | `eq-l02-ovb-gap` |
| No-intercept long difference on the same draws | $\rho=1$, $h=10$: 1.0147 (MC s.e. 0.0219), $R=500$; the authors' unmodified `IntcpN` workers at $R=500$ agree to $9.7\times10^{-8}$ | lab + table | `l02_jt_mc_ovb_{95,100}.csv`; `jt-ex1/intcpN-500/` | computed | Lab 5, `eq-l02-demeaning` |
| L01 design C gap is small-sample bias | $\rho=0.9$, $T=200$, $R=500$: $-0.0263$, $-0.0332$, $-0.0489$ at $h=4,8,12$ (MC s.e. 0.0088–0.0102); at $h=12$, intercept $-0.0327$ plus $\gamma_h$ term $-0.0162$ | sentence + footnote | `design-01/brief/mc_toy_R500_summary.csv`; `anchor/l02-designC-decomp.log` | computed | `#sec-l02-when-it-fails`, footnote 8 |
| JT bias pattern | $\rho=1$, $h=10$: levels 0.6347 ($R=500$), 0.6296 (authors, $R=10^4$); long difference 0.9032 / 0.8962 | figure + table | REP02 CSV; `dump_stored.log` | benchmark + stored | `fig-l02-jt-bias`, `tbl-l02-rep02` |
| Remaining $\rho=1$ LD bias is demeaning | §6 D9 | derivation + footnote | §6 D9; `dump_stored.log`; `l02_jt_mc_ovb_100.csv` | computed | `eq-l02-demeaning` |
| Common vs horizon-specific (RZ) | $T_0=500$, $\mathcal T_{20}$=480 rows (1891Q1–2010Q4); max $|\hat\beta^{\Sigma}_h-\sum\hat\beta_j|=0.0168$ on horizon-specific rows; exact on $\mathcal T_{20}$ | table | R2, R5 | computed | `tbl-l02-rz-samples` |
| Multiplier sample alignment | 0.726344 (varying) vs 0.7295 (common, $\hat\beta^{\Sigma,Y}_{20}/\hat\beta^{\Sigma,G}_{20}$ = 3.5496/4.8659); D11 audited 0.729480 | prose | R2; D11 | computed + benchmark | `#sec-l02-fiscal-units` |
| One response, three axes | per unit news; per one-s.d. ($\sigma_s=0.05973$); cumulative | figure | `l02_rz_responses.csv` | data ready | `fig-l02-three-axes` |
| Float accumulation tolerance | 118 rows fail at $10^{-10}$; max gap $4.768\times10^{-7}$; double: 0 | footnote | `brief-checks/l02-brief-checks.log` (b) | computed | footnote 3 |
| REP02 reruns in 19.5 | see §8.1 | table | `brief-checks/rep02-500/` | computed | `tbl-l02-rep02` |

## 5. Assessment map

Ten exercises. Four are Stata [computational], one of them [data]. D26 tags the long Monte Carlo [extra] with default $R=200$.

| Outcome | Exercise | Tags | Mode of work | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. Four axes, one economy | [core] [pencil] | At $\rho=0.9$, $\theta_0=1$: population coefficients for all four dependent variables, $h=0,\dots,3$, with units; say which question each answers | Iterate the AR(1) once and write $y_{t+h}$ before transforming | $\theta_h$: 1, 0.9, 0.81, 0.729; $\theta_h-\theta_{h-1}$: 1, −0.1, −0.09, −0.081; $B_h$: 1, 1.9, 2.71, 3.439 | 1 |
| 2 | 2. Three lines of OLS | [core] [pencil] | Prove the equivalence for general $\mathbf X$; then use the hand table at $h=2$ to say what changes when $y_{t-1}$ is dropped | Write $y_{t+h}-y_{t-1}$ as $\mathbf y-\mathbf X\mathbf e_k$ | $\hat{\mathbf b}-\mathbf e_k$; 2.15302246 versus 2.49268624 | 2 |
| 3 | 3. Telescoping on paper | [core] [pencil] | Row $t=5$ identity; list rows used by $\Delta y_{t}$, $\Delta y_{t+1}$, $\Delta y_{t+2}$ at $h=2$; explain why their coefficient sum differs from $\hat\beta^{\mathrm{LD}}_2$ | Count rows before computing anything | 1.9703125; $T_0,T_1,T_2=11,10,9$; 2.622612 versus 2.153022 on $\mathcal T_2$ | 2 |
| 2, 3 | 4. Four transformations with assertions (Stata) | [core] [computational] | On the shipped seed-2 draw, $\rho=0.9$: loop $h=0,\dots,12$, store `beta_h` for four dependent variables, on $\mathcal T_h$ and $\mathcal T_{12}$ | Build the common-sample flag once from the $h=12$ regression | `assert` level = long difference, $<10^{-8}$; on $\mathcal T_{12}$, running sum of $\hat\beta^{\Delta}$ = level and running sum of level = $\hat\beta^{\Sigma}$; $\hat\beta_{12}=-0.2933$, $\hat\beta^{\Sigma}_{12}=4.1493$ | 1, 3 |
| 2, 3 | 5. Break it on purpose (Stata) | [computational] | Three breaks: drop `L.y` from the long difference; estimate the long difference on rows `t>=20` only; add `L2.y` to one side only. Report the largest gap and the condition each break violates | Change one ingredient per run | Each gap $>10^{-3}$; restoring the ingredient returns $<10^{-8}$ (asserted) | 2 |
| 4 | 6. Percent, points, logs, and the size of the shock | [core] [pencil] | Log-approximation table; RZ 1933Q1 trend ratio 0.6127 in percent and log points; a rate from 4% to 5% in percent and points; rescale the hand-table $\hat\beta_1$ by $\Xi_s=10$ and to one s.d. | Separate "what is measured" from "how it is scaled" | −10.24 gap at −38.7%; −38.73 versus −48.99; 1 pp = 25%; −0.10504052 and −0.44288972 | 4 |
| 3, 4 | 7. The fiscal anchor's cumulative variables (Stata) | [core] [data] [computational] | Run `get_data.do`; build `y`, `g`, `newsy` and `f`h'cumuly` as in `jordagk.do`; assert the identity; estimate level and accumulated-level LPs on $\mathcal T_h$ and $\mathcal T_{20}$; plot one response on three labeled axes | Ask why an assertion at $10^{-10}$ fails on float variables | $T_h=500-h$; $\hat\sigma_s=0.05973$; $\hat\beta_{10}=0.2938$; $\sum_{j\le20}\hat\beta_j=3.5327$; $\hat\beta^{\Sigma}_{20}=3.5496$; ratio 0.7295 on $\mathcal T_{20}$ | 4 |
| 5 | 8. What differs in Figure 1? | [core] [pencil] | From `SSBias_IntcpYLagdiffN_95.do` lines 87, 94, 99, 108 and 117, write the specification table (dependent variable, regressors, rows, intercept); classify four given sentences about the figure as supported or not | Put the two regressions side by side, column by column | Regressor sets differ by $y_{t-1}$; rows identical; the transformation alone cannot explain the gap | 5 |
| 5 | 9. The Jordà–Taylor comparison at $R=200$ (Stata) | [computational] [extra] | Course harness with `global R 200`: levels, JT long difference, long difference with `L.y`, and the no-intercept long difference; means, bias, $\pm2$ MC s.e.; compare with the $R=500$ benchmark rows | Store every draw with `postfile`; summarize once | Draw-by-draw `assert` levels = long difference with `L.y`; the $\rho=1$ no-intercept bias within 2 MC s.e. of 0 (largest 1.38 MC s.e., at $h=5$, on the first 200 draws); runtime about 3 minutes (estimated from the $R=500$ run, to be timed) | 5 |
| 5 | 10. Where the intercept bites | [extra] [pencil] | At $\rho=1$ derive $\mathbb E[\hat\beta^{\mathrm{LD}}_h]-1\approx-[h-h(h+1)/(2T_h)]/(T_h-1)$; compare with the authors' stored means | Expand $\sum_t(s_t-\bar s)s_{t+j}$ and count matching pairs | −0.0102, −0.0520, −0.1066 at $h=1,5,10$ against −0.0103, −0.0511, −0.1038 | 5 |

Coverage: outcome 1 (§1 table, `fig-l02-four-transformations`, exercises 1 and 4, lab 1); outcome 2 (D1, `fig-l02-equivalence-fits`, exercises 2, 4, 5, lab 2); outcome 3 (D2–D4, exercises 3, 4, 7, labs 2–3); outcome 4 (D5, D8, `fig-l02-three-axes`, exercises 6–7, lab 4); outcome 5 (`fig-l02-jt-bias`, exercises 8–10, lab 5, REP02).

## 6. Derivations to verify

Every check passed with the assertion shown (do-files in `design-02/anchor`, `RZ`, `jt-ex1`, `brief-checks`). Displays are rounded; computations use full precision.

**D1. Same-regressor equivalence** (`eq-l02-equivalence`).

- *Source identity.* $\hat{\mathbf b}=(\mathbf X'\mathbf X)^{-1}\mathbf X'\mathbf y$, with $\mathbf y$ stacking $y_{t+h}$ over the rows $\mathcal T_h$, and column $k$ of $\mathbf X$ equal to $y_{t-1}$.
- *Steps.* Substitute: $(\mathbf X'\mathbf X)^{-1}\mathbf X'(\mathbf y-\mathbf X\mathbf e_k)=\hat{\mathbf b}-(\mathbf X'\mathbf X)^{-1}\mathbf X'\mathbf X\mathbf e_k=\hat{\mathbf b}-\mathbf e_k$. The residuals are $(\mathbf y-\mathbf X\mathbf e_k)-\mathbf X(\hat{\mathbf b}-\mathbf e_k)=\mathbf y-\mathbf X\hat{\mathbf b}$.
- *Conditions.* The same $\mathbf X$ (same columns, same rows) on both sides. With $y_{t-1}\notin\mathbf X$ the step $\mathbf X\mathbf e_k$ does not exist.
- *Hand table (inputs in §1).*
  - $h=1$, rows 2–11: $(\hat\mu,\hat\beta,\hat\gamma)=(1.05690624,-1.05040519,-0.11492433)$ against $(1.05690624,-1.05040519,-1.11492433)$; RSS 9.69221319 both; all 10 residuals equal row by row.
  - $h=2$, rows 2–10: $\hat\beta=2.15302246$ both; $\hat\gamma=0.23267886$ against $-0.76732114$.
  - Long difference without $y_{t-1}$: $-0.39993286$ ($h=1$) and 2.49268624 ($h=2$).
- *Seed-2 draw.* $\max_h|\hat\beta_h-\hat\beta^{\mathrm{LD}}_h|=7.77\times10^{-16}$ ($\rho=0.9$) and $2.22\times10^{-16}$ ($\rho=0.5$).
- *RZ data at $h=4$.* Asserted at $10^{-10}$ in the course do-file.

**D2. Telescoping identity** (`eq-l02-telescoping`).

- *Steps.* $\sum_{j=0}^{h}(y_{t+j}-y_{t+j-1})$: every interior term appears once with each sign.
- *Check (hand table, row $t=5$, $h=2$).* $y_7-y_4=2.0328125-0.0625=1.9703125$, and $\Delta y_5+\Delta y_6+\Delta y_7=-0.73125+0.534375+2.1671875=1.9703125$ exactly (asserted $<10^{-10}$ on every row).

**D3. Additivity on a fixed design.**

- *Source identity.* OLS is linear in $\mathbf y$: $(\mathbf X'\mathbf X)^{-1}\mathbf X'\sum_j\mathbf y_j=\sum_j\hat{\mathbf b}_j$, when every $\mathbf y_j$ is stacked over the same rows.
- *Combined with D2.* $\hat\beta^{\mathrm{LD}}_h=\sum_{j\le h}\hat\beta^{\Delta}_j$ on $\mathcal T_h$.
- *Hand table, $h=2$, regressors $(1,s_t,y_{t-1})$.*
  - Horizon-specific rows give $\hat\beta^{\Delta}_0,\hat\beta^{\Delta}_1,\hat\beta^{\Delta}_2=0.575667\ (T=11),\ -1.022364\ (10),\ 3.069308\ (9)$, which sum to $2.622612$.
  - On $\mathcal T_2$ they are $-0.072551,\ -0.843735,\ 3.069308$, which sum to $2.153022=\hat\beta^{\mathrm{LD}}_2$ (asserted $10^{-10}$).
- *RZ, $\mathcal T_{20}$.* $\max_h|\sum_{j\le h}\hat\beta_j-\hat\beta^{\Sigma}_h|$ is below $10^{-8}$. On horizon-specific rows it reaches 0.0168.

**D4. Accumulated change versus accumulated level.**

- *By D2–D3.* The accumulated change is the long difference, so its coefficient is the level response. The accumulated level is $\sum_j y_{t+j}$, so by D3 its coefficient on $\mathcal T_h$ is $\sum_j\hat\beta_j=\hat B_h$.
- *Hand table, $h=2$.* $\hat\beta^{\Sigma}_2=1.164185$, equal to the sum of the three level coefficients on the same 9 rows ($-0.072551-0.916286+2.153022$); the accumulated change is $2.153022$.
- *Seed 2, $\rho=0.9$, $\mathcal T_{12}$ ($T=187$), $h=0..12$.* Level: 0.8714, 0.8303, 0.5578, …, −0.2933. Accumulated level: 0.8714, 1.7016, 2.2594, …, 4.1493.
- *Population ($T=100{,}000$, seed 4).* At $h=8$: level 0.4249 (truth 0.4305), period change −0.0472 (−0.0478), accumulated level 6.0919 (6.1258), $\hat\gamma_8=0.3792$ ($\rho^9=0.3874$).

**D5. Rescaling and normalization.**

- *Source identity.* With $\tilde s_t=\Xi_s s_t$, the column is rescaled, so $\tilde\beta_h=\beta_h/\Xi_s$ and the fitted values are unchanged. The response to an intervention of $\Delta s$ original units is $\tilde\beta_h\,\Xi_s\Delta s=\beta_h\Delta s$.
- *Checks.*
  - $\Xi_s=10$: $-0.10504052$ against $-1.05040519/10$.
  - $\Xi_s=1/\hat\sigma_s$ with $\hat\sigma_s=0.421637$ (the 0/1 shock on the rows used at $h=1$): $-0.44288972$.
  - RZ, $\Xi_s=100$ (news in percent of trend GDP), $h=10$: 0.00293764 against $\hat\beta_{10}/100=0.293764/100$.
  - All asserted at $10^{-8}$ or tighter.

**D6. Population coefficients** (`eq-l02-four-populations`).

- *Source.* The forward substitution in §1, with $s_t$ independent of $(y_{t-1},s_{t+j},v_{t+j})$, so the projection coefficient on $s_t$ is the coefficient in the substituted equation.
- *Coefficients.* Level: $\rho^h$. Long difference: $\rho^h$. Period change: $\rho^h-\rho^{h-1}$. Accumulated level: $\sum_{j\le h}\rho^j$. Coefficient on $y_{t-1}$: $\rho^{h+1}$ in levels and $\rho^{h+1}-1$ in the long difference.
- *Checks.* $\rho=0.5$ values in §1. $T=100{,}000$ values in D4.

**D7. The JT regressor mapping.**

- *Mapping.* JT's long-difference LP equals the levels LP with $\gamma_h$ constrained to 1. Since $s_t\perp y_{t-1}$ in this design, both have probability limit $\theta_h$; any difference is finite-sample, and D10 writes it exactly.
- *First realization (seed 12345, $\rho=0.95$).* At $h=4$, levels 0.403161, JT long difference 0.707324, long difference with $y_{t-1}$ 0.403161. At $\rho=1$, $h=4$: 0.339892, 0.764253, 0.339892.
- *Monte Carlo.* 500 draws × 2 $\rho$ × 11 $h$: levels = long difference with $y_{t-1}$, asserted $<10^{-8}$.

**D8. Log approximation.** $100\ln(1+g)-100g$ is $-0.005$ at 0.01, $-0.121$ at 0.05, $-0.469$ at 0.10, $-2.686$ at 0.25, $-0.536$ at −0.10, $-3.768$ at −0.25, and $-10.239$ at −0.387.

**D9. Demeaning bias at $\rho=1$** (`eq-l02-demeaning`).

- *Source.* With $\rho=1$, $y_{t+h}-y_{t-1}=\sum_{j=0}^{h}(s_{t+j}+v_{t+j})$. OLS on $(1,s_t)$ over $n=T_h=99-h$ rows.
- *Steps.* $\hat\beta^{\mathrm{LD}}_h-1=\sum_t(s_t-\bar s)\big[\sum_{j=1}^{h}s_{t+j}+\sum_{j=0}^{h}v_{t+j}\big]\big/\sum_t(s_t-\bar s)^2$. The $v$ terms have mean zero.
- *Expectation.* $\mathbb E\sum_t(s_t-\bar s)s_{t+j}=-\tfrac1n\#\{(u,t):u=t+j\}=-(n-j)/n$. Summing over $j$ and dividing by $\mathbb E\sum(s_t-\bar s)^2=n-1$ (ratio-of-expectations approximation) gives $-[h-h(h+1)/(2n)]/(n-1)$.
- *Without an intercept* $\bar s$ is absent, so the bias is 0.
- *Check.*

| $h$ | $T_h$ | Formula | Authors' stored mean − 1 ($R=10^4$) | MC s.e. ($\approx$ sd$/100$) | Benchmark ($R=500$) | Authors' no-intercept ($R=10^4$) | Course harness no-intercept ($R=500$, same draws; MC s.e.) |
|---|---|---|---|---|---|---|---|
| 1 | 98 | −0.0102 | −0.0103 | 0.0017 | −0.0056 | −0.0002 | +0.0063 (0.0076) |
| 5 | 94 | −0.0520 | −0.0511 | 0.0034 | −0.0313 | +0.0002 | +0.0229 (0.0158) |
| 10 | 89 | −0.1066 | −0.1038 | 0.0045 | −0.0968 | +0.0009 | +0.0147 (0.0219) |

**D10. Where the levels LP's extra bias comes from** (`eq-l02-ovb-gap`).

- *Source identity.* Omitted-variable algebra on one row set $\mathcal T_h$. Let $\hat\beta^{\mathrm{lag}}_h$ be the slope of $y_{t-1}$ on $(1,s_t)$ over $\mathcal T_h$. For a constant $g$, regress $y_{t+h}-g\,y_{t-1}$ on $(1,s_t)$ and call the slope $\tilde b_h(g)$. The long regression on $(1,s_t,y_{t-1})$ has slope $\hat\beta_h$ for every $g$ (D1) and coefficient $\hat\gamma_h-g$ on $y_{t-1}$, so $\tilde b_h(g)=\hat\beta_h+(\hat\gamma_h-g)\,\hat\beta^{\mathrm{lag}}_h$ exactly.
- *JT's comparison ($g=1$).* $\hat\beta^{\mathrm{LD}}_h-\hat\beta_h=(\hat\gamma_h-1)\,\hat\beta^{\mathrm{lag}}_h$ in every sample, at any $\rho$.
- *First realization (seed 12345, $\rho=1$, $h=4$).* $\hat\gamma_4=0.589502$ and $\hat\beta^{\mathrm{lag}}_4=-1.033772$, so the product is $0.424361=0.764253-0.339892$ (D7).
- *Monte Carlo* (the D7 draws, $R=500$; the identity holds in every draw to $2.8\times10^{-15}$, asserted at $10^{-12}$):

| $\rho$ | $h$ | Levels | JT long diff. | Gap $=$ mean of $(\hat\gamma_h-1)\hat\beta^{\mathrm{lag}}_h$ | Mean $\hat\gamma_h$ ($\rho^{h+1}$) | Mean $\hat\beta^{\mathrm{lag}}_h$ | Product of means | Covariance |
|---|---|---|---|---|---|---|---|---|
| 0.95 | 5 | 0.678004 | 0.792438 | 0.114434 | 0.526188 (0.735092) | −0.182585 | 0.086511 | 0.027923 |
| 0.95 | 10 | 0.431520 | 0.599825 | 0.168305 | 0.267952 (0.568800) | −0.192820 | 0.141154 | 0.027151 |
| 1.00 | 5 | 0.811749 | 0.968663 | 0.156914 | 0.729233 (1) | −0.516983 | 0.139982 | 0.016932 |
| 1.00 | 10 | 0.634735 | 0.903178 | 0.268443 | 0.532440 (1) | −0.516064 | 0.241291 | 0.027152 |

- *Mechanism.* Two finite-sample errors multiply.
  - $y_{t-1}$ is a regressor but not strictly exogenous: it contains the disturbances in earlier rows' errors, so $\hat\gamma_h$ falls below $\rho^{h+1}$ (mean 0.532 against 1 at $\rho=1$, $h=10$, $T_h=89$).
  - The intercept makes $s_t$ negatively correlated in sample with the past shocks inside $y_{t-1}$. At $\rho=1$ each of the $n(n-1)/2$ in-sample pairs of a row and an earlier shock inside $y_{t-1}$ contributes $-1/n$ (the counting of D9), so $\mathbb E\sum_t(s_t-\bar s)y_{t-1}=-(n-1)/2$ and $\hat\beta^{\mathrm{lag}}_h\approx-1/2$ at every $h$ (means $-0.498$ to $-0.523$ across $h$), against a population value of 0.
  - Both errors are negative, so the gap is positive: at $\rho=1$, $h=10$, 0.241 of the 0.268 is the product of the means and 0.027 their covariance (correlation 0.17). JT's long difference imposes $\gamma=1$, which is exact at $\rho=1$, so only D9's demeaning term remains. Herbst and Johannsen (2024) analyze small-sample LP bias in general.
- *General $g$ (Lecture 1's design C).* At $g=\rho^{h+1}$, $\tilde b_h-\theta_h$ holds only the intercept's demeaning term, whose expectation by D9's counting with weights $\rho^{h-j}$ is about $-\sum_{j=1}^{h}\rho^{h-j}(n-j)/\{n(n-1)\}$. So $\hat\beta_h-\theta_h=[\tilde b_h-\theta_h]-(\hat\gamma_h-\rho^{h+1})\,\hat\beta^{\mathrm{lag}}_h$. On Lecture 1's seed-3 draws ($\rho=0.9$, $T=200$, $R=500$; means equal `mc_toy_R500_summary.csv` to $10^{-7}$):

| $h$ | Shortfall $\hat\beta_h-\theta_h$ (MC s.e.) | Intercept term (MC s.e.) | Counting approximation | $\gamma_h$ term (MC s.e.) |
|---|---|---|---|---|
| 4 | −0.0263 (0.0088) | −0.0109 (0.0086) | −0.0175 | −0.0154 (0.0014) |
| 8 | −0.0332 (0.0102) | −0.0159 (0.0099) | −0.0292 | −0.0173 (0.0019) |
| 12 | −0.0489 (0.0100) | −0.0327 (0.0099) | −0.0370 | −0.0162 (0.0022) |

- *Evidence.* `jt-ex1/l02-jt-mc-ovb.do` (95 s per $\rho$), `l02-jt-mc-ovb-summary.log`, `l02_jt_mc_ovb_{95,100}.csv`; `anchor/l02-designC-decomp.do` (57 s), its log, and `l02_designC_decomp.csv`.

## 7. HTML lab plan

Five labs follow the dependency chain. Each has the same parts:

- a setup paragraph and a **Predict before using the controls** prompt;
- controls with units, a plot or table, and a reactive sentence;
- controlled comparisons and a collapsed explanation.

Draws are shipped, never regenerated, so toggling a control never changes the data. Every panel is labeled *live calculation*, *stored result*, or *conceptual illustration*. No lab draws bands.

**Lab 1: One path, four axes (live calculation).**

- *Question.* What does each dependent variable return on the same draw?
- *Invariants.* The seed-2 innovation stream (`seed2_innovations_300.csv`, whose rows 101–300 are Lecture 1's `onedraw_rho0{5,9}_seed2.csv`; anchor B), $\theta_0=1$, controls $(1,y_{t-1})$, $H=12$.
- *Controls.*
  - $\rho\in\{0.5,0.9\}$, default 0.9.
  - Dependent variable: level, long difference, period change, accumulated level; default level.
  - Rows: horizon-specific $\mathcal T_h$ or common $\mathcal T_{12}$; default horizon-specific.
  - Overlay truth: on or off.
- *Computation.* OLS by normal equations in JS. Validation against `l02_fourtrans_rho{05,09}_seed2.csv` at $10^{-5}$: the double rebuild of the float path differs by $4.3\times10^{-7}$.
- *Reactive sentence.* "At $\rho=0.90$ on the common sample, the level response at $h=12$ is −0.293 (population 0.282) and the accumulated level is 4.149 (population 7.458). Summing the period-change responses gives −0.293 again, not 4.149."
- *Comparisons.* Switch the dependent variable with the rows fixed; switch the rows with the dependent variable fixed; switch $\rho$.
- *Handoff.* CSV of the displayed coefficients plus the settings header, for exercise 4.

**Lab 2: Subtract a regressor (live calculation).**

- *Question.* When is a long-difference LP the levels LP in different clothes?
- *Invariants.* Lecture 1's hand table (anchor A), $h\in\{1,2\}$.
- *Controls.*
  - Dependent variable: $y_{t+h}$ or $y_{t+h}-y_{t-1}$.
  - $y_{t-1}$ in the regressors: on or off, default on.
  - First row: 2 or 4, default 2.
- *Output.* Coefficient table and a row-by-row residual strip (`fig-l02-equivalence-fits` in live form).
- *Reactive sentence.* "With $y_{t-1}$ included and rows 2–11, $\hat\beta_1=-1.0504$ in both regressions, the coefficient on $y_{t-1}$ differs by exactly 1.0000, and all 10 residuals match; turning $y_{t-1}$ off moves the long-difference $\hat\beta_1$ to $-0.3999$."
- *Comparisons.* Toggle $y_{t-1}$; toggle the first row with $y_{t-1}$ on (the equivalence survives if both sides move); move the first row on one side only.
- *Prediction prompt.* "If both regressions drop the first two rows, does the equivalence survive?"
- *Handoff.* A specification-record JSON (dependent variable, regressors, rows) for exercise 5.

**Lab 3: Accumulate what? (live population calculation).**

- *Question.* What does summing changes return, and what does summing levels return?
- *Invariants.* The AR(1) population; no sampling.
- *Controls.* $\rho\in[0,1]$ (step 0.05, default 0.9); $H\in\{8,12,20\}$.
- *Output.* $\theta_h$, $\sum_{j\le h}(\theta_j-\theta_{j-1})$, $B_h$.
- *Reactive sentence.* "At $\rho=0.90$, accumulated changes return 0.282 at $h=12$, exactly the level response; accumulated levels return 7.458, heading to $1/(1-\rho)=10$."
- *Comparisons.* $\rho\to1$ ($B_h\to h+1$); $\rho=0$ ($B_h=1$).
- *Handoff.* A prediction of $B_{12}$ at $\rho=0.5$ (1.9998), checked in exercise 1.

**Lab 4: One response, three axes (stored result).**

- *Question.* Is a relabeled axis a different finding?
- *Invariants.* RZ OLS responses (`RZ/l02_rz_responses.csv`), four lags.
- *Controls.*
  - Shock units: per unit of news as a share of trend GDP (default), per percentage point of trend GDP, or per one s.d. ($\hat\sigma_s=0.05973$).
  - Accumulation: level or cumulative.
  - Rows: $\mathcal T_h$ or $\mathcal T_{20}$.
- The axis label and caption regenerate from the settings.
- *Reactive sentence.* "Ten quarters after news worth one standard deviation (5.97 percent of trend GDP), the projection coefficient implies GDP 1.76 percent of trend GDP higher; the same estimate per unit of news is 0.29. Nothing but the axis changed."
- *Comparisons.* Change the units with the accumulation fixed; change the accumulation with the units fixed.
- *Handoff.* Exported axis-label string plus a prediction of the coefficient after $\Xi_s=100$, for exercise 7.

**Lab 5: Two ingredients, one figure (stored simulation result).**

- *Question.* Is Jordà–Taylor's gap about the transformation?
- *Invariants.* JT design, $T=100$, $h=0,\dots,10$, and one draw set for every regressor set: the course harness's seed-12345 draws, $R=500$.
- *Controls.*
  - $\rho\in\{0.95,1.00\}$.
  - Long-difference regressors: $(1,s_t)$ as published, $(1,s_t,y_{t-1})$, or $(s_t)$ with no intercept.
  - Reference overlay: the authors' stored $R=10{,}000$ means (`IntcpY` files for the published curves, `IntcpN` for the no-intercept long difference), off by default and labeled "stored result, different draws".
- All three regressor sets come from the same 500 draws (`l02_jt_mc_regressors.csv`, `l02_jt_mc_ovb_{95,100}.csv`), so changing the regressors never changes the data. The harness's no-intercept means equal the authors' unmodified `IntcpN` workers rerun at $R=500$ to $9.7\times10^{-8}$.
- *Output.* Means by horizon with $\pm2$ MC s.e. whiskers labeled "simulation error", truth, and the D9 formula line at $\rho=1$.
- *Reactive sentence.* "On the same 500 draws at $\rho=1.00$ and $h=10$, the published long difference averages 0.903 against 0.635 for levels. With $y_{t-1}$ added the two curves coincide exactly, and with no intercept the long difference averages 1.015 (MC s.e. 0.022)."
- *Handoff.* A specification table (dependent variable, regressors, intercept, rows, $R$) that becomes the REP02 specification table.

## 8. Practicum plan

### 8.1 REP02: complete the levels/long-differences comparison

**Target.** Jordà and Taylor (2025), *Journal of Economic Literature* 63(1), 59–110, Figure 1a ($\rho=0.95$) and 1b ($\rho=1.00$): mean levels and long-difference LP responses, $h=0,\dots,10$, with intercept and no lagged difference. Reading sections are named from the frozen version, with the page range to confirm (D31).

**Code and data.** JEL-Code commit `655696c1c576b7537c5a939d2c261f0a111ae663` (supplied ZIP byte-identical), `LP_JEL_Replication/Example1_LongDifferences/`. The example is a simulation, so there are no data. Driver: `all-simulate.do` (globals `nobs 100`, `nreps 10000`). The workers `SSBias_IntcpYLagdiffN_95.do` and `_100.do` differ only at line 27 ($\rho$) and in whitespace on line 108. Worker line map:

| Lines | Content |
|---|---|
| 39–65 | seed and DGP |
| 67–80 | AR(1) |
| 84–89 | levels LP, regression at line 87 |
| 93–95 and 105–110 | long difference, regression at line 108 with `vy` only |
| 98–100 and 114–121 | cumulative difference |
| 133–148 | means |
| 156–168 | truth |
| 192–210 | figure |

`all-figures.do` lines 16–66 plot the panels.

**Replication kind.**

- *Instructor build ($R=500$).* An exact numerical reproduction of the course benchmark (D1, D2).
- *Student run ($R=200$).* Compared with a course-built reference from the unmodified scripts.
- Both are *statistical reproductions* of the published $R=10{,}000$ means, never replications of them.

**Benchmark** (`benchmarks/REP02-levels-long-differences.csv`, Stata 18.5, $R=500$; authors' stored means from the frozen `.dta`, $R=10{,}000$).

| $\rho$ | $h$ | Truth | Levels, $R=500$ | Long diff., $R=500$ | Cum. diff., $R=500$ | Levels, $R=10^4$ | Long diff., $R=10^4$ | $T_h$ |
|---|---|---|---|---|---|---|---|---|
| 0.95 | 0 | 1 | 1.0017575 | 1.0144148 | 1.0144148 | 0.99697095 | 1.0080452 | 99 |
| 0.95 | 5 | 0.77378094 | 0.67800373 | 0.79243773 | 0.79118729 | 0.66630644 | 0.77311319 | 94 |
| 0.95 | 10 | 0.59873694 | 0.43152007 | 0.59982502 | 0.60136211 | 0.42890212 | 0.59231287 | 89 |
| 1.00 | 0 | 1 | 0.99425775 | 1.0054513 | 1.0054513 | 0.98941326 | 0.99979359 | 99 |
| 1.00 | 5 | 1 | 0.8117491 | 0.96866316 | 0.9679389 | 0.79704797 | 0.94890392 | 94 |
| 1.00 | 10 | 1 | 0.63473517 | 0.90317798 | 0.91020358 | 0.62957841 | 0.89624506 | 89 |

**Tolerance and D1 rerun.** The tolerance is $10^{-6}$ absolute per cell against the CSV. The unmodified workers were rerun in StataNow 19.5 at $R=500$ and exported at `%21.0g` (`brief-checks/rep02-500/`). All 88 cells (4 series × 11 $h$ × 2 $\rho$) agree to $2.16\times10^{-8}$, the CSV's 8-digit precision, so no software row is logged. The course harness (a separate implementation, same draw order) agrees on 66 cells to $6.1\times10^{-8}$.

**Runtime.**

- $R=500$: 47.2 s ($\rho=0.95$) and 50.7 s ($\rho=1$).
- Course harness (all regressor sets and the D10 terms): 95 s per $\rho$ at $R=500$.
- $R=200$: 21.2 s and 21.5 s. Reference means are in `jt-ex1/reduced_IntcpYLagdiffN_{95,100}.dta`, e.g. $\rho=1$, $h=10$: levels 0.65647000, long difference 0.90201819.
- $R=10{,}000$ at the measured rate would take about 17 minutes per worker, beyond D2's ceiling, so the stored means are quoted, not rerun.

**Departures.**

1. The driver sets `nreps` instead of editing the workers.
2. PDFs are renamed by the scripts' own rule and course figures are rebuilt from CSVs.
3. The course harness adds what the authors do not keep: per-draw storage, the long difference with $y_{t-1}$, the no-intercept long difference on the same draws, $\hat\gamma_h$ and $\hat\beta^{\mathrm{lag}}_h$ for D10, and MC s.e. The authors keep only means (MANIFEST: SEs unavailable).

**Redistribution (D5).** CC0: the workers, driver and stored `.dta` ship in `lab-project/rep02/original/`. There is no data.

**Output.** The paired comparison figure, the specification table from Lab 5, and a three-sentence statement: the comparison changes the regressor set as well as the dependent variable; with $y_{t-1}$ added the curves coincide; at $\rho=1$ the remaining gap is the intercept's $O(h/T_h)$ effect.

### 8.2 STA02: independent Stata tasks

The tasks run construct → estimate → diagnose → interpret. `master.do` calls these files:

| File | Content |
|---|---|
| `code/00_setup.do` | version 19.5, paths, `global R 200` |
| `code/01_transformations.do` | task 1 |
| `code/02_equivalence.do` | tasks 2 and 3 |
| `code/03_rescale.do` | task 4 |
| `code/04_rz_cumulative.do` | tasks 1, 4 and 5 on data |
| `code/05_figures.do` | task 5 |
| `code/06_rep02.do` | REP02: sets `global nobs 100` and `global nreps $R`, then runs the two unmodified `SSBias_IntcpYLagdiffN` workers from `rep02/original/` as `all-simulate.do` lines 27–28 and 40–41 do, not the full eight-worker driver (about 43 s at $R=200$, 98 s at $R=500$); exports the 88 cells at `%21.0g` and asserts them at $10^{-6}$ against `expected/rep02_R200.csv` (student; from `jt-ex1/reduced_IntcpYLagdiffN_{95,100}.dta`) or `benchmarks/REP02-levels-long-differences.csv` (instructor, $R=500$); writes the paired comparison figure and merges the Lab 5 specification table into the REP02 specification table |

Supporting folders hold the REP02 originals (`rep02/original/`), the data (`data/sim/seed2_innovations_300.csv`, Lecture 1's seed-2 stream with its burn-in, anchor B; `data/raw/get_data.do` with the RZ author URLs from `packages/ramey-zubairy/SOURCE.md` and SHA-256 from `pilots/REP04/input-checksums.csv`, per D5), the reference results (`expected/` CSVs) and `outputs/`. Variable names follow the ledger: `y s v t h beta_h B_h`.

1. **Four transformations.** Rebuild $y$ at $\rho=0.9$ from the CSV. Store `beta_lev beta_ld beta_d beta_cum` for $h=0..12$ on $\mathcal T_h$ and on `cs` ($\mathcal T_{12}$). Expected on `cs`: $h=6$ level 0.3706 and accumulated level 4.1183; $h=12$: −0.2933 and 4.1493; $T=187$.
2. **Equivalence assertion.** `assert reldif(beta_lev, beta_ld) < 1e-8` at every $h$. Also assert that the coefficient on `L.y` differs by $1\pm10^{-8}$.
3. **Break it.** Rerun exercise 5's three breaks. Assert that each gap exceeds $10^{-3}$ and write one sentence naming the violated condition.
4. **Rescale.** Regress on `10*s` and on `s/r(sd)`, and assert the D5 identities. On RZ data, `news_pct = 100*newsy`, $h=10$: 0.00293764.
5. **Labels.** Each `ytitle` states units, normalization, accumulation and rows, e.g. "Percent of trend GDP per news worth 1% of trend GDP; level response; rows $T_h$". RZ expected values as in exercise 7; float assertions at $10^{-6}$.

### 8.3 Handoff and submission

- **Handoff.** Labs export JSON and CSV to `data/html/`; `master.do` echoes the Lab 2 specification record, and task 4 checks the Lab 4 prediction.
- **Submission (blueprint §4.2).** Replication record (target, commit, runtime, and the 88-cell comparison written by `code/06_rep02.do`); Stata submission (master do-file, log, `expected/` comparisons, figures); interpretation record (units and accumulation for every axis); HTML lab record (predictions and settings).

## 9. Slides arc

| # | Title | Governing idea |
|---|---|---|
| 1 | Levels, differences, cumulative responses, and units | Title |
| 2 | Four numbers, one dataset | 0.29, 1.76, 3.53 and 0.73 all describe the same RZ response |
| 3 | Four dependent variables | Each asks a different question and carries different units |
| 4 | Subtract a regressor | $\hat{\mathbf b}-\mathbf e_k$: only one coefficient moves, by exactly one |
| 5 | The hand table agrees to eight decimals | −1.05040519 twice; the residuals match |
| 6 | Telescoping needs the same rows | 2.6226 on horizon-specific rows, 2.1530 on $\mathcal T_2$ |
| 7 | Accumulated change versus accumulated level | Summed changes return the level response; summed levels return $B_h$ |
| 8 | Percent, points, log points | The approximation fails at large changes |
| 9 | Rescaling the shock | $\beta_h/\Xi_s$: a different number for the same intervention |
| 10 | What Figure 1 actually compares | Two ingredients change; adding $y_{t-1}$ back closes the gap |
| 11 | The intercept at $\rho=1$ | $-[h-h(h+1)/2T_h]/(T_h-1)$ matches the stored means |
| 12 | Reading the fiscal axes | Trend normalization makes the ratio dimensionless; rows matter (0.7263 versus 0.7295) |
| 13 | Workbench and practicum | Five labs, REP02 at $R=500$, STA02 |
| 14 | Handed to Lecture 3 | No transformation establishes the counterfactual |

## 10. Open questions for the editor

1. **Local superscripts.** The ledger says superscripts on $\beta$ name the outcome. This brief writes $\beta^{\mathrm{LD}}_h$, $\beta^{\Delta}_h$, $\beta^{\Sigma}_h$ for transformations of one outcome, and $\hat\beta^{\mathrm{lag}}_h$ for $y_{t-1}$ regressed on $s_t$ (D10). Confirm, or name another convention, and record it in the ledger.
2. **Spine opener.** The spine's illustrative "0.8 versus 3.1" is replaced by computed RZ numbers. Approve the spine edit.
3. **Glossary keys.** Should "accumulated change" and "accumulated level" become keys? D22 requires the terminology plan to change first.
4. **Exercise 9 runtime.** The course harness at $R=200$ is estimated, not timed, at about 3 minutes. Confirm the [extra] tag, or time it during the build. The extended harness (D10) took 95 s per $\rho$ at $R=500$.
5. **Hand-table shock (recorded choice).** Anchor A reuses Lecture 1's binary-shock table exactly, pending Lecture 1 §10 Q1. If the editor rules there that the hand table needs a Gaussian shock, Lecture 1 changes first, and every hand-table number here (§1 anchor A and step 3, §5 exercises 2, 3 and 6, §6 D1–D5, Lab 2, slides 5–6, `fig-l02-equivalence-fits`) is recomputed with `anchor/l02-derivations-l01table.do`.
6. **Rescaling constant.** $\kappa_s$ is now $\Xi_s$, because D20 gives $\kappa$ to Lecture 7. The reviewers' alternatives collide with Lecture 3, which keeps $\chi$ for $\chi^2$ and uses $\varsigma_t$ for proxy noise. Confirm $\Xi_s$, or record another letter in the ledger.
