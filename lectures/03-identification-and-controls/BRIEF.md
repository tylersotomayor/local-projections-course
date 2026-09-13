# Lecture 03 brief — Identification, controls, and the pre-shock information set

Planning brief, September 13, 2026. Governing decisions: D1, D2, D5, D7, D8 (also D20, D24, D30, D31). Every number below comes from one of five sources, named where used: the benchmark `replication-packages/benchmarks/REP03-shelter-prices-author-20240813.csv` (Stata/SE 18.5); the course rerun `design-03/d7/l03_d7_checks.do` (StataNow/SE 19.5, 71 s, no `r(#);` lines, output `l03_results.csv`); the sandbox check `design-03/sandbox/l03_sandbox.py` (8.1 s, output `l03_sandbox.out`); the sandbox addenda `design-03/sandbox/l03_sandbox_addenda.py` (noisy proxy and the $n=10^7$ confounder rerun, 3.0 s, output `l03_sandbox_addenda.out`); or a derivation in Section 6. Scratch root: `/private/tmp/claude-501/-Users-tylersotomayor-macro-local-projections/c072337f-0f2c-4cf4-bb71-22a0631666a1/scratchpad/design-03/`. Earlier scratch runs in `orig/`, `shipped/`, `timed/`, `fast/` and `rep03_scratch.do` used the November 2024 `Figure4.do` (MD5 `7a4952…`, not the frozen `e9dc38…`) or added housing starts and completions to the pointwise controls. They are not D7 and none of their numbers is used.

## 1. Session brief

**Opening situation.**
An FOMC statement is tighter than markets expected. Shelter prices, "rents that tenants face and owners de facto pay themselves" (IJK, shelter application; §6.2 of arXiv v2), are set in leases and move slowly. Does a monetary surprise lower shelter prices, and when? Take two regressions on the same monthly data (1988m1–2019m12), the same controls (12 lags of monthly shelter inflation, the federal funds rate, and the unemployment rate), and the same rows. The dependent variable is the 48-month long difference of 100 × log shelter PCE prices. On the Bauer–Swanson surprise the coefficient is −3.62 percent per unit of surprise; on the monthly change in the funds rate it is +0.78 percent per percentage point (both $T_{48}=323$). The pre-shock information in the controls explains half the variance of the funds-rate change ($R^2=0.505$, robust (HC1) $F(36,334)=9.29$) and nothing detectable in the surprise ($R^2=0.089$, robust (HC1) $F(36,334)=0.99$, $p=0.48$). Both come from `regress …, robust`; the classical $F$ statistics implied by the same $R^2$ values would be 9.47 and 0.91. The two regressions look identical. Only one can carry a causal reading, and the lecture is about why.

**Decision or empirical question.**
Given a candidate $s_t$ and candidate controls $\mathbf w_t$, when does $\beta_h=\theta_h$? Which choices bear on that equality: which variable is $s_t$, which controls and dated when, which months count as zero, which rows are kept? Which choices change only precision or the sample? And how should the argument be written so that someone else can audit it? The answer has three parts. Three assumptions place $s_t$ relative to the pre-shock information set, to contemporaneous shocks, and to the arrival of news (A1–A3). Each failure leaves a signature: an omitted-variable bias formula, predictability of $s_t$, or a change of estimand. A specification record makes the argument auditable.

**Target student and prerequisites.**
The student has finished Lecture 1 (the horizon-$h$ regression, $\beta_h$ versus $\theta_h$, the counterfactual) and Lecture 2 (long differences, the same-regressor equivalence, common versus horizon-specific samples, units). Also assumed: OLS omitted-variable algebra and the population linear projection. Stata: `tsset`, time-series operators, `forvalues`, `regress`, `newey`, `predict, residuals`, `postfile`. Not assumed: instruments (L4) and HAC theory (L5). `newey` appears only to reproduce the author's standard-error column, and its meaning is deferred (D8).

**Learning outcomes.**

1. Classify a right-hand variable as a policy action, a policy surprise, a structural shock, or a proxy. State A1–A3, under which $\beta_h=\theta_h$, and for each name the step it licenses and the diagnostic that can embarrass it.
2. Derive, and compute in the sandbox economy, three results: the omitted-variable bias of $\beta_h$ from a pre-shock confounder, the mistiming and attenuation caused by anticipation, and the change of estimand caused by a post-treatment control. Predict each sign before simulating.
3. Decide whether a candidate control belongs to $\Omega_{t-1}$. Separate controls that serve identification from those that mainly change precision or the sample. Verify a coefficient by Frisch–Waugh–Lovell partialling out.
4. Audit the timing, the zero-versus-missing coding, and the row construction of a shock series, and write a specification record that another researcher can execute.
5. Reproduce the D7 shelter point estimates and sample sizes at all 49 horizons within $10^{-6}$ (D8), and write an identification memo that names the assumptions and the principal threats. "I included controls" is not an argument.

**Anchor example.**

*Data: the D7 shelter anchor.* Inoue, Jordà, and Kuersteiner, official author archive of August 13, 2024 (commit `340947c`, CC0), `original/Replication Code/Figure4.do` lines 14–19, 32–43, 55–80, run unmodified.

| Item | Value (source: `l03_d7_checks.log` unless noted) |
|---|---|
| File | `sigband_shelterinf.dta`: 615 monthly rows, 1969m1–2020m3, internal timestamp 7 Aug 2024, MD5 `83c6d69d…` (identical to the scratch copies) |
| Outcome | $y_t=100\times$`lpcepi_house`, where `lpcepi_house` is the log of `pcepi_house`, the PCE housing price index (SA, 2017=100), stored as float (max abs deviation from `log(pcepi_house)` $2.4\times10^{-7}$) |
| Dependent variable | $y_{t+h}-y_{t-1}$: cumulative percent change in shelter prices from the month before the shock through month $h$ (D7) |
| Intervention | $s_t=$ `BSmonshock` (variable label "(sum) BSmonshock": announcement surprises summed within the month), nonmissing 1988m1–2019m12 (384 months); 118 months exactly zero; mean 0, s.d. 0.047262, range $[-0.2488,\,0.1820]$; units as shipped (Section 10, Q1) |
| Controls $\mathbf w_t$ | 12 lags each of $\Delta y_t$ (monthly shelter inflation), `stir` (effective federal funds rate, percent), `urate` (unemployment rate, percent); $p=12$ |
| Row construction | Line 19 `drop if mon_shock == .` keeps 1988m1–2019m12 only; the first usable row is 1989m2 (13 months of history needed), the last is 2019m12 $-\,h$; $T_h=371-h$, from 371 to 323 |
| Estimator | `newey …, lag(48)` at $h=0,\dots,48$; the coefficient is OLS |
| Point estimates (percent per unit $s$), benchmark CSV | $h=0$: −0.066480; 6: 0.158614; 12: −0.225245; 24: −1.502051; 36: −2.678696; 48: −3.617904. Positive at $h=1,\dots,8$, negative at the other 41 horizons |
| Per one-s.d. surprise | $\times0.047262$: −0.0031 at $h=0$, −0.0710 at $h=24$, −0.1710 at $h=48$ percent |
| Rerun agreement (D1) | StataNow 19.5 versus 18.5 benchmark: max abs coefficient difference $1.63\times10^{-7}$, max abs s.e. difference $9.3\times10^{-8}$, $T_h$ identical at all 49 horizons |

*Simulation: the sandbox economy.* Monthly flavor, all innovations i.i.d. $N(0,1)$, $\rho=0.8$, $\theta_0=1$. Classroom samples: $T=384$ after a burn-in of 50. Monte Carlo: $R=200$ (D2), NumPy `default_rng(3)`. Closed forms were checked at $n=2{,}000{,}000$ with `default_rng(20260913)`. Defaults: $\psi_s=1$, $\psi_y=0.5$ (confounder); $\zeta=0.5$ (anticipation); $\nu_s=0.5$, $\nu_y=0.6$, $\nu_v\in\{0,0.5\}$ (same-month variable). Browser and Stata do not share a generator (blueprint §5.4), so the handoff ships the lab's simulated rows as a CSV.

**Smallest useful model** (ledger notation; new local symbols in Section 2).
$$
y_t=\rho\,y_{t-1}+\theta_0 s_t+\psi_y x_{t-1}+\nu_y q_t+\zeta\,\varepsilon_{t+1}+v_t,\qquad
s_t=\varepsilon_t+\psi_s x_{t-1},\qquad
q_t=\nu_s s_t+\nu_v v_t+\xi_t .
$$
Switching all three mechanisms off gives Lecture 1's AR(1) economy, where $\beta_h=\theta_h=\theta_0\rho^h$. Each switch breaks exactly one assumption:

| Mechanism | Causal response to a unit $\varepsilon_t$ | LP coefficient as usually run | Verified ($n=2\times10^6$), $h=0$ |
|---|---|---|---|
| Confounder $x_{t-1}$ omitted (A1) | $\theta_0\rho^h$ | $\rho^h\{\theta_0+\psi_y\psi_s/(1+\psi_s^2)\}$ | 1.25 vs 1.2495; with $x_{t-1}$ controlled 0.9992 |
| Anticipation $\zeta$ (A3) | $\rho^h(\theta_0+\zeta\rho)$, plus $\zeta$ at $h=-1$ | with $y_{t-1}$: $\theta_0\rho^h$; long difference without controls: $\rho^h(\theta_0+\zeta\rho)-\zeta$ | 1.0 vs 0.9996; 0.9 vs 0.8994 |
| Same-month $q_t$ controlled, $s$ ordered first | total $\rho^h(\theta_0+\nu_s\nu_y)$; direct $\theta_0\rho^h$ | $\rho^h\{\theta_0-\nu_s\nu_v/(1+\nu_v^2)\}$ | $\nu_v=0$: 1.0 vs 0.9995; $\nu_v=0.5$: 0.8 vs 0.7994 |
| Same-month $q_t$ omitted, $q$ ordered first ($s_t=\varepsilon_t+\nu_s q_t$, $q_t=\xi_t$) (A2) | $\theta_0\rho^h$ | $\rho^h\{\theta_0+\nu_y\nu_s/(1+\nu_s^2)\}$ | 1.24 vs 1.2396; with $q_t$ 0.9998 |

**Dependency chain of sections.**

1. `#sec-l03-four-variables` *Four right-hand variables.* A policy action, a policy surprise, a structural shock, and a noisy proxy are all candidates for $s_t$, but they stand in different relations to $\varepsilon_t$. The shelter data show the difference: the funds-rate change is half-predictable from last year's data, and the surprise is not. A proxy fails differently: even pure measurement noise scales every $\beta_h$ toward zero by the same factor (§6.8).
2. `#sec-l03-assumptions` *What $\beta_h=\theta_h$ requires.* The ledger's $u_{t,h}$ is orthogonal to $\tilde s_t$ by construction, so the condition is stated for the structural composite error $u^\ast_{t,h}=y_{t+h}-\theta_hs_t-\mu^\ast_h-\boldsymbol\gamma^{\ast\prime}_h\mathbf w_t$ (the other shocks, the omitted pre-shock variables, and future shocks). Equality needs $\operatorname{Cov}(\tilde s_t,u^\ast_{t,h})=0$ for $s_t$ residualized on $\mathbf w_t$, and $u^\ast_{t,h}=u_{t,h}$ exactly when it holds. That condition splits into A1 (no omitted pre-shock predictor that also moves $y$), A2 (no correlation with other shocks dated $t$), and A3 (no correlation with shocks or news dated after $t-1$ that reached agents before $t$).
3. `#sec-l03-confounding` *Confounding.* A pre-shock variable that moves both $s_t$ and $y_{t+h}$ biases $\beta_h$ by $\rho^h\psi_y\operatorname{Cov}(x_{t-1},s_t)/\operatorname{Var}(s_t)$. The bias vanishes when either channel is off and disappears when $x_{t-1}$ joins $\mathbf w_t$.
4. `#sec-l03-anticipation` *Anticipation.* If news reaches agents before the recorded date, $y_{t-1}$ has already moved. A control dated $t-1$ then absorbs part of the effect, and a long difference from $t-1$ measures from the wrong base. Regressing $s_t$ on $\Omega_{t-1}$ is the diagnostic, and "predetermined" must mean dated before the news.
5. `#sec-l03-controls` *Predetermined and post-treatment controls.* A control dated $t$ that responds to $s_t$ turns the total effect into a direct effect, or into neither when it shares a shock with $y$. The one exception is recursive identification: a same-month variable ordered before $s_t$ must be included, and the ordering is itself the assumption.
6. `#sec-l03-partialling-out` *Partialling out.* By Frisch–Waugh–Lovell, $\hat\beta_h$ equals the slope of residualized $y_{t+h}-y_{t-1}$ on residualized $s_t$ in the same rows. The theorem is a verification tool. One sentence reads `Figure4.do` lines 99–108 with it: the authors' "joint" coefficient partials out a different control set (adding housing starts) on different rows, so it is not the plotted path (discrepancy-log row 4). Lecture 6 reproduces and explains that coefficient as its anchor B1.
7. `#sec-l03-zeros-missing` *Frequency, zeros, and missing values.* In the surprise series, zero means "no announcement this month" (four such months in every year from 2002). Missing means "not measured". Coding the 1969–1987 months as zero changes the $h=48$ estimate from −3.62 to −0.16. Dropping the zero months destroys every 12-lag window. A one-month misdating flips the sign at $h=0$.
8. `#sec-l03-specification-record` *The specification record.* Shock, outcome and transformation, controls with dates, sample and row rule, horizon, normalization, and source lines are written down once, so that each identification claim points at an entry.
9. `#sec-l03-shelter` *The shelter anchor.* Reproduce D7's 49 coefficients and $T_h$, audit the timing and rows, show that the surprise passes the predictability test that the funds-rate change fails, and read the specification variants (Section 4) as evidence about precision as well as identification. The section closes with one illustration: the surprise is unpredictable but moves the funds-rate change only weakly (first link $b=0.346$, HC1 s.e. 0.314, $R^2=0.0086$, $N=383$, no controls).
10. `#sec-l03-handoff` *When the shock is not the regressor.* A noisy proxy recovers the shape of the response but not its scale (§6.8), and a policy action is predictable. The handoff is the spine's question: how can a variable that is correlated with the shock but not the shock itself identify a response?

**Central notation.** From the ledger: $t,T,h,H,y_t,s_t,\mathbf w_t,w_{j,t},p,\beta_h,\hat\beta_h,\theta_h,\mu_h,\boldsymbol\gamma_h,u_{t,h},\mathcal T_h,T_h$, $\varepsilon_t,\boldsymbol\varepsilon_t,\Omega_{t-1}$, $\rho$, $R$, $\sigma_s$. New local symbols: $x_t$, $q_t$, $v_t$, $\xi_t$, $\theta_0$, $\psi_s,\psi_y,\zeta,\nu_s,\nu_y,\nu_v$, and $\tilde s_t,\tilde y_{t,h}$ (residuals after partialling out $\mathbf w_t$); $u^\ast_{t,h}$ with $\mu^\ast_h,\boldsymbol\gamma^\ast_h$ (structural composite error and the projection coefficients of $y_{t+h}-\theta_hs_t$ on $(1,\mathbf w_t)$, §6.1); $\varsigma_t$, $\sigma_\varepsilon$, $\sigma_\varsigma$ (proxy measurement noise and the two standard deviations, §6.8). All are chosen to avoid ledger symbols: $m$ is the bandwidth, $\tau,\kappa$ belong to L7, $\lambda$ and $\delta_k$ to L8, $\chi$ to $\chi^2$, $\eta_i$ to L11 (hence $\varsigma_t$ for the noise), and $\upsilon$ would be hard to tell from $v_t$ (hence $u^\ast_{t,h}$).

**Glossary terms** (L03-owned keys only; all twenty used).

- `identification` — The argument that a population regression coefficient equals a causal object; it concerns the population and is settled by assumptions, not by sample size.
- `identifying-assumption` — A restriction that cannot be tested in full and that licenses reading $\beta_h$ as $\theta_h$; A1–A3 in this lecture.
- `structural-shock` — The primitive, mutually uncorrelated, unpredictable disturbance $\varepsilon_t$ whose effect $\theta_h$ traces; latent by construction.
- `policy-action` — The instrument setting a policymaker chooses (the funds-rate change); partly a reaction to $\Omega_{t-1}$ and therefore not a shock.
- `policy-surprise` — The part of an announced action that markets did not expect, measured in a narrow window around the announcement; a candidate $s_t$ whose timing is its main virtue.
- `proxy` — An observed series equal to $\varepsilon_t$ plus measurement error or contamination. Used as $s_t$, even pure noise $\varsigma_t$ is correlated with $u^\ast_{t,h}$, which contains $-\theta_h\varsigma_t$. It therefore attenuates every $\beta_h$ by $\sigma_\varepsilon^2/(\sigma_\varepsilon^2+\sigma_\varsigma^2)$, leaving the shape $\beta_h/\beta_0$ but not the scale identified.
- `confounder` — A variable that moves both $s_t$ and $y_{t+h}$; omitted, it biases $\beta_h$; if it is pre-shock, controlling for it removes the bias.
- `omitted-variable-bias` — The gap $\beta_h-\theta_h$ equal to the omitted variable's effect on $y_{t+h}$ times its projection coefficient on $s_t$.
- `anticipation` — Agents acting on news about $s_t$ before its recorded date, so that pre-dated outcomes and controls already contain the effect.
- `predetermined-control` — A control dated before the arrival of news about $s_t$, so that it cannot respond to it; "dated $t-1$" is necessary, not sufficient.
- `post-treatment-control` — A control that can respond to $s_t$; including it changes the estimand or biases it.
- `mediator` — A variable through which $s_t$ affects $y_{t+h}$; controlling for it removes that channel from $\beta_h$.
- `partialling-out` — Removing the projection on $\mathbf w_t$ from both the outcome and $s_t$ before regressing one residual on the other.
- `frisch-waugh-lovell` — The theorem that the partialled-out slope equals the multiple-regression coefficient when both residuals are taken in the same rows.
- `recursive-identification` — Identification by an assumed within-period ordering in which variables ordered before $s_t$ enter $\mathbf w_t$ contemporaneously; the ordering is the assumption.
- `information-set` — $\Omega_{t-1}$, everything agents and the policymaker know just before the intervention; the set $\mathbf w_t$ is meant to span.
- `predictability-test` — A regression of $s_t$ on elements of $\Omega_{t-1}$; rejection falsifies A1 for those elements, and non-rejection is evidence only against the elements tried.
- `specification-record` — The written list of shock, outcome, transformation, controls with dates, sample and row rule, horizons, normalization, and source lines that fixes what was estimated.
- `conditional-exogeneity` — $\operatorname{Cov}(\tilde s_t,u^\ast_{t,h})=0$ after partialling out $\mathbf w_t$, where $u^\ast_{t,h}$ is the structural composite error left after removing $\theta_hs_t$ and the projection on $(1,\mathbf w_t)$. It is the single condition that A1–A3 jointly deliver, and it holds exactly when $u^\ast_{t,h}$ equals the projection residual $u_{t,h}$.
- `timing-convention` — The rule that dates $s_t$, the outcome window, and the controls relative to one another (here, the shock month $t$, the base month $t-1$, controls $t-1$ to $t-12$).

**Likely explanatory footnotes.** How Bauer and Swanson construct their surprise (high-frequency window, information effect removed) and why the dataset sums it within the month. Eight scheduled FOMC meetings a year, which explains roughly four zero months a year (74 zeros before 2008m12, 28 of 84 months in 2008m12–2015m11). The two official archives and why D7 pins the August one. The IJK Figure 4 note's "January 1998" against the text's and the code's January 1988. Stata's time-series operators returning missing across gaps. Float storage: the author's `gen` makes the dependent variable a float, so exact FWL comparisons need `double`. The same-regressor equivalence (L2) applied to the anticipation result. The "bad control" vocabulary of the applied-micro literature. The within-month ordering in a recursive VAR (link forward to L7).

**Candidate figures** (standalone TikZ/pgfplots with `figures/lpfig.tex` and `build.sh`; "Lua" means a data script that computes or reads a committed CSV).

| Label | Question | Lesson visible | Data or formula |
|---|---|---|---|
| `fig-l03-timeline` | Where do the confounder, the news, and the mediator sit relative to $t-1$, $t$, $t+h$? | A1–A3 are statements about arrows crossing the line at $t$ | Schematic |
| `fig-l03-confounder-bias` | How does the bias depend on the two channels? | $\beta_0-\theta_0=\psi_y\psi_s/(1+\psi_s^2)$: zero if either channel is off, peaks at $\psi_s=1$ | Closed form, $\psi_s\in[0,3]$, $\psi_y\in\{0.25,0.5,1\}$ |
| `fig-l03-anticipation` | What do the two usual regressions report when news arrives a month early? | Truth $1.4\times0.8^h$ with a pre-move of 0.5 at $h=-1$; LP with $y_{t-1}$ gives $0.8^h$; long difference without controls turns negative from $h=5$ | Closed form, $h=-1,\dots,12$ |
| `fig-l03-predictability` | Is each candidate $s_t$ forecastable from $\Omega_{t-1}$? | Two time series with their fitted values from the 36 controls: funds-rate change ($R^2=0.505$) and surprise ($R^2=0.089$) | `l03_d7_checks.do` fitted values (to export); droppable if a table suffices (D24) |
| `fig-l03-shelter-response` | What is the cumulative response of log shelter prices? | Near zero for a year, then steadily negative to −3.62 percent at 48 months per unit (−0.17 per s.d.); $T_h$ falls from 371 to 323 | Benchmark CSV, `pointwise_newey_west` coefficients; no bands (D8) |
| `fig-l03-shelter-variants` | Which specification choices move the path? | Missing-as-zero and the action-as-shock rewrite the estimand; adding lagged housing starts moves $h=48$ by 2.22 with an insignificant predictability $F$ | `l03_results.csv` configurations |

**Exercise capabilities.** Classify $s_t$ candidates; derive an omitted-variable bias; sign anticipation effects; classify controls by date and response; verify FWL numerically; run and read a predictability test; audit zeros, missing values, and dates; write a specification record; reproduce a published curve with assertions; separate identification from precision in a variant table.

**Controlled experiments.** Toggle the confounder with the shocks held fixed. Move the news date. Switch a same-month variable between mediator and recursive confounder. Add or remove a control while holding the rows fixed. Recode zeros and missing values in the real data (stored results, Lab 4).

**Postponed.** Instruments and the first stage (L4); what the Newey–West column means and whether it covers (L5); IJK's significance bands, Bonferroni, the joint Driscoll–Kraay test, and the authors' joint coefficient with housing starts (L6, anchor B1); the recursive VAR's equivalence to the LP (L7); nonlinear effects of large surprises (L10); sensitivity grids (L13).

**Question handed on.** How can a variable that is correlated with the shock but not the shock itself identify a response? (The shelter first link, $b=0.346$ with $R^2=0.0086$, is not handed on; it closes `#sec-l03-shelter` as an illustration.)

## 2. Concept and notation ledger

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $y_t$ | Outcome; in the anchor $100\times$ log shelter PCE price | scalar | month $t$ | log points × 100 | §1 | L5, L6 |
| $y_{t+h}-y_{t-1}$ | Long-difference dependent variable | scalar | base $t-1$, end $t+h$ | percent (cumulative) | §1 | L5, L6, L13 |
| $s_t$ | Intervention: surprise (anchor), funds-rate change (contrast) | scalar | month $t$ | as shipped; percentage points for $\Delta$`stir` | §1 | L4 as instrument, L5, L6 |
| $\varepsilon_t$, $\boldsymbol\varepsilon_t$ | Structural shock of interest; vector of all shocks | scalar; vector | $t$ | unit variance in sandbox | §2 | L4, L7 |
| $\Omega_{t-1}$ | Pre-shock information set | set | before news about $s_t$ | — | §2 | L4, L7, L12 |
| $\mathbf w_t$, $w_{j,t}$ | Controls; anchor: 12 lags of $\Delta y$, `stir`, `urate` | $36\times1$ | $t-1,\dots,t-12$ | mixed | §2 | all |
| $\beta_h$, $\hat\beta_h$ | Projection coefficient on $s_t$; estimate | scalar | horizon $h$ | percent per unit $s$ | §2 | all |
| $\theta_h$ | Causal response to a unit $\varepsilon_t$ | scalar | $h\ge-1$ in the anticipation design | units of $y$ per unit shock | §2 | all |
| $u_{t,h}$ | Horizon-$h$ residual | scalar | contains dates $t,\dots,t+h$ | units of $y$ | §2 | L5 |
| $u^\ast_{t,h}$; $\mu^\ast_h,\boldsymbol\gamma^\ast_h$ | Structural composite error $y_{t+h}-\theta_hs_t-\mu^\ast_h-\boldsymbol\gamma^{\ast\prime}_h\mathbf w_t$; coefficients of the projection of $y_{t+h}-\theta_hs_t$ on $(1,\mathbf w_t)$. Equals $u_{t,h}$ exactly when $\operatorname{Cov}(\tilde s_t,u^\ast_{t,h})=0$ | scalar; scalar and $36\times1$ | dates up to $t+h$ | units of $y$ | §2 (§6.1) | — |
| $\mathcal T_h$, $T_h$ | Rows used at $h$; count | set; integer | anchor $T_h=371-h$ | rows | §7 | L2 (recalled), L5, L6 |
| $\tilde s_t$, $\tilde y_{t,h}$ | Residuals after partialling out $\mathbf w_t$, same rows | scalar | row $t$ of horizon $h$ | as $s$, $y$ | §6 | L5, L6 (scores) |
| $x_t$ | Sandbox confounder, enters as $x_{t-1}$ | scalar | $t-1$ | s.d. 1 | §3 | Lab 1, STA03 |
| $q_t$ | Sandbox same-month variable (mediator or recursively ordered confounder) | scalar | $t$ | s.d. $\ge1$ | §5 | Lab 3 |
| $v_t$, $\xi_t$ | Other shock to $y$; idiosyncratic shock to $q$ | scalar | $t$ | s.d. 1 | §3, §5 | L6, L7 reuse $v_t$ |
| $\varsigma_t$; $\sigma_\varepsilon,\sigma_\varsigma$ | Measurement noise in a proxy $s_t=\varepsilon_t+\varsigma_t$; s.d. of $\varepsilon_t$ and of $\varsigma_t$ | scalar | $t$ | units of $s$ (1 in the sandbox check) | §1 (§6.8) | — |
| $\theta_0$ | Impact effect of $s_t$ on $y_t$ in the sandbox | scalar | $h=0$ | $y$ per $s$ | §3 | labs |
| $\psi_s$, $\psi_y$ | Loadings of $s_t$ and $y_t$ on $x_{t-1}$ | scalars | — | per unit $x$ | §3 | Lab 1 |
| $\zeta$ | Response of $y_{t-1}$ to news about $\varepsilon_t$ | scalar | one month early | $y$ per unit shock | §4 | Lab 2 |
| $\nu_s,\nu_y,\nu_v$ | $q$ on $s$; $y$ on $q$; $q$ on $v$ | scalars | same month | per unit | §5 | Lab 3 |
| $\rho$ | Persistence of the sandbox outcome | scalar | — | — | §3 | L5, L7 |
| $R$ | Monte Carlo replications, 200 (D2) | integer | — | — | §3 | all |
| $\sigma_s$ | s.d. of the surprise, 0.047262 | scalar | 1988m1–2019m12 | as shipped | §9 | L2 (recalled), L6 |

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition | First marked |
|---|---|---|---|---|
| identification | glossary | `identification` | Argument that a population coefficient equals a causal object | §2 |
| identifying assumption | glossary | `identifying-assumption` | Restriction that licenses reading $\beta_h$ as $\theta_h$ and cannot be fully tested | §2 |
| conditional exogeneity | glossary | `conditional-exogeneity` | $\operatorname{Cov}(\tilde s_t,u^\ast_{t,h})=0$ after partialling out $\mathbf w_t$ | §2 |
| structural shock | glossary | `structural-shock` | Latent, unpredictable, mutually uncorrelated primitive disturbance | §1 |
| policy action | glossary | `policy-action` | The chosen instrument setting, partly a reaction to $\Omega_{t-1}$ | §1 |
| policy surprise | glossary | `policy-surprise` | The unexpected part of an announcement, measured in a narrow window | §1 |
| proxy | glossary | `proxy` | Observed series equal to $\varepsilon_t$ plus error or contamination; attenuates every $\beta_h$ by one scale factor | §1 |
| information set | glossary | `information-set` | What is known just before the intervention, $\Omega_{t-1}$ | §2 |
| confounder | glossary | `confounder` | Variable moving both $s_t$ and $y_{t+h}$ | §3 |
| omitted-variable bias | glossary | `omitted-variable-bias` | Omitted effect on $y$ times its projection coefficient on $s$ | §3 |
| anticipation | glossary | `anticipation` | Agents acting on news before its recorded date | §4 |
| predictability test | glossary | `predictability-test` | Regression of $s_t$ on elements of $\Omega_{t-1}$ | §4 |
| timing convention | glossary | `timing-convention` | Rule dating $s_t$, the outcome window, and the controls relative to each other | §4 |
| predetermined control | glossary | `predetermined-control` | Control dated before news about $s_t$ arrives | §5 |
| post-treatment control | glossary | `post-treatment-control` | Control that can respond to $s_t$ | §5 |
| mediator | glossary | `mediator` | Channel variable through which $s_t$ moves $y$ | §5 |
| recursive identification | glossary | `recursive-identification` | Identification by an assumed within-period ordering | §5 |
| partialling out | glossary | `partialling-out` | Removing the projection on $\mathbf w_t$ from outcome and $s_t$ | §6 |
| Frisch–Waugh–Lovell theorem | glossary | `frisch-waugh-lovell` | Same-row residual slope equals the multiple-regression coefficient | §6 |
| specification record | glossary | `specification-record` | Written list that fixes what was estimated | §8 |
| high-frequency identification | footnote | — | Measuring surprises from asset prices in a window around announcements | §1 |
| information effect | footnote | — | Markets learning about the economy, not policy, from the announcement | §1 |
| bad control | footnote | — | Applied-micro name for a post-treatment control | §5 |
| time-series operators across gaps | footnote | — | `L.` and `F.` return missing when the adjacent month is absent | §7 |
| float storage | footnote | — | `gen` stores 7 significant digits; exact comparisons need `double` | §6 |
| local projection, horizon, counterfactual, causal response, long difference, common sample | prose, linked to L01/L02 glossaries | owned by L01/L02 | — | — |

## 4. Evidence and visual ledger

All Stata numbers come from `d7/l03_d7_checks.log` or `l03_results.csv` unless another source is named; sandbox numbers come from `sandbox/l03_sandbox.out`.

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| The surprise is unpredictable from $\Omega_{t-1}$; the action is not | robust (HC1) $F$ throughout: $s$ on 36 controls: $F(36,334)=0.99$, $p=0.482$, $R^2=0.089$, $N=371$; own 12 lags $F=1.10$, $p=0.359$; with housing starts $F(48,322)=1.00$, $p=0.474$; $\Delta$`stir`: $F=9.29$, $p<10^{-5}$, $R^2=0.505$ | table; optional figure | rerun | computed | `tbl-l03-predictability`, `fig-l03-predictability` |
| D7 is reproduced exactly | max coefficient difference $1.63\times10^{-7}$, s.e. $9.3\times10^{-8}$, $T_h$ identical, 49 horizons | table, figure | benchmark CSV + rerun | computed; figure to build | `tbl-l03-shelter-benchmark`, `fig-l03-shelter-response` |
| Confounder bias formula | §6.2; $n=2\times10^6$ check, $h=12$ rerun at $n=10^7$ | equation, figure | derivation, sandbox | verified; figure to build | `eq-l03-ovb`, `fig-l03-confounder-bias` |
| Anticipation: control absorbs, long difference misbases | §6.3 | equation, figure | derivation, sandbox | verified; figure to build | `eq-l03-anticipation`, `fig-l03-anticipation` |
| A predictability test detects $\zeta=0.5$ at $T=384$ | mean robust $F$ 11.67; rejection rate 0.91 at 5% ($R=200$) | prose, Lab 2 | sandbox MC | stored simulation result | — |
| Same-month variable: estimand depends on ordering | 1.0 / 0.8 / 1.3 / 1.24 at $h=0$ (§6.4) | table | derivation, sandbox | verified | `tbl-l03-same-month` |
| A noisy proxy attenuates every $\beta_h$ by one factor | §6.8: $\beta_h=0.5\times0.8^h$; simulation 0.500027, 0.398404, 0.203858, 0.035729 at $h=0,1,4,12$ | equation | derivation, sandbox addenda | verified | `eq-l03-proxy` |
| FWL holds in the anchor | differences $-2.0\times10^{-14}$, $2.1\times10^{-13}$, $1.3\times10^{-13}$, $5.1\times10^{-13}$ at $h=0,12,24,48$ (double storage) | prose, exercise | rerun | computed | `eq-l03-fwl` |
| The authors' "joint" coefficient partials out a different set on different rows | `Figure4.do` lines 99–108; benchmark joint coefficient at $h=48$ −1.38281 against pointwise −3.617904 | one sentence; discrepancy log (4) | benchmark CSV | recorded; reproduced and explained in L6 (anchor B1) | `#sec-l03-partialling-out` |
| Fixed rows, changed controls ($T=323$, $h=48$) | none −3.1933; own lags −2.3640; D7 −3.6179; +housing starts −1.3941; +same-month `stir`, `urate` −3.6567; +same-month $\Delta y_t$ −3.5438 and exactly 0 at $h=0$ | figure, table | rerun | stored | `fig-l03-shelter-variants` |
| Common versus horizon-specific rows with D7 controls | max gap 0.274 over $h$ (equal at $h=48$) | prose | rerun | computed | — |
| Zeros versus missing | keep rows with nonmissing $s$: $N$ 384→339, $b_{48}=-3.3975$; missing coded 0 from 1969: $N$ 602→554, $b_{48}=-0.1580$; zeros coded missing (`if`): $N$ 266→236, $b_{48}=-2.7283$; zeros dropped as rows: $N=0$ (longest nonzero run 8 months) | table | rerun; pandas on the `.dta` | computed | `tbl-l03-zeros-missing` |
| Misdating | shock one month late: $b_0=+0.1332$, $b_{48}=-3.7680$; one month early: $-0.0831$, $-3.6854$ | table row | rerun | computed | `tbl-l03-zeros-missing` |
| Action instead of surprise | $\Delta$`stir` as $s_t$: $b_{48}=+0.7842$; $\Delta$`stir` on $s$: $b=0.346$ (HC1 s.e. 0.314), $R^2=0.0086$, $N=383$ | prose (opening; closing illustration in `#sec-l03-shelter`) | rerun | computed | — |
| Paper text says January 1988, Figure 4 note says January 1998 | IJK arXiv v2 (13 Aug 2024) §6.2 versus the figure note; the data start in 1988m1 | footnote, discrepancy log | `design-06/papers/ijk.txt` | recorded | — |
| November archive differs | housing completions, centered 13-month smoother, $h=0$: −0.7766 | discrepancy log only (D7) | `DIAGNOSTIC-REP03-…csv` | stored | — |
| "Shelter is about a third of core inflation" (spine) | no source in hand | dropped pending Q6 | — | — | — |

## 5. Assessment map

| Outcome | Exercise | Tags | Mode | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. Four right-hand variables | [core] [pencil] | Classify six monthly candidates (funds-rate change, Bauer–Swanson surprise, Romer–Romer shock in the same file, an FOMC-meeting dummy, a Greenbook revision, a futures-rate change on non-meeting days); name the assumption each most threatens | Ask what the policymaker and markets knew at $t-1$ | Key with the threatened assumption and a diagnostic for each; the funds-rate change's $R^2=0.505$ | 1 |
| 2 | 2. The bias of a pre-shock confounder | [core] [pencil] | Derive `eq-l03-ovb`; evaluate at $(\psi_s,\psi_y)=(1,0.5)$ for $h=0,4$; show the bias is maximal at $\psi_s=1$ | Write $y_{t+h}$ by recursive substitution and keep only terms dated $t$ or $t-1$ | 1.25 and 0.512; maximum $\psi_y/2$ | 1 |
| 2 | 3. News a month early | [core] [pencil] | Derive the three coefficients of §6.3; find the first horizon at which the uncontrolled long difference is negative; compute the predictability slope and $R^2$ | Ask which regressors contain $\zeta\varepsilon_t$ | $h=5$; slope 0.059016, $R^2=0.029508$ | 2 |
| 2, 3 | 4. Mediator or confounder? | [core] [pencil] | Compute the four same-month coefficients; classify same-month `stir`, `urate`, and $\Delta y_t$ in the shelter regression | Draw the within-month arrows before writing any covariance | 1.0, 0.8, 1.3, 1.24; $\Delta y_t$ forces $\hat\beta_0=0$ exactly | 3 |
| 2 | 5. The sandbox in Stata | [core] [computational] | Load Lab 1's exported CSVs (flawed and defensible specifications); estimate $h=0,\dots,12$; then a Stata Monte Carlo with $R=200$ of $\hat\beta_0$ with and without $x_{t-1}$ | Store every replication with `postfile` and summarize once | `assert` means within $3\,\mathrm{sd}/\sqrt R$ of 1.25 and 1.00 (Python reference: 1.2525, s.d. 0.0366; 1.0042, s.d. 0.0514) | 1, 5 |
| 5 | 6. Reproduce the shelter response | [core] [computational] [data] | Transparent loop (STA03 task 1) | Recall that `drop if` changes both lags and leads | `assert` coefficient $<10^{-6}$ and $T_h$ equal at all 49 horizons | 4 |
| 3 | 7. Partialling out | [computational] [data] | FWL in `double` at every $h$; then write one sentence on why the benchmark's `joint_driscoll_kraay` column is not $\hat\beta_h$ (forward link: Lecture 6 reproduces and explains it as anchor B1) | Ask which controls and which rows each residual used | FWL $<10^{-10}$; the sentence names `dlunitstart` and the rows of lines 99–108 | 4 |
| 4 | 8. Zeros, missing values, and dates | [core] [computational] [data] | Diagnose three supplied corruptions (STA03 task 4), repair them, report $N_0$, $N_{48}$, $b_{48}$ | Tabulate zero months by year before running any regression | Values in `tbl-l03-zeros-missing`; the repaired file reproduces exercise 6 | 4 |
| 3, 5 | 9. Identification or precision? | [core] [pencil] [data] | From the variant table, classify each change as addressing A1, A2, A3, the estimand, the sample, or precision; write the specification record and a one-page identification memo | Ask whether the change could matter in population if $s_t$ were truly unpredictable | Rubric: names A1–A3 and the three threats; explains the 2.22 housing-starts shift without calling it bias | 5 |
| 2 | 10. The power of a predictability test | [extra] [computational] | $R=200$ simulations over $T\in\{120,384,1000\}$ and $\zeta\in\{0.25,0.5\}$ (D26) | Separate "no rejection" from "no anticipation" | Rejection rate at $T=384$, $\zeta=0.5$ within Monte Carlo error of 0.91 | 2 |

Coverage: outcome 1 (§1–2, exercise 1, Lab 1 setup); outcome 2 (§3–5, figures, exercises 2–5 and 10, Labs 1–3); outcome 3 (§5–6, exercises 4, 7, 9, Lab 3); outcome 4 (§7–8, exercise 8, Lab 5); outcome 5 (§9, exercises 6 and 9, REP03).

## 6. Derivations to verify

*Acceptance rule for the sandbox checks (§6.2–6.4, §6.8).* A closed form is accepted when each simulated slope lies within 3 simulation standard errors of it, with s.e. $\approx\sqrt{\operatorname{Var}(y)/(n\operatorname{Var}(\tilde s_t))}$ (an i.i.d. approximation that uses $\operatorname{Var}(y)$ as a bound on the residual variance). Every check below meets it. The largest gap, $h=12$ in §6.2 at 2.5 s.e., was also rerun at $n=10^7$.

**6.1 The identification condition** (`eq-l03-condition`). *Source identity:* FWL for the population projection, $\beta_h=\operatorname{Cov}(\tilde s_t,y_{t+h})/\operatorname{Var}(\tilde s_t)$, where $\tilde s_t=s_t-\operatorname{Proj}(s_t\mid 1,\mathbf w_t)$. *Local error:* the ledger's $u_{t,h}$ is the projection residual, orthogonal to $\tilde s_t$ by construction, so a condition written with it would always hold. Let $(\mu^\ast_h,\boldsymbol\gamma^\ast_h)$ be the coefficients of the population projection of $y_{t+h}-\theta_hs_t$ on $(1,\mathbf w_t)$, and define the structural composite error $u^\ast_{t,h}=y_{t+h}-\theta_hs_t-\mu^\ast_h-\boldsymbol\gamma^{\ast\prime}_h\mathbf w_t$ (other shocks, omitted pre-shock variables, future shocks and news). *Steps:* substitute $y_{t+h}=\theta_hs_t+\mu^\ast_h+\boldsymbol\gamma^{\ast\prime}_h\mathbf w_t+u^\ast_{t,h}$; $\tilde s_t$ is orthogonal to $(1,\mathbf w_t)$ and $\operatorname{Cov}(\tilde s_t,s_t)=\operatorname{Var}(\tilde s_t)$. *Result:* $\beta_h=\theta_h+\operatorname{Cov}(\tilde s_t,u^\ast_{t,h})/\operatorname{Var}(\tilde s_t)$. $u^\ast_{t,h}$ equals the ledger's $u_{t,h}$, with $(\mu^\ast_h,\boldsymbol\gamma^\ast_h)=(\mu_h,\boldsymbol\gamma_h)$, exactly when this covariance is zero, which is what A1–A3 jointly deliver: then $u^\ast_{t,h}$ is orthogonal to $(1,s_t,\mathbf w_t)$. A1–A3 each set one piece of the covariance to zero: omitted pre-shock variables, other shocks dated $t$, shocks and news after $t-1$. *Check:* the four sandbox rows of §1 are special cases; §6.8 gives a nonzero covariance with no timing failure.

**6.2 Confounder** (`eq-l03-ovb`). *Source:* recursive substitution, $y_{t+h}=\rho^{h+1}y_{t-1}+\sum_{j=0}^{h}\rho^{h-j}(\theta_0 s_{t+j}+\psi_y x_{t+j-1}+v_{t+j})$. *Steps:* (i) $x$ i.i.d. implies $s_{t+j}\perp s_t$ for $j\ge1$ and $y_{t-1}\perp s_t$, so the coefficient is the same with or without $y_{t-1}$. (ii) Take the covariance with $s_t$; only $j=0$ survives: $\theta_0(1+\psi_s^2)+\psi_y\psi_s$. (iii) Divide by $\operatorname{Var}(s_t)=1+\psi_s^2$. *Result:* $\beta_h=\rho^h\{\theta_0+\psi_y\psi_s/(1+\psi_s^2)\}$, which is $\theta_h$ plus $\rho^h\psi_y$ times the projection coefficient of $x_{t-1}$ on $s_t$. With $x_{t-1}$ in $\mathbf w_t$, $\tilde s_t=\varepsilon_t$ and $\beta_h=\theta_0\rho^h$. The map $\psi_s\mapsto\psi_s/(1+\psi_s^2)$ peaks at $\psi_s=1$, so the largest bias is $\psi_y/2$. *Numerical check* ($\rho=0.8,\theta_0=1,\psi_s=1,\psi_y=0.5$, $n=2\times10^6$, seed 20260913): closed form 1.250000, 1.000000, 0.512000, 0.085899 at $h=0,1,4,12$; simulation 1.249510, 0.997572, 0.510467, 0.090132. The $h=12$ gap is 2.5 simulation standard errors (s.e. $\approx\sqrt{11.806/(2\times10^6\cdot2)}=0.0017$, with $\operatorname{Var}(y)=4.25/0.36=11.806$), inside the rule. A rerun at $n=10^7$ (fresh `default_rng(20260913)`, `l03_sandbox_addenda.out`) gives 1.250408, 1.000199, 0.511828, 0.086054, each within 0.53 s.e. (s.e. 0.00077). With $x_{t-1}$ controlled: 0.999205, 0.797494, 0.407754, 0.071728 against 1, 0.8, 0.4096, 0.068719.

**6.3 Anticipation** (`eq-l03-anticipation`). *Source:* $y_t=\rho y_{t-1}+\theta_0\varepsilon_t+\zeta\varepsilon_{t+1}+v_t$ with $s_t=\varepsilon_t$. *Steps:* (i) $\operatorname{Cov}(y_{t-1},\varepsilon_t)=\zeta$. (ii) In the substitution, every term except $\rho^{h+1}y_{t-1}$ and $\theta_0\rho^h\varepsilon_t$ is dated $\varepsilon_{t+1}$ or later, or is a $v$, so the projection on $(\varepsilon_t,y_{t-1})$ is exact with coefficient $\theta_0\rho^h$. (iii) Without controls, the level coefficient is $\theta_0\rho^h+\zeta\rho^{h+1}$ (the true effect). (iv) The long difference subtracts $\zeta$. (v) With $y_{t-1}$ controlled, the long difference returns $\theta_0\rho^h$ by L2's same-regressor equivalence. (vi) $\operatorname{Var}(y)=\zeta^2+\{(\theta_0+\zeta\rho)^2+1\}/(1-\rho^2)$. *Check* ($\zeta=0.5$): truth 1.4, 1.12, 0.57344, 0.096207 at $h=0,1,4,12$ (simulation 1.400687, 1.121660, 0.573235, 0.095215); with $y_{t-1}$ 1, 0.8, 0.4096, 0.068719 (simulation 0.999552, 0.800781, 0.408988, 0.067651); uncontrolled long difference 0.9, 0.62, 0.07344, −0.403793 (simulation 0.899351, 0.620323, 0.071899, −0.406123). It first turns negative at $h=5$, where $1.4\times0.8^5-0.5=-0.04125$. $\operatorname{Var}(y)=8.472222$ (simulation 8.492029). Predictability slope $\zeta/\operatorname{Var}(y)=0.059016$ (simulation 0.059109), $R^2=\zeta^2/\operatorname{Var}(y)=0.029508$.

**6.4 Same-month variable** (`eq-l03-same-month`). *Mediator ordering:* $y_t-\rho y_{t-1}=\theta_0s_t+\nu_yq_t+v_t$ with $q_t=\nu_ss_t+\nu_vv_t+\xi_t$. Project $v_t$ on $(s_t,q_t)$: given $s_t$, $\operatorname{Cov}(v_t,q_t)=\nu_v$ and $\operatorname{Var}(q_t)=\nu_v^2+1$, so $v_t=b(q_t-\nu_ss_t)+e_t$ with $b=\nu_v/(1+\nu_v^2)$. The coefficient on $s_t$ is then $\rho^h(\theta_0-b\,\nu_s)$, and without $q_t$ it is the total effect $\rho^h(\theta_0+\nu_s\nu_y)$. $q_{t-1}$ is orthogonal to $s_t$ and changes nothing. *Recursive ordering:* $s_t=\varepsilon_t+\nu_sq_t$, $q_t=\xi_t$; omitting $q_t$ gives $\rho^h\{\theta_0+\nu_y\nu_s/(1+\nu_s^2)\}$. *Check* ($\nu_s=0.5,\nu_y=0.6$): total 1.3 (simulation 1.300075); with $q_t$ and $\nu_v=0$, 1.0 (0.999487); with $\nu_v=0.5$, 0.8 (0.799437) and at $h=4$ 0.32768 (0.329589); with $q_{t-1}$, 1.298574 when $\nu_v=0.5$. Recursive, omitted: 1.24 (1.239620) and 0.507904 at $h=4$ (0.509952); included: 1.0 (0.999802).

**6.5 FWL in the anchor** (`eq-l03-fwl`). *Source:* FWL requires the same rows for both residuals. *Check* (double storage): $\hat\beta_h$ from the full regression minus the same-row residual slope is $-2.0\times10^{-14}$, $2.1\times10^{-13}$, $1.3\times10^{-13}$, $5.1\times10^{-13}$ at $h=0,12,24,48$. The first run stored residuals as float and failed a $10^{-8}$ assertion at $h=12$ ($3.5\times10^{-8}$); that log is kept as `l03_d7_checks_run1_failed.log`. *The authors' joint coefficient (one sentence in `#sec-l03-partialling-out`):* `Figure4.do` lines 99–108 residualize $s$ on the D7 controls plus 12 lags of `dlunitstart` over all 371 rows and $y_{t+h}-y_{t-1}$ on the same set over its own rows, so the joint coefficient they feed (benchmark −1.38281 at $h=48$) is not the plotted −3.617904. This is discrepancy-log row (4); Lecture 6 reproduces and explains it as anchor B1 (REP06 Target B).

**6.6 Row counts.** In the D7 file, $\Delta y_{t-12}$ needs 13 prior months inside the 384-month file, so the first row is 1989m2 and $T_h=384-13-h=371-h$ (benchmark 371 and 323). Keeping all 615 rows and using `if s<.` gives $T_0=384$; at $h=48$ the last row is 2020m3 − 48 months = 2016m3, so $T_{48}$ counts 1988m1–2016m3 = 339. Missing coded as zero from 1969: rows 1970m2–2020m3 = 602 and 1970m2–2016m3 = 554. Zero months dropped as rows: a usable row needs 14 consecutive nonzero months, and the longest run in the data is 8, so $N=0$.

**6.7 Normalization.** Per one-s.d. surprise: $-3.6179044\times0.04726197=-0.170989$ percent at $h=48$. A unit surprise is $1/0.04726197=21.16$ standard deviations, which is why the notes quote both scales.

**6.8 Noisy proxy** (`eq-l03-proxy`). *Design:* $y_t=\rho y_{t-1}+\theta_0\varepsilon_t+v_t$ with observed $s_t=\varepsilon_t+\varsigma_t$, $\operatorname{Var}(\varepsilon_t)=\sigma_\varepsilon^2$, and $\varsigma_t$ i.i.d. with variance $\sigma_\varsigma^2$, independent of every other variable at every date. *Steps:* (i) $y_{t+h}=\rho^{h+1}y_{t-1}+\sum_{j=0}^{h}\rho^{h-j}(\theta_0\varepsilon_{t+j}+v_{t+j})$, and $y_{t-1}$ is independent of $(\varepsilon_t,\varsigma_t)$, so the coefficient is the same with or without $y_{t-1}$. (ii) $\operatorname{Cov}(s_t,y_{t+h})=\theta_0\rho^h\sigma_\varepsilon^2$ and $\operatorname{Var}(s_t)=\sigma_\varepsilon^2+\sigma_\varsigma^2$. (iii) In §6.1's terms, $y_{t+h}=\theta_hs_t-\theta_h\varsigma_t+\dots$, so $u^\ast_{t,h}$ contains $-\theta_h\varsigma_t$ and $\operatorname{Cov}(\tilde s_t,u^\ast_{t,h})=-\theta_h\sigma_\varsigma^2$ whatever the controls: the noise is correlated with $s_t$ because it is part of $s_t$. *Result:* $\beta_h=\theta_0\rho^h\,\sigma_\varepsilon^2/(\sigma_\varepsilon^2+\sigma_\varsigma^2)$. The factor is the same at every horizon, so $\beta_h/\beta_0=\rho^h=\theta_h/\theta_0$ is unaffected: the shape is identified and the scale is not. The noise is dated $t$ and unpredictable, so neither a pre-shock control nor the predictability test can detect it. Lecture 4's instrument removes the scale factor: with $z_t=\varepsilon_t+\varsigma_t$ as the instrument for an endogenous $s_t$ that $\varepsilon_t$ moves one for one, $\operatorname{Cov}(y_{t+h},z_t)/\operatorname{Cov}(s_t,z_t)$ divides out $\sigma_\varepsilon^2$ and $\sigma_\varsigma^2$ never enters. *Check* ($\rho=0.8$, $\theta_0=1$, $\sigma_\varepsilon=\sigma_\varsigma=1$, so $\beta_h=0.5\times0.8^h$; $n=2\times10^6$, fresh `default_rng(20260913)`, with $y_{t-1}$; `l03_sandbox_addenda.out`): closed form 0.5, 0.4, 0.2048, 0.034360 at $h=0,1,4,12$; simulation 0.500027, 0.398404, 0.203858, 0.035729 (largest gap 1.35 s.e.). Simulated $\hat\beta_h/\hat\beta_0$: 1, 0.796765, 0.407694, 0.071454, against $\rho^h=$ 1, 0.8, 0.4096, 0.068719.

## 7. HTML lab plan (Identification and Controls Sandbox, `interactives/03-identification-sandbox.qmd`)

Five labs in Observable JS on one page, in the order of the dependency chain. Each lab has a setup paragraph, a **Predict before using the controls** prompt, labeled controls, a plot and a small table, a reactive sentence, controlled comparisons, and a collapsed explanation. Shocks come from `mulberry32` with a visible seed. Innovations are drawn once per seed at $T_{\max}=1000$ plus the burn-in of 50 (and one lead of $\varepsilon$ for Lab 2); a sample of size $T$ uses the first $T$ rows after burn-in, and outcomes are rebuilt from the stored draws whenever $\psi_s$, $\psi_y$, $\zeta$, $\nu_s$, $\nu_y$, $\nu_v$ or the ordering changes. Changing $T$ or a parameter never redraws shocks. Each panel is labeled "live calculation", "population (closed form)", or "stored Stata result" (D30). No confidence bands appear anywhere (D8). Browser OLS is validated against `l03_sandbox.py` on one shipped draw to $10^{-10}$.

**Lab 1 — The confounder dial (live).** *Question:* when does a variable the policymaker reacts to bias the response? *Invariants:* $\rho=0.8$, $\theta_0=1$, unit variances, the shock sequences (drawn once per seed at $T=1000$ plus burn-in; a smaller $T$ takes the first $T$ rows). Changing $T$ or a parameter never redraws shocks. *Controls:* $\psi_s\in[0,3]$ (default 1); $\psi_y\in[-1,1]$ (default 0.5); "control for $x_{t-1}$" (off); $T\in\{120,384,1000\}$ months (384); seed (3); $H=12$. *Computation:* simulate, run OLS at each $h$ with $y_{t-1}$ (and $x_{t-1}$ when toggled), and overlay $\theta_h$ and the closed-form $\beta_h$. *Reactive sentence:* "With $\psi_s=1.00$ and $\psi_y=0.50$ the population coefficient at impact is 1.25 against a causal effect of 1.00; this sample gives 1.2x; controlling for $x_{t-1}$ gives 1.0x." *Comparisons:* $\psi_y=0$ with $\psi_s=1$; $\psi_s=3$; the toggle at a fixed seed. *Prediction:* "Can the bias grow while the confounder's effect on $s$ grows and its effect on $y$ stays fixed?" *Handoff:* exports the rows ($t,y,s,x$) with parameters and seed in a header.

**Lab 2 — News arrives early (live, plus a stored reference).** *Question:* what do the usual regressions report when agents learn the shock a month before its recorded date, and would we notice? *Invariants:* as in Lab 1. Changing $T$ or a parameter never redraws shocks, so $T=120$ against 1000 compares nested samples of one draw. *Controls:* $\zeta\in[0,1]$ (0.5); dependent variable level or long difference (long difference); control $y_{t-1}$ (on); $T$ (384). *Computation:* LP at $h=-1,\dots,12$; truth from §6.3; the predictability regression of $s_t$ on $y_{t-1}$ with HC1 $t$ and $p$. The reference rejection rate is shown as a labeled stored result (0.91 at $T=384$, $\zeta=0.5$, $R=200$). *Reactive sentence:* "The truth at $h=0$ is 1.40, with 0.50 already visible at $h=-1$; your regression reports 1.0x because $y_{t-1}$ contains the news; the predictability test gives $p=0.0xx$." *Comparisons:* $\zeta=0$; switch off the control and change the dependent variable; $T=120$ against 1000.

**Lab 3 — Same month, two orderings (live and closed form).** *Question:* is a same-month variable a confounder to include or a mediator to exclude? *Controls:* ordering ($s$ first / $q$ first); $\nu_s$ (0.5), $\nu_y$ (0.6), $\nu_v$ (0); include $q_t$, $q_{t-1}$, or neither. *Display:* bars for total, direct, and estimated effects at $h=0$, plus the path to $h=12$. *Reactive sentence:* "Under the $s$-first ordering, including $q_t$ reports the direct effect 1.00 instead of the total 1.30; raise $\nu_v$ and it reports neither." *Comparisons:* flip the ordering with the data fixed; $q_{t-1}$ against $q_t$. *Prediction:* "Does including $q_{t-1}$ change the estimate?"

**Lab 4 — The shelter specification explorer (stored Stata result).** *Question:* which choices move the D7 curve, and why? *Invariants:* data file, $H=48$, OLS point estimates; D7 shown as a fixed reference line. *Controls:* $s_t$ (surprise / funds-rate change / surprise misdated $\pm1$ month); controls (none / own lags / D7 / D7 + housing starts / D7 + same-month variables); rows (as shipped / common $\mathcal T_{48}$ / keep rows with nonmissing $s$ / missing coded zero / zeros coded missing). *Data:* a factorial grid ($4\times5\times5=100$ configurations × 49 horizons, `regress` only) produced by an instructor build of `l03_d7_checks.do` extended to the grid, with a version header. The rows computed so far are in `l03_results.csv`. *Reactive sentence:* "At 48 months this specification gives −1.39 percent against D7's −3.62 on the same 323 rows; the change is a predetermined control, so if the surprise is unpredictable the gap is sampling variation, not a correction of bias." *Comparisons:* change controls with rows fixed; change rows with controls fixed.

**Lab 5 — Write the specification record.** A form with shock, outcome and transformation, controls with lag dates, row rule, horizons, normalization, and source lines. It is prefilled from Labs 1–4, and a checker flags controls dated $t$ and missing-as-zero choices. *Stata handoff:* `l03_spec_flawed.json` (for example, confounder omitted, $T=384$, seed 3) and `l03_spec_defensible.json`, plus the Lab 1 CSV, for exercises 5 and 9.

## 8. Practicum plan

### 8.1 REP03 — Reconstruct an empirical specification

- **Target (D7, D8):** point estimates and $T_h$, $h=0,\dots,48$, of the cumulative response of log shelter prices to the Bauer–Swanson surprise: `pointwise_newey_west` rows of the benchmark. Bands deferred to L5–L6.
- **Paper version:** Inoue, Jordà, and Kuersteiner, "Inference for local projections", *Econometrics Journal* 29(1), 2–26 (2026), doi 10.1093/ectj/utaf004, the version frozen as R03 in `VERIFIED.md`. The reading guide cites the shelter-inflation application section of that article, "section numbers from the frozen version; page range to confirm" (D31). The EJ section number must be read from the article itself, which is not among the scratch copies. (Mapping to the August 2024 archive: arXiv 2306.03073v2, 13 Aug 2024, §6.2, "Application: the response of shelter inflation to monetary policy".)
- **Code and data:** `packages/econometrics-journal/author-20240813/original/Replication Code/Figure4.do` (commit `340947c`; archive SHA-256 `3677101c…`); lines 14–19 (shock and rows), 32–43 (outcome, lags, bandwidth), 55–61 (dependent variable), 71–80 (loop). `sigband_shelterinf.dta` (615 rows, 7 Aug 2024). Lines 97–225 are not run in REP03, so `wildbootstrap` and `xtscc` are not needed (D4).
- **Replication kind:** exact numerical replication.
- **Benchmark values** (coefficient, $T_h$): $h=0$ −0.066480346, 371; 6 0.15861371, 365; 12 −0.22524464, 359; 24 −1.5020505, 347; 36 −2.6786962, 335; 48 −3.6179044, 323. Standard errors are carried and compared, not interpreted.
- **Tolerance:** $10^{-6}$ absolute on coefficients and standard errors; $T_h$ exact. The 19.5 rerun meets it ($1.63\times10^{-7}$, $9.3\times10^{-8}$) (D1).
- **Runtime:** the author's full script took 75.5 s in 18.5 (`REP03-shelter-20240813`); the course check file, including all variants, took 71 s in 19.5.
- **Departures:** none in the author run. The course loop stores the dependent variable in `double`, which gives identical results to 10 decimals at $h=0$ and 48.
- **Discrepancy log rows:** (1) software, 18.5→19.5, within tolerance; (2) presentation, Figure 4 note "January 1998" against the text's and the code's 1988; (3) presentation, $h=48$ estimated but not plotted; (4) internal, the joint coefficient partials out housing starts on script rows ($h=48$: −1.38281 against −3.617904; §6.5), reproduced and explained in L6 (anchor B1); (5) sample, the effective first row is 1989m2 because line 19 drops pre-sample lags; (6) diagnostic, the November archive (completions, smoothed; $h=0$ −0.7766), never the anchor (D7).
- **Redistribution (D5):** CC0 archive, so the lab project ships the `.dta`, `SOURCE.md`, and `LICENSE`; see Q5 on the third-party caveat in `SOURCE.md`.
- **Outputs:** benchmark curve, data-construction audit (the row-count identities of §6.6, the zero-month table), identification memo.

### 8.2 STA03 — Construct, estimate, diagnose, interpret

Project `p03-identification-and-controls/`: `master.do`; `code/01_reproduce.do` … `05_memo_tables.do`; `data/raw/` (shipped `.dta` plus three corrupted files); `benchmarks/REP03-shelter-prices-author-20240813.csv`; `output/`. Variable names follow the ledger: `y`, `s`, `dy`, `stir`, `urate`, `h`, `beta_h`, `N_h`.

1. **Reproduce with a transparent loop.** `forvalues h=0/48`, `gen double lhs = F`h'.y - L.y`, `regress lhs s L(1/12).dy L(1/12).stir L(1/12).urate`, post to `sta03_beta.csv`. Assertions: `abs(beta_h-bench)<1e-6`, `N_h==bench_n` at every $h$.
2. **Partialling out.** Same-row residuals in `double`; `assert abs(b_full-b_fwl)<1e-10`. The authors' joint coefficient is not reproduced here; a do-file comment links forward to Lecture 6, anchor B1 (REP06 Target B).
3. **Control sets on fixed rows.** Mark `common` from the $h=48$ regression; `assert e(N)==323` everywhere. Expected at $h=48$: none −3.1933; own lags −2.3640; D7 −3.6179; + housing starts −1.3941; + same-month `stir urate` −3.6567; + $\Delta y_t$ −3.5438, and $\hat\beta_0=0$ to machine precision. Report the predictability $F$ for each set.
4. **Supplied errors.** (A) `corrupt_A.dta`: `s` lagged one month inside the 384-month analysis file; expected $b_0=+0.1332$, $b_{48}=-3.7680$, $N_0=371$. (B) `corrupt_B.dta`: the 118 zero months coded missing in the 615-row file; with `if s<.` expected $N_0=266$, $b_{48}=-2.7283$; after `drop if s==.` expected $N=0$. (C) `corrupt_C.dta`: pre-1988 missing coded 0; expected $N_0=602$, $N_{48}=554$, $b_{48}=-0.1580$. Diagnostic assertions: zero months per year $\le4$ from 2002 on; nonmissing span 1988m1–2019m12. Each repaired file must pass task 1.
5. **Identification versus precision.** Classify each variant from tasks 3–4 and the funds-rate change ($b_{48}=+0.7842$); write the specification record and the memo.

**Handoff.** In: Lab 5's two JSON records and the Lab 1 CSV (exercise 5). Out to L4: the proxy-attenuation result (§6.8) and the spine's question, how a variable correlated with the shock but not the shock itself can identify a response.

**Submission package** (blueprint §4.2): replication record (target, versions, commands, 49-row comparison, discrepancy log); Stata submission (master do-file, log, `sta03_beta.csv`, variant table, response figure, passing assertions); interpretation record (estimand, A1–A3, threats, units per unit and per s.d., limits); lab record (predictions, exported JSON, three sentences on Lab 4).

## 9. Slides arc

1. **Title.** Identification, controls, and the pre-shock information set.
2. **Two regressions, one causal reading.** −3.62 against +0.78 on identical rows; $R^2$ 0.089 against 0.505.
3. **Four right-hand variables.** Action, surprise, shock, proxy: one table.
4. **What $\beta_h=\theta_h$ requires.** `eq-l03-condition` and A1–A3 on the timeline figure.
5. **Confounding.** The bias formula and `fig-l03-confounder-bias`.
6. **News before the date.** `fig-l03-anticipation`: the control absorbs the effect, the long difference uses the wrong base.
7. **Predetermined means before the news.** The predictability test and its power at $T=384$.
8. **Same month, two orderings.** Mediator or recursive confounder: the ordering is the assumption.
9. **One coefficient, two routes.** Frisch–Waugh–Lovell in the same rows; one line on why the authors' joint coefficient differs (Lecture 6, B1).
10. **Zeros, missing values, dates.** −3.62, −0.16, $N=0$, and a sign flip at impact.
11. **The shelter anchor reproduced.** `fig-l03-shelter-response`, 49 horizons within $10^{-6}$; closing illustration: a first link with $R^2=0.0086$.
12. **Identification or precision?** `fig-l03-shelter-variants`: a 2.22 shift with an insignificant predictability $F$.
13. **The specification record and the memo.**
14. **Lab and practicum workflow.**
15. **For Lecture 4.** A proxy recovers the shape, not the scale. How can a variable correlated with the shock, but not the shock itself, identify a response?

## 10. Open questions for the editor

1. **Units of `BSmonshock`.** The file labels it "(sum) BSmonshock" and neither the code nor §6.2 states its scale. May the notes say "percentage points" after checking Bauer–Swanson's data documentation, or should they quote "per unit as shipped" and per one s.d. only?
2. **Cross-lecture consistency.** Resolved: L06 §1 now quotes the benchmark (month 48 only).
3. **Figure 4 note ("January 1998").** Should the notes state the difference neutrally in a footnote, as D14 allows for REP08, or record it only in the discrepancy log?
4. **The author's joint column.** Resolved: logged in L3 (one sentence in `#sec-l03-partialling-out`, discrepancy-log row 4), reproduced and explained in L6 (anchor B1).
5. **D5 and `SOURCE.md`.** D5 expects the IJK archive to ship, but `SOURCE.md` notes that "separate third-party data rights still apply" to bundled data (FRED series, Bauer–Swanson shocks). Is shipping confirmed, or should an acquisition script be written?
6. **Spine opening.** "Shelter is about a third of core inflation" has no source in hand. Should it be dropped or sourced?
