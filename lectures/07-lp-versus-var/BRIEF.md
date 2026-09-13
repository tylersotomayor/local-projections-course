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
by draw in StataNow 19.5 on all 500 draws of each of the four chosen designs:
with the draws and estimates exported at full double precision (`%.17g`) and
read with `import delimited, asdouble`, the largest absolute difference over
126,000 comparisons is $4.1\times10^{-12}$ and none exceeds D13's $10^{-6}$
(§8.1). The smallest teaching model was simulated in Stata (500 replications
at $T=200$, the D2 instructor build, plus three controlled variants at 500),
and its population VAR(1) bias was derived by hand and
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
   the recursive VAR in the same variables share a population estimand at
   every horizon $h\le p$ (and at every horizon as $p\to\infty$), which
   equals $\theta_h$ under the identifying assumptions; write the
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

*Relation to Lectures 6 and 8.* The same file anchors L6 and L8 (Jordà–Taylor
Example 6) under a different specification, so the two sets of numbers are
not two estimates of one response. (i) Sample: 1969m3–2008m12 here (466 VAR
rows; LP rows 466 at $h=0$ to 418 at $h=48$), 1985m1–2000m1 there
($T_H=121$). (ii) Lag length: $p=12$ here, six lags there. (iii) Intervention
and identification: here $s_t=$ `RRCGShock` enters as an observed regressor
(ordered first in the VAR); there $s_t=$ `ffr`, instrumented by `RRCGShock`
and six of its lags. (iv) Units: here per unit of the Romer–Romer shock
(percentage points of the intended funds-rate change); there per percentage
point of the effective funds rate. (v) Outcome: the level $y_{t+h}$ here, the
long difference $y_{t+h}-y_{t-1}$ there; because both control for $y_{t-1}$,
this difference alone leaves $\beta_h$ unchanged (L2's same-regressor
equivalence). (vi) Estimation and HAC: horizon-by-horizon OLS with `newey`,
$m=h$, here; joint two-step `gmm` with `vce(hac nw 6)` there. L6 and L8
report $\hat\beta_0=-0.106$ and a peak of 1.22 at $h=31$ per percentage point
of the funds rate; the $-0.072$ and $+0.431$ above are per unit shock on a
different sample and lag length, and the magnitudes are not comparable. The
notes say so where the figure first appears and in its caption (§10 Q11).

*Smallest simulation (the running numerical example).* The model of the next
paragraph with $\rho=0.5$, $\tau=0.5$, $\kappa=0.5$, $\sigma_v=1$, $s_t\sim
\mathcal N(0,1)$ i.i.d., $T=200$ after a burn-in of 100, horizons $0,\dots,8$,
$R=500$ replications (the D2 instructor build; students default to $R=200$),
`set seed 7`, estimators LP(1), LP(2), VAR(1), VAR(2). Controlled variants,
also $R=500$: $\kappa=0$ (VAR(1) correctly specified), $T=800$, $T=100$.
Script `l07_toy_mc2.do`, driver `run_toy_configs.do`, outputs
`toy_summary_{base,k0,T800,T100}.csv` (baseline run 112 s in StataNow 19.5,
`toy_r500/`).

*Bounded LPW port (REP07, D13).* Four DGPs drawn by the authors' own
`pick_var_fn` with `spec_id = 1`: two fiscal (`dgp_type = 'G'`, government
spending fixed in position 1, response variable in position 2), G2 housing
starts and G3 business-equipment production, and two monetary
(`dgp_type = 'MP'`, federal funds rate fixed in position 5, response variable
in position 1), MP2 capacity utilization and MP3 business-services employment; observed-shock identification, unit-standard-deviation
shock, $T=200$, burn-in 100, $p=4$, $H=20$, 500 draws with the authors' seed
rule (`rng(1,'twister')`, then `seed(i) = 10 i + randi([0,9])`). The exported
draws, true responses, and MATLAB estimates are the benchmark inputs;
students re-estimate $R=200$ of them by default (D2). Section 8.1 gives the
selection rule and the benchmark numbers.

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
first, implies $\theta^{\mathrm{VAR}}_h=\boldsymbol\iota_2'\mathbf A_1^{h}\mathbf g$
with $\mathbf g=(1,\ S_{21}/S_{11})'$, where $\mathbf S$ is the residual
covariance. The DGP is a VAR(2) in $\mathbf y_t$ exactly and a VAR(1) only
when $\kappa=0$: the population VAR(1) coefficients on $(s_{t-1},y_{t-1})$ in
the $y$ equation are $a_s=\tau-\kappa\psi$ and $a_y=\rho+\kappa\psi$ with
$\psi=\theta_1/(\sigma_y^2-1)$ and $\sigma_y^2=\operatorname{Var}(y_t)=
1+\theta_1^2+\theta_2^2/(1-\rho^2)+\sigma_v^2/(1-\rho^2)$. Baseline numbers:
$\sigma_y^2=4.6667$, $\psi=0.2727$, $a_y=0.6364$, $a_s=0.3636$;
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
   Monte Carlo at $T=200$ ($R=500$) shows the LP nearly unbiased with a
   standard deviation that nearly doubles between $h=0$ and $h=3$ (0.080 to
   0.150), the VAR(1) biased where the
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
   bias-to-standard-deviation ratio, so at $T=200$ the VAR(1)'s 95 percent
   band at $h=2$ covers in 10 percent of replications against 93 percent for
   the LP's Newey–West band; where the VAR(1) has the lower mean squared
   error ($h=8$ at $T=800$, RMSE 0.030 against 0.075) its band still covers
   only 76 percent against the LP's 95, so the two criteria can rank the
   methods in opposite orders at the same horizon.
7. `#sec-l07-thousands` *Thousands of DGPs.* LPW draw 6,000 five-variable DGPs
   from a DFM fitted to the Stock–Watson data and find, at $T=200$ and $p=4$,
   the same trade-off in the median DGP — LP has lower bias and roughly twice
   the VAR's standard deviation at long horizons — with bias-corrected LP the
   best estimator only when $\omega\gtrsim0.9$ and VAR-type estimators
   (least-squares or Bayesian) otherwise; the estimators between the poles are
   named and located on the trade-off.
8. `#sec-l07-bounded-port` *A bounded port.* Four of LPW's DGPs, simulated by
   the authors' code and re-estimated in Stata with draw-by-draw agreement within
   $4.1\times10^{-12}$ (D13's $10^{-6}$), keep the variance half of the profile in every design (VAR sd
   below LP sd at every $h\ge5$) and lose the bias half in G2 and, beyond
   $h=14$, in MP3, so the profile moves across designs; the port cannot speak about medians
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
$\operatorname{Var}$, $\operatorname{MSE}$; from Section 4: $R$ (D2, D20). New in this lecture (Section 2
below; $\mathbf A_{\mathrm c}$, $\mathbf S$, $\tau$, $\kappa$, and $\omega^{*}_h$ as
approved in D20): $\mathbf A_1,\dots,\mathbf A_p$, the companion matrix
$\mathbf A_{\mathrm c}$, the residual covariance $\mathbf S$, the impact vector
$\mathbf g$, the selection vector $\boldsymbol\iota_j$, the toy parameters $\tau$,
$\kappa$, $\sigma_v$, the population VAR(1) coefficients $a_s,a_y$ and the
projection coefficient $\psi$, the bias weight $\omega$ and loss $L_\omega$, the
indifference weight $\omega^{*}_h$, the bias-to-sd ratio $d_h$, and the
LPW scale $\bar\theta=\sqrt{\tfrac{1}{21}\sum_{h=0}^{20}\theta_h^2}$.

**Likely glossary terms.** All sixteen keys the terminology plan allocates to
L07 are used, including the three approved in D22. One-line definition drafts:

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
- `companion-form` (D22) — The stacking of a VAR($p$) into a VAR(1) in the
  vector $(\mathbf y_t',\dots,\mathbf y_{t-p+1}')'$ so that iteration is a
  matrix power; the largest eigenvalue of the companion matrix is the VAR's
  largest root.
- `bias-weight` (D22) — The weight $\omega\in[0,1]$ on squared bias in the loss
  $L_\omega$; $\omega=\tfrac12$ is mean squared error and $\omega^{*}_h$ is the
  weight at which two estimators tie.
- `encompassing-model` (D22) — A large calibrated model from which many
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
| `fig-l07-two-answers` | Do two estimators with the same identification and data give the same response? | Same at $h=0$, apart after 3 months, 0.23 points apart at $h=30$; both bands are wide; the caption states that this specification differs from L6/L8's LP-IV (sample, lags, observed shock versus instrumented `ffr`, units, outcome, HAC) and that the magnitudes are not comparable | `realdata_lp_var.csv` (Stata, stored) | Lua reads CSV; two panels: paths with bands, and the difference |
| `fig-l07-direct-iterated` | What does "iterate" do that "project" does not? | Direct: one arrow from $t$ to $t+h$; iterated: $h$ one-step arrows through $\mathbf A_1$ | Schematic, no data | TikZ diagram |
| `fig-l07-population-bias` | Where does the iterated response go wrong in population? | True $\theta_h$ versus $\theta^{\mathrm{VAR}}_h$ for VAR(1) and VAR(2): exact at $h\le p$, geometric after; bias changes sign | Exact recursion with $\rho,\tau,\kappa$ | Lua arithmetic |
| `fig-l07-one-sample` | How different are the two estimators on one sample? | One draw: LP(1) jagged around the truth, VAR(1) smooth and off at $h=2$ | Draw 1 of `toy_draws_base.dta` (stored) | Lua reads CSV |
| `fig-l07-bias-sd-horizon` | How do bias and variance move with $h$? | Two panels: $\lvert\mathrm{Bias}\rvert$ and sd by $h$ for LP(1), LP(2), VAR(1), VAR(2); LP(1) sd nearly doubles by $h=3$; VAR(1) sd peaks at $h=1$ and VAR(2) sd at $h=2$ | `toy_summary_base.csv` | Lua reads CSV |
| `fig-l07-mse-ranking` | Which estimator has the lower MSE at each horizon? | Small multiples of MSE by $h$ at $T\in\{100,200,800\}$ and $\kappa\in\{0,0.5\}$; the crossing moves with $T$ and $\kappa$ (stated in the caption) | `toy_summary_{base,k0,T800,T100}.csv` | Lua reads CSVs |
| `fig-l07-coverage` | Does the lower-MSE estimator also have the better band? | Coverage by $h$ of the LP Newey–West band and the VAR delta-method band at $T=200$ and $T=100$; VAR under-covers where it is biased | `toy_summary_base.csv`, `toy_summary_T100.csv` | Lua reads CSVs |
| `fig-l07-lpw-profiles` | Does the toy's profile survive in realistic DGPs? | G2, G3, MP2, MP3: relative $\lvert\mathrm{Bias}\rvert$ and sd by $h$ for LP, BC LP, VAR, and BC VAR (MATLAB only, D13); VAR sd lower at every $h\ge5$ in all four, bias ranking flips between designs; labeled stored result, 500 draws | `mc_summary_G_1.csv`, `mc_summary_MP_1.csv` (DGPs 2 and 3 of each) | Lua reads CSVs |

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
| $\mathbf S$ | Residual covariance of the VAR (D20), $\mathbf S=\operatorname{Var}(\mathbf e_t)$ (estimate $\hat{\mathbf S}$) | $n\times n$ | — | squared units | §2 | §3, §8; not the ledger's $\boldsymbol\Sigma$ |
| $\mathbf g$ | Impact vector of a unit shock ordered first, $\mathbf g=\mathbf S_{\cdot1}/S_{11}$ | $n\times1$ | $h=0$ | units of $\mathbf y$ per unit $s$ | §2 | §3, §8 |
| $\mathbf A_{\mathrm c}$ | Companion matrix of the VAR($p$) (D20) | $np\times np$ | — | — | §3 | §5, §8, exercise 3 |
| $\boldsymbol\iota_j$ | Selection vector picking element $j$ | $n\times1$ or $np\times1$ | — | — | §2 | §3 |
| $\theta^{\mathrm{VAR}}_h$ | Population response implied by the VAR($p$), $\boldsymbol\iota_{\mathrm{resp}}'\mathbf A_{\mathrm c}^{\,h}\tilde{\mathbf g}$ | scalar | horizon $h$ | units of $y$ per unit $s$ | §2 | §3–§8 |
| $\theta^{\mathrm{LP}}_h$ | Population LP coefficient with $p$ lags; equals $\theta_h$ when $s_t$ is unpredictable | scalar | horizon $h$ | as above | §2 | §3–§8 |
| $\hat\theta^{\mathrm{LP}}_h,\hat\theta^{\mathrm{VAR}}_h$ | Their estimators in one sample | scalar | $h$ | as above | §3 | §4–§8 |
| $\tau,\kappa$ | MA coefficients on $s_{t-1}$ and $s_{t-2}$ in the toy (D20); $\kappa\ne0$ is the misspecification of a VAR(1) | scalars | — | units of $y$ per unit $s$ | §3 | §4–§6, lab |
| $\sigma_v$ | Standard deviation of the unobserved shock $v_t$ | scalar | — | units of $y$ | §3 | §4, lab |
| $\sigma_y^2$ | $\operatorname{Var}(y_t)$ in the toy | scalar | — | squared units of $y$ | §3 | exercise 2 |
| $\psi$ | Coefficient on $y_{t-1}$ in the projection of $s_{t-2}$ on $(s_{t-1},y_{t-1})$ (not the ledger's Gaussian width $c$), $\psi=\theta_1/(\sigma_y^2-1)$ | scalar | — | — | §3 | exercise 2 |
| $a_s,a_y$ | Population VAR(1) coefficients in the $y$ equation | scalars | — | — | §3 | §4, exercise 2 |
| $\operatorname{Bias}_h,\operatorname{Var}_h,\operatorname{MSE}_h$ | $\mathbb E[\hat\theta_h]-\theta_h$, $\operatorname{Var}(\hat\theta_h)$, and their combination, per estimator | scalars | $h$ | units, squared units | §4 | §5–§8 |
| $R$ | Number of Monte Carlo replications (ledger §4, D20); `global R`, students 200 and instructor builds 500 (D2); Monte Carlo standard error of a mean is $\mathrm{sd}/\sqrt R$ | integer | — | — | §4 | §5–§8, practicum |
| $\omega$ | Bias weight in $L_\omega=\omega\operatorname{Bias}^2+(1-\omega)\operatorname{Var}$ | scalar in $[0,1]$ | — | — | §4 | §7, lab 3, 5 |
| $\omega^{*}_h$ | Indifference value of the bias weight (D20), $(\operatorname{Var}^{\mathrm{LP}}_h-\operatorname{Var}^{\mathrm{VAR}}_h)/[(\operatorname{Var}^{\mathrm{LP}}_h-\operatorname{Var}^{\mathrm{VAR}}_h)+(\operatorname{Bias}^{\mathrm{VAR}\,2}_h-\operatorname{Bias}^{\mathrm{LP}\,2}_h)]$ | scalar | $h$ | — | §4 | §7, §8, exercise 5 |
| $\bar\theta$ | LPW scale $\sqrt{\tfrac1{21}\sum_{h=0}^{20}\theta_h^2}$ used to make bias and sd unit-free | scalar | — | units of $y$ | §7 | §8, fig-l07-lpw-profiles |
| $\Phi(\cdot)$, $d_h$ | Standard normal cdf and the bias-to-sd ratio $d_h=\operatorname{Bias}_h/\operatorname{sd}_h$, for the coverage-of-a-biased-band formula | — | — | — | §6 | exercise 7 |
| $p$, $T$, $H$, $T_h$, $m$ | As in the ledger | — | — | — | §2 | throughout |

Stata names in the practicum mirror the ledger: `s`, `y`, `w1`–`wp`, `h`,
`beta_h`, `se_h`; new here: `theta_var_h`, `theta_true_h`, `A_c`, `S`, `g`,
`omega`, and the do-file's `global R` (D2).

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
| companion form | glossary (D22) | `companion-form` | as drafted | `#sec-l07-direct-iterated`, VAR(2) iteration |
| bias weight | glossary (D22) | `bias-weight` | as drafted | `#sec-l07-bias-variance`, loss display |
| encompassing model | glossary (D22) | `encompassing-model` | as drafted | `#sec-l07-thousands`, design paragraph |
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
| At $T=200$ the LP's sd nearly doubles by $h=3$ and the VAR(1)'s sd is smaller from $h=2$ | Monte Carlo table, $R=500$ (D2) | table + figure | `toy_summary_base.csv` | computed | `tbl-l07-toy-mc`, `fig-l07-bias-sd-horizon` |
| The ranking depends on $\omega$ through $\omega^{*}_h$ | formula §6.5 applied to the table | equation + table | `toy_summary_base.csv` | computed | `eq-l07-omega-star` |
| Adding the missing lag removes the VAR bias at a variance cost; adding a lag to the LP changes little | VAR(2) and LP(2) rows of the table | table + figure | `toy_summary_base.csv` | computed | `tbl-l07-toy-mc` |
| Larger $T$ shrinks LP variance but not VAR(1) bias; smaller $T$ does the reverse | $T=800$ and $T=100$ runs | figure | `toy_summary_T800.csv`, `toy_summary_T100.csv` | computed | `fig-l07-mse-ranking` |
| With $\kappa=0$ the VAR(1) is unbiased and dominates | $\kappa=0$ run | figure | `toy_summary_k0.csv` | computed | `fig-l07-mse-ranking` |
| A biased band under-covers by $\Phi(1.96-d_h)-\Phi(-1.96-d_h)$, $d_h=\operatorname{Bias}_h/\operatorname{sd}_h$ | formula §6.6 against Monte Carlo coverage | equation + figure | `toy_summary_base.csv` | computed | `eq-l07-biased-coverage`, `fig-l07-coverage` |
| LPW: LP lower bias, VAR lower variance in the median DGP; BC LP best iff $\omega\gtrsim0.9$; VAR/BVAR otherwise; AIC picks $\hat p\le2$ | LPW Sections 5.1–5.3, 5.6, Figures 2, 3, 6; Table 1 | prose + one table of Table 1 rows | R09 (working-paper PDF, Documents/) | cite; verify against published version | `tbl-l07-lpw-table1` |
| In the four ported DGPs the VAR's sd is below the LP's at every $h\ge5$; which estimator is less biased depends on the design | 500-draw MATLAB benchmark, bias and sd relative to $\bar\theta$ (§8.1) | figure + table | `mc_summary_G_1.csv`, `mc_summary_MP_1.csv`; `brief_fill/port_table.py` | computed (statistical reproduction) | `fig-l07-lpw-profiles`, `tbl-l07-port-benchmark` |
| The Stata port equals the MATLAB estimators draw by draw | smoke: max abs difference $9\times10^{-8}$, 4 draws × 21 horizons (8- and 10-decimal CSVs); full, on `%.17g` exports read with `asdouble`: max $4.1\times10^{-12}$ over 500 draws × 21 horizons × 3 estimators × 4 designs, none above $10^{-6}$ | table | `run_validate_smoke.log`; `port_hp/*/run_*.log` | verified at D13's $10^{-6}$ | `tbl-l07-port-validation` |

---

## 5. Assessment map

Ten exercises; six are computational in Stata. Tags follow the guide.

| Learning outcome | Exercise | Tags | Mode of work | Hint strategy | Solution check | Linked lab section |
|---|---|---|---|---|---|---|
| 1 | 1. Iterate a VAR(1) by hand | [core] [pencil] | Given $\mathbf A_1$ and $\mathbf g$ from the notes ($a_s=0.3636$, $a_y=0.6364$, $s$-equation zero, $\mathbf g=(1,1)'$), compute $\theta^{\mathrm{VAR}}_h$ for $h=0,\dots,4$; show $h\le1$ equals the direct projection; write the same recursion for a VAR(2) in companion form | Name the object carried forward ($\mathbf A_1^{h-1}\mathbf g$), not the formula | Values $1,1,0.636,0.405,0.258$; companion matrix has the identity in the lower-left block | Lab 1 |
| 2 | 2. The population bias of a misspecified VAR(1) | [core] [pencil] | Derive $a_s,a_y$ by projecting $\kappa s_{t-2}$ on $(s_{t-1},y_{t-1})$; compute with the baseline parameters; repeat with $\kappa=0$ | Suggest the normal equations with $\operatorname{Cov}(s_{t-2},y_{t-1})=\theta_1$ | $\psi=0.2727$, bias $-0.364$ at $h=2$; zero bias when $\kappa=0$; assertion in the companion do-file | Lab 1 |
| 1, 2 | 3. Same sample, two estimators (Stata) | [core] [computational] | On the shipped draw (`toy_draw1.dta`, seed 7), build LP(1) with `regress` and VAR(1) with two regressions plus companion iteration; compare with `var`/`irf create` | Point to FWL for $h=0$ and to the residual covariance for $\mathbf g$ | `assert` equality at $h=0$ to $10^{-8}$ between LP, hand VAR, and `irf`; report the gap at $h=1$ and compare it with the Monte Carlo s.d. of the LP(1)−VAR(1) gap (0.032 at $T=200$, §6.4) | Lab 2 |
| 3 | 4. A Monte Carlo of the trade-off (Stata) | [core] [computational] | `global R`, default $R=200$ (D2), replications of the toy at $T=200$; LP(1) and VAR(1); bias, sd, MSE by horizon; `postfile` | Suggest storing every replication and summarizing once | `assert` that VAR bias at $h=2$ is within $3\,\mathrm{sd}/\sqrt R$ of $-0.386$, the instructor-build mean in `toy_summary_base.csv` (the population $-0.364$ plus a small-sample bias near $-0.02$; an assertion against $-0.364$ fails at $R=500$), and that $\mathrm{MSE}=\mathrm{Bias}^2+\mathrm{Var}\cdot(R-1)/R$ | Lab 3 |
| 3 | 5. How much must you care about bias? | [core] [pencil] | From the notes' table compute $\omega^{*}_h$ at $h=2,4,8$; explain why $\omega^{*}$ can exceed 1 or fall below 0 | Separate the two differences before dividing | From `toy_summary_base.csv` ($R=500$): $\omega^{*}_2=0.033$; VAR(1) dominates at $h=4$ ($\Delta B<0<\Delta V$, $\omega^{*}_4=1.015$); $\omega^{*}_8=0.978$; the sign discussion | Lab 3 |
| 4 | 6. Lags and sample size (Stata) | [computational] | Rerun exercise 4 with $p=2$, then with $T=800$; tabulate which biases vanish and which variances shrink; state the two limits in which LP and VAR converge | Ask which change alters the population object and which alters only the sample | VAR(2) bias at $h=2$ within Monte Carlo error of 0; LP sd at $T=800$ about half of $T=200$ | Lab 3 |
| 5 | 7. Coverage is a different achievement (Stata) | [computational] | Add Newey–West ($m=h$) bands for the LP and `irf` delta-method bands for the VAR to exercise 4; compute coverage; compare the coverage ranking with the MSE ranking at $h=2$ and $h=4$, then at $h=3$ with $T=100$ | Give the biased-band formula and ask for $d_h$ at $h=2$ | Coverage within Monte Carlo error of the notes; the formula's prediction matches; the rankings agree at $h=2$ (LP) and $h=4$ (VAR) and disagree at $h=3$, $T=100$ (VAR(1) RMSE 0.178 against 0.217, coverage 0.79 against 0.92; `toy_summary_T100.csv`) | Lab 4 |
| 5 | 8. Two answers on real data (Stata) | [data] [computational] | Reproduce `fig-l07-two-answers`; rerun with $p=6$ and $p=24$; write three sentences on why neither estimator is wrong | Remind that the impact estimate must agree exactly | Impact equality assertion; the $h=30$ gap at each $p$ recorded | Lab 2 |
| 5 | 9. Reading thousands of DGPs | [core] [pencil] | From LPW's Table 1 and Figures 2, 3, 6: what is held fixed, which conclusion needs bias correction, what a median across DGPs does not say; classify five sentences as supported or unsupported | Ask "for which $T$, $p$, identification, and loss?" of each sentence | Answer key with the section of LPW that decides each | Lab 5 |
| 3, 5 | 10. Port a bias correction (Stata, Mata) | [extra] [computational] | Implement the Herbst–Johannsen recursion (given) in Mata; verify against the shipped MATLAB benchmark on draw 1 of a ported DGP; compare bias and sd with and without correction across the first $R=200$ draws (`global R`, D2) | Say what $w$ is (the $h=0$ control matrix) and what $T$ means in the formula | Max abs difference $<10^{-6}$ on draw 1; corrected LP has lower bias and higher sd | Lab 5 |

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
$\operatorname{Var}(y_{t-1})=\sigma_y^2$; solving gives coefficient $\psi=\theta_1/(\sigma_y^2-1)$
on $y_{t-1}$ and $-\psi$ on $s_{t-1}$. (ii) Hence $a_y=\rho+\kappa\psi$,
$a_s=\tau-\kappa\psi$. (iii) $\sigma_y^2=\sum_j\theta_j^2+\sigma_v^2/(1-\rho^2)$
with $\sum_j\theta_j^2=1+\theta_1^2+\theta_2^2/(1-\rho^2)$. (iv) The $s$
equation has zero coefficients; $\mathbf A_1=\begin{pmatrix}0&0\\a_s&a_y\end{pmatrix}$,
$\mathbf g=(1,\ S_{21}/S_{11})'=(1,1)'$ because $\operatorname{Cov}(e_{s,t},e_{y,t})=\operatorname{Var}(s_t)=1$.
(v) $\theta^{\mathrm{VAR}}_0=1$, $\theta^{\mathrm{VAR}}_1=a_s+a_y$,
$\theta^{\mathrm{VAR}}_h=a_y\theta^{\mathrm{VAR}}_{h-1}$ for $h\ge2$: exact at
$h=1$ because $a_s+a_y=\rho+\tau=\theta_1$ (the $\kappa\psi$ terms cancel — this
is the population equivalence at $h\le p$ made visible), geometric with ratio
$a_y=0.636$ afterwards while the truth has ratio $\rho=0.5$ from $h=3$ and a
kink at $h=2$. Interpretation: iteration replaces the missing lag by "what
$y_{t-1}$ knows about $s_{t-2}$," and that substitute is right one step ahead
and wrong afterwards. Numerical check: $\sigma_y^2=4.6667$, $\psi=0.2727$,
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
4\times10^{-8}$ at $h=0$ across draws. At $1\le h\le p$ the population
estimands coincide, but the estimates are different functions of the sample
(at $h=1$ the VAR(1) uses $\hat a_s+\hat a_y\hat g_2$, the LP a direct
regression on a different row set). When the VAR($p$) is misspecified, as the
VAR(1) is in the toy, the estimates differ by $O_p(T^{-1/2})$ because each
weights the sample differently; only their means agree to $O(1/T)$. When the
VAR($p$) is correctly specified, the first-order expansions of the two
estimators coincide (at $h=1$ both are
$\boldsymbol\iota_2'T^{-1}\sum_t(\mathbf e_{t+1}+\mathbf A_1\boldsymbol\eta_t)s_t$
with $\boldsymbol\eta_t=\mathbf e_t-\mathbf g s_t$) and the gap is $O_p(1/T)$.
Numerical check (`gapcheck/gap.do`; baseline draws $R=500$, seed 7, and the
$T=100$ and $T=800$ variants): $\hat\theta^{\mathrm{LP}}_1-\hat\theta^{\mathrm{VAR}}_1$
for LP(1) and VAR(1) has Monte Carlo mean $0.0020$, $0.0024$, $0.0006$ and
s.d. $0.047$, $0.032$, $0.015$ at $T=100,200,800$ ($\sqrt T\times$s.d.
$4.7$, $4.5$, $4.1$), against estimator s.d. $0.112$ (LP) and $0.132$ (VAR)
at $T=200$; for LP(2) and VAR(2) the s.d. is $0.027$, $0.013$, $0.003$ at
$h=1$ ($T\times$s.d. $2.7$, $2.6$, $2.3$) and $0.044$, $0.020$, $0.005$ at
$h=2$. In the real data the $h=3$ estimates are $-0.198$ and $-0.175$, a gap
small against standard errors near $0.06$.

**6.5 MSE, the loss, and the indifference weight.** Source identity:
$\mathbb E[(\hat\theta_h-\theta_h)^2]=(\mathbb E\hat\theta_h-\theta_h)^2+\operatorname{Var}(\hat\theta_h)$
(add and subtract $\mathbb E\hat\theta_h$; the cross term vanishes). The Monte
Carlo estimator uses the mean and the population-form variance, so
$\widehat{\mathrm{MSE}}=\widehat{\mathrm{Bias}}^2+\widehat{\mathrm{sd}}^2(R-1)/R$
(Stata's `sd` divides by $R-1$; the do-file asserts the identity). Loss:
$L_\omega=\omega\operatorname{Bias}^2+(1-\omega)\operatorname{Var}$; LP is
preferred iff $\omega(\Delta V+\Delta B)\ge\Delta V$, with
$\omega^{*}_h=\Delta V/(\Delta V+\Delta B)$, $\Delta V=\operatorname{Var}^{\mathrm{LP}}_h-\operatorname{Var}^{\mathrm{VAR}}_h$,
$\Delta B=\operatorname{Bias}^{\mathrm{VAR}\,2}_h-\operatorname{Bias}^{\mathrm{LP}\,2}_h$.
If $\Delta V+\Delta B>0$, LP is preferred iff $\omega\ge\omega^{*}_h$; if
$\Delta V+\Delta B<0$, LP is preferred iff $\omega\le\omega^{*}_h$. The four
cases: $\Delta V,\Delta B>0$ (LP less biased, VAR less variable), LP iff
$\omega\ge\omega^{*}_h\in(0,1)$; $\Delta V,\Delta B<0$ (LP less variable, VAR
less biased), LP iff $\omega\le\omega^{*}_h\in(0,1)$; $\Delta B<0<\Delta V$,
the VAR dominates; $\Delta V<0<\Delta B$, the LP dominates. In the last two
$\omega^{*}_h$ falls outside $[0,1]$, and §8.1 prints the dominance instead
of the number. Toy values (`toy_summary_base.csv`, $R=500$, LP(1) against
VAR(1)): LP dominates at $h=1$; $\omega^{*}_2=0.033$; $\omega^{*}_3=0.522$;
VAR dominates at $h=4$; $\omega^{*}_8=0.978$. This is LPW's equation (4) and their $\omega^{*}_h$ with the
course's symbols. Numerical check: the toy table in §8.2 below and the
`omega*` column of `summarize_lpw.py`.

**6.6 Coverage of a band around a biased estimator.** Source identity: if
$\hat\theta_h\sim\mathcal N(\theta_h+\operatorname{Bias}_h,\operatorname{sd}_h^2)$ and the band is
$\hat\theta_h\pm1.96\,\widehat{\operatorname{sd}}_h$ with $\widehat{\operatorname{sd}}_h\approx\operatorname{sd}_h$, coverage is
$\Pr(\lvert\hat\theta_h-\theta_h\rvert\le1.96\operatorname{sd}_h)=\Phi(1.96-d_h)-\Phi(-1.96-d_h)$ with
$d_h=\operatorname{Bias}_h/\operatorname{sd}_h$ (D20 leaves $b$ to Lecture 8).
Values (exact normal cdf): $d_h=0.5\Rightarrow0.921$; $1\Rightarrow0.830$; $2\Rightarrow0.484$;
$3\Rightarrow0.149$. Numerical check (`toy_summary_base.csv`, $R=500$): the
Monte Carlo sd of $\hat\theta^{\mathrm{VAR}}_2$ for VAR(1) is 0.1117, so the
population bias $-0.364$ gives $d_2=-3.25$ and
$\Phi(1.96-d_2)-\Phi(-1.96-d_2)=0.098$ (the Monte Carlo bias $-0.386$ gives
$d_2=-3.45$ and 0.068), against simulated coverage 0.100 for the `irf`
delta-method band (Monte Carlo standard error 0.013; mean width 0.429, so the
mean se 0.109 is close to the sd); the LP(1) Newey–West band at $h=2$ covers
0.930.

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
median across DGPs is taken; the port reports the same ratio per DGP. Values:
G2 1.171, G3 0.426, MP2 0.588, MP3 0.573 (§8.1).

**Worked numerical example for the notes (exact inputs).** Baseline toy,
$\rho=\tau=\kappa=0.5$, $\sigma_v=1$. Truth $\theta_2=1$. VAR(1):
$\sigma_y^2=1+1+1/0.75+1/0.75=4.6667$; $\psi=1/3.6667=0.2727$;
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
recursion of §6.1; $a_s,a_y,\psi,\sigma_y^2$ by the closed forms of §6.3;
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
Invariants: the $s$ and $v$ innovations are generated once per seed at
$T_{\max}=800$ plus the burn-in of 100, and a sample of length $T$ uses the
first $T+100$ of them; $y$ is rebuilt from those innovations when $\kappa$
changes; changing $T$ or a parameter never redraws shocks, and neither does
changing $p$ or the estimator (stated on screen); $\kappa=0.5$ unless changed. Controls:
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
so that changing $\omega$ recomputes nothing; each replication's innovations
are generated once per seed at $T_{\max}=800$ plus burn-in, and a run at $T$
uses the first $T+100$; changing $p$ re-estimates on the same draws, and
changing $\kappa$ rebuilds $y$ from the same innovations; changing $T$ or a
parameter never redraws shocks (stated on screen). Controls:
$R\in\{100,200,500\}$ (default 200, the student default of D2); $T\in\{100,200,800\}$; $p\in\{1,2\}$;
$\kappa\in\{0,0.25,0.5\}$; $\omega\in[0,1]$ slider (default 0.5). Computation:
for each replication, LP($p$) and VAR($p$) at $h=0,\dots,8$; then bias, sd,
MSE, $L_\omega$, and $\omega^{*}_h$ per horizon; Monte Carlo standard errors
of the bias shown as error bars. Display: two panels (bias, sd) and a strip
showing which estimator wins $L_\omega$ at each $h$. Reactive sentence: "At
$\omega=0.50$ and $T=200$, the LP(1) has the lower loss at $h=1,2$ and the
VAR(1) at $h=3,\dots,8$; the LP would be preferred at $h=3$ only if
$\omega\ge0.xx$." (Instructor build, $R=500$: $\omega^{*}_3=0.52$, so $h=3$ is
close to a tie and a live $R=200$ run may flip it.) Controlled
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
and the indicator that the band covers $\theta_h$; for the VAR(1), the point
estimate is Lab 3's full companion iteration
$\boldsymbol\iota_2'\hat{\mathbf A}_1^{h}\hat{\mathbf g}$, never the shortcut
$a_y^{h-1}(a_s+a_y g_2)$, which sets the $s$-equation coefficients to zero.
Its delta-method standard error uses a numerical gradient of that iteration
with respect to all four elements of $\hat{\mathbf A}_1$ and $\hat g_2$, with
$\widehat{\operatorname{Var}}(\operatorname{vec}\hat{\mathbf A}_1)=\hat{\mathbf S}\otimes(\mathbf X'\mathbf X)^{-1}$
(coefficients stacked equation by equation), $\widehat{\operatorname{Var}}(\hat g_2)$
from the regression of the $y$ residual on the $s$ residual, and the two
blocks treated as asymptotically independent, as in Stata's delta method. The
$s$-equation terms are first order (the derivative of $\theta^{\mathrm{VAR}}_2$
with respect to each $s$-equation coefficient is $a_s=0.36$), so dropping them
would narrow the band and create part of the under-coverage the lab attributes
to bias. Per D30 the panel label begins "Approximation" (a live delta method,
not Stata's `irf create` output) and the collapsed explanation states the
independence assumption; if the full gradient is not built, the panel shows
the stored `irf create` coverage from `toy_summary_{base,T100,T800}.csv`,
labeled "stored result", instead of a live band. Display: a hit-or-miss strip of 100 replications for each
estimator (as in L5's figure), coverage rates, mean widths, and the MSE
ranking from Lab 3 beside the coverage ranking. Reactive sentence: "At $h=8$
and $T=800$ the VAR(1) has the lower MSE but its band covers in only xx
percent of replications because its bias is x.x times its standard deviation;
the LP band covers in 9x percent." (At $h=2$ and $T=200$ the LP wins on both
criteria; stored values at $h=8$, $T=800$: RMSE 0.030 against 0.075, coverage
0.76 against 0.95.) Controlled comparisons: move $h$ from 2 to 8 at $T=800$;
move $T$ from 200 to 100 at $h=3$. Prediction prompt: "Will the VAR(1) band at $h=2$
cover more or less often than the LP band, and why?" Handoff: exports the
coverage table with the design record; STA07 task 4 reproduces it with
`newey` and `irf create`.

**Lab 5 — Four ported DGPs from thousands (stored simulation result).**
Learning question: does the toy's profile survive in realistic DGPs, and how
much does the profile move from one DGP to another? Invariants: the stored
500-draw benchmark; nothing is recomputed except the loss. Controls: DGP
(G2 housing starts, G3 business-equipment production, MP2 capacity
utilization, MP3 business-services employment); estimator set (LP, BC LP,
VAR, and BC VAR, the last from the MATLAB benchmark only, D13); $\omega$ slider; "relative to $\bar\theta$" toggle. Computation: reads
the committed JSON exported from `mc_summary_G_1.csv` and
`mc_summary_MP_1.csv` (with generation metadata: commit, seeds, $R=500$,
MATLAB R2024a, date); computes $L_\omega$ and the winner per horizon live.
Display: true response, mean estimate of each estimator, bias and sd panels,
winner strip. Reactive sentence: "In the [response variable] DGP, at
$\omega=0.50$ the least-squares VAR has the lower loss at $x$ of 20 horizons;
averaged over $h=0,\dots,20$, bias-corrected LP has the lowest loss [only when
$\omega\ge x.xx$ / at no $\omega$]." Controlled comparisons: same $\omega$
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
| full G | G, `spec_id=1`, 500 draws, export DGPs 1–7 | 2,854 s (Monte Carlo loop 2,302 s: draws 1–50 took 1,742 s, draws 51–500 1.24 s each; `matlab_full_G.log`) | `mat_out_full/` same file set for G |
| full MP | MP, `spec_id=1`, 500 draws, export DGPs 1–7 | 443 s (Monte Carlo loop 417 s, 0.83 s per draw; `matlab_full_MP.log`) | `mat_out_full/` same file set for MP |

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

The seven monetary DGPs of `spec_id = 1` (`FEDFUNDS` always at position 5,
response variable at position 1; $R^2_0$ and frac as above, then $\theta_h$ at five horizons; `dgp_summary_MP_1.csv`
prints MP3's largest root as 1.0001, every other as 1.0000):

| DGP | Response (position 1) | Other variables | $R^2_0$ | frac | $\theta_h$ at $h=0,4,8,12,20$ |
|---|---|---|---|---|---|
| MP1 | `LNS13008756` unemployed 5–14 weeks (log) | `CPILFESL`, `PAYEMS`, `GDPC96` | 0.317 | 0.179 | 0.850, 3.421, 5.288, 3.883, 2.439 |
| MP2 | `TCU` capacity utilization | `PCED_HC`, `USPBS`, `HOUST` | 0.348 | 0.480 | 0.424, −0.431, −0.867, −0.599, −0.514 |
| MP3 | `USPBS` employment, business services (log) | `PCED_G`, `USINFO`, `CONSUMER` | 0.365 | 0.114 | −0.169, −0.401, −0.785, −0.699, −0.504 |
| MP4 | `USGOOD` employment, goods (log) | `GPDICTPI`, `PNFIC96_Q`, `LNS13023705` | 0.336 | 0.153 | 0.313, −0.242, −1.078, −1.080, −0.936 |
| MP5 | `TB3MS` 3-month T-bill | `CPIAUCSL`, `LNS13023621`, `USFIRE` | 0.415 | 0.220 | 0.417, 0.354, 0.016, −0.066, −0.041 |
| MP6 | `PCED_MV` PCE price, motor vehicles (Δlog) | `IPFINAL`, `MZMSL`, `URATE_ST` | 0.398 | 0.229 | 0.086, 0.056, 0.044, 0.033, 0.003 |
| MP7 | `USLAH` employment, leisure and hospitality (log) | `UNLPNBS`, `PRFIC96_Q`, `PCECTPI` | 0.401 | 0.228 | 0.138, −0.101, −0.355, −0.357, −0.373 |

**Chosen subset (D13).** Fiscal: G2 (highest fraction of long-lag
coefficients, oscillating response: the case the rule expects a VAR(4) to get
most wrong) and G3 (lowest fraction, hump-shaped: the case it expects to get
least wrong). Monetary, by the same rule: MP2, capacity utilization (frac
0.480), and MP3, business-services employment (frac 0.114).

**Benchmark (`tbl-l07-port-benchmark`).** MATLAB R2024a, 500 draws per design,
$T=200$, $p=4$, observed shock with unit standard deviation. Bias and sd are
divided by the design's $\bar\theta$ (§6.9, printed beside its name), so 0.100
is a tenth of the response's root-mean-square size; $\theta_h$ is in units of
the response series as LPW transform it. BC VAR is the MATLAB Pope-corrected
VAR, reported and not ported (D13). $\omega^{*}_h$ compares least-squares LP
with least-squares VAR (§6.5); "VAR dom." and "LP dom." mark horizons where one
estimator has both the lower bias and the lower variance. All 21 horizons are
in the CSVs (`brief_fill/port_table.py` prints them). Monte Carlo standard
errors of the relative bias at $h=8$, LP and VAR: G2 0.074 and 0.050, G3 0.077
and 0.060, MP2 0.020 and 0.016, MP3 0.028 and 0.024.

| Design ($\bar\theta$) | $h$ | $\theta_h$ | LP bias | LP sd | BC LP bias | BC LP sd | VAR bias | VAR sd | BC VAR bias | BC VAR sd | $\omega^{*}_h$ |
|---|---|---|---|---|---|---|---|---|---|---|---|
| G2 housing starts (1.171) | 0 | −3.152 | −0.012 | 0.580 | −0.012 | 0.580 | −0.012 | 0.580 | −0.012 | 0.580 | — |
|  | 4 | 2.133 | −0.035 | 1.338 | −0.056 | 1.402 | −0.034 | 1.268 | −0.048 | 1.318 | VAR dom. |
|  | 8 | 0.682 | −0.390 | 1.652 | −0.288 | 1.782 | −0.077 | 1.108 | 0.020 | 1.226 | VAR dom. |
|  | 12 | −0.309 | −0.411 | 1.682 | −0.371 | 1.870 | 0.306 | 0.977 | 0.387 | 1.138 | VAR dom. |
|  | 16 | 0.033 | −0.357 | 1.768 | −0.378 | 1.992 | 0.005 | 0.903 | 0.057 | 1.100 | VAR dom. |
|  | 20 | 0.528 | −0.465 | 1.902 | −0.483 | 2.178 | −0.342 | 0.835 | −0.309 | 1.076 | VAR dom. |
| G3 IP, business equipment (0.426) | 0 | −0.204 | 0.003 | 0.360 | 0.003 | 0.360 | 0.003 | 0.360 | 0.003 | 0.360 | — |
|  | 4 | −0.291 | 0.211 | 1.350 | 0.070 | 1.419 | 0.134 | 1.318 | 0.064 | 1.363 | VAR dom. |
|  | 8 | 0.596 | 0.101 | 1.724 | 0.064 | 1.900 | −0.592 | 1.338 | −0.611 | 1.477 | 0.777 |
|  | 12 | 0.439 | −0.068 | 1.858 | 0.056 | 2.108 | −0.269 | 1.162 | −0.205 | 1.338 | 0.969 |
|  | 16 | 0.144 | −0.175 | 2.015 | −0.026 | 2.340 | 0.206 | 1.053 | 0.312 | 1.249 | 0.996 |
|  | 20 | 0.121 | −0.064 | 2.041 | 0.076 | 2.461 | 0.130 | 0.987 | 0.249 | 1.212 | 0.996 |
| MP2 capacity utilization (0.588) | 0 | 0.424 | 0.011 | 0.174 | 0.011 | 0.174 | 0.011 | 0.174 | 0.011 | 0.174 | — |
|  | 4 | −0.431 | 0.039 | 0.421 | 0.085 | 0.442 | 0.092 | 0.399 | 0.123 | 0.416 | 0.723 |
|  | 8 | −0.867 | 0.296 | 0.458 | 0.218 | 0.496 | 0.649 | 0.357 | 0.602 | 0.389 | 0.198 |
|  | 12 | −0.599 | 0.409 | 0.505 | 0.251 | 0.558 | 0.469 | 0.332 | 0.386 | 0.375 | 0.733 |
|  | 16 | −0.460 | 0.492 | 0.568 | 0.323 | 0.641 | 0.431 | 0.315 | 0.324 | 0.371 | VAR dom. |
|  | 20 | −0.514 | 0.520 | 0.559 | 0.339 | 0.656 | 0.624 | 0.289 | 0.508 | 0.363 | 0.657 |
| MP3 employment, business services (0.573) | 0 | −0.169 | −0.005 | 0.122 | −0.005 | 0.122 | −0.005 | 0.122 | −0.005 | 0.122 | — |
|  | 4 | −0.401 | 0.094 | 0.410 | 0.057 | 0.434 | 0.097 | 0.413 | 0.071 | 0.430 | LP dom. |
|  | 8 | −0.785 | 0.322 | 0.626 | 0.195 | 0.690 | 0.518 | 0.538 | 0.430 | 0.590 | 0.382 |
|  | 12 | −0.699 | 0.488 | 0.777 | 0.280 | 0.891 | 0.445 | 0.573 | 0.307 | 0.654 | VAR dom. |
|  | 16 | −0.532 | 0.552 | 0.845 | 0.324 | 1.008 | 0.280 | 0.578 | 0.114 | 0.680 | VAR dom. |
|  | 20 | −0.504 | 0.580 | 0.910 | 0.354 | 1.122 | 0.319 | 0.579 | 0.140 | 0.696 | VAR dom. |

Averages over $h=0,\dots,20$ of relative $\lvert\mathrm{Bias}\rvert$ / sd / RMSE:

| Design | LP | BC LP | VAR | BC VAR |
|---|---|---|---|---|
| G2 | 0.298 / 1.532 / 1.562 | 0.268 / 1.681 / 1.703 | 0.151 / 0.992 / 1.009 | 0.156 / 1.122 / 1.138 |
| G3 | 0.120 / 1.621 / 1.626 | 0.053 / 1.828 / 1.828 | 0.233 / 1.104 / 1.138 | 0.261 / 1.237 / 1.273 |
| MP2 | 0.299 / 0.466 / 0.569 | 0.211 / 0.513 / 0.557 | 0.393 / 0.327 / 0.537 | 0.341 / 0.364 / 0.515 |
| MP3 | 0.344 / 0.635 / 0.728 | 0.203 / 0.729 / 0.758 | 0.299 / 0.488 / 0.582 | 0.198 / 0.550 / 0.595 |

*Reading.* (i) The variance half of the toy's profile survives in every
design: the VAR's sd is below the LP's at every $h\ge1$ in G2, G3, and MP2 and
at every $h\ge5$ in MP3, and the LP-to-VAR ratio reaches 2.28, 2.07, 1.93, and
1.57 at $h=20$. (ii) The bias half does not: bias-corrected LP is less biased
than the VAR at every $h=8,\dots,20$ in G3 and MP2, at $h=8,\dots,14$ in MP3,
and at no $h\ge8$ in G2, where the VAR dominates at every horizon shown.
(iii) The selection rule ranked the monetary pair as intended (horizon-averaged
VAR $\lvert\mathrm{Bias}\rvert$ 0.393 in MP2, 0.299 in MP3) and the fiscal pair
in reverse (0.151 in G2, 0.233 in G3). (iv) Averaged over $h=0,\dots,20$, the
loss $L_\omega/\bar\theta^2$ is lowest for the least-squares VAR at
$\omega=0.5$ in G2, G3, and MP3 and for the Pope-corrected VAR in MP2;
bias-corrected LP becomes lowest at $\omega=0.9$ in MP2 and at $\omega=0.99$ in
G3, equals the corrected VAR to three decimals at $\omega=0.99$ in MP3 (0.062),
and is never lowest in G2. Scripts: `brief_fill/port_table.py` and
`brief_fill/gen_benchmark_md.py` in the scratch directory.

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

Full validation on the shipped draws (500 draws × 21 horizons × LP, BC LP,
VAR per design; StataNow 19.5 SE, batch, the four designs run concurrently on
the same machine). Inputs: `port_hp/export_hp.m` rewrites the exported draws
and the MATLAB estimates from the saved `scratch_{G,MP}_1.mat` at `%.17g`
without re-simulating (21.9 s), and `port_hp/lpw_port_validate_hp.do` reads
them with `import delimited, asdouble`; logs `port_hp/<design>/run_<design>.log`:

| Design | Port time | Max abs difference | Above $10^{-6}$ | Draw 1 max |
|---|---|---|---|---|
| G2 | 98.9 s | $5.8\times10^{-13}$ | 0 of 31,500 | $2.4\times10^{-13}$ |
| G3 | 99.0 s | $4.1\times10^{-12}$ | 0 of 31,500 | $6.0\times10^{-13}$ |
| MP2 | 99.0 s | $5.9\times10^{-13}$ | 0 of 31,500 | $1.3\times10^{-13}$ |
| MP3 | 99.2 s | $1.7\times10^{-12}$ | 0 of 31,500 | $2.6\times10^{-13}$ |

D13's $10^{-6}$ holds on all 126,000 comparisons. A first pass used the
8-decimal estimates and 10-decimal draws read with Stata's default storage
(`import delimited` stores them as `float`, about seven significant digits).
It had 1,020 comparisons above $10^{-6}$, the largest $3.5\times10^{-6}$ in
G2 where the estimate is near $-2.9$ (`port_full/`). The smoke run above used
the same files and import. Every shipped draw file and benchmark CSV is
therefore written at `%.17g`, and every do-file imports it with `asdouble`.
Timing, same machine: the smoke validation took 0.81 s for 4 draws
(`time_port.log`, StataNow 19.5); importing each design's MATLAB estimates
takes under 1 s; the first 200 draws of G2 take 36.1 s (`port_full/g2_r200/`).

**Tolerance.** Draw-by-draw agreement of LP, BC LP, and VAR with the
shipped MATLAB estimates: $10^{-6}$ absolute (D13), asserted by the
instructor build on all 500 draws of each design (largest observed difference
$4.1\times10^{-12}$). Bias, sd, and RMSE across the student's $R=200$ draws
(`global R`, 500 optional; D2) against the shipped MATLAB summary: within three
Monte Carlo standard errors (sd$/\sqrt R$ for the bias; sd$/\sqrt{2R}$ for the
sd) at every horizon — an assertion the do-file makes. Qualitative checks, per
design rather than universal: VAR sd $<$ LP sd at every $h\ge5$ in all four
designs; BC LP $\lvert\mathrm{Bias}\rvert<$ VAR $\lvert\mathrm{Bias}\rvert$ at
every $h=8,\dots,20$ in G3 and MP2 only (§8.1, *Reading*).

**Deliberate departures from the original.** (i) 500 draws instead of 5,000 (students re-estimate the first $R=200$ by
default, D2);
(ii) four DGPs instead of 6,000, so no median across DGPs is computed and
none is claimed; (iii) only the four least-squares and bias-corrected
estimators, not BVAR, penalized LP, VAR averaging, or SVAR-IV; (iv) per D13 the Pope
correction of the VAR is reported from the MATLAB benchmark but not ported
(Mata port of `VAR_CorrectBias.m`, which needs complex eigenvalues and
Kilian's stationarity adjustment, is an instructor extension); (v) the DFM is
estimated once and its parameters cached, exactly as `run_dfm.m` would
re-estimate them (the estimation is deterministic).

**Runtime.** MATLAB: DFM estimation 1,399 s once; Monte Carlo 0.83 s (MP run)
to 1.24 s (G run, draws 51–500) per draw for seven DGPs and four estimators
(the smoke run took 6.9 s for 4 draws). Stata, student side, per design:
36 s at the default $R=200$ and 90–104 s at 500 (tables above).

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
   for `mc = 1` to $10^{-6}$ (D13; on the `%.17g` exports read with
   `asdouble`, draw 1's largest difference is $6.0\times10^{-13}$ across G2,
   G3, MP2, and MP3, so the assertion passes on every design).
2. *Calculate bias, variance, and MSE separately.* `sta07_2_montecarlo.do`:
   loop over `mc = 1..R` (`global R`, default 200, 500 optional; D2) with `postfile`;
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
   interpretation record: for each of the four designs (G2, G3, MP2, MP3), which estimator has
   the lower MSE at $h=8$, which has the better-covering band at $h=8$, and
   what $\omega^{*}_8$ is; one paragraph on why the toy's $\kappa$ and the
   designs' fraction of long-lag coefficients are the same idea, and why the
   fraction nonetheless ranked the fiscal pair's VAR bias in reverse (§8.1).

Starter do-file structure (`lab-project/`): `master.do` (sets paths, runs the
four task files, writes `log/master.log`); `tests/test_port.do` (task 1
assertions); `tests/test_mc.do` (task 2 assertions); `data/` with provenance
README; `output/` for CSVs and figures. Expected outputs: `estimates_mc1.csv`,
`mc_summary_student.csv`, `lags_sample.csv`, `coverage_sta07.csv`, and four
figures (`fig_profiles_g2.pdf` etc.). Runtime at the student default $R=200$
(D2), StataNow 19.5 on this machine: the port on one design takes 36 s;
the toy Monte Carlo with bands for LP(1), LP(2), VAR(1), and VAR(2) takes
43 s (`toy_r200/`). No command may exceed 10 minutes, so `master.do` runs
each task file as its own command and task 3 runs one command per design and
per $T$.

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

- `lpw_draws_{g2,g3,mp2,mp3}.dta` and `lpw_benchmark_*.csv` (shipped, D5 and D13): simulated by the
  course from LPW's calibrated DFM using the authors' MIT-licensed code; the
  files are simulation output, not the Stock–Watson data, and are shipped
  with `data/LICENSE-lp_var_simul.txt` (the upstream MIT copyright and
  permission notice) and `SOURCE.md`, together with the commit hash, the
  `spec_id`, the seed rule, and the MATLAB version. They are built from the
  `%.17g` export with `import delimited, asdouble`, so every variable is
  stored as double (§8.1).
  The DFM parameter caches (`scratch_G_1.mat`, `scratch_MP_1.mat`) are instructor material.
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
   $\theta^{\mathrm{VAR}}_h=\boldsymbol\iota_2'\mathbf A_1^h\mathbf g$ for $h=0,\dots,4$.
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
13. **The bounded port.** `fig-l07-lpw-profiles`: the VAR's lower sd survives
    in all four designs; the bias ranking does not.
14. **Lab, exercises, and the question for Lecture 8.** Smoothness as a
    restriction.

---

## 10. Open questions for the editor

1. Resolved: D29 — the opening and closing comparison stays on the Jordà–Taylor monetary–unemployment data (`data_fred.dta`); the shelter alternative is dropped.
2. Resolved: D13, D5 — Option A: the 500 MATLAB draws of G2, G3, MP2, and MP3 ship as `lpw_draws_{g2,g3,mp2,mp3}.dta` with the MIT code (§8.4); Option B is dropped.
3. Resolved: D13 — the monetary pair, by the fiscal rule, is MP2 (capacity utilization, frac 0.480) and MP3 (business-services employment, frac 0.114); named in §1, §7 Lab 5, §8.1–§8.2, and §8.4.
4. Resolved: D20 — $\mathbf S$, $\mathbf A_{\mathrm c}$, $\tau$, $\kappa$, $\omega^{*}_h$, and $R$ adopted; so that ledger symbols keep one meaning, the toy's $c$ is now $\psi$, $\gamma_0$ is $\sigma_y^2$, the selection vector is $\boldsymbol\iota_j$, and the coverage formula uses $d_h$ for $b/\sigma$ (§1, §2, §4–§7, §9).
5. Resolved: D13 — the Pope correction is reported from the MATLAB benchmark and not ported (§8.1 departures, `fig-l07-lpw-profiles`, Lab 5).
6. Resolved: D30 — Lab 4 keeps a live VAR band under an "Approximation" panel label, computed with a numerical-gradient delta method over all of $\hat{\mathbf A}_1$ and $\hat g_2$ with a collapsed note stating the independence assumption; if that is not built, the panel shows the stored `irf create` coverage labeled "stored result" (§7).
7. Resolved: D31 — reading guides cite sections of the versions frozen in `VERIFIED.md` (R08; R09 is article 105722, no page range) with "section numbers from the frozen version; page range to confirm"; the LPW section numbers in §4 and exercise 9 came from the January 2024 working paper and are checked against the frozen article when the guide is written.
8. Resolved: D2, D26 — students run $R=200$ through `global R` (500 optional) and instructor builds 500, labeled statistical reproductions; changed in the §2 ledger, exercises 4 and 10, Lab 3's default, §8.1 tolerance and departures, and §8.2's runtime sentence.
9. Resolved: D22 — `companion-form`, `bias-weight`, and `encompassing-model` are approved (§1, §3).
10. Resolved: D13 — with the draws and MATLAB estimates re-exported at full double precision (`%.17g`) and read with `import delimited, asdouble`, the port agrees within $4.1\times10^{-12}$ on all 126,000 comparisons; the earlier gaps (largest $3.5\times10^{-6}$) came from 8- and 10-decimal CSVs stored as Stata `float`. The $10^{-6}$ tolerance stands and the $10^{-5}$ proposal is withdrawn (§1, §4, §8.1, §8.2 Task 1, §8.4).
11. **Opening specification.** D29 fixes the dataset, not the specification. This lecture's comparison uses 1969m3–2008m12, $p=12$, and the shock as an observed regressor ordered first; L6 and L8 use Jordà–Taylor's 1985m1–2000m1 LP-IV with six lags. The §1 paragraph *Relation to Lectures 6 and 8* and the `fig-l07-two-answers` caption now list the differences and state that the magnitudes are not comparable. Keep this specification, which the recursive VAR needs, or rerun the comparison on L8's sample and lag length?
12. Resolved: D2 — the baseline toy was rerun at $R=500$ with seed 7 (112 s, StataNow 19.5; `toy_r500/`; replications 1–500 are identical to those of the earlier $R=1{,}000$ run), `toy_summary_base.csv` was replaced, and the numbers drawn from it were updated in §1, §4, §5, §6.4–§6.6, and §7 Labs 3–4.
13. **L8 seam.** The L8 brief already takes this lecture's handoff: its §1 student "knows that estimators targeting the same response can trade bias for variance (L7)", it leaves LPW's penalized LP to L7, and it writes L7's keys as prose. Confirm that `#sec-l07-handoff` hands directly to `#sec-l08-free-parameters`.
