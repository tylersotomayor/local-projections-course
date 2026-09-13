# Lecture 07 brief — LPs versus VARs: estimands, bias, and variance

Planning brief for `lectures/07-lp-versus-var/` (notes, exercises, glossary,
slides, figures), `interactives/07-bias-variance-lab.qmd`, and
`practica/p07-lp-versus-var/`. Written against the course spine (Lecture 7
entry and the seams with Lectures 6 and 8), the notation ledger, the
terminology plan, the blueprint (Sections 1, 4, 5, and Lecture 7), and the
authoring guide. Every number quoted below was computed in this planning pass
in a scratch copy of the authors' code; the scratch directory and the scripts
that produced each number are named in Sections 6 and 8 so the notes author can
re-run them.

Verification status, in one paragraph. The Li–Plagborg-Møller–Wolf (LPW)
MATLAB package `lp_var_simul` (frozen commit `5a77715`, MIT) was copied to a
scratch directory and run with MATLAB R2024a in batch mode: the Stock–Watson
dynamic factor model (DFM) was estimated once (1,399 s), the authors' own
DGP-selection routine drew the seven fiscal DGPs of `spec_id = 1` and the
seven monetary DGPs of `spec_id = 1`, and 500 Monte Carlo draws per DGP were
run for least-squares LP, bias-corrected LP, least-squares VAR, and
bias-corrected VAR at $p=4$, $T=200$ (the paper uses 5,000 draws and 6,000
DGPs, so these are statistical reproductions of four of the paper's designs,
never a replication of its figures). A Stata port of LP, Herbst–Johannsen
bias-corrected LP, and the recursive VAR reproduces the MATLAB estimates draw
by draw to $10^{-7}$ on the exported simulated data. The smallest teaching
model was simulated in Stata (1,000 replications at $T=200$, plus three
controlled variants), and its population VAR(1) bias was derived by hand and
confirmed at $n=10^{6}$. The opening real-data comparison was run in Stata on
Jordà–Taylor's `data_fred.dta`.

---

## 1. Session brief

**Opening situation.**
Two researchers have the same monthly U.S. data — the unemployment rate, PCE
inflation, the federal funds rate, and the Romer–Romer monetary shock as
extended by Coibion, Gorodnichenko, Kueng, and Silvia — and the same
identifying assumption: the shock is exogenous, so it can be ordered first.
One fits a VAR with twelve lags and iterates it forward; the other runs
forty-nine local projections with the same twelve lags of the same four
series. At impact both report that a one-point shock lowers unemployment by
0.072 points. At six months the LP says $-0.213$ and the VAR $-0.139$; at
thirty months the LP says $+0.431$ and the VAR $+0.203$. Neither has made an
error, both have targeted the same object, and the reader who cannot say why
they differ cannot say which one to believe.

**Decision or empirical question.**
Given a fixed identifying assumption, a fixed sample, and a fixed set of
controls, which estimator of $\theta_h$ should be reported, and by which
criterion — bias, variance, mean squared error, or the coverage of the
interval around it — is one estimator "better" than another? The lecture's
answer is that the two estimators agree on *what* they estimate and disagree
on *how*, that the disagreement is a bias–variance trade-off whose terms can be
computed, and that the ranking depends on the criterion, the horizon, the lag
length, the sample size, and the data-generating process.

**Target student and prerequisites.**
A student who has completed Lectures 1–6: writes the horizon-$h$ regression
$y_{t+h}=\mu_h+\beta_h s_t+\boldsymbol\gamma_h'\mathbf w_t+u_{t,h}$ from memory,
distinguishes $\beta_h$ from $\theta_h$ and knows the conditions under which
they coincide (L3, assumptions A1–A3), can compute Newey–West and lag-augmented
standard errors and state what coverage means (L5), and has seen the stacked
vector $\hat{\boldsymbol\beta}$ with its cross-horizon covariance (L6).
Assumed Stata: `regress`, `newey`, `tsset` with leads and lags, `postfile`
loops, and matrix subscripts. Introduced here from scratch: the VAR as a
system of one-step regressions, the companion matrix, and iteration; no prior
VAR course is assumed. Matrices enter only after the two-variable VAR(1) has
been iterated by hand.

**Five or fewer learning outcomes.**

1. State the population equivalence: for a given lag length $p$, the LP and
   the recursive VAR in the same variables estimate the same $\theta_h$ at
   every horizon $h\le p$, and as $p\to\infty$ at every horizon; write the
   recursive VAR as a sequence of one-step regressions and iterate a
   two-variable VAR(1) by hand to any horizon.
2. Explain direct versus iterated estimation and, in the smallest model,
   derive the population VAR(1) response, show that it is biased at $h\ge2$
   when the lag structure omits a moving-average term, and show that the LP
   is unbiased in population at every horizon because $s_t$ is unpredictable.
3. Decompose the mean squared error of each estimator at each horizon into
   squared bias and variance from a Monte Carlo, and compute the bias weight
   $\omega^{*}_h$ at which a researcher is indifferent between LP and VAR.
4. Predict, then verify by simulation, how the bias and variance of each
   estimator move with the lag length $p$ and the sample size $T$, and state
   the two limits in which the estimators converge.
5. Separate point-estimation performance from interval performance, and read
   the LPW simulation study and the course's bounded port with the correct
   scope: what was held fixed, what "median across DGPs" means, what the four
   ported designs can and cannot claim.

**Anchor numerical or data example.**

*Real data (opening and closing figure).* Jordà–Taylor (2025) replication
package, `Example6_JointInference/data_fred.dta` (local copy
`~/JEL-Code-main 3/LP_JEL_Replication/Example6_JointInference/`; 517 monthly
rows 1965m12–2008m12). Series and units: `urate` = civilian unemployment rate,
percent, level; `infl` = PCE inflation as constructed by Jordà–Taylor
(annualized monthly percent change of `PCEPI`); `ffr` = effective federal
funds rate, percent; `RRCGShock` = Romer–Romer monetary shock extended by
Coibion, Gorodnichenko, Kueng, and Silvia (2017), percentage points of the
intended funds-rate change, mean zero, standard deviation 0.296, nonmissing
1969m3–2008m12 (478 rows). Specification: $s_t=$ `RRCGShock`, $y_t=$ `urate`,
$\mathbf w_t=$ twelve lags of `RRCGShock`, `urate`, `infl`, `ffr`; $p=12$,
$H=48$. LP by OLS horizon by horizon with Newey–West $m=h$ (466 rows at $h=0$,
418 at $h=48$); recursive VAR(12) in (`RRCGShock`, `urate`, `infl`, `ffr`)
with the shock ordered first (466 rows), response to a unit shock obtained by
dividing Stata's orthogonalized response by the shock equation's residual
standard deviation (0.2653), delta-method standard errors from `irf create`.
Values (unit shock, percentage points of unemployment):

| $h$ | 0 | 3 | 6 | 9 | 12 | 18 | 24 | 30 | 36 | 42 | 48 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| LP(12) | $-0.072$ | $-0.198$ | $-0.213$ | $-0.141$ | $0.057$ | $0.222$ | $0.384$ | $0.431$ | $0.177$ | $0.041$ | $-0.091$ |
| VAR(12) | $-0.072$ | $-0.175$ | $-0.139$ | $-0.115$ | $0.016$ | $0.171$ | $0.232$ | $0.203$ | $0.131$ | $0.052$ | $-0.015$ |
| se, LP (NW) | 0.041 | 0.063 | 0.097 | 0.117 | 0.105 | 0.127 | 0.148 | 0.135 | 0.123 | 0.149 | 0.113 |
| se, VAR (delta) | 0.027 | 0.057 | 0.084 | 0.102 | 0.112 | 0.110 | 0.108 | 0.114 | 0.128 | 0.142 | 0.152 |

The impact estimates are identical to every printed digit (they are the same
regression coefficient); the two paths separate after the third month and are
0.23 points apart at $h=30$. Script: `design-07/l07_realdata.do` in the
scratch directory named in Section 8; output `realdata_lp_var.csv`.

*Smallest simulation (the running numerical example).* The model of the next
paragraph with $\rho=0.5$, $\tau=0.5$, $\kappa=0.5$, $\sigma_v=1$, $s_t\sim
\mathcal N(0,1)$ i.i.d., $T=200$ after a burn-in of 100, horizons $0,\dots,8$,
$R=1{,}000$ replications, `set seed 7`, estimators LP(1), LP(2), VAR(1),
VAR(2). Controlled variants with $R=500$: $\kappa=0$ (VAR(1) correctly
specified), $T=800$, $T=100$. Script `l07_toy_mc2.do`, driver
`run_toy_configs.do`, outputs `toy_summary_{base,k0,T800,T100}.csv`.

*Bounded LPW port (REP07).* Four DGPs drawn by the authors' own
`pick_var_fn` with `spec_id = 1`: two fiscal (`dgp_type = 'G'`, government
spending fixed in position 1, response variable in position 2) and two
monetary (`dgp_type = 'MP'`, federal funds rate fixed in position 5, response
variable in position 1); observed-shock identification, unit-standard-deviation
shock, $T=200$, burn-in 100, $p=4$, $H=20$, 500 draws with the authors' seed
rule (`rng(1,'twister')`, then `seed(i) = 10 i + randi([0,9])`). The exported
draws, true responses, and MATLAB estimates are the benchmark inputs; Section
8 names the DGPs and the benchmark numbers.

**Smallest useful model (ledger notation).**
Outcome $y_t$, intervention $s_t$ observed and unpredictable, and a second
shock $v_t$ the researcher never sees:
$$
y_t=\rho\,y_{t-1}+\theta_0 s_t+\tau s_{t-1}+\kappa s_{t-2}+v_t,\qquad
s_t\sim\text{i.i.d.}(0,1),\quad v_t\sim\text{i.i.d.}(0,\sigma_v^2),\quad
\theta_0=1 .
$$
The true response is $\theta_1=\rho+\tau$, $\theta_2=\rho\theta_1+\kappa$,
$\theta_h=\rho\,\theta_{h-1}$ for $h\ge3$; with the baseline parameters,
$\theta=(1,\,1,\,1,\,0.5,\,0.25,\,0.125,\,0.0625,\,0.03125,\,0.015625)$ for
$h=0,\dots,8$. The VAR vector is $\mathbf y_t=(s_t,y_t)'$. The LP with $p$ lags is
$y_{t+h}=\mu_h+\beta_h s_t+\boldsymbol\gamma_h'\mathbf w_t+u_{t,h}$ with
$\mathbf w_t=(s_{t-1},\dots,s_{t-p},y_{t-1},\dots,y_{t-p})'$, and
$\beta_h=\theta_h$ for every $p\ge0$ because $s_t$ is orthogonal to
$\mathbf w_t$ and to every shock dated after $t$. The recursive VAR(1),
$\mathbf y_t=\mathbf c+\mathbf A_1\mathbf y_{t-1}+\mathbf e_t$ with $s_t$ ordered
first, implies $\theta^{\mathrm{VAR}}_h=\mathbf e_2'\mathbf A_1^{h}\mathbf g$
with $\mathbf g=(1,\ S_{21}/S_{11})'$, where $\mathbf S$ is the residual
covariance. The DGP is a VAR(2) in $\mathbf y_t$ exactly and a VAR(1) only
when $\kappa=0$: the population VAR(1) coefficients on $(s_{t-1},y_{t-1})$ in
the $y$ equation are $a_s=\tau-\kappa c$ and $a_y=\rho+\kappa c$ with
$c=\theta_1/(\gamma_0-1)$ and $\gamma_0=\operatorname{Var}(y_t)=
1+\theta_1^2+\theta_2^2/(1-\rho^2)+\sigma_v^2/(1-\rho^2)$. Baseline numbers:
$\gamma_0=4.6667$, $c=0.2727$, $a_y=0.6364$, $a_s=0.3636$;
$\theta^{\mathrm{VAR}}=(1,\,1,\,0.636,\,0.405,\,0.258,\,0.164,\,0.104,\,0.066,\,0.042)$,
so the population bias of the VAR(1) is $0$ at $h\le1$, $-0.364$ at $h=2$,
$-0.095$ at $h=3$, $+0.008$ at $h=4$, $+0.039$ at $h=5$, and decays from
there. Confirmed at $n=10^6$ (two seeds): $\hat a_s\in\{0.3664,0.3637\}$,
$\hat a_y\in\{0.6372,0.6357\}$, $\widehat{\operatorname{Var}}(y)\in\{4.689,4.650\}$,
LP(1) coefficients within $0.005$ of $\theta_h$ at $h=0,\dots,4$, VAR(2)
$y$-equation coefficients within $0.002$ of $(\tau,\rho,\kappa,0)$.

**Dependency chain of sections** (section titles and anchors; consistent with
the spine's eight steps, refined into nine numbered sections plus the
unnumbered apparatus).

1. `#sec-l07-two-answers` *Two answers to one question.* The unemployment
   response to the Romer shock from LP(12) and VAR(12) on identical data with
   identical identification agree at impact and part after three months, so
   the difference must lie in how each estimator uses the sample, not in what
   it targets.
2. `#sec-l07-same-estimand` *The same estimand.* Writing the recursive VAR as
   one-step projections shows that the VAR with $p$ lags and the LP with $p$
   lags are the same projection at $h\le p$ and that both converge to the same
   $\theta_h$ as $p\to\infty$ (Plagborg-Møller–Wolf), and that every LP
   identification scheme in the course — observed shock, recursive ordering,
   instrument ordered first — has a VAR counterpart that does not require the
   shock to be invertible.
3. `#sec-l07-direct-iterated` *Direct versus iterated.* In the smallest model,
   the LP projects $y_{t+h}$ on $s_t$ directly, while the VAR(1) projects one
   step ahead and multiplies by $\mathbf A_1$ $h$ times, so its response is
   exact at $h\le1$ and, when $\kappa\ne0$, wrong at $h\ge2$ by a population
   amount that can be computed by hand ($-0.364$ at $h=2$).
4. `#sec-l07-bias-variance` *Bias, variance, and mean squared error.* A
   Monte Carlo at $T=200$ shows the LP nearly unbiased with a standard
   deviation that doubles between $h=0$ and $h=3$, the VAR(1) biased where the
   population calculation says and less variable at every $h\ge2$, and the
   loss $L_\omega=\omega\,\mathrm{Bias}^2+(1-\omega)\operatorname{Var}$ makes
   the ranking a function of the bias weight $\omega$ through the indifference
   weight $\omega^{*}_h$.
5. `#sec-l07-lags-and-sample` *Lag length and sample size.* Adding the lag the
   DGP needs (VAR(2)) removes the population bias at a variance cost, adding a
   lag to the LP changes nothing in population and little in the sample, and
   quadrupling $T$ shrinks the LP's variance by a factor near four while
   leaving the VAR(1)'s bias untouched — so the two estimators converge as
   $p$ grows, not as $T$ grows, and information criteria pick short $p$.
6. `#sec-l07-coverage` *Point performance and interval performance.* A biased
   estimator with a narrow band under-covers by an amount fixed by its
   bias-to-standard-deviation ratio, so the VAR(1)'s 95 percent band at $h=2$
   covers far less often than the LP's Newey–West band even where the VAR has
   the lower mean squared error; the two criteria can rank the methods in
   opposite orders at the same horizon.
7. `#sec-l07-thousands` *Thousands of DGPs.* LPW draw 6,000 five-variable DGPs
   from a DFM fitted to the Stock–Watson data and find, at $T=200$ and $p=4$,
   the same trade-off in the median DGP — LP has lower bias and roughly twice
   the VAR's standard deviation at long horizons — with bias-corrected LP the
   best estimator only when $\omega\gtrsim0.9$ and VAR-type estimators
   (least-squares or Bayesian) otherwise; the estimators between the poles are
   named and located on the trade-off.
8. `#sec-l07-bounded-port` *A bounded port.* Four of LPW's DGPs, simulated by
   the authors' code and re-estimated in Stata with draw-by-draw agreement to
   $10^{-7}$, reproduce the qualitative profile in each design and show how
   much the profile moves across designs; the port cannot speak about medians
   over 6,000 DGPs, about Bayesian VARs, or about 5,000-draw precision.
9. `#sec-l07-handoff` *What restricting the shape would buy.* Every estimator
   met here treats the response at each horizon as free or as a function of
   $p$ lags; the next lecture asks what is gained, and assumed, when the
   response is told to be smooth.

**Central notation.** From the ledger: $y_t$, $s_t$, $\mathbf w_t$, $p$,
$\beta_h$, $\hat\beta_h$, $\theta_h$, $\mu_h$, $\boldsymbol\gamma_h$,
$u_{t,h}$, $\mathcal T_h$, $T_h$, $\rho$, $\alpha$ (significance level only),
$\operatorname{se}(\hat\beta_h)$, $m$; from Section 5 of the ledger:
$\mathbf y_t$, $\mathbf A(L)$, $\theta^{\mathrm{LP}}_h$, $\theta^{\mathrm{VAR}}_h$,
$\hat\theta^{\mathrm{LP}}_h$, $\hat\theta^{\mathrm{VAR}}_h$, $\operatorname{Bias}$,
$\operatorname{Var}$, $\operatorname{MSE}$. New in this lecture (Section 2
below): $\mathbf A_1,\dots,\mathbf A_p$, the companion matrix
$\mathbf A_{\mathrm c}$, the residual covariance $\mathbf S$, the impact vector
$\mathbf g$, the selection vector $\mathbf e_j$, the toy parameters $\tau$,
$\kappa$, $\sigma_v$, the population VAR(1) coefficients $a_s,a_y$ and the
projection coefficient $c$, the bias weight $\omega$ and loss $L_\omega$, the
indifference weight $\omega^{*}_h$, the number of replications $R$, and the
LPW scale $\bar\theta=\sqrt{\tfrac{1}{21}\sum_{h=0}^{20}\theta_h^2}$.

**Likely glossary terms.** Owned keys (all thirteen are used) plus three new
keys. One-line definition drafts:

- `vector-autoregression` — A system in which each variable in $\mathbf y_t$ is
  regressed on $p$ lags of every variable in the system; its coefficients
  summarize the first $p$ autocovariances and, iterated, produce a response at
  every horizon.
- `direct-estimation` — Estimating the horizon-$h$ response by a regression
  whose dependent variable is dated $t+h$; the local projection, which uses
  autocovariances out to lag $h+p$.
- `iterated-estimation` — Estimating one-step dynamics and multiplying them
  forward $h$ times; the VAR response, which uses only the first $p$
  autocovariances and extrapolates the rest.
- `population-equivalence` — The Plagborg-Møller–Wolf result that the LP and
  the VAR with the same variables and $p$ lags coincide in population at
  $h\le p$, and that both converge to the same response as $p\to\infty$.
- `invertibility` — The property that the structural shock can be recovered
  from current and past observables; needed by SVAR-IV, not by the LP or by a
  VAR that orders the shock (or instrument) first.
- `bias-variance-tradeoff` — The situation in which one estimator has lower
  bias and the other lower variance, so neither dominates and the choice
  depends on how the two are weighed.
- `mean-squared-error` — Squared bias plus variance at a horizon; the loss
  that weighs bias and variance equally.
- `misspecification` — A gap between the estimating model and the DGP; here,
  a VAR whose $p$ lags cannot represent the dynamics, so its iterated
  response is biased even in population.
- `lag-length` — The number $p$ of lags of every variable used as controls (LP)
  or as regressors (VAR); it fixes the horizon up to which the two estimators
  coincide.
- `bias-correction` — An analytic adjustment for the order-$1/T$ bias that
  persistence imparts to least-squares estimates: Pope's formula for VAR
  coefficients, Herbst–Johannsen's for LP; each lowers bias and raises
  variance.
- `shrinkage` — Pulling an estimate toward a restriction (a smooth curve, a
  prior, a random walk) to lower variance at the price of bias; penalized LP
  and Bayesian VARs are shrinkage estimators.
- `model-averaging` — Combining the responses of several models with
  data-chosen weights (Hansen's VAR averaging over lag lengths); a way to move
  along the trade-off rather than pick a pole.
- `data-generating-process` — The complete probability model from which a
  simulated sample is drawn; a Monte Carlo statement is always relative to
  one, so "thousands of DGPs" is a statement about a distribution of designs.
- `companion-form` (new) — The stacking of a VAR($p$) into a VAR(1) in the
  vector $(\mathbf y_t',\dots,\mathbf y_{t-p+1}')'$ so that iteration is a
  matrix power; the largest eigenvalue of the companion matrix is the VAR's
  largest root.
- `bias-weight` (new) — The weight $\omega\in[0,1]$ on squared bias in the loss
  $L_\omega$; $\omega=\tfrac12$ is mean squared error and $\omega^{*}_h$ is the
  weight at which two estimators tie.
- `encompassing-model` (new) — A large calibrated model from which many
  smaller DGPs are drawn by selecting subsets of its variables; LPW's
  encompassing model is a six-factor DFM fitted to 207 quarterly U.S. series.

**Likely explanatory footnotes** (`.footnote-term`, local): the Wold
representation and the VAR($\infty$); the Cholesky factor and why ordering the
shock first makes the first orthogonalized innovation the shock itself;
"drifting DGP" as the device LPW use to keep bias and standard error of the
same order in their Proposition 1; the Herbst–Johannsen correction formula in
one line; Pope's correction and Kilian's stationarity adjustment; the
winsorized and quantile summaries LPW report; the AIC; Stata's delta-method
standard errors in `irf create`; the difference between the working-paper
version (January 23, 2024, local PDF) and the published *Journal of
Econometrics* article; why the impact estimates of LP and VAR are the same
number by Frisch–Waugh–Lovell.

**Candidate figures** (`fig-l07-*`; each is a standalone TikZ/pgfplots
document compiled by `figures/build.sh` with the shared `lpfig.tex` preamble;
"Lua data" means a `fig-*-data.lua` script builds the pgfplots coordinate
macros, either by exact arithmetic or by reading a committed CSV that Stata or
MATLAB produced).

| Figure | Question it answers | Lesson visible | Data or formula | Source |
|---|---|---|---|---|
| `fig-l07-two-answers` | Do two estimators with the same identification and data give the same response? | Same at $h=0$, apart after 3 months, 0.23 points apart at $h=30$; both bands are wide | `realdata_lp_var.csv` (Stata, stored) | Lua reads CSV; two panels: paths with bands, and the difference |
| `fig-l07-direct-iterated` | What does "iterate" do that "project" does not? | Direct: one arrow from $t$ to $t+h$; iterated: $h$ one-step arrows through $\mathbf A_1$ | Schematic, no data | TikZ diagram |
| `fig-l07-population-bias` | Where does the iterated response go wrong in population? | True $\theta_h$ versus $\theta^{\mathrm{VAR}}_h$ for VAR(1) and VAR(2): exact at $h\le p$, geometric after; bias changes sign | Exact recursion with $\rho,\tau,\kappa$ | Lua arithmetic |
| `fig-l07-one-sample` | How different are the two estimators on one sample? | One draw: LP(1) jagged around the truth, VAR(1) smooth and off at $h=2$ | Draw 1 of `toy_draws_base.dta` (stored) | Lua reads CSV |
| `fig-l07-bias-sd-horizon` | How do bias and variance move with $h$? | Two panels: $\lvert\mathrm{Bias}\rvert$ and sd by $h$ for LP(1), LP(2), VAR(1), VAR(2); LP sd doubles by $h=3$, VAR sd peaks at $h=2$ | `toy_summary_base.csv` | Lua reads CSV |
| `fig-l07-mse-ranking` | Which estimator wins, and does the answer move with $T$ and $\kappa$? | Small multiples of MSE by $h$ at $T\in\{100,200,800\}$ and $\kappa\in\{0,0.5\}$; the crossing moves | `toy_summary_{base,k0,T800,T100}.csv` | Lua reads CSVs |
| `fig-l07-coverage` | Does the lower-MSE estimator also have the better band? | Coverage by $h$ of the LP Newey–West band and the VAR delta-method band at $T=200$ and $T=100$; VAR under-covers where it is biased | `toy_summary_base.csv`, `toy_summary_T100.csv` | Lua reads CSVs |
| `fig-l07-lpw-profiles` | Does the toy's profile survive in realistic DGPs? | Four ported DGPs: relative $\lvert\mathrm{Bias}\rvert$ and sd by $h$ for LP, BC LP, VAR, BC VAR; labeled stored result, 500 draws | `mc_summary_G_1.csv`, `mc_summary_MP_1.csv` | Lua reads CSVs |

**Exercise capabilities to test.** Iterate a VAR by hand; derive and compute
the population bias of a misspecified VAR(1); build LP and VAR responses from
`regress` and matrix arithmetic and verify against `var`/`irf create`; run and
summarize a Monte Carlo; compute $\omega^{*}_h$; predict and confirm the
effect of $p$ and $T$; compute and compare coverage; reproduce and vary the
real-data comparison; read LPW's design and findings with the correct scope;
port a bias correction and check it against a benchmark (extra).

**Candidate controlled experiments for the HTML lab.** (Section 7 gives the
full plan.) Iterating a VAR by hand with the true response overlaid; one
sample, two estimators with a fixed shock sequence and a movable $p$; a live
Monte Carlo with $T$, $p$, $\kappa$, and $\omega$ as controls; coverage versus
MSE at one horizon; the four ported DGPs with a bias-weight slider (stored).

**What this session deliberately postpones.** Bayesian VARs beyond naming
them and locating them on the trade-off (further reading); penalized LP's
construction and tuning (L8 owns `penalized-regression`, `roughness-penalty`,
`cross-validation`); structural identification beyond observed shock,
recursive ordering, and an instrument ordered first (sign restrictions,
long-run restrictions); SVAR-IV's bias under non-invertibility beyond one
paragraph and one footnote; bootstrap and Bayesian inference for VAR
responses; the panel version of the trade-off.

**Question handed to the next session.** What do we gain, and what do we
assume, when we tell the estimator the response must be smooth?

---

## 2. Concept and notation ledger

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $\mathbf y_t$ | VAR vector; in the toy $(s_t,y_t)'$, in the port (shock, five observables) | $n\times1$, $n=2$ or $6$ | dated $t$ | mixed | §2 | §3, §8, exercises 1, 3 |
| $\mathbf A_j$ | VAR coefficient matrix at lag $j$; $\mathbf A(L)=\sum_{j=1}^p\mathbf A_jL^j$ | $n\times n$ | — | — | §2 | §3, §5 |
| $\mathbf c$ | VAR intercept vector | $n\times1$ | — | units of $\mathbf y$ | §2 | never interpreted |
| $\mathbf e_t$ | VAR one-step residual vector | $n\times1$ | dated $t$ | units of $\mathbf y$ | §2 | §3 |
| $\mathbf S$ | Residual covariance of the VAR, $\mathbf S=\operatorname{Var}(\mathbf e_t)$ (estimate $\hat{\mathbf S}$) | $n\times n$ | — | squared units | §2 | §3, §8; not the ledger's $\boldsymbol\Sigma$ |
| $\mathbf g$ | Impact vector of a unit shock ordered first, $\mathbf g=\mathbf S_{\cdot1}/S_{11}$ | $n\times1$ | $h=0$ | units of $\mathbf y$ per unit $s$ | §2 | §3, §8 |
| $\mathbf A_{\mathrm c}$ | Companion matrix of the VAR($p$) | $np\times np$ | — | — | §3 | §5, §8, exercise 3 |
| $\mathbf e_j$ | Selection vector picking element $j$ | $n\times1$ or $np\times1$ | — | — | §2 | §3 |
| $\theta^{\mathrm{VAR}}_h$ | Population response implied by the VAR($p$), $\mathbf e_{\mathrm{resp}}'\mathbf A_{\mathrm c}^{\,h}\tilde{\mathbf g}$ | scalar | horizon $h$ | units of $y$ per unit $s$ | §2 | §3–§8 |
| $\theta^{\mathrm{LP}}_h$ | Population LP coefficient with $p$ lags; equals $\theta_h$ when $s_t$ is unpredictable | scalar | horizon $h$ | as above | §2 | §3–§8 |
| $\hat\theta^{\mathrm{LP}}_h,\hat\theta^{\mathrm{VAR}}_h$ | Their estimators in one sample | scalar | $h$ | as above | §3 | §4–§8 |
| $\tau,\kappa$ | MA coefficients on $s_{t-1}$ and $s_{t-2}$ in the toy; $\kappa\ne0$ is the misspecification of a VAR(1) | scalars | — | units of $y$ per unit $s$ | §3 | §4–§6, lab |
| $\sigma_v$ | Standard deviation of the unobserved shock $v_t$ | scalar | — | units of $y$ | §3 | §4, lab |
| $\gamma_0$ | $\operatorname{Var}(y_t)$ in the toy | scalar | — | squared units of $y$ | §3 | exercise 2 |
| $c$ | Coefficient on $y_{t-1}$ in the projection of $s_{t-2}$ on $(s_{t-1},y_{t-1})$, $c=\theta_1/(\gamma_0-1)$ | scalar | — | — | §3 | exercise 2 |
| $a_s,a_y$ | Population VAR(1) coefficients in the $y$ equation | scalars | — | — | §3 | §4, exercise 2 |
| $\operatorname{Bias}_h,\operatorname{Var}_h,\operatorname{MSE}_h$ | $\mathbb E[\hat\theta_h]-\theta_h$, $\operatorname{Var}(\hat\theta_h)$, and their combination, per estimator | scalars | $h$ | units, squared units | §4 | §5–§8 |
| $R$ | Number of Monte Carlo replications; Monte Carlo standard error of a mean is $\mathrm{sd}/\sqrt R$ | integer | — | — | §4 | §5–§8, practicum |
| $\omega$ | Bias weight in $L_\omega=\omega\operatorname{Bias}^2+(1-\omega)\operatorname{Var}$ | scalar in $[0,1]$ | — | — | §4 | §7, lab 3, 5 |
| $\omega^{*}_h$ | Indifference weight, $(\operatorname{Var}^{\mathrm{LP}}_h-\operatorname{Var}^{\mathrm{VAR}}_h)/[(\operatorname{Var}^{\mathrm{LP}}_h-\operatorname{Var}^{\mathrm{VAR}}_h)+(\operatorname{Bias}^{\mathrm{VAR}\,2}_h-\operatorname{Bias}^{\mathrm{LP}\,2}_h)]$ | scalar | $h$ | — | §4 | §7, §8, exercise 5 |
| $\bar\theta$ | LPW scale $\sqrt{\tfrac1{21}\sum_{h=0}^{20}\theta_h^2}$ used to make bias and sd unit-free | scalar | — | units of $y$ | §7 | §8, fig-l07-lpw-profiles |
| $\Phi(\cdot)$ | Standard normal cdf, for the coverage-of-a-biased-band formula | — | — | — | §6 | exercise 7 |
| $p$, $T$, $H$, $T_h$, $m$ | As in the ledger | — | — | — | §2 | throughout |

Stata names in the practicum mirror the ledger: `s`, `y`, `w1`–`wp`, `h`,
`beta_h`, `se_h`; new here: `theta_var_h`, `theta_true_h`, `A_c`, `S`, `g`,
`R`, `omega`.

---

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition | First marked occurrence |
|---|---|---|---|---|
| vector autoregression | glossary | `vector-autoregression` | as drafted in §1 | `#sec-l07-same-estimand`, first paragraph |
| direct estimation | glossary | `direct-estimation` | as drafted | `#sec-l07-direct-iterated`, opening sentence |
| iterated estimation | glossary | `iterated-estimation` | as drafted | `#sec-l07-direct-iterated`, second sentence |
| population equivalence | glossary | `population-equivalence` | as drafted | `#sec-l07-same-estimand`, statement of the result |
| invertibility | glossary | `invertibility` | as drafted | `#sec-l07-same-estimand`, identification-schemes paragraph |
| bias–variance trade-off | glossary | `bias-variance-tradeoff` | as drafted | `#sec-l07-bias-variance`, after the table |
| mean squared error | glossary | `mean-squared-error` | as drafted | `#sec-l07-bias-variance`, definition display |
| misspecification | glossary | `misspecification` | as drafted | `#sec-l07-direct-iterated`, when $\kappa\ne0$ is introduced |
| lag length | glossary | `lag-length` | as drafted | `#sec-l07-lags-and-sample`, first sentence |
| bias correction | glossary | `bias-correction` | as drafted | `#sec-l07-thousands`, estimators paragraph |
| shrinkage | glossary | `shrinkage` | as drafted | `#sec-l07-thousands`, estimators paragraph |
| model averaging | glossary | `model-averaging` | as drafted | `#sec-l07-thousands`, estimators paragraph |
| data-generating process | glossary | `data-generating-process` | as drafted | `#sec-l07-direct-iterated`, when the toy is introduced |
| companion form | glossary (new) | `companion-form` | as drafted | `#sec-l07-direct-iterated`, VAR(2) iteration |
| bias weight | glossary (new) | `bias-weight` | as drafted | `#sec-l07-bias-variance`, loss display |
| encompassing model | glossary (new) | `encompassing-model` | as drafted | `#sec-l07-thousands`, design paragraph |
| Wold representation, VAR($\infty$) | footnote | — | the population regression of $\mathbf y_t$ on its infinite past, whose coefficients decay but never vanish in LPW's DGPs | `#sec-l07-same-estimand` |
| Cholesky factor | footnote | — | the lower-triangular $\mathbf P$ with $\mathbf P\mathbf P'=\mathbf S$; with the shock first, its first column divided by $\sqrt{S_{11}}$ is $\mathbf g$ | `#sec-l07-same-estimand` |
| drifting DGP | footnote | — | LPW's device $\kappa_T=\kappa/\sqrt T$ so that bias and standard error stay of the same order as $T\to\infty$ | `#sec-l07-bias-variance` |
| Herbst–Johannsen correction | footnote | — | one-line statement of the recursion ported in Section 6 | `#sec-l07-thousands` |
| Pope correction | footnote | — | analytic order-$1/T$ correction of VAR coefficients, with Kilian's stationarity adjustment | `#sec-l07-thousands` |
| delta method (Stata `irf`) | footnote | — | first-order standard error of a nonlinear function of VAR coefficients | `#sec-l07-coverage` |
| median across DGPs | footnote | — | LPW report the median over 6,000 DGPs of a per-DGP statistic; the port reports four DGPs, so no median | `#sec-l07-thousands` |
| recursive identification, observed shock, instrument, lag augmentation, Newey–West, coverage, pointwise band, Monte Carlo simulation, statistical reproduction, persistence, unit root, identifying assumption | prose (owned elsewhere) | L3, L4, L5, L6, L2, L1 keys | linked to the owning glossary at first use | — |
| penalized LP, Bayesian VAR, VAR model averaging (as named estimators) | prose | — | named and located on the trade-off; `penalized-regression` is L8's key and is not marked here | `#sec-l07-thousands` |

---

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Best medium | Source | Asset status | Cross-reference label |
|---|---|---|---|---|---|
| LP and VAR on the same data and identification give the same impact estimate and different paths | LP(12) and VAR(12) unemployment responses, values in §1 | figure + table | `l07_realdata.do` → `realdata_lp_var.csv` | computed; figure to build | `fig-l07-two-answers`, `tbl-l07-two-answers` |
| The impact estimates are the same number | FWL: both are the coefficient of $y_t$ on $s_t$ given $\mathbf w_t$ | equation + prose | derivation §6.4 | verified in real data (identical to 4 digits) and in the port (identical to $10^{-8}$) | `eq-l07-impact-equality` |
| VAR($p$) and LP($p$) coincide at $h\le p$ in population; both converge as $p\to\infty$ | Plagborg-Møller–Wolf (2021) Propositions 1–2, restated for the course's regression | equation + prose | R08 | cite; no asset | `eq-l07-equivalence` |
| The VAR(1) response is biased at $h\ge2$ when $\kappa\ne0$, by a computable amount | derivation §6.3; population values $-0.364,-0.095,+0.008,+0.039$; $n=10^6$ check | equation + figure | `l07_popcheck.do` | verified | `eq-l07-var1-bias`, `fig-l07-population-bias` |
| The LP is unbiased in population at every $h$ for any $p$ | orthogonality of $s_t$ to $\mathbf w_t$ and to future shocks; $n=10^6$ check | equation | derivation §6.2 | verified | `eq-l07-lp-unbiased` |
| At $T=200$ the LP's sd doubles by $h=3$ and the VAR(1)'s sd is smaller from $h=2$ | Monte Carlo table, $R=1{,}000$ | table + figure | `toy_summary_base.csv` | computed | `tbl-l07-toy-mc`, `fig-l07-bias-sd-horizon` |
| The ranking depends on $\omega$ through $\omega^{*}_h$ | formula §6.5 applied to the table | equation + table | `toy_summary_base.csv` | computed | `eq-l07-omega-star` |
| Adding the missing lag removes the VAR bias at a variance cost; adding a lag to the LP changes little | VAR(2) and LP(2) rows of the table | table + figure | `toy_summary_base.csv` | computed | `tbl-l07-toy-mc` |
| Larger $T$ shrinks LP variance but not VAR(1) bias; smaller $T$ does the reverse | $T=800$ and $T=100$ runs | figure | `toy_summary_T800.csv`, `toy_summary_T100.csv` | computed | `fig-l07-mse-ranking` |
| With $\kappa=0$ the VAR(1) is unbiased and dominates | $\kappa=0$ run | figure | `toy_summary_k0.csv` | computed | `fig-l07-mse-ranking` |
| A biased band under-covers by $\Phi(1.96-b/\sigma)-\Phi(-1.96-b/\sigma)$ | formula §6.6 against Monte Carlo coverage | equation + figure | `toy_summary_base.csv` | computed | `eq-l07-biased-coverage`, `fig-l07-coverage` |
| LPW: LP lower bias, VAR lower variance in the median DGP; BC LP best iff $\omega\gtrsim0.9$; VAR/BVAR otherwise; AIC picks $\hat p\le2$ | LPW Sections 5.1–5.3, 5.6, Figures 2, 3, 6; Table 1 | prose + one table of Table 1 rows | R09 (working-paper PDF, Documents/) | cite; verify against published version | `tbl-l07-lpw-table1` |
| Four ported DGPs reproduce the trade-off qualitatively with design-specific profiles | 500-draw benchmark, relative $\lvert\mathrm{Bias}\rvert$ and sd | figure + table | `mc_summary_G_1.csv`, `mc_summary_MP_1.csv` | computed (statistical reproduction) | `fig-l07-lpw-profiles`, `tbl-l07-port-benchmark` |
| The Stata port equals the MATLAB estimators draw by draw | max abs difference $\le 9\times10^{-8}$ (LP, BC LP, VAR), 4 draws × 21 horizons | table | `run_validate_smoke.log` | verified | `tbl-l07-port-validation` |

---

## 5. Assessment map

Ten exercises; six are computational in Stata. Tags follow the guide.

| Learning outcome | Exercise | Tags | Mode of work | Hint strategy | Solution check | Linked lab section |
|---|---|---|---|---|---|---|
| 1 | 1. Iterate a VAR(1) by hand | [core] [pencil] | Given $\mathbf A_1$ and $\mathbf g$ from the notes ($a_s=0.3636$, $a_y=0.6364$, $s$-equation zero, $\mathbf g=(1,1)'$), compute $\theta^{\mathrm{VAR}}_h$ for $h=0,\dots,4$; show $h\le1$ equals the direct projection; write the same recursion for a VAR(2) in companion form | Name the object carried forward ($\mathbf A_1^{h-1}\mathbf g$), not the formula | Values $1,1,0.636,0.405,0.258$; companion matrix has the identity in the lower-left block | Lab 1 |
| 2 | 2. The population bias of a misspecified VAR(1) | [core] [pencil] | Derive $a_s,a_y$ by projecting $\kappa s_{t-2}$ on $(s_{t-1},y_{t-1})$; compute with the baseline parameters; repeat with $\kappa=0$ | Suggest the normal equations with $\operatorname{Cov}(s_{t-2},y_{t-1})=\theta_1$ | $c=0.2727$, bias $-0.364$ at $h=2$; zero bias when $\kappa=0$; assertion in the companion do-file | Lab 1 |
| 1, 2 | 3. Same sample, two estimators (Stata) | [core] [computational] | On the shipped draw (`toy_draw1.dta`, seed 7), build LP(1) with `regress` and VAR(1) with two regressions plus companion iteration; compare with `var`/`irf create` | Point to FWL for $h=0$ and to the residual covariance for $\mathbf g$ | `assert` equality at $h=0$ to $10^{-8}$ between LP, hand VAR, and `irf`; report the $O(1/T)$ gap at $h=1$ | Lab 2 |
| 3 | 4. A Monte Carlo of the trade-off (Stata) | [core] [computational] | $R=200$ replications of the toy at $T=200$; LP(1) and VAR(1); bias, sd, MSE by horizon; `postfile` | Suggest storing every replication and summarizing once | `assert` that VAR bias at $h=2$ is within $3\,\mathrm{sd}/\sqrt R$ of $-0.364$ and that $\mathrm{MSE}=\mathrm{Bias}^2+\mathrm{Var}\cdot(R-1)/R$ | Lab 3 |
| 3 | 5. How much must you care about bias? | [core] [pencil] | From the notes' table compute $\omega^{*}_h$ at $h=2,4,8$; explain why $\omega^{*}$ can exceed 1 or fall below 0 | Separate the two differences before dividing | Numbers from `toy_summary_base.csv`; the sign discussion | Lab 3 |
| 4 | 6. Lags and sample size (Stata) | [computational] | Rerun exercise 4 with $p=2$, then with $T=800$; tabulate which biases vanish and which variances shrink; state the two limits in which LP and VAR converge | Ask which change alters the population object and which alters only the sample | VAR(2) bias at $h=2$ within Monte Carlo error of 0; LP sd at $T=800$ about half of $T=200$ | Lab 3 |
| 5 | 7. Coverage is a different achievement (Stata) | [computational] | Add Newey–West ($m=h$) bands for the LP and `irf` delta-method bands for the VAR to exercise 4; compute coverage; compare the coverage ranking with the MSE ranking at $h=2$ and $h=4$ | Give the biased-band formula and ask for $b/\sigma$ at $h=2$ | Coverage within Monte Carlo error of the notes; the formula's prediction matches | Lab 4 |
| 5 | 8. Two answers on real data (Stata) | [data] [computational] | Reproduce `fig-l07-two-answers`; rerun with $p=6$ and $p=24$; write three sentences on why neither estimator is wrong | Remind that the impact estimate must agree exactly | Impact equality assertion; the $h=30$ gap at each $p$ recorded | Lab 2 |
| 5 | 9. Reading thousands of DGPs | [core] [pencil] | From LPW's Table 1 and Figures 2, 3, 6: what is held fixed, which conclusion needs bias correction, what a median across DGPs does not say; classify five sentences as supported or unsupported | Ask "for which $T$, $p$, identification, and loss?" of each sentence | Answer key with the section of LPW that decides each | Lab 5 |
| 3, 5 | 10. Port a bias correction (Stata, Mata) | [extra] [computational] | Implement the Herbst–Johannsen recursion (given) in Mata; verify against the shipped MATLAB benchmark on draw 1 of a ported DGP; compare bias and sd with and without correction across 100 draws | Say what $w$ is (the $h=0$ control matrix) and what $T$ means in the formula | Max abs difference $<10^{-6}$ on draw 1; corrected LP has lower bias and higher sd | Lab 5 |

Every learning outcome has evidence in at least two media: outcome 1 (prose
§2, equation, figure `population-bias`, exercises 1 and 3, lab 1); outcome 2
(derivation, figure, exercise 2, lab 1); outcome 3 (table, figure
`bias-sd-horizon`, exercises 4 and 5, lab 3); outcome 4 (figure
`mse-ranking`, exercise 6, lab 3); outcome 5 (figure `coverage`, figure
`lpw-profiles`, exercises 7–9, labs 4–5, REP07).

---

## 6. Derivations to verify

Scratch directory for every script named here:
`/private/tmp/claude-501/-Users-tylersotomayor-macro-local-projections/c072337f-0f2c-4cf4-bb71-22a0631666a1/scratchpad/design-07/`.

**6.1 True response of the toy by forward substitution.** Source identity:
the model equation. Steps: write $y_t=\sum_{j\ge0}\theta_j s_{t-j}+\sum_{j\ge0}\rho^j v_{t-j}$
and match coefficients: $\theta_0=1$; at lag 1, $\rho\theta_0+\tau$; at lag
2, $\rho\theta_1+\kappa$; at lag $j\ge3$, $\rho\theta_{j-1}$. Interpretation:
the response is a geometric decay from $h=2$ with a kink at $h=2$ of size
$\kappa$. Numerical check: $\theta=(1,1,1,0.5,0.25,\dots)$ with
$\rho=\tau=\kappa=0.5$; the Stata matrix `theta` in `l07_toy_mc2.do`.

**6.2 The LP is unbiased in population at every horizon for any $p$.**
Source identity: $y_{t+h}=\theta_h s_t+\sum_{j\ne0}\theta_j s_{t+h-j}+\sum_j\rho^j v_{t+h-j}$.
Steps: the population projection of $y_{t+h}$ on $(1,s_t,\mathbf w_t)$ gives
$\beta_h=\theta_h$ if $s_t$ is orthogonal to $\mathbf w_t$ (it is: $s_t$ is
i.i.d. and $\mathbf w_t$ is dated $t-1$ or earlier) and orthogonal to every
other term (shocks dated $t+1,\dots,t+h$ are independent of $s_t$; shocks
dated before $t$ are independent of $s_t$). The controls change $u_{t,h}$ and
its variance, never $\beta_h$. This is L3's A1–A3 in the sandbox. Numerical
check: LP(1) at $n=10^6$ gives $0.9998, 1.0027, 1.0033, 0.5051, 0.2539$ (seed
11) and $0.9981,0.9981,0.9976,0.4968,0.2481$ (seed 12) against
$1,1,1,0.5,0.25$ (`l07_popcheck.do`).

**6.3 Population VAR(1) coefficients and the iterated response.** Source
identity: the $y$ equation of the DGP, $y_t=\rho y_{t-1}+\tau s_{t-1}+\kappa s_{t-2}+(s_t+v_t)$.
Steps. (i) The VAR(1) regresses $y_t$ on $(1,s_{t-1},y_{t-1})$; the term
$\kappa s_{t-2}$ is not a regressor, so "complete the projection" of $s_{t-2}$
on $(s_{t-1},y_{t-1})$: the normal equations use
$\operatorname{Cov}(s_{t-2},s_{t-1})=0$, $\operatorname{Cov}(s_{t-2},y_{t-1})=\theta_1$,
$\operatorname{Cov}(s_{t-1},y_{t-1})=\theta_0=1$, $\operatorname{Var}(s_{t-1})=1$,
$\operatorname{Var}(y_{t-1})=\gamma_0$; solving gives coefficient $c=\theta_1/(\gamma_0-1)$
on $y_{t-1}$ and $-c$ on $s_{t-1}$. (ii) Hence $a_y=\rho+\kappa c$,
$a_s=\tau-\kappa c$. (iii) $\gamma_0=\sum_j\theta_j^2+\sigma_v^2/(1-\rho^2)$
with $\sum_j\theta_j^2=1+\theta_1^2+\theta_2^2/(1-\rho^2)$. (iv) The $s$
equation has zero coefficients; $\mathbf A_1=\begin{pmatrix}0&0\\a_s&a_y\end{pmatrix}$,
$\mathbf g=(1,\ S_{21}/S_{11})'=(1,1)'$ because $\operatorname{Cov}(e_{s,t},e_{y,t})=\operatorname{Var}(s_t)=1$.
(v) $\theta^{\mathrm{VAR}}_0=1$, $\theta^{\mathrm{VAR}}_1=a_s+a_y$,
$\theta^{\mathrm{VAR}}_h=a_y\theta^{\mathrm{VAR}}_{h-1}$ for $h\ge2$: exact at
$h=1$ because $a_s+a_y=\rho+\tau=\theta_1$ (the $\kappa c$ terms cancel — this
is the population equivalence at $h\le p$ made visible), geometric with ratio
$a_y=0.636$ afterwards while the truth has ratio $\rho=0.5$ from $h=3$ and a
kink at $h=2$. Interpretation: iteration replaces the missing lag by "what
$y_{t-1}$ knows about $s_{t-2}$," and that substitute is right one step ahead
and wrong afterwards. Numerical check: $\gamma_0=4.6667$, $c=0.2727$,
$a_y=0.6364$, $a_s=0.3636$, $\theta^{\mathrm{VAR}}=(1,1,0.636,0.405,0.258,0.164,0.104,0.066,0.042)$;
at $n=10^6$, $\hat a_s=0.3664$ and $0.3637$ (se 0.0017), $\hat a_y=0.6372$
and $0.6357$ (se 0.0008), $\widehat{\operatorname{Var}}(y)=4.689$ and $4.650$
(`l07_popcheck.do`). With $\kappa=0$: $a_y=\rho$, $a_s=\tau$, no bias
(`toy_summary_k0.csv`).

**6.4 The impact estimates of LP and recursive VAR are the same number.**
Source identity: FWL. Steps: the LP at $h=0$ regresses $y_t$ on $(1,s_t,\mathbf w_t)$;
the recursive VAR's impact response is $\hat S_{21}/\hat S_{11}$, the slope of
the $y$-equation residual on the $s$-equation residual, both residualized on
$(1,\mathbf w_t)$ — which by FWL is the same coefficient. Numerical check: real
data, $-0.0717$ in both columns; port validation, $\lvert\Delta\rvert\le
4\times10^{-8}$ at $h=0$ across draws. The finite-sample gap at $h=1$ (the
VAR uses $\hat a_s+\hat a_y\hat g_2$, the LP a direct regression on a
different row set) is $O(1/T)$: in the real data $-0.198$ versus $-0.175$ at
$h=3$; in the toy the Monte Carlo means agree at $h=1$ to the third decimal.

**6.5 MSE, the loss, and the indifference weight.** Source identity:
$\mathbb E[(\hat\theta_h-\theta_h)^2]=(\mathbb E\hat\theta_h-\theta_h)^2+\operatorname{Var}(\hat\theta_h)$
(add and subtract $\mathbb E\hat\theta_h$; the cross term vanishes). The Monte
Carlo estimator uses the mean and the population-form variance, so
$\widehat{\mathrm{MSE}}=\widehat{\mathrm{Bias}}^2+\widehat{\mathrm{sd}}^2(R-1)/R$
(Stata's `sd` divides by $R-1$; the do-file asserts the identity). Loss:
$L_\omega=\omega\operatorname{Bias}^2+(1-\omega)\operatorname{Var}$; LP is
preferred iff $\omega\ge\omega^{*}_h$ with
$\omega^{*}_h=\Delta V/(\Delta V+\Delta B)$, $\Delta V=\operatorname{Var}^{\mathrm{LP}}_h-\operatorname{Var}^{\mathrm{VAR}}_h$,
$\Delta B=\operatorname{Bias}^{\mathrm{VAR}\,2}_h-\operatorname{Bias}^{\mathrm{LP}\,2}_h$;
when $\Delta B<0$ (VAR less biased) the LP is dominated and $\omega^{*}$ is
outside $[0,1]$. This is LPW's equation (4) and their $\omega^{*}_h$ with the
course's symbols. Numerical check: the toy table in §8.2 below and the
`omega*` column of `summarize_lpw.py`.

**6.6 Coverage of a band around a biased estimator.** Source identity: if
$\hat\theta_h\sim\mathcal N(\theta_h+b,\sigma^2)$ and the band is
$\hat\theta_h\pm1.96\hat\sigma$ with $\hat\sigma\approx\sigma$, coverage is
$\Pr(\lvert\hat\theta_h-\theta_h\rvert\le1.96\sigma)=\Phi(1.96-b/\sigma)-\Phi(-1.96-b/\sigma)$.
Values: $b/\sigma=0.5\Rightarrow0.93$; $1\Rightarrow0.83$; $2\Rightarrow0.48$;
$3\Rightarrow0.17$. Numerical check: VAR(1) at $h=2$ in the toy (bias
$-0.364$ against its Monte Carlo sd) versus its Monte Carlo coverage in
`toy_summary_base.csv`; the LP's Newey–West band at $h=2$ covers 0.934.

**6.7 The Herbst–Johannsen correction as ported.** Source: `LP_CorrectBias.m`.
With $\mathbf W$ the $(T-p)\times np$ de-meaned matrix of the $h=0$ controls,
$\boldsymbol\Sigma_0=\widehat{\operatorname{Var}}(\mathbf W)$,
$\boldsymbol\Sigma_j=\mathbf W_{1:T-p-j}'\mathbf W_{j+1:T-p}/(T-p-j-1)$,
$a_j=1+\operatorname{tr}(\boldsymbol\Sigma_0^{-1}\boldsymbol\Sigma_j)$, the
corrected response is $\tilde\theta_h=\hat\theta_h+\frac{1}{T-p-h}\sum_{i=1}^{h}a_i\tilde\theta_{h-i}$
for $h\ge1$, $\tilde\theta_0=\hat\theta_0$. Numerical check: Mata
implementation `lp_correct_bias.mata` matches MATLAB on 4 draws × 21
horizons with max abs difference $9\times10^{-8}$ (`run_validate_smoke.log`).

**6.8 The recursive VAR($p$) response as ported.** Source: `SVAR_est.m`,
`IRF_SVAR.m`. Equation-by-equation OLS of each series on a constant and $p$
lags of all series; $\hat{\mathbf S}$ from the residuals; impact
$\mathbf g=\hat{\mathbf S}_{\cdot1}/\hat S_{11}$ (the Cholesky first column
divided by its first element, so the degrees-of-freedom convention cancels);
companion iteration; response variable at position $\mathrm{resp}+1$ (the
shock occupies position 1). Numerical check: max abs difference
$4\times10^{-8}$ against MATLAB.

**6.9 LPW's scale.** Bias and sd are divided by
$\bar\theta=\sqrt{\tfrac1{21}\sum_{h=0}^{20}\theta_h^2}$ per DGP before the
median across DGPs is taken; the port reports the same ratio per DGP. Values
of $\bar\theta$ for the ported DGPs are in §8.

**Worked numerical example for the notes (exact inputs).** Baseline toy,
$\rho=\tau=\kappa=0.5$, $\sigma_v=1$. Truth $\theta_2=1$. VAR(1):
$\gamma_0=1+1+1/0.75+1/0.75=4.6667$; $c=1/3.6667=0.2727$;
$a_y=0.5+0.5\times0.2727=0.6364$; $a_s=0.5-0.1364=0.3636$;
$\theta^{\mathrm{VAR}}_1=0.3636+0.6364=1.0000=\theta_1$;
$\theta^{\mathrm{VAR}}_2=0.6364\times1=0.6364$, bias $-0.3636$;
$\theta^{\mathrm{VAR}}_3=0.4050$, bias $-0.0950$;
$\theta^{\mathrm{VAR}}_4=0.2577$, bias $+0.0077$. Rounded for display to
three decimals; the Lua data script computes from the unrounded recursion.

---

## 7. HTML lab plan (Bias–Variance Laboratory, `interactives/07-bias-variance-lab.qmd`)

Five labs in Observable JS, one page, in the order of the dependency chain.
Every lab has a setup paragraph, a **Predict before using the controls**
prompt, controls with units, a plot or table, a reactive sentence, controlled
comparisons, and a collapsed explanation. Random numbers come from a seeded
generator (`mulberry32` with a fixed seed input) so that toggling a control
never changes the underlying shocks. Every output is labeled live calculation,
stored simulation result, or conceptual illustration.

**Lab 1 — Iterate a VAR by hand (live).**
Learning question: where does the iterated response depart from the truth?
Invariants: $\rho=0.5$, $\tau=0.5$, $\sigma_v=1$ fixed unless the learner
opens the advanced panel; the truth and the VAR(1) response are population
objects, no sampling. Controls: $\kappa$ (units of $y$ per unit $s$, range
$[-1,1]$, default 0.5); lag length of the VAR, $p\in\{1,2\}$ (default 1);
horizon shown, $H\in\{4,8,12\}$ (default 8). Computation: $\theta_h$ by the
recursion of §6.1; $a_s,a_y,c,\gamma_0$ by the closed forms of §6.3;
$\theta^{\mathrm{VAR}}_h$ by iteration; for $p=2$ the response equals the
truth (the DGP is a VAR(2)). Reactive sentence: "With $\kappa=0.50$ the
VAR(1) matches the truth at $h\le1$, is $0.364$ too low at $h=2$, and decays at
rate $0.636$ instead of $0.500$; the largest absolute bias is at $h=2$."
Controlled comparisons: set $\kappa=0$ and read the bias; hold $\kappa$ and
switch $p$ to 2; make $\kappa$ negative and watch the sign of the bias.
Prediction prompt: "If $\kappa=0$, will the VAR(1) response equal the truth
at every horizon or only at $h\le1$?" Handoff: none (feeds Lab 2).

**Lab 2 — One sample, two estimators (live).**
Learning question: on one sample of realistic length, how different are the
two estimates, and which one is closer to the truth at which horizon?
Invariants: the shock and $v$ sequences are fixed by the seed; changing $p$ or
the estimator never redraws them; $\kappa=0.5$ unless changed. Controls:
$T\in\{100,200,400,800\}$ (observations, default 200); $p\in\{1,2,4\}$
(default 1); seed (integer, default 7); a "new draw" button increments the
seed. Computation: simulate the toy with burn-in 100; LP($p$) by OLS at
$h=0,\dots,8$ (normal equations, $2p+2$ regressors, solved by Cholesky in JS);
VAR($p$) by equation-by-equation OLS, residual covariance, companion
iteration, unit normalization — the same arithmetic as the Stata port.
Reactive sentence: "In this sample the two estimates are identical at $h=0$
($-$/$+x.xxx$), differ by $0.0xx$ at $h=1$, and by $0.xxx$ at $h=2$, where the
LP is $0.xx$ from the truth and the VAR is $0.xx$ from it." Controlled
comparisons: change $p$ from 1 to 2 with the seed fixed; change $T$ from 200
to 800 with the seed fixed; press "new draw" three times and note which
estimator moves more. Prediction prompt: "At which horizon will the two
estimates first differ?" Handoff: exports the draw as CSV ($t,s,y$) with the
seed and parameters in a header, for exercise 3.

**Lab 3 — The bias–variance laboratory (live, labeled with its Monte Carlo
error).** Learning question: which estimator has lower loss at each horizon,
and how does the answer depend on $T$, $p$, $\kappa$, and the bias weight?
Invariants: the $R$ replications use seeds $\text{seed}+1,\dots,\text{seed}+R$
so that changing $\omega$ recomputes nothing; changing $p$ re-estimates on the
same draws; changing $T$ or $\kappa$ redraws (stated on screen). Controls:
$R\in\{100,250,500\}$ (default 250; a run of 500 at $T=200$ completes in a few
seconds in a laptop browser); $T\in\{100,200,800\}$; $p\in\{1,2\}$;
$\kappa\in\{0,0.25,0.5\}$; $\omega\in[0,1]$ slider (default 0.5). Computation:
for each replication, LP($p$) and VAR($p$) at $h=0,\dots,8$; then bias, sd,
MSE, $L_\omega$, and $\omega^{*}_h$ per horizon; Monte Carlo standard errors
of the bias shown as error bars. Display: two panels (bias, sd) and a strip
showing which estimator wins $L_\omega$ at each $h$. Reactive sentence: "At
$\omega=0.50$ and $T=200$, the VAR(1) has the lower loss at $h=2,\dots,8$; the
LP would be preferred at $h=2$ only if $\omega\ge0.xx$." Controlled
comparisons: (a) $\omega$ from 0.5 to 0.95 with everything else fixed; (b)
$T$ from 200 to 800 at $\omega=0.5$; (c) $\kappa$ to 0; (d) $p$ to 2.
Prediction prompt: "Raising $T$ from 200 to 800 will shrink the LP's sd by
about what factor, and will it change the VAR(1)'s bias?" Handoff: exports
the design record (`rho, tau, kappa, sigma_v, T, p, R, seed`) and the table
of bias/sd/MSE as CSV; STA07 task 2 recomputes it in Stata on its own draws
and compares within Monte Carlo error.

**Lab 4 — Coverage is a different achievement (live, with one labeled
approximation).** Learning question: does the estimator with the lower MSE at
a horizon also have the band that covers more often? Invariants: same draws as
Lab 3 at the same seed; one horizon at a time. Controls: horizon $h\in\{1,2,3,4,8\}$
(default 2); $T\in\{100,200,800\}$; the nominal level fixed at 95 percent.
Computation: for the LP, the Newey–West ($m=h$) standard error per replication
and the indicator that the band covers $\theta_h$; for the VAR(1), a
delta-method standard error of $\theta^{\mathrm{VAR}}_h=a_y^{h-1}(a_s+a_y g_2)$
using the OLS covariance of $(\hat a_s,\hat a_y)$ and of $\hat g_2$ treated as
independent — labeled on screen as "delta method with the impact and slope
blocks treated as independent; the Stata handoff computes the exact
`irf create` band." Display: a hit-or-miss strip of 100 replications for each
estimator (as in L5's figure), coverage rates, mean widths, and the MSE
ranking from Lab 3 beside the coverage ranking. Reactive sentence: "At $h=2$
the VAR(1) has the lower MSE but its band covers in only xx percent of
replications because its bias is x.x times its standard deviation; the LP
band covers in 9x percent." Controlled comparisons: move $h$ from 2 to 8;
move $T$ from 200 to 100. Prediction prompt: "Will the VAR(1) band at $h=2$
cover more or less often than the LP band, and why?" Handoff: exports the
coverage table with the design record; STA07 task 4 reproduces it with
`newey` and `irf create`.

**Lab 5 — Four ported DGPs from thousands (stored simulation result).**
Learning question: does the toy's profile survive in realistic DGPs, and how
much does the profile move from one DGP to another? Invariants: the stored
500-draw benchmark; nothing is recomputed except the loss. Controls: DGP
(four, named by their response variable); estimator set (LP, BC LP, VAR, BC
VAR); $\omega$ slider; "relative to $\bar\theta$" toggle. Computation: reads
the committed JSON exported from `mc_summary_G_1.csv` and
`mc_summary_MP_1.csv` (with generation metadata: commit, seeds, $R=500$,
MATLAB R2024a, date); computes $L_\omega$ and the winner per horizon live.
Display: true response, mean estimate of each estimator, bias and sd panels,
winner strip. Reactive sentence: "In the [response variable] DGP, at
$\omega=0.50$ the least-squares VAR wins at $h\ge x$; bias-corrected LP wins
everywhere only when $\omega\ge0.9x$." Controlled comparisons: same $\omega$
across the four DGPs; same DGP across $\omega$. Prediction prompt: "Before
selecting the housing-starts DGP: will the VAR(4)'s bias be larger or smaller
than in the toy?" Handoff: exports the selected design's identifier, seed
list, and benchmark rows as the REP07 comparison file; the practicum's
`rep07_compare.do` reads it.

The final lab asks the learner to explain, without formulas, why two
estimators with the same target differ, why one is smoother, why smoother is
not the same as more accurate, and why more accurate is not the same as
better covered, and links to `#sec-l07-bias-variance` and exercises 4–7.

---

## 8. Practicum plan (REP07, STA07, HTML07 handoff)

### 8.1 REP07 — A bounded bias–variance study

**Target.** Four of the observed-shock designs of Li, Plagborg-Møller, and
Wolf, "Local Projections vs. VARs: Lessons From Thousands of DGPs," *Journal
of Econometrics* 244(2), 2024, 105722 (local PDF is the working-paper version
dated January 23, 2024, in `upstream/lp_var_simul/Documents/`; the published
version must be frozen before release). The published objects the design
subset speaks to are Figures 2 and 3 (median relative bias and standard
deviation by horizon, observed shock, $T=200$, $p=4$) and the per-DGP
profiles that underlie them. The task is a **statistical reproduction** of
four of the paper's 6,000 DGPs at 500 rather than 5,000 draws, with a Stata
re-estimation validated against the authors' MATLAB estimators draw by draw.
It is not a replication of any published figure, and the notes must say so
in the first sentence of `#sec-l07-bounded-port`.

**Original code and the lines that produce the target.** Repository
`dake-li/lp_var_simul`, commit `5a7771560737d7961202075e90c602e55d299347`
(MIT), local copy `~/macro/local_projections/upstream/lp_var_simul/`, frozen
archive and `DESIGNS.md` in `~/macro/local_projections/replication-packages/packages/lp-var-simul/`.
Driver `DFM/run_dfm.m` (settings lines 25–33: `spec_id`, `dgp_type`,
`estimand_type='ObsShock'`, `lag_type=4`, `mode_type=1`); `DFM/Settings/shared.m`
(DFM dimensions lines 5–11; `random_n_spec`, `random_n_var=5`, category
rules lines 17–24; `IRF_hor=21`; `n_MC`, seed rule lines 52–53; `T=200`,
`T_burn=100` lines 57–58; `methods_name` line 64; `n_lags_fix` line 70);
`Settings/G.m` and `Settings/MP.m` (fixed variable 12 = `GCEC96` at position
1 with response position 2; fixed variable 142 = `FEDFUNDS` at position 5
with response position 1; shock weight chosen to maximize the impact response
of the fixed variable); `Subroutines/pick_var_fn.m` (DGP draw, `rng(spec_id)`);
`Auxiliary_Functions/generate_data.m` (ABCD simulation);
`Estimation_Routines/LP_est.m`, `LP.m`, `LP_gen_data.m`, `IRF_LP.m`,
`LP_CorrectBias.m`, `SVAR_est.m`, `VAR.m`, `IRF_SVAR.m`,
`VAR_CorrectBias.m`; `Auxiliary_Functions/irf_perform_summary.m` (bias²,
variance, MSE); `DFM/Reporting/run_plot_loss.m` lines 108–110 and 126–129
(the $\bar\theta$ normalization and the median across DGPs). Data:
`DFM/Subroutines/SW_DFM_Estimation/data/hom_fac_1.xlsx` (Stock–Watson 2016
panel as shipped in the Lazarus–Lewis–Stock–Watson replication files, 207
quarterly series 1959Q1–2014Q4), used only to estimate the DFM.

**What was run.** Scratch copy at `design-07/lp_var_simul/` (the `.git`
directory removed; no file of the original package touched). Two drivers
were added: `DFM/run_scratch.m` (estimates the DFM as `run_dfm.m` does,
without `parpool`, then runs the Monte Carlo for `svar`, `svar_corrbias`,
`lp`, `lp_corrbias` and exports CSVs) and `DFM/run_scratch2.m` (identical but
loads the cached DFM parameters). Runs, MATLAB R2024a `-batch`:

| Run | Settings | Wall clock | Outputs |
|---|---|---|---|
| smoke | G, `spec_id=1`, 4 draws, export DGP 1 | 1,548 s (DFM estimation 1,399 s; Monte Carlo 6.9 s) | `mat_out_smoke/`: `dgp_summary_G_1.csv`, `true_irf_G_1.csv`, `mc_summary_G_1.csv`, `irf_draws_G_1_dgp1.csv`, `simdata_G_1_dgp1.csv`, reduced ABCD matrices (44 states, 11 shocks), `scratch_G_1.mat` |
| full G | G, `spec_id=1`, 500 draws, export DGPs 1–7 | see §8.1 benchmark table | `mat_out_full/` same file set for G |
| full MP | MP, `spec_id=1`, 500 draws, export DGPs 1–7 | see §8.1 benchmark table | `mat_out_full/` same file set for MP |

The seven fiscal DGPs of `spec_id = 1` (position 1 is always `GCEC96`,
response variable at position 2; `R0_sq` is the degree of invertibility,
`frac` the fraction of VAR($\infty$) coefficient norm at lags $\ge5$, LPW
Table 1's second row):

| DGP | Response (position 2) | Other variables | $R^2_0$ | frac | Shape of $\theta_h$, $h=0..20$ |
|---|---|---|---|---|---|
| G1 | `CPILFESL` core CPI (Δlog) | `PAYEMS`, `GDPC96`, `LNS13008756` | 0.387 | 0.235 | small, sign change at $h=6$ |
| G2 | `HOUST` housing starts (log) | `TCU`, `FEDFUNDS`, `PCED_HC` | 0.437 | 0.314 | $-3.15$ at impact, $+2.13$ at $h=4$, oscillating |
| G3 | `IP.B52000.S` IP business equipment (log) | `USINFO`, `PAYEMS`, `PCED_TRA` | 0.406 | 0.112 | hump: $-0.79$ at $h=2$, $+0.62$ at $h=9$ |
| G4 | `DPIC96` real disposable income (log) | `LNS13023557`, `PNFIC96_Q`, `A0M099` | 0.617 | 0.153 | monotone rise $0.27\to0.52$ |
| G5 | `TB6MS` 6-month T-bill | `AWHMAN`, `LNS13023621`, `PCED_HC` | 0.462 | 0.293 | $-0.37$ at impact, returns to zero by $h=8$ |
| G6 | `A0M046` help-wanted index | `MZMSL`, `PPIFGS`, `LNS14000012` | 0.529 | 0.148 | $-1.67$ at impact, $+1.20$ at $h=8$ |
| G7 | `UNLPNBS` unit labor payments | `IPFINAL`, `IPDBS`, `PCNDGC96_Q` | 0.473 | 0.211 | monotone: $-1.77$ at impact, $-0.58$ at $h=20$ |

**Chosen subset (fiscal).** G2 (highest fraction of long-lag coefficients,
oscillating response: the case where a VAR(4) should be most wrong) and G3
(lowest fraction, hump-shaped: the case where it should be least wrong). The
monetary pair is chosen by the same rule from the `spec_id = 1` monetary
draws and is named in the benchmark table below.

PENDING-LPW-BENCHMARK

**Validation of the Stata port.** `lpw_port_validate.do` (with
`lp_correct_bias.mata`) reads the exported draws, estimates LP(4) at
$h=0,\dots,20$, the Herbst–Johannsen correction, and the recursive VAR(4)
with the shock ordered first, and merges with the MATLAB estimates:

| Estimator | Max abs difference | Mean abs difference | Draws × horizons |
|---|---|---|---|
| `lp` | $8\times10^{-8}$ | $1\times10^{-8}$ | 4 × 21 (smoke, G1) |
| `lp_corrbias` | $9\times10^{-8}$ | $1\times10^{-8}$ | 4 × 21 |
| `svar` | $4\times10^{-8}$ | $1\times10^{-8}$ | 4 × 21 |
| `svar_corrbias` | not ported | — | — |

The differences are the CSV rounding of the MATLAB export (8 decimals).
PENDING-PORT-TIMING

**Tolerance.** Draw-by-draw agreement of LP, BC LP, and VAR with the
shipped MATLAB estimates: $10^{-6}$ absolute. Bias, sd, and RMSE across the
student's 500 draws (or 200 for a shorter run) against the shipped MATLAB
summary: within three Monte Carlo standard errors (sd$/\sqrt R$ for the bias;
sd$/\sqrt{2R}$ for the sd) at every horizon — an assertion the do-file makes.
Qualitative checks: LP $\lvert\mathrm{Bias}\rvert\le$ VAR $\lvert\mathrm{Bias}\rvert$
at $h\ge8$ in each design after correction; VAR sd $<$ LP sd at $h\ge8$ in
each design.

**Deliberate departures from the original.** (i) 500 draws instead of 5,000;
(ii) four DGPs instead of 6,000, so no median across DGPs is computed and
none is claimed; (iii) only the four least-squares and bias-corrected
estimators, not BVAR, penalized LP, VAR averaging, or SVAR-IV; (iv) the Pope
correction of the VAR is reported from the MATLAB benchmark but not ported
(Mata port of `VAR_CorrectBias.m`, which needs complex eigenvalues and
Kilian's stationarity adjustment, is an instructor extension); (v) the DFM is
estimated once and its parameters cached, exactly as `run_dfm.m` would
re-estimate them (the estimation is deterministic).

**Runtime.** MATLAB: DFM estimation 23 minutes once; Monte Carlo about 1.7 s
per draw for seven DGPs and four estimators. Stata (student side, per
design): see PENDING-PORT-TIMING.

### 8.2 STA07 — Stata problem set

Blueprint tasks made concrete. Two data sources: the toy (simulated by the
student's own do-file, seed 7) and the shipped LPW draws.

1. *Estimate LP and VAR responses on identical simulated datasets.*
   `sta07_1_estimate.do`: load `lpw_draws_g2.dta` (variables `mc t shock y1
   y2 y3 y4 y5`; response `y2`); for `mc = 1` estimate LP(4) at $h=0..20$ by
   `regress F`h'.y2 shock L(1/4).(shock y1 y2 y3 y4 y5)` and the recursive
   VAR(4) by six `regress` calls, `matrix accum` for $\hat{\mathbf S}$, and
   companion iteration; then the same with `var`/`irf create` as a check.
   Assertions: LP and VAR equal at $h=0$ to $10^{-8}$; hand VAR equals
   `irf`'s `oirf/sqrt(S11)` to $10^{-8}$; both equal the shipped MATLAB row
   for `mc = 1` to $10^{-6}$.
2. *Calculate bias, variance, and MSE separately.* `sta07_2_montecarlo.do`:
   loop over `mc = 1..R` ($R=200$ default, 500 optional) with `postfile`;
   `collapse` to mean, sd, bias, MSE by `method h`; assert the MSE identity;
   compare with the shipped summary within three Monte Carlo standard errors;
   report $\bar\theta$-relative values and $\omega^{*}_h$.
3. *Vary lag length and sample size.* `sta07_3_lags_sample.do`: on the LPW
   draws, $p\in\{2,4,8\}$ (the draws have $T=200$; $T=100$ by using rows
   $t\le100$); on the toy, $T\in\{100,200,800\}$ with $p\in\{1,2\}$; tabulate
   the horizon at which LP and VAR first differ and the bias and sd at
   $h\in\{2,4,8\}$.
4. *Compare point-estimation performance with confidence-interval
   performance.* `sta07_4_coverage.do`: on the toy, Newey–West ($m=h$) and
   lag-augmented HC bands for the LP (L5's two procedures), `irf create`
   delta-method bands for the VAR; coverage and mean width by horizon; on the
   LPW draws, the same for LP and VAR at $h\in\{0,4,8,12,20\}$ against the
   shipped true response. Assertions: LP Newey–West coverage at $h=0$ in
   $[0.90,0.99]$; the coverage table is written to `coverage_sta07.csv`.
5. *Explain why rankings depend on the criterion and the DGP.* Written in
   structured comments at the end of `sta07_4_coverage.do` and in the
   interpretation record: for each of the four designs, which estimator has
   the lower MSE at $h=8$, which has the better-covering band at $h=8$, and
   what $\omega^{*}_8$ is; one paragraph on why the toy's $\kappa$ and the
   designs' fraction of long-lag coefficients are the same idea.

Starter do-file structure (`lab-project/`): `master.do` (sets paths, runs the
four task files, writes `log/master.log`); `tests/test_port.do` (task 1
assertions); `tests/test_mc.do` (task 2 assertions); `data/` with provenance
README; `output/` for CSVs and figures. Expected outputs: `estimates_mc1.csv`,
`mc_summary_student.csv`, `lags_sample.csv`, `coverage_sta07.csv`, and four
figures (`fig_profiles_g2.pdf` etc.). Student runtime target: under 15
minutes for the full set at $R=200$.

### 8.3 HTML07 handoff

Lab 3 exports the toy design record and its bias/sd/MSE table; Lab 4 exports
the coverage table; Lab 5 exports the selected LPW design identifier and its
benchmark rows. `rep07_compare.do` reads the Lab 5 export and the student's
`mc_summary_student.csv` and prints the comparison with Monte Carlo standard
errors. Browser and Stata are compared on the same shipped draws for the LPW
designs (common input observations, as the blueprint requires); for the toy
the comparison is within Monte Carlo error because the two random-number
generators differ, and the handoff says so.

### 8.4 Data provenance and redistribution

- `lpw_draws_{g2,g3,mp?,mp?}.dta` and `lpw_benchmark_*.csv`: simulated by the
  course from LPW's calibrated DFM using the authors' MIT-licensed code; the
  files are simulation output, not the Stock–Watson data, and are shipped
  with the commit hash, the `spec_id`, the seed rule, and the MATLAB version.
  The DFM parameter cache (`scratch_G_1.mat`) is instructor material.
- `data_fred.dta`: from the Jordà–Taylor JEL replication repository (FRED
  series plus the CGKS shock); already shipped in the L6/L8/L13 practica
  under the course's attribution note; reused here unchanged.
- The toy draws are generated by the student's do-file; `toy_draw1.dta`
  (seed 7, replication 1) is shipped so that exercise 3 has a fixed sample.

### 8.5 Submission package

Replication record (target as stated in §8.1, commit hash, MATLAB version,
seeds, the numerical comparison table with Monte Carlo standard errors, and
the departures list copied verbatim); Stata submission (`master.do`,
`master.log`, saved estimates, figures, test logs); interpretation record
(estimand, the identifying assumption held fixed, units of each response
variable, the two uncertainty statements — MSE and coverage — and the
limitations of a four-design reproduction); HTML lab record (the five
predictions, selected settings, the Lab 3–5 exports, and the paragraph from
Lab 5).

---

## 9. Slides arc

1. **Title.** Lecture 7 — LPs versus VARs: estimands, bias, and variance.
2. **Two answers to one question.** `fig-l07-two-answers`: same data, same
   identification, same impact, different paths.
3. **One estimand, two projections.** The recursive VAR written as one-step
   regressions; the equivalence at $h\le p$ and as $p\to\infty$.
4. **The smallest model.** The toy equation and its true response; what
   $\kappa$ does.
5. **Iterating a VAR by hand.** $\mathbf A_1$, $\mathbf g$, and
   $\theta^{\mathrm{VAR}}_h=\mathbf e_2'\mathbf A_1^h\mathbf g$ for $h=0,\dots,4$.
6. **Where iteration goes wrong.** `fig-l07-population-bias`: exact at
   $h\le1$, $-0.364$ at $h=2$, sign change at $h=4$.
7. **One sample, two estimators.** `fig-l07-one-sample`: jagged and close,
   smooth and off.
8. **Bias, variance, MSE by horizon.** `fig-l07-bias-sd-horizon` with the
   $T=200$ table.
9. **How much must you care about bias?** $L_\omega$ and $\omega^{*}_h$.
10. **Lags and sample size.** `fig-l07-mse-ranking`: $p$ moves the target,
    $T$ moves the noise.
11. **Coverage is a different achievement.** `fig-l07-coverage` and the
    biased-band formula.
12. **Thousands of DGPs.** LPW's design in one table and their three
    conclusions in three lines.
13. **The bounded port.** `fig-l07-lpw-profiles` and what four designs can
    claim.
14. **Lab, exercises, and the question for Lecture 8.** Smoothness as a
    restriction.

---

## 10. Open questions for the editor

1. **Opening anchor.** The spine lists the monetary-unemployment data for L6,
   L8, and L13. Using it as L7's opening figure keeps one dataset running
   through Part II; confirm, or substitute the shelter data (IJK), for which
   the same LP-versus-VAR comparison would need a specification the course
   has not yet fixed.
2. **What to ship for REP07.** Option A: the 500 MATLAB draws for four designs
   (about 19 MB of `.dta` in double precision), giving exact draw-by-draw
   validation. Option B: the reduced ABCD matrices plus a Mata simulator,
   giving a statistical reproduction only. This brief assumes A; B is a
   fallback if the zip size is a concern.
3. **Monetary pair.** Chosen by the same rule as the fiscal pair (highest
   and lowest fraction of long-lag coefficients among the seven `spec_id = 1`
   monetary draws); confirm after the benchmark table, or ask for a pair
   chosen by response variable instead.
4. **Symbols.** $\kappa$ for the omitted MA coefficient, $\tau$ for the MA(1)
   coefficient, $\mathbf A_{\mathrm c}$ for the companion matrix, $\mathbf S$
   for the VAR residual covariance (to keep the ledger's $\boldsymbol\Sigma$
   for the cross-horizon covariance of $\hat{\boldsymbol\beta}$), $R$ for the
   replication count, $\omega$ for the bias weight. None is in the ledger;
   $R$ should be checked against L2's Monte Carlo notation before it is fixed.
5. **Pope correction.** Port it in Mata (about a page, complex eigenvalues,
   Kilian's adjustment) or report it from the MATLAB benchmark only and say
   "not ported." The brief assumes the latter for the first release.
6. **Lab 4's VAR band.** The live delta-method band treats the impact and
   slope blocks as independent. Accept as a labeled approximation, or replace
   with stored Stata `irf` results for the five horizons offered.
7. **Reading excerpts to freeze.** Plagborg-Møller–Wolf (2021): Sections 1–3
   and Propositions 1–2 (the equivalence and the finite-$p$ statement);
   LPW: Sections 2, 3.4 (Table 1), 4, 5.1–5.3, 5.6, and 6. The local LPW PDF
   is the January 2024 working paper; the published article should be frozen
   and page ranges assigned.
8. **Replication counts.** Students at $R=200$ (toy and LPW) with 500 as an
   option; instructor benchmark at 500. Confirm that 200 is acceptable for a
   "statistical reproduction" label in the practicum.
9. **New glossary keys.** `companion-form`, `bias-weight`,
   `encompassing-model` are proposed additions to L07's allocation in the
   terminology plan.
10. **L8 seam.** Penalized LP is named in `#sec-l07-thousands` as an estimator
    between the poles and left undefined; L8 owns its keys. Confirm that L8's
    opening ("the unrestricted LP as $H+1$ parameters") can take the handoff
    sentence as written in `#sec-l07-handoff`.
