# Lecture 01 brief — From an economic question to a local projection

Planning brief for `lectures/01-question-to-projection/` (notes, exercises,
glossary, slides, figures), `interactives/01-shock-to-response-explorer.qmd`
("Shock-to-Response Explorer"), and `practica/p01-question-to-projection/`.
Written against the course spine (Lecture 1 entry and the Lecture 2 seam), the
notation ledger, the terminology plan, the editor decisions, the blueprint
(Sections 1, 4, 5, and Lecture 1), and the authoring guide. The Lecture 6 brief already reuses this lecture's AR(1) economy with
$\sigma_s$ and $\sigma_v$, so the notation here is written to meet it.

Verification status. Every number comes from a StataNow/SE 19.5 run (D1), a
benchmark CSV, or a derivation in Section 6. Runs are in
`/private/tmp/claude-501/-Users-tylersotomayor-macro-local-projections/c072337f-0f2c-4cf4-bb71-22a0631666a1/scratchpad/design-01/`
(`design-01/` below); every log was checked for `^r\([0-9]+\);` and none has
an error line. Scripts are named beside their numbers. No MATLAB was run.

---

## 1. Session brief

**Opening situation.**
June 1950. North Korea invades the South, and over the summer
newspapers report plans for large increases in U.S. military spending. In
Ramey's news series the present value of expected military spending announced
in 1950Q3 is 179.4 billion nominal dollars, 0.600 of the previous quarter's
nominal trend GDP at an annual rate. A policymaker asks what will happen to
output over the next three years. The realized path is easy to read: real GDP
was 2.75 percent below trend in 1950Q2 and 5.12 percent above it in 1953Q1, a
rise of 7.87 points of trend GDP in ten quarters. But taxes rose, the Treasury–Federal Reserve Accord freed monetary policy, and
wage and price controls came and went during those same quarters. The realized path is one
draw with everything mixed in. The question is not "what happened next" but
"what happened *because of* the news", and that requires a path we never
observe.

**Decision or empirical question.**
How does a regression coefficient become one point on an impulse-response
function, and what exactly does that coefficient measure? The lecture's
answer: the causal response at horizon $h$ is the gap between the realized and
the no-intervention paths; in the smallest model where that gap is known, the
coefficient on $s_t$ in a regression of $y_{t+h}$ on $s_t$ and $y_{t-1}$
equals it; and the estimate averages over every date with variation in $s_t$,
never over one episode.

**Target student and prerequisites.**
An advanced undergraduate, master's student, or beginning research assistant
who knows OLS (slope as covariance over variance, the slope on a binary
regressor as a difference in means), expectation and independence, and
elementary Stata. The blueprint's unnumbered readiness exercise (§1.2) covers
`tsset`, leads and lags with missing values, loops, `regress`, and stored
results. No time-series course is assumed: the AR(1) is introduced from
scratch and iterated by hand. Not assumed: HAC standard errors, instruments,
VARs.

**Learning outcomes (five).**

1. Define the causal response $\theta_h$ as the difference between the realized
   path and the no-intervention counterfactual path at horizon $h$, and
   distinguish it from the realized path's change since the pre-intervention
   date.
2. Iterate $y_t=\rho y_{t-1}+\theta_0 s_t+v_t$ forward to derive
   $\theta_h=\theta_0\rho^h$, and show that the horizon-$h$ regression of
   $y_{t+h}$ on $(1,s_t,y_{t-1})$ has $\beta_h=\theta_h$,
   $\gamma_h=\rho^{h+1}$, and a residual $u_{t,h}$ built from disturbances
   dated $t,\dots,t+h$ and shocks dated $t+1,\dots,t+h$.
3. Build the estimation rows for $h=0,1,2$ by hand, state
   $T_h=T-h-p$, and compute $\hat\beta_h$ from those rows.
4. In Stata, estimate $\hat\beta_h$ for $h=0,\dots,H$ in a loop that stores
   $\hat\beta_h$ and $T_h$, and draw a response graph whose caption names the
   intervention, the units, and the counterfactual.
5. Explain what one estimated coefficient measures and where its variation
   comes from (every date with $s_t\neq\bar s$, weighted by
   $(s_t-\bar s)^2$), why one episode cannot identify it, and which claims a
   first data application has not yet earned (the mastery requirement).

**Anchor examples.**

*A. The twelve-period hand economy (seed 1).* $y_t=0.5\,y_{t-1}+s_t+v_t$,
$t=1,\dots,12$, $y_0=0$, so $\rho=0.5$, $\theta_0=1$. Design in Stata order:
`set seed 1`; `gen v = round(rnormal(),0.1)` for all twelve periods, then
`gen s = rbinomial(1,0.3)`. Shock dates are $t=1,5,10,12$. The regression rows
are $t\ge2$ so that $y_{t-1}$ exists in every row (with and without the
control, the rows are the same). Values (exact decimals; the notes display four
decimals and compute with the exact values):

| $t$ | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $s_t$ | 1 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| $v_t$ | 0.9 | 0.5 | 0.6 | $-0.6$ | $-1.7$ | 0.2 | 2.1 | $-1.3$ | 0.8 | 0.6 | $-0.9$ | 1.5 |
| $y_t$ | 1.9 | 1.45 | 1.325 | 0.0625 | $-0.66875$ | $-0.134375$ | 2.0328125 | $-0.28359375$ | 0.658203125 | 1.9291015625 | 0.06455078125 | 2.532275390625 |

Results ($\theta_h=1,0.5,0.25$):

| $h$ | $T_h$ | treated rows | $\bar y_{t+h}\mid s_t=1$ | $\bar y_{t+h}\mid s_t=0$ | $\hat\beta_h$ (no control) | $\hat\beta_h$ (with $y_{t-1}$) |
|---|---|---|---|---|---|---|
| 0 | 11 | 5, 10, 12 | 1.264209 | 0.646887 | 0.617322 | 0.575667 |
| 1 | 10 | 5, 10 | $-0.034912$ | 0.948444 | $-0.983356$ | $-1.050405$ |
| 2 | 9 | 5, 10 | 2.282544 | 0.232520 | 2.050024 | 2.153022 |

Counterfactual: set $s_5=0$ and hold every $v_t$ fixed. The realized minus
counterfactual gap at $t=5,6,7,8$ is exactly $1,\ 0.5,\ 0.25,\ 0.125$. The
change from the pre-shock value $y_4$ is $-0.73125,\ -0.196875,\ 1.9703125,\
-0.34609375$. With only the $t=5$ shock kept, the OLS slope equals
$y_{5+h}$ minus the mean of the other rows: $-1.632397$, $-0.984608$,
$1.512823$. Source: `brief/l01-brief-checks.do`, output
`hand_table_final.csv`.

*B. One draw (seed 2).* The same model with $s_t,v_t\sim\mathcal N(0,1)$
i.i.d., $\theta_0=1$, $\rho\in\{0.5,0.9\}$, 300 periods with the first 100
discarded, $T=200$. Stata order: `set seed 2`; `gen s = rnormal()`, then
`gen v = rnormal()` (all 300 periods). LP with $y_{t-1}$, $h=0,\dots,12$,
$T_h=199-h$. At $\rho=0.9$: $\hat\beta_0=0.878940$, $\hat\beta_4=0.548477$,
$\hat\beta_8=0.240595$, $\hat\beta_{12}=-0.293297$ against
$\theta_h=1,\ 0.6561,\ 0.4305,\ 0.2824$. Shipped as
`onedraw_rho05_seed2.csv` and `onedraw_rho09_seed2.csv` (columns $t,s,v,y$) so
that the browser and Stata use identical observations (blueprint §5.4).

*C. The toy Monte Carlo (seed 3).* Design B, `set seed 3` once before the
replication loop for each $\rho$, draws $s$ then $v$ in every replication,
$h=0,\dots,12$. Instructor build $R=500$, student default $R=200$ (D2); both
are the first $R$ replications of one stream. At $R=500$ the mean of
$\hat\beta_h$ is within 0.013 of $\theta_h$ at every horizon for $\rho=0.5$.
For $\rho=0.9$ it falls short by 0.026 at $h=4$, by 0.033 at $h=8$ and by
0.049 at $h=12$ (Monte Carlo standard error about 0.010). Lecture 2 names this
gap. Source: `brief/mc_toy_R500_summary.csv`, `mc_toy_R200_summary.csv`,
subsets of `l01-sim/mc_v2_results.dta`.

*D. First contact with data.* Ramey–Zubairy (2018) `RZDAT.xlsx`, sheet
`rzdat` (February 2018 package; data comment April 7, 2016), frozen at
`replication-packages/pilots/REP04/source/rzdat.xlsx` (SHA-256
`b2d85087…6c8c6120`); quarterly 1889Q1–2015Q4, 508 quarters. Outcome
$y_t=$ `rgdp/rgdp_pott6`: real GDP (billions of chained 2009 dollars, annual
rate; 16,470.6 in 2015Q4) over the authors' potential-GDP series, mean 0.987.
Intervention $s_t=$ `newsy` $=$ `news`$_t/($`rgdp_pott6`$_{t-1}$`pgdp`$_{t-1})$:
present value of expected military spending changes as a fraction of lagged
nominal trend GDP at an annual rate; nonmissing 1890Q1–2015Q4 (504 quarters),
nonzero in 108, mean 0.007222, sd 0.059728, largest 0.691893 (1941Q4) and
0.600073 (1950Q3). Toy specification: OLS of $y_{t+h}$ on $(1,s_t,y_{t-1})$,
$h=0,\dots,20$, $T_h=504-h$: $\hat\beta_0=0.080313$, $\hat\beta_4=0.259141$,
$\hat\beta_8=0.361906$, peak $\hat\beta_{10}=0.404210$, $\hat\beta_{20}=0.0796$.
In words: news worth 1 percent of trend GDP is followed ten quarters later by
GDP about 0.40 percent of trend GDP above what the regression otherwise
predicts. With the Ramey–Zubairy controls (four lags each of `newsy`, $y$,
$g$; $T_h=500-h$) the coefficients are 0.0510 ($h=0$) and 0.2938 ($h=10$),
the REP04 benchmark's `irf_gdp_linear`. Sources: `rz/first-contact.do`,
`brief/l01-brief-checks.do`.

**Smallest useful model (ledger notation).**

$$
y_t=\rho\,y_{t-1}+\theta_0 s_t+v_t,\qquad s_t\overset{\text{iid}}{\sim}(0,\sigma_s^2),\quad v_t\overset{\text{iid}}{\sim}(0,\sigma_v^2),\quad \{s_t\}\perp\{v_t\}.
$$

Substituting forward $h+1$ times gives the local projection with
$\mathbf w_t=y_{t-1}$ and $p=1$:

$$
y_{t+h}=\mu_h+\beta_h s_t+\gamma_h y_{t-1}+u_{t,h},\qquad
\beta_h=\theta_h=\theta_0\rho^h,\quad \gamma_h=\rho^{h+1},\quad \mu_h=0,
$$

$$
u_{t,h}=\sum_{j=0}^{h}\rho^{h-j}v_{t+j}+\theta_0\sum_{j=1}^{h}\rho^{h-j}s_{t+j}.
$$

The blueprint's $\alpha_h$ is written $\mu_h$ (ledger §1). In this model
$s_t$ is an *observed shock* by construction. For the Ramey–Zubairy news it is
called the intervention variable until Lecture 3 argues identification.

**Dependency chain.**

1. `#sec-l01-question` *The question: an intervention, an outcome, and a path we never see.* The causal response is the gap between the realized path and the no-intervention path at the same date, not the change since the pre-intervention date, and the hand economy shows the two differ (1 versus $-0.731$ at $t=5$).
2. `#sec-l01-two-clocks` *Two clocks.* Calendar time $t$ dates the intervention and the regression row; horizon $h$ counts periods after it; an impulse-response function is a function of $h$ and one coefficient is one point on it.
3. `#sec-l01-smallest-model` *The smallest model.* In the AR(1) with an observed exogenous shock the counterfactual gap is computable exactly, and iterating forward gives $\theta_h=\theta_0\rho^h$, so persistence $\rho$ sets the response's shape.
4. `#sec-l01-model-to-regression` *From the model to a regression.* The forward substitution is a regression equation whose error is uncorrelated with $s_t$ and $y_{t-1}$, so the population projection coefficient $\beta_h$ equals $\theta_h$; including $y_{t-1}$ does not change the estimand here but sharply reduces sampling noise.
5. `#sec-l01-many-shock-dates` *Why many shock dates.* The OLS slope weights every row by $s_t-\bar s$; with one episode it collapses to "that episode's outcome minus the others' average", which cannot separate the shock from whatever else happened then.
6. `#sec-l01-rows-by-hand` *Building the rows by hand.* The twelve-period table with $h=0,1,2$ makes leads, lost rows ($T_h=11,10,9$), and the difference-of-means arithmetic visible before any loop, and shows twelve periods are far too few.
7. `#sec-l01-response-graph` *Reading the response graph.* A response graph plots $\hat\beta_h$ against $h$; its reader needs the units of $s$ and of $y$, the horizon unit, what the intercept is not, and a caption naming intervention, units, and counterfactual.
8. `#sec-l01-residual` *What the residual contains.* $u_{t,h}$ sums disturbances between $t$ and $t+h$, so adjacent rows share terms and the residual is serially correlated to lag $h$ by construction; this is recorded here; Lecture 5 shows that inference depends on the autocorrelation of $s_tu_{t,h}$, which in this economy is zero because $s_t$ is unpredictable.
9. `#sec-l01-first-contact` *First contact with data.* The toy specification on military news and GDP relative to trend produces a hump-shaped response peaking at $h=10$. Two quarters (1941Q4 and 1950Q3) supply 45.7 percent of the variation in $s_t$, and the units, controls, and identification it silently assumes are listed rather than defended.
10. `#sec-l01-handoff` *Handoff.* The regressions used the level of $y_{t+h}$; the next lecture asks whether a differenced outcome gives a different answer or the same answer in different clothes.

Also `#sec-l01-glossary` and `#sec-l01-exercises`.

**Central notation.** $t$, $T$, $h$, $H$, $y_t$, $s_t$, $\mathbf w_t$ (here
$y_{t-1}$), $p$, $\beta_h$, $\hat\beta_h$, $\theta_h$, $\theta_0$, $\mu_h$,
$\gamma_h$, $u_{t,h}$, $\mathcal T_h$, $T_h$, $\rho$, $R$; new to this lecture
and not yet in the ledger: $v_t$ (outcome disturbance) and $\sigma_v$. The
lecture also uses $\sigma_s$ before Lecture 2's units section (see Section 10).

**Glossary terms (the twenty keys owned by Lecture 1; drafts, full sentences in Section 3).**
`counterfactual` (the path without the intervention); `realized-path` (what
was observed, everything mixed in); `causal-response` (realized minus
counterfactual, $\theta_h$); `intervention-variable` ($s_t$, neutral about
identification); `observed-shock` (measured, unpredictable, independent of
other disturbances); `calendar-time` (the row date $t$); `horizon` ($h$
periods after $t$); `impact-response` ($h=0$); `impulse-response-function`
(responses as a function of $h$); `response-graph` ($\hat\beta_h$ against $h$
with units and caption); `estimand` (the population target);
`population-projection` (best linear predictor, orthogonal error);
`projection-coefficient` (its coefficient, causal only under assumptions);
`local-projection` (one projection per horizon); `lead`, `lag` ($y_{t\pm k}$,
missing at the ends); `regression-row` (one dated observation);
`estimation-sample` ($\mathcal T_h$, shrinking with $h$);
`autoregressive-process` (own past plus disturbances); `persistence` (the
decay factor $\rho$).

**Likely footnotes.** (1) $y_0=0$ and the burn-in; (2) Stata `F.`/`L.`
return missing past the sample ends; (3) why "local" (Jordà 2005, §2); (4) the
Ramey news series and its scaling, pointing to Lectures 2 and 4; (5) the slope
on a 0–1 regressor is a difference in means; (6) with $y_{t-1}$ included the
exact weights use $s_t$ purged of $y_{t-1}$ (Lecture 3).

**Candidate figures.**

| Label | Question | Lesson visible | Generating data or formula |
|---|---|---|---|
| `fig-l01-realized-counterfactual` | What is the response? | The response is the vertical gap between two paths (1, 0.5, 0.25, …), not the rise from $y_4$ ($-0.731$, $-0.197$, 1.970) | `hand_table_final.csv`: $y_t$, $y^{c}_t$ for $t=1..12$; bracket at $t=5,6,7$ |
| `fig-l01-row-staircase` | Which rows enter the $h=2$ regression? | Row $t$ pairs $s_t, y_{t-1}$ with $y_{t+2}$; rows 11–12 have no lead; $T_h=11,10,9$ | Hand-table indices; three stacked panels $h=0,1,2$ |
| `fig-l01-persistence` | How does persistence shape the response? | Same impact, decay by $\rho$ per period; at $h=7$, 0.0078 versus 0.478 | $\theta_h=\rho^h$, $\rho\in\{0.5,0.9\}$, $h=0..12$ |
| `fig-l01-one-draw` | How noisy is one draw? | One $T=200$ path wanders far from $\theta_h$ and its errors move together across $h$; the 5–95 percent band is wide | `onedraw_rho09_seed2`; stored band from `mc_toy_R500_summary.csv` |
| `fig-l01-first-contact` | What does a first LP of GDP on military news look like? | Hump peaking at $h=10$ (0.404); no bands yet. The caption states that the RZ controls lower the $h=10$ coefficient to 0.294 | `rz/first_contact.dta`, $h=0..20$ |
| `fig-l01-sample-by-horizon` | What does $h$ cost? | $T_h=T-h-p$ | **Droppable (D24):** the sentence and the staircase answer it |
| `fig-l01-news-variation` | Which dates supply the variation? | Four quarters carry 64.5 percent of $\sum(s_t-\bar s)^2$ | **Droppable (D24):** a six-row table answers it |

**Exercise capabilities.**
- Compute a counterfactual path and a causal response by hand.
- Derive $\theta_h$ and the LP coefficients by forward substitution.
- List the rows of a horizon-$h$ regression and compute its slope.
- Reproduce these in Stata with assertions.
- Loop across horizons, storing $\hat\beta_h$ and $T_h$.
- Write a complete caption.
- Run a small Monte Carlo and read mean against truth.
- Write the residual and its autocorrelation.
- Acquire real data, reproduce the first-contact response, and write the "not yet argued" paragraph.

**Controlled experiments.**
- Switch the $t=5$ shock off with every $v_t$ fixed.
- Move $h$ with the data fixed and watch rows leave the sample.
- Change $\rho$ with $\theta_0$ fixed.
- Add or remove $y_{t-1}$ on the same rows and draw.
- Shorten $T$ on the same draw.
- Drop one episode (1950Q3 or 1941Q4) with the specification fixed. At $h=8$: 0.3619 full sample, 0.4340 without 1950Q3, 0.3443 without 1941Q4, 0.0587 from 1947Q1 on.

**Postponed.**
- Lecture 2: levels versus differences, cumulative responses, units and normalization, common samples, small-sample bias (including the $\rho=0.9$ gap in design C and the rest of Jordà–Taylor Example 1).
- Lecture 3: identification, controls, and the pre-shock information set.
- Lecture 4: IV and multipliers.
- Lecture 5: standard errors and HAC.
- Lecture 6: bands and joint claims across horizons.
- Lecture 7: VAR comparison.
- Lecture 13: influential episodes and leave-one-out.

**Question handed on.** If we regress $y_{t+h}-y_{t-1}$ instead of $y_{t+h}$,
is the answer different, or the same answer in different clothes?

---

## 2. Concept and notation ledger

Every symbol follows the notation ledger. Three symbols are new ($v_t$,
$\sigma_v$, $y^{c}_t$). $\sigma_s$ is used early, with its meaning from ledger
§2. Timing is relative to the regression row $t$.

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $t$ | Calendar date of an observation and of a regression row | scalar index | row date $=$ intervention date | periods (quarters in RZ) | §question | every lecture |
| $T$ | Length of the series | scalar | — | periods | §rows-by-hand ($T=12$) | L2, L5 |
| $h$ | Horizon, periods after $t$ | scalar, $0..H$ | outcome dated $t+h$ | periods | §two-clocks | every lecture |
| $H$ | Largest horizon estimated | scalar | — | periods | §two-clocks ($H=2,12,20$) | L6 $\mathcal H$ |
| $y_t$ | Outcome | scalar series | $t$ | toy: unitless; RZ: real GDP / trend GDP | §question | L2 transformations |
| $s_t$ | Intervention variable | scalar series | $t$, the impact period | toy: one unit; RZ: fraction of lagged nominal trend GDP | §question | L3 identification, L4 instrument |
| $v_t$ | Outcome disturbance, independent of $\{s_t\}$ | scalar series | $t$ | units of $y$ | §smallest-model | L6, L7 toy economies (**new**) |
| $\sigma_s,\ \sigma_v$ | Standard deviations of $s_t$, $v_t$ | scalars | — | units of $s$, of $y$ | §residual | L2 normalization; L6 (**$\sigma_v$ new**) |
| $\rho$ | AR(1) persistence | scalar, $\lvert\rho\rvert<1$ here | — | unitless | §smallest-model | L2 ($\rho\to1$), L5 |
| $\theta_0$ | Impact response of $s_t$ on $y_t$ | scalar | $h=0$ | units of $y$ per unit of $s$ | §smallest-model | L6, L7 |
| $\theta_h$ | Causal response: realized minus counterfactual at $t+h$ | scalar per $h$ | $t+h$ | units of $y$ per unit of $s$ | §question (words), §smallest-model (formula) | L3 conditions for $\beta_h=\theta_h$; L10 $\theta_h(e)$ |
| $y^{c}_t$ | Counterfactual path with one intervention removed | scalar series | dates of $y_t$ | units of $y$ | §question | L13 $y^{c}_{t+h}$ (**new here**) |
| $\beta_h$ | Population projection coefficient on $s_t$ | scalar per $h$ | row $t$, outcome $t+h$ | units of $y$ per unit of $s$ | §model-to-regression | all |
| $\hat\beta_h$ | OLS estimate of $\beta_h$ | scalar per $h$ | — | same | §rows-by-hand | all |
| $\mu_h$ | Intercept (blueprint $\alpha_h$) | scalar | — | units of $y$ | §model-to-regression | all; never interpreted |
| $\gamma_h$ | Coefficient on $y_{t-1}$, $=\rho^{h+1}$ in the toy | scalar here | — | unitless in toy | §model-to-regression | L3 $\boldsymbol\gamma_h$ |
| $\mathbf w_t$ | Controls; here only $y_{t-1}$ | $1\times1$ here | dated $t-1$ or earlier | units of each control | §model-to-regression | L3 |
| $p$ | Lags in $\mathbf w_t$ | scalar (toy 1; RZ controls 4) | — | lags | §rows-by-hand | L3, L5 |
| $u_{t,h}$ | Horizon-$h$ residual in row $t$ | scalar per $(t,h)$ | contains $v_t..v_{t+h}$ and $s_{t+1}..s_{t+h}$ | units of $y$ | §model-to-regression; §residual | L5 HAC, L6 covariance |
| $\mathcal T_h,\ T_h$ | Horizon-$h$ estimation sample and its size | set, scalar | — | rows | §rows-by-hand (11, 10, 9) | L2 common sample |
| $\bar s,\ \bar y$ | Means over $\mathcal T_h$ | scalars | — | units of $s$, $y$ | §many-shock-dates | all |
| $R$ | Monte Carlo replications (D20) | scalar | — | count | §rows-by-hand, `fig-l01-one-draw` | L2, L5–L8 |

Conditioning, stated once in §model-to-regression:
$\mathbb E[s_tu_{t,h}]=\mathbb E[y_{t-1}u_{t,h}]=0$ because $u_{t,h}$ holds only
disturbances dated $t$ or later and shocks dated $t+1$ or later; $\Omega_{t-1}$
waits for Lecture 3. Stata names follow ledger §9 (`t s y h beta_h T_h`, plus
`v` and `y_c`).

---

## 3. Terminology ledger

Glossary keys are exactly the twenty owned by Lecture 1. No key owned elsewhere
is marked. Terms owned by later lectures stay as prose with a link to that
lecture's glossary.

| Phrase | Treatment | Key | One-sentence definition or note | First marked section |
|---|---|---|---|---|
| counterfactual | glossary | `counterfactual` | The outcome path that would have occurred without the intervention, all else as it was. | `#sec-l01-question` |
| realized path | glossary | `realized-path` | The outcome sequence actually observed, mixing the intervention with every other disturbance. | `#sec-l01-question` |
| causal response | glossary | `causal-response` | Realized minus counterfactual outcome at horizon $h$, the object $\theta_h$. | `#sec-l01-question` |
| intervention variable | glossary | `intervention-variable` | The variable $s_t$ whose effect is wanted, named neutrally about identification. | `#sec-l01-question` |
| calendar time | glossary | `calendar-time` | The date $t$ of an observation and its regression row. | `#sec-l01-two-clocks` |
| horizon | glossary | `horizon` | Periods $h$ after the intervention at which the outcome is measured. | `#sec-l01-two-clocks` |
| impact response | glossary | `impact-response` | The response at $h=0$. | `#sec-l01-two-clocks` |
| impulse-response function | glossary | `impulse-response-function` | Responses read as a function of horizon. | `#sec-l01-two-clocks` |
| autoregressive process | glossary | `autoregressive-process` | A series equal to a linear function of its own past plus new disturbances. | `#sec-l01-smallest-model` |
| persistence | glossary | `persistence` | How slowly a series returns after a disturbance; here the decay factor $\rho$. | `#sec-l01-smallest-model` |
| observed shock | glossary | `observed-shock` | A measured intervention variable unpredictable from the past and independent of other disturbances. | `#sec-l01-smallest-model` |
| estimand | glossary | `estimand` | The population quantity an estimator targets, fixed before data are used. | `#sec-l01-model-to-regression` |
| population projection | glossary | `population-projection` | The best linear predictor in the population, defined by an orthogonal error. | `#sec-l01-model-to-regression` |
| projection coefficient | glossary | `projection-coefficient` | A coefficient of a population projection; causal only under assumptions. | `#sec-l01-model-to-regression` |
| local projection | glossary | `local-projection` | A separate projection of $y_{t+h}$ on the intervention and controls at each horizon. | `#sec-l01-model-to-regression` |
| lead | glossary | `lead` | The value $k$ periods later; missing for the last $k$ rows. | `#sec-l01-rows-by-hand` |
| lag | glossary | `lag` | The value $k$ periods earlier; missing for the first $k$ rows. | `#sec-l01-rows-by-hand` |
| regression row | glossary | `regression-row` | One dated observation of a horizon-$h$ regression. | `#sec-l01-rows-by-hand` |
| estimation sample | glossary | `estimation-sample` | Rows with every variable nonmissing at horizon $h$; size $T_h$. | `#sec-l01-rows-by-hand` |
| response graph | glossary | `response-graph` | A plot of $\hat\beta_h$ against $h$, with units and a caption naming intervention, units, counterfactual. | `#sec-l01-response-graph` |
| burn-in | footnote | — | Early simulated periods discarded so that $y_0$ does not matter. | `#sec-l01-smallest-model` |
| `F.` and `L.` operators | footnote | — | Stata time-series operators; missing past the sample ends. | `#sec-l01-rows-by-hand` |
| "local" | footnote | — | Each horizon is estimated separately (Jordà 2005, §2). | `#sec-l01-model-to-regression` |
| military news | footnote | — | Narrative present value of expected military spending changes, scaled by lagged nominal trend GDP. | `#sec-l01-first-contact` |
| difference in means | prose | — | The OLS slope on a 0–1 regressor. | — |
| Monte Carlo simulation; small-sample bias; trend normalization; percent; percentage point | prose, link | L02 keys | Used unmarked; the $\rho=0.9$ gap is deferred. | — |
| identification; Frisch–Waugh–Lovell; serial correlation; influential episode | prose, link | L03, L05, L13 keys | Named where §first-contact and §residual stop. | — |

---

## 4. Evidence and visual ledger

Status codes: **C** means computed in a logged run and quoted here. **B** means
the figure or table is still to be built from stored output. **S** means a
stored result to export for the lab.

| Claim | Evidence or calculation | Medium | Source | Status | Label |
|---|---|---|---|---|---|
| The causal response is a gap between paths, not a change from the pre-shock level | Gap at $t=5..8$: $1, 0.5, 0.25, 0.125$. Change from $y_4$: $-0.73125, -0.196875, 1.9703125, -0.34609375$ | figure + table | `brief/l01-brief-checks.do` A3 | C, B | `fig-l01-realized-counterfactual`, `tbl-l01-hand-table` |
| $\theta_h=\theta_0\rho^h$; persistence sets the shape | $\theta_7=0.0078$ ($\rho=0.5$), $0.4783$ ($\rho=0.9$) | equation + figure | derivation D1 | C, B | `eq-l01-theta`, `fig-l01-persistence` |
| $\beta_h=\theta_h$ and $\gamma_h=\rho^{h+1}$ in population | $T=100{,}000$, seed 4, $\rho=0.9$, with $y_{t-1}$. $\hat\beta_h$ at $h=0,1,2,4,8$: 0.9985, 0.9013, 0.8117, 0.6498, 0.4249 (vs 1, 0.9, 0.81, 0.6561, 0.4305). $\hat\gamma_h$: 0.8990, 0.8068, 0.7235, 0.5825, 0.3792 (vs 0.9, 0.81, 0.729, 0.5905, 0.3874) | equation + sentence | `lecture/l01-checks.do` | C | `eq-l01-lp-toy` |
| Adding $y_{t-1}$ leaves the estimand alone but cuts sampling spread | $R=500$, $\rho=0.9$: sd of $\hat\beta_h$ is 0.0734 vs 0.2177 ($h=0$), 0.1978 vs 0.2693 ($h=4$). Means 1.0040 vs 0.9666 at $h=0$ | small table | `brief/l01-noctrl.do` | C | `tbl-l01-control-precision` |
| Twelve periods are too few | Slopes 0.617322, $-0.983356$, 2.050024 vs 1, 0.5, 0.25; $T_h=11,10,9$ | table + staircase | A1 | C, B | `tbl-l01-hand-slopes`, `fig-l01-row-staircase` |
| One episode is its outcome minus everyone else's mean | $-1.632397 = 1+(0.5\cdot0.0625-1.7-0.963648)$ at $h=0$ | equation + prose | A4, D4 | C | `eq-l01-one-episode` |
| One draw is noisy and its errors move together across $h$ | $\rho=0.9$, seed 2: $\hat\beta_{12}=-0.293297$, below the $R=500$ 5th percentile $-0.106968$ | figure | `lecture/onedraw_rho09_seed2.dta`, `brief/mc_toy_R500_summary.csv` | C, B | `fig-l01-one-draw` |
| On average the estimator lands near $\theta_h$ at $\rho=0.5$ and below it at $\rho=0.9$ | $R=500$: largest $\lvert$bias$\rvert$ at $\rho=0.5$ over $h\in\{0,1,2,4,8,12\}$ is 0.0124. At $\rho=0.9$: $-0.0263, -0.0332, -0.0489$ at $h=4,8,12$ (MCSE 0.0088–0.0102) | sentence (band in figure) | same | C | `fig-l01-one-draw` |
| The residual is serially correlated to lag $h$ | $u_{t,1}$ AC1 $=\rho/(2+\rho^2)$: 0.2222 / 0.3203. $u_{t,2}$ AC1 0.4390 / 0.5914, AC2 0.0976 / 0.1894, AC3 0. Empirical ($T=10^5$, seed 4): 0.2213, 0.3216; 0.4375, 0.5911; 0.0980, 0.1911; 0.0011, 0.0011 | equation + table | `checks/l01-design-checks.do` §4; D6 | C | `eq-l01-residual`, `tbl-l01-residual-ac` |
| First contact: a hump peaking at 10 quarters | Toy: 0.080313 ($h=0$), 0.404210 ($h=10$), 0.0796 ($h=20$). RZ controls: 0.0510, 0.2938, 0.0671, equal to REP04 `irf_gdp_linear` (0.050987698, 0.29376385) | figure (controls value in caption) | `rz/first-contact.do`; `benchmarks/REP04-linear-fiscal-multiplier.csv` | C, B | `fig-l01-first-contact` |
| Variation is concentrated in a few quarters | 108 of 504 quarters nonzero. Shares of $\sum(s_t-\bar s)^2$ ($h=8$ sample): 1941Q4 0.2612, 1950Q3 0.1958, 1942Q3 0.1009, 1950Q4 0.0869, 1917Q2 0.0745, 1941Q2 0.0617; cumulative 0.6448 (four), 0.7811 (six) | table | A E4 | C | `tbl-l01-news-variation` |
| One episode moves the estimate | $h=8$: 0.3619 full; 0.4340 without 1950Q3; 0.3443 without 1941Q4; 0.4451 without both; 0.0587 from 1947Q1 ($T_h=268$) | sentence + lab 4 | `rz/drop-episode.do` | C; S for $h=0..20$ | Lab 4 |
| Korea's realized path is not the response | Change since 1950Q2 at $h=0,4,10$: 0.028072, 0.061430, 0.078712. $0.600073\times\hat\beta_h$: 0.048194, 0.155503, 0.242556 | prose + exercise 10 | E3 | C | `#exercise-l01-10` |
| $T_h=T-h-p$ in every design | hand 11,10,9; toy $199-h$; RZ toy $504-h$; RZ controls $500-h$; JT $99-h$ | sentence | logs above | C | — |
| REP01 reproduces in 19.5 | Authors' script, 500 draws: $h=0..10$ means equal the CSV to 8 decimals (1.00175750 … 0.43152007) in 48.43 s | practicum table | `jt-example1-500/run500.do` | C | §8 |

---

## 5. Assessment map

Ten exercises: four in Stata ([computational]), one of them on real data. Every
Stata solution ships with `assert` lines.

| Outcome | Number and title | Tags | Mode of work | Hint strategy | Solution check | Linked lab section |
|---|---|---|---|---|---|---|
| 1 | 1. Two paths, one difference | [core] [pencil] | Recompute the hand economy with $s_5=0$ and every $v_t$ fixed; tabulate gap and change from $y_4$ for $t=5..8$ | Say which single input changes | Gap $1,0.5,0.25,0.125$ exactly; change from $y_4$ $-0.73125,-0.196875,1.9703125,-0.34609375$; common mistake named: subtracting $y_4$ | Lab 1 |
| 2 | 2. Iterate forward | [core] [pencil] | Write $h=1$, $h=2$, then general $h$; read off $\beta_h,\gamma_h,\mu_h,u_{t,h}$; show $\mathbb E[s_tu_{t,h}]=0$; at $\rho=0.9$ give $\theta_4$, $\theta_7$, first $h$ with $\theta_h<0.5$ | Do two substitutions before generalizing | $0.6561$, $0.4783$, $h=7$; $\gamma_h=\rho^{h+1}$ | Lab 1 |
| 3 | 3. Rows by hand | [core] [pencil] | For $h=0,1,2$ list the rows ($t\ge2$), $T_h$, treated rows, group means, slopes | Draw the staircase: which $t$ still has $y_{t+h}$? | $T_h=11,10,9$; slopes 0.617322, $-0.983356$, 2.050024; notice row 4 at $h=1$ has outcome $y_5$, which contains $s_5$ | Lab 2 |
| 3, 4 | 4. The same rows in Stata | [core] [computational] | `tsset t`; `forvalues h=0/2`; `regress F\`h'.y s if t>=2`, with and without `L.y`; means by `summarize` | Check `e(N)` before reading a coefficient | `assert abs(_b[s]-(m1-m0))<1e-6`, `assert e(N)==11-\`h'`; with-control slopes 0.575667, $-1.050405$, 2.153022 | Lab 2 export |
| 5 | 5. One episode | [core] [pencil] | Keep only the $t=5$ shock; prove slope $=y_{5+h}-\bar y_{\text{others}}$; compute $h=0,1,2$; split the $h=0$ value into $\theta_0$ and "everything else" | With one treated row, its "mean" is one number | $-1.632397,-0.984608,1.512823$; $-1.632397=1+(0.03125-1.7-0.963648)$ | Lab 2 |
| 4 | 6. A response in a loop | [core] [computational] | On `onedraw_rho09_seed2.csv`, loop $h=0..12$ with `postfile` (`h beta_h T_h`); graph with $\theta_h$ overlaid; caption | Store `e(N)` in the same `post` as `_b[s]`; the caption rubric has four slots | `assert T_h==199-h`; $\hat\beta_0=0.878940$, $\hat\beta_{12}=-0.293297$ at $10^{-6}$; caption graded on intervention, units of $s$ and $y$, horizon unit, counterfactual | Lab 3 export |
| 2, 5 | 7. Many draws | [computational] | Wrap exercise 6 in $R=200$ replications (skeleton fixes seed 3 and the $s$-then-$v$ order), $\rho\in\{0.5,0.9\}$; mean, sd, 5th/95th percentiles, with and without $y_{t-1}$ | Seed once, outside the loop | $\rho=0.9$, $h=8$: mean 0.370337, sd 0.211226 at $10^{-6}$; no-control sd larger at every $h$ when $\rho=0.9$; about one minute (not [extra], D26) | Lab 3 stored MC |
| 2 | 8. What the residual contains | [core] [pencil] | Write $u_{t,1}$ and $u_{t,2}$; count shared terms; give $\operatorname{Corr}(u_{t,1},u_{t+1,1})$ and $\operatorname{Corr}(u_{t,2},u_{t+k,2})$, $k=1,2,3$, at $\rho=0.5$ | List the dated terms in two adjacent rows | 0.2222; 0.4390, 0.0976, 0 | notes §residual |
| 5 | 9. First contact with military news | [data] [computational] | Run `get_data.do` (D5); build `y`, `newsy`; loop $h=0..20$; variation shares; $h=8$ without 1950Q3; caption and a five-sentence "not yet argued" paragraph (units, controls, identification, uncertainty, episode dependence) | Date news by arrival quarter and $y_{t-1}$ one quarter before | `assert` 504 nonmissing `newsy`, $T_h=504-h$; $\hat\beta_8=0.361906$, $\hat\beta_{10}=0.404210$; shares 0.261211, 0.195838; 0.4340 without 1950Q3 | Lab 4 |
| 1, 5 | 10. Korea is not the average | [extra] [pencil] | Compare realized change since 1950Q2 with $0.600073\,\hat\beta_h$ at $h=0,4,10$; give three reasons they differ | Which one is a gap between paths? | 0.028072/0.048194, 0.061430/0.155503, 0.078712/0.242556; reasons: a realized change is not a counterfactual gap; $\hat\beta_h$ averages over episodes led by 1941Q4; controls and identification are unargued | Lab 4 |

Each outcome has evidence in at least two media: 1 (figure, exercises 1 and
10, lab 1); 2 (equations, figure, exercises 2, 7, 8, lab 1); 3 (tables,
staircase, exercises 3–4, lab 2); 4 (figure, exercise 6, lab 3, STA01); 5
(table, figure, exercises 5, 9, 10, lab 4).

---

## 6. Derivations to verify

Unless stated otherwise, $\theta_0=\sigma_s=\sigma_v=1$.

**D1. The causal response (`eq-l01-theta`).**
*Source:* $y_t=\rho y_{t-1}+\theta_0s_t+v_t$.
*Steps:*
1. Substitute once: $y_{t+1}=\rho^2y_{t-1}+\rho\theta_0s_t+\rho v_t+\theta_0s_{t+1}+v_{t+1}$.
2. By induction, $y_{t+h}=\rho^{h+1}y_{t-1}+\sum_{j=0}^{h}\rho^{h-j}(\theta_0s_{t+j}+v_{t+j})$.
3. Change $s_t$ by $\delta$ and hold every other term fixed. The path moves by $\delta\theta_0\rho^h$ at $t+h$, so $\theta_h=\theta_0\rho^h$.

*Check:* in the hand economy, realized minus counterfactual at $t=5,\dots,12$ is exactly 1, 0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625, 0.0078125 (A3).

**D2. The projection (`eq-l01-lp-toy`).**
*Source:* the population projection's error is orthogonal to every regressor.
*Steps:*
1. In step 2 of D1, $u_{t,h}$ contains $v_t,\dots,v_{t+h}$ and $s_{t+1},\dots,s_{t+h}$.
2. $s_t$ is independent of all of these, so $\mathbb E[s_tu_{t,h}]=0$.
3. $y_{t-1}$ is built from terms dated $t-1$ or earlier, so $\mathbb E[y_{t-1}u_{t,h}]=0$.
4. $\mathbb E[u_{t,h}]=0$, so $\mu_h=0$.
5. The forward equation is therefore the projection: $\beta_h=\theta_0\rho^h$ and $\gamma_h=\rho^{h+1}$.
6. Dropping $y_{t-1}$ leaves $\beta_h$ unchanged, because $\operatorname{Cov}(s_t,y_{t-1})=0$. The residual then gains $\rho^{h+1}y_{t-1}$, so precision falls.

*Checks:* $T=100{,}000$ (seed 4) and $R=500$ precision, both in Section 4.

**D3. Slope on a binary regressor.**
*Steps:*
1. $\hat\beta=\sum(s_t-\bar s)y_{t+h}/\sum(s_t-\bar s)^2$.
2. With $n_1$ ones among $n$ rows, $\sum(s_t-\bar s)^2=n_1n_0/n$.
3. $\sum(s_t-\bar s)y_{t+h}=n_1(\bar y_1-\bar y)=(n_1n_0/n)(\bar y_1-\bar y_0)$.
4. So $\hat\beta=\bar y_1-\bar y_0$.

*Exact check, $h=0$:* $\bar y_1=3.792626953125/3=1.264208984375$ and $\bar y_0=5.17509765625/8=0.64688720703125$, difference 0.61732177734375.
*Exact check, $h=1$ and $h=2$:* $-0.034912109375-0.948443603515625=-0.983355712890625$; $2.2825439453125-0.23251953125=2.0500244140625$.
*Stata:* 0.61732179, $-0.98335569$, 2.05002437. The gaps of $2\times10^{-8}$ come from `v` stored as float.

**D4. One episode (`eq-l01-one-episode`).**
*Steps:*
1. With a single treated row $\tau$, D3 gives $\hat\beta_h=y_{\tau+h}-\bar y_{\text{others}}$.
2. At $\tau=5$, $h=0$: $y_5=0.5y_4+1+v_5=0.03125+1-1.7$.
3. The ten other rows sum to $9.636474609375$.
4. So $\hat\beta_0=-0.66875-0.9636474609375=-1.6323974609375$. This equals $\theta_0+(0.03125-1.7-0.9636475)$: the shock plus everything else that happened.

*Stata:* $-1.63239751$.

**D5. Sample size.** Row $t$ needs $y_{t-p}$ ($t\ge p+1$) and $y_{t+h}$ ($t\le T-h$), so $T_h=T-h-p$.
*Checks:* hand table 11, 10, 9; toy $199-h$; JT $99-h$.
*RZ:* `newsy` starts in 1890Q1, and $y_{t-1}$ exists there, so the toy specification has $504-h$ rows. The four-lag specification has $500-h$.

**D6. Residual autocovariance (`eq-l01-residual`).**
*Formulas:*
- $\operatorname{Var}(u_{t,h})=\frac{(1-\rho^{2h+2})+(1-\rho^{2h})}{1-\rho^2}$.
- For $1\le k\le h$: $\operatorname{Cov}(u_{t,h},u_{t+k,h})=\rho^k\frac{(1-\rho^{2(h-k+1)})+(1-\rho^{2(h-k)})}{1-\rho^2}$, from the $v$ terms and then the $s$ terms shared by both rows.
- For $k>h$ the covariance is zero.

*Special cases:*
- $h=1$: variance $2+\rho^2$, covariance $\rho$.
- $h=2$: variance $2+2\rho^2+\rho^4$, covariances $2\rho+\rho^3$ and $\rho^2$.

*Numbers:*
- $\rho=0.5$: $0.5/2.25=0.2222$; $1.125/2.5625=0.4390$; $0.25/2.5625=0.0976$.
- $\rho=0.9$: $0.9/2.81=0.3203$; $2.529/4.2761=0.5914$; $0.81/4.2761=0.1894$.

*Empirical check ($T=10^5$, seed 4):* 0.2213, 0.4375, 0.0980 and 0.3216, 0.5911, 0.1911. Lag 3 is 0.0011 at both $\rho$.

**D7. Where the variation comes from.** Row $t$'s share of the slope's denominator is $(s_t-\bar s)^2/\sum(s_t-\bar s)^2$. On the $h=8$ toy sample the shares are 0.261211 (1941Q4) and 0.195838 (1950Q3), and four quarters give 0.644839. With $y_{t-1}$ included, the exact weights use $s_t$ purged of $y_{t-1}$; that is footnote 6.

**D8. Korea.** Realized change $y_{1950Q3+h}-y_{1950Q2}$ with
$y_{1950Q2}=0.972500$, against $0.600073\,\hat\beta_h$; values in Section 4.

**D9. Monte Carlo precision.** MCSE $=\text{sd}/\sqrt R$. At $\rho=0.9$,
$h=12$, $R=500$: $0.224580/\sqrt{500}=0.010044$, so the $-0.048891$ gap is 4.9
MCSE. At $\rho=0.5$ the largest gap is $-0.012368$ (2.3 MCSE). The notes say
"close" and "systematically below" and defer the cause to Lecture 2.

---

## 7. HTML lab plan (Shock-to-Response Explorer, `interactives/01-shock-to-response-explorer.qmd`)

Four Observable JS labs, each with setup, a **Predict before using the
controls** prompt, controls with units, a plot or table, a reactive sentence,
controlled comparisons, and a collapsed explanation. Outputs are labeled live
calculation, stored simulation result, or stored result. The browser reads
shipped observations instead of regenerating Stata's draws (blueprint §5.4);
live OLS is validated against Stata at $10^{-8}$.

**Lab 1 — Two paths (live).**
- *Question:* what is the response, and why is it not the rise since the pre-shock date?
- *Invariants:* $v_1,\dots,v_{12}$ from the hand table; $y_0=0$; reference date $t=4$.
- *Controls:*
  - shock at $t=5$ on or off (default on);
  - $\theta_0\in[0,2]$, units of $y$ per unit of $s$ (default 1);
  - $\rho\in[0,0.95]$, step 0.05 (default 0.5).
- *Computation:* the recursion for $y_t$ and $y^{c}_t$.
- *Reactive sentence:* "With $\rho=0.50$ and $\theta_0=1.00$ the gap at $t=7$ is 0.250, while $y$ has risen 1.970 since $t=4$; the other 1.720 is everything else."
- *Comparisons:* change $\rho$ from 0.5 to 0.9 with $\theta_0$ fixed (the impact gap does not move); double $\theta_0$; switch the shock off.
- *Prediction:* "If $\rho$ rises, does the gap at $t=5$ change?"
- *Handoff:* none; feeds Lab 2.

**Lab 2 — Rows for horizon $h$ (live).**
- *Question:* which rows enter, and what does each regression compute?
- *Invariants:* the stored twelve-row table.
- *Controls:*
  - $h\in\{0,1,2,3\}$, periods (default 0);
  - $y_{t-1}$ on or off (default off);
  - "single episode" (keep only $s_5$; default off).
- *Output:* a highlighted row table, the staircase, $T_h$, group means, $\hat\beta_h$.
- *Reactive sentence:* "At $h=2$ the regression uses rows 2–10 ($T_h=9$); treated rows 5 and 10 average 2.283 against 0.233, so $\hat\beta_2=2.050$ while $\theta_2=0.25$."
- *Comparisons:*
  - change $h$ only;
  - toggle the control on the same rows;
  - at $h=3$, notice that only row 5 is treated and the regression becomes a single episode automatically.
- *Prediction:* "Which rows leave when $h$ goes from 0 to 2?"
- *Handoff:* export `hand_table.csv` ($t,s,v,y$) and the chosen $h$ for exercise 4.

**Lab 3 — One draw versus the truth (live on shipped draws; stored band).**
- *Question:* how far can one $T=200$ estimate be from $\theta_h$, and what does $y_{t-1}$ buy?
- *Invariants:* the seed-2 draws; $H=12$.
- *Controls:*
  - $\rho\in\{0.5,0.9\}$, which selects the draw (default 0.9);
  - $T\in\{50,100,200\}$, the first $T$ rows (default 200);
  - $y_{t-1}$ on or off (default on);
  - 5–95 percent band on or off, labeled "stored simulation result, $R=500$, seed 3".
- *Reactive sentence:* "With $\rho=0.90$, $T=200$ and $y_{t-1}$ included, $\hat\beta_8=0.241$ against $\theta_8=0.430$; across 500 stored samples, 90 percent of estimates lie between 0.047 and 0.793."
- *Comparisons:* toggle the control at fixed $T$; shorten $T$ with the draw fixed; switch $\rho$.
- *Prediction:* "Without $y_{t-1}$, does the curve move toward $\theta_h$, away from it, or just get noisier?"
- *Handoff:* export the draw, $T$, and the control choice for exercises 6–7.

**Lab 4 — Where the coefficient's variation comes from (stored results).**
- *Question:* which quarters drive the military-news coefficient, and how much does one episode matter?
- *Invariants:* the RZ sample and specifications; no raw series is sent to the browser (D5; Section 10, question 3).
- *Controls:*
  - $h\in\{0,\dots,20\}$ quarters (default 8);
  - specification: toy or RZ controls;
  - exclude 1941Q4; exclude 1950Q3;
  - start in 1947Q1.
- *Computation:* a stored grid of $2\times5\times21=210$ OLS coefficients plus the ten largest variation shares, produced by the build do-file. Only $h=4$ and $h=8$ are computed now.
- *Reactive sentence:* "At $h=8$ the toy LP gives 0.362; without 1950Q3 it gives 0.434 — one quarter of 496 moves the estimate by 0.072."
- *Comparisons:* one exclusion at a time; the specification toggle with the exclusion fixed.
- *Prediction:* "Will dropping Korea's news quarter lower the coefficient?" It raises it.
- *Handoff:* a written hypothesis about the $h=8$ drop-1950Q3 estimate, tested in exercise 9.

---

## 8. Practicum plan (REP01, STA01, HTML01 handoff)

### 8.1 REP01 — Recover the basic LP estimator

**Target.**
- *Paper:* Jordà and Taylor (2025), "Local Projections," *JEL* 63(1), 59–110, Figure 1a. The levels-LP mean response, $h=0,\dots,10$, intercept included, no lagged difference.
- *Package:* `ojorda/JEL-Code`, commit `655696c1c576b7537c5a939d2c261f0a111ae663`. Frozen at `replication-packages/packages/jel-code/`; CC0; the supplied ZIP is identical.

**Script and lines** (`original/LP_JEL_Replication/Example1_LongDifferences/SSBias_IntcpYLagdiffN_95.do`, SHA-256 `07116508…4682a1e7e2`):
- 20–27: settings (burn-in 500, `hmax` 10, $\rho=0.95$).
- 39: `set seed 12345`.
- 45–63: DGP. `vy` is drawn on line 52, then `e` on line 56; line 59 is `y = rho*l.y + vy + e` for `_n>2`; line 62 drops the burn-in.
- 84–90: the levels regressions (line 87: `reg f\`h'.y vy l.y`).
- 125: stored draws. 139–140: MC means. 156–160: true response.
- Driver `all-simulate.do`: lines 18–19 (`nobs 100`, `nreps 10000`) and 27–28.
- Mapping to course notation: `vy`$=s_t$, `e`$=v_t$, $\theta_0=1$, $T=100$, $p=1$, $T_h=99-h$ (derived, not a stored `e(N)`).

**Kind.** A statistical reproduction: the published figure uses 10,000 draws. At a matched draw count it is exact.

**Benchmark** (`benchmarks/REP01-levels-lp.csv`, 500 draws, Stata 18.5). The column "19.5, $R=500$" is the authors' script rerun this pass. The column "$R=200$" is the authors' script at `nreps 200` in 19.5; the course reconstruction gives the same values.

| $h$ | $\theta_h$ | CSV mean | 19.5, $R=500$ | $R=200$ | MCSE ($R=500$) |
|---|---|---|---|---|---|
| 0 | 1.0000 | 1.00175750 | 1.00175750 | 0.99686521 | 0.0047 |
| 1 | 0.9500 | 0.92489529 | 0.92489529 | 0.91357774 | 0.0077 |
| 2 | 0.9025 | 0.86787397 | 0.86787397 | 0.85901380 | 0.0103 |
| 3 | 0.8574 | 0.79257834 | 0.79257834 | 0.78925842 | 0.0118 |
| 4 | 0.8145 | 0.73754936 | 0.73754936 | 0.74316418 | 0.0135 |
| 5 | 0.7738 | 0.67800373 | 0.67800373 | 0.68870902 | 0.0149 |
| 6 | 0.7351 | 0.62550861 | 0.62550861 | 0.62830913 | 0.0159 |
| 7 | 0.6983 | 0.57830870 | 0.57830870 | 0.57235688 | 0.0166 |
| 8 | 0.6634 | 0.51882571 | 0.51882571 | 0.50967115 | 0.0177 |
| 9 | 0.6302 | 0.48049915 | 0.48049915 | 0.48197576 | 0.0177 |
| 10 | 0.5987 | 0.43152007 | 0.43152007 | 0.42771590 | 0.0178 |

**Tolerance.** Absolute $10^{-6}$ on means at a matched $R$ (manifest). The 19.5 rerun matches to every printed digit, so D1 needs no software row.
The authors also ship a precomputed 10,000-draw file. The $R=500$ means lie within 0.018 of it (largest at $h=2$, 1.7 MCSE). That comparison is visual only; there is no equality criterion.

**Runtime (19.5).** Authors' script: 48.43 s at 500 draws, 28 s at 200.
Reconstruction, 1,000 levels-only draws: 123.89 s.

**Departures.** Draws reduced (D2); `graph set window fontface "Palatino"` is
ignored in batch (presentation only); the authors' `cap cd` Dropbox lines fail
silently; the long-difference, cumulated and AR curves in the same figure
belong to REP02; no regression standard errors are stored.

**Redistribution (D5).** CC0: ship `SSBias_IntcpYLagdiffN_95.do` and `all-simulate.do` unchanged, with `SOURCE.md`, the license, and hashes.

**Student steps.**
1. One realization, one horizon. Rebuild draw 1 outside the loop: seed 12345, 600 observations, `vy` then `e`, recursion, drop 500. `reg F0.y vy L.y` gives 1.06035137 with $N=99$; assert equality with the authors' script at `nreps 1` (1.060351).
2. The draw-1 curve at $h=0,\dots,10$: 1.06035137, 0.99981713, 0.59646147, 0.55573124, 0.40316078, 0.21355943, 0.08826523, $-0.14803843$, $-0.28229347$, $-0.25071168$, 0.24310037.
3. Run the supplied driver at $R=200$ and assert the $R=200$ column at $10^{-6}$.
4. Write a 150-word note on the construction: which variable is $s_t$, which rows, what is averaged.

### 8.2 STA01

**Structure.**

```
lab-project/
  master.do                 global R 200; runs code/ in order; stops on a failed assert
  code/01_hand_rows.do      exercises 3-5
  code/02_loop.do           exercise 6
  code/03_mc.do             exercise 7
  code/04_first_contact.do  exercise 9
  code/05_rep01.do          REP01 steps 1-3
  data/raw/                 hand_table.csv, onedraw_rho05_seed2.csv, onedraw_rho09_seed2.csv (ship);
                            get_data.do (RZ; SHA-256 b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120);
                            PROVENANCE.md (URLs, vintage, manual fallback; D5)
  vendor/jel-code/          CC0 files and SOURCE.md
  output/                   logs, results, figures
```

**Tasks** (construct, estimate, diagnose, interpret):
1. Construct the rows for $h=0,1,2$. Assert `T_h==11-h`.
2. Estimate them manually. Assert that the slope equals the difference in means at $10^{-6}$.
3. Loop across horizons. Assert `T_h==199-h`; $\hat\beta_0=0.878940$, $\hat\beta_{12}=-0.293297$.
4. Draw the graph with a four-part caption. Run the Monte Carlo; assert $\rho=0.9$, $h=8$ mean 0.370337.
5. Explain the shock dates: the variation shares and the drop-1950Q3 estimate (0.4340), plus the "not yet argued" paragraph.

Expected outputs: `results_hand.dta`, `results_onedraw.dta`, `mc_R200_summary.dta`, `first_contact.dta`, `rep01_compare.csv`, and three PDF figures.

**Handoff.**
- Labs 2 and 3 export the observations the Stata tasks read.
- Lab 4's written hypothesis is tested in task 5.
- `first_contact.dta` is reopened in Lecture 2 (units) and Lecture 4 (the same data under REP04).

**Submission package (blueprint §4.2).**
- *Replication record:* the REP01 table, the draw count, and 19.5 against the 18.5 benchmark.
- *Stata submission:* `master.do`, the log, results, figures, and the assertion log.
- *Interpretation record:* estimand $\theta_h$, units of $s$ and $y$, the unargued assumptions, and the absence of standard errors.
- *HTML lab record:* predictions and settings for labs 1–4.

---

## 9. Slides arc

1. **Korea, 1950** — one realized path cannot answer "because of".
2. **Two paths** — the response is a gap between paths, not a rise since the pre-shock date.
3. **Two clocks** — $t$ dates the row, $h$ counts forward; one coefficient is one point.
4. **The smallest model** — $\theta_h=\theta_0\rho^h$; persistence sets the shape.
5. **The model is a regression** — forward substitution gives the LP with $\beta_h=\theta_h$.
6. **Why $y_{t-1}$** — the same estimand with far less noise (sd 0.073 versus 0.218).
7. **Rows by hand** — the staircase, $T_h=11,10,9$.
8. **One episode** — $-1.632=1+(-2.632)$: the shock plus everything else.
9. **One draw, many draws** — `fig-l01-one-draw` with its stored band.
10. **Inside the residual** — shared terms, autocorrelation to lag $h$; Lecture 5 shows that inference depends on the autocorrelation of $s_tu_{t,h}$, which in this economy is zero because $s_t$ is unpredictable.
11. **First contact** — military news and GDP relative to trend.
12. **Not yet argued** — two quarters carry 46 percent of the variation; units, controls, identification.
13. **The Explorer and STA01** — from rows in the browser to a loop in Stata.
14. **Handoff** — $y_{t+h}$ or $y_{t+h}-y_{t-1}$: a different answer or different clothes?

---

## 10. Open questions for the editor

1. **Hand-table shock.** This brief uses a binary shock (`rbinomial(1,0.3)`) so the slope is a difference in means, while designs B–C use Gaussian shocks. The spine fixes only seed 1, $\rho=0.5$, $\theta_0=1$. Is the switch acceptable?
2. **Ledger entries.** Please add $v_t$, $\sigma_v$, $\theta_0$ and $y^{c}_t$ to ledger §1; the Lecture 6 and 7 briefs already use $\sigma_v$. Please also allow $\sigma_s$ before Lecture 2. The ledger row for $u_{t,h}$ should read "disturbances dated $t,\dots,t+h$ and shocks dated $t+1,\dots,t+h$", because the toy residual contains $v_t$.
3. **D5 and the browser lab (owner).** May a public lab display coefficients and variation shares estimated from Ramey–Zubairy data without shipping the series? If not, Lab 4 becomes a Stata-only exercise.
4. **Seed-2 draw.** At $\rho=0.9$, $\hat\beta_{12}$ lies below the stored 5th percentile. The brief keeps the draw as honest evidence that errors move together across horizons. A seed chosen by outcome would be cherry-picking; confirm.
5. **Acquisition script location.** Ramey–Zubairy data recur in Lectures 1, 2, 4, 9 and 13. Should one course-level `get_data.do` serve every practicum? The author archive is a Google Drive viewer link that may refuse scripted download, which would make the manual fallback the usual route.
