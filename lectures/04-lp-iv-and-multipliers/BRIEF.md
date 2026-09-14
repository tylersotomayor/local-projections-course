# Lecture 04 brief — LP-IV and cumulative multipliers

Planning brief, September 13, 2026. Binding: editor decisions D1, D2, D5, D11,
with D4, D24, D26, D30, D31 where cited. Every number below comes from a run in
the table, the REP04 benchmark CSV, or a derivation in Section 6. `design-04/`
abbreviates the scratch directory
`/private/tmp/claude-501/-Users-tylersotomayor-macro-local-projections/c072337f-0f2c-4cf4-bb71-22a0631666a1/scratchpad/design-04/`.

| Script (in `design-04/`) | Purpose | Wall clock | Stata error lines |
|---|---|---|---|
| `rz/fresh/jordagk.do` | Unchanged author script, StataNow/SE 19.5 | 9.73 s | 0 |
| `rz/rz_l04_extract.do` | IRFs, reduced forms, one- and two-step multipliers, OLS comparison, residualized first stage at $H=7$ | seconds | 0 |
| `rz/l04_hac_check.do` | `ivregress 2sls, vce(hac bartlett)` against `ivreg2, robust bw(auto)`; Kleibergen–Paap $F$ identity | 1.5 s | 0 |
| `rz/rz_l04_delta.do`, `rz/l04_delta_detail.do` | Delta-method standard errors with and without the covariance | about 1 s | 0 |
| `sim/l04_mc500.do` (one Stata command per design, via `run_mc500_*.do`) | Sandbox Monte Carlo at D2's instructor count $R=500$, `set seed 4`: $\sigma_\xi\in\{0.5,1,2,4,8\}$ at $\zeta_0=0$, and $\zeta_0=0.3$ at $\sigma_\xi\in\{0.5,1\}$; StataNow/SE 19.5 written to each log | 15.8–16.3 s per design | 0 |
| `sim/l04_leadlag_sandbox.do`, `sim/l04_leadlag_cover.do` | Sandbox, $R=200$: lead–lag contamination, lag length, weak instrument | 39.6 s, 1 s | 0 |
| `sim/l04_largen.do`, `sim/l04_largen_p1.do`, `sim/l04_ols_limit.py`, `sim/l04_draw_check.do` | $n=10^6$ population limits (`set seed 4`), including $p=1$ and the cumulative OLS limit; exact limits from MA coefficients (Python); shipped-draw check | 11.4 s, 13.3 s, under 1 s, 1 s | 0 (Python: none) |

Every Monte Carlo number comes from a run within D2: instructor quantities
from `l04_mc500.do` ($R=500$) and student-scale ones from
`l04_leadlag_sandbox.do` ($R=200$). Earlier $R=2{,}000$ runs
(`l04_sim.do`, `l04_sim2.do`; 737 s and 685 s, Stata version not logged)
broke D2's ceiling and are not quoted; each $R=500$ run reproduces their first
500 replications exactly. `l04_sim.do` remains the generator of the shipped
draw `l04_sandbox_seed4.csv`, which `l04_draw_check.do` re-imports in 19.5.
The extract's Stata version was not logged either; `l04_hac_check.do`
reproduces it in 19.5 at nine horizons to $10^{-7}$. The
coverage column of `l04_leadlag_summary.csv` is invalid because the scalar
`cov` abbreviated the variable `cover`; coverage comes from
`l04_leadlag_cover.log`. The earlier `sim_l04*.do` files use another design
and are not quoted.

## 1. Session brief

**Opening situation.**
Two years after a military-news shock, how much GDP has a dollar of government
spending bought? Take the Ramey–Zubairy quarterly data, 1889Q1–2015Q4, with
real GDP and real government spending both divided by trend real GDP.
Regress output accumulated over eight quarters on spending accumulated over
the same eight quarters, controlling for four lags of GDP, spending, and
military news. The coefficient is 0.487 (HAC s.e. 0.098, 493 rows). Now
instrument accumulated spending with the military news dated at the start of
the window. The answer becomes 0.664 (0.067), the "2-year integral" in the
linear column of their Table 1. On impact the two estimates are 0.164 and
1.306, and the first-stage $F$ statistic behind the 1.306 is 7.3. The
regression's spending variable responds to the economy it is supposed to
explain. The news is meant to isolate the part of spending that does not.
The lecture asks three things: whether the news does that, why the answer
must be a ratio, and what that ratio can and cannot promise. The residualized
news series links back to Lecture 1: 1950Q3, the Korean War, is its
second-largest value (0.592), just behind 1941Q4 (0.598).

**Decision or empirical question.**
A forecaster must quote one number: the cumulative government-spending
multiplier over two and four years. The question is which regression produces
it and what must be true of the instrument for that number to be causal. The
answer is a one-step two-stage-least-squares regression of accumulated output
on accumulated spending, instrumented by news. Its estimand is a ratio of two
reduced-form cumulative responses. It is causal only under relevance,
contemporaneous exogeneity, and lead–lag exogeneity conditional on the
controls. Its precision depends on the denominator, and the strength of the
first stage says nothing about validity.

**Target student and prerequisites.**
The student has completed Lectures 1–3. They can write
$y_{t+h}=\mu_h+\beta_h s_t+\boldsymbol\gamma_h'\mathbf w_t+u_{t,h}$, compute
cumulative responses $B_h$ and state their units, and choose a common or a
horizon-specific sample (L2). They know the identifying assumption and
Frisch–Waugh–Lovell partialling out, and can tell a predetermined control
from a post-treatment one (L3). They also bring L3's open question. The
shelter regression on the Bauer–Swanson surprise is the reduced form of an
LP-IV whose endogenous regressor is the monthly change in the funds rate
(`stir`), which is what `Figure4.do`'s "Instrument: mon_shock" comment
announces even though the code regresses on the instrument directly. Its
first link (funds-rate change on the surprise, $b=0.346$, s.e. 0.314,
$R^2=0.0086$, $N=383$, no controls) is a weak first stage. On the Stata side they know `regress`,
`tsset` leads and lags, loops, and `postfile`. Cross-sectional 2SLS at the
level of an introductory course is assumed (blueprint §1.2); the Wald ratio is
rederived. HAC standard errors are used as a named procedure with a footnote.
Lecture 5 explains them.

**Learning outcomes.**

1. State relevance, contemporaneous exogeneity, and lead–lag exogeneity for an
   external instrument $z_t$ conditional on $\mathbf w_t$. Show when
   predetermined controls restore lead–lag exogeneity, and write
   $\beta^{\mathrm{IV}}_h$ as a ratio of two conditional covariances.
2. Estimate LP-IV horizon by horizon with `ivregress 2sls`. At every horizon,
   report the first stage, its robust $F$ statistic, and the estimation
   sample, and explain why each horizon needs its own first stage.
3. Build $M_H=B^{Y}_H/B^{G}_H$ two ways, as one-step 2SLS and as a ratio of
   reduced forms, and prove the two identical on a common sample. Explain why
   the two-step ratio of response sums (a teaching comparison, D11) differs,
   and why the one-step standard error
   is the one to report.
4. Predict and then verify how a weak denominator reshapes the sampling
   distribution of the ratio: the median moves toward OLS, the tails become
   heavy, and the mean does not exist. Show that a contaminated instrument
   biases $M_H$ however strong its first stage.
5. Reproduce the Ramey–Zubairy linear military-news multipliers for
   $h=0,\dots,20$. Reconstruct numerator, denominator, units, and horizon
   indexing, and write an instrument memo that separates relevance evidence
   from the validity argument. This outcome is the mastery requirement.

**Anchor numerical or data example.**

*Real data (REP04, D11).* Source: the Ramey and Zubairy (2018) package, February
2018, `jordagk.do` dated February 24, 2018. The data are `RZDAT.xlsx`, sheet
`rzdat`, the April 7, 2016 update: 508 consecutive quarters, 1889Q1–2015Q4.
Variables and units, following `jordagk.do` lines 90–108:

- $y_t$ = `rgdp/rgdp_pott6`, real GDP as a ratio to trend real GDP. The trend
  is a sixth-degree polynomial in log GDP, fitted excluding 1930–1946.
- $s_t$ = `(ngov/pgdp)/rgdp_pott6`, real government spending on the same scale.
  In the fiscal sections it is written $g_t$ where the fiscal meaning helps,
  with Stata name `g`.
- $z_t$ = `news/(L.rgdp_pott6*L.pgdp)`: the change in the expected present
  discounted value of military spending, as a ratio to lagged nominal trend
  GDP.
- $\mathbf w_t$ = a constant plus lags 1–4 of $z$, $y$, $g$. No trend, no
  taxes, World War II retained.
- Accumulated variables are `fHcumuly` $=\sum_{j=0}^{H}y_{t+j}$ and
  `fHcumulg`. The estimation sample has $T_H=500-H$ rows.
- HAC standard errors come from `ivreg2, robust bw(auto)`: a Bartlett kernel
  with automatic bandwidth 29, or 28 at $h=11$–14.

Values from `rz_l04_extract.do` (`l04_linear.csv`); one-step $\hat M_H$ and
its s.e. equal the benchmark CSV within $3\times10^{-7}$.

| $H$ | $T_H$ | $\hat\beta^{Y}_H$ | $\hat\beta^{G}_H$ | $\hat B^{Y}_H$ (common) | $\hat B^{G}_H$ (common) | $\hat M_H$ | HAC s.e. | KP $F$ | $\tilde M_H$ (two-step) |
|---|---|---|---|---|---|---|---|---|---|
| 0 | 500 | 0.0510 | 0.0390 | 0.0510 | 0.0390 | 1.3065 | 0.3517 | 7.33 | 1.3065 |
| 1 | 499 | 0.0747 | 0.0796 | 0.1257 | 0.1186 | 1.0599 | 0.2490 | 8.94 | 1.0598 |
| 4 | 496 | 0.1612 | 0.2556 | 0.5074 | 0.7460 | 0.6801 | 0.0997 | 19.22 | 0.6799 |
| 7 | 493 | 0.2035 | 0.3349 | 1.1273 | 1.6985 | 0.6637 | 0.0671 | 19.38 | 0.6632 |
| 12 | 488 | 0.2563 | 0.3500 | 2.4782 | 3.4452 | 0.7193 | 0.0511 | 14.23 | 0.7175 |
| 15 | 485 | 0.1682 | 0.2585 | 3.0842 | 4.3235 | 0.7134 | 0.0436 | 11.22 | 0.7116 |
| 20 | 480 | 0.0671 | 0.0500 | 3.5496 | 4.8659 | 0.7295 | 0.0594 | 10.43 | 0.7263 |

Table 1's "2-year integral" 0.66 (0.067) is $H=7$ and its "4-year integral"
0.71 (0.044) is $H=15$ (JPE p. 871). The reason is that the windows
$h=0,\dots,7$ and $h=0,\dots,15$ contain 8 and 16 quarters.

*Simulated sandbox economy.* This is Lecture 1's AR(1) economy with spending made
endogenous and an external instrument added (model below). Baseline:
$\rho=0.5$, $\rho_s=0.7$, $\theta_0=0.8$, $\psi=0.5$, $\sigma_\xi=1$,
$\zeta_0=\zeta_1=0$. Design: $T=200$ after a burn-in of 100, `set seed 4`
before each design. The target is the cumulative multiplier at $H=8$. The
controls are $p=2$ lags of $y$, $s$, $z$, with HC-robust `ivregress 2sls`.
Instructor Monte Carlo (D2): $R=500$ for $\sigma_\xi\in\{0.5,1,2,4,8\}$, plus
$\zeta_0=0.3$ at $\sigma_\xi\in\{0.5,1\}$, one Stata command per design. Student-scale Monte Carlo:
$R=200$ for designs (1) baseline, (2) $\zeta_1=0.8$, (3) $\zeta_0=0.3$,
(4) $\sigma_\xi=4$, each with $p\in\{0,1,2,4\}$. The shipped single draw is
`l04_sandbox_seed4.csv` (variables `t eps eta nu z s y`; `eta` is $v_t$ and
`nu` is $\xi_t$; renamed in the lab project).

**Smallest useful model (ledger notation).**
$$
\begin{aligned}
s_t&=\rho_s s_{t-1}+\varepsilon_t+\psi v_t,\\
y_t&=\rho\,y_{t-1}+\theta_0 s_t+v_t,\\
z_t&=\varepsilon_t+\sigma_\xi\xi_t+\zeta_0 v_t+\zeta_1 v_{t-1},
\end{aligned}
\qquad \varepsilon_t,v_t,\xi_t\ \text{i.i.d. }\mathcal N(0,1).
$$
$\varepsilon_t$ is the spending shock of interest, $v_t$ the output shock the
researcher never sees, and $\xi_t$ measurement noise in the instrument.
$\psi>0$ makes spending endogenous. $\sigma_\xi$ sets instrument strength,
$\zeta_0$ contaminates the instrument contemporaneously (a violation of A2),
and $\zeta_1$ violates lead–lag exogeneity (A3). Truth for a unit
$\varepsilon_t$ (§6.3): $\theta^{G}_h=\rho_s^h$ and
$\theta^{Y}_h=\theta_0\sum_{j=0}^{h}\rho^{h-j}\rho_s^{j}$, so
$M_H=\sum_{h\le H}\theta^Y_h/\sum_{h\le H}\theta^G_h$. The values are
$M_0=0.8$, $M_1=1.035294$, $M_4=1.402647$, $M_8=1.551982$ (with
$B^G_8=3.198821$, $B^Y_8=4.964512$), and $M_{12}=1.588407$. The shock
$v_{t-1}$, like every earlier shock, reaches $y_{t+h}$ and $s_{t+h}$ only
through $(y_{t-1},s_{t-1})$. With $p\ge1$ lags that pair is in $\mathbf w_t$,
so $\zeta_1v_{t-1}$ drops out of both covariances, although $v_{t-1}$ itself
($=y_{t-1}-\rho y_{t-2}-\theta_0 s_{t-1}$) is spanned only at $p\ge2$, which is
sufficient but not necessary. The population one-step LP-IV then has limit
$M_H+\zeta_0\sum_{h\le H}\rho^h/\{B^G_H(1+\psi\zeta_0)\}$ (1.714767 at
$\zeta_0=0.3$), whatever the values of $\sigma_\xi$ and $\zeta_1$. Without
controls, $\zeta_1=0.8$ moves the limit to 1.824986 (§6.5). The population
impact first stage is $\pi=1/(1+\sigma_\xi^2)$.

**Dependency chain of sections.**

1. `#sec-l04-endogenous-regressor` *The endogenous regressor.* Spending
   reacts to the output shock ($\psi>0$), so the slope of output on spending
   mixes the spending effect with that reaction: 1.2 against 0.8 on impact in
   the sandbox.
2. `#sec-l04-instrument-conditions` *Three conditions for an instrument.*
   Relevance (A1), contemporaneous exogeneity (A2), and lead–lag exogeneity
   (A3), each conditional on $\mathbf w_t$ (Stock–Watson). Controls repair a
   lead–lag failure when they absorb the offending shock's effect on the
   future outcome and regressor. In the sandbox that means $y_{t-1}$ and
   $s_{t-1}$, so $p=1$ suffices; spanning $v_{t-1}$ itself at $p=2$ is
   sufficient but not necessary.
3. `#sec-l04-lp-iv-estimand` *The LP-IV estimand is a ratio.* Under A1–A3,
   $\operatorname{Cov}(y_{t+h},z_t\mid\mathbf w_t)/\operatorname{Cov}(s_t,z_t\mid\mathbf w_t)=\theta_h$,
   and just-identified 2SLS computes exactly this ratio of two slopes. L3's
   shelter regression on the surprise is such a numerator, with the
   funds-rate change as $s_t$. Its first link ($b=0.346$, s.e. 0.314,
   $R^2=0.0086$, no controls) is a weak denominator, and
   `#sec-l04-first-stages` shows what that does to the ratio.
4. `#sec-l04-first-stages` *One first stage per horizon.* Each horizon has
   its own dependent variable, its own $T_H$ rows, and its own first-stage
   slope $\hat B^G_H$. The news first-stage $F$ is 7.3 at impact, 19.6 at
   $h=5$, and 10.4 at $h=20$.
5. `#sec-l04-responses-to-multiplier` *From responses to a multiplier.* On
   common rows, one-step 2SLS of $\sum y$ on $\sum s$ equals the ratio of the
   cumulative reduced forms. The two-step ratio of response sums (a teaching
   comparison, D11) sums slopes from different rows. The one-step s.e.
   includes the covariance of numerator and denominator automatically. A
   two-step delta-method s.e. matches it only if the cross covariance is
   estimated on common rows (§6.7). Dropping the covariance overstates the
   s.e. 1.50 times at $H=0$, 3.67 at $H=7$, and 6.25 at $H=20$.
6. `#sec-l04-small-denominator` *When the denominator is small.* In
   $R=500$ replications (seed 4), as $\sigma_\xi$ rises from 0.5 to 8, the
   median $F$ falls from 22.1 to 0.7. The median multiplier drifts from 1.567
   toward OLS, reaching 1.633 against an OLS median of 1.693, and 8.2 percent
   of estimates exceed 5 in absolute value.
7. `#sec-l04-units-normalization` *Units and normalization.* Dividing by
   trend GDP makes $M_H$ dollars per dollar. Rescaling $z_t$ changes nothing,
   but $\beta^{\mathrm{IV}}_h$ and $M_H$ normalize by different spending
   quantities.
8. `#sec-l04-relevance-validity` *Relevance is not validity.* Contaminating
   the instrument ($\zeta_0=0.3$, $\sigma_\xi=1$, $R=500$, seed 4) raises its
   median $F$ from 13.0 to 16.8. It moves the median $\hat M_8$ to 1.74 (mean
   1.733, limit 1.715) against a truth of 1.55. Validity is argued from the
   narrative record; the $F$ statistic cannot test it.
9. `#sec-l04-fiscal-anchor` *The fiscal anchor.* Reproduce REP04 exactly
   (D11) and rebuild numerator, denominator, horizon indexing, and first
   stages with built-in commands.
10. `#sec-l04-handoff` *What a band around a multiplier promises.* The
    interval beside 0.664 is a claim about repeated samples, which Lecture 5
    tests.

**Central notation.**
From the ledger: $t,h,H,T,T_h,\mathcal T_h$; $y_t$, $s_t$, $\mathbf w_t$, $p$;
$\beta_h,\hat\beta_h,\theta_h,\mu_h,\boldsymbol\gamma_h,u_{t,h}$;
$\varepsilon_t,\boldsymbol\varepsilon_t,\Omega_{t-1}$; $z_t$, $\pi$,
$\beta^{\mathrm{IV}}_h$; $\beta^Y_h,\beta^G_h,B_h,M_H$; $\rho$, $R$,
$\operatorname{se}(\cdot)$, $\alpha$. New in this lecture (Section 2): $v_t$
(from L1), $\xi_t$, $\sigma_\xi$, $\psi$, $\zeta_0$, $\zeta_1$, $\rho_s$,
$\theta^{Y}_h$, $\theta^{G}_h$, $B^Y_H$, $B^G_H$, $\hat M_H$ and $\tilde M_H$,
$F_H$, $q$, $F^{\mathrm{pop}}_0$, and $M^{0}$, the hypothesized multiplier in
the Anderson–Rubin test ($m$ stays the ledger's HAC bandwidth).

**Glossary terms (the 19 keys owned by L04; no new keys).**

- `instrument` — A variable used to isolate the variation in a regressor that
  is unrelated to the regression error; it identifies an effect only if it
  is relevant and valid.
- `external-instrument` — An instrument built outside the model from
  information such as narratives, forecasts, or high-frequency prices, rather
  than from the model's own lags; military news is one.
- `endogenous-regressor` — A right-hand variable correlated with the
  horizon-$h$ error, for example spending that reacts to the output shock, so
  that OLS mixes its effect with that reaction.
- `relevance` — The instrument moves the regressor conditional on the
  controls (A1); it is testable, and weakness is a matter of degree.
- `exogeneity` — The instrument is uncorrelated with every shock other than
  the one of interest, at every date, conditional on the controls
  (A2 and A3); it cannot be tested with the instrument alone.
- `exclusion-restriction` — The instrument affects the outcome only through
  the shock of interest; in the sandbox it fails when $\zeta_0\neq0$.
- `lead-lag-exogeneity` — The instrument is uncorrelated with past and
  future shocks (A3); lagged controls can restore it when they absorb the
  offending past shocks' effects on the future outcome and regressor.
- `first-stage` — The regression of the endogenous regressor (in a
  multiplier, accumulated spending) on the instrument and controls; its slope
  is the ratio's denominator.
- `reduced-form` — The regression of an outcome directly on the instrument
  and controls; its slope is the ratio's numerator.
- `two-stage-least-squares` — Replacing the endogenous regressor with its
  first-stage fitted value; with one instrument it equals the ratio of
  reduced form to first stage.
- `lp-iv` — A local projection in which the intervention variable is
  instrumented at each horizon; its estimand is $\beta^{\mathrm{IV}}_h$.
- `wald-ratio` — A reduced-form slope divided by a first-stage slope; the
  just-identified IV estimator written as a ratio.
- `weak-instrument` — An instrument whose first stage is small relative to
  its sampling noise, so that 2SLS is biased toward OLS, has heavy tails, and
  yields misleading Wald intervals.
- `robust-f-statistic` — The first-stage $F$ statistic computed with a
  heteroskedasticity- or autocorrelation-robust variance (here Kleibergen–Paap);
  it gauges relevance, not validity.
- `cumulative-multiplier` — Accumulated output response divided by
  accumulated spending response through $H$: dollars of output per dollar of
  spending.
- `one-step-multiplier` — $M_H$ estimated by one 2SLS regression of
  accumulated output on accumulated spending instrumented by $z_t$; its
  standard error is direct.
- `two-step-multiplier` — $M_H$ built by summing separately estimated
  horizon responses and dividing; its rows differ by horizon and it has no
  single standard error.
- `delta-method` — A first-order approximation to the variance of a smooth
  function of estimates; for a ratio it needs the covariance of numerator and
  denominator.
- `anderson-rubin-test` — A test of $M_H=M^{0}$ that regresses
  $\sum y-M^{0}\sum s$ on the instrument; its size holds however weak the
  instrument (a mention here, with further reading).

Earlier-owned terms used as ordinary prose, linked to their glossaries:
cumulative response, common sample, horizon-specific sample, shock
normalization, trend normalization (L2); identifying assumption, proxy,
predetermined control, Frisch–Waugh–Lovell (L3). HAC estimator and
Newey–West (L5) appear in a footnote with a forward link.

**Likely explanatory footnotes.** `ivreg2`'s automatic bandwidth (Newey–West
1994) and why bandwidth 29 means 28 Bartlett lags; the Kleibergen–Paap rk Wald
$F$ and its factor $(T_H-q)/T_H$; the Staiger–Stock rule of 10 and the
Montiel Olea–Pflueger effective $F$ with threshold 23.1, which `jordagk.do`
subtracts from the KP $F$; why a just-identified 2SLS estimator has no finite
mean; the local-average interpretation of IV when effects are heterogeneous;
the Gordon–Krenn normalization against an ex post $Y/G$ conversion (RZ
§III.B.1); present-value multipliers; SVAR-IV and invertibility as a
forward link to L7; `suest`'s $N/(N-1)$ scaling; L3's shelter first link
($t=0.346/0.314\approx1.10$, so $F=t^2\approx1.2$ from L3's rounded values,
no controls, $N=383$) beside the news impact first-stage $F$ of 7.3, both
below the rule of 10.

**Candidate figures** (TikZ/pgfplots through `figures/build.sh`; Lua reads
committed CSVs).

| Label | Question | Visible lesson | Data or formula |
|---|---|---|---|
| `fig-l04-first-stage-scatter` | Once lagged controls are removed, does news move two years of spending? | Slope 1.698 (reduced-form slope 1.127); most quarters sit at zero news; the caption names the episodes that carry the slope (1941Q4, 1950Q3, 1917Q2, labeled) | `l04_fwl_h7.csv`, 493 rows (stored Stata) |
| `fig-l04-responses` | How do output and spending respond to news, quarter by quarter? | Spending peaks at 0.366 ($h=11$), output at 0.294 ($h=10$); pointwise HAC bands | Benchmark CSV, IRF series |
| `fig-l04-ratio-of-reduced-forms` | Why is the multiplier a slope? | Each $H$ is the point $(\hat B^G_H,\hat B^Y_H)$ and $\hat M_H$ the slope of the ray through it; the caption notes that $H=0$ sits at $(0.039,0.051)$ near the origin, so the impact ray is fragile | `l04_linear.csv` |
| `fig-l04-multiplier-schedule` | What is the multiplier schedule? | $\hat M_H$ with pointwise band and $\tilde M_H$ overlaid; first-stage strength by horizon moves to the KP $F$ column of `tbl-l04-fiscal-ledger`, with 10 and 23.1 in its note | Benchmark CSV |
| `fig-l04-ratio-instability` | What happens to the ratio as the denominator weakens? | Five densities of $\hat M_8$ ($\sigma_\xi=0.5$–8): median toward OLS, tails exploding; share $\lvert\hat M\rvert>5$ annotated | `mc500_sxi{05,1,2,4,8}_z00.dta` ($R=500$, seed 4, StataNow/SE 19.5) |
| `fig-l04-lead-lag-controls` (droppable per D24; §6.5's table answers it) | Which lag restores lead–lag exogeneity? | $p=0$ biased (1.827), $p\ge1$ near the truth | `l04_leadlag_d2.dta` ($R=200$) |

**Exercise capabilities to test.** Derive the OLS bias, the Wald limits, and
the lag that restores lead–lag exogeneity; run LP-IV horizon by horizon with first stages and samples;
compare one-step and two-step estimates; compute a delta-method standard
error; reproduce REP04 with built-in commands; run a weak-instrument Monte
Carlo; handle units and horizon labels; write an instrument memo (§5).

**Candidate controlled experiments.** Move $\psi$ with the shocks fixed; move
along the reduced-form plane by $H$; weaken the instrument through
$\sigma_\xi$ under common seeds; toggle $\zeta_0$, $\zeta_1$, and $p$; switch
REP04 between common and varying rows (§7).

**What this session postpones.** Coverage and HAC theory (L5); joint bands and
the accumulated-response covariance (L6); state-dependent multipliers and the
difference test (L9, REP09 per D12); weak-IV-robust inference beyond the
glossary term and one footnote (Anderson–Rubin, effective-$F$ theory,
conditional tests as further reading); SVAR-IV and invertibility (L7);
heterogeneous effects and causal weights (L10); Blanchard–Perotti and
combined instruments (a footnote on RZ Table 1's other panels).

**Question handed to the next session.** The interval printed beside 0.664
is a statement about repeated samples. In the sandbox ($R=500$, seed 4) it covers
95.0 percent of the time with a clean instrument and 74.8 percent with a
contaminated one. What does a confidence band promise, and when does it keep
that promise?

---

## 2. Concept and notation ledger

All objects are scalars unless the table says otherwise. Section numbers refer
to the dependency chain.

| Symbol | Meaning | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|
| $z_t$ | External instrument: military news (REP04) or the sandbox instrument | dated $t$ | ratio to lagged nominal trend GDP; sandbox: sd $\sqrt{1+\sigma_\xi^2}$ | §2 | L9, L10, L13, L14 |
| $\mathbf w_t$ | Controls: constant and lags $1..p$ of $z,y,s$; $(3p+1)\times1$ | $t-1,\dots,t-p$ | components' units | §2 | all |
| $p$ | Lag length: 4 in REP04, 2 in the sandbox | — | quarters | §2 | L5, L7 |
| $\varepsilon_t$ | Spending shock of interest | $t$ | sd 1 (sandbox) | §2 | L7 |
| $v_t$ | Output shock the researcher never sees (L1's symbol, same role) | $t$ | sd 1 | §1 | L7 |
| $\xi_t$, $\sigma_\xi$ | Instrument noise and its scale; $\sigma_\xi$ sets strength | $t$ | $z$ units | §6 | labs 3–4, STA04 |
| $\psi$ | Contemporaneous loading of spending on $v_t$ (endogeneity) | $t$ | $s$ per unit $v$ | §1 | lab 1 |
| $\zeta_0$, $\zeta_1$ | Loadings of $z_t$ on $v_t$ (breaks A2) and on $v_{t-1}$ (breaks A3) | $t$, $t-1$ | $z$ per unit $v$ | §2, §8 | lab 4 |
| $\rho$, $\rho_s$ | Persistence of output and of spending | — | — | §1 | $\rho$ course-wide |
| $\theta_0$ | Impact response of spending on output | $t$ | $y$ per unit $s$ | §1 | L1 |
| $\theta^Y_h$, $\theta^G_h$ | Causal responses of output and spending to a unit $\varepsilon_t$ | $t+h$ | per unit $\varepsilon$ | §3 | L9 |
| $\pi$ | Impact first stage, $\operatorname{Cov}(s_t,z_t\mid\mathbf w_t)/\operatorname{Var}(z_t\mid\mathbf w_t)$; equals $\beta^G_0$ | $t$ | $s$ per unit $z$ | §3 | — |
| $\beta^Y_h$, $\beta^G_h$ | Reduced-form LP coefficients of $y_{t+h}$ and $s_{t+h}$ on $z_t$ | $t+h$ on $t$ | trend-GDP ratio per unit news | §3 | L9 |
| $\beta^{\mathrm{IV}}_h$ | LP-IV estimand $\beta^Y_h/\beta^G_0$: response per unit of impact spending | $t+h$ | $y$ per unit $s_t$ | §3 | L7 |
| $B^Y_H$, $B^G_H$ | $\sum_{h\le H}\beta^Y_h$, $\sum_{h\le H}\beta^G_h$; in population, the slopes of $\sum y$ and $\sum s$ on $z_t$ | $t..t+H$ | quarter-sums of trend-GDP ratios per unit news | §5 | L6, L9 |
| $M_H$ | Cumulative multiplier $B^Y_H/B^G_H$ | $t..t+H$ | dollars of output per dollar of spending | §5 | L9, L13, L14 |
| $\hat M_H$, $\tilde M_H$ | One-step 2SLS estimate; two-step ratio of horizon-specific sums | — | as $M_H$ | §5 | REP04, REP09, REP14 |
| $F_H$ | Kleibergen–Paap robust first-stage $F$ of the horizon-$H$ regression | — | — | §4 | L9 |
| $q$ | Instruments counted in the KP factor (excluded plus included, constant too): 14 in REP04 | — | count | §4 | — |
| $F^{\mathrm{pop}}_0$ | Population approximation to the impact first-stage $F$ in the sandbox | — | — | §6 | lab 3 |
| $M^{0}$ | Hypothesized multiplier in the Anderson–Rubin test (not $m$, the HAC bandwidth) | — | as $M_H$ | glossary | L14 |

Hats mark estimates; the ledger's $T_H$ is $500-H$ in REP04. The ledger
already reserves $\lambda$ (the L8 penalty) and $\eta_i$ (the L11 fixed
effect), so contamination is written $\zeta$ and the output shock $v_t$. The
planning do-files' names `lambda`, `eta`, and `nu` are renamed in every
course file.

## 3. Terminology ledger

Glossary treatment covers all 19 keys L04 owns and no others. The one-line
drafts in §1 are the glossary text; the column below is the short form used
in the key audit.

| Phrase | Key | One-sentence definition | First marked |
|---|---|---|---|
| endogenous regressor | `endogenous-regressor` | A regressor correlated with the horizon-$h$ error. | §1 |
| instrument | `instrument` | A variable that isolates the movement in a regressor unrelated to the error. | §1 |
| external instrument | `external-instrument` | An instrument built from information outside the model. | §2 |
| relevance | `relevance` | The instrument moves the regressor given the controls (A1). | §2 |
| exogeneity | `exogeneity` | The instrument is uncorrelated with all other shocks at all dates (A2–A3). | §2 |
| exclusion restriction | `exclusion-restriction` | The instrument affects the outcome only through the shock of interest. | §2 |
| lead–lag exogeneity | `lead-lag-exogeneity` | The instrument is uncorrelated with past and future shocks (A3). | §2 |
| reduced form | `reduced-form` | The regression of the outcome on the instrument and controls; the ratio's numerator. | §3 |
| first stage | `first-stage` | The regression of the regressor on the instrument and controls; the ratio's denominator. | §3 |
| Wald ratio | `wald-ratio` | A reduced-form slope divided by a first-stage slope. | §3 |
| two-stage least squares | `two-stage-least-squares` | Regression on the first-stage fitted value; with one instrument, the Wald ratio. | §3 |
| LP-IV | `lp-iv` | A local projection instrumented at every horizon. | §3 |
| robust F statistic | `robust-f-statistic` | A first-stage $F$ with a robust variance; it measures relevance only. | §4 |
| weak instrument | `weak-instrument` | An instrument whose first stage is too small for its noise, so 2SLS is biased toward OLS and heavy-tailed. | §4 |
| cumulative multiplier | `cumulative-multiplier` | Accumulated output response divided by accumulated spending response. | §5 |
| one-step multiplier | `one-step-multiplier` | $M_H$ from one 2SLS regression of $\sum y$ on $\sum s$ instrumented by $z_t$. | §5 |
| two-step multiplier | `two-step-multiplier` | $M_H$ from separately estimated responses, summed and then divided. | §5 |
| delta method | `delta-method` | A linear approximation to the variance of a function of estimates. | §5 |
| Anderson–Rubin test | `anderson-rubin-test` | A test of $M_H=M^{0}$ whose size does not depend on instrument strength. | §6 |

**Footnotes** (`.footnote-term`, local, section where each first appears):
HAC and Newey–West, keys owned by L5 (§4); the Kleibergen–Paap $F$ as
$t^2(T_H-q)/T_H$ (§4); the effective $F$ and the 23.1 threshold, RZ
footnote 18 (§4); why 2SLS has no finite moments (§6); the local average
effect, linked to L10 (§8); Gordon–Krenn normalization, RZ §III.B.1 (§7);
the present-value multiplier, RZ footnote 12 (§5); L3's shelter first link
($F\approx1.2$) beside the news impact $F$ of 7.3 (§3); SVAR-IV and
invertibility, key owned by L7 (§3).

**Ordinary prose, linked to the owning glossary:** cumulative response,
common and horizon-specific samples, trend and shock normalization (L2;
§5, §7); identifying assumption, proxy, predetermined control,
Frisch–Waugh–Lovell (L3; §2–3); coverage (L5; §10 only).

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| OLS on spending is not the IV multiplier | 0.487 (0.098) against 0.664 (0.067) at $H=7$; 0.164 against 1.306 at $H=0$ | prose, opening | `rz_l04_extract.log` | computed | `#sec-l04-endogenous-regressor` |
| Endogenous spending biases the impact slope | $\theta_0+\psi/(1+\psi^2)=1.2$ against 0.8 (§6.6) | equation | derivation | derived; numeric check in STA04 task 1 | `eq-l04-ols-bias` |
| Controls that absorb $(y_{t-1},s_{t-1})$ restore A3, so $p\ge1$ suffices | Mean $\hat M_8$ for $p=0,1,2,4$: 1.827, 1.534, 1.538, 1.536; limit 1.825 without controls and exactly the truth 1.552 at $p\ge1$ ($n=10^6$, $p=1$: 1.548312) | table (figure droppable) | `l04_leadlag_d2.dta`, $R=200$ | computed | `tbl-l04-lead-lag` |
| LP-IV is a ratio of two slopes | Residualized first stage 1.6985, reduced form 1.1273, ratio 0.6637 | figure | `l04_fwl_h7.csv` | computed | `fig-l04-first-stage-scatter` |
| One first stage per horizon | KP $F$ 7.33 ($h=0$), 19.57 ($h=5$), 10.43 ($h=20$) | table column | `l04_linear.csv` | computed | `tbl-l04-fiscal-ledger` |
| One-step equals the common-sample ratio | Maximum gap $5.663\times10^{-11}$ over 21 horizons | equation and exercise | `pilots/REP04-VALIDATION.md` | validated | `eq-l04-one-step-ratio` |
| The two-step ratio differs only through its rows | $H=20$: 0.729480 against 0.726344; two-step on common rows equals one-step within $1.8\times10^{-7}$ at $H=7,15$ | table | extract log; benchmark CSV | computed | `tbl-l04-fiscal-ledger` |
| The one-step s.e. carries the covariance | HC at $H=7$: 2SLS 0.07248, delta with covariance 0.07255 (ratio $\sqrt{N/(N-1)}$), without covariance 0.26574; correlation 0.940 | table and exercise | `l04_delta_detail.log` | computed | `eq-l04-delta` |
| The multiplier is a ray's slope; the impact point is fragile | $(\hat B^G_H,\hat B^Y_H)$ for $H=0..20$ | figure | `l04_linear.csv` | computed | `fig-l04-ratio-of-reduced-forms` |
| A weak denominator skews the ratio and fattens its tails | $\sigma_\xi=0.5\to8$: median $F$ 22.07 → 0.69; median $\hat M_8$ 1.567 → 1.633 (OLS median 1.693); share above 5 in absolute value 0 → 0.082 | figure | `mc500_sxi*_z00.dta`, $R=500$, seed 4 | computed (19.5) | `fig-l04-ratio-instability` |
| Relevance is not validity | $\sigma_\xi=1$, $\zeta_0=0\to0.3$: median $F$ 12.96 → 16.81; mean $\hat M_8$ 1.733 (limit 1.715); HC coverage 0.950 → 0.748. At $\sigma_\xi=0.5$: 22.07 → 27.98; mean 1.728; coverage 0.932 → 0.630 | table and lab 4 | `mc500_sxi{05,1}_z0{0,03}.dta`, $R=500$, seed 4 | computed (19.5) | `tbl-l04-relevance-validity` |
| Built-in commands reproduce the author's HAC | `ivregress 2sls, vce(hac bartlett bw-1)` equals `ivreg2, robust bw(auto)`: zero difference at 9 horizons; $F_H=t^2(T_H-14)/T_H$ exactly | footnote, STA04 | `l04_hac_check.csv` | computed at 9 horizons; the other 12 in the build | — |
| REP04 holds in 19.5 (D1) | Fresh author run against the 18.5 benchmark: zero difference at CSV precision, 21 coefficients and s.e. | practicum | `rz/fresh/junkmultse.csv` | computed | §8 |
| Output and spending responses | IRFs with pointwise HAC bands | figure | benchmark CSV | benchmarked | `fig-l04-responses` |

## 5. Assessment map

Ten exercises. Five use Stata ([computational]) and three use the Ramey–Zubairy data ([data]).

| Outcome | Exercise | Tags | Mode of work | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. Why output on spending is not a spending effect | [core] [pencil] | Derive the population impact slope in the sandbox with $p\ge2$ controls; repeat with $\psi=0$ | Residualize $s_t$ on $\mathbf w_t$ first: what remains? | $1.2$; $0.8$ when $\psi=0$ | 1 |
| 1 | 2. The Wald ratio and a contaminated instrument | [core] [pencil] | Derive $\pi$ and the limit of $\hat M_H$ with $\zeta_0$; evaluate at $H=8$, $\zeta_0=0.3$ | Which responses to $v_t$ enter $\operatorname{Cov}(\sum y,z)$? | 1.714767; independent of $\sigma_\xi$ | 4 |
| 1 | 3. Which lag restores lead–lag exogeneity | [core] [pencil] | Write $\sum y$ and $\sum s$ as a function of $(y_{t-1},s_{t-1})$ plus later shocks; predict $\hat M_8$ for $p=0,1,2$; compute the limit at $p=0$ | Through which variables does $v_{t-1}$ reach $y_{t+h}$ and $s_{t+h}$? | $p=1$ suffices (limit 1.551982); $v_{t-1}\in\operatorname{span}(y_{t-1},y_{t-2},s_{t-1})$ only at $p=2$, sufficient but not necessary; 1.824986 at $p=0$; §6.5 table | 4 |
| 2, 3 | 4. LP-IV horizon by horizon on one draw | [core] [computational] | On the shipped draw, loop $h=0..12$: $\hat\beta^Y_h$, $\hat\beta^G_h$, $\hat M_h$, $F_h$, $T_h$; assert that the common-sample ratio equals one-step | Build the accumulated variables so that each horizon loses a row | `assert` to $10^{-8}$; $H=8$: $\hat M=1.2033$, s.e. 0.2579, $F=10.79$, $\tilde M=1.1838$ (tolerance $5\times10^{-4}$) | 2 |
| 5 | 5. Reproduce REP04 with built-in commands | [core] [computational] [data] | `ivregress 2sls` with `vce(hac bartlett L)`, $L$ = author bandwidth − 1; compare all 21 rows; name the 2- and 4-year rows | A kernel bandwidth is not a lag count | $\le10^{-6}$ and $N$ exact; $H=7$: 0.6637145 (0.067114); $H=15$: 0.7133608 (0.0435753) | 5 |
| 3 | 6. Numerator, denominator, and rows | [computational] [data] | Common-sample reduced forms; two-step on varying rows; HC delta-method s.e. with and without covariance at $H=7$ | Save `e(sample)` from the IV regression and reuse it | 0.729480 against 0.726344; 0.07255, 0.26574, against 0.07248 | 5 |
| 4 | 7. A weak denominator | [computational] [extra] | $R=200$ (D26), $\sigma_\xi\in\{1,4\}$; median, 10th and 90th percentiles, share above 5, median $F$; compare with the instructor $R=500$ run | Decide in advance whether a mean is reportable | $\sigma_\xi=4$, $p=2$: median 1.609, p10 0.472, p90 2.939, $F$ 1.48 (instructor $R=500$, seed 4: 1.610, 0.579, 2.588, 1.54) | 3 |
| 4, 5 | 8. Units, normalization, horizon labels | [core] [pencil] | From $\hat B^Y_7$, $\hat B^G_7$ compute $\hat M_7$; rescale news ×100; compute $\hat\beta^Y_7/\hat\beta^G_0$ and interpret | Write each object's units before dividing | 0.663715; $\hat\beta,\hat B$ ÷100, $\hat M$ and $F$ unchanged; 5.2148 per unit of *impact* spending | 2 |
| 4, 5 | 9. Relevance is not validity: an instrument memo | [core] [pencil] | Classify six statements by A1–A3 and by testability; write a 250-word memo on military news | Can any dataset refute this statement? | Rubric; sandbox contamination numbers; RZ §II and §IV.B | 4 |
| 2 | 10. The robust $F$ and its thresholds | [computational] [data] | $F_H$ from the first-stage HAC $t$ at every $H$; list horizons below 10 and below 23.1; state what failing implies | Count $q$ before applying the factor | Zero gap against `e(widstat)`; below 10 at $h=0,1$; below 23.1 at all 21 horizons | 5 |

Every outcome is taught in at least two media. Outcome 1: §2–3 prose,
`eq-l04-ols-bias`, exercises 1–3, labs 1 and 4. Outcome 2: the first-stage
figure, exercises 4 and 10, lab 2. Outcome 3: `eq-l04-one-step-ratio`, the
fiscal ledger table, exercises 4 and 6, lab 5. Outcome 4: `ratio-instability`,
exercise 7, lab 3. Outcome 5: REP04, exercises 5, 8, and 9, lab 5.

## 6. Derivations to verify

**6.1 The LP-IV estimand** (`eq-l04-lp-iv`). *Source:* A1–A3 and the
unit-effect normalization $\theta^G_0=1$. *Steps:* write $y_{t+h}$ and $s_t$
as linear in current, past, and future shocks. Take conditional covariances
with $z_t$. By A2–A3, only the $\varepsilon_t$ terms survive, giving
$\operatorname{Cov}(y_{t+h},z_t\mid\mathbf w_t)=\theta^Y_h\alpha$ and
$\operatorname{Cov}(s_t,z_t\mid\mathbf w_t)=\alpha$ with $\alpha\neq0$ by A1.
Divide. For accumulated outcomes the same steps give
$B^Y_H\alpha/(B^G_H\alpha)=M_H$, and no normalization is needed. *Check:* in
the sandbox $\pi=1/(1+\sigma_\xi^2)=0.5$; at $n=10^6$ the estimate is
0.499707.

**6.2 Just-identified 2SLS is the Wald ratio** (`eq-l04-one-step-ratio`).
*Source:* Frisch–Waugh–Lovell (L3). *Steps:* residualize $\sum y$, $\sum s$,
and $z$ on $\mathbf w_t$ over the same rows. Then
$\hat M_H=\tilde z'\tilde Y/\tilde z'\tilde S$. Divide numerator and
denominator by $\tilde z'\tilde z$ to get the reduced-form slope over the
first-stage slope. *Check (worked example, REP04 $H=7$):* $\hat B^Y_7=1.12730557$ and
$\hat B^G_7=1.69847950$ give ratio 0.66371456, equal to `ivregress` 0.66371456.
Across all 21 horizons the pilot's maximum gap is $5.663\times10^{-11}$.

**6.3 Summing responses is linear only on common rows.** *Source:* OLS is
linear in the dependent variable for a fixed design matrix. *Steps:* with
identical rows and regressors, the slope of $\sum_{j\le H}y_{t+j}$ equals
$\sum_j$ of the slopes. Rows that change with $j$ break the identity.
*Check:* on common rows, the two-step and one-step estimates agree within
$1.8\times10^{-7}$ ($H=7$) and $1.6\times10^{-7}$ ($H=15$); the residual is
float accumulation. On varying rows at $H=20$, $3.5327487/4.8637385=0.726344$
while the one-step is $3.5495729/4.8658957=0.729480$ (D11).

**6.4 Sandbox truth.** $\theta^G_h=\rho_s^h$ and
$\theta^Y_h=\rho\,\theta^Y_{h-1}+\theta_0\theta^G_h$; for example
$\theta^Y_1=0.5(0.8)+0.8(0.7)=0.96$. Values are in §1. Mata and Python agree
to six decimals. *Check:* at $n=10^6$, $\hat M_8=1.549231$ against 1.551982.

**6.5 Contaminated and lead–lag limits** (`tbl-l04-lead-lag`). *Source:* the
model. *Steps:* (i) $\sum_{h\le H}y_{t+h}$ and $\sum_{h\le H}s_{t+h}$ are a linear
function of $(y_{t-1},s_{t-1})$ plus shocks dated $t$ or later. With $p\ge1$
the first part lies in $\mathbf w_t$ and is orthogonal to the residual
$\tilde z_t$ of $z_t$ on $\mathbf w_t$. The later shocks are orthogonal to
$\mathbf w_t$ and to $v_{t-1}$. Only $\varepsilon_t+\sigma_\xi\xi_t+\zeta_0v_t$
in $\tilde z_t$ therefore carries covariance, and $\zeta_1$ drops out at $p=1$.
Spanning $v_{t-1}=y_{t-1}-\rho y_{t-2}-\theta_0 s_{t-1}$ at $p\ge2$ is
sufficient but not necessary.
(ii) The response of $y$ to a unit $v_t$ is $\rho^h+\psi\theta^Y_h$, and of
$s$ it is $\psi\rho_s^h$. (iii) Take covariances:
$$\operatorname{plim}\hat M_H=\frac{B^Y_H+\zeta_0\big(\sum_{h\le H}\rho^h+\psi B^Y_H\big)}{B^G_H(1+\psi\zeta_0)}.$$
At $H=8$, $\zeta_0=0.3$: $(4.964512+0.3\times4.478350)/(3.198821\times1.15)=1.714767$.
With $p=0$, the numerator adds $\zeta_1\sum_{h\le H}(\rho^{h+1}+\psi\theta^Y_{h+1})$
and the denominator adds $\zeta_1\psi\sum_{h\le H}\rho_s^{h+1}$, giving 1.824986
at $\zeta_1=0.8$. *Checks:* at $n=10^6$ the estimates are 1.712404, 1.822406, and
1.549229 ($\zeta_1=0.8$, $p=2$). With $p=1$ on the same draws
(`l04_largen_p1.do`, `set seed 4`, $n=10^6$) the $\zeta_1=0.8$ estimate is
1.548312 (s.e. 0.00249) and the $\zeta_0=0.3$ estimate is 1.712402. An exact
projection on MA coefficients (`l04_ols_limit.py`) gives 1.551982 at $p=1$ and
$p=2$, 1.824986 at $p=0$, and 1.714767 for $\zeta_0=0.3$ at every $p$. The $R=200$ runs (means; design 4 medians,
because no mean exists):

| Design | $p=0$ | $p=1$ | $p=2$ | $p=4$ | HC coverage, $p=2$ | median $F$, $p=2$ |
|---|---|---|---|---|---|---|
| 1 baseline | 1.514 | 1.539 | 1.537 | 1.523 | 0.945 | 12.43 |
| 2 $\zeta_1=0.8$ | 1.827 | 1.534 | 1.538 | 1.536 | 0.950 | 12.44 |
| 3 $\zeta_0=0.3$ | 1.708 | 1.727 | 1.727 | 1.728 | 0.785 | 15.79 |
| 4 $\sigma_\xi=4$ | 1.644 | 1.602 | 1.609 | 1.597 | 0.975 | 1.48 |

**6.6 OLS impact bias** (`eq-l04-ols-bias`). The residual of $s_t$ on
$\mathbf w_t$ is $\varepsilon_t+\psi v_t$, with variance $1+\psi^2$. Then
$\operatorname{Cov}(y_t,\tilde s_t)=\theta_0(1+\psi^2)+\psi$, so the slope is
$\theta_0+\psi/(1+\psi^2)=1.2$. *Check:* 1.199469 at $n=10^6$. The cumulative
analogue at $H=8$ with $p\ge1$, OLS of $\sum y$ on $\sum s$, has limit 1.696316
from the MA coefficients (`l04_ols_limit.py`); $n=10^6$ with seed 4 gives
1.694716 (s.e. 0.00057).

**6.7 Delta method** (`eq-l04-delta`). *Source:* for $g(a,b)=a/b$, the
gradient is $(1/b,-a/b^2)$. *Steps:*
$\operatorname{Var}(\hat M)\approx[\operatorname{Var}\hat a-2M\operatorname{Cov}(\hat a,\hat b)+M^2\operatorname{Var}\hat b]/b^2$.
The combined influence function is
$(\tilde Y-\hat a\tilde z)-M(\tilde S-\hat b\tilde z)=\tilde Y-M\tilde S$,
because $\hat a=M\hat b$. That is the 2SLS residual, so the two sandwiches
coincide up to `suest`'s $N/(N-1)$ factor. *Check at $H=7$ (HC):* inputs
$\operatorname{Var}\hat a=8.39646\times10^{-2}$,
$\operatorname{Var}\hat b=2.71849\times10^{-1}$, and covariance
$1.42030\times10^{-1}$ give 0.0725502. The 2SLS s.e. is 0.0724766, and the
ratio 1.0010157 equals $\sqrt{493/492}$. Dropping the covariance gives
0.2657390, which overstates the s.e. 3.67 times; the factors at $H=0$ and
$H=20$ are 1.50 and 6.25.

**6.8 Units, normalization, robust $F$** (`eq-l04-units`). Replacing $z_t$
by $cz_t$ divides every $\beta$ and $B$ by $c$, leaves $M_H$ unchanged, and
leaves every $t$ and $F$ unchanged. The impact-normalized
$\hat\beta^Y_7/\hat\beta^G_0=0.20351917/0.039027371=5.21478$ is output per
unit of impact spending, not per accumulated dollar ($\hat M_7=0.66371$).
With one instrument, $F_H=t_H^2(T_H-q)/T_H$ with $q=14$. At $H=0$,
$7.54499\times486/500=7.33373$, equal to `e(widstat)`, and the gap is zero at
the nine horizons checked. `vce(hac bartlett L)` with $L=\text{bw}-1$
reproduces the `ivreg2` s.e. exactly.

**6.9 Population impact $F$ in the sandbox.**
$F^{\mathrm{pop}}_0\approx T_0\pi^2\operatorname{Var}(\tilde z)/\sigma^2_{\mathrm{fs}}$,
with $\pi^2\operatorname{Var}(\tilde z)=\pi$ and
$\sigma^2_{\mathrm{fs}}=1+\psi^2-\pi$. With $T_0=198$ and $\sigma_\xi=0.5,1,2,4,8$
this gives 352.0, 132.0, 37.7, 9.78, and 2.47. The seed-4 draws give 344.42
($\sigma_\xi=0.5$) and 135.02 ($\sigma_\xi=1$). *Worked sandbox example
(shipped CSV, re-imported):* $\hat M_8=1.203268$, s.e. 0.257922, $F=10.7886$,
$N=190$, two-step 1.183784.

## 7. HTML lab plan

`interactives/04-instrument-multiplier-lab.qmd`, "Instrument and Multiplier
Laboratory", holds five Observable JS labs. Each runs through setup, **Predict
before using the controls**, controls, display, reactive sentence, controlled
comparisons, and a collapsed explanation. Randomness comes from seeded
`mulberry32`, and changing a parameter never redraws the shocks. The default
sample is the shipped Stata draw, so browser and Stata work on the same
observations (blueprint §5.4). The build asserts that the JavaScript OLS and
2SLS reproduce §6.9's worked example to $10^{-6}$, using HC errors with no
degrees-of-freedom factor, as `vce(robust)` does. Every panel is labeled
"live calculation" or "stored result".

**Lab 1 — One sample, two slopes (live).** *Question:* why does OLS move
with $\psi$ while IV does not? *Held fixed:* $\varepsilon,v,\xi$; $s$ and $y$
are rebuilt from them. *Controls:* $\psi\in[0,1]$ ($s$ per unit $v$, default
0.5); $\sigma_\xi\in\{0.5,1,2,4\}$ (default 1); $H\in\{0..12\}$ quarters
(default 8). *Computation:* OLS and one-step IV with $p=2$, plus the true
$M_H$ and OLS's population limit, computed live from the MA-coefficient
projection of §6.6 (1.696316 at the defaults). *Reactive sentence (default,
shipped draw, seed 4):* "At $H=8$ OLS says 1.610 and IV 1.203, against a true
1.552. OLS's limit is 1.70, a bias of +0.14 that does not shrink with $T$;
IV's limit is the truth, and its miss here (−0.35, s.e. 0.26) is sampling
noise." *Comparisons:* $\psi\to0$; $\sigma_\xi$ from
1 to 4. *Handoff:* a CSV of `t eps v xi z s y` with a settings header, for
STA04 task 1.

**Lab 2 — Two reduced forms, one ray (live).** *Question:* why is the
multiplier a slope, and why is it fragile near impact? *Held fixed:* the
draw. *Controls:* $H$; common or varying rows. *Display:* the points
$(\hat B^G_h,\hat B^Y_h)$, the ray, and an $F_H$ strip. *Reactive sentence (shipped draw, seed 4):*
"At $H=8$ the ray's slope is 1.203 and the first-stage $F$ is 10.8; on
varying rows the ratio is 1.184." *Comparisons:* $H=0$ against $H=8$; the row
toggle. *Handoff:* a table of $H$, $T_H$, $\hat B$, $\hat M$, $\tilde M$, and
$F$, for task 2.

**Lab 3 — The small denominator (live Monte Carlo, stored overlay).**
*Question:* how does the ratio's distribution change as the instrument
weakens? *Held fixed:* seeds $1..R$, $\psi$, $\rho$, $\rho_s$, $\theta_0$,
$p=2$, $H=8$. *Controls:* $\sigma_\xi\in\{0.5,1,2,4,8\}$;
$R\in\{200,500\}$. *Display:* a histogram clipped at $\pm5$ with the clipped
count shown, and the Stata $R=500$ quantiles (seed 4) overlaid and labeled "stored Stata
result, $R=500$". *Reactive sentence (template; it names the live run):*
"With {R} replications (seeds 1..{R}), at $\sigma_\xi=4$ the median $F$ is
{F}. The median estimate, {median}, sits between the truth (1.55) and OLS's
limit (1.70), and {share} percent of estimates exceed 5 in absolute value, so
no mean should be reported." The Stata reference ($R=500$, seed 4) gives 1.54,
1.61, and 5.0 percent. *Comparisons:* $\sigma_\xi$ from 0.5 to 8; $R$ from 200 to 500.
*Handoff:* the design record (`rho rho_s theta0 psi sigma_xi T p H R seed`)
and the quantiles, for task 4. The comparison holds only within Monte Carlo
error because the random-number generators differ.

**Lab 4 — Relevance is not validity (live Monte Carlo).** *Question:* can a
stronger first stage come with a worse estimate? *Held fixed:* lab 3's seeds
and $\sigma_\xi=1$. *Controls:* $\zeta_0\in[0,0.5]$ (default 0);
$\zeta_1\in\{0,0.8\}$; $p\in\{0,1,2,4\}$. *Display:* the $F$ and $\hat M_8$
distributions, with §6.5's limit drawn live. *Reactive sentence (template; it names the live
run):* "With {R} replications (seeds 1..{R}) and $\zeta_0=0.30$, the median $F$
rose from {F0} to {F1} while the estimates centered on {median}, not 1.55: the
instrument got stronger and wrong." The Stata reference ($R=500$, seed 4)
gives 13.0 to 16.8 and a median of 1.74; the browser's values differ within
Monte Carlo error.
*Comparisons:* $\zeta_0$ from 0 to 0.3; $\zeta_1=0.8$ at $p=0$ against $p=2$.
*Handoff:* the settings and a memo template for exercise 9.

**Lab 5 — The fiscal ledger (stored result).** *Question:* what numerator,
denominator, rows, and first stage lie behind each published multiplier?
*Data:* the benchmark CSV and `l04_linear.csv`. *Controls:*
$H\in\{0..20\}$; one-step or two-step; threshold 10 or 23.1. *Reactive
sentence:* "At $H=7$, the paper's 2-year integral covering 8 quarters,
$1.1273/1.6985=0.664$ (HAC s.e. 0.067, 493 rows). $F=19.4$ clears 10 but not
23.1." *Handoff:* `rep04_spec.csv` (sample, controls, normalization,
bandwidth by horizon) for the REP04 compare script.

## 8. Practicum plan

### 8.1 REP04

*Target (D11):* Ramey–Zubairy Table 1, linear column, military news, full
sample. The objects are one-step cumulative IV multipliers with HAC s.e. and
$N$ for $h=0..20$; the two-step ratio is a teaching comparison. *Paper:*
*JPE* 126(2), 850–901, DOI 10.1086/696277; equation (3) on p. 864 and Table 1
on p. 871 of the frozen PDF (D31). *Code:* the February 2018 package,
`jordagk.do` of February 24, 2018. Defaults are at lines 29–41, import at 48,
normalization at 90–108, accumulation at 126–145, IRFs and two-step ratios at
253–386, one-step IV at 442–446, and the export to `junkmultse.csv` at 500.
*Data:* `RZDAT.xlsx`, sheet `rzdat`, April 7, 2016 update, 508 quarters.
*Kind:* exact numerical replication. *Benchmark*
(`REP04-linear-fiscal-multiplier.csv`, rounded here; $N=500-h$):
$h$: $\hat M_h$ (s.e.) — 0: 1.3065 (0.3517); 1: 1.0599 (0.2490); 2: 0.8469
(0.1732); 3: 0.7057 (0.1303); 4: 0.6801 (0.0997); 5: 0.6765 (0.0815); 6:
0.6772 (0.0735); 7: 0.6637 (0.0671); 8: 0.6690 (0.0588); 9: 0.6880 (0.0538);
10: 0.7065 (0.0527); 11: 0.7163 (0.0524); 12: 0.7193 (0.0511); 13: 0.7189
(0.0482); 14: 0.7173 (0.0450); 15: 0.7134 (0.0436); 16: 0.7096 (0.0442); 17:
0.7098 (0.0464); 18: 0.7153 (0.0499); 19: 0.7230 (0.0544); 20: 0.7295
(0.0594). *Tolerance:* $10^{-6}$ absolute on coefficients and s.e.; $N$
exact; common-sample ratio against IV at $10^{-8}$. *Runtime:* 13.631 s for
the 18.5 pilot and 9.73 s for the 19.5 author script. *D1:* the 19.5 author
run matches the 18.5 benchmark with zero difference at CSV precision, so no
software discrepancy row is expected; the build reruns the check and logs it.
*Departures:* (i) course code uses `ivregress 2sls, vce(hac bartlett L_h)`
with $L_h=28$ (27 at $h=11$–14) copied from `ivreg2`'s automatic bandwidth,
stored in `data/derived/rep04_bandwidths.csv`, with `ivreg2` optional (D4);
(ii) figures are course TikZ, not the MATLAB graphics; (iii) the two-step
ratio has no s.e.; (iv) the KP $F$ is not the paper's effective $F$ (§10).
*Redistribution (D5):* no license covers the data or the author code, so
neither `rzdat.xlsx` nor `jordagk.do` ships. `data/raw/get_data.do` fetches
both from the authors' public archive, verifies each SHA-256 against
`pilots/REP04/bundle-sha256.json` (`jordagk.do`: `25afd71a…6d81be8f`), and
stops with a message; `PROVENANCE.md` gives the manual route. The pilot's
`vendor/` copies of SSC `ivreg2` and `ranktest` do not ship. The course
`replicate.do` ships; it is rewritten with built-ins only, because the
pilot's version calls `ivreg2`. Running the unchanged author script is an
optional step that needs `ssc install ivreg2 ranktest` (D4). The lab project
mirrors the pilot's file roles, not its contents:
`check_inputs.do`, `replicate.do`, `compare.do`, `figures.do`, and
`expected/REP04.csv`.

### 8.2 STA04

1. *Horizon-specific `ivregress 2sls`* (`sta04_1_lpiv.do`, shipped draw,
   variables `t z s y`). Loop over $h=0..12$ running
   `ivregress 2sls F`h'.y (s = z) L(1/2).(y s z), vce(robust)` alongside OLS.
   Assert the impact IV equals $\hat\beta^Y_0/\hat\beta^G_0$ to $10^{-8}$.
   Output: `lpiv_sandbox.csv`.
2. *Cumulative quantities and normalization* (`sta04_2_cumulative.do`, RZ).
   Compute one-step, common-sample reduced forms, and two-step. Assert ratio
   = one-step ($10^{-8}$), benchmark ($10^{-6}$), and $\hat M$ unchanged when
   news is rescaled ×100. Output: `rep04_components.csv`.
3. *First stages and samples* (`sta04_3_firststage.do`). For each $H$:
   $T_H$, $\hat B^G_H$, HAC $t$, and $F_H$. Assert $F_H$ equals the value
   from `estat firststage` and $t^2(T_H-14)/T_H$ ($10^{-6}$); flag horizons
   below 10 and below 23.1. Outputs: `firststage.csv`,
   `fig_firststage.pdf`.
4. *A weakly estimated denominator* (`sta04_4_weak.do`, `global R 200`).
   Run $\sigma_\xi\in\{1,4\}$ with `postfile`. Assert the median $F$ exceeds
   10 at $\sigma_\xi=1$ and falls below 10 at $\sigma_\xi=4$, and the median
   $\hat M_8$ lies within 0.05 of 1.552 at $\sigma_\xi=1$. Output:
   `weak_mc.csv`.
5. *Strength against validity* (`sta04_5_validity.do`, $R=200$). Run
   $\zeta_0\in\{0,0.3\}$. Assert the median $F$ rises and the mean
   $\hat M_8$ departs from 1.552 by more than 0.1. Written comments state
   which assumption each result tests.

Starter layout: `master.do`, `code/`, `data/raw/get_data.do`,
`data/sim/l04_sandbox_seed4.csv` (course-generated, shipped), `tests/`,
`output/`. Target runtime under 5 minutes at $R=200$; one sandbox design took
9–11 s.

### 8.3 Handoff

Lab 1's CSV feeds task 1, lab 2's table task 2, lab 3's design record task 4,
and lab 5's `rep04_spec.csv` the REP04 comparison. Browser and Stata agree
exactly on the shipped draw; simulations agree only within Monte Carlo error.

### 8.4 Submission package

Per blueprint §4.2:

- a replication record with the target, versions, the 21-row comparison, and
  the departures;
- the Stata submission: `master.do`, logs, `.ster` files, figures, tests;
- an interpretation record covering estimand, A1–A3, units, uncertainty, and
  the instrument memo;
- an HTML lab record with predictions, settings, and exports.

## 9. Slides arc

1. **Title.** Lecture 4 — LP-IV and cumulative multipliers.
2. **Two answers at two years.** OLS 0.487 against IV 0.664.
3. **Why spending is endogenous.** The sandbox slope of 1.2 against a true 0.8.
4. **Three conditions.** A1–A3, conditional on $\mathbf w_t$.
5. **The lag that restores lead–lag exogeneity.** `tbl-l04-lead-lag`.
6. **LP-IV is a ratio.** `fig-l04-first-stage-scatter`.
7. **One first stage per horizon.** The KP $F$ column of `tbl-l04-fiscal-ledger`.
8. **From responses to a multiplier.** `fig-l04-ratio-of-reduced-forms`; one-step equals the common-row ratio.
9. **Why report the one-step s.e.** 0.0725 against 0.2657.
10. **The small denominator.** `fig-l04-ratio-instability`.
11. **Relevance is not validity.** $F$ up, estimate wrong.
12. **The fiscal anchor.** `fig-l04-multiplier-schedule`; the 2- and 4-year rows are $H=7$ and $H=15$.
13. **Lab, exercises, and Lecture 5's question.** What a band promises.

## 10. Open questions for the editor

1. **Acquisition route (D5, owner).** The only public source on record is a
   Google Drive link with a resource key. A scripted download may fail on
   Drive's confirmation page. Should a manual download plus SHA-256
   verification be the primary route?
2. **Which weak-instrument statistic.** RZ footnote 18 and Figure 4 use the
   Montiel Olea–Pflueger effective $F$ (`weakivtest`); `jordagk.do` line 446
   subtracts 23.1085 from the KP $F$. By the KP $F$, no linear horizon
   reaches 23.1 (the maximum is 19.57, at $h=5$). The options are to report
   the KP $F$ (reproducible with built-ins) and footnote the effective $F$,
   or to add `weakivtest` to D4's optional list.
3. **HAC lags in course code.** This brief hard-codes the author's
   per-horizon bandwidth so that REP04 is exact. Confirm, rather than a
   course rule such as $m=h$ (L5).
4. **Stored $R=2{,}000$ results.** Resolved: every design was rerun at
   $R=500$ in StataNow/SE 19.5 (seed 4, one command per design, about 16 s
   each), and the $R=2{,}000$ runs are no longer quoted.
5. **Coverage preview.** The handoff quotes sandbox coverage (0.950, 0.748; $R=500$),
   a Lecture 5 term. Is one labeled preview acceptable?
