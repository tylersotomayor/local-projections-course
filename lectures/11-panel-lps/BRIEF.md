# Lecture 11 brief — Panel LPs and common macroeconomic shocks

Planning brief for `lectures/11-panel-lps/` (notes, exercises, glossary,
slides, figures), `interactives/11-panel-identification.qmd` ("Where Does
Identification Come From?"), and `practica/p11-panel-lps/`. Written against the
course spine (Lecture 11 entry and the seams with Lectures 10 and 12), the
notation ledger, the terminology plan, the editor decisions, the blueprint
(Sections 1, 4, 5, and Lecture 11), and the authoring guide.

Verification status. Every number below comes from one of six runs made for
this brief in StataNow/SE 19.5 (D1), in the scratch directory
`…/scratchpad/design-11/`: (i) `rep11_audit.do` reran the unmodified *When
Credit Bites Back* archive (`all.do`, 18.2 s) on a scratch copy and matched the
Stata 18.5 benchmark `REP11-historical-recession-paths.csv` to a maximum
absolute difference of $4.6\times10^{-7}$, then audited the sample and the
inference; (ii) `l11_absorb.do` ran one seeded simulated panel through Stata
`regress` and the course's Mata engine (agreement to $10^{-8}$); (iii)
`l11_mc_course.do` is the course-built panel Monte Carlo at $R=200$ (9.7 s) and
$R=500$ (24.4 s); (iv) `l11_mc_as.do` is a statistical reproduction of
Almuzara–Sancibrián's Table 1 coverage columns at $R=200$ (13.7 s) and $R=500$
(34.6 s), against their 5,000; (v) `rep11_pvalues.do` and `rep11_df_check.do`
reran `all.do` and recorded the degrees of freedom and $p$-values of the $h=5$
gap under each `vce`; (vi) `l11_timing_regress.do` timed the `regress` loops of
exercise 5 and STA11 task 4 at $R=200$ (30.4 s in all). No log contains a Stata error line. SR1090's
author R/MATLAB code was read, not executed (MANIFEST §REP11).

---

## 1. Session brief

**Opening situation.**
Jordà, Schularick, and Taylor ask whether recessions that follow credit booms
are deeper. Their historical archive has 1,946 country-years for 14 advanced
economies, 1870–2008, and dates 298 business-cycle peaks: 231 normal and 67
financial. The regression behind Figure 4 uses 121 of those peaks, 92 normal
and 29 financial. They fall in only 58 distinct years, and in 1929, 1981, and
1992 five countries peak at once. Five years after the peak, real GDP per
capita in the average normal recession is 4.81 percent above its peak level.
After a financial recession at average excess credit it is 1.36 percent below.
The 6.18-point gap has a conventional standard error of 1.83. The panel looks
large, and the figure looks like an impulse response. Neither impression
survives inspection. The rows are not the identifying information, and the
figure is not a response to a shock.

**Decision or empirical question.**
When a panel LP is estimated on many units, what variation identifies the
coefficient, how many independent pieces of that variation are there, and
which standard error matches that answer? Three designs make this concrete.
In a pooled regression on a common shock, identification comes from the time
series of shocks: its precision is governed by $T$, not $NT$, and it cannot
include time effects. In an exposure interaction with time effects,
identification comes from how responses vary across exposure: it recovers a
gradient, never the level. In JST's recession-path comparison there is no
shock at all: the coefficients are type-specific intercepts, and the result is
a conditional comparison. Inference follows from the answer, never the other
way round.

**Target student and prerequisites.**
Has completed Lectures 1–10: writes
$y_{t+h}=\mu_h+\beta_h s_t+\boldsymbol\gamma_h'\mathbf w_t+u_{t,h}$ from memory;
separates $\beta_h$ from $\theta_h$ (L3); knows lag augmentation and HAC
standard errors (L5); has met $\beta^{A}_h$, $\beta^{B}_h$ and interacted
specifications (L9) and the weighted-average reading of a linear coefficient
(L10). Stata assumed: `xtset`, factor variables, `regress` with
`vce(cluster …)`, `postfile`, `lincom`. New here: panel indexing, fixed effects
as dummies and as demeaning, and clustering on more than one dimension, which
`regress` supports directly in StataNow 19.5 (`vce(cluster id t)`; verified in
this pass).

**Learning outcomes (five).**

1. Write a panel LP with horizon-specific unit effects and report its
   estimation sample by horizon. Explain why time effects absorb a common
   shock, and state what the exposure interaction $e_i s_t$ identifies: the
   gradient $\psi\rho^h$, not the level.
2. State the Almuzara–Sancibrián estimands:
   $\mathbb E[e_i\theta_{i,h}]/\mathbb E[e_i^2]$ without time effects
   ($\mathbb E[\theta_{i,h}]$ when $e_i$ is identically 1, design P) and
   $\operatorname{Cov}(e_i,\theta_{i,h})/\operatorname{Var}(e_i)$ with time
   effects (design E, $\psi\rho^h$ here). Use the synthetic time series to
   compute an effective sample size and show that it is bounded as
   $N\to\infty$.
3. Choose inference from the design. Predict, then verify by simulation, when
   standard errors clustered by unit, clustered by time, two-way clustered, and
   Driscoll–Kraay cover, and implement time clustering with lag augmentation.
4. Replicate the JST Figure 4 GDP panel exactly, record how the sample was
   built, and read the result as a conditional comparison of recession paths.
5. Diagnose the small-$T$ bias created by unit effects combined with lagged
   outcomes (Nickell), and say when it matters for the shock coefficient.

**Anchor examples.**

*Data (opening and evidence).* The *When Credit Bites Back* historical archive,
`WCBB_replication_14aug2015` (acquired 2026-09-13, SHA-256 `5e61b649…d298899`),
starting panel `data/panel14_1_oj.dta`, prepared by `programs/data_Oct2012.do`.
Never JST R6 (D16).
- Outcome: `lrgdp = log(rgdpbarro)`, the Barro–Ursúa index of real GDP per
  capita. The horizon-$h$ outcome is `lrgdp`$h$ $=100\,(\text{lrgdp}_{i,t+h}-\text{lrgdp}_{i,t})$,
  the cumulative percent change from the peak year $t$, for $h=1,\dots,5$
  years. The value at $h=0$ is imposed as zero.
- Rows: country-years flagged as peaks (`pk_norm`, `pk_fin`; both hand-coded
  in `auxprograms/peak_dummies_August2012Alan.do`) inside `core`. `core` covers 1870–1908, 1921–1933
  and 1948–2003 and requires five leads, leaving 223 rows. Of these, 121 have
  all controls.
- Controls: seven macro variables standardized over the full panel (real
  private-loan growth, real GDP per capita growth, CPI inflation, real
  investment growth, short rate, long rate, current account/GDP) and their
  first lags.
- Country effects: 13 sum-to-zero deviation dummies, estimated with
  `noconstant`.
- Excess credit: `srx_prv`, the percentage-point-per-year change in loans/GDP
  over the preceding expansion, demeaned within type (means 0.2358 normal,
  1.2559 financial). "Plus one SD" scales by within-type SDs of 2.0079 (normal)
  and 2.5130 (financial).
- Standard errors: conventional OLS.

*Simulation (the running example).* The smallest model below with $\rho=0.5$,
$\bar\theta=1$, $\psi=0.5$, and $s_t,\zeta_t,v_{i,t}$ i.i.d. $\mathcal N(0,1)$.
Exposure $e_i\sim\mathcal N(0,1)$ is standardized in-sample to mean 0 and
variance 1. Burn-in is 50 periods, with one lag of the outcome and of the
regressor. Single sample (`l11_absorb.do`): `set seed 11`, $N=20$, $T=40$.
Monte Carlo (`l11_mc_course.do`): `set seed 20260913`,
$T\in\{40,160\}$, $N\in\{5,20,80,320\}$, $h\in\{0,2\}$, $R=200$ for students
and $R=500$ for the instructor (D2). It is a course-built simulation, labeled
as such.

*Published simulation (inference section).* Almuzara–Sancibrián's stylized
model (4): $T=30$, $N=1{,}500$, $\rho=0.7$, $s_i=\beta_i\sim\mathcal N(1,1)$,
$\sigma_u^2=N(1-\bar R^2)/\bar R^2$ (their footnote 10), $\bar R^2\in\{0.1,0.9\}$,
90 percent intervals. Run with `set seed 1090`, $R=200$ and $R=500$, labeled a
statistical reproduction.

**Smallest useful model (ledger notation plus the new symbols in Section 2).**
$$
y_{i,t}=\rho\,y_{i,t-1}+\theta_i s_t+\zeta_t+v_{i,t},\qquad
\theta_i=\bar\theta+\psi e_i,\qquad \theta_{i,h}=\rho^h\theta_i .
$$
Two projections on the same panel, both with $\mathbf w_{i,t}$ containing one
lag of the outcome and of the regressor:

- (P) $y_{i,t+h}=\eta^{(h)}_i+\beta_h s_t+\boldsymbol\gamma_h'\mathbf w_{i,t}+u_{i,t,h}$,
  with estimand $\beta_h=\rho^h\bar\theta$;
- (E) $y_{i,t+h}=\eta^{(h)}_i+\phi^{(h)}_t+\beta^{e}_h\,e_is_t+\boldsymbol\gamma_h'\mathbf w_{i,t}+u_{i,t,h}$,
  with estimand $\beta^{e}_h=\operatorname{Cov}(e_i,\theta_{i,h})/\operatorname{Var}(e_i)=\psi\rho^h$.

Adding $\phi^{(h)}_t$ to (P) makes $s_t$ collinear with the date dummies.

Synthetic-time-series variances, derived in §6.3:
$$
\operatorname{Var}(\hat\beta_h)\approx\frac{\sigma^2_{A,h}+\sigma^2_{I,h}/N}{T_h},\qquad
\operatorname{Var}(\hat\beta^{e}_h)\approx\frac{\psi^2\sum_{j=1}^{h}\rho^{2(h-j)}+\sigma^2_{I,h}/(N-1)}{T_h},
$$
where $\sigma^2_{A,h}=\rho^{2h}+2\sum_{j=1}^{h}\rho^{2(h-j)}$ and
$\sigma^2_{I,h}=\sum_{j=0}^{h}\rho^{2(h-j)}$ at unit variances. The effective
number of units, $N_{\mathrm{eff},h}=(\sigma^2_{A,h}+\sigma^2_{I,h})/(\sigma^2_{A,h}+\sigma^2_{I,h}/N)$,
never exceeds 2 at $h=0$ or 1.5122 at $h=2$.

JST in the same notation. The rows are episodes $(i,t)\in\mathcal P$ with
$|\mathcal P|=121$:
$$
y_{i,t+h}-y_{i,t}=\mu^{\mathrm N}_h P^{\mathrm N}_{i,t}+\mu^{\mathrm F}_h P^{\mathrm F}_{i,t}
+\chi^{\mathrm N}_h\tilde x^{\mathrm N}_{i,t}+\chi^{\mathrm F}_h\tilde x^{\mathrm F}_{i,t}
+\boldsymbol\gamma_h'\mathbf w_{i,t}+\eta^{(h)}_i+u_{i,t,h},\qquad \textstyle\sum_i\eta^{(h)}_i=0 .
$$
There is no $s_t$ in this equation.

**Dependency chain of sections.** The titles refine the spine's nine steps in
the spine's order.

1. `#sec-l11-panel-lp` *The panel LP, horizon by horizon.* Unit effects
   $\eta^{(h)}_i$ are re-estimated at every horizon, and each unit loses $h+p$
   dates. The JST regression is a panel of 121 episodes, not 1,946
   country-years, so the first record to keep is the sample by horizon.
2. `#sec-l11-time-effects` *What time effects absorb.* With $\phi_t$ in the
   regression, a common shock lies in the span of the date dummies. Depending
   on variable order, Stata either omits it or reports a normalization
   artifact: 1.132 in the seed-11 panel, where the true response is 1. Only
   $e_is_t$ survives, and it identifies a gradient across exposure.
3. `#sec-l11-micro-macro` *Micro responses to a macro shock.* The pooled
   estimator equals a time-series LP on a cross-sectional average. Its
   precision is set by $T$ and by the aggregate share of the error, so 320
   units are worth at most 1.51 units at $h=2$ in the running example.
4. `#sec-l11-inference` *Inference when the shocks are shared.*
   Unit-clustered intervals lose coverage as $N$ grows, falling to 8.6 percent
   at $N=320$, $h=2$, $T=40$. Time clustering with lags stays near nominal once
   $T$ is moderate. Two-way and Driscoll–Kraay intervals fall in between, which
   is the pattern Almuzara–Sancibrián report.
5. `#sec-l11-heterogeneity` *What a pooled coefficient averages.* In a
   balanced panel a common-shock regression averages $\theta_{i,h}$ equally
   across units; an unbalanced panel weights by dates observed. An exposure
   coefficient is the best linear approximation to $\mathbb E[\theta_{i,h}\mid e_i]$,
   and a binary exposure gives a group difference. This connects to Lecture
   10's weights.
6. `#sec-l11-recession-paths` *Recession paths are conditional comparisons.*
   $\mu^{\mathrm N}_h$ and $\mu^{\mathrm F}_h$ are intercepts by recession type,
   conditional on controls and averaged over country effects. Reading them as
   the effect of a financial crisis would require assumptions the design does
   not supply (D16).
7. `#sec-l11-nickell` *Fixed effects, lags, and short samples.* The lag
   coefficient has the Nickell bias $-(1+\rho)/(T_h-1)$, which is $-0.039$ at
   $T=40$. The shock coefficient is unbiased at $h=0$ but carries an
   order-$1/T$ bias at $h=2$. With about 8.6 episodes per country and lagged
   growth controls, the JST design deserves the same caution.
8. `#sec-l11-evidence` *Evidence: the Figure 4 GDP panel.* The exact
   replication in StataNow 19.5 agrees with the benchmark to
   $4.6\times10^{-7}$. The sample record shows 121 episodes in 58 years, and
   the inference audit shows that the financial–normal gap at $h=5$ keeps
   $|t|>2.8$ under country, year, and two-way clustering ($p\le0.013$ on $t$
   with $G-1$ degrees of freedom).
9. `#sec-l11-handoff` *Units that switch on at different dates.* Exposure
   designs and recession types compare units at the same date. When a
   treatment turns on in different years for different units, the comparison
   group itself changes with the date.

**Central notation.** Ledger §1, used throughout: $h,H,y,s,\mathbf w,p,\beta_h,\hat\beta_h,\theta_h,\mu_h,\boldsymbol\gamma_h,u,\mathcal T_h,T_h$.
Ledger §4: $\alpha,\operatorname{se}(\cdot),m,\rho,R$. Ledger §7: $i,N,y_{i,t+h},\eta_i,\phi_t,\phi^{(h)}_t,e_i$.
New here (Section 2): $\theta_i,\theta_{i,h},\bar\theta,\psi,\zeta_t,v_{i,t},\beta^{e}_h,\bar y_{t},\sigma^2_{A,h},\sigma^2_{I,h},N_{\mathrm{eff},h},\bar R^2_h$,
and for JST $P^{\mathrm N}_{i,t},P^{\mathrm F}_{i,t},\tilde x^{\mathrm N}_{i,t},\tilde x^{\mathrm F}_{i,t},\mu^{\mathrm N}_h,\mu^{\mathrm F}_h,\chi^{\mathrm N}_h,\chi^{\mathrm F}_h,\sigma^{\mathrm N}_x,\sigma^{\mathrm F}_x,\mathcal P$.

**Glossary terms (the fourteen owned keys; no new keys without approval, D22).**

- `panel-local-projection`: A horizon-by-horizon regression of $y_{i,t+h}$ on
  an intervention with unit effects and, if the regressor varies across units,
  time effects. More rows do not mean more identifying variation.
- `unit-fixed-effect`: A separate intercept $\eta^{(h)}_i$ for each unit,
  re-estimated at each horizon. It removes permanent level differences, and
  combined with lagged outcomes over a short $T$ it produces Nickell bias.
- `time-fixed-effect`: A separate intercept $\phi^{(h)}_t$ for each date. It
  absorbs everything common to all units at that date, including the shock of
  interest when that shock is common.
- `common-shock`: An intervention with the same value $s_t$ for every unit.
  Its coefficient is identified only from time-series variation, and it cannot
  coexist with time effects.
- `exposure`: A predetermined unit characteristic $e_i$ that scales how
  strongly unit $i$ is expected to respond to a common shock, such as leverage
  or trade openness.
- `exposure-interaction`: The regressor $e_is_t$, which survives time effects.
  Its coefficient is $\operatorname{Cov}(e_i,\theta_{i,h})/\operatorname{Var}(e_i)$,
  a difference in responses across exposure, not the average response.
- `cross-sectional-dependence`: Correlation of regression errors across units
  at the same date. It is created by shared shocks, including future shocks
  that enter the horizon-$h$ error.
- `clustered-standard-errors`: Standard errors that sum the regression score
  within groups before squaring. They are valid when groups are independent,
  so the cluster must match the dimension in which errors are shared.
- `driscoll-kraay`: A HAC estimator applied to scores summed across units at
  each date. It allows cross-sectional and serial dependence, but it needs a
  bandwidth and a long $T$.
- `effective-sample-size`: The number of independent observations that would
  give the estimator's actual precision. For a common shock it is governed by
  the number of dates, and it stays bounded as $N$ grows.
- `nickell-bias`: The order-$1/T$ bias in a lagged-outcome coefficient caused
  by demeaning within units over a short sample. It is $-(1+\rho)/(T-1)$ to
  first order in an AR(1).
- `heterogeneous-response`: A response $\theta_{i,h}$ that differs across
  units. A pooled coefficient then estimates a weighted average or a linear
  projection of it, with weights set by the design.
- `conditional-comparison`: A difference in average outcomes between groups
  defined by an observed event (a recession type) after conditioning on
  controls. It describes, and becomes causal only under assumptions the
  comparison does not test.
- `financial-recession`: In JST, a business-cycle peak that the authors
  associate with a systemic financial crisis (67 hand-coded country-years in the
  archive; the paper's timing rule to be quoted from the frozen article, §10).
  It classifies episodes after the fact; it is not an exogenous shock.

**Likely explanatory footnotes.** Sum-to-zero deviation dummies and why
`noconstant` makes $\mu^{\mathrm N}_h$ the unweighted country average;
Bry–Boschan dating of annual peaks; `pk_glob` being created but never set, so
`replace pk_fin = pk_fin + pk_glob` changes nothing; the war and depression windows excluded from
`core`; the within-type SDs being computed on 119 and 35 episodes, not on the
92 and 29 in the regression; Stata's rule for which collinear variable it
omits; the name "t-LAHR" for Almuzara–Sancibrián's time-clustered,
lag-augmented, heteroskedasticity-robust standard error, and their Imbens–Kolesár
small-sample refinement (not ported); the Newey–West (1994) Driscoll–Kraay
bandwidth $\lceil 4(T_h/100)^{2/9}\rceil$; SR1090's survey of 61 papers
(two-way clustering in slightly under half, unit-only clustering in over a
third); JST R6 as a later release whose use is an extension (D16); inference
with few clusters: `vce(cluster)` $p$-values use $t$ with $G-1$ degrees of
freedom (13 for 14 countries, 57 for 58 years, 13 for two-way, the smaller
dimension), cluster-robust SEs can still be too small with 14 clusters, the
two-way matrix is not positive semidefinite here (Stata's note), and the wild
cluster bootstrap (`wildbootstrap`, optional under D4) is further reading.

**Candidate figures.** Each is standalone TikZ/pgfplots, built by
`figures/build.sh` with the shared `lpfig.tex`; Lua reads the committed CSVs.

| Label | Question | Lesson visible | Data or formula |
|---|---|---|---|
| `fig-l11-episodes-by-year` | How many independent dates does the JST regression rest on? | 121 episodes in 58 peak years, clusters at 1929, 1981, 1992; war windows empty | `es1` sample from `rep11_audit.do` (stored) |
| `fig-l11-absorption` | What do time effects remove from a panel hit by a common shock? | Unit paths co-move with $s_t$; $\hat\phi_t$ tracks $s_t+\zeta_t$; residual variation is $e_i s_t$ | seed-11 panel, `l11_absorb.do` |
| `fig-l11-exposure` | What does an exposure coefficient identify? | $\theta_{i,h}$ against $e_i$: slope $\psi\rho^h$ identified; the intercept (level) is not | exact formula, $\rho=0.5,\psi=0.5$ |
| `fig-l11-effective-sample` | Does adding units shrink the sampling SD? | (P): flat in $N$ at $T=40$ (0.160 formula, 0.177 MC) and halves with $4T$; (E): $1/\sqrt N$ at $h=0$, floor 0.092 at $h=2$ | `l11_mc_course_summary_R500.csv` plus formula lines |
| `fig-l11-coverage-by-n` | Which interval covers? | Unit clustering falls from 46 to 9 percent as $N$ rises (P, $h=2$, $T=40$); time clustering 86–89 percent, 94–96 percent at $T=160$; the caption adds that more $N$ does not rescue unit clustering | same CSV |
| `fig-l11-recession-paths` | What does Figure 4's GDP panel show? | Normal path to +4.81 at $h=5$ with band; financial paths below zero; labeled "conditional paths" | `REP11-historical-recession-paths.csv` |

Droppable under D24: `fig-l11-episodes-by-year` (a sentence and a table carry
it) and the audit intervals, which are a table (`tbl-l11-inference-audit`).

**Exercise capabilities.** Build the sample record of a panel LP; prove
absorption and FWL two-way demeaning; run and read a collinearity diagnosis;
derive the synthetic time series and $N_{\mathrm{eff},h}$; simulate precision
against $N$ and $T$; simulate coverage for four standard errors; state the
exposure estimand under nonlinearity and imbalance; replicate REP11 exactly;
audit its inference and scaling; measure Nickell bias.

**Controlled experiments (lab).** Toggle time effects and exposure on a fixed
panel; move $N$ with $T$ and the aggregate share fixed; move $T$ with $N$
fixed; switch the standard error while holding the draws fixed; swap
inference choices on the stored JST results.

**Postponed.** Interactive fixed effects and factor-augmented panels; spatial
dependence; panel LP-IV beyond one footnote (SR1090 §3.3); the Imbens–Kolesár
refinement and AIC lag rule; dynamic-panel GMM (Arellano–Bond) beyond naming
it; staggered treatments (L12).

**Question handed on.** When a treatment switches on in different years for
different units, which units are valid comparisons at each horizon, and how
should the projection be built so that already-treated units never serve as
controls?

---

## 2. Concept and notation ledger

Symbols in the ledger keep their meaning. New symbols are local to this
lecture until the editor records them (see §10). Almuzara–Sancibrián write
$X_t$ for the macro shock and $s_i$ for the unit attribute, and the course's
$s_t$ would collide with their $s_i$. The notes therefore carry a mapping
footnote at first use: AS $X_t\to s_t$, $s_i\to e_i$, $\beta_i^h\to\theta_{i,h}$,
$Z_t\to\zeta_t$, $u_{it}\to v_{i,t}$, $\mu_i(h),\nu_t(h)\to\eta^{(h)}_i,\phi^{(h)}_t$,
$\beta(h)\to\beta^{e}_h$ (or $\beta_h$ when $s_i=1$).

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $i$, $N$ | Unit index; number of units | scalar | — | countries, simulated units | §1 | L12 |
| $y_{i,t}$ | Outcome of unit $i$ | scalar | $t$ | model units (sim.); $100\times\log$ real GDP per capita (JST) | §1 | all |
| $y_{i,t+h}-y_{i,t}$ | JST cumulative change from the **peak** year | scalar | $t\to t+h$ | percent | §6 | §8, REP11 |
| $s_t$ | Common shock, same for all $i$ | scalar | $t$ | s.d. 1 | §2 | §3–5 |
| $e_i$ | Exposure, predetermined, standardized in-sample | scalar | fixed | s.d. 1 | §2 | §3–5, L12 contrast |
| $\eta^{(h)}_i$ | Unit fixed effect at horizon $h$ | $N$ | fixed | outcome units | §1 | §7, JST |
| $\phi^{(h)}_t$ | Time fixed effect at horizon $h$ | $T_h$ | $t$ | outcome units | §2 | §3–4, L12 |
| $\theta_i$, $\theta_{i,h}$ | Unit impact response; unit response at $h$ ($=\rho^h\theta_i$ here) | scalar | $t\to t+h$ | outcome per unit $s$ | §3 | §5 |
| $\bar\theta$, $\psi$ | Mean response; exposure gradient, $\theta_i=\bar\theta+\psi e_i$ | scalars | — | outcome per unit $s$ (per s.d. of $e$) | §2 | §3, §5 |
| $\zeta_t$ | Omitted aggregate shock, independent of $s_t$ | scalar | $t$ | outcome units | §3 | §4 |
| $v_{i,t}$ | Idiosyncratic shock | scalar | $t$ | outcome units | §3 | §4 |
| $\beta_h$, $\beta^{e}_h$ | Pooled coefficient on $s_t$; coefficient on $e_is_t$ | scalars | $h$ | outcome per unit $s$ | §1, §2 | §3–5 |
| $\mathbf w_{i,t}$ | Controls: $y_{i,t-1}$ and $s_{t-1}$ (P) or $e_is_{t-1}$ (E) | $2p\times1$ | $\le t-1$ | — | §1 | §4, §7 |
| $u_{i,t,h}$ | Horizon-$h$ residual of row $(i,t)$ | scalar | $t+1..t+h$ shocks | outcome units | §1 | §3–4 |
| $T_h$ | Dates per unit at horizon $h$, $T-h-p$ | scalar | — | dates | §1 | §3–4, §7 |
| $\bar y_{t}$ | Cross-sectional average (synthetic series) | $T\times1$ | $t$ | outcome units | §3 | §4 |
| $\sigma^2_{A,h}$, $\sigma^2_{I,h}$ | Aggregate and idiosyncratic variance of the synthetic horizon-$h$ error | scalars | $h$ | squared outcome units | §3 | §4, lab 2 |
| $N_{\mathrm{eff},h}$ | Effective number of units, $(\sigma^2_{A,h}+\sigma^2_{I,h})/(\sigma^2_{A,h}+\sigma^2_{I,h}/N)$ | scalar | $h$ | units | §3 | lab 2, STA11 |
| $\bar R^2_h$ | Aggregate share of synthetic error, $\sigma^2_{A,h}/(\sigma^2_{A,h}+\sigma^2_{I,h}/N)$ (AS's $\bar R^2$) | scalar | $h$ | share | §4 | lab 3 |
| $m$ | Driscoll–Kraay bandwidth, $\lceil4(T_h/100)^{2/9}\rceil$ | scalar | — | lags | §4 | STA11 |
| $\rho$, $R$ | Persistence; Monte Carlo replications (ledger) | scalars | — | — | §1, §3 | §7 |
| $\mathcal P$ | JST estimation set of recession episodes, $\lvert\mathcal P\rvert=121$ | set | peak years | episodes | §1 | §6, §8 |
| $P^{\mathrm N}_{i,t}$, $P^{\mathrm F}_{i,t}$ | Normal and financial peak indicators ($P^{\mathrm N}+P^{\mathrm F}=1$ on $\mathcal P$) | scalars | $t$ = peak | 0/1 | §6 | §8 |
| $\tilde x^{\mathrm N}_{i,t}$, $\tilde x^{\mathrm F}_{i,t}$ | Excess credit of the prior expansion, demeaned within type, zero for the other type | scalars | expansion ending at $t$ | pp of GDP per year | §6 | §8 |
| $\mu^{\mathrm N}_h$, $\mu^{\mathrm F}_h$ | Type-specific intercepts: average-country conditional paths | scalars | $h$ | percent | §6 | §8, REP11 |
| $\chi^{\mathrm N}_h$, $\chi^{\mathrm F}_h$ | Path shift per pp/yr of excess credit | scalars | $h$ | percent per pp/yr | §6 | §8 |
| $\sigma^{\mathrm N}_x$, $\sigma^{\mathrm F}_x$ | Within-type SDs of excess credit (2.0079; 2.5130) | scalars | — | pp/yr | §6 | §8 |

Avoided: $b$ (D20), $\kappa$ (L7), $\lambda$ (L8), $f_s$ (L10), $D_{i,t},g_i$ (L12), $\alpha_i$ (ledger).

Stata names follow the ledger: `id t y s e es` (`es` $=e_is_t$), `h beta_h
se_h`. Author names such as `pk_norm pk_fin srx_norm_prv srx_fin_prv
lrgdp1`–`lrgdp5 dum1`–`dum13` are kept inside REP11, with a mapping table in
the practicum README.

---

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition or note | First marked |
|---|---|---|---|---|
| panel local projection | glossary | `panel-local-projection` | See §1 draft. | `#sec-l11-panel-lp` |
| unit fixed effect | glossary | `unit-fixed-effect` | See §1. | `#sec-l11-panel-lp` |
| time fixed effect | glossary | `time-fixed-effect` | See §1. | `#sec-l11-time-effects` |
| common shock | glossary | `common-shock` | See §1. | `#sec-l11-time-effects` |
| exposure | glossary | `exposure` | See §1. | `#sec-l11-time-effects` |
| exposure interaction | glossary | `exposure-interaction` | See §1. | `#sec-l11-time-effects` |
| effective sample size | glossary | `effective-sample-size` | See §1. | `#sec-l11-micro-macro` |
| cross-sectional dependence | glossary | `cross-sectional-dependence` | See §1. | `#sec-l11-inference` |
| clustered standard errors | glossary | `clustered-standard-errors` | See §1. | `#sec-l11-inference` |
| Driscoll–Kraay | glossary | `driscoll-kraay` | See §1. | `#sec-l11-inference` |
| heterogeneous response | glossary | `heterogeneous-response` | See §1. | `#sec-l11-heterogeneity` |
| conditional comparison | glossary | `conditional-comparison` | See §1. | `#sec-l11-recession-paths` |
| financial recession | glossary | `financial-recession` | See §1; timing rule to be quoted from the frozen article (§10 Q5). | `#sec-l11-recession-paths` |
| Nickell bias | glossary | `nickell-bias` | See §1. | `#sec-l11-nickell` |
| synthetic time series | footnote (key proposed, §10) | — | The cross-sectional (exposure-weighted) average whose time-series LP reproduces the panel estimator. | `#sec-l11-micro-macro` |
| t-LAHR | footnote | — | Almuzara–Sancibrián's label for time-clustered, lag-augmented, heteroskedasticity-robust inference. | `#sec-l11-inference` |
| two-way clustering | prose under `clustered-standard-errors` | — | Unit meat plus time meat minus the heteroskedasticity meat. | `#sec-l11-inference` |
| sum-to-zero deviation dummies | footnote | — | $\mathbb 1\{i=j\}-1/14$ with `noconstant` makes the type intercepts unweighted country averages. | `#sec-l11-recession-paths` |
| Bry–Boschan peaks; `core` sample | footnote | — | Annual turning-point rule; windows 1870–1908, 1921–1933, 1948–2003 with five leads. | `#sec-l11-recession-paths` |
| collinearity omission | footnote | — | Stata keeps earlier-listed terms, so the reported variable depends on order. | `#sec-l11-time-effects` |
| Imbens–Kolesár refinement | footnote | — | HC2 leverage adjustment with a Student-$t$ critical value; recommended by AS for small $T$, not ported. | `#sec-l11-inference` |
| few-cluster inference | footnote | — | `vce(cluster)` reports $t$ with $G-1$ degrees of freedom; with 14 country clusters even that reference can overstate significance. | `#sec-l11-evidence` |

Earlier-owned terms appear as linked prose: local projection, estimation sample, statistical reproduction (L01–L02); lag augmentation, HAC estimator, coverage (L05); interacted LP (L09); weighted-average effect (L10). L12's `two-way-fixed-effects` is written "unit and time effects" here.

---

## 4. Evidence and visual ledger

Runs are in `design-11/`: `rep11_audit.log` and `rep11_audit_results.csv`; `l11_absorb.log`; `l11_mc_course_summary_R{200,500}.csv`; `l11_mc_as_summary_R{200,500}.csv`; `rep11_pvalues.log`, `rep11_df_check.log`; `l11_timing_regress.log`. All values below are at $R=500$ unless marked otherwise.

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| The GDP regression uses 121 of 1,946 country-years (298 peaks → 223 `core` → 121): 92 normal, 29 financial, 14 countries, 58 peak years, at most 5 per year (1929, 1981, 1992) | `count`, `tab`, `contract` on `e(sample)` | table (+ droppable strip) | `rep11_audit.log` | computed | `tbl-l11-sample-record`, `fig-l11-episodes-by-year` |
| StataNow 19.5 reproduces the 18.5 benchmark | max abs diff $4.59\times10^{-7}$ over 20 coefficients and 20 SEs; $N=121$ at every $h$ | table | `rep11_audit_results.csv` vs `REP11-historical-recession-paths.csv` | computed | `tbl-l11-rep11-benchmark` |
| $\mu^{\mathrm N}_h$ is the unweighted mean of country intercepts | $h=1$: mean of 14 `ibn.ccode` intercepts $-1.27130819$ vs $\hat\mu^{\mathrm N}_1=-1.27130816$ | footnote, §6.5 | `rep11_audit.log` | computed | — |
| Figure 4 GDP: normal $+4.812954$ at $h=5$, band $[2.466485, 7.159423]$; financial $-1.364781$; financial +1 SD $-3.615045$ | benchmark rows | figure | benchmark CSV | stored | `fig-l11-recession-paths` |
| Gap $\hat\mu^{\mathrm F}_5-\hat\mu^{\mathrm N}_5=-6.177735$; SE 1.833874 (OLS), 2.064873 (HC1), 2.123384 (country), 1.964324 (year), 2.152092 (two-way); $p$ = 0.0011 and 0.0036 ($t_{90}$), 0.0122 ($t_{13}$), 0.0026 ($t_{57}$), 0.0131 ($t_{13}$) | `lincom` under five `vce`; two-way $p$ from `test` | table | audit CSV, `rep11_pvalues.log` | computed | `tbl-l11-inference-audit` |
| Country clustering (14 clusters) *shrinks* the normal-path SE at $h=5$ from 1.197178 to 0.615769 | audit | prose in §8 | audit CSV | computed | — |
| +1 SD scaling uses SDs from 119 and 35 episodes, not the 92 and 29 in the regression | `sum` counts | footnote + discrepancy log | `rep11_audit.log` | computed | — |
| Time effects absorb $s_t$: with `i.t` first, `s` and `L.s` are omitted; with `s` first, Stata reports 1.132241 (SE 0.125757) and omits `39.t`, `40.t` | two `regress` calls, seed 11 | code excerpt + figure | `l11_absorb.log` | computed | `fig-l11-absorption` |
| The exposure coefficient recovers the gradient: 0.446353 at $h=0$ (truth 0.5), 0.041152 at $h=2$ (truth 0.125) in one panel; MC means 0.4995 and 0.1002 ($N=80$, $T=40$) | Stata = Mata to $10^{-8}$ | prose + figure | `l11_absorb.log`, MC CSV | computed | `fig-l11-exposure` |
| (P) precision does not improve with $N$: SD 0.1915, 0.1692, 0.1766, 0.1769 for $N=5,\dots,320$ ($T=40$, $h=0$); formula 0.1754, 0.1641, 0.1611, 0.1604; at $T=160$, 0.0850–0.0786 against 0.0869–0.0794 | MC and §6.3 | figure | MC CSV | computed | `fig-l11-effective-sample` |
| $N_{\mathrm{eff}}$ ceilings of 2 ($h=0$) and 1.5122 ($h=2$) | §6.3 | equation + lab 2 | derivation | derived | `eq-l11-neff` |
| (E) SD falls like $1/\sqrt N$ at $h=0$ (0.0847 → 0.0100) but floors at $h=2$ (0.0898 at $N=320$; formula 0.0925) | MC and §6.4 | same figure | MC CSV | computed | `fig-l11-effective-sample` |
| Unit-clustered 95% coverage collapses as $N$ grows, (P), $h=2$, $T=40$: 0.464, 0.264, 0.156, 0.086; time-clustered 0.886, 0.892, 0.864, 0.886; at $T=160$, time 0.940–0.956 | MC | figure | MC CSV | computed | `fig-l11-coverage-by-n` |
| In (E), unit clustering is adequate at $h=0$ for $N\ge80$ (0.934, 0.942), yet at $h=2$ it falls to 0.352 and 0.186 | MC | same figure, second panel | MC CSV | computed | `fig-l11-coverage-by-n` |
| AS Table 1 pattern reproduces (90% nominal, $\bar R^2=0.9$): unit-clustered 0.502/0.336/0.290/0.354 vs published 0.494/0.372/0.344/0.376; two-way 0.828/0.722/0.710/0.830 vs 0.819/0.726/0.725/0.811; Driscoll–Kraay 0.690/0.712/0.654/0.766 vs 0.716/0.725/0.695/0.782; plain t-LAHR 0.866/0.830/0.798/0.814 vs 0.851/0.842/0.811/0.806 | MC; Monte Carlo SE ≈ 0.013 | table | `l11_mc_as_summary_R500.csv`; SR1090 Table 1 | computed (statistical reproduction) | `tbl-l11-as-reproduction` |
| Nickell bias in the lag coefficient: mean 0.4563 at $T=40$ (bias $-0.044$; formula $-0.0395$), 0.4909 at $T=160$ (bias $-0.009$; formula $-0.0095$) | MC, (P), $N=320$, $h=0$ | table | MC CSV | computed | `tbl-l11-nickell` |
| Shock coefficient at $h=2$ has an order-$1/T$ bias: (P) 0.1976 vs 0.25 at $T=40$ (MC SE 0.013), 0.2438 at $T=160$; (E) 0.1002 vs 0.125 at $T=40$ | MC, $N=80$ | same table | MC CSV | computed | `tbl-l11-nickell` |
| AS estimand; effective sample governed by $T$; 61-paper survey | SR1090 §2.3, §3.2 Remarks 1–2, §1 | equation, prose | SR1090 (Aug 2026) | read | `eq-l11-as-estimand` |

---

## 5. Assessment map

Ten exercises. Four are Stata [computational] and two are [data]. Every
outcome is covered by at least two exercises and a lab.

| Outcome | Exercise | Tags | Mode | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1, 4 | 1. Rows, episodes, and years | [core] [data] | From the acquired archive, count rows, peaks, `core` rows, `e(sample)`, countries, and distinct peak years; tabulate episodes per year | Ask which filter removes the most rows | Assertions 1,946; 231/67; 223; 121 = 92 + 29; 14; 58 | 4 |
| 1 | 2. Why time effects swallow a common shock | [core] [pencil] | Show $s_t=\sum_\tau s_\tau\mathbb 1\{t=\tau\}$; show that two-way demeaning of $e_is_t$ is $(e_i-\bar e)(s_t-\bar s)$ in a balanced panel; say what is left to identify | Write the date dummies as columns and look for a linear combination | Algebra in §6.1–6.2 | 1 |
| 1 | 3. Absorption in Stata | [core] [computational] | On the shipped seed-11 panel, run (P), (P) + `i.t` in both orders, and (E); explain the 1.132 | Point to Stata's "omitted because of collinearity" note and ask which term was dropped | `assert` $\hat\beta^{e}_0=0.446353$ (to $10^{-6}$); that `s` is omitted in the first order; that 1.132241 appears in the second | 1 |
| 2 | 4. The synthetic time series | [core] [pencil] | Prove that pooled OLS with unit effects on a balanced panel equals the time-series LP of $\bar y_{t+h}$ on $s_t$; derive $\operatorname{Var}(\hat\beta_h)$ and $N_{\mathrm{eff},h}$; evaluate at $h=0,2$ | Suggest FWL on the unit dummies first | $N_{\mathrm{eff}}\to2$ and $1.5122$; $N=320$ values 1.9938, 1.5098 | 2 |
| 2 | 5. Rows versus shocks | [computational] | $R=200$ loop with `regress … i.id, vce(cluster t)` for $N\in\{5,80\}$, $T\in\{40,160\}$, $h=0$; compare the SD with the formula | Store $\hat\beta$ with `postfile`; summarize once | SD within $3\cdot\mathrm{SD}/\sqrt{2R}$ of the stored R=500 values | 2 |
| 3 | 6. Which standard error covers? | [core] [computational] | Same draws, (P) at $h=2$, $T=40$, $N\in\{20,80\}$: coverage for `vce(cluster id)`, `vce(cluster t)`, `vce(cluster id t)`, and the course Mata Driscoll–Kraay; predict first | Ask where the horizon-2 error's shared component comes from | Coverage within $3\sqrt{0.05\cdot0.95/R}$ of stored values (e.g. unit 0.264 and time 0.892 at $N=20$) | 3 |
| 2, 3 | 7. What the exposure coefficient averages | [pencil] | Derive $\beta^{e}_h$ when $\mathbb E[\theta_{i,h}\mid e_i]$ is quadratic, when $e_i$ is binary, and the pooled $\beta_h$ in an unbalanced panel; connect to L10 weights | Separate the projection coefficient from the conditional mean | Closed forms; binary case equals the group difference | 1 |
| 4 | 8. Replicate the Figure 4 GDP panel (REP11) | [core] [data] [computational] | Acquire, run `all.do`, extract the five regressions and `lincom`s, compare with the benchmark, and rebuild the figure with its caption labeled "conditional paths" | Warn that preserve/restore discards the figure columns | `rep11_compare.do` asserts max abs diff $\le10^{-5}$ and $N=121$ (course build $4.6\times10^{-7}$) | 4 |
| 3, 4 | 9. Audit the inference and scaling in Figure 4 | [data] [computational] | Re-estimate the gap under HC1 and country, year, and two-way clustering; count the clusters; recompute the +1 SD path with SDs from the regression sample and log it as a labeled variant | Ask how many independent draws each cluster choice assumes | SEs at $h=5$: 1.833874, 2.064873, 2.123384, 1.964324, 2.152092; a written discrepancy row | 4 |
| 5 | 10. Nickell bias and the shock coefficient | [extra] [computational] | Course Mata engine, $R=200$: lag and shock coefficients at $T\in\{40,160\}$; compare with $-(1+\rho)/(T_h-1)$ | Say which regressor is correlated with the unit mean | Lag bias within MC error of $-0.0395$ and $-0.0095$; the $h=2$ shock bias shrinks with $T$ | 2 |

---

## 6. Derivations to verify

**6.1 Absorption.** *Source identity:* with dates $\tau=1,\dots,T_h$,
$s_t=\sum_\tau s_\tau\mathbb 1\{t=\tau\}$. Any regression containing all date
dummies, or a constant plus all but one, spans $s_t$ and $s_{t-1}$. The
coefficient on $s_t$ is therefore not identified, and what Stata prints depends
on which column it drops. *Check (seed 11, $N=20$, $T=40$, $h=0$):*
$n=20\times39=780$. `regress y i.t s L.y L.s i.id` has rank
$1+38+1+19=59$ and omits `s` and `L.s`. `regress y s L.y L.s i.id i.t` also
has rank 59 but omits `39.t` and `40.t`, and reports 1.132241 (SE 0.125757).
The truth is 1, so that number is a normalization artifact.

**6.2 What survives.** *Operation:* FWL on unit and time dummies in a balanced
panel. Two-way demeaning maps $e_is_t$ to $(e_i-\bar e)(s_t-\bar s)$, which is
nonzero whenever $e$ varies. Substituting $\theta_i=\bar\theta+\psi e_i$, the
term $\bar\theta\rho^h s_t$ is absorbed by $\phi^{(h)}_t$ and $\psi\rho^h e_is_t$
remains, so $\beta^{e}_h=\psi\rho^h$. The general form is AS §2.3:
$\operatorname{Cov}(e_i,\theta_{i,h})/\operatorname{Var}(e_i)$. *Check:* Stata
0.4463528867 vs Mata 0.4463528875 ($h=0$); 0.0411523102 vs 0.0411523106
($h=2$). The Mata SE differs from Stata's by the degrees-of-freedom factor
$\sqrt{(n-1)/(n-k)}$; for (P) $n=780$, $k=23$, and
$\sqrt{779/757}=1.014427$ against the observed ratio 1.01442697.

**6.3 Synthetic time series and $N_{\mathrm{eff}}$** (`eq-l11-neff`).
1. *FWL on the unit dummies.* The demeaned regressor is $s_t-\bar s$ for every
   $i$, so
   $\hat\beta_h=\sum_t(s_t-\bar s)\bar y_{t+h}/\sum_t(s_t-\bar s)^2$. This is
   exact with no unit-varying controls and approximate with $y_{i,t-1}$ (AS
   Remark 1).
2. *Iterate the model given $y_{i,t-1}$.*
   $y_{i,t+h}=\rho^{h+1}y_{i,t-1}+\sum_{j=0}^{h}\rho^{h-j}(\theta_is_{t+j}+\zeta_{t+j}+v_{i,t+j})$.
3. *Average over $i$ with $\bar e=0$.* The heterogeneity terms cancel. The
   synthetic error has aggregate variance
   $\sigma^2_{A,h}=\rho^{2h}\sigma^2_\zeta+\sum_{j=1}^{h}\rho^{2(h-j)}(\bar\theta^2\sigma_s^2+\sigma^2_\zeta)$
   and idiosyncratic variance $\sigma^2_{I,h}/N$, where
   $\sigma^2_{I,h}=\sigma^2_v\sum_{j=0}^{h}\rho^{2(h-j)}$.
4. *The error at $t$ contains only $s_{t+1},\dots,s_{t+h}$.* Every cross
   product $s_t\epsilon_t\,s_{t'}\epsilon_{t'}$ therefore has mean zero, and
   $\operatorname{Var}(\hat\beta_h)\approx(\sigma^2_{A,h}+\sigma^2_{I,h}/N)/(T_h\sigma^2_s)$.

*Numbers (unit variances, $\rho=0.5$).* At $h=0$: $\sigma^2_A=\sigma^2_I=1$,
$N_{\mathrm{eff}}=2N/(N+1)$, and the ceiling is 2. At $h=2$:
$\sigma^2_A=0.0625+2(0.25)+2=2.5625$, $\sigma^2_I=1.3125$, and the ceiling is
$3.875/2.5625=1.512195$. At $N=320$: 1.993769 and 1.509779.

*SD check against MC ($R=500$):*

| $T$, $h$ | $T_h$ | $N=5$ | $N=320$ |
|---|---|---|---|
| 40, 0 | 39 | 0.17541 (MC 0.1915) | 0.16038 (MC 0.1769) |
| 40, 2 | 37 | 0.27632 (MC 0.2814) | 0.26338 (MC 0.2795) |
| 160, 0 | 159 | 0.08688 (MC 0.0850) | 0.07943 (MC 0.0786) |

The formula is within 2 percent at $T=160$. At $T=40$ it is about 10 percent
low (MC SE of an SD ≈ 0.0056) because it ignores estimation of the controls
and the mean.

**6.4 Exposure variance.** In the same steps, future shocks enter the (E)
error as $\psi e_i\sum_{j\ge1}\rho^{h-j}s_{t+j}$. Time effects do not remove
this term, and the exposure weights cancel between numerator and denominator.
The result is
$\operatorname{Var}(\hat\beta^{e}_h)\approx[\psi^2\sum_{j=1}^{h}\rho^{2(h-j)}+\sigma^2_{I,h}/(N-1)]/T_h$.
*Check:* $h=2$, $T=40$, $N=320$ gives $\sqrt{(0.3125+1.3125/319)/37}=0.09250$
(MC 0.0898). $h=0$, $N=5$ gives $\sqrt{(1/4)/39}=0.08006$ (MC 0.0847). The
floor $\sqrt{0.3125/37}=0.0919$ is AS Remark 2 in numbers.

**6.5 JST algebra.**
- *Sum-to-zero dummies.* With $d_j=\mathbb 1\{i=j\}-1/14$ for $j\le13$ and
  $P^{\mathrm N}+P^{\mathrm F}=1$, the normal-type intercept of country
  $j\le13$ is $\mu^{\mathrm N}+\delta_j-\tfrac1{14}\sum\delta$, and country 14's
  is $\mu^{\mathrm N}-\tfrac1{14}\sum\delta$. Summing over the 14 countries gives
  $14\mu^{\mathrm N}$. *Check:* the mean of the `ibn.ccode` intercepts is
  $-1.27130819$ against $\hat\mu^{\mathrm N}_1=-1.27130816$, and the `pk_fin`
  coefficient in that specification is $-1.5566161$, which equals the `lincom`
  gap.
- *+1 SD path.* $\hat\mu^{\mathrm F}_5+\sigma^{\mathrm F}_x\hat\chi^{\mathrm F}_5=-1.364781+2.512981\times(-0.895456)=-3.615045$,
  matching the benchmark.
- *Normal band.* $4.812954\pm1.96\times1.197178=[2.466485,\,7.159423]$,
  matching the benchmark.
- *Gap $t$-ratios and $p$-values at $h=5$.* `regress` reports $t$ with
  $n-k=90$ degrees of freedom for OLS and HC1, and $t$ with $G-1$ under
  `vce(cluster)`: 13 for country, 57 for year, and 13 for two-way (the smaller
  dimension; `e(df_r)`). $t=-3.369$, $p=0.0011$ (OLS); $-2.992$, $p=0.0036$
  (HC1); $-2.909$, $p=0.0122$ (country); $-3.145$, $p=0.0026$ (year);
  $-2.871$, $p=0.0131$ (two-way). A normal reference would give 0.0036
  (country) and 0.0041 (two-way). In StataNow 19.5, `lincom` after two-way
  clustering prints $p=0.0051$ on 90 degrees of freedom although
  `e(df_r)=13`, so the two-way $p$ comes from `test pk_fin = pk_norm` or
  `2*ttail(e(df_r), abs(r(t)))`. The few-cluster footnote (§1) sits here.
  *Check:* `rep11_pvalues.log`, `rep11_df_check.log`.

**6.6 Nickell bias.** *Source:* Nickell (1981), leading term
$\operatorname{plim}_{N\to\infty}(\hat\rho-\rho)\approx-(1+\rho)/(T_h-1)$.
*Check:* $T_h=39$ gives $-1.5/38=-0.03947$ (MC $-0.0437$), and $T_h=159$ gives
$-0.00949$ (MC $-0.0091$), both for (P) with $N=320$. The shock coefficient
inherits bias only through the in-sample correlation between $s_t-\bar s$ and
the unit-demeaned lag, which is why it shows at $h=2$ and not at $h=0$.

**6.7 AS reproduction design.** $\sigma_u^2=N(1-\bar R^2)/\bar R^2$ equals
166.67 at $\bar R^2=0.9$ and 13,500 at 0.1 ($N=1{,}500$). The Driscoll–Kraay
bandwidth is $\lceil4(T_h/100)^{2/9}\rceil=4$ at $T_h=30$ and 3 at $T_h=25$.
The truth is $0.7^h$. The critical value is $z_{0.95}=1.644854$, as in their
equation (3).

---

## 7. HTML lab plan (`interactives/11-panel-identification.qmd`)

Four labs in Observable JS. Each has setup, **Predict before using the
controls**, controls with units, a plot, a reactive sentence, controlled
comparisons, and a collapsed explanation. Shocks come from a seeded
`mulberry32`, so toggling a regression never redraws the data. Every output is
labeled as a live calculation, stored result, or conceptual illustration
(D30).

**Lab 1: What time effects remove (live).**
- *Question.* Which coefficient survives when a common shock hits every unit?
- *Invariants.* Innovations ($s_t$, $\zeta_t$, $v_{i,t}$, $e_i$) are drawn once
  per seed at $N_{\max}=50$ and $T_{\max}=120$ plus the 50-period burn-in. The
  lab takes the first $N$ units (re-standardizing $e_i$ over them) and the
  first $T$ dates after burn-in, and rebuilds outcomes from the same draws when
  $\psi$ changes ($\rho=0.5$, unit shock variances). Changing $T$ or a
  parameter never redraws shocks, and neither does changing $N$ or toggling a
  regression.
- *Controls.* $N$ (units, 5–50, default 20); $T$ (dates, 20–120, default 40);
  $\psi$ (outcome per s.d. of $e$, 0–1, default 0.5); toggles for time effects
  and for the exposure term.
- *Computation.* OLS by FWL two-way demeaning, matching §6.2. With time effects
  on and no exposure term, the lab shows "not identified: $s_t$ lies in the
  date dummies".
- *Reactive sentence.* "With time effects, the common-shock coefficient is not
  identified; the exposure coefficient is 0.45 (truth $\psi\rho^0=0.50$) and
  says units with one s.d. more exposure respond 0.45 more, not how much the
  average unit responds."
- *Comparisons.* $\psi=0$; time effects off, then on.
- *Handoff.* The panel as a CSV (`id,t,y,s,e`) with seed and parameters, for
  exercise 3.

**Lab 2: Rows versus shocks (live formula; optional live simulation).**
- *Question.* Does adding units buy precision?
- *Invariants.* $\rho$ and $h$ are fixed while $N$ moves.
- *Controls.* $N$ (1–1,000, log slider, default 20); $T$ (20–200, default 40);
  aggregate-to-idiosyncratic s.d. ratio $\sigma_\zeta/\sigma_v$ (0–3, default
  1); $h\in\{0,2\}$; design (P or E).
- *Display.* SD against $N$ from §6.3–6.4, with $N_{\mathrm{eff},h}$ and its
  ceiling. A "simulate" button runs $R=100$ in JS for $N\le200$, labeled with
  its MC error.
- *Reactive sentence.* "At $h=2$ with equal aggregate and idiosyncratic
  variance, 320 units are worth 1.51 units; quadrupling $T$ halves the SD,
  multiplying $N$ by 64 changes it by 5 percent."
- *Comparisons.* $\sigma_\zeta=0$; $T\times4$; P versus E at $h=0$ and $h=2$.
- *Handoff.* Design record plus the student's predicted SD, for exercise 5.

**Lab 3: Which standard error covers? (stored simulation result).**
- *Question.* Does the interval that looks most precise cover?
- *Invariants.* Stored $R=500$ draws (`l11_mc_course_summary_R500.csv`,
  `l11_mc_as_summary_R500.csv`, with seeds, engine hash, and date).
- *Controls.* Design; $T$; $N$; $h$; method (unit, time, two-way,
  Driscoll–Kraay, HC); an AS panel with $\bar R^2$ and $p\in\{0,1\}$.
- *Display.* Coverage against $N$ with a nominal line and MC bands; the AS
  panel sits beside the published Table 1 values.
- *Reactive sentence.* "Clustering by unit covers 8.6 percent of the time at
  $N=320$ because the horizon-2 error is shared across units at each date;
  clustering by date covers 88.6 percent with only 37 dates."
- *Comparisons.* $N$ up with the method fixed; $h$ from 0 to 2 in E.
- *Handoff.* The selected coverage rows, for exercise 6's comparison.

**Lab 4: Recession paths, read correctly (stored Stata result).**
- *Question.* What does the 6.18-point gap measure?
- *Invariants.* The benchmark CSV and the audit CSV.
- *Controls.* Paths (mean credit, +1 SD); inference (OLS, HC1, country, year,
  two-way); a gap view.
- *Display.* Each inference choice shows the gap's SE, $t$-ratio, and $p$-value
  on Stata's reference distribution: $t$ with 90 degrees of freedom for OLS and
  HC1 ($p$ = 0.0011, 0.0036), and $t$ with $G-1$ under clustering: country 13
  ($p$ = 0.0122), year 57 (0.0026), two-way 13 (0.0131).
- *Prediction prompt.* "Is the gap the effect of a financial crisis on GDP?"
- *Reactive sentence.* "Under year clustering (58 peak years) the gap at $h=5$
  is $-6.18$ with SE 1.96 ($t=-3.15$, $p=0.003$ on 57 degrees of freedom). It compares episodes classified after the fact,
  conditional on seven controls; no shock was assigned."
- *Collapsed explanation.* What a causal reading would need: an as-good-as-random
  crisis classification given $\mathbf w_{i,t}$, and no selection of peaks by
  outcomes. A second note explains why 14 country clusters are few: the
  $t_{13}$ reference is already wider than the normal, and cluster-robust SEs
  can still be too small.
- *Handoff.* The chosen inference specification and a two-sentence
  interpretation, for exercise 9.

---

## 8. Practicum plan (REP11, STA11, HTML11 handoff)

### 8.1 REP11: reconstruct historical recession paths

- **Target (D16).** Jordà, Schularick, and Taylor (2013), *JMCB* 45(s2),
  3–28, Figure 4, GDP panel. Four paths for $h=0,\dots,5$: normal and
  financial, at mean excess credit and at +1 within-type SD. The kind is
  **exact numerical replication**. The notes call the result a conditional
  comparison of recession paths.
- **Data and vintage.** `WCBB_replication_14aug2015` from the author landing
  page (SOURCE.md URL; SHA-256 `5e61b6492115bf2adc13ac63f86bb4e7846dda47c5b0c07dab687ed1dd298899`),
  `panel14_1_oj.dta`: 1,946 rows, 14 countries, 1870–2008. Never R6.
- **Script and lines.** `programs/all.do` (forces `version 12.0`) runs
  `data_Oct2012.do`, `Table2_Oct2012.do`, `AMTamplitudes_Oct2012.do`, and
  `AMTregressions_Oct2012.do`. Lines 1038–1058 hold the regressions and
  `lincom`s, 1069–1099 the bands, 1219–1221 the export. SSC `estout` is
  required (D4).

**Benchmark** (`REP11-historical-recession-paths.csv`; coefficient with OLS
SE in parentheses, $N=121$; $h=0$ imposed as 0):

| $h$ | Normal, mean | Financial, mean | Normal +1 SD | Financial +1 SD |
|---|---|---|---|---|
| 1 | −1.271308 (0.359891) | −2.827924 (0.574213) | −1.802208 (0.434171) | −3.835402 (0.755846) |
| 2 | 0.692653 (0.643817) | −4.135313 (1.027221) | −0.680188 (0.776697) | −6.626399 (1.352148) |
| 3 | 3.178779 (0.868926) | −3.585679 (1.386386) | 1.630665 (1.048267) | −4.524948 (1.824924) |
| 4 | 3.838303 (1.122219) | −2.750529 (1.790521) | 1.966768 (1.353840) | −6.012553 (2.356894) |
| 5 | 4.812954 (1.197178) | −1.364781 (1.910119) | 3.384338 (1.444269) | −3.615045 (2.514322) |

- **Tolerance.** Absolute $10^{-5}$ on coefficients and SEs; $N$ exact.
  StataNow 19.5 achieves $4.6\times10^{-7}$, so no D1 software row is needed,
  only an agreement row.
- **Runtime.** 40.6 s in 18.5 (MANIFEST); 18.2 s in 19.5 (this pass).
- **Departures.** The author code is unchanged. Preserve/restore discards the
  figure columns, so `rep11_extract.do` re-runs the Figure 4 block after
  `all.do` and posts double-precision values; `rep11_audit.do` is the model.
- **Discrepancy log.** Software: agreement. Definition: +1 SD scalers from
  119/35 episodes, not 92/29. Inference: OLS SEs, reported as the authors'.
  Code: `pk_glob` never set. Scope: `core` ends 2003. Documentation: spine
  wording (§10).
- **Redistribution (D5).** The historical archive has no license.
  `data/raw/get_data.do` downloads from the author URL, verifies SHA-256,
  unzips, and stops with a message on failure; `PROVENANCE.md` gives the
  manual route. The JST R6 extension (exercise 9 variant, labeled) ships
  `JSTdatasetR6.dta` with the CC BY-NC-SA 4.0 notice. SR1090's code (no
  license) is linked, not shipped.

### 8.2 STA11: Stata problem set (construct, estimate, diagnose, interpret)

1. *Panel LP and sample by horizon* (`sta11_1_panel_lp.do`, acquired data).
   Loop $h=1..5$ with `regress lrgdp`h' pk_fin srx_norm_prv srx_fin_prv
   $rhs7 ibn.ccode if core==1, noconstant`, posting $N_h$, type counts,
   countries, and years. Assert $N_h=121$, 92/29, and that the mean country
   intercept equals the author's `pk_norm` to $10^{-6}$. Then relax the
   five-lead restriction as a labeled variant and tabulate $N_h$ by horizon.
2. *Absorption* (`sta11_2_absorb.do`, shipped `l11_panel_seed11.dta`). The
   exercise 3 assertions.
3. *Exposure interactions* (`sta11_3_exposure.do`). Simulate (E) with
   $\psi\in\{0,0.5\}$ and a binary-$e$ variant, $R=200$. Assert that the mean
   of $\hat\beta^{e}_h$ is within 3 MC SEs of $\psi\rho^h$, and state the
   estimand in comments.
4. *Inference under aggregate dependence* (`sta11_4_inference.do`). The
   exercise 6 design with `vce(cluster id)`, `vce(cluster t)`,
   `vce(cluster id t)`, and `mata/l11_engine.mata` for Driscoll–Kraay and for
   time clustering with lags. Coverage is written to `coverage_sta11.csv`,
   with assertions against the stored rows.
5. *What $N$ adds* (`sta11_5_neff.do` plus interpretation). The $N_{\mathrm{eff},h}$
   table for $N\in\{5,20,80,320,\infty\}$, $h\in\{0,2\}$, and one paragraph
   that uses the JST sample record (58 dates).

**Starter layout** (`lab-project/`): `master.do`; `do/`; `mata/l11_engine.mata`
(validated against `regress` to $10^{-8}$); `data/raw/get_data.do`;
`data/sim/l11_panel_seed11.dta`; `tests/`; `output/`.

**Outputs:** `sample_by_h.csv`, `rep11_compare.csv`, `coverage_sta11.csv`,
`neff.csv`, `fig_recession_paths.pdf`.

**Runtime** (StataNow 19.5 batch, `l11_timing_regress.do`, $R=200$, panels
from the engine's `simpanel`): Mata engine ≈ 10 s. Exercise 5's
`regress y s L.y L.s i.id, vce(cluster t)` loop takes 9.6 s at its largest cell
($N=80$, $T=160$) and 15.3 s over all four cells. Task 4's three `regress`
fits (`vce(cluster id)`, `vce(cluster t)`, `vce(cluster id t)`) plus the Mata
Driscoll–Kraay per draw take 11.7 s at $N=80$ and 3.2 s at $N=20$. Both are far
below D2's 10 minutes, so neither is tagged [extra] (D26) or split by $N$.

### 8.3 Handoff and submission

- **Browser to Stata.** Lab 1's CSV feeds exercise 3, Lab 2's design record
  exercise 5, Lab 3's coverage rows exercise 6, and Lab 4's specification
  record exercise 9. Data move only by CSV; simulations agree within MC error.
- **Submission package** (blueprint §4.2):
  - *Replication record:* target, archive hash, `all.do` log, comparison
    table, discrepancy log.
  - *Stata submission:* `master.do`, logs, CSVs, figure, tests.
  - *Interpretation record:* estimand of each design; why REP11 is a
    conditional comparison; the inference choice defended from the source of
    variation.
  - *HTML record:* the four predictions and exports.

---

## 9. Slides arc

1. **Title.** Lecture 11: Panel LPs and common macroeconomic shocks.
2. **1,946 rows, 121 recessions, 58 years.** The sample record.
3. **The panel LP.** Unit effects re-estimated at each $h$; the sample by
   horizon.
4. **Time effects eat common shocks.** The collinearity note and the 1.132
   artifact.
5. **What survives.** $e_is_t$ and `fig-l11-exposure`: a gradient, not a level.
6. **A panel is a time series in disguise.** The synthetic series.
7. **Effective sample size.** `fig-l11-effective-sample`: ceilings of 2 and
   1.51.
8. **More units, worse coverage.** `fig-l11-coverage-by-n`.
9. **Match the cluster to the shared shock.** The AS Table 1 reproduction;
   time clustering with lags.
10. **What a pooled coefficient averages.** Balanced, unbalanced, nonlinear
    exposure.
11. **Recession paths.** `fig-l11-recession-paths`: intercepts by type, not
    responses.
12. **Auditing Figure 4.** Five SEs for one gap; the SD-sample discrepancy.
13. **Fixed effects and lags.** Nickell bias in numbers.
14. **Lab, exercises, and the question for Lecture 12.**

---

## 10. Open questions for the editor

1. **Spine text.** The Lecture 11 opening says "seventeen countries" and
   "fewer than two hundred recessions"; the archive has 14 countries, 298
   peaks, and 121 in the regression. Evidence step 8 still says "release 6".
   D16 settles the substance; the spine needs an edit outside this brief's
   scope.
2. **New notation.** Approve for the ledger (as D20 did for Lectures 7–8):
   $\theta_{i,h},\bar\theta,\psi,\zeta_t,v_{i,t},\beta^{e}_h,\sigma^2_{A,h},\sigma^2_{I,h},N_{\mathrm{eff},h},\bar R^2_h$,
   and the JST symbols $\mathcal P,P^{\mathrm N},P^{\mathrm F},\tilde x,\mu^{\mathrm N}_h,\mu^{\mathrm F}_h,\chi_h,\sigma_x$.
3. **Glossary key.** Add `synthetic-time-series` (D22), or keep it as a
   footnote?
4. **Driscoll–Kraay validation.** `xtscc` (optional, D4) is not installed, so
   the course Mata Driscoll–Kraay is unvalidated against it. Allow a one-time
   install in the instructor build, or label the estimator "course
   implementation"?
5. **Financial-recession timing rule.** The archive hand-codes the 67 peaks
   and states no rule. Quote the rule from the frozen article; the section and
   page are to confirm (D31).
6. **AS recommended inference.** Port the AIC lag rule and the Imbens–Kolesár
   refinement to Mata (instructor task, R/MATLAB source without license), or
   teach plain time-clustered, lag-augmented inference only (current plan)?
7. **SHA-256 in Stata.** There is no built-in command. Approve shelling out
   (`shasum -a 256` on macOS/Linux, `certutil -hashfile` on Windows) as the
   course convention for `get_data.do`.
8. **Exercise 6 tolerance.** In `l11_timing_regress.do` (its own draws,
   $R=200$), `regress … vce(cluster t)` covered 0.945 at $N=20$ and 0.915 at
   $N=80$, which is 0.053 and 0.051 above the Mata-stored 0.892 and 0.864 and
   outside the $3\sqrt{0.05\cdot0.95/R}=0.046$ check. Stata's cluster SE
   carries $\tfrac{G}{G-1}\tfrac{n-1}{n-k}$, the engine only $\tfrac{G}{G-1}$,
   and the check ignores the stored run's own MC error. Store exercise 6's
   comparison rows from a `regress` run, or widen the tolerance?
