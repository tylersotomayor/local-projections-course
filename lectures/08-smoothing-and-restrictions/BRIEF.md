# Lecture 08 brief — Smoothing and restrictions across horizons

Planning author's brief for `lectures/08-smoothing-and-restrictions/`,
`interactives/08-smoothing-workbench.qmd`, and
`practica/p08-smoothing-and-restrictions/`. Everything below was checked
against the editor decisions (D1–D31), the course spine, the notation ledger,
the terminology plan, the blueprint (Sections 1, 4, 5, Lecture 8), and the
authoring guide. Replication numbers come from the validated REP08 benchmark
(Stata/SE 18.5), which the authors' stored `.ster` files and a 13 September
2026 StataNow/SE 19.5 replay of Part 2 match. Spline, cross-validation,
Wald-ratio, and Monte Carlo values are marked *Python prototype; the
instructor build regenerates them in Stata/Mata* (scratch `design-08/run2/`).

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
2. read and fit Jordà–Taylor's Gaussian response
   $\beta_h=a\exp\{-(h-h^\star)^2/c^2\}$, a three-parameter parametric family
   rather than a linear basis expansion (D21): state the
   units and meaning of $a$, $h^\star$, $c$, estimate them by nonlinear least
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
   assumption rather than the data (on a comparison that matches bandwidth,
   instruments, and sample), and write the "data or structure" memo
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

Benchmarks (REP08 benchmark CSV, Stata/SE 18.5, equal to the authors' 15 July
2024 log at printed precision — see §8): unrestricted $\hat\beta_h$ as quoted
in the opening situation ($T_H=121$); joint test $\chi^2(49)=446.89$;
Gaussian response $a=1.3875$ (0.2779), $h^\star=26.189$ (0.922), $c=12.997$
(0.891), $T_H=127$.

*Illustration anchor.* JT Example 3, `GBF.do`: the Gaussian basis with
$a=1,h^\star=8,c=8$ on $h=0,\dots,30$ (JT Figure 3). Reproduced in 2 seconds; values
$\beta_0=0.3679$, $\beta_8=1$, $\beta_{16}=0.3679$.

*Simulation anchor (the course's own design; a Monte Carlo, never called a
replication).* Seed 8. $T=181$ (to match the empirical sample), $H=48$.
$s_t\sim\mathrm{iid}\,\mathcal N(0,1)$ observed; $v_t=\rho_v v_{t-1}+\varepsilon^v_t$,
$\varepsilon^v_t\sim\mathrm{iid}\,\mathcal N(0,\sigma^2_{\varepsilon v})$ with $\sigma_{\varepsilon v}=1$ (not $e$, which the ledger reserves for shock size and exposure), $\rho_v=0.5$, burn-in 49 periods;
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
cross-validation on the 51-point grid of §6 (13 points in the Python
prototype), and at a fixed $\lambda=10T$ to separate the tuning from the
estimator.

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
- Gaussian response: $\beta_h=\mathcal G(h;a,h^\star,c)=a\exp\{-(h-h^\star)^2/c^2\}$, a parametric family (D21) with three numbers;
- penalized spline: $\beta_h=\sum_{k=1}^{K}\delta_k b_k(h)$ with $K=H+4$
  cubic B-splines and the penalty $\lambda\|\mathbf D_r\boldsymbol\delta\|^2$.

Everything in the lecture can be said in this model, because $\theta_h$ is
chosen by the author and can be given a second hump or a sign change at will.

**Dependency chain of sections** (spine order preserved; titles refined).

1. `#sec-l08-free-parameters` — *The unrestricted local projection as $H+1$
   free parameters.* Stacking the residualized horizon regressions shows the
   estimator as a $(H+1)$-parameter regression whose coefficient at each $h$
   is estimated from its own $T_h$ rows; the standard error
   $\sqrt{\sigma^2_{u,h}/\sum_t\tilde s_t^2}$ (JT report its HAC analogue) grows
   with $h$ in the JT application from 0.10 at $h=0$ to 0.63 at $h=48$, and nothing in the estimator relates
   $\beta_h$ to $\beta_{h+1}$ — freedom is variance.
2. `#sec-l08-gaussian-basis` — *A three-parameter response: the Gaussian
   basis.* Jordà–Taylor's $\mathcal G(h;a,h^\star,c)$, a parametric family rather than
   a linear expansion (D21): $a$ is the peak (units of $\beta$), $h^\star$
   the peak horizon (months), $c\sqrt{\ln 2}$ the half-width at half height;
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
   The Gaussian basis is unimodal, single-signed, and symmetric about $h^\star$;
   the spline is locally smooth and shrinks toward a line; a table of shapes
   each can and cannot draw, with the assumption anchors A1 (shape adequacy)
   and A2 (smoothness target).
5. `#sec-l08-misspecification` — *When the truth has a second hump or changes
   sign.* Seed-8 Monte Carlo under shapes A, B, C: what each estimator's mean
   path does and where its bias sits; the minimum-distance overidentification
   test of a shape, $Q_T\to\chi^2_{(H+1)-3}$, headlined on every sixth
   horizon, with the all-horizon sequence showing what a near-singular
   $\hat{\boldsymbol\Sigma}$ from 121 rows does to it (D27).
6. `#sec-l08-uncertainty-after-restriction` — *Uncertainty after
   restriction.* The delta-method band is conditional on A1. JT's own runs
   put the Gaussian band at 19 percent of the unrestricted width at $h=1$ and
   7 percent at $h=48$, but that ratio also mixes three other differences
   between the two GMM runs: 179 against 6 Bartlett lags (the authors' choice,
   D14), current `rz` against `rz` and six lags as instruments, and 127 against
   121 rows. On the matched pair of §6 D10 the band is 22 percent as wide at
   $h=1$, 13 percent at $h=48$, and 89 percent at its widest ($h=19$): still
   narrowest where the restriction ties the response to zero; a wrong
   restriction gives confident wrong answers.
7. `#sec-l08-evidence` — *Evidence: the unemployment response, twice.* JT
   Figure 6a–b replicated with corrected horizon labels (D14); one paragraph
   on the course's penalized-spline fit of the reduced-form response,
   labelled an instructional extension (D28); the published figure's
   one-month offset stated neutrally with the do-file lines cited (D14).
8. `#sec-l08-summary` — *What the lecture built and what it leaves open.*
   Return to the referee; inventory the three estimators, the two assumptions,
   the test, and the memo; hand off to state dependence.

**Central notation.** $\beta_h,\hat\beta_h,\theta_h,\mu_h,\boldsymbol\gamma_h,u_{t,h},\mathcal T_h,T_h$
from ledger §1; $\hat{\boldsymbol\beta},\boldsymbol\Sigma,\alpha,\operatorname{se}(\cdot)$
from §4; $b_k(h),\delta_k,K,\lambda$, and $a,h^\star,c,r$ (D20) from §5. New
in this lecture: $\mathcal G(h;a,h^\star,c)$; $\tilde y_{t,h},\tilde s_t$; $\mathbf X$
(stacked design); $\mathbf D_r$; $\operatorname{df}(\lambda)$; $Q_T$ and $J$;
$\rho_v$, $\varepsilon^v_t$, $\sigma_{\varepsilon v}$. See §2.

**Likely glossary terms (owned keys, plus three new).** Owned:
`unrestricted-lp`, `basis-function`, `gaussian-basis-function`, `b-spline`,
`penalized-regression`, `roughness-penalty`, `tuning-parameter`,
`cross-validation`, `shape-restriction`, `nonlinear-least-squares`,
`restricted-estimation`, `unimodality`. New: `effective-degrees-of-freedom`,
`minimum-distance`, `overidentification-test`, each added to
`terminology-plan.md` in the change that first marks it (D22). One-line
drafts in §3.
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
Bartlett kernel with 179 lags on 127 observations; the notes report it as the
authors' choice (D14) and take the lecture's se ratio from the matched 6-lag
run (§6 D10). (iii) The half-width
reading of $c$: the response exceeds $a/2$ for $|h-h^\star|<c\sqrt{\ln2}$. (iv)
Farebrother's partitioned ridge result, which is why the unpenalized
intercept and controls can be partialled out first and the penalized solve
needs only $K$ columns. (v) Starting values for `nl`/`gmm`: $a$ at the largest
$|\hat\beta_h|$, $h^\star$ at its horizon, $c=H/4$. (vi) "P-spline" as the name for
a B-spline with a difference penalty. (vii) Why the stacked $\hat{\boldsymbol\Sigma}$
of 49 horizons from 121 rows is nearly singular (condition number
$8.9\times10^4$) and what that does to a quadratic form. (viii) D23: the
notes report $\lambda/T$; BB's and LPW's $\lambda$ is $(\lambda/T)\times T$
(`LP_shrink_est.m` line 19), so $80T$ with $T=127$ is $\lambda=10{,}160$. (ix)
D20: JT's code calls the peak horizon `b` (`/b0`); the notes write $h^\star$.

**Candidate figures** (all TikZ/pgfplots from a Lua data script via
`figures/build.sh`; SVG for HTML, PDF for LaTeX; caption above; alt text
describes the relationship).

| Label | Question it answers | Lesson visible | Generated from |
|---|---|---|---|
| `fig-l08-unrestricted-urate` | What do forty-nine free parameters look like? | Early negative dip, sawtooth 17–31, widening 68/95% bands; $\beta_0$ shown at $h=0$ (the published panel omits it) | `fig-l08-unrestricted-urate-data.lua`: $\hat\beta_h$ and HAC se from the authors' stored `gmm.ster` (equal to the REP08 benchmark), $h=0,\dots,48$ |
| `fig-l08-gbf-anatomy` | What does each of $a$, $h^\star$, $c$ do? | Peak height, peak horizon, half-width at half height annotated on JT's $a=1,h^\star=8,c=8$ curve | formula in Lua (JT Figure 3 geometry, CEMFI slide 12 annotations) |
| `fig-l08-gbf-vs-unrestricted` | What changed when three numbers replaced forty-nine? | Smooth unimodal curve through the cloud; band narrow at both ends; $\hat\beta_1=-0.28$ outside the restricted band | Lua data: unrestricted path + Gaussian path and delta-method se from the authors' stored `gmmgbf.ster` (`nlcom` values; REP08 benchmark rows) |
| `fig-l08-bspline-basis` | What is the spline built from? | Overlapping local bumps; $K=H+4$; a coefficient moves the curve only near its knot | formula in Lua: cubic B-splines for $H=12$ ($K=16$) so individual functions are legible; inset shows one $\mathbf D_2\boldsymbol\delta$ row |
| `fig-l08-penalty-path` | What does $\lambda$ do? | Four fits of the shipped seed-8 shape-B draw at $\lambda\in\{10^{-4},\lambda_{\mathrm{CV}},10T,10^{10}\}$ over the truth; inset CV-MSE against $\lambda/T$ with the minimum marked (simulated data, D28) | Lua data from the instructor build (`lp_spline`) — stored result |
| `fig-l08-misspecification` | What does each estimator do to a shape it excludes? | 3×3 small multiple: truth A/B/C (rows) versus OLS / Gaussian / spline (columns), MC mean path and pointwise 5–95% band, $R=500$, seed 8 | Lua data from the instructor build — stored simulation result |
| `fig-l08-se-ratio` | Where is the restricted band narrow, and why? | Matched ratio $\operatorname{se}^{\mathrm{GBF}}_h/\operatorname{se}^{\mathrm{OLS}}_h$ (§6 D10: 6 HAC lags, `rz` and six lags, 121 rows) by horizon at corrected horizons: 0.23 at $h=0$, 0.22 at $h=1$, a maximum of 0.89 at $h=19$, 0.13 at $h=48$; the authors' reported ratio (0.21 at $h=0$, 0.19 at $h=1$, a maximum of 0.75 at $h=19$, 0.07 at $h=48$) as a second, labelled line whose caption lists its three confounds — 179 against 6 Bartlett lags, current `rz` against `rz` and six lags, 127 against 121 rows (D14); the shape of $\partial\mathcal G/\partial(a,h^\star,c)$ explains the inverted U | Lua data: unrestricted `standard_error` by `horizon` from the REP08 benchmark CSV; authors' Gaussian se from `gmmgbf.ster` ($h=0$ from $\mathbf V$); matched Gaussian se from `gmmgbf_nw6.ster` (instructor build, §6 D10) |

**Exercise capabilities to test.** Count parameters and cost them in variance
(LO1); read $a,h^\star,c$ into economics with units and compute the implied path by
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
§7): (1) three sliders $a,h^\star,c$ against the fixed unrestricted cloud —
which features can the three numbers reach? (2) one seed-8 draw of shape
A/B/C with $\sigma_{\varepsilon v}$, $T$, $\lambda$, $r$ as controls — the three fits and
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
| $\mathcal G(h;a,h^\star,c)$ | Gaussian response $a\exp\{-(h-h^\star)^2/c^2\}$: a three-parameter parametric family, not a linear basis expansion (D21; JT's $\psi(h)$, $\mathcal R(h;a,b,c)$); calligraphic because the ledger reserves $g_i$ for the cohort and Lectures 2, 4, 14 use $g_t$ for spending | scalar function of $h$ | — | as $\beta_h$ | 2 | 4–7 |
| $a$ | peak height | scalar | — | as $\beta_h$ (pp per pp) | 2 | 4–7 |
| $h^\star$ | peak horizon (ledger §5, D20); `b` (`/b0`) only when quoting JT code | scalar | — | months | 2 | 4–7 |
| $c$ | width; $c\sqrt{\ln2}$ = half-width at half height | scalar | — | months | 2 | 4–7 |
| $\nabla\mathcal G_h$ | gradient $(\partial\mathcal G/\partial a,\partial\mathcal G/\partial h^\star,\partial\mathcal G/\partial c)$ at $h$ | $3\times1$ | — | mixed | 2 | 6 |
| $\mathbf V$ | covariance of $(\hat a,\hat h^\star,\hat c)$ | $3\times3$ | — | — | 2 | 6 |
| $\pi$, $\hat\pi$ | first-stage coefficient of $\tilde s_t$ on $\tilde z_t$ (ledger §3) | scalar | — | pp per pp | 7 | 8 |
| $b_k(h)$ | $k$-th cubic B-spline evaluated at $h$; knots at $-3,\dots,H+1$ | scalar; $\mathbf B$ is $(H+1)\times K$ | — | dimensionless | 3 | 4, 5 |
| $K$ | number of basis functions; $K=H+4=52$ | integer | — | — | 3 | 3, 6 |
| $\delta_k$, $\boldsymbol\delta$ | spline coefficients; $\beta_h=\sum_k\delta_k b_k(h)=(\mathbf B\boldsymbol\delta)_h$ | $K\times1$ | — | as $\beta_h$ | 3 | 4, 5 |
| $\mathbf X$ | stacked design, row $(t,h)$ and column $k$ equal to $\tilde s_t b_k(h)$ | $(\sum_hT_h)\times K$ | — | as $s$ | 3 | 3, 6 |
| $\mathbf D_r$ | $r$-th difference matrix | $(K-r)\times K$ | — | — | 3 | 4, 6 |
| $r$ | penalty order; course default 2, toward a line (D23); LPW's port uses 3 (§8) | integer | — | — | 3 | 4, 6 |
| $\lambda$ | penalty (ledger §5); reported as $\lambda/T$ on the LPW grid, footnote (viii) mapping it to their $\lambda$ (D23) | scalar $\ge0$ | — | — | 3 | 4–7 |
| $\operatorname{df}(\lambda)$ | effective degrees of freedom $\operatorname{tr}[(\mathbf X'\mathbf X+\lambda\mathbf D_r'\mathbf D_r)^{-1}\mathbf X'\mathbf X]$; $\operatorname{rank}(\mathbf X)=H+1$ at $\lambda\to0$, $r$ at $\lambda\to\infty$ | scalar | — | parameters | 3 | 5, 7 |
| $\operatorname{CV}(\lambda)$ | mean hold-out squared error over 5 contiguous blocks | scalar | — | $y$-units² | 3 | 7 |
| $Q_T(\boldsymbol\vartheta)$ | minimum-distance criterion $[\hat{\boldsymbol\beta}-\boldsymbol{\mathcal G}(\boldsymbol\vartheta)]'\hat{\boldsymbol\Sigma}^{-1}[\hat{\boldsymbol\beta}-\boldsymbol{\mathcal G}(\boldsymbol\vartheta)]$, $\boldsymbol\vartheta=(a,h^\star,c)$ | scalar | — | — | 5 | 6, 7 |
| $J$ | $Q_T$ at its minimum; $J\to\chi^2_{(H+1)-3}$ under A1 | scalar | — | — | 5 | 7 |
| $\mathcal H_J$ | horizon subset on which the test is computed (headline: every 6th horizon, 9 points, 6 d.o.f.; D27) | set | — | — | 5 | 7 |
| $\rho_v$ | AR(1) persistence of the MC noise $v_t$ (distinct from the ledger's $\rho$, which is not used here) | scalar | — | — | 5 | 7 |
| $\varepsilon^v_t$, $\sigma_{\varepsilon v}$ | innovation of the MC noise $v_t$ and its standard deviation (default 1; a Lab 2 control); not $e$, which the ledger reserves for $\theta_h(e)$ and $e_i$ | scalar | row $t$ | as $y$ | 1 | 5, 7 |
| $R$ | Monte Carlo replications (500 instructor, 200 student) | integer | — | — | 5 | 7, 8 |

Stata names in the lab project follow ledger §9: `y`, `s`, `z`, `w1`–`wp`,
`h`, `beta_h`, `se_h`; stacked long file has `t`, `h`, `ytil`, `stil`,
`bk1`–`bk52`; Gaussian parameters `a`, `hstar`, `c` (`b0` survives only in the REP08 author code); spline coefficients `delta`;
penalty `lambda`, order `r`.

---

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition (draft) | First marked occurrence |
|---|---|---|---|---|
| unrestricted local projection | glossary | `unrestricted-lp` | The horizon-by-horizon estimator that treats each $\beta_h$ as a free parameter estimated from its own rows; it imposes nothing across horizons and pays for that freedom in variance that grows with $h$. | §1 |
| shape restriction | glossary | `shape-restriction` | A constraint tying $\beta_0,\dots,\beta_H$ to fewer parameters or to a smoothness condition; it lowers variance where it is right and cannot be tested from inside the restricted model. | §1 (last paragraph) |
| restricted estimation | glossary | `restricted-estimation` | Estimating the response path subject to a shape restriction; the reported uncertainty is then conditional on the restriction being true. | §2 |
| basis function | glossary | `basis-function` | A known function of the horizon, $b_k(h)$, whose weighted sum represents the response; the weights, not the functions, are estimated. | §2 |
| Gaussian basis function | glossary | `gaussian-basis-function` | Jordà–Taylor's $a\exp\{-(h-h^\star)^2/c^2\}$: despite the name, a three-parameter parametric family rather than a linear basis expansion (D21) — one bump whose height, peak horizon, and width are the only free parameters, so the path is unimodal, single-signed, and symmetric about $h^\star$. | §2 |
| nonlinear least squares | glossary | `nonlinear-least-squares` | Minimizing the stacked sum of squared residuals over parameters that enter the fitted value nonlinearly, here $(a,h^\star,c)$; Stata's `nl` or `gmm` with iid weights. | §2 |
| unimodality | glossary | `unimodality` | Having one peak; a unimodal restriction cannot represent a second hump or a rebound, so such features are absorbed into the single bump's height and width. | §4 (defined where the restriction table is) — first *use* in §2 is plain prose |
| B-spline | glossary | `b-spline` | A piecewise-polynomial basis function that is non-zero only over a few adjacent knot intervals; with knots at every horizon, cubic B-splines give $K=H+4$ local bumps. | §3 |
| penalized regression | glossary | `penalized-regression` | Least squares plus a penalty on the coefficients; the solution shrinks toward the penalty's null space and is linear in the data for a given $\lambda$. | §3 |
| roughness penalty | glossary | `roughness-penalty` | The term $\lambda\|\mathbf D_r\boldsymbol\delta\|^2$ that charges for $r$-th differences of neighbouring spline coefficients; it makes the fitted path smooth without saying where its peaks are. | §3 |
| tuning parameter | glossary | `tuning-parameter` | A quantity such as $\lambda$ (or $r$, or the knot spacing) that the researcher sets and the data do not identify; its choice is a modelling decision and should be reported. | §3 |
| cross-validation | glossary | `cross-validation` | Choosing a tuning parameter by hold-out prediction error; for time series the held-out sets are contiguous blocks so that neighbouring rows do not leak the answer. | §3 |
| effective degrees of freedom | glossary (new) | `effective-degrees-of-freedom` | The trace of the hat matrix of a penalized fit, $\operatorname{tr}[(\mathbf X'\mathbf X+\lambda\mathbf D_r'\mathbf D_r)^{-1}\mathbf X'\mathbf X]$; it counts the parameters the fit is effectively spending, from $H+1$ at $\lambda=0$ to $r$ as $\lambda\to\infty$. | §3 |
| minimum distance | glossary (new) | `minimum-distance` | Fitting a restricted path to an unrestricted estimate $\hat{\boldsymbol\beta}$ by minimizing $[\hat{\boldsymbol\beta}-\boldsymbol{\mathcal G}(\boldsymbol\vartheta)]'\hat{\boldsymbol\Sigma}^{-1}[\hat{\boldsymbol\beta}-\boldsymbol{\mathcal G}(\boldsymbol\vartheta)]$; it reuses the cross-horizon covariance of Lecture 6. | §5 |
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
| The unrestricted LP-IV path is jagged and its se grows from 0.10 to 0.63 across $h$ | 49 GMM coefficients and HAC se; $\chi^2(49)=446.89$ | figure + table row | REP08 benchmark (Stata/SE 18.5 run of `GMM_LPIV_GBF_estimate_part1.do`); authors' stored `gmm.ster` | benchmarked; stored `.ster` agrees ($\lvert\Delta\hat\beta_h\rvert\le1.0\times10^{-13}$); Lua data file to build | `fig-l08-unrestricted-urate`, `tbl-l08-jt-benchmark` |
| Each free horizon costs variance | $\operatorname{Var}(\hat\beta_h\mid\tilde s)=\sigma^2_{u,h}/\sum\tilde s_t^2$ on the stacked design | equation + MC sd | derivation D1; MC | derivation verified in §6; MC numbers from instructor build | `eq-l08-var-unrestricted` |
| Three numbers describe a hump | $\mathcal G(h;a,h^\star,c)$ anatomy: $\beta_0=0.024$, $\beta_{12}=0.421$, $\beta_{26}=1.387$, $\beta_{48}=0.083$; above $a/2$ on $[15.4,37.0]$ | figure + worked example | JT `gmmgbf.ster`; hand calculation | verified against `nlcom` (0.02392, 0.42129, 1.38722, 0.08301) | `fig-l08-gbf-anatomy`, `eq-l08-gbf` |
| JT's Gaussian fit: $a=1.388$ (0.278), $h^\star=26.19$ (0.92), $c=13.00$ (0.89) | GMM, 98 moments, $T_H=127$ | table + figure | REP08 benchmark; authors' log; 19.5 Part 2 replay (identical printed output) | benchmarked (see §8) | `tbl-l08-jt-benchmark`, `fig-l08-gbf-vs-unrestricted` |
| At the peak only $a$'s uncertainty matters; at impact the band is 2 basis points wide | delta method: se$_{26}=0.2796$ (hand: 0.27960), se$_0=0.0217$ | equation + figure | $\mathbf V$ from `gmmgbf.ster` | verified by hand against `nlcom` | `eq-l08-gbf-gradient`, `fig-l08-se-ratio` |
| On a matched pair the restricted band is 22% of the unrestricted at $h=1$, at most 89% (at $h=19$), and 13% at $h=48$; the authors' runs give 19%, 75%, 7% | ratio of se paths at corrected horizons (D14); matched re-estimation with 6 HAC lags, `rz` and six lags, 121 rows (§6 D10) | figure | REP08 benchmark CSV and $\mathbf V$; StataNow/SE 19.5 re-estimation | authors' ratio computed (se from $\mathbf V$ match the benchmark to $5\times10^{-8}$); matched ratio *verified* in 19.5 (13.1 s); `gmmgbf_nw6.ster` to be stored by the instructor build | `fig-l08-se-ratio` |
| The unrestricted $\hat\beta_1=-0.277$ (se 0.145) lies outside the Gaussian band; pointwise $\lvert z\rvert$ never exceeds 2.13 | $z_h=(\hat\beta_h-\mathcal G_h)/\operatorname{se}_h$ | prose + figure annotation | computed from `bsel`, `Vsel` | computed | `fig-l08-gbf-vs-unrestricted` |
| Cubic B-splines with knots at every horizon give $K=H+4$ local bumps | basis construction | figure + footnote | Eilers–Marx `bspline` as ported by LPW | formula figure to build | `fig-l08-bspline-basis` |
| $\lambda\to0$ returns the unrestricted LP; $\lambda\to\infty$ with $r=2$ returns a line | max$_h\lvert\hat\beta^{\mathrm{sp}}_h(10^{-4})-\hat\beta^{\mathrm{OLS}}_h\rvert$ and second differences at $10^{10}$ | assertion + figure | Python prototype; the instructor build regenerates them in Stata/Mata | $3.3\times10^{-4}$; $9.7\times10^{-9}$ (§6 D4) | §6 D4, STA08 Task 2, Exercise 6 |
| CV on the reduced-form unemployment response picks heavy smoothing but barely discriminates | 5-fold contiguous CV over the 51-point LPW grid | one evidence paragraph + STA08 table (D28) | Python prototype; the instructor build regenerates them in Stata/Mata | $\lambda_{\mathrm{CV}}/T=80$, df 3.12, CV curve flat within 0.14% (§6 D6); peak 0.498 at $h=24$, 0.765 pp per pp after $\div\hat\pi$ | `#sec-l08-evidence`, `tbl-l08-spline`, STA08 Task 2 |
| A unimodal restriction fits one hump and drops the other; a single-signed one cannot show the early dip and reports the miss with a small sd | MC under B and C | figure + table | seed-8 MC, $R=200$ | Python prototype; the instructor build regenerates them in Stata/Mata ($R=500$). B: 78.5% of fits on the first hump, bias $-0.43$ at $h=26$; C: $\hat a>0$ in 200/200, bias $+0.50$ at $h=3$, sd 0.052 (OLS 0.177) | `fig-l08-misspecification`, `tbl-l08-mc` |
| The spline keeps both humps and the dip but flattens them; its bias sits at peaks and troughs, and tuning adds variance | MC; CV versus fixed $\lambda=10T$ | figure + table | seed-8 MC, $R=200$ | Python prototype; the instructor build regenerates them in Stata/Mata. B: mean path peaks at $h=8$ and 30, bias $-0.33$ at $h=8$ (OLS $-0.13$); C: $-0.30$ at $h=3$ (truth $-0.47$); A: sd 0.214 at $h=0$ (fixed $\lambda$ 0.094, OLS 0.087) | same |
| At $T=181$ the unrestricted LP is itself biased toward zero at long horizons, and the Gaussian fit under A inherits the bias | MC bias and MC se | table | seed-8 MC, $R=200$ | Python prototype; the instructor build regenerates them in Stata/Mata. A, $h=26$: OLS and Gaussian $-0.248$ (MC se 0.038) | `tbl-l08-mc`, §6 D1, §10 |
| The overidentification verdict depends on how many horizons $\hat{\boldsymbol\Sigma}$ must describe | $J$ = 346.4 (46 d.o.f.) on all 49 horizons with cond$(\hat{\boldsymbol\Sigma})=8.9\times10^4$; 59.0 (22) every 2nd; 19.6 (10, $p=0.033$) every 4th; 5.99 (6, $p=0.42$) every 6th; 4.28 (2, $p=0.12$) every 12th | table | `bsel_lpiv.csv`, `Vsel_lpiv.csv` from the authors' `gmm.ster` | computed | `tbl-l08-jtest-subsets`, Lab 4 |
| A three-horizon toy makes the test's mechanics visible | $\hat\beta=(0.2,0.5,0.8)$, se $=(0.1,0.1,0.2)$, flat restriction: $\hat\delta=0.4$, $J=9.0>\chi^2_{2,0.95}=5.99$ | worked example | hand + Python check | verified | Exercise 8 |
| The published Figure 6 plots horizons 1–48 at axis positions 0–47 | `replace bj = ... if _n == 0` never fires; `t=_n-1`; `b_gbf` loop runs $h=1..48$ into row $h$ | prose + discrepancy log | `GMM_LPIV_GBF_estimate_part1.do` lines 91, 145, 206; `output.dta` row $t=0$ holds $\hat\beta_1=-0.2771$ and $\mathcal G(1)=0.0324$ | verified | §7, REP08 discrepancy guidance, Exercise 9 |
| The Gaussian GMM's HAC uses 179 lags | Stata default $N-2$ with $N=181$ dataset rows | footnote | authors' log line "Bartlett kernel with 179 lags" | verified | §7 |
| Reduced form ÷ first stage tracks the LP-IV path up to the instrument set | $\hat\beta^{\mathrm{RF}}_h/\hat\pi$ vs JT GMM (which adds six lags of $z$ and two-step weights) | table | Python prototype; the instructor build regenerates them in Stata | $\hat\pi=0.6506$; correlation 0.957 with the GMM path (§6 D8) | `tbl-l08-wald`, STA08 Task 5 |
| Long-difference and level outcomes give the same $\beta_h$ here | L2 equivalence, checked at $h=12$: $1.3\times10^{-14}$ | assertion in `tests/checks.do` | `chk_infl.do` | verified | §1 footnote |

---

## 5. Assessment map

Ten exercises; four are Stata [computational] (4, 6, 7, 10). Every learning
outcome has evidence in prose plus at least one of figure/exercise/lab.

| LO | Exercise | Tags | Mode of work | Hint strategy | Solution check | Linked lab |
|---|---|---|---|---|---|---|
| 1 | 1 · *Count the parameters and cost them.* For the seed-8 design with shape A, split $y_{t+h}-\theta_hs_t$ into future shocks and a past part (earlier shocks plus $v_{t+h}$), compute $\sigma^2_{u,h}$ at $h=0,26,48$ after projecting the past part on $y_{t-1}$ ($\sum_j\theta_j^2=31.9$; $\sigma^2_{\varepsilon v}/(1-\rho_v^2)=1.333$; projection coefficients $\gamma_h$ given), and the implied se of $\hat\beta_h$ with $\sum\tilde s_t^2\approx T_h$; compare with the MC sd. | core, pencil | derivation → number → comparison | "Which shocks does row $t$ of horizon $h$ still contain after $s_t$ and $y_{t-1}$ are in the regression, and which of them can $y_{t-1}$ predict?" | $\sigma^2_{u,h}=1.51,\ 30.97,\ 33.25$ and se 0.092, 0.448, 0.502 (§6 D1), against `tbl-l08-mc`; common mistake: treating the past shocks as unabsorbed, which gives a flat profile near 0.43 | Lab 2 |
| 2 | 2 · *Read three numbers.* With $a=1.3875,h^\star=26.189,c=12.997$: compute $\beta_h$ at $h=0,12,26,48$; find the months during which the response exceeds half its peak; say in one sentence each what $a$, $h^\star$, $c$ mean, with units. | core, pencil | hand arithmetic → interpretation | "Write $(h-b)/c$ first; it is dimensionless." | matches `nlcom` (0.0239, 0.4213, 1.3872, 0.0830); window $[15.4,37.0]$ | Lab 1 |
| 2, 5 | 3 · *The band at the peak and at impact.* Derive $\nabla\mathcal G_h$; show that at $h=h^\star$ it equals $(1,0,0)'$ so se$_{h^\star}=\operatorname{se}(\hat a)$; evaluate se$_{26}$ and se$_0$ with $\mathbf V$ (given as a table); explain what the band conditions on. | core, pencil | derivation → evaluation → interpretation | "Differentiate the exponent before the exponential; at $h=h^\star$ the exponent's derivative vanishes." | 0.2796 and 0.0217 against `nlcom`; common mistake: dropping the cross terms of $\mathbf V$ | Lab 3 |
| 2 | 4 · *Fit the Gaussian basis two ways.* On the shipped seed-8 draw (shape A), build the stacked residualized file with `lp_stack`, fit $(a,h^\star,c)$ by `nl` and by `gmm` with iid weights; assert agreement to $10^{-4}$; compute the path with `nlcom`; report the path's se at $h=0$ and at the peak. | core, computational (Stata) | implement → assert → interpret | "Start `nl` at $a=\max_h\lvert\hat\beta_h\rvert$, $h^\star=\arg\max$, $c=12$; the objective is well behaved but $c$ must be positive." | `assert reldif(a_nl, a_gmm) < 1e-4`; shipped benchmark values in `tests/` | Lab 1, 5 |
| 3 | 5 · *A spline you can do by hand.* For $H=4$ and degree-1 B-splines (hat functions) with unit knots, write $\mathbf B$ ($5\times6$) and $\mathbf D_2$ ($4\times6$); show that $\mathbf D_2\boldsymbol\delta=\mathbf 0$ forces $\delta_k$ linear in $k$ and hence $\beta_h$ linear in $h$; compute $\beta_h$ for $\boldsymbol\delta=(0,1,2,3,4,5)$. | core, pencil | construction → algebra → check | "A hat function at knot $k$ is 1 at $h=k$ and 0 at the neighbours; so $\mathbf B$ is a selection of $\boldsymbol\delta$." | $\beta_h=h+1$; common mistake: miscounting $K$ | — |
| 3 | 6 · *The two limits of $\lambda$.* With the supplied `lp_spline` on the seed-8 draw: (i) at $\lambda=10^{-4}$ assert $\max_h\lvert\hat\beta^{\mathrm{sp}}_h-\hat\beta^{\mathrm{OLS}}_h\rvert<10^{-3}$; (ii) at $\lambda=10^{10}$ assert second differences $<10^{-6}$ and report the slope; (iii) run the CV and report $\lambda_{\mathrm{CV}}/T$ and $\operatorname{df}(\lambda_{\mathrm{CV}})$. | core, computational (Stata) | implement → assert → report | "The unrestricted OLS path must be computed on the same common sample as the stack." | assertions; df between 2 and 49 | Lab 2 |
| 4 | 7 · *Seed 8: a second hump and a sign change.* Run the shipped MC driver at $R=200$ for shapes B and C, one shape per command; tabulate bias and sd at $h=3,8,26,40$ for OLS, Gaussian, spline; explain where each estimator's bias sits and why the Gaussian bias under C is largest near $h=3$. | core, computational, data (Stata); [extra] under D26 if the instructor build times a shape above a few minutes | run → tabulate → interpret | "Plot the MC mean path over the truth before reading the table; the Gaussian fit cannot be negative anywhere if $\hat a>0$." | numbers against the instructor's $R=500$ table within MC error; log file must show seed 8 | Lab 2 |
| 4 | 8 · *Does the shape pass?* Three horizons, $\hat{\boldsymbol\beta}=(0.2,0.5,0.8)$, se $=(0.1,0.1,0.2)$, independent; restriction "flat"; compute $\hat\delta$ and $J$, compare with $\chi^2_2$; then read `tbl-l08-jtest-subsets` and explain why $J$ on 49 horizons is not the same test as $J$ on 9. | core, pencil | hand → reading → explanation | "With a diagonal $\hat{\boldsymbol\Sigma}$ the restricted estimate is a precision-weighted mean." | $\hat\delta=0.4$, $J=9.0$, reject at 5%; the 49-horizon $\hat{\boldsymbol\Sigma}$ has condition number $8.9\times10^4$ | Lab 4 |
| 5 | 9 · *Data or structure?* Using both panels of JT Figure 6 and the benchmarked numbers: list five features (impact sign, early dip, peak month, symmetry of the decline, band width at $h=48$) and classify each as data-supported, imposed, or undetermined; include the horizon-offset audit as a presentation discrepancy. | core, data | reading → memo | "For each feature ask: could the Gaussian basis have produced anything else?" | model memo in the solution; rubric: each classification must cite a number | Lab 3, 4 |
| 3 | 10 · *The shrinkage target.* Rerun `lp_spline` on the shipped seed-8 shape-B draw (the JT reduced form stays in STA08 Task 2, D28) with $r\in\{1,2,3\}$ and knots every 2 horizons; report $\lambda_{\mathrm{CV}}$, df, peak height and month; explain what changes as the null space of $\mathbf D_r$ changes. | extra, computational (Stata) | run → compare → explain | "$r=1$ shrinks toward a constant, $r=3$ toward a quadratic; look at the $\lambda\to\infty$ fit first." | table of results; no single right answer, but $\lambda\to\infty$ fits must match the stated polynomials | Lab 2 |

---

## 6. Derivations to verify

Each item names the source identity, the steps the notes will display, and
the numerical check. All checks below marked *verified* were run on 13
September 2026; values marked *prototype* are Python prototype values
(`proto08.py`; the MC driver `run2/mc08_fast.py` matches its solver to
$1.3\times10^{-9}$); the instructor build regenerates them in Stata/Mata.

**D1. Stacked form and the variance of a free horizon** (`#eq-l08-stacked`,
`#eq-l08-var-unrestricted`). Source: the canonical LP and FWL (L3). Steps:
(i) partial out $(1,\mathbf w_t)$ from $y_{t+h}$ and $s_t$ within
$\mathcal T_h$; (ii) $\hat\beta_h=\sum_t\tilde s_t\tilde y_{t,h}/\sum_t\tilde s_t^2$;
(iii) conditional on $\tilde s$, $\operatorname{Var}(\hat\beta_h)=\sigma^2_{u,h}/\sum_t\tilde s_t^2$
when $\tilde u_{t,h}$ is homoskedastic and uncorrelated with $\tilde s$ (the
HAC version replaces the numerator by the long-run variance of
$\tilde s_t\tilde u_{t,h}$, L5); (iv) in the MC with $\mathbf w_t=y_{t-1}$,
split $y_{t+h}-\theta_hs_t$ into future shocks $\sum_{j<h}\theta_js_{t+h-j}$,
which nothing in the regression predicts, and the past part
$P_{t,h}=\sum_{m\ge1}\theta_{h+m}s_{t-m}+v_{t+h}$, which $y_{t-1}$ partly
predicts; with $\gamma_h=\operatorname{Cov}(y_{t+h},y_{t-1})/\operatorname{Var}(y)$,
$\sigma^2_{u,h}=\sum_{j<h}\theta_j^2+\operatorname{Var}(P_{t,h})-\gamma_h^2\operatorname{Var}(y)$.
Worked numbers (shape A, $\theta_j$ truncated at $j=48$ as simulated):
$\sum_j\theta_j^2=1.96\sum_h e^{-2(h-26)^2/169}=31.9$ and
$\operatorname{Var}(y)=31.9+1.33=33.26$. At $h=0$: $\gamma_0=0.977$,
$\sigma^2_{u,0}=33.26(1-0.977^2)=1.51$, se $\approx\sqrt{1.51/180}=0.092$. At
$h=26$: $\gamma_{26}=0.099$, $\sigma^2_{u,26}=14.99+16.31-0.33=30.97$, se
$\approx\sqrt{30.97/154}=0.448$ (0.625 with the cross-row terms of the
long-run variance). At $h=48$: $\sigma^2_{u,48}=33.25$, se 0.502. Check
(*prototype*, $R=200$): MC sd at $h=0,1,6,12,26,48$ is 0.087, 0.123, 0.239,
0.365, 0.533, 0.459 against 0.092, 0.123, 0.244, 0.362, 0.448, 0.502. Note for
the notes: the profile rises, as JT's does (0.10 → 0.63), because $y_{t-1}$
absorbs the past at short horizons and none of the future at long ones. The
same run shows OLS bias toward zero, $-0.248$ at $h=26$ ($-17.7\%$, 6.6 MC
standard errors), which the Gaussian fit inherits (§10).

**D2. Reading the Gaussian basis** (`#eq-l08-gbf`). Source: JT's
$\psi(h)=a\exp\{-((h-b)/c)^2\}$, written $a\exp\{-(h-h^\star)^2/c^2\}$ (D20).
Steps: $\mathcal G(h^\star)=a$; $\mathcal G(h)=a/2\iff|h-h^\star|=c\sqrt{\ln2}$; symmetry
$\mathcal G(h^\star+d)=\mathcal G(h^\star-d)$; sign of $\mathcal G$ is the sign of $a$ for every $h$; one
stationary point. Worked example, exact inputs $a=1.387518$,
$h^\star=26.1893$ (JT's `/b0`), $c=12.99661$: $(0-h^\star)/c=-2.01509$, squared $4.0606$, $e^{-4.0606}=0.017237$,
$\beta_0=0.02392$; $\beta_{12}=0.4213$; $\beta_{26}=1.3872$;
$\beta_{48}=0.0830$; $c\sqrt{\ln2}=10.820$, window $[15.37,37.01]$.
*Verified* against `nlcom` (0.02392, 0.42129, 1.38722, 0.08301).

**D3. Delta-method band for the restricted path** (`#eq-l08-gbf-gradient`).
Source: delta method (L4). Steps: $\partial\mathcal G/\partial a=e^{-(h-h^\star)^2/c^2}$;
$\partial\mathcal G/\partial h^\star=a\,e^{-(\cdot)}\,2(h-h^\star)/c^2$;
$\partial\mathcal G/\partial c=a\,e^{-(\cdot)}\,2(h-h^\star)^2/c^3$;
$\operatorname{Var}(\hat{\mathcal G}_h)=\nabla\mathcal G_h'\mathbf V\nabla\mathcal G_h$. Inputs (REP08
benchmark `raw/REP08-gbf-covariance.csv`): $\mathbf V$ with $V_{aa}=0.077203$,
$V_{h^\star h^\star}=0.850645$, $V_{cc}=0.793986$, $V_{ah^\star}=-0.157383$,
$V_{ac}=0.221345$, $V_{h^\star c}=-0.312063$. At $h=26$:
$\nabla\mathcal G=(0.99979,-0.003109,0.0000453)'$, variance $0.078178$, se $0.27960$.
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
Checks (*prototype*, reduced-form unemployment response on the Romer shock,
common sample of 127 rows × 49 horizons, $K=52$, $r=2$):
$\max_h|\hat\beta^{\mathrm{sp}}_h(10^{-4})-\hat\beta^{\mathrm{OLS}}_h|=3.3\times10^{-4}$;
at $\lambda=10^{10}$, $\max_h|\Delta^2\hat\beta^{\mathrm{sp}}_h|=9.7\times10^{-9}$,
a line from 0.251 at $h=0$ with slope 0.0013 per month. Stata `lp_spline` must
reproduce both as assertions (tolerances $10^{-3}$ and $10^{-6}$).

**D5. Effective degrees of freedom** (`#eq-l08-edf`). Source: hat matrix of
a linear smoother. Steps: $\hat{\tilde{\mathbf y}}=\mathbf H(\lambda)\tilde{\mathbf y}$,
$\operatorname{df}(\lambda)=\operatorname{tr}\mathbf H(\lambda)=\operatorname{tr}[(\mathbf X'\mathbf X+\lambda\mathbf D_r'\mathbf D_r)^{-1}\mathbf X'\mathbf X]$;
at $\lambda\to0$ equals $\operatorname{rank}\mathbf X=49$, at $\lambda\to\infty$
equals $\dim\operatorname{null}(\mathbf D_r)=r$. Check: df at
$\lambda\in\{10^{-4},\lambda_{\mathrm{CV}}=80T,T,10T,100T,10^{10}\}$ on the JT reduced form
(*prototype*, $T=127$): 48.93, 3.12, 7.27, 4.56, 3.01, 2.00 (11.89 at $0.1T$).

**D6. Contiguous-block cross-validation** (`#eq-l08-cv`). Source: LPW
`locproj_cv.m`. Steps: split $t=1,\dots,T$ into 5 contiguous blocks
(`chunks = ceil(5·t/T)`); for each block, rebuild the stacked design on the
remaining rows, fit at each $\lambda$, predict the held-out rows'
$\tilde y_{t,h}$ from $\tilde s_t b(h)'\hat{\boldsymbol\delta}$ using the
full-sample residualization, average the squared errors; choose the
minimizer. Grid: $\lambda/T\in\{0.001{:}0.005{:}0.021,\ 0.05{:}0.1{:}1.05,\ 2{:}1{:}19,\ 20{:}20{:}100,\ 200{:}200{:}2000\}$
plus $10^{-4}$ and $10^{10}$ (51 values). Checks (*prototype*): on the JT
reduced form $\lambda_{\mathrm{CV}}/T=80$ (df 3.12), but the curve is nearly
flat: grid points from $\lambda/T=17$ to 1,000 lie within 0.05% of the
minimum, the line limit 0.07% and the OLS limit 0.14% above it, so CV barely
informs the choice. On the MC draws (13-point grid, $R=200$) the median
$\lambda_{\mathrm{CV}}/T$ is 300 for A (IQR 100–1,000; df 5.03), 30 for B
(10–150; df 7.98), 1,000 for C (100–1,000; df 4.04); the line limit wins in
11%, 20%, 1% of draws.

**D7. Minimum distance and the overidentification statistic**
(`#eq-l08-md`, `#eq-l08-jstat`). Source: Jordà's two-step GBF (CEMFI
slides 7, 9): $\min_{\boldsymbol\vartheta}Q_T$; $J=Q_T(\hat{\boldsymbol\vartheta})\to\chi^2_{(H+1)-3}$.
Steps: Cholesky factor of $\hat{\boldsymbol\Sigma}^{-1}$ turns the problem into
NLS; degrees of freedom count. Toy check (hand and Python): flat restriction on
$(0.2,0.5,0.8)$ with se $(0.1,0.1,0.2)$: $\hat\delta=(20+50+20)/225=0.4$,
$J=4+1+4=9.0$, $\chi^2_{2,0.95}=5.99$. *Verified.* Empirical check with the
authors' $\hat{\boldsymbol\beta}$ and 49×49 HAC $\hat{\boldsymbol\Sigma}$: all
horizons $J=346.4$ (46 d.o.f.), $\hat a=1.426$ (0.157), $\hat h^\star=26.93$ (0.56),
$\hat c=12.66$ (0.48); every 2nd horizon $J=59.0$ (22); every 4th $J=19.6$
(10, $p=0.033$); every 6th $J=5.99$ (6, $p=0.42$), $\hat a=0.956$ (0.427),
$\hat h^\star=28.67$ (3.99), $\hat c=15.65$ (3.52); every 12th $J=4.28$ (2,
$p=0.12$); diagonal-weighted on all 49: $J_{\mathrm{diag}}=14.8$, which has no $\chi^2(46)$
reference distribution (with a weight other than $\hat{\boldsymbol\Sigma}^{-1}$
the minimized distance is a weighted sum of $\chi^2(1)$ variables), so it is
reported without a $\chi^2$ p-value; Lab 4 simulates one.
*Verified.* Per D27 the notes present the every-6th version as the headline
test and the all-horizon sequence as the illustration of a near-singular
covariance.

**D8. Wald ratio versus JT's joint GMM** (`#tbl-l08-wald`). Source: L4,
$\beta^{\mathrm{IV}}_h=\operatorname{Cov}(\tilde y_{t,h},\tilde z_t)/\operatorname{Cov}(\tilde s_t,\tilde z_t)$.
Steps: reduced form $\hat\beta^{\mathrm{RF}}_h$ (OLS of $\tilde y_{t,h}$ on
$\tilde z_t$, common sample), first stage $\hat\pi$ (OLS of $\tilde s_t$ on
$\tilde z_t$, same rows), ratio. Checks (*prototype*, 127 common rows):
$\hat\pi=0.6506$; against JT's GMM path (121 rows) the ratio path has
correlation 0.957, mean absolute difference 0.136, largest difference 0.408 at
$h=33$ (0.78 GMM se), and peak 1.075 at $h=26$ against 1.222 at $h=31$. The discrepancy is logged as
"specification: instrument set and weighting," not as an error.

**D9. Same-regressor equivalence for the JT outcome.** Source: L2. Check at
$h=12$: OLS of $f_{12}.\texttt{urate}-l.\texttt{urate}$ and of
$f_{12}.\texttt{urate}$ on `RRCGShock` and the 18 controls give
$0.43014988$ both times, difference $1.3\times10^{-14}$ (163 rows). *Verified.*

**D10. A matched standard-error ratio** (`fig-l08-se-ratio`, chain item 6).
Source: D3 and the REP08 benchmark README ("the comparison also changes
instruments/sample"). The authors' ratio
$\operatorname{se}^{\mathrm{GBF}}_h/\operatorname{se}^{\mathrm{OLS}}_h$
compares two GMM runs that differ in more than the restriction: (i) the
Gaussian run's `vce(hac nw)` uses Stata's default $N-2=179$ Bartlett lags on
127 observations, so every available autocovariance of the moments enters
with weight between 0.30 and 0.99, against 6 lags in the unrestricted run;
(ii) its only instrument is current `rz`, against `rz` and `L(1/6).rz`;
(iii) its sample has 127 rows, against 121. (The unrestricted equations also
carry per-horizon intercepts and the Gaussian ones do not; the caption says
so.) Steps: re-estimate JT's Gaussian system (lines 125–137) with
`instruments(rz l(1/6).rz)` and `vce(hac nw 6)`, keeping the two-step
unadjusted weights; the six lags of `rz` drop the first six rows, so
$N=121$, the unrestricted rows; delta-method se by `nlcom`; divide by the
stored unrestricted se. Checks (*verified*, StataNow/SE 19.5 batch, 13
September 2026, 13.1 s): matched $a=1.2521$ (0.4109), $h^\star=26.141$
(1.650), $c=12.387$ (2.121); matched ratio 0.235 at $h=0$, 0.219 at $h=1$,
0.894 at $h=19$ (its maximum over $h=0,\dots,48$), 0.825 at $h=26$, 0.129 at
$h=48$. The same code on the authors' `gmmgbf.ster` returns their ratio:
0.209, 0.192, 0.751 (maximum), 0.563, 0.067. Bandwidth alone (6 lags on JT's
127 rows with current `rz`; point estimates unchanged; 2.2 s) raises
$\operatorname{se}(\hat a)$ from 0.278 to 0.461 and gives 0.304, 0.277, 1.016,
0.927, 0.152: the 179 lags narrow the authors' band and the smaller
instrument set widens it. Interpretation for the notes: the matched ratio is
the lecture's number; the restriction still makes the band far narrower where
the shape pins the path near zero ($h\le1$, $h=48$), but at $h=19$–26 the
restricted band is 83–89 percent of the unrestricted width, not 56–75
percent, and at $h=48$ the authors' band is about half as wide as the matched
one. The instructor build stores `gmmgbf_nw6.ster`; the scratch run is not
shipped.

---

## 7. HTML lab plan (Smoothing Workbench, `interactives/08-smoothing-workbench.qmd`)

Five labs, each predict → manipulate → observe → explain → transfer. Shared
helpers come verbatim from `docs/templates/interactive.qmd` (`ols`, `invert`,
`hcSe`, `neweyWestSe`, `localProjection`, `mulberry32`, `gaussian`). New
lecture-specific functions, hidden from the student view: `gbf(h,a,hstar,c)`,
`gbfGradient`, `bsplineBasis(H, degree=3)`, `diffMatrix(K,r)`,
`ridgeSolve(X,y,lambda,D)` (normal equations on $K=52$ columns, solved with
`invert`), `blockCV`, `gaussNewtonGBF` (Levenberg–Marquardt, 3 parameters,
analytic Jacobian, 50 iterations, starting values as in footnote (v)),
`minDistance(beta, SigmaInv, hsel)`, and `mdPvalueSim(Sigma, hsel, weight,
nDraws)`. Every panel is labelled **live
calculation**, **stored result**, or **conceptual illustration**. Browser
NLS and ridge results are validated against Stata on the shipped seed-8 CSV
(tolerance $10^{-4}$ for NLS parameters, $10^{-8}$ for the ridge path);
the validation table lives in `practica/p08-.../build/`.

**Lab 1 — Three numbers, one curve.**
*Learning question:* which features of the unrestricted cloud can three
parameters reach? *Invariants:* the 49 unrestricted points and their 95%
bars (stored result from `gmm.ster`, plotted at the correct horizons).
*Controls:* $a$ (pp per pp; range $[-1,3]$, step 0.01, default 1.39),
$h^\star$ (months; $[0,48]$, step 0.1, default 26.2), $c$ (months; $[1,40]$, step
0.1, default 13.0); a "snap to JT" button. *Computation:* live —
$\mathcal G(h;a,h^\star,c)$ for $h=0,\dots,48$; the sum of squared distances to the
unrestricted points, unweighted and precision-weighted. *Predict prompt:*
"If you double $c$, does the peak height change? Can any setting make the
curve negative at $h=1$?" *Reactive sentence:* "The curve peaks at
**{a}** pp in month **{hstar}** and stays above half its peak from month
**{hstar−c√ln2}** to **{hstar+c√ln2}**; the closest unrestricted point it cannot
reach is $h=1$ at −0.28, **{z}** unrestricted standard errors away."
*Comparisons:* (1) hold $a,h^\star$, move $c$ — what happens at $h=0$ and $h=48$;
(2) set $a<0$ — the whole curve flips; (3) try to match both the early dip
and the peak. *Handoff:* `{a,hstar,c}` chosen, with the two prompts' answers.

**Lab 2 — Freedom is variance (and what a restriction buys).**
*Learning question:* on one draw with a known truth, which estimator is
closest, and does the answer change with the shape? *Invariants:* the
draw — `mulberry32(8)` generates $s_t$ and the standardized innovations
$\varepsilon^v_t/\sigma_{\varepsilon v}$ once per seed at $T_{\max}=360$ plus the
49-period burn-in; a run at $T$ uses the first $49+T$ rows; $v_t$ and $y_t$ are
rebuilt from those draws when $\sigma_{\varepsilon v}$, $\rho_v$, or the shape
changes, and toggling estimators, $\lambda$, or $r$ reuses the same $y$.
Changing $T$ or a parameter never redraws shocks; only "new draw" does. *Controls:* shape (A/B/C; default
A), $T\in\{120,181,360\}$ (default 181), $\sigma_{\varepsilon v}$ ($[0.25,2]$, default 1.0),
$\rho_v$ ($[0,0.9]$, default 0.5), $\log_{10}(\lambda/T)$ ($[-4,4]$, step
0.25, default: CV value), $r\in\{1,2,3\}$ (default 2), checkboxes for the
three fits, "new draw" (seed +1). *Computation:* live — 49 OLS projections
(`localProjection` with $y_{t-1}$ as control, HC1 se), Gauss–Newton Gaussian
fit on the stacked residualized design, ridge spline at the chosen $\lambda$,
5-block CV curve (51-point grid; recomputed only when $T$, shape, $\sigma_{\varepsilon v}$,
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
shape, $T$, $\sigma_{\varepsilon v}$, $\rho_v$, $\lambda$, $r$, seed, predictions; plus a
CSV download of the $49+T$ rows of $(s_t,\varepsilon^v_t)$ in use so Stata uses identical
observations (blueprint 5.4).

**Lab 3 — Where the band is narrow.**
*Learning question:* what does a restricted band condition on? *Invariants:*
the stored $3\times3$ covariances $\mathbf V$ from the authors' `gmmgbf.ster`
and from the matched `gmmgbf_nw6.ster` (§6 D10), with their point estimates,
and the stored unrestricted se path (stored results, labelled). *Controls:*
$h$ (slider 0–48, default 26); a toggle between the matched run (6 lags,
`rz` and six lags, 121 rows; default) and the authors' run (179 lags,
current `rz`, 127 rows); a toggle "scale $\mathbf V$ by $k$" ($k\in[0.25,4]$)
to show the band is proportional to the parameter uncertainty; a toggle
showing $\nabla\mathcal G_h$ components. *Computation:* live — $\nabla\mathcal G_h$,
$\operatorname{se}_h=\sqrt{\nabla\mathcal G_h'\mathbf V\nabla\mathcal G_h}$, the ratio to
the unrestricted se, a bar chart of the three gradient contributions.
*Predict prompt:* "At $h=h^\star$, which parameter's uncertainty matters? At $h=0$?"
*Reactive sentence:* "At month **{h}** the restricted band is
**{ratio}×** the unrestricted band; **{share_a}%** of its variance comes
from $\hat a$, **{share_hstar}%** from $\hat h^\star$, **{share_c}%** from $\hat c$
(cross terms **{share_x}%**). The band is narrow here because the shape,
not the data, fixes the path near **{g}**." *Comparisons:* (1) $h=26$ vs
$h=1$; (2) $h=19$, where the ratio peaks (0.89 matched, 0.75 authors'), then switch
runs and name what besides the shape moved the ratio; (3) scale $\mathbf V$ by 4
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
minimum distance in $(a,h^\star,c)$, $J$, condition number; under full
$\hat{\boldsymbol\Sigma}$ weighting, degrees of freedom and the $\chi^2$ p-value
(regularized incomplete gamma); under diagonal weighting $J$ is a weighted
sum of $\chi^2(1)$ variables with no $\chi^2$ reference, so the panel shows
$J$ with a simulated p-value: 100,000 draws from
$\mathcal N(\mathbf 0,\hat{\boldsymbol\Sigma})$ on the chosen subset
(`mulberry32(8)`, computed once per subset), each passed through the
diagonal-weighted residual maker of the Gaussian fit linearized at the
estimates, then the diagonal-weighted quadratic form; $p$ is the share of
draws above $J$. *Predict prompt:* "Will
using all 49 horizons make the test more or less reliable?" *Reactive
sentence:* "On **{n}** horizons the distance-minimizing shape is
$a=${a}, $h^\star=${hstar}, $c=${c}; $J=${J} on **{dof}** degrees of freedom
($p=${p}, **{χ² | simulated}**); the covariance's condition number is **{cond}**, so
**{verdict-sentence about whether the quadratic form is trustworthy}**."
*Comparisons:* (1) every 6th vs every 1st; (2) full vs diagonal weighting on
all 49 (the diagonal $J$ has no $\chi^2$ reference); (3) drop $h\le5$ — does the rejection come from the early dip?
*Handoff:* the subset and weighting the student would report, and why.

**Lab 5 — Export a shape (transfer to Stata).**
*Learning question:* can Stata reproduce what the browser computed on the
same observations? *Controls:* pick a shape (A/B/C or the custom
$(a,h^\star,c)$ from Lab 1 plus an optional second bump), $\lambda$, $r$, $T$,
$\sigma_{\varepsilon v}$, $\rho_v$. *Computation:* live restatement of the Lab 2 fits on
the chosen settings. *Export:* `handoff/p08-handoff.json` (settings,
browser estimates of $(a,h^\star,c)$, the spline path at $\lambda$, df, the CV
$\lambda$, predictions) and `handoff/p08-draws.csv` (columns `t`, `s`, `ev` for $\varepsilon^v_t$).
STA08 Task 1 reads the CSV, rebuilds $y$, and asserts the Stata estimates
match the browser's to the stated tolerances; the reactive sentence lists
the three numbers the student must see again in Stata.

---

## 8. Practicum plan (REP08, STA08, HTML08 handoff)

### REP08 — Raw versus restricted responses

| Field | Value |
|---|---|
| Paper and version | Jordà and Taylor (2025), "Local Projections," *JEL* 63(1), 59–110; JEL-Code commit `655696c1c576b7537c5a939d2c261f0a111ae663` (the supplied `LP_JEL_Replication.zip` is identical per the replication manifest); CC0 1.0 |
| Exact target | Figure 6a (unrestricted LP-IV path with 68/95% HAC bands and the joint test) and Figure 6b (Gaussian-basis path with delta-method bands and the printed parameters, which JT's output names `a0`, `b0`, `c0`); the numerical targets are the 49 coefficients and se, $\chi^2(49)$, and $(a,h^\star,c)$ with se — an exact replication with the authors' HAC choice reported as theirs (D14) |
| Kind | **Exact numerical replication** (deterministic; no random draws) |
| Data and vintage | `Example6_JointInference/data_fred.dta`, dated 30 March 2023; FRED `UNRATE`, `PCEPI`, `FEDFUNDS` (monthly, 1965m12–2008m12) and `RRCGShock` (Coibion et al. 2017); sample 1985m1–2000m1 |
| Original script and lines | `GMM_LPIV_GBF_estimate_part1.do`: sample lines 34–35; outcome construction line 42; residualization lines 52–53 (outcome), 58 (treatment), 65 (instrument); unrestricted GMM system lines 78–87; storage of estimates line 91; joint test lines 97–107; save line 108; Gaussian GMM lines 125–137; `nlcom` path lines 144–145; `t` index line 206; save line 210. `GMM_LPIV_GBF_output_part2.do`: replay and test lines 13–15; Gaussian replay line 35; Figure 6a lines 52–67; Figure 6b lines 70–90 |
| Benchmark | `benchmarks/REP08-gaussian-basis.csv` (148 rows, Stata/SE 18.5, *benchmarked*): 49 $\hat\beta_h$ with se, $T_H=121$ ($\hat\beta_0=-0.106426$ (0.103634), $\hat\beta_{48}=0.177344$ (0.626619)); $\chi^2(49)=446.89$; $a=1.387518$ (0.277854), $h^\star=26.189304$ (0.922304; `/b0`), $c=12.996609$ (0.891059), $T_H=127$; covariances in `raw/`. Same values as the authors' 15 July 2024 log. The stored `gmm.ster` matches to $10^{-13}$ ($\hat\beta_h$); the 19.5 Part 2 replay prints identical output; the 19.5 Part 1 re-estimation belongs to the instructor build (D1, D3) |
| Tolerance | Absolute $10^{-6}$ on the 49 $\hat\beta_h$, their se, $(a,h^\star,c)$, and their se against `REP08-gaussian-basis.csv` (the benchmark README's $10^{-6}$; the stored `gmm.ster` already agrees to $10^{-13}$ on $\hat\beta_h$); $\chi^2(49)$ to $10^{-4}$ against the full-precision `test` on the stored `gmm.ster` (446.888634 in StataNow/SE 19.5, 13 September 2026; `raw/REP08-joint-test.json` holds only the printed 446.89, which must agree at printed precision); $T_H$ (121 unrestricted, 127 Gaussian) exact. Any excess between the 18.5 benchmark and a 19.5 rerun is a *software* row in the discrepancy log (D1); on the same Stata version it indicates a specification change |
| Runtime | Part 1: 979.9 s in the benchmark run (manifest `REP08-layout-estimation`, rc 0), above the 10-minute ceiling (D2); two 19.5 scratch attempts did not finish. Part 2: 2.0 s in 19.5. Per D3 the project ships the authors' stored `gmm.ster` and `gmmgbf.ster` (CC0); `rep08.do` re-estimates behind `global REESTIMATE 1`, which the instructor build runs once and records agreement |
| Deliberate departures | (1) The course figure plots $\hat\beta_h$ and $\mathcal G(h)$ at horizon $h$; the published panels plot horizon $h+1$ at axis position $h$ and omit $\hat\beta_0=-0.106$ (0.104) and $\mathcal G(0)=0.024$, because `replace bj = _b[/b\`i'] if _n == \`i'` never fires for $i=0$ and `t=_n-1`. Logged as a *presentation* discrepancy (L14 taxonomy). (2) Bands are drawn at $z_{0.84}=1$ and $z_{0.975}=1.96$ exactly as JT do; the course labels them 68% and 95%. (3) The Gaussian GMM's HAC bandwidth (Stata default $N-2=179$ lags) is kept and reported as the authors' choice (D14); STA08 Task 5(c) and §6 D10 re-estimate with 6 lags, the unrestricted system's instruments (`rz`, `L(1/6).rz`), and its 121 rows, which gives the matched se ratio the notes quote. (4) Fonts: no Palatino/cmsy10 requirement. (5) Sample follows the code, 1985m1–2000m1 (lines 34–35); any difference from Figure 6's note, transcribed from the frozen JEL text, is logged (D14). (6) The notes may state the offset in (1) neutrally, citing lines 91, 145, 206; authors not contacted (D6) |

*Discrepancy guidance for students.* Likely causes, in order: wrong sample
(the `drop if` lines run before residualization, so $T_H$ must be 121/127);
wrong instrument set (six lags of `rz` in the unrestricted system, none in the
Gaussian one); reading the figure's horizon axis literally; `gmm` starting
values for (`/a0`, `/b0`, `/c0`) other than JT's $(1,24,10)$ can converge to the same optimum
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
values; posts $(a,h^\star,c)$ and the `nlcom` path). *Assertions:* the 49 OLS
coefficients equal those from the stacked file's horizon-by-horizon
regressions ($10^{-8}$); `nl` $(a,h^\star,c)$ match the browser's to $10^{-4}$;
`gbf_gmm` (iid weights) matches `nl` to $10^{-4}$. *Expected output:*
`output/task1_paths.dta`, figure `output/task1.pdf` (truth, OLS, Gaussian).

**Task 2 · Instructional extension: the penalized spline.** Apply
`lp_spline` (Mata: `bspline()`, `diffmat()`, ridge solve, `blockcv()`) to
the same stacked file at the CV $\lambda$; report $\lambda_{\mathrm{CV}}/T$,
df, and the path; then, as a labelled instructional extension (D28), apply
it to the JT reduced-form unemployment response and divide by $\hat\pi$.
*Assertions:* at $\lambda=10^{-4}$ the
path equals the OLS path within $10^{-3}$; at $\lambda=10^{10}$, $r=2$, the
second differences are below $10^{-6}$; df$(\lambda_{\mathrm{CV}})\in(2,49)$;
on the JT reduced form $\hat\pi$ matches `tests/benchmarks.dta` to $10^{-6}$
(prototype 0.6506). *Expected output:* `output/task2_spline.dta`,
`output/task2_cv.pdf`, `output/task2_jt_spline.dta`.

**Task 3 · Diagnose: vary the tuning parameter.** Loop $\lambda/T$ over the
51-point grid; save the path, df, and CV-MSE at each; plot the penalty path
and the CV curve. *Assertion:* CV-MSE is minimized at the $\lambda$ that
`lp_spline` reports. *Expected output:* `output/task3_path.pdf`,
`output/task3_grid.dta`.

**Task 4 · Diagnose: a second hump and a sign reversal.** Run
`mc_shapes.do` at `global R 200` (D2), `set seed 8`, once per shape (B, then
C, as separate commands under the 10-minute ceiling); tabulate bias, sd, and
MC standard error at $h=3,8,26,40$ for the three estimators; plot MC mean
paths over the truth. *Assertions:* the log records the seed and $R$; under
C, when $\hat a>0$ in every replication the Gaussian mean path is $\ge0$ at
every $h$ (prototype: 200/200), and its bias at $h=3$ exceeds OLS's by more
than ten MC standard errors (prototype $+0.499$ vs $-0.012$); OLS bias is
reported, not asserted zero (§6 D1). *Expected output:* `output/task4_mc.dta`,
`output/task4.pdf`, a written interpretation in the do-file header.

**Task 5 · Interpret: the limits of the inference.** On the JT data:
(a) compute the Gaussian delta-method band from the authors' `gmmgbf.ster` and
the unrestricted band and report their ratio at $h=1,19,48$, labelled the
authors' ratio; (b) compute the minimum-distance
Gaussian fit and $J$ on every 6th horizon using the shipped
`data/raw/jt_beta_sigma.dta` (49×49, from the authors' stored `gmm.ster`), then
on all 49, and explain the difference with the condition number; (c) re-run
the Gaussian GMM on the matched specification of §6 D10
(`instruments(rz l(1/6).rz)`, `vce(hac nw 6)`, 121 rows), report how
$(a,h^\star,c)$ and their se change, recompute the ratio of (a) at
$h=0,1,19,26,48$, and say how much of the authors' narrowing survives; (d) write the data-or-structure memo (Exercise 9). *Assertions:*
authors' ratio at $h=1$ between 0.15 and 0.25; matched run `e(N)==121` and
matched ratio at $h=48$ between 0.10 and 0.16 (19.5: 0.129); $J$ on every 6th horizon between 4 and
8 with 6 d.o.f.; the memo file exists and names five features. *Expected
output:* `output/task5_bands.pdf`, `output/task5_memo.md`.

**Runtime (D2).** The instructor build times each row in StataNow/SE 19.5
batch mode (`stata-se -e do`) and records it here before the practicum ships.
The lab-project routines are not written yet, so only Task 5(c) has a
measured time.

| Step | Command timed | 19.5 batch time | If over 10 minutes |
|---|---|---|---|
| Task 2 | `lp_spline` with `lambda(cv)` (51-point grid, 5 folds) on the seed-8 draw, then on the JT reduced form | to measure | split by data set; tag the JT part [extra] (D26) |
| Task 3 | the $\lambda/T$ grid loop (51 fits with df and CV-MSE) | to measure | split the grid across commands; tag [extra] (D26) |
| Task 4 | `mc_shapes.do`, `global R 200`, seed 8, one command per shape (A, B, C timed separately) | to measure | split by estimator within a shape; tag Task 4 and Exercise 7 [extra] (D26) |
| Task 5(c) | the matched Gaussian GMM alone (§6 D10) | 13.1 s (scratch run, 13 September 2026); 6 lags on JT's 127-row design 2.2 s | ship `gmmgbf_nw6.ster` with re-estimation behind `global REESTIMATE 1` (D3); not needed at 13.1 s |
| `master.do` | all tasks with `REESTIMATE 0` | to measure | the ceiling applies per command; the total is reported on the setup page |

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
MATLAB is required. Deliberate departure (D23): course $r=2$ where the port
sets $r=3$ (`LP_shrink_est.m` line 15, `irfLimitOrder = 2`); it covers BB too
if their frozen text differs. The authors' stored `.ster` files ship (D3, D5).

### Submission package

| Deliverable | Contents for P08 |
|---|---|
| Replication record | target (JT Fig 6a–b, commit, CC0), data vintage (30 Mar 2023), `rep08.log`, the numerical comparison table (49 coefficients, se, $\chi^2$, $(a,h^\star,c)$ with se), the horizon-offset entry in the discrepancy log |
| Stata submission | `master.do`, logs, `output/*.dta`, five figures, `tests/checks.do` passing |
| Interpretation record | estimand (pp of unemployment per pp of the funds rate, $h\le48$), assumptions (L3/L4 identification; A1 shape adequacy; A2 smoothness target), units, uncertainty (which band conditions on what), limitations (the two tests' dependence on $\hat{\boldsymbol\Sigma}$) |
| Lab record | the five predictions, chosen settings, the Lab 4 subset and verdict, the memo paragraph |

---

## 9. Slides arc

1. **Title.** Smoothing and restrictions across horizons.
2. **Forty-nine free parameters.** JT Figure 6a at correct horizons; the referee's question.
3. **Freedom is variance.** The stacked design; se from 0.10 to 0.63; nothing links $h$ to $h+1$.
4. **Three numbers.** $a$, $h^\star$, $c\sqrt{\ln2}$ on the anatomy figure; units.
5. **Estimating a shape.** NLS on the stack; GMM when instrumented; the delta-method band.
6. **What changed.** Figure 6b over 6a: $a=1.39$ (0.28), $h^\star=26.2$ (0.9), $c=13.0$ (0.9); $\hat\beta_1$ outside the band.
7. **Local bumps and a roughness penalty.** The B-spline basis; $\lambda\|\mathbf D_2\boldsymbol\delta\|^2$; the closed form.
8. **Turning the dial.** Penalty path on the seed-8 draw with the CV minimum; df from 49 to 2.
9. **What each restriction cannot draw.** The shape table (unimodal, single-signed, symmetric; smooth, toward a line).
10. **Seed 8.** The 3×3 misspecification panel; where each bias sits.
11. **Narrow where assumed.** The matched se ratio (§6 D10): 0.22 at $h=1$, 0.89 at $h=19$, 0.13 at $h=48$; the authors' 0.19, 0.75, 0.07 also move with 179 HAC lags, instruments, and sample; conditional on A1.
12. **Does the shape pass?** $J$ on 9 horizons as the headline, then 13, 25, 49 and the condition number (D27).
13. **Data or structure?** The five-feature memo on Figure 6.
14. **The question for Lecture 9.** Is the response the same in a recession?

---

## 10. Open questions for the editor

1. Resolved: D20 — peak horizon written $h^\star$ throughout; `b` only in JT code quotations; mapping in footnote (ix).
2. Resolved: D21 — Gaussian response described as a three-parameter parametric family in §1, §2, §3.
3. Resolved: D23 — $r=2$ throughout; LPW's $r=3$ logged as a deliberate departure in §8 provenance.
4. **Do BB smooth the control coefficients?** The LPW port partials out the intercept and controls horizon by horizon and penalizes only the basis coefficients (`locproj_partitioned.m`); its README says the BB code was modified only for run time. Confirm against BB's original MATLAB before the notes describe "the" BB estimator.
5. Resolved: D14 — 179-lag HAC reported as the authors' choice (§8 departure 3, footnote (ii)); the lecture's se ratio comes from the matched 6-lag run (§6 D10, STA08 Task 5(c)), and the 179-lag ratio appears only as the authors' reported ratio in `fig-l08-se-ratio`.
6. Resolved: D14, D6 — offset stated neutrally with do-file lines, corrected in figures and se ratios, logged; authors not contacted.
7. Resolved: D27 — every-sixth-horizon test is the headline; all-horizon sequence shows the near-singular covariance (§1, §2, §6 D7, §9).
8. Resolved: D23 — $\lambda/T$ everywhere; footnote (viii) maps it to BB's $\lambda$.
9. Resolved: D28 — JT-data spline confined to one evidence paragraph and STA08 Task 2; `fig-l08-penalty-path` and Exercise 10 moved to the seed-8 draw.
10. Resolved: D3 — Part 1 takes 979.9 s; authors' stored `.ster` files ship, re-estimation behind `global REESTIMATE 1` (§8 Runtime).
11. Resolved: D31 — reading guide cites sections of the `VERIFIED.md` versions (R02, R10), page ranges "to confirm".
12. Resolved: D22 — the three new keys enter `terminology-plan.md` when first marked (§1); "shrinkage toward a polynomial" stays a footnote.
13. **Finite-sample bias in the seed-8 design.** At $T=181$ the prototype's unrestricted LP is biased toward zero at long horizons (shape A, $h=26$: $-0.248$, 6.6 MC standard errors), and the Gaussian fit inherits the bias (§6 D1). Keep $T=181$ and read restricted-estimator bias against both $\theta_h$ and the OLS mean path, or raise $T$ for `fig-l08-misspecification` so that the figure isolates the restriction? The instructor build should confirm the bias in Stata first.
14. **Exercise 7 and STA08 Task 4 runtime.** The prototype needs 16 s per replication per shape with a least-squares ridge solve, 0.05 s with cached normal equations; the Stata/Mata timing, recorded in the STA08 runtime table (§8), decides whether D26 tags Exercise 7 [extra].
15. **Prototype numbers.** Prototype values in §4, §6, §8 (MC at $R=200$) reach the notes only after the Stata/Mata build regenerates them; its $R=500$ MC uses another random stream, so agreement is judged within MC error.
