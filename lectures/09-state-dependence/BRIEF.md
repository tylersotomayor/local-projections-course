# Lecture 09 brief — State dependence and asymmetric responses

Planning brief for `lectures/09-state-dependence/`, the browser lab
`interactives/09-state-dependence-lab.qmd` ("State-Dependence Laboratory"),
and the practicum `practica/p09-state-dependence/`. Binding sources: editor
decisions D1, D2, D4, D5, D11, D12, D20, D22, D24–D26, D30, D31; the course
spine entry for Lecture 9; notation ledger §6; terminology plan row 09. Every
number below comes from a benchmark CSV, a scratch run in
`scratchpad/design-09/` (StataNow/SE 19.5 or Python 3 with NumPy 1.26.4 and SciPy 1.11.4), or a derivation shown in §6.

## 1. Session brief

**Opening situation.** After 2009 the multiplier debate was about slack: is
government spending more effective when unemployment is high? Ramey and
Zubairy (2018) split 127 years of U.S. quarterly data by whether last
quarter's unemployment rate was at least 6.5 percent. They then estimate one cumulative
multiplier for each state. Through quarter 7, the published "2-year integral", the high-unemployment
multiplier is 0.60 (s.e. 0.095) and the low-unemployment multiplier 0.59
(0.091), with a HAC $p$-value of .954 for the difference. The same program at impact gives
different numbers: −0.61 in slack and 1.24 otherwise, with a direct-test $p$-value of 0.044. Yet both
95 percent bands overlap. The slack-state first stage there has a
Kleibergen–Paap $F$ of 2.03, and 99 percent of the slack state's shock variance
comes from 1940–45. Estimating the two numbers takes one interaction.
Saying what they mean requires answering three questions. Which shocks identify each state? What
happens to the state after the shock? And what does "the multiplier in slack"
describe when spending itself pulls the economy out of slack?

**Decision or empirical question.** Does the response depend on the state the
economy starts in or on the direction of the shock? What must a
researcher report before a state-specific coefficient can support such a claim? In
operational terms: given an interacted LP, which object does each state
coefficient estimate, how many shocks inform it, is the difference tested
directly, and was the state definition fixed before the answer was seen?

**Target student and prerequisites.** A student who has completed Lectures 1–8 can already:

- build the horizon-$h$ regression and state its units (L1–L2);
- argue identification from a pre-shock information set (L3);
- estimate the RZ one-step cumulative multiplier by LP-IV and read a robust first-stage $F$ (L4, REP04);
- name a HAC procedure and its bandwidth (L5);
- test a linear combination of coefficients with their joint covariance (L6).

L7–L8 supply the vocabulary of misspecification and restriction. New tools
are Stata factor-variable interactions, `lincom`/`test` after `ivregress
2sls`, and `postfile` for a short Monte Carlo. No regime-switching or
threshold-estimation theory is assumed.

**Learning outcomes (five).** By the end, the student can

1. write the interacted LP with state-specific intercepts, shock
   coefficients, and controls (and its LP-IV multiplier form). The student can show that it
   reproduces two split-sample regressions in point estimates and explain what
   pooling adds: a joint HAC covariance across states.
2. state the estimand of a state coefficient as a response conditional on the
   state at $t-1$ that averages over later state transitions, and distinguish it
   from a fixed-state experiment. The student computes both in a two-state economy, says when they coincide,
   and explains why a shock that moves the state makes the response
   depend on the shock's sign and size.
3. diagnose support. That means counting and sizing the shocks in each state,
   locating the episodes that carry the identifying variance, and reporting
   first-stage strength by state. The student then decides what a state-specific estimate can
   claim.
4. test a state difference directly from the joint covariance, and explain why non-overlapping
   95 percent bands imply rejection while overlapping bands do not imply equality. The student treats
   alternative thresholds and sign splits as labeled sensitivity with the
   multiplicity stated.
5. decompose a difference between state-specific responses into coefficient
   and composition components (Kitagawa–Oaxaca–Blinder). The student writes the RZ interpretation
   record without claiming that an interaction identifies a finite-sized
   intervention in an economy held in one state, which is the blueprint's mastery requirement.

**Anchor examples.**

*Empirical anchor (the fiscal anchor of the spine; REP09 per D12).* Ramey and
Zubairy (2018), *JPE* 126(2), 850–901. The data are `RZDAT.xlsx`, sheet `rzdat` (April 7,
2016 update; SHA-256 `b2d85087…8c6120`), and the program is `jordagk.do` of February 24,
2018, run unmodified with `local state slack` (line 33).

| Object | Definition in the code | Units |
|---|---|---|
| $y_t$ | `rgdp/rgdp_pott6` (line 106) | real GDP as a ratio to sixth-degree-trend potential GDP |
| $g_t$ | `(ngov/pgdp)/rgdp_pott6` (lines 95, 107) | real government spending, same denominator |
| $s_t$ (reduced form), $z_t$ (instrument) | `newsy = news/(L.rgdp_pott6*L.pgdp)` (line 94) | present value of military-spending news as a share of lagged nominal potential GDP |
| $U_{t-1}$ | `unemp`, lagged | percent |
| $I_{t-1}$ | `L.slack`, `slack = unemp >= 6.5` (line 75) | indicator |

In reduced-form LPs the news series is the intervention $s_t$, as in L1–L2 (ledger §6's $s^\pm_t$); in the multiplier form it is the instrument $z_t$, and spending $g_t$ is L4's $s_t$.

Sample: 508 quarters 1889Q1–2015Q4, WWII retained, four lags of $s$, $y$, $g$,
no trend, no taxes; $T_h=500-h$. At $h=0$ the sample has 181 slack
quarters (36.2 percent) and 319 non-slack quarters.
Benchmark: `REP09-state-dependent-fiscal.csv` (189 rows, Stata/SE 18.5). Rerun
in 19.5 (D1): every multiplier, standard error, and $p$-value identical (max
absolute difference 0), 8.9 s wall clock.

*Illustration anchor (JT Example 9; CC0).* Jordà–Taylor (2025) `kob_sim.do`
(SHA-256 `b495e481…a65d`). Seed 12345, 500 burn-in and 500 kept observations.
The DGP is $s_t=0.75s_{t-1}+v_{s,t}$, $x_t=0.75x_{t-1}+v_{x,t}$,
$y_t=0.75y_{t-1}+0.75x_t+\mathbb 1(|s_t|>1)\,s_t(0.5+0.5x_t)+v_{y,t}$, with LPs
`newey f(h).y x l.y Is Isx, lag(12)` for $h=0,\dots,12$. There are 230 treated periods.

*Simulation anchor (course design; a Monte Carlo, never called a
replication).* A two-state economy calibrated to RZ frequencies. States $A$ (slack, $I=1$) and $B$.
Shock $s_t=\zeta_t\epsilon_t$, $\zeta_t\sim\text{Bernoulli}(\nu)$,
$\epsilon_t\sim\mathcal N(0,1)$, $\nu=0.2$ (RZ: 107 nonzero quarters in 500). Outcome
$y_t=\rho_{I_{t-1}}y_{t-1}+\theta^{I_{t-1}}_0 s_t+v_t$, $v_t\sim\mathcal N(0,1)$,
with $\theta^A_0=1.5$, $\theta^B_0=0.5$, $\rho_A=0.9$, $\rho_B=0.6$. The state follows
$\Pr(I_t=1\mid I_{t-1}=i,s_t)=\Phi\big(\Phi^{-1}(p_{iA})-\varpi s_t\big)$ with
$p_{AA}=0.93$, $p_{BA}=0.04$ (RZ: 168/181 and 13/319), so the stationary slack share
is $0.3636$ (RZ: 0.362). Two designs: $\varpi=0$ (exogenous state) and
$\varpi=1$ (a positive shock pushes the economy out of slack). Seed 9;
$T=500$ after 200 burn-in; $R=200$ for students, 500 for instructor builds (D2).
Population values come from long simulations (5,000 chains × 600 quarters for LP
coefficients; 300,000 histories for finite-shock responses).

**Smallest useful model (ledger notation).** The interacted projection

$$
y_{t+h}=\mu^{B}_h+(\mu^{A}_h-\mu^{B}_h)I_{t-1}
+\beta^{A}_h I_{t-1}s_t+\beta^{B}_h(1-I_{t-1})s_t
+\boldsymbol\gamma^{A\prime}_h I_{t-1}\mathbf w_t+\boldsymbol\gamma^{B\prime}_h(1-I_{t-1})\mathbf w_t+u_{t,h},
$$

and its multiplier form (L4). The outcome is $\sum_{j=0}^{h}y_{t+j}$ on
$I_{t-1}\sum_{j}g_{t+j}$ and $(1-I_{t-1})\sum_j g_{t+j}$, instrumented by
$I_{t-1}z_t$ and $(1-I_{t-1})z_t$, with coefficients $M^A_h$, $M^B_h$. In the two-state
economy $s_t$ is independent of the past, so $\beta^A_h$ is a population object
we can compute exactly or by long simulation and set beside three alternatives:

- the fixed-state response $\theta^{A,\mathrm{fix}}_h=\theta^A_0\rho_A^h$, where the economy is held in $A$;
- the initial-state response $\theta^{A,\mathrm{init}}_h=\theta^A_0\,[(\mathbf P\mathbf D_\rho)^h\mathbf 1]_A$, where the state evolves by its own chain ($\varpi=0$);
- the finite-shock response $\psi^A_h(e)=E[y_{t+h}\mid s_t=e,I_{t-1}=1]-E[y_{t+h}\mid s_t=0,I_{t-1}=1]$ for $\varpi>0$, a level as in L10, reported per unit as $\psi^A_h(e)/e$ (shock size $e$, ledger §6).

Every distinction in the lecture can be displayed in this model with two
parameters, $p_{AA}$ and $\varpi$.

**Dependency chain of sections** (spine order preserved; titles refined).

1. `#sec-l09-interacted-lp` — *The interacted local projection.* Interacting
   the shock, the intercept, and every control with $I_{t-1}$ gives two
   split-sample regressions in one. Omitting the main effect or the
   state-specific controls forces the two states to share an intercept or lag dynamics, and that
   contaminates $\beta^A_h-\beta^B_h$. The RZ state regressions and the joint model return
   identical point estimates (max difference 0 in the scratch run).
2. `#sec-l09-estimand` — *What a state coefficient estimates.*
   $\beta^A_h$ is a response conditional on $I_{t-1}=1$ that averages over the
   states the economy passes through after $t$. In the two-state economy at $h=8$ it
   equals $0.430$, against a fixed-state response of $0.646$. When the shock moves
   the state ($\varpi=1$), the per-unit response $\psi^A_8(e)/e$ depends on sign and size:
   $0.346$ for $e=+1$, $0.434$ for $e=-1$, $0.217$ for $e=+2$.
   This is the Gonçalves–Herrera–Kilian–Pesavento point.
3. `#sec-l09-support` — *Support: how many shocks, how large, and when.*
   In RZ, 29 of 107 nonzero news quarters fall in slack. Of the slack state's
   $\sum s_t^2$, 99.1 percent comes from 1940Q1–1945Q4, and weighted by $s_t^2$
   only 0.24 percent of slack-state shock variance comes from quarters still in
   slack eight quarters later. The slack-state first-stage $F$ is 2.03 at $h=0$.
4. `#sec-l09-direct-test` — *Testing the difference directly.* This is L6's
   curve-difference test (`#sec-l06-curve-differences`), the general result, applied to two
   states' coefficients, with the cross-state covariance in the role of the cross-curve one:
   $\operatorname{Var}(\hat M^A_h-\hat M^B_h)=\operatorname{Var}(\hat M^A_h)+\operatorname{Var}(\hat M^B_h)-2\operatorname{Cov}(\hat M^A_h,\hat M^B_h)$.
   The HAC covariance across states is not zero (correlation 0.26 at $h=0$, −0.19
   at $h=7$). At $h=0$ the separate bands overlap, yet the direct test gives
   $p=0.0437$; ignoring the covariance gives $p=0.0844$.
5. `#sec-l09-sign-asymmetry` — *Positive and negative shocks.* Splitting
   $s_t$ into $s^+_t$ and $s^-_t$ is the same algebra with a partition by the
   shock's own sign. In RZ the per-unit responses of $y$ differ (1.07 versus 4.38 at
   $h=8$, $p=0.015$), but the sign-specific multipliers do not (0.69 versus 0.61):
   negative news also moves spending more per unit. Negative news supplies 7.4
   percent of $\sum s_t^2$.
6. `#sec-l09-thresholds` — *Thresholds as labeled sensitivity.* Across seven
   state definitions and 21 horizons (147 tests), 12 reject equality at 5
   percent. All 12 are at $h\le3$, and all have a first-stage $F$ below 10 in at least one
   state. At the pre-specified $h=7$ and $h=15$, $p$ ranges from 0.23 to 0.95,
   while the slack multiplier at $h=7$ moves from 0.51 (6.0 percent) to 0.91 (7.0
   percent). Choosing the threshold after seeing results turns a sensitivity table
   into a specification search.
7. `#sec-l09-decomposition` — *Coefficients or composition.* Following the
   Jordà–Taylor response $\beta_h+\vartheta_h x_t$, a difference between two
   states' average responses splits into a coefficient part and a composition
   part $\vartheta_h(\bar x_1-\bar x_0)$. In Example 9 with a state defined by
   $x_{t-1}>0$, the naive state-dependent LP reports a difference of 0.99 at
   impact ($p<0.0001$), of which composition is 1.06 and coefficients −0.06.
8. `#sec-l09-evidence` — *Evidence: slack and non-slack multipliers.* REP09
   with the original 6.5 percent definition gives the full $h=0,\dots,20$ schedule, the
   direct test, and the support table. The published Table 1 columns are the
   code's $h=7$ and $h=15$. Short-horizon "differences" coincide with weak first stages;
   at the published horizons there is none.
9. `#sec-l09-summary` — *What a state-dependent response licenses.* Return to
   the slack question. The coefficient says what followed a marginal news shock that
   arrived when unemployment was high, in the episodes that supplied such shocks. It
   does not say what spending does in an economy kept in slack. Hand
   off to shock-size weighting.

**Central notation.** $y_t,s_t,\mathbf w_t,h,H,\beta_h,\mu_h,\boldsymbol\gamma_h,u_{t,h},T_h$ come from
§1 of the ledger; $B_h,\beta^Y_h,\beta^G_h,M_H$ from §2; $z_t$ from §3;
$\alpha,\operatorname{se}(\cdot),m,R,\rho$ from §4; and
$I_{t-1},\beta^A_h,\beta^B_h,s^+_t,s^-_t$ from §6. New in this lecture:
$\mu^A_h,\mu^B_h,\boldsymbol\gamma^A_h,\boldsymbol\gamma^B_h$;
$M^A_H,M^B_H$; $U_t$ and threshold $U^{*}$;
$\theta^{A,\mathrm{fix}}_h,\theta^{A,\mathrm{init}}_h$; $\theta^A_0,\theta^B_0$;
$\rho_A,\rho_B$; $p_{AA},p_{BA},\mathbf P,\mathbf D_\rho$; $\nu$; $\varpi$;
$\psi^A_h(e)$ (shock size $e$ as in ledger §6); $x_t,\vartheta_h,\bar x_g$. See §2.

**Glossary terms (owned keys only; one-line drafts in §3).** `state-dependence`,
`state-indicator`, `interacted-lp`, `main-effect`, `state-specific-control`,
`support`, `threshold`, `sign-asymmetry`, `fixed-state-experiment`,
`initial-state-response`, `endogenous-state`, `direct-difference-test`,
`kitagawa-oaxaca-blinder`, `specification-search`. No new keys (D22 not
triggered). Terms reused as prose with links to their owners: cumulative
multiplier, one-step and two-step multiplier, weak instrument, robust $F$
statistic (L4); common sample, small-sample bias, Monte Carlo simulation,
statistical reproduction (L2); HAC estimator, Newey–West, bandwidth, coverage
(L5); linear-combination test, curve-difference test, multiplicity, family-wise error rate (L6);
misspecification (L7). Forward references to marginal effect and causal weight (L10) appear in plain prose.

**Likely explanatory footnotes.**

- (i) "2-year integral" in RZ Table 1 is the code's `h==7`, eight quarters counting impact; "4-year" is `h==15`. The benchmark reproduces the published 0.60/0.59/.954 and 0.68/0.67/.924 at those rows.
- (ii) `ivreg2 …, robust bw(auto)` equals `ivregress 2sls …, vce(hac nwest opt)`, which chooses lag $=$ bandwidth $-1$. Coefficients, standard errors, and difference $p$-values agree to eight decimals at $h\in\{0,1,2,7,8,15,16,20\}$, so course code can use the built-in per D4. The same `opt` port reproduces REP04: in a 19.5 check without `ivreg2`, the linear one-step multipliers and s.e. match `REP04-linear-fiscal-multiplier.csv` at all 21 horizons (max absolute differences $3.2\times10^{-7}$ and $4.8\times10^{-8}$, at CSV precision), with selected lags 28 (27 at $h=11$–14), the values L4 copies into `rep04_bandwidths.csv`.
- (iii) The code's first-stage statistic is the Kleibergen–Paap rk Wald $F$ (`e(widstat)`), compared in the code with 23.1085. It is not the Montiel Olea–Pflueger effective $F$ plotted in RZ Figure 4.
- (iv) Why the state is dated $t-1$: it keeps $I_{t-1}$ predetermined relative to $s_t$. It does not keep it fixed after $t$.
- (v) With persistent $y$ and about 36 slack shocks per sample, $\hat\beta^A_8$ is biased downward by about 0.11 in the Monte Carlo (L2's small-sample bias).
- (vi) JT's Example 9 text writes $\gamma x_{t-1}$ where the code uses $x_t$. The code stores the horizon-$h$ estimate in row $h$, so $h=0$ is dropped and panel (a)'s "$R(0)$" is horizon 1.
- (vii) RZ's HP threshold uses $\lambda=10^6$ on split samples, which puts about half the quarters in slack (246 of 500 in the scratch run).

**Candidate figures** (TikZ/pgfplots via `figures/build.sh`, SVG and PDF from one
source; caption above; D24 applied).

| Label | Question it answers | Lesson visible | Generated from |
|---|---|---|---|
| `fig-l09-state-multipliers` | Do the two states' multipliers differ? | Top: $\hat M^A_h,\hat M^B_h$ with separate 95% bands, $h=0..20$. Bottom: $\hat M^A_h-\hat M^B_h$ with its joint-covariance band, shaded where either state's first-stage $F<10$. The only exclusions of zero sit in the shaded region. The caption states the horizon point: a difference can be read only at unshaded horizons, and none excludes zero there. | `REP09-state-dependent-fiscal.csv` plus `threshold_grid.csv` (joint s.e. and covariance) |
| `fig-l09-support` | Which episodes identify each state? | News shocks 1889–2015 as stems colored by $I_{t-1}$, slack shaded. The inset shows each state's cumulative share of $\sum s_t^2$: slack reaches 99 percent by 1945, non-slack is split between WWII and Korea. | `rzdat.xlsx` through `sta09_3_support.do` |
| `fig-l09-fixed-vs-initial` | Is the slack coefficient the effect of spending in an economy that stays slack? | $\theta^{A,\mathrm{fix}}_h$, $\theta^{A,\mathrm{init}}_h$, $\beta^A_h$ at $\varpi=1$, and the per-unit responses $\psi^A_h(+2)/2$ and $\psi^A_h(-2)/(-2)$, $h=0..20$. The curves separate after impact; $\psi^A_h(+2)/2$ lies below $\psi^A_h(-2)/(-2)$. | `l09_population_v2.json` (stored simulation result) |
| `fig-l09-threshold-sensitivity` | Does the verdict depend on where the line is drawn? | Slack and non-slack $\hat M_7$ and $\hat M_{15}$ across 5.5, 6.0, 6.5, 7.0, 7.5, 8.0 percent and HP, point size by first-stage $F$. A $p$-value strip is labeled "sensitivity, not selection". | `threshold_grid.csv` |
| `fig-l09-kob` *(droppable per D24; `tbl-l09-kob` carries the numbers)* | How much of a state difference is composition? | Stacked bars at $h=0,4,8,12$ | `kob_l09.log` |

**Exercise capabilities to test.**

- Write and count the interacted LP, and prove split-sample equivalence (LO1).
- Compute fixed-state and initial-state responses by hand (LO2).
- Replicate REP09 with built-ins (LO1, LO4).
- Build the support table and first-stage $F$ by state (LO3).
- Carry out the direct-test arithmetic and the band-overlap logic (LO4).
- Run the two-state Monte Carlo for coverage of two targets (LO2, LO3).
- Build the pre-registered threshold grid (LO4).
- Show that the sign-split multiplier equals an IV (LO4).
- Apply KOB to Example 9 with the storage fix (LO5).
- *Extra:* verify that the LP equals the $e^2\phi(e)$-weighted average of per-unit finite-shock responses $\psi^A_h(e)/e$ (LO2, handoff).

**Candidate controlled experiments** (State-Dependence Laboratory, §7):

1. $p_{AA}$ and $\rho_A-\rho_B$ against fixed-state and initial-state responses.
2. $\varpi$ and shock size $e$ and sign against $\psi^A_h(e)/e$ and $\beta^A_h$.
3. $\nu$, slack share, and $T$ against the sampling distribution, coverage of both targets, and power of the direct test, with draws held fixed.
4. Stored RZ results by horizon and threshold, with a covariance toggle.

**What this session deliberately postpones.**

- Regime-switching and smooth-transition VARs (Auerbach–Gorodnichenko estimation), and estimated thresholds: spine.
- Nonlinear GIRF estimation by simulation from an estimated model: GHKP's alternative, named only.
- Weak-instrument-robust (Anderson–Rubin) state-difference tests, beyond one footnote and the published AR $p$-values.
- The general theory of weights over shock sizes (L10).
- State dependence in panels (not covered in the course; further reading).

**Question handed to the next session.** The slack coefficient averaged over
the shocks each state happened to receive, and once the shock could move the
state, large and small shocks had different per-unit effects. If large shocks
and small shocks have different effects, what does one linear coefficient
measure?

---

## 2. Concept and notation ledger

Symbols already in the course ledger keep their meaning. Rows marked *new* are
this lecture's additions; none reassigns a reserved symbol. $\theta^A_0$ reuses
the causal-response letter for the true impact effect; $\vartheta_h$ avoids JT's
$\theta_h$ for their interaction coefficient, and the notes map it in one sentence (as D20 does for $b$).

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $s_t$, $z_t$, $g_t$ | RZ news `newsy` and real spending. In reduced-form LPs the news series is the intervention $s_t$, as in L1–L2 (ledger §6's $s^\pm_t$); in the multiplier form it is the instrument $z_t$, and spending $g_t$ is L4's $s_t$ | scalars | $t$ | news: share of lagged nominal potential GDP; $g$: ratio to potential GDP | `#sec-l09-interacted-lp` | `#sec-l09-sign-asymmetry`, `#sec-l09-evidence`, REP09 |
| $I_{t-1}$ | State indicator, 1 = slack ($U_{t-1}\ge U^{*}$) | scalar | dated $t-1$, predetermined for row $t$ | indicator | `#sec-l09-interacted-lp` | all sections |
| $U_t$, $U^{*}$ *(new)* | Unemployment rate; threshold defining slack | scalars | $U_{t-1}$ enters row $t$ | percent | `#sec-l09-interacted-lp` | `#sec-l09-thresholds` |
| $\mu^A_h,\mu^B_h$ *(new)* | State-specific intercepts (main effects) | scalars | per horizon | units of $y$ | `#sec-l09-interacted-lp` | exercise 1 |
| $\boldsymbol\gamma^A_h,\boldsymbol\gamma^B_h$ *(new)* | State-specific control coefficients | $p\cdot k\times1$ each | per horizon | nuisance | `#sec-l09-interacted-lp` | exercise 1, REP09 |
| $\beta^A_h,\beta^B_h$ | Responses in states $A$ and $B$ from the interacted LP | scalars | $s_t$ at $t$, $y$ at $t+h$ | units of $y$ per unit of $s$ | `#sec-l09-interacted-lp` | every section; L10 |
| $M^A_H,M^B_H$ *(new)* | State-specific one-step cumulative multipliers | scalars | cumulation $0..H$ | dollars of GDP per dollar of spending | `#sec-l09-interacted-lp` | `#sec-l09-direct-test`, `#sec-l09-evidence`, L13 |
| $\operatorname{Cov}(\hat M^A_H,\hat M^B_H)$ | Cross-state HAC covariance from the joint model | scalar | per $H$ | squared multiplier units | `#sec-l09-direct-test` | exercise 5, lab 4 |
| $s^+_t,s^-_t$ | $\max(s_t,0)$, $\min(s_t,0)$ | scalars | $t$ | units of $s$ | `#sec-l09-sign-asymmetry` | exercise 8, L10 |
| $\theta^A_0,\theta^B_0$ *(new)* | True impact effect in each state (simulation) | scalars | $h=0$ | units of $y$ per unit of $s$ | `#sec-l09-estimand` | labs 1–3 |
| $\rho_A,\rho_B$ *(new use of $\rho$)* | State-specific persistence of $y$ (simulation) | scalars | $t-1\to t$, governed by $I_{t-1}$ | none | `#sec-l09-estimand` | labs 1–3, STA09 |
| $\theta^{A,\mathrm{fix}}_h$ *(new)* | Fixed-state response, $\theta^A_0\rho_A^h$ | scalar | state held at $A$ over $t..t+h$ | units of $y$ | `#sec-l09-estimand` | figure, labs 1, 3 |
| $\theta^{A,\mathrm{init}}_h$ *(new)* | Initial-state response under an exogenous state chain | scalar | conditions on $I_{t-1}=1$ only | units of $y$ | `#sec-l09-estimand` | exercise 2, lab 1 |
| $p_{AA},p_{BA}$; $\mathbf P$ *(new)* | $\Pr(I_t=1\mid I_{t-1}=A\text{ or }B,s_t=0)$; transition matrix | scalars; $2\times2$ | $t-1\to t$ | probability | `#sec-l09-estimand` | `#sec-l09-support` (RZ 0.928, 0.041) |
| $\mathbf D_\rho$ *(new)* | $\operatorname{diag}(\rho_B,\rho_A)$ | $2\times2$ | — | — | `#sec-l09-estimand` | §6.2 |
| $\nu$ *(new)* | Probability a quarter carries a nonzero shock | scalar | per $t$ | probability | `#sec-l09-support` | lab 3 |
| $\varpi$ *(new; $\lambda$ stays L8's smoothing penalty, §10 Q5)* | State feedback: how much $s_t$ shifts $\Pr(I_t=1)$ | scalar | contemporaneous | probit index per unit of $s$ | `#sec-l09-estimand` | lab 2, exercise 10 |
| $\psi^A_h(e)$ *(new)* | Finite-shock response in state $A$, a level as in L10's $\psi_h(e)$: $E[y_{t+h}\mid s_t=e,I_{t-1}=1]-E[y_{t+h}\mid s_t=0,I_{t-1}=1]$; the per-unit response is $\psi^A_h(e)/e$ | scalar function of shock size $e$ (ledger §6) | conditions on $I_{t-1}$ | units of $y$; $\psi^A_h(e)/e$ in units of $y$ per unit of $s$ | `#sec-l09-estimand` | lab 2, exercise 10; L10 finite-shock-effect $[\psi_h(e')-\psi_h(e)]/(e'-e)$ |
| $x_t$, $\vartheta_h$ *(new)* | Secondary covariate; coefficient on $s_tx_t$ (JT's $\theta_h$) | scalars | $t$ | units of $y$ per unit $s$ per unit $x$ | `#sec-l09-decomposition` | exercise 9 |
| $\bar x_g$ *(new)* | $s_t^2$-weighted mean of $x_t$ among treated rows of group $g$ | scalar | sample | units of $x$ | `#sec-l09-decomposition` | `tbl-l09-kob` |

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition | First marked in |
|---|---|---|---|---|
| state dependence | glossary | `state-dependence` | A response that differs with a pre-shock condition of the economy. It is established only by a direct test of the difference, and it is interpreted only after support and the state's own response to the shock are examined. | `#sec-l09-interacted-lp` |
| state indicator | glossary | `state-indicator` | A predetermined variable, usually binary and dated $t-1$, that assigns each regression row to a state. Dating it before the shock makes it predetermined but does not keep the economy in that state afterward. | `#sec-l09-interacted-lp` |
| interacted LP | glossary | `interacted-lp` | A local projection in which the intercept, the shock, and the controls are each multiplied by the state indicator and its complement. Its point estimates equal those of two split-sample regressions, and pooling adds a joint covariance across states. | `#sec-l09-interacted-lp` |
| main effect | glossary | `main-effect` | The uninteracted state term (the intercept shift $\mu^A_h-\mu^B_h$). Omitting it forces both states to share a mean outcome, so any level difference loads onto the shock interaction. | `#sec-l09-interacted-lp` |
| state-specific control | glossary | `state-specific-control` | A control interacted with the state indicator so that lag dynamics may differ across states. Without it, the difference between state responses absorbs differences in propagation of pre-shock conditions. | `#sec-l09-interacted-lp` |
| support | glossary | `support` | The shocks that actually inform an estimate: how many, how large, of which sign, and in which episodes. A state with few or clustered shocks identifies a response only for those episodes. | `#sec-l09-support` |
| threshold | glossary | `threshold` | The cutoff $U^{*}$ that maps a continuous variable into a state indicator. It is a specification choice to be fixed in advance, and alternatives are reported as labeled sensitivity. | `#sec-l09-thresholds` |
| sign asymmetry | glossary | `sign-asymmetry` | A difference between the responses to positive and negative shocks, estimated by entering $s^+_t$ and $s^-_t$ separately. A difference in per-unit responses need not be a difference in multipliers. | `#sec-l09-sign-asymmetry` |
| fixed-state experiment | glossary | `fixed-state-experiment` | A counterfactual in which the economy is held in one state for the whole horizon. A state-interacted LP does not estimate it unless the state cannot change. | `#sec-l09-estimand` |
| initial-state response | glossary | `initial-state-response` | The average response conditional on the state just before the shock, averaging over whatever states follow. This is the estimand of an interacted LP with a predetermined indicator. | `#sec-l09-estimand` |
| endogenous state | glossary | `endogenous-state` | A state whose future values respond to the shock being studied. Then the response depends on the shock's sign and size, and the coefficient is best read as a small-shock average. | `#sec-l09-estimand` |
| direct difference test | glossary | `direct-difference-test` | A Wald test of $\beta^A_h=\beta^B_h$ (or $M^A_H=M^B_H$) using the joint covariance of both estimates: L6's curve-difference test applied across states, with the cross-state covariance. Non-overlapping bands imply rejection, but overlapping bands are not evidence of equality. | `#sec-l09-direct-test` |
| Kitagawa–Oaxaca–Blinder decomposition | glossary | `kitagawa-oaxaca-blinder` | The split of a difference in group-average responses into a part due to different coefficients and a part due to different covariate composition. For dynamic responses it is partial equilibrium, because covariates keep moving after the shock. | `#sec-l09-decomposition` |
| specification search | glossary | `specification-search` | Choosing a state definition, horizon, or sign split after seeing which one yields a preferred result. It invalidates the nominal size of the reported test. | `#sec-l09-thresholds` |
| 2-year integral | footnote | — | RZ's label for the cumulative multiplier through code horizon $h=7$ | `#sec-l09-evidence` |
| Kleibergen–Paap rk Wald $F$ | footnote | — | The code's `e(widstat)` HAC first-stage statistic, distinct from the effective $F$ | `#sec-l09-support` |
| `bw(auto)` / `hac nwest opt` | footnote | — | Newey–West automatic lag; the built-in equals `ivreg2` | `#sec-l09-direct-test` |

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| Published Table 1 military-news columns are code $h=7$ and $h=15$ | Benchmark $h=7$: slack 0.6028659 (0.0947127), non-slack 0.5949385 (0.0909187), $p=0.9539886$; $h=15$: 0.6819684 (0.0517369), 0.6683413 (0.1214891), $p=0.9244053$; linear 0.6637145 (0.067114) and 0.7133608 (0.0435753); paper .60/.59/.954, .68/.67/.924, .66, .71 | table + footnote | REP09 and REP04 CSVs; `design-04/paper/rz_jpe.txt` Table 1 | benchmark | `tbl-l09-evidence` |
| Interacted = split-sample point estimates | Joint minus separate: 0 at all 21 horizons, both states | derivation + numeric check | `threshold_grid.csv` | computed | `eq-l09-split-equivalence` |
| Overlap is not a test | $h=0$: bands [0.368, 2.118] and [−2.522, 1.304]; direct $p=0.0437$; independence $p=0.0844$ | worked example | `threshold_grid.csv`, §6.4 | computed | `tbl-l09-direct-test` |
| Short-horizon differences sit where instruments are weak | $p<0.05$ at $h=0..3$ only; $F$ (slack, non-slack) $=$ (2.03, 3.35), (2.30, 3.66), (32.3, 4.74), (103.4, 6.14) | figure | `junk.csv`, benchmark | to build | `fig-l09-state-multipliers` |
| Slack identification is WWII | 29/107 nonzero quarters; slack share of $\sum s^2$ 0.3905; 1940–45 share of slack $\sum s^2$ 0.9906; 1950–53 share of non-slack 0.4725 | figure + table | `rz_l09.log` | to build | `fig-l09-support`, `tbl-l09-support` |
| The state responds to the shock in RZ | Slack-state unemployment response to news of 1% of GDP: −0.112 pp at $h=8$ (0.026); slack probability −0.0115 (0.0049) | table row + prose | `rz_l09.log` | computed | `tbl-l09-support` |
| Shocks that identify slack were followed by exit from slack | Share still slack at $t+8$: 0.542 of slack rows; 0.0024 when weighted by $s_t^2$ | prose | `rz_l09.log` | computed | `#sec-l09-support` |
| Initial-state ≠ fixed-state | $h=8$: fixed 0.6457, initial (closed form) 0.4300, LP population 0.4285 ($\varpi=0$) | figure + exercise | `l09_population_v2.json`, §6.2 | stored simulation result | `fig-l09-fixed-vs-initial` |
| Endogenous state creates sign and size dependence | $\varpi=1$, $h=8$, per-unit $\psi^A_8(e)/e$: 0.3459 ($e=+1$), 0.4344 ($e=-1$), 0.2166 ($e=+2$), 0.4323 ($e=-2$); LP 0.3484 | figure + lab 2 | same | stored simulation result | `fig-l09-fixed-vs-initial` |
| Bands cover the initial-state target, not the fixed-state one | $T=500$, $R=200$, $h=8$: coverage 0.885 (initial) and 0.740 (fixed) at $\varpi=0$; 0.865 and 0.700 at $\varpi=1$ | lab 3 + exercise 6 | Python MC in `l09_states_v2.py` | stored simulation result | lab 3 |
| Low power with realistic support | Rejection of equality at $h=8$: 0.15 ($\varpi=0$), true gap 0.40; mean 36.1 slack shocks per sample, 5th percentile 20 | lab 3 | same; Stata prototype 0.175 | stored simulation result | lab 3 |
| Threshold grid | 147 tests, 12 rejections, all $h\le3$, all with min $F<10$; $h=7$ slack multiplier 0.508–0.909; RZ Table 2 reproduced (8%: .80/.60, .76/.65; HP: .52/.66, .56/.75) | figure + table | `threshold_grid.csv` | to build | `fig-l09-threshold-sensitivity`, `tbl-l09-thresholds` |
| Response asymmetry without multiplier asymmetry | $h=8$: $y$ 1.072 (0.254) versus 4.380 (1.285), $p=0.0152$; $g$ 1.544 versus 7.168, $p=0.0065$; multipliers 0.6943 (0.0732, $F$ 10.4) versus 0.6111 (0.0637, $F$ 13.5) | table | `rz_l09.log`, `sign_iv.log` | computed | `tbl-l09-sign` |
| KOB separates composition | $h=0$: naive 0.9855; 0.9932 $=$ −0.0624 $+$ 1.0555; $h=8$: 1.3274 $=$ 0.8271 $+$ 0.5004 | table | `kob_l09.log` | computed | `tbl-l09-kob` |

## 5. Assessment map

Ten exercises: five Stata computational (three on RZ data), four pencil, one extra.

| LO | Exercise | Tags | Mode of work | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. Two regressions in one | [core] [pencil] | Write the interacted LP for $p=1$; count parameters; show by Frisch–Waugh–Lovell that block-separable regressors give split-sample $\hat\beta^A_h,\hat\beta^B_h$; say what dropping $I_{t-1}$ or $\boldsymbol\gamma^A_h$ imposes | Ask what the residualized $I_{t-1}s_t$ equals in non-slack rows | Residual is zero in $B$ rows; RZ run: joint minus separate $=0$ at 21 horizons | 4 |
| 2 | 2. Held in slack, or starting in slack? | [core] [pencil] | With $\theta^A_0=1.5,\rho_A=0.9,\rho_B=0.6,p_{AA}=0.93,p_{BA}=0.04$, compute $\theta^{A,\mathrm{fix}}_h$ and $\theta^{A,\mathrm{init}}_h$ for $h=0,1,2$; state two conditions for equality | Carry the vector $(\mathbf P\mathbf D_\rho)^h\mathbf 1$, not a scalar | 1.5, 1.35, 1.215 versus 1.5, 1.3185, 1.14214; equal iff $\rho_A=\rho_B$ or $p_{AA}=1$ | 1 |
| 1, 4 | 3. REP09 with built-ins (Stata) | [core] [computational] [data] | `ivregress 2sls` with state-interacted controls and `vce(hac nwest opt)` for $h=0..20$; separate and joint models; export | Point to jordagk lines 448–462 and the control list at 187 | `assert` $\lvert\cdot\rvert<10^{-6}$ against `REP09-state-dependent-fiscal.csv` for multipliers, s.e., $p$ | 4 |
| 3 | 4. Who identifies the slack multiplier? (Stata) | [core] [computational] [data] | Support table: quarters, nonzero shocks by sign, $\sum s_t^2$ shares, top 10 episodes, first-stage $F$ by state and horizon; state response of $U$ and $I$ to news | Suggest sorting by $s_t^2$ before reading means | 181/319 quarters; 29/78 shocks; shares 0.3905 and 0.9906; $F$ from `junk.csv` | 4 |
| 4 | 5. Overlap is not a test | [core] [pencil] | From $\hat M^A_0,\hat M^B_0$, joint s.e. and covariance, compute the Wald $p$; show non-overlap ⇒ rejection using $\lvert\operatorname{corr}\rvert\le1$; give an overlapping-but-rejecting case | Write $(\operatorname{se}_A+\operatorname{se}_B)^2$ beside $\operatorname{Var}(\hat M^A-\hat M^B)$ | $p=0.0436692$; independence $p=0.0844$ | 4 |
| 2, 3 | 6. Coverage of which target? (Stata) | [core] [computational] | Two-state Monte Carlo, $R=200$ (D2), $\varpi\in\{0,1\}$, $h\in\{0,4,8\}$: mean, sd, coverage of $\theta^{A,\mathrm{init}}_8$ and $\theta^{A,\mathrm{fix}}_8$, rejection of equality | Name the two targets before simulating | Runtime ≈17 s; coverage of initial target near 0.9, fixed-state near 0.7; mean within 3 MC s.e. of the stored values (§6.3) | 3 |
| 4 | 7. A pre-registered threshold grid (Stata) | [computational] [data] | Write `threshold_prereg.txt` (definitions 5.5–8.0, 8%, HP; horizons 7, 15) before estimating; run 147 cells; classify rejections by first-stage $F$ | Ask which cells were chosen before seeing results | 12 rejections, all $h\le3$, all min $F<10$; Table 2 (8%, HP) reproduced to two decimals | 4 |
| 4 | 8. Asymmetric responses, symmetric multipliers | [pencil] | Given the $h=8$ reduced forms for $y$ and $g$ by sign, compute both ratios; prove each equals IV with the other part as a control; explain why the $y$ test rejects and the multipliers agree | Recall L4's common-sample ratio argument | 0.69426 and 0.61110; IV equality to $10^{-7}$ | — |
| 5 | 9. Coefficients or composition (Stata) | [computational] | Run JT `kob_sim.do` with corrected storage; define $S_{t-1}=\mathbb 1(x_{t-1}>0)$; naive state LP versus two-fold KOB at $h=0,4,8,12$; log the storage offset | Separate "who is treated" from "how treatment works" | $h=0$: 0.9932 $=-0.0624+1.0555$; $b_0=0.5330$ | 5 |
| 2 | 10. What the coefficient averages | [extra] [computational] | In the $\varpi=1$ economy compute $\psi^A_8(e)$ on a grid of shock sizes $e$ and verify $\beta^A_8=\int e^2\phi(e)\,[\psi^A_8(e)/e]\,de=\int e\,\phi(e)\,\psi^A_8(e)\,de$ | Subtract $E[y_{t+8}\mid s_t=0]$ first, using $E[s_t]=0$ | 0.3542 versus 0.3484 within simulation error | 2 |

Each outcome has two media: LO1 (equation, exercises 1, 3, lab 4); LO2
(figure `fixed-vs-initial`, exercises 2, 6, 10, labs 1–3); LO3 (figure `support`,
exercise 4, lab 3); LO4 (figures `state-multipliers`, `threshold-sensitivity`,
exercises 5, 7, 8, lab 4); LO5 (table `kob`, exercise 9, lab 5, interpretation record).

## 6. Derivations to verify

**6.1 Split-sample equivalence** (`eq-l09-split-equivalence`). *Source identity:*
FWL (L3). *Steps:* (a) the regressors $\{1,I_{t-1}\}$, $\{I_{t-1}\mathbf w_t\}$,
$\{(1-I_{t-1})\mathbf w_t\}$ span state-specific intercepts and controls, so the
projection of $I_{t-1}s_t$ on them fits $s_t$ within $A$ rows and returns exactly
0 in $B$ rows; (b) its residual is $I_{t-1}\tilde s^{A}_t$, zero in $B$; (c) the
coefficient is therefore $\sum_{A}\tilde s^A_t y_{t+h}/\sum_A(\tilde s^A_t)^2$,
the split-sample estimate; (d) for 2SLS the same argument applies to instrument
and regressor. *Check:* RZ joint versus separate, max $\lvert\Delta\rvert=0$ for
both states at $h=0..20$; standard errors differ ($h=7$ slack 0.0947127 separate,
0.087281 joint) because the HAC score and automatic bandwidth are computed from different moment sets.

**6.2 Fixed-state and initial-state responses** (`eq-l09-initial-state`). *Source:*
the simulation DGP with $\varpi=0$. *Steps:* (a) iterate
$y_{t+h}=\theta^{I_{t-1}}_0\prod_{j=0}^{h-1}\rho_{I_{t+j}}\,s_t+(\text{terms without }s_t)$;
(b) with the chain independent of $s_t$, $\beta^A_h=E[s_ty_{t+h}\mid I_{t-1}=1]/E[s_t^2]=\theta^A_0E[\prod_j\rho_{I_{t+j}}\mid I_{t-1}=1]$;
(c) define $v_h(i)=E[\prod_{j=0}^{h-1}\rho_{I_{t+j}}\mid I_{t-1}=i]$, condition on
$I_t$: $v_h(i)=\sum_k P_{ik}\rho_kv_{h-1}(k)$, so $\mathbf v_h=(\mathbf P\mathbf D_\rho)^h\mathbf 1$;
(d) holding $I\equiv A$ gives $\theta^A_0\rho_A^h$. *Exact inputs:*
$\mathbf P=\begin{psmallmatrix}0.96&0.04\\0.07&0.93\end{psmallmatrix}$ (rows $B,A$), $\mathbf D_\rho=\operatorname{diag}(0.6,0.9)$.
*Full precision:* $v_1(A)=0.93(0.9)+0.07(0.6)=0.879$; $v_1(B)=0.04(0.9)+0.96(0.6)=0.612$;
$v_2(A)=0.93(0.9)(0.879)+0.07(0.6)(0.612)=0.761427$. So $\theta^{A,\mathrm{init}}_{0,1,2}=1.5,\ 1.3185,\ 1.1421405$;
$\theta^{A,\mathrm{fix}}_{0,1,2}=1.5,\ 1.35,\ 1.215$; at $h=8$, 0.4300 versus
$1.5(0.9)^8=0.6457008$; state $B$: 0.5, 0.306, 0.1921. *Check:* long-simulation LP
coefficient 0.4285 at $h=8$ (0.8307 at $h=4$ versus 0.8361).

**6.3 Endogenous state as a weighted average** (`eq-l09-shock-weights`). *Source:*
$E[s_t\mid\text{past}]=0$ and $s_t$ independent of the past. *Steps:* (a)
$\beta^A_h=E[s_ty_{t+h}\mid I_{t-1}=1]/E[s_t^2]$; (b) subtract
$E[y_{t+h}\mid s_t=0,I_{t-1}=1]$ inside the expectation (it is uncorrelated with
$s_t$); (c) condition on $s_t=e$: $\beta^A_h=E[s_t\psi^A_h(s_t)]/E[s_t^2]$, with $\psi^A_h(e)$ the level of §2.
With $E[s_t]=0$ this is $\operatorname{Cov}(\psi^A_h(s_t),s_t)/\operatorname{Var}(s_t)$, which equals L10's weighted
average of marginal effects $\int\omega_h(e)\,\theta_h(e)\,de$ with $\theta_h(e)=\psi^{A\prime}_h(e)$;
(d) zero shocks drop out; in per-unit form $\beta^A_h=E[s_t^2\,\psi^A_h(s_t)/s_t]/E[s_t^2]$, with weights
$e^2\phi(e)$ on $\psi^A_h(e)/e$. *Check ($\varpi=1$):* grid of 32 $e\in[-4,4]$, 150,000 histories each:
weighted per-unit response 0.7224 at $h=4$ and 0.3542 at $h=8$ versus LP 0.7157, 0.3484. Monte Carlo means for
exercise 6 (Python, seed 9): $\varpi=0$, $h=8$: 0.316 (sd 0.355); $\varpi=1$: 0.356
(0.351); Stata prototype (different generator): 0.339 (0.354) and 0.268 (0.331),
17.0 s. The $\varpi=1$ gap is 2.6 Monte Carlo s.e.; assertions use 3.

**6.4 Direct test and band overlap** (`eq-l09-direct-test`). *Source:* Wald test of
a linear combination (L6). *Steps and exact inputs ($h=0$, joint model):*
$\hat M^B_0-\hat M^A_0=1.243312-(-0.608974)=1.852286$;
$\operatorname{Var}=0.446488^2+0.927454^2-2(0.108195)=0.843132$; s.e. $0.918222$;
$z=2.01725$; $p=0.0436692$, matching the benchmark to $10^{-7}$. Ignoring the covariance
and using the separate s.e. (0.446488, 0.976001): s.e. $1.073280$, $z=1.72582$, $p=0.08438$.
*Band lemma:* $\operatorname{Cov}\ge-\operatorname{se}_A\operatorname{se}_B$ implies
$\operatorname{Var}(\hat M^A-\hat M^B)\le(\operatorname{se}_A+\operatorname{se}_B)^2$, so
$\lvert d\rvert>1.96(\operatorname{se}_A+\operatorname{se}_B)$ implies $\lvert z\rvert>1.96$; the converse fails,
as at $h=0$. $h=7$: $d=-0.007927$, variance 0.018877, $p=0.9539886$.

**6.5 Sign-specific multiplier as IV.** *Source:* L4's common-sample
ratio (D11). *Steps:* both reduced forms share regressors and sample, so by FWL
$\hat b^Y_+/\hat b^G_+$ is the just-identified IV of $\sum y$ on $\sum g$ with
instrument $s^+_t$ and $s^-_t$ as control. *Check, $h=8$:* $1.07218/1.54436=0.69426$;
IV 0.6942575 (s.e. 0.073158, $F$ 10.39); negative 0.6111041 (0.063728, 13.53);
linear 0.6689613.

**6.6 Two-fold KOB identity** (`eq-l09-kob`). *Source:* add and subtract
$\vartheta_{1,h}\bar x_0$. *Steps:* $\bar R_g=\beta_{g,h}+\vartheta_{g,h}\bar x_g$;
$\bar R_1-\bar R_0=[(\beta_{1,h}-\beta_{0,h})+(\vartheta_{1,h}-\vartheta_{0,h})\bar x_0]+\vartheta_{1,h}(\bar x_1-\bar x_0)$.
*Check, $h=0$:* $\beta_1=0.4981,\beta_0=0.6027,\vartheta_1=0.5226,\vartheta_0=0.5676,\bar x_1=1.0841,\bar x_0=-0.9357$;
$\bar R_1=1.0647$, $\bar R_0=0.0715$; coefficient $-0.0624$, composition 1.0555. The naive
interacted LP gives 0.9855 (common controls). At $h=8$, 1.3274 $=$ 0.8271 $+$ 0.5004: the
"coefficient" part grows because $x$ keeps evolving after $t$, which is JT's partial-equilibrium caveat.

**6.7 First-stage $F$ with built-ins.** $F_{\mathrm{KP}}=t^2_{\text{ivregress}}\times(N-k)/N$ with lag $=$ `e(bw)`$-1$ from the
single-state model, which without `ivreg2` is `e(hac_lag)` of the single-state `ivregress 2sls …, vce(hac nwest opt)`
fit (14 at $h=0$, 21 at $h=7$; checked in 19.5, reproducing both values below): $h=0$: $2.1412\times473/500=2.0256$ (code 2.025596); $h=7$:
$426.6471\times466/493=403.281$ (403.281). Automatic lag selection in the built-in
gives 1.888 at $h=0$, so the benchmark $F$ comes from `junk.csv`.

## 7. HTML lab plan (State-Dependence Laboratory, `interactives/09-state-dependence-lab.qmd`)

Five Observable JS labs in chain order. Each has a setup paragraph, **Predict before
using the controls**, unit-labeled controls with reset, a plot, a reactive
sentence, controlled comparisons, and a collapsed explanation. Draws come from
`mulberry32` with a visible seed, so toggles never redraw unless the screen says
so. Every panel is labeled live calculation, stored simulation result, or stored
result (D30).

**Lab 1 — Starting in slack or staying in slack (live, closed form).**
*Question:* when does the initial-state response equal the fixed-state response?
*Invariants:* $\varpi=0$; population objects only. *Controls:* $p_{AA}\in[0.5,1]$
(0.93), $p_{BA}\in[0,0.5]$ (0.04), $\rho_A$ (0.9), $\rho_B$ (0.6), $\theta^A_0$ (1.5),
$\theta^B_0$ (0.5; units of $y$ per unit $s$), $H\in\{8,12,20\}$ (20).
*Computation:* $\theta^{A,\mathrm{fix}}_h$, $\theta^{A,\mathrm{init}}_h$ by §6.2. *Sentence:* "At
$h=8$ an economy that starts in slack responds 0.430, two-thirds of the 0.646 it
would show if kept in slack; the gap closes only when $p_{AA}=1$ or $\rho_A=\rho_B$."
*Comparisons:* $p_{AA}\to1$; $\rho_B\to\rho_A$; $p_{BA}\to0$. *Prediction:* "With slack
lasting 14 quarters on average, is the $h=8$ response nearer the fixed-state value
or the non-slack value?"

**Lab 2 — When the shock moves the state (live simulation).** *Question:* does
the slack coefficient describe a large or a negative shock? *Invariants:* 40,000
histories drawn once from the stationary distribution given $I_{t-1}=1$; common
random numbers across $e$ and $\varpi$. *Controls:* $\varpi\in[0,2]$ (1; probit
index per unit $s$), shock size $e\in\{\pm0.5,\pm1,\pm2\}$ (+2), $h\in0..20$ (8).
*Computation:* the level $\psi^A_h(e)$ and the per-unit response $\psi^A_h(e)/e$, the LP
coefficient from one 200,000-quarter chain, and the $e^2\phi(e)$ weights on $\psi^A_h(e)/e$;
simulation error (±0.01) is displayed. *Sentence:* "With $\varpi=1$, a +2 shock raises
$y_{t+8}$ by 0.22 per unit and a −2 shock lowers it by 0.43 per unit; the slack coefficient,
0.35, averages per-unit responses with weight $e^2\phi(e)$."
*Comparisons:* $\varpi=0$ (symmetry returns); flip the sign; shrink $e$.
*Handoff:* $\varpi$, grid, $\psi^A_h(e)$ table, seed → exercise 10.

**Lab 3 — Support and the sampling distribution (live Monte Carlo).**
*Question:* with RZ-like support, how often does the slack band cover each
target, and how often is a true difference detected? *Invariants:* $R=200$; for each
seed and replication, $\epsilon_t$, $v_t$, an arrival uniform $U^\zeta_t$ and a transition uniform
$U^I_t$ are drawn once for $T_{\max}=1000$ plus 200 burn-in quarters; $\zeta_t=\mathbb 1\{U^\zeta_t<\nu\}$
and $I_t=\mathbb 1\{U^I_t<\Phi(\Phi^{-1}(p_{iA})-\varpi s_t)\}$ with $i=I_{t-1}$; $y$ is rebuilt for
the chosen parameters and the first $T$ kept rows are used. Parameters and $T$ rebuild paths
from the same draws, and the $h$ toggle never redraws.
*Controls:* $\nu\in\{0.1,0.2,0.4\}$, $p_{AA}\in\{0.8,0.93,0.98\}$, $T\in\{250,500,1000\}$
quarters, $\varpi\in\{0,1\}$, $h\in\{0,4,8\}$. *Computation:* interacted OLS with
Newey–West ($m=h+1$) in JS; histograms of $\hat\beta^A_h$ with both targets marked;
count of slack shocks; coverage; rejection rate. A side panel shows the stored Python
result (seed 9: coverage 0.885/0.740, rejection 0.15). *Sentence:* "In these 200
samples the slack state saw 36 shocks on average (fewest 10); the band covered the
initial-state response 89 percent of the time and the fixed-state response 74
percent; a true gap of 0.40 was detected in 15 percent." *Comparisons:* $\nu$ 0.2→0.4;
$T$ 500→1000; $\varpi$ 0→1. *Handoff:* state-process record
($\theta_0,\rho,p_{AA},p_{BA},\nu,\varpi,T,R$, seed) plus a one-line hypothesis →
STA09 task 6.

**Lab 4 — Reading the RZ evidence (stored result).** *Question:* which RZ
differences survive a direct test with adequate first stages? *Controls:*
horizon 0–20 (7); state definition (seven; 6.5 percent); covariance toggle
(joint / ignored); $F=10$ reference line. *Computation:* reads `threshold_grid.json`
(147 rows; metadata: jordagk.do date, RZDAT SHA-256, Stata 19.5, built-in `ivregress 2sls, vce(hac nwest opt)` (D4));
$z$ and $p$ recomputed live from stored s.e. and covariance. *Sentence:* "At $h=0$
with 6.5 percent the bands overlap, the direct test gives $p=0.044$, and the slack
first stage has $F=2.0$: neither the overlap nor the rejection is informative."
*Comparisons:* covariance toggle at $h=0$; $h$ 0→7; 6.5→7.0 at $h=7$. *Prediction:*
"At $h=7$, will any definition give $p<0.10$?" *Handoff:* specification record →
STA09 task 4.

**Lab 5 — Coefficients or composition (live).** *Question:* is a state difference a
different response or a different mix of conditions? *Invariants:* JT's DGP,
$T=500$, JS draws (labeled: not Stata's seed-12345 stream). *Controls:* $\vartheta$
(0.5), $\rho_x\in\{0,0.75,0.95\}$, split point $c$ for $x_{t-1}>c$ (0), $h\in\{0,4,8\}$.
*Computation:* naive state LP and two-fold KOB. *Sentence:* "The naive state
difference at $h=0$ is 0.99, and composition accounts for 1.06 of it; set
$\vartheta=0$ and it disappears." *Handoff:* exercise 9 on Stata's own draws.

## 8. Practicum plan (REP09, STA09, HTML09 handoff)

### 8.1 REP09 — Fiscal responses across states

**Target (D12).** An exact numerical replication of Ramey and Zubairy (2018), *JPE*
126(2), 850–901 (published version; `VERIFIED.md` R05): Table 1, military-news
row, high- and low-unemployment one-step cumulative multipliers with the HAC
$p$-value for their difference ("2-year" $=$ code $h=7$; "4-year" $=h=15$). It also covers
the full schedule $h=0..20$ with HAC s.e., $N$, and the 21 direct-test $p$-values.

**Package, data, lines.** Supplied February 2018 package; `jordagk.do` dated
February 24, 2018, unmodified; `RZDAT.xlsx` sheet `rzdat`, April 7, 2016 update,
SHA-256 `b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120`. Code lines:

- parameters 29–41 (`state slack` 33);
- state 75 (alternatives 76–77);
- normalization 90–107;
- state-split cumulated spending 135–136;
- shock interactions 150–151;
- state lag controls 175–176, list 187;
- state IRFs 259–291 and 338–352;
- state multipliers 448–458;
- joint test 460–462;
- first-stage $F$ export 489;
- CSV 500.

**Benchmark** (`REP09-state-dependent-fiscal.csv`; tolerance $10^{-6}$ absolute, $N$ exact):

| $h$ | Non-slack $M^B_h$ (s.e.) | Slack $M^A_h$ (s.e.) | $p$ | $N$ | $F$ non-slack / slack |
|---|---|---|---|---|---|
| 0 | 1.243312 (0.4464884) | −0.6089739 (0.9760011) | 0.0436692 | 500 | 3.35 / 2.03 |
| 2 | 0.8859406 (0.1926358) | −0.1744422 (0.251903) | 2.16e−05 | 498 | 4.74 / 32.29 |
| 7 | 0.5949385 (0.0909187) | 0.6028659 (0.0947127) | 0.9539886 | 493 | 8.37 / 403.28 |
| 15 | 0.6683413 (0.1214891) | 0.6819684 (0.0517369) | 0.9244053 | 485 | 10.85 / 130.20 |
| 20 | 0.6572446 (0.1756467) | 0.713527 (0.0501407) | 0.7714522 | 480 | 10.67 / 61.91 |

**Runtime and software (D1).** 18.5: 9.466 s. 19.5 rerun: 8.9 s, max absolute
difference 0, so there is no software row. The course's built-in port (§6.1, footnote ii)
agrees with the benchmark to $<10^{-6}$ (threshold-grid run, 24.6 s for 147 cells × 3 models).

**Departures and discrepancy log.**

- (i) The course port uses `ivregress 2sls, vce(hac nwest opt)` (D4).
- (ii) The support table, joint covariance, threshold grid, and sign split are instructional additions, labeled.
- (iii) RZ's MATLAB Figures 5–6 are not reproduced; the course figure is labeled.
- (iv) Anderson–Rubin $p$-values (`jordagk_ar.do`) are not run (§10).
- (v) Presentation rows: the Table 1 horizon labels; Table 1 standard errors come from the separate models while its $p$-value comes from the joint model.
- (vi) JT Example 9: horizon storage offset; the text writes $x_{t-1}$ where the code uses $x_t$; the stated "impact ≈0.75" is the $h=1$ estimate (0.7188).

**Redistribution (D5).** Ramey–Zubairy has no explicit license, so the project
ships `data/raw/get_data.do`. It fetches the author archive (URL in
`packages/ramey-zubairy/SOURCE.md`), verifies the SHA-256 above, saves
`rzdat.xlsx` (lowercase, as the do-file expects), and stops with a clear
message on failure. `PROVENANCE.md` gives the manual route from the author page.
`jordagk.do` is acquired the same way. JEL-Code `kob_sim.do` (CC0) ships.
Simulated draws are generated by student code; `twostate_draw1.dta` (seed 9,
replication 1) ships.

### 8.2 STA09 — Stata problem set

Variables follow the ledger: `y g s z I_lag cumy_h cumg_h cumgA_h cumgB_h zA zB`.

1. *Estimate interacted LPs with main effects and controls.*
   `sta09_1_interacted.do` builds state IRFs of $y$ and $g$ and the one-step state
   multipliers, separate and joint, for $h=0..20$. Assertions: separate equals joint
   point estimates to $10^{-10}$; multipliers, s.e., $p$ equal the benchmark to $10^{-6}$; $N=500-h$.
2. *Calculate state-specific responses and test their difference directly.*
   `sta09_2_direct_test.do` uses `lincom`, `test`, and `e(V)` and writes `direct_test.csv` (`h d se_d
   cov corr p p_indep overlap`). Assertions: $p_0=0.0436692$; every non-overlapping
   row has $p<0.05$.
3. *Report shock distributions and support.* `sta09_3_support.do` writes
   `support.csv` and `fig_support.pdf`: counts by state and sign, $\sum s^2$ shares,
   top episodes, first-stage $F$ by §6.7 with built-ins (the default; `ivreg2`'s
   `e(widstat)` is an optional check, D4), and leads of $U$ and `I_lag` on
   $s$. Assertions: 181/319; 29/78; 0.3905 and 0.9906 to $10^{-4}$.
4. *Alternative thresholds as labeled sensitivity.* `sta09_4_thresholds.do`
   first asserts that `threshold_prereg.txt` exists and names $h=7,15$, then loops
   the seven definitions and writes `thresholds.csv`. Assertions: the 6.5 rows equal the benchmark;
   RZ Table 2 (8 percent, HP) at $h=7,15$ to 0.005.
5. *Why a selected threshold compromises interpretation.* Structured comments
   and the interpretation record cover the 147 tests and 12 rejections, their
   location at weak first stages, and the claims that survive pre-specification.
6. *Lab handoff.* `sta09_6_state_process.do` reads Lab 3's `state_process.csv`
   and runs the Monte Carlo (`global R 200`), writing `mc_state.csv`. It asserts
   agreement with the stored summary within 3 Monte Carlo s.e.; the student's
   hypothesis is judged in comments.

Starter `lab-project/`: `master.do`, `code/`, `data/raw/get_data.do`,
`data/sim/`, `tests/test_rep09.do`, `tests/test_support.do`, `output/`,
`PROVENANCE.md`. Target runtime under 3 minutes (measured pieces: 8.9 s, 24.6 s, 17.0 s).

### 8.3 Handoff and submission

Lab 2 feeds exercise 10, Lab 3 task 6, Lab 4 task 4, Lab 5 exercise 9. Stored
RZ results use identical inputs; simulations are compared within Monte Carlo error because
generators differ. The submission follows blueprint §4.2:

- **Replication record:** target, lines, SHA-256, comparison table, discrepancy rows.
- **Stata submission:** `master.do`, logs, CSVs, figures, test logs.
- **Interpretation record:** the initial-state estimand, identification, units, support, direct test, what is not claimed.
- **HTML lab record:** five predictions, settings, exports.

---

## 9. Slides arc

1. **Title.** Lecture 9 — State dependence and asymmetric responses.
2. **Multipliers in slack.** RZ's two numbers at $h=7$ (0.60, 0.59) and at impact (−0.61, 1.24).
3. **One interaction, two regressions.** The interacted LP and split-sample equivalence.
4. **Starting in slack is not staying in slack.** `fig-l09-fixed-vs-initial`: 0.430 versus 0.646 at $h=8$.
5. **When spending moves the state.** $\psi^A_8(+2)/2=0.22$, $\psi^A_8(-2)/(-2)=0.43$; the small-shock reading.
6. **Who identifies the slack multiplier.** `fig-l09-support`: 99 percent from 1940–45.
7. **Weak where it matters.** First-stage $F$ by state and horizon.
8. **Test the difference, not the bands.** §6.4 arithmetic at $h=0$.
9. **Positive and negative news.** Different responses, similar multipliers.
10. **Sensitivity, not selection.** `fig-l09-threshold-sensitivity`: 147 tests, 12 rejections, all at weak first stages.
11. **Coefficients or composition.** `tbl-l09-kob` at $h=0$ and $h=8$.
12. **What the evidence licenses.** The interpretation record in three sentences.
13. **Lab, exercises, and Lecture 10's question.** One coefficient, many shock sizes.

## 10. Open questions for the editor

1. **GHKP version (D31).** R11's metadata is verified, but no frozen PDF exists in
   `replication-packages/`. The brief's GHKP claims rest on Jordà–Taylor's (2025) summary and the
   course simulation. Freeze the article so the reading guide can name sections.
2. **Anderson–Rubin $p$-values.** `jordagk_ar.do` is in the supplied package with
   unmeasured runtime. Should the instructor build run it once if it finishes under 10 minutes (D2), or should the brief
   quote the published values (.954, .924), labeled?
3. **Horizon wording.** Adopt "through quarter 7 (eight quarters)" for RZ's
   "2-year integral" consistently in L4, L9, and L13?
4. **JT Example 9 discrepancies.** Apply the D14/D18 treatment to the storage
   offset and the $x_{t-1}$/$x_t$ mismatch: log them, correct the course figure, and add a neutral note?
5. **State-feedback symbol (resolved).** L8 owns $\lambda$ as the smoothing penalty (ledger §5), so
   the state-feedback parameter is $\varpi$ throughout; $\xi$ was not used because L4 assigns
   $\xi_t$ to instrument noise. Record it in ledger §6 (D20).
6. **KOB framing.** The two-group split at $x_{t-1}>0$ is a course construction
   on JT's Equation 67, not their figure. Should it be labeled an instructional extension?
7. **Simulation design.** Approve the probit transition, sparse Gaussian shocks,
   and calibration to RZ state frequencies as the course's Lecture 9 design.
8. **One HAC port for REP04 and REP09.** Footnote (ii) shows that built-in
   `ivregress 2sls, vce(hac nwest opt)` reproduces both benchmarks without `ivreg2`. The L4
   brief copies bandwidths into `rep04_bandwidths.csv`; ask it to adopt the `opt` port or
   cite this equivalence, so the course has one HAC port of `jordagk.do`.
