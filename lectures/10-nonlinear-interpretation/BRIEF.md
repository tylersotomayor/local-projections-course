# Lecture 10 brief — What linear LPs mean in nonlinear economies

Planning brief for `lectures/10-nonlinear-interpretation/` (notes, exercises,
glossary, slides, figures), `interactives/10-causal-weight-explorer.qmd`
("Causal-Weight Explorer"), and `practica/p10-nonlinear-interpretation/`.
Written against the course spine (Lecture 10 and the seams with Lectures 9
and 11), the notation ledger, the terminology plan, the blueprint
(Sections 1, 4, 5, Lecture 10, R12), the authoring guide, MANIFEST §REP10,
and editor decisions D1, D2, D5, D15, D20, D24, D26, D30, D31.

Verification status. Every number below was produced in this planning pass
or read from a validated benchmark. (i) The authors' three do-files were
copied unchanged to the scratch directory
`…/scratchpad/design-10/rep10/` and run in StataNow/SE 19.5 (revision
12 Aug 2026): no Stata error lines; the 1,026 benchmark rows of
`REP10-causal-weights.csv`, all 4,088 rows × 30 columns of
`raw/REP10-all-weights.csv`, and the four government-spending columns of
`raw/REP10-shock-q.csv` agree with the 18.5 benchmark with maximum absolute
difference exactly 0 (D1). (ii) A course-built do-file,
`design-10/course/l10_course.do` (6 s wall), computes the exact weight
function in double precision, checks it against regressions, reproduces the
authors' float tie behaviour, runs the Monte Carlo (`global R`: 200 for the
student default, rerun at the D2 instructor value 500 in 6.9 s, whose first
200 replications are identical), and runs the
negative-weight illustration; its outputs are `l10_course_results.csv`,
`l10_ramey_weights.csv`, `l10_mc.dta`. (iii) Python scripts
`l10_checks.py`, `l10_ties.py`, `l10_bad_quad.py` in `design-10/` recompute
moments, integrals, and one closed-form quadrature from the benchmark CSVs.
(iv) The section structure of Kolesár and Plagborg-Møller (KPM) was read from
arXiv 2411.10415 v4 (15 July 2025), the version matching code commit
`4834381` (16 July 2025). The frozen version in `VERIFIED.md` (R12, the
*JBES* 43(4) article) could not be opened (publisher 403). Per D31 the
reading guide names sections of that frozen article and says "section
numbers from the frozen version; page range to confirm". The arXiv v4
section and proposition numbers quoted in this brief are only a mapping, to
be checked against the article before the guide is written.

---

## 1. Session brief

**Opening situation.**
Lecture 4 estimated a multiplier from Ramey's military-news series and
Lecture 9 asked whether it depends on slack. This lecture looks at the
post-war version of that series used by Kolesár and Plagborg-Møller, which is
built differently (see the anchor example). After the residualization KPM use (two lags of news, output,
spending, and taxes, plus a quadratic trend, post-1947 sample), there are 265
quarterly news shocks from 1947Q4 to 2013Q4. Measured in standard deviations,
one of them, 1950Q3 (Korea), equals 14.33; the next largest is 1.85; the
sample skewness is 11.13. Suppose output responds more than proportionally
to large buildups. Then the linear LP coefficient is an average of marginal
effects at different shock sizes, and the averaging weights come from this
distribution rather than from the researcher: 67.0 percent of the weight
sits above two standard deviations, all of it in the gap between 1.85 and
14.33, and 87.0 percent sits on positive shocks. Drop the single quarter
1950Q3 and the weight on positive shocks falls to 45.1 percent. Nothing
about the economy's response has changed; the coefficient has.

**Decision or empirical question.**
A researcher reports $\hat\beta_h$ from a linear LP on an observed shock and
a referee asks whether the economy is nonlinear. Which causal statement does
$\hat\beta_h$ still support, which does it not, and how does one show the
referee which shock sizes the number is about? The lecture's answer: with an
observed shock that is independent of everything else, $\beta_h$ is a
weighted average of marginal effects with nonnegative weights that integrate
to one and depend only on the shock distribution; those weights can be
computed and must be reported; the guarantee weakens with linear controls,
proxies, and polynomial specifications; and a change in $\hat\beta_h$ across
samples or series may be a change in the weights, not in the response.

**Target student and prerequisites.**
Completed Lectures 1–9. Uses from earlier lectures: $\beta_h$ versus
$\theta_h$ and conditional exogeneity (L3); the Ramey military-news shock and
LP-IV (L4); the interacted LP, support, and sign asymmetry (L9, used as prose).
Mathematics: covariance algebra, the fundamental theorem of calculus, a step
function, the standard normal density. Stata: `regress`, `gsort` with running
sums, `postfile`, `bsample`, `levelsof`. No nonparametric estimation is
assumed or taught.

**Learning outcomes (five).**

1. Distinguish the marginal effect $\theta_h(e)$, the per-unit finite-shock
   effect $[\psi_h(e')-\psi_h(e)]/(e'-e)$, and the linear coefficient
   $\beta_h$, and state what $\beta_h$ equals when $\psi_h$ is nonlinear.
2. Derive $\omega_h(e)=\operatorname{Cov}(\mathbb 1\{s_t\ge e\},s_t)/\operatorname{Var}(s_t)$,
   show it is nonnegative, integrates to one, peaks at $\mathbb E[s_t]$, and
   does not depend on $h$; compute it exactly from a shock series.
3. State when the weighted-average reading fails or changes: a linear control
   with a nonlinear propensity (negative weights), a proxy (scale and
   monotonicity), a polynomial specification (negative weights under
   misspecification).
4. Separate a change in the shock distribution from a change in the response
   function by predicting and then computing $\beta_h$ for a fixed
   $\theta_h(\cdot)$ under several distributions.
5. Reproduce KPM Figure 1 (government spending) with the authors' code,
   compare with the benchmark at $10^{-6}$, and explain its estimand and its
   plotting convention.

**Anchor example.**

*Data.* KPM replication repository, commit
`48343812993bb18c1516c8746a064b330761beed` (MIT code; bundled Ramey (2016)
Handbook files, third-party). Series `gov_ramey`: residual from
`reg newsy L(1/2).newsy L(1/2).y L(1/2).g L(1/2).tax t t2 if postwwii==1`
(`save_shocks.do` lines 17–23). `newsy` $=100\times$`rameynews`$/(\text{L.yquad}\times\text{L.pgdp})$,
percent of the previous quarter's nominal quadratic-trend GDP
(`data/Ramey_HOM_govtspending/jordagov_edit.do` lines 42, 99–105). This is not the Ramey–Zubairy `newsy` of the course's
fiscal anchor (Lectures 1 and 4). That series comes from `RZDAT.xlsx` (April
7, 2016 update), is `news`$/(\text{L.rgdp\_pott6}\times\text{L.pgdp})$ as a
fraction, and covers 1889Q1–2015Q4. KPM's series instead comes from the
bundled Ramey (2016) Handbook file `homgovdat.xlsx`, is scaled by
quadratic-trend GDP rather than `rgdp_pott6` and multiplied by 100, starts
after 1947, and is residualized on lags that include taxes. The notes say this
where the series first appears. Its standard-deviation units and 1950Q3
$=14.33$ cannot be compared numerically with Lecture 1's 0.600 or Lecture 4's
residualized 0.592. Raw
residual standard deviation 0.0375358; `compute_weights.do` line 30 divides
by it, so the working unit is one standard deviation. The plotted weights are the
LP's causal weights if this residualized series is the shock, with $\psi_h$
defined on it. If raw news is $s_t$ and the controls enter the LP as
$\mathbf w_t$, the weights are
$\operatorname{Cov}(\mathbb 1\{s_t\ge e\},\tilde s_t)/\operatorname{Var}(\tilde s_t)$,
with $\tilde s_t$ the residual of $s_t$ on $\mathbf w_t$. Those weights are
guaranteed nonnegative only if $\mathbb E[s_t\mid\mathbf w_t]$ is linear
(§6.5). 265 nonmissing quarters,
1947Q4–2013Q4. Largest three: 1950Q3 (14.3336), 1951Q2 (1.8545), 1980Q1
(1.6210). Contrasts from the same run: `gov_blanchardperotti` (269 quarters,
1948Q3–2015Q3, skewness 0.300), `gov_fisherpeters` (246, 1947Q3–2008Q4,
−0.086), `gov_benzeevpappa` (238, 1948Q3–2007Q4, 3.716), and the monthly
`mon_gertlerkaradi` (268 months, 1990m3–2012m6, skewness −2.264, 57.8
percent of shocks positive).

*Response functions (supplied, not estimated).* Quadratic
$\psi(e)=e+\tfrac{\nu}{2}e^{2}$, $\theta(e)=1+\nu e$, default $\nu=0.1$;
saturating $\psi(e)=\bar e\tanh(e/\bar e)$, $\theta(e)=\operatorname{sech}^2(e/\bar e)$,
default $\bar e=2$. Units: outcome per one-standard-deviation shock at
$e=0$; one horizon is shown because the weights are the same at every $h$.

*Simulations.* (a) Monte Carlo `l10_course.do` §3: `global R` (instructor
build 500 per D2, student default 200), `set seed 10`,
$T=265$, $y=\psi(s)+u$, $u\sim\mathcal N(0,1)$, $\nu=0.1$; shocks either
bootstrapped (`bsample 265`) from the standardized Ramey series or drawn
$\mathcal N(0,1)$. (b) Negative-weight illustration §4: $T=10^6$,
`set seed 20260913`, $w_t,\xi_t$ i.i.d. $\mathcal N(0,1)$,
$s_t=w_t^3+\sigma_\xi\xi_t$ with $\sigma_\xi\in\{0,0.5,1\}$,
$y_t=\Phi(2s_t)+0.5w_t$, LP with $w_t$ as a linear control.

**Smallest useful model (ledger notation).**
$$
y_{t+h}=\psi_h(s_t)+u_{t,h},\qquad s_t\perp u_{t,h},\qquad
\theta_h(e)=\psi_h'(e),
$$
with $\beta_h=\operatorname{Cov}(y_{t+h},s_t)/\operatorname{Var}(s_t)$ the
LP estimand without controls. Then
$\beta_h=\int\omega_h(e)\,\theta_h(e)\,de$ with
$\omega_h(e)=\operatorname{Cov}(\mathbb 1\{s_t\ge e\},s_t)/\operatorname{Var}(s_t)$,
which depends only on $f_s$. Under the quadratic,
$\beta_h=\theta_h(\mathbb E s_t)+\tfrac{\nu}{2}\,\sigma_s\operatorname{skew}(s_t)$:
1.555315 on the Ramey distribution, 1 under $\mathcal N(0,1)$, 0.991667 on
Ramey without 1950Q3 (§6.3).

**Dependency chain of sections.** The eight spine steps in spine order. Steps
2–4 are retitled because KPM's labels differ from the spine's; see §10, Q1.

1. `#sec-l10-nonlinear-response` *A response that depends on the size of the
   shock.* When $\psi_h$ curves, the effect of a one-unit shock depends on
   where it starts, so marginal, finite-shock, and linear effects become
   three different numbers.
2. `#sec-l10-weights` *What the linear coefficient averages.* Writing
   $\psi_h(s)$ as an integral of its derivative and taking the covariance
   with $s_t$ shows that $\beta_h$ is a nonnegative, unit-mass, horizon-free
   weighting of $\theta_h(e)$ (KPM Proposition 1, §3.1).
3. `#sec-l10-negative-weights` *When the weights change meaning: controls and
   proxies.* The guarantee needs the shock's conditional mean to be linear in
   the controls, and with a proxy it needs monotonicity and holds only up to
   scale. A linear control on a cubic propensity produces negative weights,
   and a negative $\beta_h$ even though every marginal effect is positive
   (KPM §3.2–3.3).
4. `#sec-l10-nonlinear-specifications` *A nonlinear regression is not a
   nonlinear economy.* Adding $s_t^2$ fits a curve whose implied marginal
   effects are again weighted averages, some with negative weights, and on a
   skewed series they can have the wrong sign (KPM Proposition 2).
5. `#sec-l10-computing-weights` *Computing the weights from a shock series.*
   The weight function of a sample is a step function given by a running sum
   from the top, the authors' indicator regressions reproduce it, and float
   storage decides at which end of each step a value is recorded.
6. `#sec-l10-distribution-vs-response` *A moved coefficient is not a moved
   response.* Holding $\theta_h(\cdot)$ fixed while changing $f_s$ (Gaussian,
   Ramey, Ramey without one quarter) moves $\beta_h$ from 1 to 1.555 to 0.992,
   and a bootstrap shows the coefficient splitting into two groups according
   to whether 1950Q3 is drawn.
7. `#sec-l10-evidence` *Evidence: the weights behind government-spending
   shocks.* KPM Figure 1, reproduced exactly: the news-based series (Ramey,
   Ben Zeev–Pappa) put 0.870 and 0.671 of their weight on positive shocks,
   so LPs estimated from them largely describe military buildups.
8. `#sec-l10-handoff` *Panels add units; do they add identification?* Every
   weight here comes from the time-series distribution of one shock, and the
   next lecture asks what a cross-section of units exposed to that shock
   adds.

**Central notation.** From the ledger: $t,T,h,H$, $y_{t+h}$, $s_t$,
$\mathbf w_t$ (here a scalar $w_t$), $\beta_h,\hat\beta_h$, $\theta_h(e)$,
$\omega_h(e)$, $f_s$, $\sigma_s$, $u_{t,h}$, $z_t$, $R$, $s_t^{+}$. New
(Section 2): $\psi_h(e)$, $\omega^{+}$, $s_{(k)}$, $\hat\omega_h(e)$, $\nu$,
$\bar e$, $\tilde s_t$, $\xi_t$, $\sigma_\xi$, $\zeta(e)$,
$f_{\mathcal N}$, $\Phi$, $\operatorname{skew}(\cdot)$.

**Glossary terms (owned keys; all nine used).**

- `nonlinear-response-function` — The function $\psi_h(e)$ that gives the
  average outcome $h$ periods after a shock of size $e$; linear models assume
  it is a straight line, and this lecture does not.
- `marginal-effect` — The slope $\theta_h(e)=\psi_h'(e)$: the effect per unit
  of a very small additional shock at size $e$. In a nonlinear economy it is
  a function, not a number.
- `finite-shock-effect` — The change $\psi_h(e')-\psi_h(e)$ produced by moving
  the shock from $e$ to $e'$; per unit, it averages $\theta_h$ over $[e,e']$
  with equal weights, which is why large and small shocks can differ.
- `causal-weight` — The weight $\omega_h(e)$ a linear LP places on the
  marginal effect at $e$; for an observed independent shock it equals
  $\operatorname{Cov}(\mathbb 1\{s_t\ge e\},s_t)/\operatorname{Var}(s_t)$.
- `weighted-average-effect` — An estimand of the form
  $\int\omega_h(e)\theta_h(e)\,de$ with $\omega_h\ge0$ and $\int\omega_h=1$:
  a causal summary whose meaning depends on the weights.
- `shock-distribution` — The distribution $f_s$ of the observed shock in the
  estimation sample; it alone determines the causal weights, so two samples
  with the same economy can yield different coefficients.
- `linear-approximation` — Reading $\beta_h$ as the slope of a line fitted to
  a curve: it summarizes $\psi_h$ over the shocks that occurred and says
  nothing about shock sizes outside their support.
- `negative-weights` — Weights below zero on some shock sizes, which let an
  estimand take a sign opposite to every marginal effect; they arise with
  linear controls on a nonlinear propensity and in misspecified polynomial
  LPs.
- `policy-relevant-effect` — The effect for the shock sizes and signs a
  decision contemplates (a retrenchment, a small surprise); it coincides with
  $\beta_h$ only when the decision's weights match the sample's.

**Likely explanatory footnotes.** KPM's own labels: "the good" is observed
shocks and proxies (§3), "the bad" identification through heteroskedasticity
(§4), "the ugly" identification through non-Gaussianity (§5). A VAR with the
shock ordered first has the same estimand given enough lags (KPM §3.1). The
finite-shock average of KPM eq. (4) tends to the marginal average as the
shock shrinks. Fubini and the integrability conditions behind Proposition 1.
The mutually-exclusive-dummies case in which linear controls are safe.
Proxy weights integrate to $\operatorname{Cov}(s_t,z_t)/\operatorname{Var}(z_t)$
(attenuation). Float versus double comparisons in Stata. The robust standard
errors on the weight function are pointwise and ignore estimation of the
residualization and of $\sigma_s$. Angrist (2001) on linear methods and
limited dependent variables, as KPM cite it.

**Candidate figures** (`figures/fig-l10-*.tex` with the shared `lpfig.tex`;
data from committed CSVs or Lua arithmetic).

| Label | Question | Lesson | Data or formula |
|---|---|---|---|
| `fig-l10-nonlinear-response` | What does one linear coefficient summarize when the slope changes with shock size? | $\theta(e)=1+0.1e$ rises; $\beta=1$ under $\mathcal N(0,1)$ and $1.555$ under Ramey; the Ramey value equals $\theta$ at $e=5.55$, where no shock occurred | Formula; shock rug from `l10_ramey_weights.csv` |
| `fig-l10-ramey-weights` | Which shock sizes does an LP on the Ramey series average over? | Exact step weights, peak 0.1849 near 0, a 0.0543 plateau from 1.85 to 14.33 carrying 0.678 of the mass; $f_{\mathcal N}$ overlaid with peak 0.3989 | `l10_ramey_weights.csv` (left limits), $f_{\mathcal N}$ |
| `fig-l10-two-distributions` | Does the coefficient move when only the shock distribution changes? | Same $\theta$; weights and $\beta$ for Gaussian (1), Ramey (1.555), Ramey without 1950Q3 (0.992), Blanchard–Perotti (1.015) | `l10_course_results.csv`, `l10_ties.py` output |
| `fig-l10-bootstrap-split` (droppable per D24) | How does a coefficient behave when one quarter carries most of the weight? | Bootstrap $\hat\beta$ splits ($R=500$): 320 draws with 1950Q3, mean 1.594; 180 without, mean 0.985 | `l10_mc.dta` (instructor build, $R=500$) exported to CSV |
| `fig-l10-negative-weights` | How can a linear control make an average of positive effects negative? | $\omega(e)=(a^2-1)f_{\mathcal N}(a)/6$, $a=e^{1/3}$, negative on $\lvert e\rvert<1$; simulated points for $\sigma_\xi=0,0.5,1$ | Closed form; `l10_course_results.csv` |
| `fig-l10-gov-weights` | Which shock sizes do four government-spending series weight? | Four exact step weight functions with $\omega^{+}$ labels 0.520, 0.497, 0.671, 0.870 | Benchmark CSV; course redraw per §8.1 |

**Exercise capabilities.** Tell marginal, finite, and linear effects apart
by hand; derive the weight representation and its properties; compute
weights for a five-point distribution; build the exact weight function in
Stata and verify it against regressions; derive negative weights with a
linear control; compute $\beta$ for supplied response functions under
several distributions and verify the skewness identity; run and read a
bootstrap; replicate REP10 and diagnose its plotting convention; show a
quadratic LP giving a wrong-signed marginal effect; handle proxy weights and
scale (extra).

**Controlled experiments (HTML lab).** Response shape and a finite shock
against a fixed distribution; the weight function of a chosen series with
the peak and $\omega^{+}$; a fixed $\theta$ across distributions, with the
option to drop one quarter; a linear control with a variable propensity
noise; a quadratic LP fitted to a saturating truth.

**Postponed.** Nonparametric estimation of $\theta_h(\cdot)$ (spine).
Identification through heteroskedasticity or non-Gaussianity (KPM §§4–5; one
footnote). KPM §6 on weighted regressions that target other averages
(further reading). Inference on weighted averages. State-dependent weights
beyond the L9 seam. Panels (L11).

**Question handed on.** What identifying information does a cross-section
of countries add to a common shock?

---

## 2. Concept and notation ledger

New symbols do not reassign any ledger symbol. $c$ (L8 width), $\kappa$ (L7),
$\pi$ (L4), $\delta_k$ (L8), $\phi_t$ (L11), and $k$ (L12) are avoided on
purpose: curvature is $\nu$, the saturation scale is $\bar e$, the standard
normal density is $f_{\mathcal N}$, a finite shock runs from $e$ to $e'$, and
a standardized shock is "$s_t$ in standard-deviation units". $z_t$ keeps its
ledger meaning as an instrument/proxy (§3).

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $s_t$ | Observed shock (military-news residual) | scalar | $t$ | s.d. of the residual (raw 0.0375358 percent of lagged nominal trend GDP) | §1 | all |
| $y_{t+h}$ | Outcome at horizon $h$ | scalar | $t+h$ | outcome units per the design | §1 | §§2–6 |
| $\psi_h(e)$ | Nonlinear response function: average $y_{t+h}$ when $s_t=e$, up to a constant | function $\mathbb R\to\mathbb R$ | shock $t$, outcome $t+h$ | outcome units | §1 | §§2–4, 6, labs 1, 3 |
| $\theta_h(e)$ | Marginal effect $\psi_h'(e)$ (ledger) | function | as $\psi_h$ | outcome per s.d. | §1 | all |
| $[\psi_h(e')-\psi_h(e)]/(e'-e)$ | Per-unit finite-shock effect | scalar | as $\psi_h$ | outcome per s.d. | §1 | ex. 1, lab 1 |
| $\beta_h$, $\hat\beta_h$ | LP estimand and estimate (ledger) | scalar | row $t$ | outcome per s.d. | §1 | all |
| $\omega_h(e)$ | Causal weight (ledger); the same for every $h$ with an observed shock | function, $\ge0$ in §2 | none beyond $f_s$ | per s.d. of shock (a density-like object) | §2 | §§3–7 |
| $\hat\omega_h(e)$ | Sample weight function, a left-continuous step function | step function | sample | per s.d. | §5 | §7, REP10, STA10 |
| $f_s$, $\sigma_s$ | Shock density and s.d. (ledger) | — | sample or population | — ; raw units | §2 | §§5–6 |
| $\omega^{+}$ | Total weight on positive shocks, $\int_0^\infty\omega_h(e)\,de$ | scalar in $[0,1]$ | — | share | §2 | §§6–7, fig `gov-weights` |
| $s_{(k)}$ | $k$-th smallest shock in the sample | scalar | — | s.d. | §5 | §6.2 |
| $\nu$ | Curvature of the quadratic response, $\theta(e)=1+\nu e$ | scalar | — | per s.d.$^2$ | §1 | §§4, 6, labs 1, 3 |
| $\bar e$ | Scale of the saturating response $\bar e\tanh(e/\bar e)$ | scalar | — | s.d. | §4 | lab 4, ex. 9 |
| $\operatorname{skew}(s_t)$ | Third standardized moment ($n$ divisor) | scalar | sample | none | §6 | ex. 6 |
| $w_t$ | Single control (ledger $\mathbf w_t$) | scalar | $t$ | s.d. | §3 | lab 4, ex. 5 |
| $\tilde s_t$ | Residual of $s_t$ after linear projection on $w_t$ | scalar | $t$ | s.d. | §3 | ex. 5 |
| $\xi_t$, $\sigma_\xi$ | Variation in $s_t$ not explained by $w_t$, and its s.d. | scalar | $t$ | s.d. | §3 | lab 4 |
| $z_t$, $\zeta(e)$ | Proxy (ledger) and its conditional mean $\mathbb E[z_t\mid s_t=e]$ | scalar; function | $t$ | proxy units | §3 | ex. 10 |
| $f_{\mathcal N}$, $\Phi$ | Standard normal density and c.d.f. | functions | — | — | §2 | §3 |
| $\mathbb 1\{\cdot\}$ | Indicator | — | — | 0/1 | §2 | §5 |
| $R$ | Monte Carlo replications (ledger; D2) | integer | — | — | §6 | STA10 |

The notes write $\omega_h(e)$ throughout, as the ledger does. Section 2 shows
that $\omega_h$ does not depend on $h$ for an observed shock, apart from the
horizon-specific sample $\mathcal T_h$ losing its last $h$ quarters.

---

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition or note | First marked |
|---|---|---|---|---|
| nonlinear response function | glossary | `nonlinear-response-function` | as §1 | `#sec-l10-nonlinear-response` |
| marginal effect | glossary | `marginal-effect` | as §1 | `#sec-l10-nonlinear-response` |
| finite-shock effect | glossary | `finite-shock-effect` | as §1 | `#sec-l10-nonlinear-response` |
| causal weight | glossary | `causal-weight` | as §1 | `#sec-l10-weights` |
| weighted-average effect | glossary | `weighted-average-effect` | as §1 | `#sec-l10-weights` |
| shock distribution | glossary | `shock-distribution` | as §1 | `#sec-l10-weights` |
| linear approximation | glossary | `linear-approximation` | as §1 | `#sec-l10-weights` |
| negative weights | glossary | `negative-weights` | as §1 | `#sec-l10-negative-weights` |
| policy-relevant effect | glossary | `policy-relevant-effect` | as §1 | `#sec-l10-distribution-vs-response` |
| the good, the bad, the ugly (KPM) | footnote | — | KPM's labels for observed shocks and proxies, heteroskedasticity, and non-Gaussianity identification | `#sec-l10-weights` |
| propensity score (linear) | footnote | — | $\mathbb E[s_t\mid w_t]$; linear controls keep weights nonnegative when it is linear, automatically so for mutually exclusive dummies | `#sec-l10-negative-weights` |
| attenuation (proxy scale) | footnote | — | Proxy weights integrate to $\operatorname{Cov}(s_t,z_t)/\operatorname{Var}(z_t)$, so effects are identified up to scale | `#sec-l10-negative-weights` |
| float precision | footnote | — | Stata's `float` stores about seven digits, so `v >= l` can exclude the observation equal to the level `l` | `#sec-l10-computing-weights` |
| stairstep | footnote | — | Stata's `connect(stairstep)` draws flat then vertical, holding each value until the next $x$ | `#sec-l10-computing-weights` |
| support; sign asymmetry | prose, linked to L9 glossary | (L09 keys) | Used, not re-marked | §§1, 6 |
| conditional exogeneity; observed shock; identification | prose, linked to L1/L3 | (L01/L03 keys) | Used, not re-marked | §§2–3 |
| LP-IV; external instrument | prose, linked to L4 | (L04 keys) | Used for the proxy case | §3 |
| Monte Carlo simulation; statistical reproduction | prose, linked to L2 | (L02 keys) | The bootstrap in §6 is labeled a course simulation | §6 |
| vector autoregression | prose, linked to L7 | (L07 key) | One sentence: same estimand with the shock ordered first | §2 |

No new glossary keys are needed, so `terminology-plan.md` does not change (D22).

---

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| The Ramey series is extremely skewed, driven by one quarter | $T=265$, skewness 11.127315, max 14.3336 (1950Q3), next 1.8545 | prose + table | `raw/REP10-shock-q.csv`; `l10_checks.py` | computed | `tbl-l10-shock-series` |
| $\beta_h$ is a nonnegative weighted average of $\theta_h$ | Derivation §6.1; exact integral of the sample weights $=1$ to $10^{-10}$ (assert) | equation | KPM Prop. 1; `l10_course.do` §1 | derived, verified | `eq-l10-weights` |
| Gaussian weights equal the density | $\mathbb E[s\mathbb 1\{s\ge e\}]=f_{\mathcal N}(e)$; peak 0.398942 | equation + figure overlay | §6.1 | derived | `fig-l10-ramey-weights` |
| Ramey weights: peak 0.1849 near 0; 0.678 of the mass in (1.8545, 14.3336]; $\omega^{+}=0.8699$ | Running-sum formula; regression of $\max(s,0)$ on $s$ (robust s.e. 0.01734) | figure | `l10_ramey_weights.csv`, `l10_course_results.csv` | computed | `fig-l10-ramey-weights` |
| Same $\theta$, different $f_s$, different $\beta$ | Quadratic $\nu=0.1$: Gaussian 1, Ramey 1.555315, Ramey without 1950Q3 0.991667, BP 1.014984, GK 0.887037; saturating $\bar e=2$: Ramey 0.307499, without 1950Q3 0.896285 | figure + table | `l10_course_results.csv`, `l10_ties.py` | computed | `fig-l10-two-distributions`, `tbl-l10-beta-by-distribution` |
| A skewed series makes the coefficient fragile across samples | Bootstrap $R=500$ (instructor build, D2): mean 1.3749, s.d. 0.3082, p10 0.9059, p50 1.5429, p90 1.6578; with 1950Q3 (320 draws) mean 1.5942, without (180) 0.9849; Gaussian mean 0.9993, s.d. 0.0619 | figure (droppable) or table | `l10_mc.dta` ($R=500$) | stored simulation result | `fig-l10-bootstrap-split` |
| Linear control + nonlinear propensity gives negative weights and a wrong-signed $\beta$ | Closed form $\omega(0)=-0.066490$, $\beta=-0.027650$; simulation $-0.066214$, $-0.027543$; $\sigma_\xi=0.5$: $\omega(0)=-0.00799$, $\beta=-0.00543$; $\sigma_\xi=1$: all positive, $\beta=0.02688$ | figure | `l10_bad_quad.py`; `l10_course.do` §4 | computed; course illustration of KPM §3.3 | `fig-l10-negative-weights` |
| A quadratic LP can give a wrong-signed marginal effect | Saturating truth on Ramey: $b_1=0.881051$, $b_2=-0.051642$; implied $\theta(14.3336)=-0.599382$ vs true $2.38\times10^{-6}$; without 1950Q3 $b_2=+0.018558$ | table | `l10_course_results.csv` | computed; course illustration of KPM Prop. 2 | `tbl-l10-quadratic-lp` |
| KPM Figure 1 reproduces exactly in 19.5 | 1,026 benchmark rows, max abs diff 0; $\omega^{+}$ labels 0.520/0.497/0.671/0.870 | figure + replication table | REP10 rerun, `design-10/rep10/` | computed | `fig-l10-gov-weights`, `tbl-l10-rep10` |
| The authors' plot mixes left and right limits | Float ties: 87 of 265 levels excluded (Ramey), 62/269 BP, 63/246 FP, 65/238 BZP; L1 area between plotted and exact step 0.0148 (Ramey), 0.0423, 0.0205, 0.0262 | footnote + discrepancy log | `export_full.do`, `l10_ties.py` | computed | footnote in `#sec-l10-computing-weights` |
| News shocks mostly describe buildups | KPM §3.1 text on Ramey and Ben Zeev–Pappa; $\omega^{+}$ 0.870, 0.671 | prose | KPM arXiv v4 §3.1 | read | `#sec-l10-evidence` |

---

## 5. Assessment map

Ten exercises: four [computational] in Stata, one of them [data]. Solutions
check against numbers in §6. Hints never give the final number.

| Outcome | No. and title | Tags | Mode | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. Three effects of one curve | [core] [pencil] | For $\psi(e)=e+0.05e^2$: $\theta(e)$ at $e=-1,0,2$; per-unit finite effect from 0 to 2; show that for a quadratic it equals $\theta$ at the midpoint; $\beta$ under $\mathcal N(0,1)$ | "Which of the three objects depends on the shock distribution?" | 0.9, 1, 1.2; 1.1 $=\theta(1)$; $\beta=1$ | 1 |
| 2 | 2. Derive the causal weights | [core] [pencil] | Write $\psi(s)-\psi(a)=\int(\mathbb 1\{s\ge e\}-\mathbb 1\{a\ge e\})\theta(e)\,de$, take covariances, prove $\omega\ge0$, $\int\omega=1$, the peak at $\mathbb E s$, $\omega=f_{\mathcal N}$ for a standard normal | Suggest applying the identity to $\psi(s)=s$ | §6.1 steps; $\omega(0)=0.398942$ | 2 |
| 2 | 3. Weights for five shocks | [core] [pencil] | Shocks $\{-1,-1,0,0,2\}$: the step weights, $\omega^{+}$, $\beta$ for exercise 1's $\psi$ both by the weights and by $\operatorname{Cov}/\operatorname{Var}$; the regression at $e=2$ with $\ge$ versus $>$ | Tabulate $\sum_{s_i\ge e}(s_i-\bar s)$ from the top | $\tfrac13$ on $(-1,0]$ and $(0,2]$; $\omega^{+}=\tfrac23$; $\beta=1.05$; $\tfrac13$ vs 0 | 2 |
| 2, 5 | 4. Exact weights for the Ramey series (Stata) | [core] [computational] | From `shock_q.dta`: standardize in double, running sum from the top, left and right limits, assert the integral equals 1, regressions at ranks 1, 100, 133, 264, 265, $\omega^{+}$ | Name the sort order and the denominator, not the command | Rank 264: $x=1.854502$, left 0.0613186, right 0.0542940; $\omega^{+}=0.869910$; asserts at $10^{-10}$ | 2 |
| 3 | 5. A linear control on a cubic propensity | [core] [pencil] | $s=w^3$, control $w$ linearly: find the projection coefficient, $\operatorname{Var}(\tilde s)$, and $\omega(e)$; show negative weights on $\lvert e\rvert<1$; explain why $\sigma_\xi>0$ helps | Give $\int_a^\infty x^3f_{\mathcal N}=(a^2+2)f_{\mathcal N}(a)$ | 3; 6; $(a^2-1)f_{\mathcal N}(a)/6$; $\omega(0)=-0.066490$ | 4 |
| 4 | 6. One response, four distributions (Stata) | [core] [computational] [data] | Quadratic ($\nu=0.1$) and saturating ($\bar e=2$) $\psi$ applied to Gaussian, Ramey, Ramey without 1950Q3, Blanchard–Perotti, Gertler–Karadi; verify $\beta=\theta(\mathbb E s)+\tfrac{\nu}{2}\sigma\operatorname{skew}$ | "Which moment of $f_s$ enters when $\theta$ is a line?" | Table §6.3; identity assert at $10^{-10}$ | 3 |
| 4 | 7. When one quarter decides (Stata) | [computational] | Bootstrap with `global R` (student default 200, seed 10) versus Gaussian draws; split the Ramey draws by whether 1950Q3 was drawn; write two sentences for a referee | Suggest recording a 0/1 flag per draw | Reference (instructor build, $R=500$): means 1.3749 / 0.9993; split 1.5942 (320) and 0.9849 (180). A student run at $R=200$ agrees within Monte Carlo error (seed 10 gives 1.3807 / 1.0013; 1.5997 (128) and 0.9915 (72)) | 3 |
| 5 | 8. Replicate KPM Figure 1 and read it (Stata) | [core] [computational] [data] | Run the three author do-files, compare with the benchmark CSV, redraw with the exact step convention, and write the estimand in two sentences | Point to `connect(stairstep)` and to the storage type of the shock | Max abs diff $\le10^{-6}$ (0 in the build); 87 excluded ties for Ramey | 2 |
| 3 | 9. Polynomials are not nonlinear economies | [computational] | Fit $\psi=2\tanh(s/2)$ with a quadratic LP on the Ramey series with and without 1950Q3; compare the implied $\theta$ at the largest shock with the truth; relate the result to KPM Prop. 2 | Ask for the sign of the true $\theta$ everywhere | $b_2=-0.051642$ vs $+0.018558$; $-0.599382$ vs $2.38\times10^{-6}$ | 4 |
| 3 | 10. Proxies and scale | [extra] [pencil] | $z=s+\eta$ and $z=\mathbb 1\{s>1\}$: derive $\tilde\omega(e)=\operatorname{Cov}(\mathbb 1\{s\ge e\},\zeta(s))/\operatorname{Var}(z)$, its total mass, and when it is nonnegative | Separate the scale from the shape | Mass $\operatorname{Cov}(s,z)/\operatorname{Var}(z)$; nonnegative for monotone $\zeta$ (KPM Prop. 3) | 4 |

Evidence in at least two media for each outcome: 1 (prose, `fig-l10-nonlinear-response`,
ex. 1, lab 1); 2 (equation, `fig-l10-ramey-weights`, ex. 2–4, lab 2); 3
(`fig-l10-negative-weights`, `tbl-l10-quadratic-lp`, ex. 5, 9, 10, lab 4); 4
(`fig-l10-two-distributions`, ex. 6–7, lab 3, STA10 task 4); 5
(`fig-l10-gov-weights`, ex. 8, REP10).

---

## 6. Derivations to verify

### 6.1 The weight representation (KPM Proposition 1, scalar form)

*Source identity.* For $\psi$ locally absolutely continuous with derivative
$\theta$, and any fixed $a$:
$\psi(s)-\psi(a)=\int_{-\infty}^{\infty}\big(\mathbb 1\{s\ge e\}-\mathbb 1\{a\ge e\}\big)\theta(e)\,de$
(fundamental theorem of calculus; the integrand is $+\theta$ on $(a,s]$ when
$s>a$ and $-\theta$ on $(s,a]$ when $s<a$).

*Steps.* (1) $s_t\perp u_{t,h}$ gives $\operatorname{Cov}(y_{t+h},s_t)=\operatorname{Cov}(\psi_h(s_t),s_t)$.
(2) Take the covariance of both sides of the identity with $s_t$; the term in
$a$ is nonrandom. (3) Exchange covariance and integral (Fubini, under KPM's
moment conditions): $\operatorname{Cov}(\psi_h(s_t),s_t)=\int\operatorname{Cov}(\mathbb 1\{s_t\ge e\},s_t)\,\theta_h(e)\,de$.
(4) Divide by $\operatorname{Var}(s_t)$. *Nonnegativity:*
$\operatorname{Cov}(\mathbb 1\{s\ge e\},s)=P(s\ge e)\,(\mathbb E[s\mid s\ge e]-\mathbb E s)\ge0$.
*Unit mass:* apply steps 2–4 to $\psi(s)=s$, $\theta\equiv1$. *No $h$:* the
weight involves only $s_t$. *Peak:*
$\tfrac{d}{de}\int_e^\infty(x-\mu)f_s(x)\,dx=-(e-\mu)f_s(e)$, so the weight
rises up to $\mu=\mathbb E s$ and falls after it, with
$\omega(\mu)=\mathbb E\lvert s-\mu\rvert/(2\operatorname{Var}s)$. *Gaussian
case:* $\int_e^\infty xf_{\mathcal N}(x)\,dx=f_{\mathcal N}(e)$ because
$f_{\mathcal N}'(x)=-xf_{\mathcal N}(x)$, so $\omega=f_{\mathcal N}$, with peak
$1/\sqrt{2\pi}=0.398942$. *Positive-shock weight:* $\max(s,0)=\int_0^\infty\mathbb 1\{s\ge e\}\,de$,
so $\omega^{+}=\operatorname{Cov}(\max(s,0),s)/\operatorname{Var}(s)$ (the
authors' `compute_weights.do` lines 48–51); 0.5 under $\mathcal N(0,1)$.

*Numerical check (Ramey, `l10_course.do` §1).* $\omega^{+}=0.869910$ (robust
s.e. 0.017343; the author label reads 0.870); without 1950Q3, 0.451385;
Blanchard–Perotti 0.519835, Fisher–Peters 0.497411, Ben Zeev–Pappa 0.671410,
Gertler–Karadi 0.295224 (labels 0.520, 0.497, 0.671, 0.295). Exact peak
0.184905 near $e=0$. The weight on $(-\infty,0]$ is 0.130090, on $(0,2]$ it is
0.200270, and above 2 it is 0.669640.

### 6.2 The sample weight function and the authors' regressions

*Source identity.* With one regressor, OLS of $d_i$ on $(1,s_i)$ gives
$\sum_i(s_i-\bar s)d_i/\sum_i(s_i-\bar s)^2$. Take $d_i=\mathbb 1\{s_i\ge e\}$:
$\hat\omega(e)=\sum_{i:\,s_i\ge e}(s_i-\bar s)\big/\sum_i(s_i-\bar s)^2$.
*Steps.* Sort in descending order and take a running sum of $s_i-\bar s$. The
function is constant on $(s_{(k-1)},s_{(k)}]$, where it equals the left limit
at $s_{(k)}$ (tie included). On $(s_{(k)},s_{(k+1)}]$ it equals the right
limit (tie excluded). It is 0 below $s_{(1)}$ because deviations sum to zero,
and 0 above $s_{(T)}$. Its integral is
$\sum_k\hat\omega(s_{(k)})(s_{(k)}-s_{(k-1)})=1$.
These weights, like the authors', treat the residualized series as the shock.
They are the LP's causal weights when $\psi_h$ is defined on that residual. If
raw news is $s_t$ and the controls enter the LP as $\mathbf w_t$, the sample
weights become $\sum_{i:\,s_i\ge e}\tilde s_i\big/\sum_i\tilde s_i^2$, with
$\tilde s_i$ the residual of $s_i$ on $\mathbf w_i$. That is a different
function, guaranteed nonnegative only if $\mathbb E[s_t\mid\mathbf w_t]$ is
linear (§6.5).

*Numerical check.* Double precision: the integral equals 1 to $10^{-10}$ for
all four series (asserted). Regressions agree with the running sum to
$10^{-10}$ at ranks 1, 100, 133, 264, and 265. Rank 100: $x=-0.142469$,
weight 0.169250 (s.e. 0.112365). Rank 133: $x=-0.067749$, weight 0.181998.
Rank 264: $x=1.854502$, left 0.061319 (s.e. 0.008994), right 0.054294. Rank
265: $x=14.333603$, left 0.054294 (s.e. 0.012044), right 0.

*The authors' float tie.* `compute_weights.do` line 40 runs `gen ind = (v>=l)`
with `v` stored as `float` and `l` taken from `levelsof`. Rerun on the actual
`shock_q.dta` in 19.5, 87 of the 265 Ramey levels satisfy
`count if v>=l` $<$ `count if v>=float(l)`, so the tie is dropped there.
Comparing benchmark values with the exact left and right limits gives the
same split, 178 left and 87 right, and the other series give 207/62,
182/63 (plus one indistinct level), and 173/65. `plot_weights.do` line 22 uses
`connect(stairstep)`, which draws flat and then vertical and so holds each
value on $[x_k,x_{k+1})$. That is exact where the tie was dropped and one
support point off where it was kept. The L1 area between the plotted and the
exact step functions is 0.014781 for Ramey (maximum pointwise gap 0.008847,
at $x=-2.3357$), 0.042341 for BP, 0.020454 for FP, and 0.026204 for BZP. The
Ramey tail from 1.85 to 14.33 is drawn correctly because both of its end
levels dropped the tie. $\omega^{+}$ comes from a separate regression and is
unaffected.

### 6.3 Quadratic response: the skewness identity

*Source identity.* With $\psi(e)=e+\tfrac{\nu}{2}e^2$ and $s=\mu+\sigma x$,
$\operatorname{Var}x=1$: $s^2=\mu^2+2\mu\sigma x+\sigma^2x^2$, so
$\operatorname{Cov}(s^2,s)=2\mu\sigma^2+\sigma^3\mathbb E x^3$.
*Steps.* $\beta=1+\tfrac{\nu}{2}\operatorname{Cov}(s^2,s)/\sigma^2=1+\nu\mu+\tfrac{\nu}{2}\sigma\operatorname{skew}(s)=\theta(\mu)+\tfrac{\nu}{2}\sigma\operatorname{skew}(s)$.
Moments use the $n$ divisor, which is what OLS uses. Checked by the weights:
$\sum_k\hat\omega(s_{(k)})\big[(s_{(k)}-s_{(k-1)})+\tfrac{\nu}{2}(s_{(k)}^2-s_{(k-1)}^2)\big]=\beta$.

*Numerical check* ($\nu=0.1$ unless stated; regression, weights, and identity
agree to $10^{-10}$):

| Distribution | $\mu$ | $\sigma$ ($n$) | skew | $\beta$ quadratic | $\beta$ saturating $\bar e=2$ |
|---|---|---|---|---|---|
| $\mathcal N(0,1)$ (population) | 0 | 1 | 0 | 1 | 0.826484 |
| Ramey, 265 quarters | $-1.04\times10^{-9}$ | 0.998111 | 11.127315 | 1.555315 | 0.307499 |
| Ramey without 1950Q3 (same s.d. units) | −0.054294 | 0.467786 | −0.124149 | 0.991667 | 0.896285 |
| Blanchard–Perotti | 0 | 0.998139 | 0.300245 | 1.014984 | 0.764473 |
| Gertler–Karadi (monthly) | 0 | — | −2.2635 | 0.887037 | 0.635646 |

Ramey at $\nu=0.05$: 1.277658; at $\nu=0.2$: 2.110630. Hand check for
Ramey without 1950Q3: $1+0.1(-0.054294)+0.05(0.467786)(-0.124149)=0.991667$.

The $\mathcal N(0,1)$ saturating entry is a population value, not a
regression. Because $\omega=f_{\mathcal N}$,
$\beta=\mathbb E[\operatorname{sech}^2(s/2)]=0.826484$ (adaptive quadrature in
the repair pass, error below $10^{-13}$; the same value as
$\operatorname{Cov}(2\tanh(s/2),s)$ by Stein's lemma). The build recomputes
it and asserts at $10^{-6}$. The skewness identity holds only for the
quadratic, whose $\theta$ is linear. Under $\mathcal N(0,1)$ every shape has
$\beta=\mathbb E[\theta(s)]$. That equals $\theta(0)$ when $\theta$ is linear
and exceeds it when $\theta$ is convex: $\psi(e)=\exp(e)$ gives
$e^{1/2}=1.648721$. It falls below $\theta(0)$ for the saturating shape,
whose $\theta$ peaks at 0 (0.826484 < 1).

### 6.4 Bootstrap (course simulation, `l10_course.do` §3)

Design as in §1 (a). Population values: 1.555315 for the Ramey empirical
distribution (the bootstrap population) and 1 for the Gaussian. Instructor
build, $R=500$ (D2; 6.9 s wall in 19.5): Ramey mean 1.374872, s.d. 0.308213,
p10 0.905859, median 1.542882, p90 1.657822. 1950Q3 appears in 64 percent of
draws, close to $1-(264/265)^{265}=0.632$, with mean 1.594235 (320 draws)
versus 0.984893 (180). Gaussian: mean 0.999252, s.d. 0.061892. Labeled a
stored simulation result with $R=500$. Student default $R=200$ (the first 200
replications of the same stream, identical with maximum absolute difference
0): Ramey mean
1.380742, s.d. 0.309070, p10 0.933586, median 1.551051, p90 1.664140; with
1950Q3 1.599692 (128) versus 0.991498 (72); Gaussian mean 1.001289, s.d.
0.059170. STA10 task 3 compares these with the $R=500$ values within Monte
Carlo error.

### 6.5 Negative weights with a linear control (course illustration of KPM §3.3)

*Source identities.* For a standard normal $w$:
$\int_a^\infty xf_{\mathcal N}=f_{\mathcal N}(a)$,
$\int_a^\infty x^3f_{\mathcal N}=(a^2+2)f_{\mathcal N}(a)$, $\mathbb E w^4=3$,
$\mathbb E w^6=15$.
*Steps* ($\sigma_\xi=0$). The linear projection of $s=w^3$ on $w$ has slope
$\mathbb E w^4/\mathbb E w^2=3$, so $\tilde s=w^3-3w$ and
$\operatorname{Var}\tilde s=15-18+9=6$. By Frisch–Waugh–Lovell the LP
coefficient is $\operatorname{Cov}(y,\tilde s)/\operatorname{Var}\tilde s$.
The step-2–4 argument of §6.1 with $\tilde s$ in place of $s$ gives weights
$\operatorname{Cov}(\mathbb 1\{s\ge e\},\tilde s)/6$, which integrate to
$\operatorname{Cov}(s,\tilde s)/6=1$. With $a=e^{1/3}$, the weight is
$\mathbb E[(w^3-3w)\mathbb 1\{w\ge a\}]/6=(a^2-1)f_{\mathcal N}(a)/6$: negative
on $\lvert e\rvert<1$, zero at $\pm1$, and $-f_{\mathcal N}(0)/6$ at 0. Take
$y=\Phi(2s)+0.5w$. The term $0.5w$ is orthogonal to $\tilde s$, and
$\theta(e)=2f_{\mathcal N}(2e)>0$ everywhere, yet
$\beta=\int\omega\theta$.

*Numerical check.*

| Quantity | Closed form / quadrature | Simulation ($T=10^6$, seed 20260913) |
|---|---|---|
| projection slope | 3 | 3.004897 |
| $\omega(0)$ | −0.066490 | −0.066214 |
| $\omega(\pm0.5)$ | −0.017956 | −0.018052, −0.017715 |
| $\omega(\pm2)$ | 0.017660 | 0.017530, 0.017471 |
| $\int\omega$; mass on $(-1,1)$ | 1.000000; −0.043223 | — |
| $\beta$ with $w$ controlled | −0.027650 | −0.027543 |
| $\beta$ of $\Phi(2s)$ on $s$, no control | 0.051476 | 0.051266 |
| $\sigma_\xi=0.5$: $\omega(0)$; $\beta$ | — | −0.007992; −0.005431 |
| $\sigma_\xi=1$: $\omega(0)$; $\beta$ | — | 0.028096; 0.026884 |

The lesson for the notes: the more of the shock's variation lies outside the
controls, the less the functional form of the propensity matters. The example
is labeled course-built. KPM's statement is qualitative (§3.3).

### 6.6 A quadratic LP on a saturating truth (course illustration of KPM Proposition 2)

The regression of $2\tanh(s/2)$ on $(1,s,s^2)$ over the 265 Ramey values, with
no noise, gives $b_1=0.881051$ and $b_2=-0.051642$. The implied marginal
effect at $s_{(T)}=14.333603$ is $b_1+2b_2s_{(T)}=-0.599382$; the truth is
$\operatorname{sech}^2(7.1668)=2.38\times10^{-6}$, and the true $\theta$ is
positive everywhere. Without 1950Q3, $b_1=0.899378$ and $b_2=+0.018558$, so the
estimated curvature changes sign. KPM's Gaussian statement to quote:
$\bar\beta_h(x)=\mathbb E[(1+s_tx)\theta_h(s_t)]$, with weights negative
where $1+s_tx<0$.

### 6.7 REP10 numbers

See §8.1: 1,026 rows, 19.5 against 18.5, maximum absolute difference 0.
---

## 7. HTML lab plan (Causal-Weight Explorer, `interactives/10-causal-weight-explorer.qmd`)

Four Observable JS labs in chain order. Each has a setup, **Predict before
using the controls**, controls with units, a plot, a reactive sentence,
controlled comparisons, and a collapsed explanation. Every panel is labeled
*live calculation*, *stored result*, or *stored simulation result*. No dated
shock value reaches the browser (D5; the same rule as Lecture 1, Lab 4; §10,
Q3). The build writes one JSON of stored results, with commit and provenance
metadata. It covers each listed series and its "without 1950Q3" variant: the
undated step weight function (`x`, `w_left`, `w_right`, computed by the
running sum of §6.2 in double precision), the moments $\mu$, $\sigma_s$, and
$\operatorname{skew}$, and the Lab 4 panel B coefficients. Browser arithmetic
integrates response functions against these stored steps and never needs a
date. Build acceptance: the browser reproduces
$\omega^{+}=0.869910$ and $\beta=1.555315$ to $10^{-9}$.

**Lab 1 — Three effects of one curve (live).** *Question:* when the slope
changes with shock size, which number is "the effect"? *Invariants:*
distribution fixed at $\mathcal N(0,1)$, one horizon. *Controls:* shape
(linear / quadratic / saturating); $\nu\in[-0.2,0.2]$ per s.d.$^2$, default
0.1; $\bar e\in[0.5,5]$ s.d., default 2; start $e\in[-3,3]$, default 0; size
$e'-e\in[0.1,4]$, default 1. *Computation:* $\psi$, $\theta$, the finite
effect, and $\beta$ by quadrature against $f_{\mathcal N}$. *Reactive
sentence:* "A shock from 0.0 to 1.0 s.d. raises the outcome by 1.05 per unit.
The marginal effect is 1.00 at 0 and 1.10 at 1. Under a Gaussian shock the
linear coefficient is 1.00." *Comparisons:* move the start with the size
fixed; switch shape with the defaults fixed. *Predictions:* (1) "Under a
symmetric distribution, will a quadratic response push the linear coefficient
above the marginal effect at zero?" (Answer: no. For a quadratic the gap is
$\tfrac{\nu}{2}\sigma_s\operatorname{skew}(s_t)=0$, §6.3.) (2) "Under the same
distribution, is the coefficient for the saturating response above, equal to,
or below the marginal effect at zero?" (Answer: below.
$\beta=\mathbb E[\operatorname{sech}^2(s/2)]=0.826484$ under $\mathcal N(0,1)$
at $\bar e=2$, §6.3.)
*Handoff:* none; it feeds Lab 3.

**Lab 2 — The weights of a shock series (stored weights, live arithmetic).** *Question:* which shock
sizes does an LP on this series average over? *Invariants:* weights depend
only on the chosen series; no response function appears. *Controls:* series
(Gaussian, Ramey, Ramey without 1950Q3, Blanchard–Perotti, Fisher–Peters,
Ben Zeev–Pappa, Gertler–Karadi); display (exact step / authors' stairstep
convention); a threshold marker $e^\ast$ in s.d., default 2. *Computation:*
from the stored left and right limits of $\hat\omega$ (the "without 1950Q3"
entry is its own stored variant), $\omega^{+}$, the mass above $e^\ast$, and
the peak location. *Reactive sentence:* "Ramey: 87.0 percent of the weight is
on positive shocks and 67.0 percent above 2 s.d. The largest step,
0.0543, runs from 1.85 to 14.33 and exists only because 1950Q3 exists."
*Comparisons:* Ramey with and without 1950Q3; Blanchard–Perotti against
Fisher–Peters (0.520 and 0.497, close to the Gaussian 0.5); exact against
stairstep (the difference is visible only in sparse regions). *Prediction:*
"Where does the Ramey weight function peak: at the largest shock, at zero, or
at the median?" *Handoff:* exports `weights_<series>.csv`
(`x, w_left, w_right`) and the series metadata. STA10 task 1 asserts equality
to $10^{-9}$.

**Lab 3 — A moved coefficient is not a moved response (live, plus one stored
panel).** *Question:* if only the shock distribution changes, does $\beta$
change? *Invariants:* the response function is locked across distributions,
and the lock icon is shown. *Controls:* Lab 1's shape and parameters; two
distributions side by side; a "without 1950Q3" toggle (default off). It is
the only dropped-quarter variant the build stores, because no dated values
ship (D5). The
bootstrap panel is labeled *stored simulation result, $R=500$ (instructor build, D2), seed 10,
StataNow 19.5*. *Computation:* $\beta=\sum_k\hat\omega_k\,\Delta\psi_k$ live
and the identity of §6.3 displayed. The stored panel shows `l10_mc` as a
histogram split by whether 1950Q3 was drawn. *Reactive sentence:* "With the
same response ($\nu=0.10$), the coefficient is 1.00 under the Gaussian and
1.56 under the Ramey series. Dropping one quarter moves it to 0.99. No
marginal effect changed." *Comparisons:* change the distribution with the
shape fixed; change the shape with the distribution fixed; drop 1950Q3 under
the saturating shape (0.307 to 0.896). *Prediction (committed before reveal):*
"Will $\beta$ under the Ramey series be above, equal to, or below 1?" A
policy-relevant-effect prompt asks for $\theta$ averaged over negative shocks
only, a retrenchment, and compares it with $\beta$. *Handoff:*
`response_spec.csv` (shape, $\nu$, $\bar e$, series, 1950Q3 dropped 0/1) for
STA10 tasks 2 and 4.

**Lab 4 — When weights go negative (live).** *Question:* what makes an
average of positive effects negative? *Panel A, controls:* $\sigma_\xi\in[0,2]$,
default 0; control on/off; bump width of $\theta(e)=kf_{\mathcal N}(ke)$ with
$k\in\{1,2,4\}$, default 2. Computation: the closed form for $\sigma_\xi=0$
and a seeded ($\text{mulberry32}$) in-browser simulation with $T=20{,}000$
for $\sigma_\xi>0$, labeled with its Monte Carlo error. Sentence: "With
$w$ controlled linearly and $\sigma_\xi=0$, the weights are negative for
shocks between −1 and 1 and the coefficient is −0.028, although every
marginal effect is positive." *Panel B (stored result: the §6.3 and §6.6 coefficients), controls:* regression (linear /
quadratic); series (Ramey with or without 1950Q3); truth $2\tanh(s/2)$.
Sentence: "The quadratic LP implies a marginal effect of −0.60 at the largest
shock; the truth is 0.000002." *Comparisons:* raise $\sigma_\xi$ from 0 to 1
with the seed fixed; switch the control off (the confounding term $0.5w$
returns); drop 1950Q3 in panel B. *Prediction:* "Can $\beta$ be negative if
$\theta(e)>0$ for every $e$?" *Handoff:* design record
(`sigma_xi, k, T, seed`) for STA10 task 5. Final prompt: explain the whole
chain in words, linking to `#sec-l10-distribution-vs-response`.

---

## 8. Practicum plan (REP10, STA10, HTML10 handoff)

### 8.1 REP10 — Recover causal weights

**Target (D15).** Kolesár and Plagborg-Møller, "Dynamic Causal Effects in a
Nonlinear World: the Good, the Bad, and the Ugly," *JBES* 43(4), 737–754
(2025), DOI 10.1080/07350015.2025.2539478, the version frozen in
`VERIFIED.md` (R12). The reading guide names that article's sections and says
"section numbers from the frozen version; page range to confirm" (D31). arXiv
2411.10415 v4, read for this brief, gives only a section mapping, to be
checked against the article.
Figure 1, the government-spending weight functions: Ramey (military news),
Blanchard–Perotti, Fisher–Peters, and Ben Zeev–Pappa, the `fig/gov.png`
panel. **Exact numerical replication** of the plotted weights, their robust
s.e., and the $\omega^{+}$ labels. The horizontal axis is a shock threshold in
standard deviations, not a horizon.

**Code, data, vintage.** Repository `mikkelpm/nonlinear_dynamic_causal`,
commit `48343812993bb18c1516c8746a064b330761beed` (MIT; archive SHA-256
`2baa9f4b982816383e400057e12e3791ad648f65e8fb33efb052bb2266940a65`), frozen
at `replication-packages/packages/nonlinear-dynamic-causal/`. Data are the
bundled Ramey (2016) Handbook files (`Ramey_HOM_govtspending/homgovdat.xlsx`,
sheet `govdat`, via `jordagov_edit.do`), unmodified; the `_edit` files are
author-commented copies. Lines: `save_shocks.do` 12–35 (government
residuals; the regression is at line 21, $p=2$, `postwwii`);
`compute_weights.do` 29–30 (standardize), 33–45 (indicator regressions on the
support plus min−0.01 and max+0.01), 47–52 ($\omega^{+}$), 55–61 and 68–70
(save); `plot_weights.do` 18–28.

**Benchmark (from `REP10-causal-weights.csv`).**

| Series | Rows | N | Peak weight (s.e.) at $x$ | $\omega^{+}$ label |
|---|---|---|---|---|
| Ramey | 267 | 265 | 0.18490513 (0.11232752) at −0.0023352937 | 0.870 |
| Blanchard–Perotti | 271 | 269 | 0.36671612 (0.02949363) at 0.0036485903 | 0.520 |
| Fisher–Peters | 248 | 246 | 0.39101747 (0.020971144) at −0.0024718007 | 0.497 |
| Ben Zeev–Pappa | 240 | 238 | 0.30834776 (0.10088853) at −0.001363862 | 0.671 |

Ramey spot rows: $x=1.8545021$, $b=0.054293953$ (s.e. 0.01204442);
$x=14.333603$ and $14.343603$, $b=0$.

**Tolerance and result.** Tolerance $10^{-6}$ on $x$, $b$, and s.e.; N and
row counts exact (MANIFEST). The 19.5 build (D1) gives maximum absolute
difference 0 on all 1,026 rows, on all 30 columns of the raw weights, and on
`shock_q`, with no software row in the log. Runtime in 19.5 wall clock: 2 s,
14 s, 4 s (18.5 audit: 2.813, 13.628, 2.939 s).

**Dependencies.** `save_shocks.do` runs Ramey's `_edit` scripts, which still
call `ivreg2` (the log shows `ivreg2` lines executing), so `ivreg2` and
`ranktest` are required to run the original (D4 "optional" category). They
are therefore required for P10, and `master.do` checks for both before
anything runs (§8.2). Course code uses only built-ins.

**Departures and discrepancy log.** No departure in the replication itself.
Log rows: (1) *presentation*: `connect(stairstep)` combined with float ties
records 178 of 265 Ramey values as left limits and plots them one support
point to the right; L1 area 0.0148 (§6.2). The course figure is redrawn from
exact double-precision limits and the notes state this neutrally, following
the D14 pattern (see §10, Q4). (2) *interpretation*: the s.e. are pointwise
robust s.e. from indicator regressions and ignore the estimated
residualization and standardization; they are reported, not used for claims.

**Redistribution (D5).** `SOURCE.md` records MIT for code and "third-party
data may have separate terms" with no explicit data license. The lab project
therefore ships the author do-files with `LICENSE`, and
`data/raw/get_data.do` downloads the codeload archive for the commit,
verifies the SHA-256 above, and extracts `data/Ramey_HOM_*`. It stops with a
message if either step fails. `PROVENANCE.md` gives the manual fallback (the
GitHub commit page, then Ramey's replication page) and notes that generated
`shock_q.dta` and `weights.dta` are rebuilt locally, not shipped.

### 8.2 STA10 — Stata problem set

Construct, estimate, diagnose, interpret (blueprint §4.1). `master.do` sets
paths and checks dependencies first. It runs `capture which ivreg2` and
`capture which ranktest`, and if either is missing it stops with a message
naming `ssc install ivreg2`, `ssc install ranktest`, and the P10 `README.md`.
The check is needed because `jordagov_edit.do` calls `ivreg2` (lines 189, 200,
247) and `shock_q.dta` is rebuilt locally, not shipped (§8.1), so no task has
another input. It then calls `get_data.do`, runs REP10 once, and runs the five
task files; the full set runs in under 2 minutes at $R=200$.

1. *Reconstruct the weights* (`sta10_1_weights.do`). Input `shock_q.dta`,
   variable `gov_ramey`. Build `s` (double, s.d. units), `w_left`, `w_right`,
   and `gap`. Assert: the integral equals 1 ($10^{-10}$); five regressions
   match ($10^{-10}$); $\omega^{+}$ within $10^{-6}$ of 0.869910; the
   classification against the author `weights.dta` is 178 left and 87 right.
   Output `weights_ramey.csv`, compared with the Lab 2 export.
2. *Apply them to a supplied response* (`sta10_2_apply.do`). Read
   `response_spec.csv`; compute $\beta$ by weights and by `regress psi s`.
   Assert equality ($10^{-10}$) and 1.555315 for the default quadratic,
   0.307499 for the saturating response.
3. *Compare with an estimated LP coefficient* (`sta10_3_lp.do`). Simulate
   $y=\psi(s)+u$ on the 265 actual shocks and on $\mathcal N(0,1)$ draws,
   seed 10, $R=200$; tabulate mean, s.d., and deciles. Assert the Gaussian
   mean is within $3\times0.0592/\sqrt{200}$ of 1 and that the with-1950Q3
   draws average above the without-1950Q3 draws. Compare the means with the
   stored instructor result ($R=500$: 1.3749 Ramey, 0.9993 Gaussian) within
   Monte Carlo error ($3\times$s.d.$/\sqrt{200}$). Written: why the Ramey
   mean (1.381 at $R=200$) is below 1.555.
4. *Change the distribution, hold the response* (`sta10_4_distribution.do`).
   The §6.3 table for five distributions and two shapes; assert the
   skewness identity. Output `beta_by_distribution.csv` and
   `fig_two_distributions.pdf`.
5. *State the conditions* (`sta10_5_conditions.do` plus structured comments).
   The §6.5 simulation with $\sigma_\xi\in\{0,0.5,1\}$ ($T=10^6$, seed
   20260913, under 10 s). Assert $\hat\omega(0)<0$ and $\hat\beta<0$ at
   $\sigma_\xi=0$, and $\hat\beta>0$ at $\sigma_\xi=1$. Written: four
   conditions (independent observed shock; linear propensity when controls
   enter; monotone proxy, up to scale; no polynomial reading beyond the
   support) and one sentence on the policy-relevant effect.

Layout: `master.do`, `tests/` (tasks 1, 2, 4 assertions), `data/raw/`,
`output/`, `README.md` (lists `ivreg2` and `ranktest` as required for P10,
because REP10 runs author scripts; D4).

### 8.3 Handoff and submission package

Lab 2 exports `weights_<series>.csv`, Lab 3 `response_spec.csv`, and Lab 4
the design record. STA10 reads all three on common inputs (the same 265
values), so browser and Stata agree to $10^{-9}$. The simulated panels agree
only within Monte Carlo error, and the handoff says so. Submission: a
replication record (target, commit, data vintage, commands, 1,026-row
comparison, the two log rows); the Stata submission (`master.do`, log,
CSVs, figures, test logs); an interpretation record (estimand as a weighted
average, the weight function, $\omega^{+}$, units, pointwise s.e., four
conditions); and the HTML lab record (four predictions, settings, exports,
one paragraph on why a moved coefficient need not mean a moved response).
---

## 9. Slides arc

1. **Title.** What linear LPs mean in nonlinear economies.
2. **One quarter, 14 s.d.** The Ramey series and 1950Q3.
3. **Three effects of one curve.** Marginal, finite, linear.
4. **What $\beta_h$ averages.** $\int\omega_h\theta_h$ in three lines.
5. **The weights are the shock's.** Nonnegative, unit mass, no $h$; Gaussian equals density.
6. **Ramey weights.** `fig-l10-ramey-weights`: $\omega^{+}=0.870$.
7. **Same response, new distribution.** 1 → 1.555 → 0.992.
8. **When one quarter decides.** Bootstrap split.
9. **Controls can flip signs.** `fig-l10-negative-weights`.
10. **Polynomials are not economies.** −0.60 versus 0.
11. **Computing weights in Stata.** Running sum; ties; stairstep.
12. **Evidence.** `fig-l10-gov-weights`: news shocks describe buildups.
13. **Lab, exercises, and Lecture 11.** Do panels add identification?

---

## 10. Open questions for the editor

1. **Section labels.** KPM's "bad" and "ugly" are heteroskedasticity and non-Gaussianity identification (§§4–5), not the spine's controls and polynomials. Retitle spine steps 3–4 as in §1?
2. **Opening series.** The spine opens with a skewed monetary series; this brief uses Ramey news (D15, L4/L9) with Gertler–Karadi as contrast. Confirm.
3. **Browser data (owner, D5).** Default adopted in §7 and used for drafting: the browser receives only stored results (undated step weights, moments, and panel B coefficients for each series and its without-1950Q3 variant). No dated shock values ship, matching Lecture 1, Lab 4. Question for the owner: may standardized residual series ship? Only a ruling recorded under D5 in `docs/editor-decisions.md` would allow dated values and a free drop-quarter picker.
4. **Plot convention.** Apply D14's presentation-discrepancy rule to REP10?
