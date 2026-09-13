# Lecture 08 brief — Smoothing and restrictions across horizons

Planning author's brief for `lectures/08-smoothing-and-restrictions/`,
`interactives/08-smoothing-workbench.qmd`, and
`practica/p08-smoothing-and-restrictions/`. Everything below was checked
against the course spine, the notation ledger, the terminology plan, the
blueprint (Sections 1, 4, 5, Lecture 8), the authoring guide, and the
Jordà–Taylor replication package run in a scratch copy on 13 September 2026
(StataNow/SE 19.5). Numbers quoted from the replication are the authors'
values as reproduced in that run unless marked "authors' log".

---

## 1. Session brief

**Opening situation.** A researcher regresses the change in the U.S.
unemployment rate on the federal funds rate, instrumented by the Romer–Romer
shock (Coibion–Gorodnichenko–Kueng–Silvia update), monthly 1985m1–2000m1,
with six lags of unemployment, PCE inflation, and the funds rate, at every
horizon from 0 to 48 months. The estimate is −0.11 percentage points at
impact, −0.31 at month 3, crosses zero at month 5, dips back below zero at
month 6, climbs unevenly to 1.01 at month 20, falls to 0.84 at month 21, peaks
at 1.22 at month 31, and drifts down to 0.18 by month 48. The forty-nine
coefficients are jointly different from zero (χ²(49) = 446.9). A referee asks
whether the early negative dip and the sawtooth between months 17 and 31 are
findings or noise. The estimator cannot answer: it treated every horizon as a
free parameter and has nothing to say about how neighbouring horizons relate.
Jordà and Taylor answer by assuming the answer. Their Figure 6b replaces the
forty-nine numbers with three — a peak height of 1.39 percentage points, a
peak month of 26.2, a width of 13.0 months — and the band shrinks everywhere.
The lecture asks what was bought and what was paid.

**Decision or empirical question.** What do we gain, and what do we assume,
when we tell the estimator that the response must have a particular shape? In
operational terms: when a paper reports a smooth response, which of its
features came from the data and which came from the restriction, and does the
reported band know the difference?

**Target student and prerequisites.** The Lecture 1–7 student: can build the
horizon-$h$ regression, argue identification (L3), run LP-IV and read a first
stage (L4), name an inference procedure (L5), and knows that a claim about
several horizons needs the cross-horizon covariance $\boldsymbol\Sigma$ (L6)
and that estimators targeting the same response can trade bias for variance
(L7). Needs: OLS with an added penalty (ridge), the delta method (L4), Stata
`nl`, `gmm`, and a first look at Mata for one supplied routine. No prior
exposure to splines is assumed; the B-spline is built from hat functions in
an exercise.

**Learning outcomes (five).** By the end, the student can

1. write the unrestricted local projection as an $(H+1)$-parameter estimator
   on a stacked, residualized design, and explain — with the conditional
   variance formula and the JT standard errors — why every free horizon is
   paid for in variance;
2. read and fit the Gaussian basis $\beta_h=a\exp\{-((h-b)/c)^2\}$: state the
   units and meaning of $a$, $b$, $c$, estimate them by nonlinear least
   squares on the stacked design (or by GMM when the intervention is
   instrumented), and compute the implied response path with its
   delta-method standard errors;
3. construct the Barnichon–Brownlees penalized B-spline estimator — basis,
   stacked regression, $r$-th difference penalty, $\lambda$ chosen by
   contiguous-block cross-validation — and say exactly what $\lambda\to0$ and
   $\lambda\to\infty$ return;
4. diagnose shape misspecification: list which shapes each restriction cannot
   represent, read a minimum-distance overidentification test of the shape,
   and predict what each estimator does when the truth has a second hump or
   a sign reversal;
5. explain why a restricted estimator's standard errors are conditional on
   the restriction, locate where a restricted band is narrow because of the
   assumption rather than the data, and write the "data or structure" memo
   that the blueprint's mastery requirement asks for.

**Anchor numerical or data example.**

*Empirical anchor (the monetary-unemployment anchor of the spine).*
Jordà–Taylor (2025, JEL 63(1)) Example 6, Figure 6a–b. Data file
`Example6_JointInference/data_fred.dta` (517 monthly rows, 1965m12–2008m12;
file dated 30 March 2023; JEL-Code commit `655696c1c576b7537c5a939d2c261f0a111ae663`,
CC0 1.0). Series and units, verified in the scratch run:

| Variable | Definition (verified) | Units |
|---|---|---|
| `urate` | FRED `UNRATE`, identical to the raw column | percent of labour force |
| `infl` | $1200\,\Delta\log(\texttt{PCEPI})$, matches to machine precision | annualized percent |
| `ffr` | FRED `FEDFUNDS`, identical to the raw column | percent |
| `RRCGShock` | Romer–Romer shock extended by Coibion, Gorodnichenko, Kueng and Silvia (2017); 355 non-zero of 478 non-missing; in-sample s.d. 0.135 | percentage points of the funds rate |

Estimation sample 1985m1–2000m1 (181 rows). Outcome
$y_{t+h}-y_{t-1}$ with $y$ = unemployment rate (the do-file's `urate_f\`h'`);
intervention $s_t=$ `ffr`; instrument $z_t=$ `RRCGShock`; controls
$\mathbf w_t$ = six lags each of `urate`, `infl`, `ffr`; $H=48$; every series
residualized on $(1,\mathbf w_t)$ before a joint GMM across horizons (two-step,
HAC Bartlett with 6 lags, instruments $z_t$ and six lags of $z_t$; $T_H=121$).
Units of $\beta_h$: percentage points of unemployment per percentage point
of the funds rate. Because $y_{t-1}$ is among the controls, the long-difference
outcome and the level outcome give the same $\beta_h$ (L2's same-regressor
equivalence; verified at $h=12$: difference $1.3\times10^{-14}$).

Benchmarks (authors' log, 15 July 2024, reproduced in the scratch run — see §8):
unrestricted $\hat\beta_h$ as quoted in the opening situation; joint test
$\chi^2(49)=446.89$; Gaussian basis $a=1.3875$ (0.2779), $b=26.189$ (0.922),
$c=12.997$ (0.891), $T_H=127$.

*Illustration anchor.* JT Example 3, `GBF.do`: the Gaussian basis with
$a=1,b=8,c=8$ on $h=0,\dots,30$ (JT Figure 3). Reproduced in 2 seconds; values
$\beta_0=0.3679$, $\beta_8=1$, $\beta_{16}=0.3679$.

*Simulation anchor (the course's own design; a Monte Carlo, never called a
replication).* Seed 8. $T=181$ (to match the empirical sample), $H=48$.
$s_t\sim\mathrm{iid}\,\mathcal N(0,1)$ observed; $v_t=\rho_v v_{t-1}+e_t$,
$e_t\sim\mathrm{iid}\,\mathcal N(0,1)$, $\rho_v=0.5$, burn-in 49 periods;
$y_t=\sum_{j=0}^{H}\theta_j s_{t-j}+v_t$. Controls $\mathbf w_t=y_{t-1}$.
Three true shapes:

| Shape | $\theta_h$ | What it tests |
|---|---|---|
| A, single hump | $1.4\exp\{-((h-26)/13)^2\}$ (the JT estimates, rounded) | the Gaussian basis is exactly right |
| B, two humps | $1.0\exp\{-((h-8)/5)^2\}+0.8\exp\{-((h-30)/8)^2\}$ | unimodality fails |
| C, sign reversal | $-0.5\exp\{-((h-3)/3)^2\}+1.2\exp\{-((h-26)/12)^2\}$ | single sign fails; the early dip of the empirical estimate is "real" |

Replications: $R=500$ in the instructor build, $R=200$ in the student problem
set; the notes report the instructor numbers and say which run they come from.
Estimators: unrestricted OLS by horizon; Gaussian basis by NLS on the stacked
design; penalized cubic B-spline with $r=2$, $\lambda$ by 5-fold contiguous
cross-validation on the grid of §6 (also at a fixed $\lambda=10T$ to separate
the tuning from the estimator).

**Smallest useful model (ledger notation).** The canonical projection

$$
y_{t+h}=\mu_h+\beta_h s_t+\boldsymbol\gamma_h'\mathbf w_t+u_{t,h},\qquad h=0,\dots,H,
$$

with the simulation DGP above, so that $\beta_h=\theta_h$ exactly (L3's A1–A3
hold by construction: $s_t$ is iid and observed). Partialling out
$(1,\mathbf w_t)$ horizon by horizon (L3, Frisch–Waugh–Lovell) gives the
stacked residualized form
$\tilde y_{t,h}=\beta_h\tilde s_t+\tilde u_{t,h}$, $t\in\mathcal T_h$, $h=0,\dots,H$,
with $\sum_h T_h$ rows. The three estimators are three choices of what
$\{\beta_h\}_{h=0}^{H}$ may be:

- unrestricted: $H+1$ free numbers;
- Gaussian basis: $\beta_h=g(h;a,b,c)=a\exp\{-((h-b)/c)^2\}$, three numbers;
- penalized spline: $\beta_h=\sum_{k=1}^{K}\delta_k b_k(h)$ with $K=H+4$
  cubic B-splines and the penalty $\lambda\|\mathbf D_r\boldsymbol\delta\|^2$.

Everything in the lecture can be said in this model, because $\theta_h$ is
chosen by the author and can be given a second hump or a sign change at will.

**Dependency chain of sections** (spine order preserved; titles refined).

1. `#sec-l08-free-parameters` — *The unrestricted local projection as $H+1$
   free parameters.* Stacking the residualized horizon regressions shows the
   estimator as a $(H+1)$-parameter regression whose coefficient at each $h$
   is estimated from its own $T_h$ rows; the conditional variance
   $\sigma^2_{u,h}/\sum_t\tilde s_t^2$ grows with $h$ in the JT application
   from 0.10 at $h=0$ to 0.63 at $h=48$, and nothing in the estimator relates
   $\beta_h$ to $\beta_{h+1}$ — freedom is variance.
2. `#sec-l08-gaussian-basis` — *A three-parameter response: the Gaussian
   basis.* Jordà–Taylor's $g(h;a,b,c)$: $a$ is the peak (units of $\beta$),
   $b$ the peak date (months), $c\sqrt{\ln 2}$ the half-width at half height;
   NLS on the stacked design, GMM with the instrument when $s_t$ is
   endogenous, and delta-method standard errors for the implied path that
   are conditional on the shape.
3. `#sec-l08-penalized-spline` — *Penalized B-splines: local flexibility with
   a roughness penalty.* Barnichon–Brownlees: $K=H+4$ cubic B-splines with
   knots at every horizon, the stacked regressor $\tilde s_t b_k(h)$, the
   $r$-th difference penalty, the closed form
   $\hat{\boldsymbol\delta}(\lambda)=(\mathbf X'\mathbf X+\lambda\mathbf D_r'\mathbf D_r)^{-1}\mathbf X'\tilde{\mathbf y}$,
   effective degrees of freedom, and $\lambda$ chosen by contiguous-block
   cross-validation; $\lambda\to0$ returns the unrestricted LP and
   $\lambda\to\infty$ a polynomial of degree $r-1$ in $h$.
4. `#sec-l08-what-restrictions-impose` — *What each restriction imposes.*
   The Gaussian basis is unimodal, single-signed, and symmetric about $b$;
   the spline is locally smooth and shrinks toward a line; a table of shapes
   each can and cannot draw, with the assumption anchors A1 (shape adequacy)
   and A2 (smoothness target).
5. `#sec-l08-misspecification` — *When the truth has a second hump or changes
   sign.* Seed-8 Monte Carlo under shapes A, B, C: what each estimator's mean
   path does and where its bias sits; the minimum-distance overidentification
   test of a shape, $Q_T\to\chi^2_{(H+1)-3}$, and what it can and cannot
   detect when $\hat{\boldsymbol\Sigma}$ is estimated from 121 rows.
6. `#sec-l08-uncertainty-after-restriction` — *Uncertainty after
   restriction.* The delta-method band is conditional on A1; in the JT
   application it is 19 percent as wide as the unrestricted band at $h=1$ and
   7 percent at $h=47$, exactly where the restriction ties the response to
   zero; a wrong restriction gives confident wrong answers.
7. `#sec-l08-evidence` — *Evidence: the unemployment response, twice.* JT
   Figure 6a–b reproduced with corrected horizon labels; the course's
   penalized-spline fit of the reduced-form response as a labelled
   instructional extension; the audit of the published figure's one-month
   offset.
8. `#sec-l08-summary` — *What the lecture built and what it leaves open.*
   Return to the referee; inventory the three estimators, the two assumptions,
   the test, and the memo; hand off to state dependence.

**Central notation.** $\beta_h,\hat\beta_h,\theta_h,\mu_h,\boldsymbol\gamma_h,u_{t,h},\mathcal T_h,T_h$
from ledger §1; $\hat{\boldsymbol\beta},\boldsymbol\Sigma,\alpha,\operatorname{se}(\cdot)$
from §4; $b_k(h),\delta_k,K,\lambda$ from §5. New in this lecture:
$g(h;a,b,c)$; $a,b,c$; $\tilde y_{t,h},\tilde s_t$; $\mathbf X$ (stacked
design); $\mathbf D_r$; $r$; $\operatorname{df}(\lambda)$; $Q_T$ and $J$;
$\rho_v$. See §2.

**Likely glossary terms (owned keys, plus three new).** Owned:
`unrestricted-lp`, `basis-function`, `gaussian-basis-function`, `b-spline`,
`penalized-regression`, `roughness-penalty`, `tuning-parameter`,
`cross-validation`, `shape-restriction`, `nonlinear-least-squares`,
`restricted-estimation`, `unimodality`. New: `effective-degrees-of-freedom`,
`minimum-distance`, `overidentification-test`. One-line drafts in §3.
Reused from earlier lectures as plain prose with links: local projection,
impulse-response function (L1); same-regressor equivalence, Monte Carlo
simulation, statistical reproduction (L2); partialling out, Frisch–Waugh–Lovell
(L3); LP-IV, Wald ratio, first stage, reduced form, delta method (L4);
HAC estimator, Newey–West (L5); cross-horizon covariance, stacked regression,
Wald test, joint hypothesis (L6); bias–variance tradeoff, mean squared error,
misspecification, shrinkage (L7 — never re-marked here).

**Likely explanatory footnotes.** (i) Why $K=H+4$: cubic B-splines on
$H+1$ unit intervals with knots at $-3,\dots,H+1$ give $(H+1)+3$ functions
(Eilers–Marx construction). (ii) `vce(hac nw)` without a lag count in Stata's
`gmm` uses $N-2$ lags, which is why JT's Gaussian-basis output reports a
Bartlett kernel with 179 lags on 127 observations. (iii) The half-width
reading of $c$: the response exceeds $a/2$ for $|h-b|<c\sqrt{\ln2}$. (iv)
Farebrother's partitioned ridge result, which is why the unpenalized
intercept and controls can be partialled out first and the penalized solve
needs only $K$ columns. (v) Starting values for `nl`/`gmm`: $a$ at the largest
$|\hat\beta_h|$, $b$ at its horizon, $c=H/4$. (vi) "P-spline" as the name for
a B-spline with a difference penalty. (vii) Why the stacked $\hat{\boldsymbol\Sigma}$
of 49 horizons from 121 rows is nearly singular (condition number
$8.9\times10^4$) and what that does to a quadratic form.

**Candidate figures** (all TikZ/pgfplots from a Lua data script via
`figures/build.sh`; SVG for HTML, PDF for LaTeX; caption above; alt text
describes the relationship).

| Label | Question it answers | Lesson visible | Generated from |
|---|---|---|---|
| `fig-l08-unrestricted-urate` | What do forty-nine free parameters look like? | Early negative dip, sawtooth 17–31, widening 68/95% bands; $\beta_0$ shown at $h=0$ (the published panel omits it) | `fig-l08-unrestricted-urate-data.lua`: $\hat\beta_h$ and HAC se from the scratch run's `gmm.ster`, $h=0,\dots,48$ |
| `fig-l08-gbf-anatomy` | What does each of $a$, $b$, $c$ do? | Peak height, peak date, half-width at half height annotated on JT's $a=1,b=8,c=8$ curve | formula in Lua (JT Figure 3 geometry, CEMFI slide 12 annotations) |
| `fig-l08-gbf-vs-unrestricted` | What changed when three numbers replaced forty-nine? | Smooth unimodal curve through the cloud; band narrow at both ends; $\hat\beta_1=-0.28$ outside the restricted band | Lua data: unrestricted path + Gaussian path and delta-method se from `gmmgbf.ster` (`nlcom` values) |
| `fig-l08-bspline-basis` | What is the spline built from? | Overlapping local bumps; $K=H+4$; a coefficient moves the curve only near its knot | formula in Lua: cubic B-splines for $H=12$ ($K=16$) so individual functions are legible; inset shows one $\mathbf D_2\boldsymbol\delta$ row |
| `fig-l08-penalty-path` | What does $\lambda$ do? | Four fits of the reduced-form unemployment response at $\lambda\in\{10^{-4},\lambda_{\mathrm{CV}},10T,10^{10}\}$; inset CV-MSE against $\lambda/T$ with the minimum marked | Lua data from the instructor build (`lp_spline`) — stored result |
| `fig-l08-misspecification` | What does each estimator do to a shape it excludes? | 3×3 small multiple: truth A/B/C (rows) versus OLS / Gaussian / spline (columns), MC mean path and pointwise 5–95% band, $R=500$, seed 8 | Lua data from the instructor build — stored simulation result |
| `fig-l08-se-ratio` | Where is the restricted band narrow, and why? | $\operatorname{se}^{\mathrm{GBF}}_h/\operatorname{se}^{\mathrm{OLS}}_h$ by horizon: 0.19 at $h=1$, 0.75 at $h=18$, 0.07 at $h=47$; the shape of $\partial g/\partial(a,b,c)$ explains the U | Lua data from the scratch run (`output.dta` columns after the index fix) |

**Exercise capabilities to test.** Count parameters and cost them in variance
(LO1); read $a,b,c$ into economics with units and compute the implied path by
hand (LO2); derive and evaluate the delta-method gradient at the peak and at
impact (LO2, LO5); fit the Gaussian basis two ways in Stata and assert
agreement (LO2); construct a degree-1 B-spline basis and the $\mathbf D_2$
penalty by hand and show the $\lambda\to\infty$ limit (LO3); implement and
unit-test the spline's two limits and the CV choice in Stata (LO3); run the
seed-8 Monte Carlo and locate bias (LO4); compute a minimum-distance
overidentification test on a three-horizon toy (LO4); write the data-or-
structure memo on JT Figure 6, including the horizon-offset audit (LO5); vary
the penalty order and knot spacing (LO3, extra).

**Candidate controlled experiments for the HTML lab** (Smoothing Workbench,
§7): (1) three sliders $a,b,c$ against the fixed unrestricted cloud —
which features can the three numbers reach? (2) one seed-8 draw of shape
A/B/C with $\sigma_e$, $T$, $\lambda$, $r$ as controls — the three fits and
their MSE against a known truth, draws held fixed across toggles; (3) the
delta-method band from the stored $3\times3$ covariance — where is it narrow
and which parameter's uncertainty is doing the work at each $h$; (4) the
overidentification check on the stored $\hat{\boldsymbol\beta},\hat{\boldsymbol\Sigma}$
with a horizon-subset selector — does the shape pass, and does the verdict
depend on how many horizons the covariance has to describe; (5) export a
shape, a $\lambda$, and the identical simulated observations to Stata.

**What this session deliberately postpones.** Bayesian shrinkage priors on
$\{\beta_h\}$ and MIDAS-type restrictions (spine); functional approximations
beyond one Gaussian bump (Barnichon–Matthes FAIR) as further reading; the
LPW "penalized LP" as one of many estimators between the two poles (L7 owns
that comparison); inference for the spline path (BB's bands) beyond a stated
caveat; penalized 2SLS.

**Question handed to the next session.** Every restriction here was imposed
across horizons for one economy. Is the response the same in a recession as
in an expansion — and what would "the same" even mean?

---

## 2. Concept and notation ledger

| Symbol | Meaning | Dimensions | Timing | Units | First use (section) | Later uses |
|---|---|---|---|---|---|---|
| $y_{t+h}$, $s_t$, $\mathbf w_t$, $\mu_h$, $\beta_h$, $\boldsymbol\gamma_h$, $u_{t,h}$ | canonical projection (ledger §1) | scalar; $\mathbf w_t$ is $p\times1$ with $p=18$ in JT (6 lags × 3 series), $1$ in the MC | row dated $t$ | $y$: pp of unemployment; $s$: pp of funds rate; $\beta_h$: pp per pp | 1 | all |
| $\theta_h$ | causal response; equals $\beta_h$ under L3 A1–A3; the MC's chosen truth | scalar per $h$ | — | pp per unit shock | 1 | 5 |
| $\mathcal T_h$, $T_h$ | horizon-$h$ estimation sample and size; JT: $T_h=175-h$ before instrument lags; common sample $T_H=127$ (GBF) or 121 (unrestricted, six lags of $z$) | — | — | rows | 1 | 3, 7, 8 |
| $\tilde y_{t,h}$, $\tilde s_t$ | outcome and intervention residualized on $(1,\mathbf w_t)$ within $\mathcal T_h$ (FWL) | scalar | row $t$, horizon $h$ | as $y$, $s$ | 1 | 2, 3 |
| $\hat{\boldsymbol\beta}$, $\boldsymbol\Sigma$, $\hat{\boldsymbol\Sigma}$ | stacked path and its cross-horizon covariance (ledger §4) | $(H+1)\times1$, $(H+1)^2$ | — | — | 1 | 5, 6 |
| $\sigma^2_{u,h}$ | $\operatorname{Var}(\tilde u_{t,h})$ | scalar | — | $y$-units² | 1 | 5 |
| $g(h;a,b,c)$ | Gaussian-basis response, $a\exp\{-((h-b)/c)^2\}$ (JT's $\psi(h)$, $\mathcal R(h;a,b,c)$) | scalar function of $h$ | — | as $\beta_h$ | 2 | 4–7 |
| $a$ | peak height | scalar | — | as $\beta_h$ (pp per pp) | 2 | 4–7 |
| $b$ | peak horizon (not the basis function $b_k(h)$ — see §10 Q1) | scalar | — | months | 2 | 4–7 |
| $c$ | width; $c\sqrt{\ln2}$ = half-width at half height | scalar | — | months | 2 | 4–7 |
| $\nabla g_h$ | gradient $(\partial g/\partial a,\partial g/\partial b,\partial g/\partial c)$ at $h$ | $3\times1$ | — | mixed | 2 | 6 |
| $\mathbf V$ | covariance of $(\hat a,\hat b,\hat c)$ | $3\times3$ | — | — | 2 | 6 |
| $\pi$, $\hat\pi$ | first-stage coefficient of $\tilde s_t$ on $\tilde z_t$ (ledger §3) | scalar | — | pp per pp | 7 | 8 |
| $b_k(h)$ | $k$-th cubic B-spline evaluated at $h$; knots at $-3,\dots,H+1$ | scalar; $\mathbf B$ is $(H+1)\times K$ | — | dimensionless | 3 | 4, 5 |
| $K$ | number of basis functions; $K=H+4=52$ | integer | — | — | 3 | 3, 6 |
| $\delta_k$, $\boldsymbol\delta$ | spline coefficients; $\beta_h=\sum_k\delta_k b_k(h)=(\mathbf B\boldsymbol\delta)_h$ | $K\times1$ | — | as $\beta_h$ | 3 | 4, 5 |
| $\mathbf X$ | stacked design, row $(t,h)$ and column $k$ equal to $\tilde s_t b_k(h)$ | $(\sum_hT_h)\times K$ | — | as $s$ | 3 | 3, 6 |
| $\mathbf D_r$ | $r$-th difference matrix | $(K-r)\times K$ | — | — | 3 | 4, 6 |
| $r$ | penalty order; course default 2 (shrinks toward a line); LPW use 3 | integer | — | — | 3 | 4, 6 |
| $\lambda$ | penalty (ledger §5); reported as $\lambda/T$ on the LPW grid | scalar $\ge0$ | — | — | 3 | 4–7 |
| $\operatorname{df}(\lambda)$ | effective degrees of freedom $\operatorname{tr}[(\mathbf X'\mathbf X+\lambda\mathbf D_r'\mathbf D_r)^{-1}\mathbf X'\mathbf X]$; $\operatorname{rank}(\mathbf X)=H+1$ at $\lambda\to0$, $r$ at $\lambda\to\infty$ | scalar | — | parameters | 3 | 5, 7 |
| $\operatorname{CV}(\lambda)$ | mean hold-out squared error over 5 contiguous blocks | scalar | — | $y$-units² | 3 | 7 |
| $Q_T(\boldsymbol\vartheta)$ | minimum-distance criterion $[\hat{\boldsymbol\beta}-\mathbf g(\boldsymbol\vartheta)]'\hat{\boldsymbol\Sigma}^{-1}[\hat{\boldsymbol\beta}-\mathbf g(\boldsymbol\vartheta)]$, $\boldsymbol\vartheta=(a,b,c)$ | scalar | — | — | 5 | 6, 7 |
| $J$ | $Q_T$ at its minimum; $J\to\chi^2_{(H+1)-3}$ under A1 | scalar | — | — | 5 | 7 |
| $\mathcal H_J$ | horizon subset on which the test is computed (every 6th horizon: 9 points, 6 d.o.f.) | set | — | — | 5 | 7 |
| $\rho_v$ | AR(1) persistence of the MC noise $v_t$ (distinct from the ledger's $\rho$, which is not used here) | scalar | — | — | 5 | 7 |
| $R$ | Monte Carlo replications (500 instructor, 200 student) | integer | — | — | 5 | 7, 8 |

Stata names in the lab project follow ledger §9: `y`, `s`, `z`, `w1`–`wp`,
`h`, `beta_h`, `se_h`; stacked long file has `t`, `h`, `ytil`, `stil`,
`bk1`–`bk52`; Gaussian parameters `a`, `b`, `c`; spline coefficients `delta`;
penalty `lambda`, order `r`.

---

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition (draft) | First marked occurrence |
|---|---|---|---|---|
| unrestricted local projection | glossary | `unrestricted-lp` | The horizon-by-horizon estimator that treats each $\beta_h$ as a free parameter estimated from its own rows; it imposes nothing across horizons and pays for that freedom in variance that grows with $h$. | §1 |
| shape restriction | glossary | `shape-restriction` | A constraint tying $\beta_0,\dots,\beta_H$ to fewer parameters or to a smoothness condition; it lowers variance where it is right and cannot be tested from inside the restricted model. | §1 (last paragraph) |
| restricted estimation | glossary | `restricted-estimation` | Estimating the response path subject to a shape restriction; the reported uncertainty is then conditional on the restriction being true. | §2 |
| basis function | glossary | `basis-function` | A known function of the horizon, $b_k(h)$, whose weighted sum represents the response; the weights, not the functions, are estimated. | §2 |
| Gaussian basis function | glossary | `gaussian-basis-function` | Jordà–Taylor's $a\exp\{-((h-b)/c)^2\}$: a single bump whose height, timing, and width are the only free parameters, so the path is unimodal, single-signed, and symmetric about $b$. | §2 |
| nonlinear least squares | glossary | `nonlinear-least-squares` | Minimizing the stacked sum of squared residuals over parameters that enter the fitted value nonlinearly, here $(a,b,c)$; Stata's `nl` or `gmm` with iid weights. | §2 |
| unimodality | glossary | `unimodality` | Having one peak; a unimodal restriction cannot represent a second hump or a rebound, so such features are absorbed into the single bump's height and width. | §4 (defined where the restriction table is) — first *use* in §2 is plain prose |
| B-spline | glossary | `b-spline` | A piecewise-polynomial basis function that is non-zero only over a few adjacent knot intervals; with knots at every horizon, cubic B-splines give $K=H+4$ local bumps. | §3 |
| penalized regression | glossary | `penalized-regression` | Least squares plus a penalty on the coefficients; the solution shrinks toward the penalty's null space and is linear in the data for a given $\lambda$. | §3 |
| roughness penalty | glossary | `roughness-penalty` | The term $\lambda\|\mathbf D_r\boldsymbol\delta\|^2$ that charges for $r$-th differences of neighbouring spline coefficients; it makes the fitted path smooth without saying where its peaks are. | §3 |
| tuning parameter | glossary | `tuning-parameter` | A quantity such as $\lambda$ (or $r$, or the knot spacing) that the researcher sets and the data do not identify; its choice is a modelling decision and should be reported. | §3 |
| cross-validation | glossary | `cross-validation` | Choosing a tuning parameter by hold-out prediction error; for time series the held-out sets are contiguous blocks so that neighbouring rows do not leak the answer. | §3 |
| effective degrees of freedom | glossary (new) | `effective-degrees-of-freedom` | The trace of the hat matrix of a penalized fit, $\operatorname{tr}[(\mathbf X'\mathbf X+\lambda\mathbf D_r'\mathbf D_r)^{-1}\mathbf X'\mathbf X]$; it counts the parameters the fit is effectively spending, from $H+1$ at $\lambda=0$ to $r$ as $\lambda\to\infty$. | §3 |
| minimum distance | glossary (new) | `minimum-distance` | Fitting a restricted path to an unrestricted estimate $\hat{\boldsymbol\beta}$ by minimizing $[\hat{\boldsymbol\beta}-\mathbf g(\boldsymbol\vartheta)]'\hat{\boldsymbol\Sigma}^{-1}[\hat{\boldsymbol\beta}-\mathbf g(\boldsymbol\vartheta)]$; it reuses the cross-horizon covariance of Lecture 6. | §5 |
| overidentification test | glossary (new) | `overidentification-test` | The minimized distance $J$, distributed $\chi^2_{(H+1)-q}$ if the $q$-parameter shape is correct; it asks whether the restricted path is consistent with the unrestricted one given the estimated covariance. | §5 |
| P-spline | footnote | — | Eilers–Marx name for a B-spline with a difference penalty. | §3 |
| $N-2$ HAC lags | footnote | — | Stata's `vce(hac nw)` default when no lag count is given. | §7 |
| half-width at half height | footnote | — | $c\sqrt{\ln 2}$. | §2 |
| partitioned ridge | footnote | — | Farebrother (1978): unpenalized blocks can be partialled out first. | §3 |
| conditional band, "narrow where assumed" | prose | — | — | §6 |
| data or structure | prose (the memo's name) | — | — | §6, §7 |
| shrinkage, misspecification, bias–variance tradeoff, MSE | prose with links to L7's glossary | — | — | §1, §5 |
| cross-horizon covariance, stacked regression, Wald test | prose with links to L6 | — | — | §1, §5 |
| delta method, LP-IV, Wald ratio, first stage, reduced form | prose with links to L4 | — | — | §2, §7 |
| partialling out, Frisch–Waugh–Lovell | prose with link to L3 | — | — | §1 |
| same-regressor equivalence, statistical reproduction, Monte Carlo simulation | prose with links to L2 | — | — | §1, §5, §7 |

---

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Best medium | Source | Asset status | Cross-reference |
|---|---|---|---|---|---|
| The unrestricted LP-IV path is jagged and its se grows from 0.10 to 0.63 across $h$ | 49 GMM coefficients and HAC se; $\chi^2(49)=446.89$ | figure + table row | scratch run of `GMM_LPIV_GBF_estimate_part1.do`; authors' log | `gmm.ster` reproduced in scratch; Lua data file to build | `fig-l08-unrestricted-urate`, `tbl-l08-jt-benchmark` |
| Each free horizon costs variance | $\operatorname{Var}(\hat\beta_h\mid\tilde s)=\sigma^2_{u,h}/\sum\tilde s_t^2$ on the stacked design | equation + MC sd | derivation D1; MC | derivation verified in §6; MC numbers from instructor build | `eq-l08-var-unrestricted` |
| Three numbers describe a hump | $g(h;a,b,c)$ anatomy: $\beta_0=0.024$, $\beta_{12}=0.421$, $\beta_{26}=1.387$, $\beta_{48}=0.083$; above $a/2$ on $[15.4,37.0]$ | figure + worked example | JT `gmmgbf.ster`; hand calculation | verified against `nlcom` (0.02392, 0.42129, 1.38722, 0.08301) | `fig-l08-gbf-anatomy`, `eq-l08-gbf` |
| JT's Gaussian fit: $a=1.388$ (0.278), $b=26.19$ (0.92), $c=13.00$ (0.89) | GMM, 98 moments, $T_H=127$ | table + figure | authors' log; scratch run | reproduced (see §8) | `tbl-l08-jt-benchmark`, `fig-l08-gbf-vs-unrestricted` |
| At the peak only $a$'s uncertainty matters; at impact the band is 2 basis points wide | delta method: se$_{26}=0.2796$ (hand: 0.27960), se$_0=0.0217$ | equation + figure | $\mathbf V$ from `gmmgbf.ster` | verified by hand against `nlcom` | `eq-l08-gbf-gradient`, `fig-l08-se-ratio` |
| The restricted band is 19% of the unrestricted at $h=1$, 75% at $h=18$, 7% at $h=47$ | ratio of se paths | figure | `output.dta` (index-corrected) | computed | `fig-l08-se-ratio` |
| The unrestricted $\hat\beta_1=-0.277$ (se 0.145) lies outside the Gaussian band; pointwise $\lvert z\rvert$ never exceeds 2.13 | $z_h=(\hat\beta_h-g_h)/\operatorname{se}_h$ | prose + figure annotation | computed from `bsel`, `Vsel` | computed | `fig-l08-gbf-vs-unrestricted` |
| Cubic B-splines with knots at every horizon give $K=H+4$ local bumps | basis construction | figure + footnote | Eilers–Marx `bspline` as ported by LPW | formula figure to build | `fig-l08-bspline-basis` |
| $\lambda\to0$ returns the unrestricted LP; $\lambda\to\infty$ with $r=2$ returns a line | max$_h\lvert\hat\beta^{\mathrm{sp}}_h(10^{-4})-\hat\beta^{\mathrm{OLS}}_h\rvert$ and second differences at $10^{10}$ | assertion + figure | prototype and Stata `lp_spline` | ⟦PENDING-A⟧ prototype values | `fig-l08-penalty-path`, Exercise 6 |
| CV picks $\lambda_{\mathrm{CV}}$ with df$(\lambda_{\mathrm{CV}})$ on the reduced-form unemployment response | 5-fold contiguous CV over the LPW grid | figure inset + table | prototype (Python) → instructor build (Stata/Mata) | ⟦PENDING-A⟧ | `fig-l08-penalty-path`, `tbl-l08-spline` |
| A unimodal restriction absorbs a second hump; a single-signed one cannot show the early dip | MC mean paths under B and C | figure + table | seed-8 MC | ⟦PENDING-MC⟧ prototype; instructor build at $R=500$ | `fig-l08-misspecification`, `tbl-l08-mc` |
| The spline follows a second hump at the cost of variance; its bias is local | MC | figure + table | seed-8 MC | ⟦PENDING-MC⟧ | same |
| The overidentification verdict depends on how many horizons $\hat{\boldsymbol\Sigma}$ must describe | $J$ = 346.4 (46 d.o.f.) on all 49 horizons with cond$(\hat{\boldsymbol\Sigma})=8.9\times10^4$; 59.0 (22) every 2nd; 19.6 (10, $p=0.033$) every 4th; 5.99 (6, $p=0.42$) every 6th; 4.28 (2, $p=0.12$) every 12th | table | `bsel_lpiv.csv`, `Vsel_lpiv.csv` from the authors' `gmm.ster` | computed | `tbl-l08-jtest-subsets`, Lab 4 |
| A three-horizon toy makes the test's mechanics visible | $\hat\beta=(0.2,0.5,0.8)$, se $=(0.1,0.1,0.2)$, flat restriction: $\hat\delta=0.4$, $J=9.0>\chi^2_{2,0.95}=5.99$ | worked example | hand + Python check | verified | Exercise 8 |
| The published Figure 6 plots horizons 1–48 at axis positions 0–47 | `replace bj = ... if _n == 0` never fires; `t=_n-1`; `b_gbf` loop runs $h=1..48$ into row $h$ | prose + discrepancy log | `GMM_LPIV_GBF_estimate_part1.do` lines 91, 145, 206; `output.dta` row $t=0$ holds $\hat\beta_1=-0.2771$ and $g(1)=0.0324$ | verified | §7, REP08 discrepancy guidance, Exercise 9 |
| The Gaussian GMM's HAC uses 179 lags | Stata default $N-2$ with $N=181$ dataset rows | footnote | authors' log line "Bartlett kernel with 179 lags" | verified | §7 |
| Reduced form ÷ first stage reproduces the LP-IV path up to the instrument set | $\hat\beta^{\mathrm{RF}}_h/\hat\pi$ vs JT GMM (which adds six lags of $z$ and two-step weights) | table | prototype | ⟦PENDING-A⟧ | `tbl-l08-wald`, STA08 Task 5 |
| Long-difference and level outcomes give the same $\beta_h$ here | L2 equivalence, checked at $h=12$: $1.3\times10^{-14}$ | assertion in `tests/checks.do` | `chk_infl.do` | verified | §1 footnote |

---

## 5. Assessment map

Ten exercises; four are Stata [computational] (4, 6, 7, 10). Every learning
outcome has evidence in prose plus at least one of figure/exercise/lab.

| LO | Exercise | Tags | Mode of work | Hint strategy | Solution check | Linked lab |
|---|---|---|---|---|---|---|
| 1 | 1 · *Count the parameters and cost them.* For the seed-8 design with shape A, write $\tilde u_{t,h}$ as a sum of the other horizons' shocks plus $v_{t+h}$, compute $\sigma^2_{u,h}$ at $h=0,26,48$ ($\sum_j\theta_j^2=31.9$; $\sigma_v^2/(1-\rho_v^2)=1.333$), and the implied se of $\hat\beta_h$ with $\sum\tilde s_t^2\approx T_h$; compare with the MC sd. | core, pencil | derivation → number → comparison | "Which shocks does row $t$ of horizon $h$ still contain after $s_t$ and $y_{t-1}$ are in the regression?" | numbers against `tbl-l08-mc`; common mistake: forgetting the past shocks that $y_{t-1}$ does not absorb | Lab 2 |
| 2 | 2 · *Read three numbers.* With $a=1.3875,b=26.189,c=12.997$: compute $\beta_h$ at $h=0,12,26,48$; find the months during which the response exceeds half its peak; say in one sentence each what $a$, $b$, $c$ mean, with units. | core, pencil | hand arithmetic → interpretation | "Write $(h-b)/c$ first; it is dimensionless." | matches `nlcom` (0.0239, 0.4213, 1.3872, 0.0830); window $[15.4,37.0]$ | Lab 1 |
| 2, 5 | 3 · *The band at the peak and at impact.* Derive $\nabla g_h$; show that at $h=b$ it equals $(1,0,0)'$ so se$_b=\operatorname{se}(\hat a)$; evaluate se$_{26}$ and se$_0$ with $\mathbf V$ (given as a table); explain what the band conditions on. | core, pencil | derivation → evaluation → interpretation | "Differentiate the exponent before the exponential; at $h=b$ the exponent's derivative vanishes." | 0.2796 and 0.0217 against `nlcom`; common mistake: dropping the cross terms of $\mathbf V$ | Lab 3 |
| 2 | 4 · *Fit the Gaussian basis two ways.* On the shipped seed-8 draw (shape A), build the stacked residualized file with `lp_stack`, fit $(a,b,c)$ by `nl` and by `gmm` with iid weights; assert agreement to $10^{-4}$; compute the path with `nlcom`; report the path's se at $h=0$ and at the peak. | core, computational (Stata) | implement → assert → interpret | "Start `nl` at $a=\max_h\lvert\hat\beta_h\rvert$, $b=\arg\max$, $c=12$; the objective is well behaved but $c$ must be positive." | `assert reldif(a_nl, a_gmm) < 1e-4`; shipped benchmark values in `tests/` | Lab 1, 5 |
| 3 | 5 · *A spline you can do by hand.* For $H=4$ and degree-1 B-splines (hat functions) with unit knots, write $\mathbf B$ ($5\times6$) and $\mathbf D_2$ ($4\times6$); show that $\mathbf D_2\boldsymbol\delta=\mathbf 0$ forces $\delta_k$ linear in $k$ and hence $\beta_h$ linear in $h$; compute $\beta_h$ for $\boldsymbol\delta=(0,1,2,3,4,5)$. | core, pencil | construction → algebra → check | "A hat function at knot $k$ is 1 at $h=k$ and 0 at the neighbours; so $\mathbf B$ is a selection of $\boldsymbol\delta$." | $\beta_h=h+1$; common mistake: miscounting $K$ | — |
| 3 | 6 · *The two limits of $\lambda$.* With the supplied `lp_spline` on the seed-8 draw: (i) at $\lambda=10^{-4}$ assert $\max_h\lvert\hat\beta^{\mathrm{sp}}_h-\hat\beta^{\mathrm{OLS}}_h\rvert<10^{-3}$; (ii) at $\lambda=10^{10}$ assert second differences $<10^{-6}$ and report the slope; (iii) run the CV and report $\lambda_{\mathrm{CV}}/T$ and $\operatorname{df}(\lambda_{\mathrm{CV}})$. | core, computational (Stata) | implement → assert → report | "The unrestricted OLS path must be computed on the same common sample as the stack." | assertions; df between 2 and 49 | Lab 2 |
| 4 | 7 · *Seed 8: a second hump and a sign change.* Run the shipped MC driver at $R=200$ for shapes B and C; tabulate bias and sd at $h=3,8,26,40$ for OLS, Gaussian, spline; explain where each estimator's bias sits and why the Gaussian bias under C is largest near $h=3$. | core, computational, data (Stata) | run → tabulate → interpret | "Plot the MC mean path over the truth before reading the table; the Gaussian fit cannot be negative anywhere if $\hat a>0$." | numbers against the instructor's $R=500$ table within MC error; log file must show seed 8 | Lab 2 |
| 4 | 8 · *Does the shape pass?* Three horizons, $\hat{\boldsymbol\beta}=(0.2,0.5,0.8)$, se $=(0.1,0.1,0.2)$, independent; restriction "flat"; compute $\hat\delta$ and $J$, compare with $\chi^2_2$; then read `tbl-l08-jtest-subsets` and explain why $J$ on 49 horizons is not the same test as $J$ on 9. | core, pencil | hand → reading → explanation | "With a diagonal $\hat{\boldsymbol\Sigma}$ the restricted estimate is a precision-weighted mean." | $\hat\delta=0.4$, $J=9.0$, reject at 5%; the 49-horizon $\hat{\boldsymbol\Sigma}$ has condition number $8.9\times10^4$ | Lab 4 |
| 5 | 9 · *Data or structure?* Using both panels of JT Figure 6 and the reproduced numbers: list five features (impact sign, early dip, peak month, symmetry of the decline, band width at $h=48$) and classify each as data-supported, imposed, or undetermined; include the horizon-offset audit as a presentation discrepancy. | core, data | reading → memo | "For each feature ask: could the Gaussian basis have produced anything else?" | model memo in the solution; rubric: each classification must cite a number | Lab 3, 4 |
| 3 | 10 · *The shrinkage target.* Rerun `lp_spline` on the reduced-form unemployment response with $r\in\{1,2,3\}$ and knots every 2 horizons; report $\lambda_{\mathrm{CV}}$, df, peak height and month; explain what changes as the null space of $\mathbf D_r$ changes. | extra, computational (Stata) | run → compare → explain | "$r=1$ shrinks toward a constant, $r=3$ toward a quadratic; look at the $\lambda\to\infty$ fit first." | table of results; no single right answer, but $\lambda\to\infty$ fits must match the stated polynomials | Lab 2 |

---

## 6. Derivations to verify

Each item names the source identity, the steps the notes will display, and
the numerical check. All checks below marked *verified* were run on 13
September 2026; ⟦PENDING⟧ items are filled from the runs listed in §8.

**D1. Stacked form and the variance of a free horizon** (`#eq-l08-stacked`,
`#eq-l08-var-unrestricted`). Source: the canonical LP and FWL (L3). Steps:
(i) partial out $(1,\mathbf w_t)$ from $y_{t+h}$ and $s_t$ within
$\mathcal T_h$; (ii) $\hat\beta_h=\sum_t\tilde s_t\tilde y_{t,h}/\sum_t\tilde s_t^2$;
(iii) conditional on $\tilde s$, $\operatorname{Var}(\hat\beta_h)=\sigma^2_{u,h}/\sum_t\tilde s_t^2$
when $\tilde u_{t,h}$ is homoskedastic and uncorrelated with $\tilde s$ (the
HAC version replaces the numerator by the long-run variance of
$\tilde s_t\tilde u_{t,h}$, L5); (iv) in the MC with $\mathbf w_t=y_{t-1}$,
$\tilde u_{t,h}$ contains $\sum_{j\ne h}\theta_j s_{t+h-j}$ (future shocks
for $j<h$, past shocks for $j>h$ not absorbed by $y_{t-1}$) plus $v_{t+h}$, so
$\sigma^2_{u,h}\approx\sum_{j\ne h}\theta_j^2+\sigma_e^2/(1-\rho_v^2)$.
Worked numbers (shape A): $\sum_j\theta_j^2=1.96\sum_h e^{-2(h-26)^2/169}=31.9$;
$\sigma^2_{u,26}=31.9-1.96+1.33=31.3$, se $\approx\sqrt{31.3/181}=0.42$;
$\sigma^2_{u,0}=33.2$, se $\approx0.43$. Check: MC sd of $\hat\beta_{26}$ and
$\hat\beta_0$ ⟦PENDING-MC⟧. Note for the notes: in this design the
variance profile is flat because past-shock content falls as future-shock
content rises; the JT profile (0.10 → 0.63) rises because eighteen controls
absorb the past.

**D2. Reading the Gaussian basis** (`#eq-l08-gbf`). Source: JT's
$\psi(h)=a\exp\{-((h-b)/c)^2\}$. Steps: $g(b)=a$; $g(h)=a/2\iff|h-b|=c\sqrt{\ln2}$;
symmetry $g(b+d)=g(b-d)$; sign of $g$ is the sign of $a$ for every $h$; one
stationary point. Worked example, exact inputs $a=1.387518$, $b=26.1893$,
$c=12.99661$: $(0-b)/c=-2.01509$, squared $4.0606$, $e^{-4.0606}=0.017237$,
$\beta_0=0.02392$; $\beta_{12}=0.4213$; $\beta_{26}=1.3872$;
$\beta_{48}=0.0830$; $c\sqrt{\ln2}=10.820$, window $[15.37,37.01]$.
*Verified* against `nlcom` (0.02392, 0.42129, 1.38722, 0.08301).

**D3. Delta-method band for the restricted path** (`#eq-l08-gbf-gradient`).
Source: delta method (L4). Steps: $\partial g/\partial a=e^{-((h-b)/c)^2}$;
$\partial g/\partial b=a\,e^{-(\cdot)}\,2(h-b)/c^2$;
$\partial g/\partial c=a\,e^{-(\cdot)}\,2(h-b)^2/c^3$;
$\operatorname{Var}(\hat g_h)=\nabla g_h'\mathbf V\nabla g_h$. Inputs:
$\mathbf V$ with $V_{aa}=0.077203$, $V_{bb}=0.850645$, $V_{cc}=0.793986$,
$V_{ab}=-0.157383$, $V_{ac}=0.221345$, $V_{bc}=-0.312063$. At $h=26$:
$\nabla g=(0.99979,-0.003109,0.0000453)'$, variance $0.078178$, se $0.27960$.
*Verified* (`nlcom` 0.27960). At $h=0$: se $0.02169$ (`nlcom`). Interpretation
line for the notes: at the peak the band is $\operatorname{se}(\hat a)$; at
impact it is two basis points because the shape forces the path to zero there.

**D4. The penalized spline in closed form** (`#eq-l08-penalized-objective`,
`#eq-l08-penalized-solution`). Source: BB (2019) as ported in LPW's
`locproj_partitioned.m`. Steps: objective
$\|\tilde{\mathbf y}-\mathbf X\boldsymbol\delta\|^2+\lambda\|\mathbf D_r\boldsymbol\delta\|^2$;
first-order condition; augmented-regression equivalence (append $\sqrt\lambda\mathbf D_r$
rows and zeros); $\hat\beta_h=(\mathbf B\hat{\boldsymbol\delta})_h$. Limits:
$\lambda\to0$ with $\operatorname{rank}\mathbf B=H+1<K$ gives fitted values
equal to the unrestricted OLS path (the horizon blocks separate);
$\lambda\to\infty$ forces $\mathbf D_r\boldsymbol\delta=0$, so $\delta_k$ is a
polynomial of degree $r-1$ in $k$ and, because uniform B-splines reproduce
polynomials of degree $\le3$, $\beta_h$ is a polynomial of degree $r-1$ in $h$.
Checks (prototype, reduced-form unemployment response, common sample of 127
rows × 49 horizons): $\max_h|\hat\beta^{\mathrm{sp}}_h(10^{-4})-\hat\beta^{\mathrm{OLS}}_h|=$ ⟦PENDING-A⟧;
second differences at $\lambda=10^{10}$ ⟦PENDING-A⟧. Stata `lp_spline` must
reproduce both as assertions.

**D5. Effective degrees of freedom** (`#eq-l08-edf`). Source: hat matrix of
a linear smoother. Steps: $\hat{\tilde{\mathbf y}}=\mathbf H(\lambda)\tilde{\mathbf y}$,
$\operatorname{df}(\lambda)=\operatorname{tr}\mathbf H(\lambda)=\operatorname{tr}[(\mathbf X'\mathbf X+\lambda\mathbf D_r'\mathbf D_r)^{-1}\mathbf X'\mathbf X]$;
at $\lambda\to0$ equals $\operatorname{rank}\mathbf X=49$, at $\lambda\to\infty$
equals $\dim\operatorname{null}(\mathbf D_r)=r$. Check: df at
$\lambda\in\{10^{-4},\lambda_{\mathrm{CV}},T,10T,100T,10^{10}\}$ ⟦PENDING-A⟧.

**D6. Contiguous-block cross-validation** (`#eq-l08-cv`). Source: LPW
`locproj_cv.m`. Steps: split $t=1,\dots,T$ into 5 contiguous blocks
(`chunks = ceil(5·t/T)`); for each block, rebuild the stacked design on the
remaining rows, fit at each $\lambda$, predict the held-out rows'
$\tilde y_{t,h}$ from $\tilde s_t b(h)'\hat{\boldsymbol\delta}$ using the
full-sample residualization, average the squared errors; choose the
minimizer. Grid: $\lambda/T\in\{0.001{:}0.005{:}0.021,\ 0.05{:}0.1{:}1.05,\ 2{:}1{:}19,\ 20{:}20{:}100,\ 200{:}200{:}2000\}$
plus $10^{-4}$ and $10^{10}$ (55 values). Check: $\lambda_{\mathrm{CV}}/T$ and
the CV curve's shape on the JT reduced form ⟦PENDING-A⟧; on the MC draws the
median $\lambda_{\mathrm{CV}}/T$ per shape ⟦PENDING-MC⟧.

**D7. Minimum distance and the overidentification statistic**
(`#eq-l08-md`, `#eq-l08-jstat`). Source: Jordà's two-step GBF (CEMFI
slides 7, 9): $\min_{\boldsymbol\vartheta}Q_T$; $J=Q_T(\hat{\boldsymbol\vartheta})\to\chi^2_{(H+1)-3}$.
Steps: Cholesky factor of $\hat{\boldsymbol\Sigma}^{-1}$ turns the problem into
NLS; degrees of freedom count. Toy check (hand and Python): flat restriction on
$(0.2,0.5,0.8)$ with se $(0.1,0.1,0.2)$: $\hat\delta=(20+50+20)/225=0.4$,
$J=4+1+4=9.0$, $\chi^2_{2,0.95}=5.99$. *Verified.* Empirical check with the
authors' $\hat{\boldsymbol\beta}$ and 49×49 HAC $\hat{\boldsymbol\Sigma}$: all
horizons $J=346.4$ (46 d.o.f.), $\hat a=1.426$ (0.157), $\hat b=26.93$ (0.56),
$\hat c=12.66$ (0.48); every 2nd horizon $J=59.0$ (22); every 4th $J=19.6$
(10, $p=0.033$); every 6th $J=5.99$ (6, $p=0.42$), $\hat a=0.956$ (0.427),
$\hat b=28.67$ (3.99), $\hat c=15.65$ (3.52); every 12th $J=4.28$ (2,
$p=0.12$); diagonal-weighted on all 49: $J_{\mathrm{diag}}=14.8$.
*Verified.* The notes present the every-6th version as the test and the
sequence as the caution.

**D8. Wald ratio versus JT's joint GMM** (`#tbl-l08-wald`). Source: L4,
$\beta^{\mathrm{IV}}_h=\operatorname{Cov}(\tilde y_{t,h},\tilde z_t)/\operatorname{Cov}(\tilde s_t,\tilde z_t)$.
Steps: reduced form $\hat\beta^{\mathrm{RF}}_h$ (OLS of $\tilde y_{t,h}$ on
$\tilde z_t$, common sample), first stage $\hat\pi$ (OLS of $\tilde s_t$ on
$\tilde z_t$, same rows), ratio. Check: $\hat\pi=$ ⟦PENDING-A⟧; ratio path
versus JT's GMM path (which adds six lags of $\tilde z$ as instruments and
uses two-step weights) ⟦PENDING-A⟧. The discrepancy is logged as
"specification: instrument set and weighting," not as an error.

**D9. Same-regressor equivalence for the JT outcome.** Source: L2. Check at
$h=12$: OLS of $f_{12}.\texttt{urate}-l.\texttt{urate}$ and of
$f_{12}.\texttt{urate}$ on `RRCGShock` and the 18 controls give
$0.43014988$ both times, difference $1.3\times10^{-14}$ (163 rows). *Verified.*

---

## 7. HTML lab plan (Smoothing Workbench, `interactives/08-smoothing-workbench.qmd`)

Five labs, each predict → manipulate → observe → explain → transfer. Shared
helpers come verbatim from `docs/templates/interactive.qmd` (`ols`, `invert`,
`hcSe`, `neweyWestSe`, `localProjection`, `mulberry32`, `gaussian`). New
lecture-specific functions, hidden from the student view: `gbf(h,a,b,c)`,
`gbfGradient`, `bsplineBasis(H, degree=3)`, `diffMatrix(K,r)`,
`ridgeSolve(X,y,lambda,D)` (normal equations on $K=52$ columns, solved with
`invert`), `blockCV`, `gaussNewtonGBF` (Levenberg–Marquardt, 3 parameters,
analytic Jacobian, 50 iterations, starting values as in footnote (v)), and
`minDistance(beta, SigmaInv, hsel)`. Every panel is labelled **live
calculation**, **stored result**, or **conceptual illustration**. Browser
NLS and ridge results are validated against Stata on the shipped seed-8 CSV
(tolerance $10^{-4}$ for NLS parameters, $10^{-8}$ for the ridge path);
the validation table lives in `practica/p08-.../build/`.

**Lab 1 — Three numbers, one curve.**
*Learning question:* which features of the unrestricted cloud can three
parameters reach? *Invariants:* the 49 unrestricted points and their 95%
bars (stored result from `gmm.ster`, plotted at the correct horizons).
*Controls:* $a$ (pp per pp; range $[-1,3]$, step 0.01, default 1.39),
$b$ (months; $[0,48]$, step 0.1, default 26.2), $c$ (months; $[1,40]$, step
0.1, default 13.0); a "snap to JT" button. *Computation:* live —
$g(h;a,b,c)$ for $h=0,\dots,48$; the sum of squared distances to the
unrestricted points, unweighted and precision-weighted. *Predict prompt:*
"If you double $c$, does the peak height change? Can any setting make the
curve negative at $h=1$?" *Reactive sentence:* "The curve peaks at
**{a}** pp in month **{b}** and stays above half its peak from month
**{b−c√ln2}** to **{b+c√ln2}**; the closest unrestricted point it cannot
reach is $h=1$ at −0.28, **{z}** unrestricted standard errors away."
*Comparisons:* (1) hold $a,b$, move $c$ — what happens at $h=0$ and $h=48$;
(2) set $a<0$ — the whole curve flips; (3) try to match both the early dip
and the peak. *Handoff:* `{a,b,c}` chosen, with the two prompts' answers.

**Lab 2 — Freedom is variance (and what a restriction buys).**
*Learning question:* on one draw with a known truth, which estimator is
closest, and does the answer change with the shape? *Invariants:* the
draw — `mulberry32(8)` generates $s_t$ and $e_t$ once per (T, seed); toggling
estimators, $\lambda$, $r$, or the shape reuses the same draws (the truth
changes the $y$ path but not the shocks). *Controls:* shape (A/B/C; default
A), $T\in\{120,181,360\}$ (default 181), $\sigma_e$ ($[0.25,2]$, default 1.0),
$\rho_v$ ($[0,0.9]$, default 0.5), $\log_{10}(\lambda/T)$ ($[-4,4]$, step
0.25, default: CV value), $r\in\{1,2,3\}$ (default 2), checkboxes for the
three fits, "new draw" (seed +1). *Computation:* live — 49 OLS projections
(`localProjection` with $y_{t-1}$ as control, HC1 se), Gauss–Newton Gaussian
fit on the stacked residualized design, ridge spline at the chosen $\lambda$,
5-block CV curve (55-point grid; recomputed only when $T$, shape, $\sigma_e$,
or $\rho_v$ change), MSE of each fitted path against the truth, df$(\lambda)$.
*Predict prompt:* "Under shape C, will the Gaussian fit be negative anywhere?
Which estimator will have the smallest error at $h=3$, and which at $h=26$?"
*Reactive sentence:* "On this draw the unrestricted path misses the truth by
**{rmse_ols}** on average, the Gaussian by **{rmse_gbf}**, the spline at
$\lambda/T=${λ/T} (df **{df}**) by **{rmse_sp}**; the largest Gaussian
error is at $h=${h*}, where the truth is **{θ}** and the fit is **{g}**."
*Comparisons:* (1) shape A: slide $\lambda$ from $10^{-4}T$ to $10^{4}T$ and
watch the fit move from the OLS path to a line; (2) shape B with the CV
$\lambda$ versus $\lambda=100T$; (3) shape C: compare the three fits at
$h\le5$; (4) $T=360$: which estimator improves most? *Handoff:* JSON with
shape, $T$, $\sigma_e$, $\rho_v$, $\lambda$, $r$, seed, predictions; plus a
CSV download of the $T+49$ draws of $(s_t,e_t)$ so Stata uses identical
observations (blueprint 5.4).

**Lab 3 — Where the band is narrow.**
*Learning question:* what does a restricted band condition on? *Invariants:*
the stored $3\times3$ covariance $\mathbf V$ from `gmmgbf.ster` and the
stored unrestricted se path (stored results, labelled). *Controls:* $h$
(slider 0–48, default 26); a toggle "scale $\mathbf V$ by $k$" ($k\in[0.25,4]$)
to show the band is proportional to the parameter uncertainty; a toggle
showing $\nabla g_h$ components. *Computation:* live — $\nabla g_h$,
$\operatorname{se}_h=\sqrt{\nabla g_h'\mathbf V\nabla g_h}$, the ratio to
the unrestricted se, a bar chart of the three gradient contributions.
*Predict prompt:* "At $h=b$, which parameter's uncertainty matters? At $h=0$?"
*Reactive sentence:* "At month **{h}** the restricted band is
**{ratio}×** the unrestricted band; **{share_a}%** of its variance comes
from $\hat a$, **{share_b}%** from $\hat b$, **{share_c}%** from $\hat c$
(cross terms **{share_x}%**). The band is narrow here because the shape,
not the data, fixes the path near **{g}**." *Comparisons:* (1) $h=26$ vs
$h=1$; (2) $h=18$ where the ratio peaks at 0.75; (3) scale $\mathbf V$ by 4
and confirm the ratio doubles everywhere. *Handoff:* the horizon at which the
student judges the band least trustworthy and one sentence why.

**Lab 4 — Does the shape pass?**
*Learning question:* is the Gaussian shape consistent with the unrestricted
estimate, and does the verdict depend on how many horizons the covariance
must describe? *Invariants:* stored $\hat{\boldsymbol\beta}$ (49) and
$\hat{\boldsymbol\Sigma}$ (49×49) from the authors' `gmm.ster` (stored
result). *Controls:* horizon subset (every 1st/2nd/4th/6th/12th; default
every 6th), weighting (full $\hat{\boldsymbol\Sigma}$ / diagonal), starting
values. *Computation:* live — Cholesky of the sub-covariance inverse, LM
minimum distance in $(a,b,c)$, $J$, degrees of freedom, $\chi^2$ p-value
(regularized incomplete gamma), condition number. *Predict prompt:* "Will
using all 49 horizons make the test more or less reliable?" *Reactive
sentence:* "On **{n}** horizons the distance-minimizing shape is
$a=${a}, $b=${b}, $c=${c}; $J=${J} on **{dof}** degrees of freedom
($p=${p}); the covariance's condition number is **{cond}**, so
**{verdict-sentence about whether the quadratic form is trustworthy}**."
*Comparisons:* (1) every 6th vs every 1st; (2) full vs diagonal weighting on
all 49; (3) drop $h\le5$ — does the rejection come from the early dip?
*Handoff:* the subset and weighting the student would report, and why.

**Lab 5 — Export a shape (transfer to Stata).**
*Learning question:* can Stata reproduce what the browser computed on the
same observations? *Controls:* pick a shape (A/B/C or the custom
$(a,b,c)$ from Lab 1 plus an optional second bump), $\lambda$, $r$, $T$,
$\sigma_e$, $\rho_v$. *Computation:* live restatement of the Lab 2 fits on
the chosen settings. *Export:* `handoff/p08-handoff.json` (settings,
browser estimates of $(a,b,c)$, the spline path at $\lambda$, df, the CV
$\lambda$, predictions) and `handoff/p08-draws.csv` (columns `t`, `s`, `e`).
STA08 Task 1 reads the CSV, rebuilds $y$, and asserts the Stata estimates
match the browser's to the stated tolerances; the reactive sentence lists
the three numbers the student must see again in Stata.

---

## 8. Practicum plan (REP08, STA08, HTML08 handoff)

### REP08 — Raw versus restricted responses

| Field | Value |
|---|---|
| Paper and version | Jordà and Taylor (2025), "Local Projections," *JEL* 63(1), 59–110; JEL-Code commit `655696c1c576b7537c5a939d2c261f0a111ae663` (the supplied `LP_JEL_Replication.zip` is identical per the replication manifest); CC0 1.0 |
| Exact target | Figure 6a (unrestricted LP-IV path with 68/95% HAC bands and the joint test) and Figure 6b (Gaussian-basis path with delta-method bands and the printed $a,b,c$); the numerical targets are the 49 coefficients and se, $\chi^2(49)$, and $(a,b,c)$ with se |
| Kind | **Exact numerical replication** (deterministic; no random draws) |
| Data and vintage | `Example6_JointInference/data_fred.dta`, dated 30 March 2023; FRED `UNRATE`, `PCEPI`, `FEDFUNDS` (monthly, 1965m12–2008m12) and `RRCGShock` (Coibion et al. 2017); sample 1985m1–2000m1 |
| Original script and lines | `GMM_LPIV_GBF_estimate_part1.do`: sample lines 34–35; outcome construction line 42; residualization lines 52–53 (outcome), 58 (treatment), 65 (instrument); unrestricted GMM system lines 78–87; storage of estimates line 91; joint test lines 97–107; save line 108; Gaussian GMM lines 125–137; `nlcom` path lines 144–145; `t` index line 206; save line 210. `GMM_LPIV_GBF_output_part2.do`: replay and test lines 13–15; Gaussian replay line 35; Figure 6a lines 52–67; Figure 6b lines 70–90 |
| Benchmark | Authors' log (15 July 2024): $\chi^2(49)=446.89$; $a=1.387518$ (0.2778542), $b=26.1893$ (0.9223044), $c=12.99661$ (0.8910589); $T_H=121$ (unrestricted), 127 (Gaussian). Instructor scratch run 13 Sept 2026: ⟦PENDING-STATA⟧ |
| Tolerance | Point estimates: relative $10^{-4}$ for $(a,b,c)$ and each $\hat\beta_h$; standard errors: relative $10^{-3}$; $\chi^2$: absolute 0.05. Differences beyond these on the same Stata version indicate a specification change, not numerical noise |
| Runtime | Part 1 ⟦PENDING-STATA⟧ in StataNow/SE 19.5 on a loaded machine; Part 2 under 5 seconds. The lab project ships the reproduced `gmm.ster` and `gmmgbf.ster` so students can run Part 2 immediately, and re-estimates in `rep08.do` behind a `global REESTIMATE 1` switch |
| Deliberate departures | (1) The course figure plots $\hat\beta_h$ and $g(h)$ at horizon $h$; the published panels plot horizon $h+1$ at axis position $h$ and omit $\hat\beta_0=-0.106$ (0.104) and $g(0)=0.024$, because `replace bj = _b[/b\`i'] if _n == \`i'` never fires for $i=0$ and `t=_n-1`. Logged as a *presentation* discrepancy (L14 taxonomy). (2) Bands are drawn at $z_{0.84}=1$ and $z_{0.975}=1.96$ exactly as JT do; the course labels them 68% and 95%. (3) The Gaussian GMM's HAC bandwidth (Stata default $N-2=179$ lags) is kept for the replication and noted; STA08 Task 5 re-estimates with 6 lags as a sensitivity. (4) Fonts: no Palatino/cmsy10 requirement |

*Discrepancy guidance for students.* Likely causes, in order: wrong sample
(the `drop if` lines run before residualization, so $T_H$ must be 121/127);
wrong instrument set (six lags of `rz` in the unrestricted system, none in the
Gaussian one); reading the figure's horizon axis literally; `gmm` starting
values for $(a,b,c)$ other than $(1,24,10)$ can converge to the same optimum
but slowly.

### STA08 — Stata problem set

Starter `starter/pset.do` with `TASK` markers; every task states its
deliverable and its assertion in `tests/checks.do`. Variables follow ledger §9.

**Task 1 · Construct and estimate (unrestricted versus the supplied Gaussian
routine).** Read `handoff/p08-draws.csv` (or the shipped
`data/raw/sim_seed8_shapeA.csv` if no handoff), rebuild $y_t$ from the
JSON's shape, `tsset`, and estimate $\hat\beta_h$, $h=0,\dots,48$, by
`regress` with `vce(hc1)`; then `lp_stack` (creates the long file with
`ytil`, `stil`, `h`) and `gbf_nl` (wraps `nl` with the footnote-(v) starting
values; posts $(a,b,c)$ and the `nlcom` path). *Assertions:* the 49 OLS
coefficients equal those from the stacked file's horizon-by-horizon
regressions ($10^{-8}$); `nl` $(a,b,c)$ match the browser's to $10^{-4}$;
`gbf_gmm` (iid weights) matches `nl` to $10^{-4}$. *Expected output:*
`output/task1_paths.dta`, figure `output/task1.pdf` (truth, OLS, Gaussian).

**Task 2 · Instructional extension: the penalized spline.** Apply
`lp_spline` (Mata: `bspline()`, `diffmat()`, ridge solve, `blockcv()`) to
the same stacked file at the CV $\lambda$; report $\lambda_{\mathrm{CV}}/T$,
df, and the path. *Assertions:* at $\lambda=10^{-4}$ the path equals the OLS
path within $10^{-3}$; at $\lambda=10^{10}$, $r=2$, the second differences
are below $10^{-6}$; df$(\lambda_{\mathrm{CV}})\in(2,49)$. *Expected output:*
`output/task2_spline.dta`, `output/task2_cv.pdf`.

**Task 3 · Diagnose: vary the tuning parameter.** Loop $\lambda/T$ over the
55-point grid; save the path, df, and CV-MSE at each; plot the penalty path
and the CV curve. *Assertion:* CV-MSE is minimized at the $\lambda$ that
`lp_spline` reports. *Expected output:* `output/task3_path.pdf`,
`output/task3_grid.dta`.

**Task 4 · Diagnose: a second hump and a sign reversal.** Run
`mc_shapes.do` at `global REPS 200`, `set seed 8`, shapes B and C; tabulate
bias and sd at $h=3,8,26,40$ for the three estimators; plot MC mean paths
over the truth. *Assertions:* the log records the seed and $R$; for shape C
the Gaussian mean path is $\ge0$ at every $h$ when $\hat a>0$ in every
replication (the routine records the sign); the OLS bias at every tabulated
$h$ is below $2\,\mathrm{sd}/\sqrt R$. *Expected output:* `output/task4_mc.dta`,
`output/task4.pdf`, a written interpretation in the do-file header.

**Task 5 · Interpret: the limits of the inference.** On the JT data:
(a) compute the Gaussian delta-method band and the unrestricted band and
report their ratio at $h=1,18,47$; (b) compute the minimum-distance
Gaussian fit and $J$ on every 6th horizon using the shipped
`data/raw/jt_beta_sigma.dta` (49×49, from the reproduced `gmm.ster`), then
on all 49, and explain the difference with the condition number; (c) re-run
the Gaussian GMM with `vce(hac nw 6)` and report how $(a,b,c)$ and their se
change; (d) write the data-or-structure memo (Exercise 9). *Assertions:*
ratio at $h=1$ between 0.15 and 0.25; $J$ on every 6th horizon between 4 and
8 with 6 d.o.f.; the memo file exists and names five features. *Expected
output:* `output/task5_bands.pdf`, `output/task5_memo.md`.

**Supplied routines (instructor development).** `ado/lp_stack.ado`,
`ado/gbf_nl.ado`, `ado/gbf_gmm.ado` (JT's system, with an `iid` option),
`ado/lp_spline.ado` + `ado/lp_spline.mata` (interface:
`lp_spline ytil stil, h(h) lambda(#|cv) r(2) knots(1) grid(default) folds(5)`;
returns `r(beta)` $49\times1$, `r(df)`, `r(lambda)`, `r(cv)` matrix),
`ado/gbf_md.ado` (minimum distance given `beta` and `Sigma` matrices and a
horizon list; uses `optimize()`), `mc_shapes.do`. Tests in `tests/checks.do`
exercise each routine on the seed-8 draw with the benchmark values stored in
`tests/benchmarks.dta` (from the instructor build).

### Data provenance and redistribution

`data/PROVENANCE.md`: `data_fred.dta` copied unchanged from JEL-Code commit
`655696c1…`, `Example6_JointInference/`, licence CC0 1.0 (repository
`LICENSE`); FRED series are U.S. government data (attribution: Federal
Reserve Bank of St. Louis, series UNRATE, PCEPI, FEDFUNDS, retrieved by the
authors on or before 30 March 2023); `RRCGShock` is the Coibion,
Gorodnichenko, Kueng and Silvia (2017, *JME*) extension of Romer and Romer
(2004), redistributed as part of the CC0 package with citation. Derived
files (`jt_beta_sigma.dta`, `sim_seed8_shape{A,B,C}.csv`, `benchmarks.dta`)
are generated by `build/` scripts and carry their generation date, Stata
version, and seed. The MC design is the course's own. The Barnichon–Brownlees
construction follows Li, Plagborg-Møller and Wolf's port (`lp_var_simul`,
`Estimation_Routines/LP_Penalize/`, MIT licence), re-implemented in Mata; no
MATLAB is required.

### Submission package

| Deliverable | Contents for P08 |
|---|---|
| Replication record | target (JT Fig 6a–b, commit, CC0), data vintage (30 Mar 2023), `rep08.log`, the numerical comparison table (49 coefficients, se, $\chi^2$, $(a,b,c)$ with se), the horizon-offset entry in the discrepancy log |
| Stata submission | `master.do`, logs, `output/*.dta`, five figures, `tests/checks.do` passing |
| Interpretation record | estimand (pp of unemployment per pp of the funds rate, $h\le48$), assumptions (L3/L4 identification; A1 shape adequacy; A2 smoothness target), units, uncertainty (which band conditions on what), limitations (the two tests' dependence on $\hat{\boldsymbol\Sigma}$) |
| Lab record | the five predictions, chosen settings, the Lab 4 subset and verdict, the memo paragraph |

---

## 9. Slides arc

1. **Title.** Smoothing and restrictions across horizons.
2. **Forty-nine free parameters.** JT Figure 6a at correct horizons; the referee's question.
3. **Freedom is variance.** The stacked design; se from 0.10 to 0.63; nothing links $h$ to $h+1$.
4. **Three numbers.** $a$, $b$, $c\sqrt{\ln2}$ on the anatomy figure; units.
5. **Estimating a shape.** NLS on the stack; GMM when instrumented; the delta-method band.
6. **What changed.** Figure 6b over 6a: $a=1.39$ (0.28), $b=26.2$ (0.9), $c=13.0$ (0.9); $\hat\beta_1$ outside the band.
7. **Local bumps and a roughness penalty.** The B-spline basis; $\lambda\|\mathbf D_2\boldsymbol\delta\|^2$; the closed form.
8. **Turning the dial.** Penalty path with the CV minimum; df from 49 to 2.
9. **What each restriction cannot draw.** The shape table (unimodal, single-signed, symmetric; smooth, toward a line).
10. **Seed 8.** The 3×3 misspecification panel; where each bias sits.
11. **Narrow where assumed.** The se-ratio U; conditional on A1.
12. **Does the shape pass?** $J$ on 9, 13, 25, 49 horizons; the condition number.
13. **Data or structure?** The five-feature memo on Figure 6.
14. **The question for Lecture 9.** Is the response the same in a recession?

---

## 10. Open questions for the editor

1. **Notation collision.** The Gaussian basis's peak horizon is $b$ in JT, in
   the replication output (`b0`), and in the spine's formula, while the ledger
   reserves $b_k(h)$ for basis functions. The brief keeps JT's $(a,b,c)$ and
   uses $b_k(h)$ only for the B-spline, with one disambiguating sentence.
   Alternative: rename the peak horizon $h^\star$ in prose and keep $b$ only in
   code. Decide before drafting.
2. **Is the Gaussian basis a "basis"?** It is one nonlinear three-parameter
   function, not a linear expansion $\sum_k\delta_k b_k(h)$. The notes will
   say so; the ledger's §5 wording ("Gaussian basis functions in JT") could be
   softened.
3. **Penalty order.** The brief sets $r=2$ (shrink toward a line) as the
   course default; LPW's port uses $r=3$ (`irfLimitOrder=2`). BB's own
   choice should be confirmed against the frozen REStat text and, if it
   differs, recorded as a deliberate departure.
4. **Do BB smooth the control coefficients?** The LPW port leaves intercept
   and controls horizon-specific and unpenalized; confirm against BB's
   original MATLAB before the notes describe "the" BB estimator.
5. **The 179-lag HAC.** Keep the authors' `vce(hac nw)` in REP08 (exact
   replication) and confine the 6-lag re-estimation to STA08 Task 5, or
   flag it in the notes' evidence section? The brief does both; the notes'
   footnote (ii) can be cut if the editor prefers the practicum to carry it.
6. **The horizon-offset finding.** The published Figure 6 is plotted one
   month off. The brief treats it as a presentation discrepancy to be logged
   and corrected in the course figure. Confirm that the notes may say so in
   print (with the do-file lines cited) and whether to notify the authors.
7. **The overidentification test in the notes.** Including it adds a
   subsection to §5 and a lab. It reuses L6's $\boldsymbol\Sigma$ and is the
   only formal diagnostic of a shape; but the all-horizon version is
   dominated by a near-singular covariance. The brief recommends including
   it with the every-6th-horizon version as the headline and the sequence as
   the caution. Editor to confirm scope.
8. **Which $\lambda$ scale to show.** LPW report $\lambda/T$; BB report
   $\lambda$. The brief uses $\lambda/T$ everywhere with one footnote.
9. **Spline on the JT data.** The penalized spline is applied to the
   reduced-form response (unemployment on the Romer shock) and divided by
   $\hat\pi$, because BB is an OLS estimator. It is labelled an instructional
   extension in §7 and STA08 Task 2. Editor to confirm it belongs in the
   notes' evidence section or only in the practicum.
10. **Runtime.** If Part 1 exceeds ten minutes in the classroom environment,
    ship the reproduced `.ster` files and make re-estimation optional (as the
    brief proposes). Confirm the policy.
11. **Reading versions.** Fix the page ranges for BB (2019, REStat 101(3),
    522–530; DOI 10.1162/rest_a_00778) and the smoothing section of JT (2025)
    before release; neither paper's PDF is in the local packages.
12. **Handbook collisions.** "Shrinkage," "misspecification," and "mean
    squared error" are L7's keys and appear often here as prose; if the
    handbook's index needs an entry for "shrinkage toward a polynomial,"
    decide whether L8 may add a footnote-term rather than a glossary term.
13. **Prototype numbers.** The spline/CV and Monte Carlo values in this
    brief come from a Python prototype of the Mata routine; the instructor
    build must regenerate them in Stata and they must agree to the stated
    tolerances before any appear in the notes.
