# Lecture 12 brief — LP difference-in-differences

Planning brief for Lecture 12 of *Local Projections: From First Principles to
Empirical Research*. Browser lab: `interactives/12-clean-control-builder.qmd`
("Clean-Control Builder"). Practicum: `practica/p12-lp-did/`.

**Status and provenance.** Numbers come from (i)
`benchmarks/REP12-banking-lpdid.csv` (Stata/SE 18.5) and its raw
companions; (ii) the 19.5 rerun of the unmodified DGJT workers
(`design-12/rep12/rep12_195.do`, D1); (iii) course computations on the same
panel (`bank12.do`, `check_builtin.do`), which are not benchmark rows; and
(iv) the course simulation `design-12/sim/sim12.do` (seed 12; $R=200$ student
default, $R=500$ instructor build, D2),
never called a replication (D17). Every final run used StataNow/SE 19.5, and
none of their logs contains an `r(#);` line. Decisions applied: D1, D2, D4,
D5, D17, D24, D26, D30, D31.

## 1. Session brief

**Opening situation.**
Lecture 11 ended with units that switch on at different dates. Here are
46 of them. Between 1978 and 1993 the U.S. states in the
Dube–Girardi–Jordà–Taylor (DGJT) sample removed barriers to interstate
banking. The switch-on years span 13 dates: one state in 1978, nine in 1985,
ten in 1986, nine in 1987, and the last in 1993. By 1993 every state is
treated. A two-way fixed effects regression of the private-sector labor share
(mean 0.526 over 1,242 state-years, 1970–1996) on the deregulation dummy
gives −0.0123 (state-clustered s.e. 0.0031), about 1.2 percentage points.
That number is a weighted sum over the 489 treated state-years. In it, 150
treated state-years carry *negative* weight, summing to −0.177. Arizona in
1993–1996 and Connecticut in 1989–1993 are among them. In those cells,
states that deregulated early serve as controls for late deregulators while
their own labor shares are still moving. DGJT rebuild the comparison. Each
newly deregulated state is compared only with states still regulated at the
outcome date. On this sample the labor share falls 0.49 percentage points in
the deregulation year and 2.07 points four years later. Run the same
long-difference regression with the same time effects, but let
already-deregulated states act as controls, and the four-year response
shrinks to 0.42 points. The data, fixed effects, and dependent variable are
unchanged; only the sample rows differ.

**Decision or empirical question.**
How should a local projection be built when units enter treatment at
different dates? In operational terms, a researcher with a staggered,
absorbing policy panel must decide:

- which $(i,t)$ rows may enter the horizon-$h$ regression;
- what weighted average of cohort-specific effects the coefficient then
  estimates, and whether to reweight it;
- what the negative-horizon coefficients can say about parallel trends, and
  when they say nothing.

The lecture's answer:

- regress $y_{i,t+h}-y_{i,t-1}$ on $\Delta D_{i,t}$ with time effects, keeping
  only newly treated rows and clean controls, the rows with $D_{i,t+h}=0$;
- by default the coefficient is a variance-weighted average of cohort effects
  with nonnegative weights, and reweighting by the inverse of the untreated
  share turns it into an equally weighted one;
- pre-horizon coefficients diagnose parallel trends only if the controls do
  not span them by construction.

**Target student and prerequisites.**
Has completed Lectures 1–11. Uses from earlier lectures:

- the long difference and cumulative response (L2);
- conditional exogeneity, anticipation, and Frisch–Waugh–Lovell (L3);
- clustered standard errors (L11);
- the panel LP with unit and time fixed effects, and what a pooled
  coefficient averages when responses differ (L11);
- the weighted-average reading of a linear coefficient, as prose (L10).

Mathematics: within-group demeaning, weighted least squares, and the
difference of two group means. Stata: `xtset`; the `F.`, `L.`, and `D.`
operators; `regress … i.year, vce(cluster statenum)`; `bysort … egen`;
`postfile`; and `lpdid` (D4). `lpdid` and the authors' workers need SSC
packages beyond D4's required list; §8.1 *Dependencies* lists them, and
`check_deps.do` stops with install instructions if one is missing (§10, Q1).

**Learning outcomes (five).** By the end, the student can:

1. Describe a staggered absorbing design with $D_{i,t}$, $g_i$, $\Delta D_{i,t}$,
   and event time $k$. On a cohort timeline, name the comparisons a
   two-way fixed effects regression makes and mark which are forbidden.
   Compute the regression's implicit weights on treated cells and find the
   negative ones.
2. Build the horizon-$h$ LP-DiD estimation sample by hand, estimate the
   regression with built-in commands, and match `lpdid` to $10^{-6}$.
3. Derive that the coefficient equals
   $\sum_g q_{g,h}\,\theta_{g,h}$ with
   $q_{g,h}\propto N_gN^{\mathrm{cc}}_{g,h}/(N_g+N^{\mathrm{cc}}_{g,h})$.
   Show that weights $1/(1-\overline{\Delta D}_{t,h})$ turn it into an equally weighted
   average, and say which average a stated question needs.
4. State no anticipation and parallel trends as restrictions on potential
   outcomes, and read negative horizons as a diagnostic. Recognize when a
   pre-horizon coefficient is zero by construction, as in DGJT
   specifications C and D at $h=-2,\dots,-5$.
5. Reproduce DGJT Figure 3 exactly from the authors' loops and cross-check
   it with `lpdid`. Explain what the nonabsorbing extension adds: the
   effect-stabilization window and its assumption.

**Anchor example.**

*Empirical anchor.* The data are the DGJT *Journal of Applied Econometrics*
archive 1.0 (data DOI 10.15456/jae.2025155.1159719289, readme 4 June 2025),
frozen in `replication-packages/packages/lpdid/publication-original/`. Raw
inputs are Leblebicioglu–Weinberger (2020) `state_industry_replication.dta`
and `banking_law_indicators.dta`. They are processed by
`collapse_lshare_dataset.do`, which runs as follows:

- line 6 creates `laborsh_private = comp_private/gsp_private`;
- line 10 collapses to state-years;
- line 12 drops AK, HI, SD, DE, DC;
- line 13 keeps 1970–1996.

The result is a balanced panel of 46 states × 27 years = 1,242 rows.

| Variable | Definition | Units and facts (19.5 run) |
|---|---|---|
| `laborsh_private` | Private labor compensation / private gross state product | Ratio; mean 0.5260, s.d. 0.0547. Coefficients × 100 are percentage points. |
| `intbanking` | Interstate banking permitted | 0/1, absorbing (0 reversals). Cohorts 1978 (1), 1982 (1), 1983 (2), 1984 (3), 1985 (9), 1986 (10), 1987 (9), 1988 (4), 1989 (2), 1990 (1), 1991 (2), 1992 (1), 1993 (1). No never-treated state. |
| `intbranching` | Intrastate branching permitted | 0/1, absorbing (0 reversals). Ten states already treated in 1970 (always treated in-sample); the rest 1975–1994. No never-treated state. |
| `statenum`, `year` | Panel identifiers | 46 clusters |

The DGJT regression (specification A, `figure_3.do` lines 28–46) is
`reghdfe D`j'y D.intbanking if D.intbanking==1 | F`j'.intbanking==0, absorb(year) vce(cluster statenum)`,
with `D`j'y = F`j'.laborsh_private - L.laborsh_private`. It runs for
$h=0,\dots,9$. The pre-horizons $j=2,\dots,9$ use
`Dm`j'y = L`j'.laborsh_private - L.laborsh_private` on the sample
`D.intbanking==1 | intbanking==0`. Horizon $-1$ is the normalization.
Specifications B–D add, in turn: the other reform's leads and lags; four lags
of the level and of the first difference of the outcome; and four lags of
`grgsp`, `corptax`, and `unionmem`.

*Simulation anchor (course-built; "SIM12").* The design has
$N=40$ units observed for $t=1,\dots,20$. There are four cohorts,
$g\in\{5,8,11,14\}$, with six units each; the other 16 units are never
treated. The effects are linear ramps that differ by cohort,
$\theta_{g,k}=\theta_{g,0}\,(k+1)$ for $k\ge0$, with impact responses $\theta_{g,0}=(1,\,0.75,\,0.5,\,0.25)$ for $g=(5,8,11,14)$. They
are measured in outcome units, and later cohorts respond more slowly. The
outcome is
$y_{i,t}=\eta_i+\phi_t+\theta_{g_i,t-g_i}\mathbb 1\{t\ge g_i\}+\sigma\varepsilon_{i,t}$,
with:

- $\eta_i\sim\mathcal N(0,1)$;
- $\phi_t=0.2t+\sin t$;
- $\varepsilon_{i,t}$ i.i.d. $\mathcal N(0,1)$ and $\sigma=1$.

Seed 12; $R=200$ for students and 500 for the instructor build (D2);
pre-window $Q=4$; $H=5$. The noiseless version sets $\sigma=0$ and
$\eta_i=i/10$ and gives exact population values. There are three variants:

- anticipation, an effect of $0.5$ at $k=-1$;
- a divergent trend, $+0.1t$ for cohort 5 only;
- no never-treated units.

Population targets (§6.3):

| $h$ | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| $\theta^{\mathrm{VW}}_h$ | 0.640926 | 1.281853 | 1.922779 | 2.556664 | 3.195830 | 3.834996 |
| $\theta^{\mathrm{ATE}}_h$ | 0.625 | 1.25 | 1.875 | 2.5 | 3.125 | 3.75 |

**Smallest useful model (ledger notation).**
Potential outcomes $y_{i,t}(g)$ are indexed by treatment date, with
$y_{i,t}(\infty)$ the untreated path. The cohort effect is
$\theta_{g,h}=\mathbb E[y_{i,g+h}(g)-y_{i,g+h}(\infty)\mid g_i=g]$. The
LP-DiD regression at horizon $h$ is

$$
y_{i,t+h}-y_{i,t-1}=\beta_h\,\Delta D_{i,t}+\phi^{(h)}_t+u_{i,t,h},
\qquad (i,t)\in\mathcal T_h=\{\Delta D_{i,t}=1\}\cup\{D_{i,t+h}=0\}.
$$

Under no anticipation and parallel trends,
$\beta_h=\sum_g q_{g,h}\theta_{g,h}=\theta^{\mathrm{VW}}_h$, with
$q_{g,h}=\dfrac{N_gN^{\mathrm{cc}}_{g,h}/(N_g+N^{\mathrm{cc}}_{g,h})}{\sum_{g'}N_{g'}N^{\mathrm{cc}}_{g',h}/(N_{g'}+N^{\mathrm{cc}}_{g',h})}$.
Weighting each date-$t$ row by $1/(1-\overline{\Delta D}_{t,h})$, where $\overline{\Delta D}_{t,h}$ is
the treated share of the sample rows at date $t$, gives
$\theta^{\mathrm{ATE}}_h=\sum_gN_g\theta_{g,h}/\sum_gN_g$. Both sums run over
cohorts with $N^{\mathrm{cc}}_{g,h}>0$.

**Dependency chain of sections.** The eight spine steps, in spine order.

1. `#sec-l12-staggered-adoption` *Staggered absorbing treatment and the
   forbidden comparison.* Once cohorts switch on at different dates, a
   two-way fixed effects regression uses already-treated units as
   controls. Their outcomes are still responding, so some treated cells
   get negative weight (150 of 489 in the banking panel).
2. `#sec-l12-lp-did-regression` *The LP-DiD regression.* A long difference
   from $t-1$, the switch $\Delta D_{i,t}$, and time effects form the
   Lecture 11 panel LP. What makes it a clean DiD is restricting the sample
   to newly treated rows and rows still untreated at $t+h$.
3. `#sec-l12-estimand` *What the coefficient averages.* Frisch–Waugh–Lovell
   within each date turns $\beta_h$ into a nonnegative, variance-weighted
   average of cohort effects. Weighting rows by $1/(1-\overline{\Delta D}_{t,h})$
   produces the equally weighted average, and the research question decides
   which one to report.
4. `#sec-l12-assumptions` *No anticipation, parallel trends, and what
   pre-trends can show.* The estimand needs both assumptions. Negative
   horizons check an implication of parallel trends, but not when
   lagged-outcome controls make them zero by construction.
5. `#sec-l12-manual-vs-lpdid` *Building the eligibility table by hand, then
   matching `lpdid`.* A cohort-by-horizon table of treated units, clean
   controls, and exclusions reproduces the coefficient exactly. The command
   then reproduces the table, and its options map onto rows and weights.
6. `#sec-l12-nonabsorbing` *Nonabsorbing treatment.* When units can exit
   and re-enter treatment, "clean" needs an effect-stabilization window
   $\bar k$ or a first-treatment restriction, and each adds an assumption.
7. `#sec-l12-evidence` *Evidence: banking deregulation and the labor share.*
   Reproduce DGJT Figure 3 exactly, audit its samples by horizon, and compare
   the variance-weighted, equally weighted, and composition-fixed versions,
   each labeled as a course computation.
8. `#sec-l12-handoff` *Handoff.* A defended LP-DiD estimate is an average
   over specific cohorts, horizons, and controls. The next question is which
   of a paper's conclusions follow from it.

**Central notation.** Ledger §7: $i$, $N$; $y_{i,t+h}$; $\eta_i$; $\phi_t$
and $\phi^{(h)}_t$; $D_{i,t}$; $g_i$ (with $g_i=\infty$ for never treated);
$\Delta D_{i,t}$; $k=t-g_i$; $\theta^{\mathrm{ATE}}_h$ and
$\theta^{\mathrm{VW}}_h$; clustering by unit. New and local to this lecture
(§2): $y_{i,t}(g)$, $\theta_{g,h}$, $N_g$, $N^{\mathrm{cc}}_{g,h}$,
$q_{g,h}$, $\overline{\Delta D}_{t,h}$, $u_{i,t,h}$, $\tilde D_{i,t}$, $Q$, and $\bar k$.
$\mathcal T_h$ keeps its ledger meaning; it is a set of $(i,t)$ rows here, so
its size is written $|\mathcal T_h|$.

**Glossary terms (owned keys only; one-sentence definitions in §3).**

- `staggered-adoption`: units enter treatment at different dates.
- `absorbing-treatment`: once treated, always treated.
- `treatment-cohort`: units sharing a treatment date $g$.
- `event-time`: $k=t-g_i$.
- `clean-control`: a row still untreated at $t+h$.
- `not-yet-treated`: treated after the window, or never.
- `already-treated`: treated before $t$; still responding.
- `forbidden-comparison`: a DiD contrast with an already-treated control.
- `parallel-trends`: equal expected untreated changes from $t-1$ to $t+h$.
- `no-anticipation`: pre-$g_i$ outcomes equal untreated ones.
- `variance-weighted-ate`: the cohort average weighted by $q_{g,h}$.
- `equally-weighted-ate`: the average over treated units, each counted once.
- `reweighting`: row weights that move cohort weights to a target.
- `pre-trend`: the $h\le-2$ coefficient; a diagnostic unless forced to zero.
- `two-way-fixed-effects`: unit and time effects; averages forbidden comparisons under staggered heterogeneous effects.
- `nonabsorbing-treatment`: treatment that can switch off and on.

**Likely footnotes.** Goodman-Bacon decomposition; negative weights
(de Chaisemartin–D'Haultfœuille); Sun–Abraham event-study contamination;
Callaway–Sant'Anna and Borusyak–Jaravel–Spiess (DGJT §5 comparisons); ATE
versus ATT naming (§10, Q2); composition and `nocomp`; PMD baseline; wild
cluster bootstrap; regression adjustment (DGJT §4.1.1–4.1.2); singleton rows
(§6.6); `mkmat … nomissing` and $h=-1$.

**Candidate figures** (D24: each answers one question; one is marked
droppable).

| Label | Question | Lesson | Data or formula |
|---|---|---|---|
| `fig-l12-cohort-timeline` | At horizon 4, which state-years may serve as controls for the 1985 deregulators? | Of 46 states, 9 are treated, 5 are clean controls, 7 are already treated, and 25 switch between 1986 and 1989. Most of the panel is excluded. | `bank12_eligibility.csv` ($h=4$, cohort 1985) plus cohort years |
| `fig-l12-twfe-weights` | Which treated state-years does static TWFE weight negatively? | Late years of early deregulators: 150 of 489 cells, total weight −0.177 | Residual $\tilde D_{i,t}$ from `bank12.do` |
| `fig-l12-sim-estimators` | On a design with known effects, which estimator recovers which average? | Clean-control LP-DiD tracks $\theta^{\mathrm{VW}}_h$, reweighted LP-DiD tracks $\theta^{\mathrm{ATE}}_h$, and naive LP and TWFE event study miss both | `sim12_mc_summary_R500.csv` from the instructor build (`sim12.do 500`, D2; mean ± 2 Monte Carlo s.e.) with the truth rows |
| `fig-l12-reweighting` | How different are variance weights and equal weights across banking cohorts, by horizon? | Variance weights favor cohorts with balanced treated and control counts; by $h=9$ only 3 cohorts and 4 treated states remain | $q_{g,h}$ and $N_g/\sum N_g$ from `bank12_eligibility.csv` |
| `fig-l12-figure3` | Does the deregulation response survive the four specifications? | In the interstate banking panel, all four specifications decline, with bands excluding zero, through $h=4$. Specification A has positive pre-horizons; in C and D, horizons −2 to −5 are zero by construction | Benchmark CSV (152 rows) |
| `fig-l12-spanned-pretrends` (droppable; a table can do it) | Which pre-horizons can specification C test? | Only $-6,\dots,-9$ | Benchmark C rows |

**Exercise capabilities to test.** Mark clean, already-treated, and
treated-between rows on a timeline. Compute TWFE weights on a three-unit
toy, then drop its never-treated unit and find the negative weight. Derive the variance weights. Build and verify the reweighting factor.
Build the eligibility table and regression in Stata and match `lpdid`.
Diagnose a sample that admits already-treated controls. Identify pre-trend
coefficients that are zero by construction. Reproduce Figure 3. Write the
assumptions for a nonabsorbing design.

**Controlled experiments (lab and STA12).**

1. Admit already-treated rows, then treated-between rows, as controls,
   holding the data fixed.
2. Change cohort sizes and add or remove never-treated units, and watch the
   gap between $\theta^{\mathrm{VW}}_h$ and $\theta^{\mathrm{ATE}}_h$.
3. Turn on anticipation at $k=-1$.
4. Give one cohort a divergent trend.
5. Remove the never-treated units, so the last cohort loses every clean
   control.
6. Fix the control set across horizons (`nocomp`) and see the composition
   effect.

**What is postponed.** Continuous and multivalued treatments; synthetic
control; spillovers across units; inference with few treated clusters
(footnote only); regression adjustment with many covariates
(footnote only); and sensitivity analysis for violations of parallel trends (further reading;
L13's grid treats sample and specification sensitivity only).

**Question handed on.** Which of a paper's conclusions follow from the
estimated response, and which require assumptions it has not stated?

## 2. Concept and notation ledger

Ledger symbols keep their ledger meaning. Rows marked *new* are local to
Lecture 12 and are proposed for notation-ledger §7 (§10, Q3). Collision
check against the ledger and D20: $s$, $a$, $b$, $c$, $\delta_k$,
$\lambda$, $\tau$, $\kappa$, $\omega$, $\pi$, $p$, $m$, $r$, and $L$ are
already taken. So the simulated ramp is written with $\theta_{g,0}$, not a
slope letter; cohort weights are $q_{g,h}$, not $\omega$; the within-date
treated share is $\overline{\Delta D}_{t,h}$, not $\bar s$; and the
stabilization window is $\bar k$, not DGJT's/`lpdid`'s $L$. Anticipation is
written as a nonzero $\theta_{g,-1}$, not a new letter.

| Symbol | Meaning | Dimension | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $i$, $N$ | Unit index; number of units | scalar | — | 46 states (banking); 40 (SIM12) | `#sec-l12-staggered-adoption` | all sections; L13 grid |
| $t$, $T$ | Calendar period; panel length | scalar | $t=1970,\dots,1996$ ($T=27$); SIM12 $t=1,\dots,20$ | years | same | all |
| $y_{i,t}$ | Outcome | scalar | dated $t$ | banking: ratio (× 100 = percentage points of private GSP); SIM12: outcome units | same | all |
| $y_{i,t}(g)$ *new* | Potential outcome if unit $i$'s treatment date is $g$; $y_{i,t}(\infty)$ untreated | scalar | dated $t$ | as $y$ | `#sec-l12-estimand` | assumptions, nonabsorbing |
| $D_{i,t}$ | Absorbing treatment indicator | $\{0,1\}$ | status during period $t$ | — | `#sec-l12-staggered-adoption` | regression, lab, `lpdid treat()` |
| $g_i$ | Treatment date (cohort); $\infty$ if never treated | scalar | calendar period | years | same | eligibility table, weights |
| $\Delta D_{i,t}$ | Treatment switch, $D_{i,t}-D_{i,t-1}$ | $\{0,1\}$ under absorption | equals 1 at $t=g_i$ | — | `#sec-l12-lp-did-regression` | all estimators; Stata `dD` |
| $k$ | Event time, $t-g_i$ | integer | — | periods | `#sec-l12-staggered-adoption` | TWFE event study, anticipation $\theta_{g,-1}$ |
| $h$ | Horizon, $h=-Q,\dots,-2,0,\dots,H$ | integer | outcome at $t+h$, baseline $t-1$ | periods | `#sec-l12-lp-did-regression` | pre-trends ($h<0$) |
| $H$; $Q$ *new* | Post-treatment horizon; pre-window length (DGJT's $Q$) | scalar | — | periods; banking $H=Q=9$, SIM12 $H=5$, $Q=4$ | same | lab, STA |
| $\eta_i$, $\phi_t$, $\phi^{(h)}_t$ | Unit effect; time effect; horizon-specific time effect | scalar | — | as $y$ | same | TWFE, LP-DiD |
| $u_{i,t,h}$ *new* | Row-$(i,t)$ residual of the horizon-$h$ regression | scalar | contains outcomes through $t+h$ | as $y$ | same | inference (clustered by unit) |
| $\mathcal T_h$, $\lvert\mathcal T_h\rvert$ | Horizon-$h$ estimation sample of $(i,t)$ rows; its size | set; count | — | rows (752 at $h=0$, spec. A) | same | eligibility table, `nocomp` |
| $\beta_h$, $\hat\beta_h$ | LP-DiD coefficient on $\Delta D_{i,t}$ within $\mathcal T_h$; its estimate | scalar | — | $y$ units per switch | same | all |
| $\theta_{g,h}$ *new* | Cohort effect $\mathbb E[y_{i,g+h}(g)-y_{i,g+h}(\infty)\mid g_i=g]$ | scalar | at $t=g+h$ | $y$ units | `#sec-l12-estimand` | weights, lab, SIM12 design |
| $\theta^{\mathrm{VW}}_h$, $\theta^{\mathrm{ATE}}_h$ | Variance-weighted and equally weighted averages of $\theta_{g,h}$ over cohorts with clean controls | scalar | — | $y$ units | same | reweighting, lab, REP12 extension |
| $N_g$ *new* | Treated units in cohort $g$ with $y_{i,g+h}$ observed | count | — | units | same | weights |
| $N^{\mathrm{cc}}_{g,h}$ *new* | Clean controls at date $g$ for horizon $h$: $\#\{i:g_i>g+h\}$ with outcome observed | count | — | units | `#sec-l12-lp-did-regression` | weights, eligibility table |
| $q_{g,h}$ *new* | Variance weight on cohort $g$ at horizon $h$ | scalar in $[0,1]$, sums to 1 | — | — | `#sec-l12-estimand` | reweighting figure, lab |
| $\overline{\Delta D}_{t,h}$ *new* | Treated share among $\mathcal T_h$ rows at date $t$ | scalar | — | — | same | reweight $1/(1-\overline{\Delta D}_{t,h})$ |
| $\tilde D_{i,t}$ *new* | Residual of $D_{i,t}$ on unit and time effects | scalar | — | — | `#sec-l12-staggered-adoption` | TWFE weights $\tilde D_{i,t}/\sum_{D=1}\tilde D$ |
| $\beta^{\mathrm{TWFE}}$ *new* | Static TWFE coefficient on $D_{i,t}$ | scalar | — | $y$ units | same | evidence |
| $\bar k$ *new* | Effect-stabilization window for nonabsorbing treatment (`lpdid`'s `nonabsorbing(#)`) | integer | periods after an event | periods | `#sec-l12-nonabsorbing` | STA12 extra |
| $R$ | Monte Carlo replications | scalar | — | 200 students / 500 instructor (D2) | `#sec-l12-estimand` (SIM12) | STA12 |

**Stata names (mirror the ledger).** `D`, `dD`, `g`, `k`, `Dy`h'`
($y_{i,t+h}-y_{i,t-1}$), `Dym`j'` ($y_{i,t-j}-y_{i,t-1}$), `cc_`h'` (the
$\mathcal T_h$ flag), `rw_`h'` ($1/(1-\overline{\Delta D}_{t,h})$), and
`beta_h`, `se_h`. REP12 keeps the authors' names (`intbanking`,
`D`j'y`, `Dm`j'y`, `b_lpl*`) and adds a one-table mapping in its README.

## 3. Terminology ledger

Owned keys come from the terminology plan. No new keys are requested.
Earlier-owned terms appear as prose with a link.

| Phrase | Treatment | Key | Definition | First marked |
|---|---|---|---|---|
| staggered adoption | glossary | `staggered-adoption` | Units enter treatment at different dates, so the comparison group must be chosen date by date. | `#sec-l12-staggered-adoption` |
| absorbing treatment | glossary | `absorbing-treatment` | Treatment that never switches off, so $D_{i,t}$ is nondecreasing and $g_i$ summarizes it. | same |
| treatment cohort | glossary | `treatment-cohort` | The units sharing treatment date $g$, over which effects are defined and averaged. | same |
| event time | glossary | `event-time` | Periods since treatment, $k=t-g_i$, aligning cohorts across calendar years. | same |
| two-way fixed effects | glossary | `two-way-fixed-effects` | A unit-and-time-effects regression whose coefficient, under staggered heterogeneous effects, can weight treated cells negatively. | same |
| forbidden comparison | glossary | `forbidden-comparison` | A DiD contrast using an already-treated control, which subtracts that unit's ongoing effect. | same |
| already treated | glossary | `already-treated` | A unit treated before the comparison date, whose outcome may still be responding. | same |
| not yet treated | glossary | `not-yet-treated` | A unit treated after the comparison window, or never; a valid control until its date. | `#sec-l12-lp-did-regression` |
| clean control | glossary | `clean-control` | A row with $D_{i,t+h}=0$, the only control LP-DiD admits. | same |
| variance-weighted average effect | glossary | `variance-weighted-ate` | $\sum_gq_{g,h}\theta_{g,h}$, the target of unweighted LP-DiD. | `#sec-l12-estimand` |
| equally weighted average effect | glossary | `equally-weighted-ate` | $\sum_gN_g\theta_{g,h}/\sum_gN_g$, with each treated unit counted once. | same |
| reweighting | glossary | `reweighting` | Weighting rows by $1/(1-\overline{\Delta D}_{t,h})$ so that cohort weights become $N_g/\sum N_g$. | same |
| parallel trends | glossary | `parallel-trends` | Without treatment, newly treated units and clean controls have the same expected change from $t-1$ to $t+h$. | `#sec-l12-assumptions` |
| no anticipation | glossary | `no-anticipation` | Outcomes before $g_i$ equal untreated outcomes, so $t-1$ is a valid baseline. | same |
| pre-trend | glossary | `pre-trend` | The coefficient at $h\le-2$, informative only if the specification does not force it to zero. | same |
| nonabsorbing treatment | glossary | `nonabsorbing-treatment` | Treatment that can switch off and on, so clean controls need a stabilization window $\bar k$ or a first-treatment restriction. | `#sec-l12-nonabsorbing` |
| long difference; common sample; Monte Carlo simulation; statistical reproduction | prose, link L2 | L02 keys | `nocomp` is L2's common sample applied to the control set. | — |
| anticipation; identifying assumption; Frisch–Waugh–Lovell | prose, link L3 | L03 keys | `anticipation` stays L3's; `no-anticipation` is marked here. | — |
| weighted-average effect; negative weights | prose, link L10 | L10 keys | TWFE weights are a second instance of L10's reading. | — |
| clustered standard errors; unit and time fixed effects; heterogeneous response; effective sample size | prose, link L11 | L11 keys | Effective sample size reappears as treated cohorts per horizon (3 at $h=9$). | — |
| Goodman-Bacon; negative weighting; event-study contamination | footnotes | — | Static TWFE as a sum of 2×2 DiDs; cells with $\tilde D<0$; leads and lags that mix event times. | `#sec-l12-staggered-adoption` |
| ATE/ATT naming; composition effect | footnotes | — | DGJT's VWATT/ATT average over treated cohorts; control sets change with $h$ unless `nocomp` is used. | `#sec-l12-estimand` |
| singleton rows; PMD; wild bootstrap; regression adjustment | footnotes | — | §6.6; a baseline averaged over pre-periods; `bootstrap()`; DGJT §4.1.1. | `#sec-l12-manual-vs-lpdid` |
| `mkmat … nomissing` | footnote | — | Why the authors' plot omits $h=-1$. | `#sec-l12-evidence` |

## 4. Evidence and visual ledger

"Verified" means checked numerically in this pass. "Computed" means a 19.5
course computation, labeled as such wherever it appears (D17).

| Claim | Evidence | Medium | Source | Status | Label |
|---|---|---|---|---|---|
| Static TWFE −0.0123 (0.0031); 150 of 489 treated weights negative, summing to −0.177 | $\tilde D$ residual; manual −0.012299165 | figure | `bank12.do` | computed | `fig-l12-twfe-weights` |
| At $h=4$ the 1985 cohort has 9 treated, 5 clean, 7 already treated, 25 switching | Eligibility counts | figure | `bank12_eligibility.csv` | computed | `fig-l12-cohort-timeline` |
| $q_{g,h}$ formula reproduces specification A, $h=0..9$ | §6.2; largest gap $8.8\times10^{-10}$ | table | benchmark + eligibility | verified | `tbl-l12-weights-check` |
| Four-year answer by sample rule: clean −0.0207; not yet treated at $t$ −0.0078; all rows −0.0042 | One regression, three samples | table | `bank12_regs.csv` | computed | `tbl-l12-sample-rules` |
| VW −0.0207 vs EW −0.0213 at $h=4$; −0.0309 vs −0.0411 at $h=9$ (3 cohorts, 4 states); largest weight gap 0.391 at $h=7$ | `lpdid …, rw` | figure | `bank12_lpdid_A_rw.csv` | computed | `fig-l12-reweighting` |
| Pooled 0–9: VW −0.0133 (0.0102), EW −0.0209 (0.0118); pre 0.0060 (0.0024) | `lpdid` pooled | prose | `bank12` pooled CSVs | computed | — |
| `nocomp` ($\lvert\mathcal T_h\rvert=338$, $h=0$–5): $h=4$ −0.0041 (0.0103) | `lpdid …, nocomp` | footnote | `bank12_lpdid_A_nocomp.csv` | computed | — |
| Figure 3 in 19.5: 144 pairs, largest gap $4.9\times10^{-10}$ | `rep12_195.do` vs 18.5 benchmark (D1) | figure | benchmark CSV | verified | `fig-l12-figure3` |
| `lpdid` 1.0.3 equals authors' loops for A/C/D (54 pairs, $\le9.5\times10^{-10}$, same N) | `bank12.do` | practicum | `bank12_lpdid_{A,C,D}.csv` | verified | — |
| A pre-horizon bands exclude zero at −4, −5, −6, −8; C/D at −2…−5 zero by construction ($\le1.3\times10^{-17}$) | Benchmark; §6.5 | table | benchmark CSV | verified | `fig-l12-spanned-pretrends` (droppable) |
| Banking TWFE event study (binned ±9): +0.017 at −9, −0.067 at +9 | `bank12.do` | backup slide | `bank12_regs.csv` | computed | — |
| Noiseless SIM12: clean LP-DiD $=\theta^{\mathrm{VW}}_h$, reweighted $=\theta^{\mathrm{ATE}}_h$; naive LP 0.404 ($h=0$), 2.228 ($h=5$); TWFE event study 0.270, 6.074 (binned); static TWFE 2.264 vs treated-cell mean 5.190 | §6.3 | figure | `sim12_noiseless.csv` | verified | `fig-l12-sim-estimators` |
| SIM12, $R=200$: VW mean within 1.3 Monte Carlo s.e. of truth at every $h$; clustered coverage 0.945–0.985; naive coverage of $\theta^{\mathrm{ATE}}_5$ 0.03 | Summary CSV | table | `sim12.do 200` (58 s) | computed | `tbl-l12-sim-coverage`; exercise 9 |
| SIM12, $R=500$ (instructor build): VW mean within 1.2 Monte Carlo s.e. of $\theta^{\mathrm{VW}}_h$ and RW mean within 1.2 of $\theta^{\mathrm{ATE}}_h$ at every $h\ge0$; VW clustered coverage 0.918–0.982 over $h=-4,\dots,5$; naive coverage of $\theta^{\mathrm{ATE}}_5$ 0.03 | `sim12_mc_summary_R500.csv` | figure | `sim12.do 500` (148 s) | computed | `fig-l12-sim-estimators` |
| Anticipation 0.5: pre-horizons −0.5; $h=2$ 1.338 vs 1.923 | §6.4 | lab | noiseless | verified | Lab 4 |
| Cohort-5 trend: pre-horizons −0.027, −0.053, −0.080 | §6.4 | lab | noiseless | verified | Lab 4 |
| No never-treated: $\theta^{\mathrm{VW}}_0=0.7826$; static TWFE **−1.575** with all effects positive | §6.3 | lab, slide | noiseless | verified | Lab 2 |
| Toy: TWFE weights $(\tfrac12,0,\tfrac12)$, $\beta^{\mathrm{TWFE}}=1$ vs $\tfrac53$; without C $(1,-\tfrac12,\tfrac12)$, $\beta^{\mathrm{TWFE}}=0$ | §6.1 | exercise | exact fractions | verified | Exercise 2 |
| Author example (Stata 19 version line) runs in 19.5: 6 min 7 s; pooled truth 13.12, VW 14.03 (0.72), RW 13.83 (0.73) | `run_authorex.do` | practicum note | computed | instructor only | — |
| `regress … i.year` equals `reghdfe` $\hat\beta$; s.e. 0.0067349 vs 0.0067230 until singleton dates are dropped, then identical | `check_builtin.do`, `check_singletons.do` | footnote | computed | verified | — |

## 5. Assessment map

Ten exercises. Five are Stata [computational] (4, 5, 6, 8, 9) and one is
[data] (8). Exercise 9 is [extra] with $R=200$ (D26).

| Outcome | Exercise | Tags | Mode of work | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. Mark the timeline | [core] [pencil] | From the banking cohort table, classify all 46 states for the 1985 cohort at $h=0$ and $h=4$ | Ask of each state: "is it untreated in 1989?" | Treated/clean/already/between = 9/30/7/0 at $h=0$ and 9/5/7/25 at $h=4$ | 1 |
| 1 | 2. TWFE weights by hand | [core] [pencil] | Units A ($g=2$), B ($g=3$), C (never), $t=1,2,3$. Compute $\tilde D$, the weights, and $\beta^{\mathrm{TWFE}}$ with $\theta_{A,0}=1$, $\theta_{A,1}=3$, $\theta_{B,0}=1$. Show that the $t=3$ comparison of B against A returns 0. Then drop C and find the negative weight. | Use two-way demeaning in a balanced panel | Weights $(\tfrac12,0,\tfrac12)$; $\beta^{\mathrm{TWFE}}=1$ vs $\tfrac53$. Without C: $(1,-\tfrac12,\tfrac12)$; $\beta^{\mathrm{TWFE}}=0$ | 2 |
| 3 | 3. Where the weights come from | [core] [pencil] | Apply FWL within date to derive $q_{g,h}$; show that $1/(1-\overline{\Delta D}_{t,h})$ gives $N_g/\sum N_g$ | The residual of $\Delta D$ on date dummies is $\Delta D-\overline{\Delta D}_{t,h}$ | SIM12 $h=0$: $q=(0.266749,0.258442,0.246575,0.228234)$, $\theta^{\mathrm{VW}}_0=53468/83423$ | 3 |
| 2 | 4. LP-DiD by hand, then `lpdid` | [core] [computational] | On `sim12_draw1.csv`, build `cc_h`, estimate with `regress … i.t, vce(cluster id)`, export the eligibility table, and run `lpdid` | Build the flag before any `bysort`; drop singleton dates before comparing s.e. | `assert` $\lvert\hat\beta_h-$`lpdid`$\rvert<10^{-6}$ for all $h$; $\lvert\mathcal T_0\rvert=508$ | 1, 3 |
| 3 | 5. Name the estimand | [core] [computational] | Noiseless SIM12: assert VW $=\theta^{\mathrm{VW}}_h$ and RW $=\theta^{\mathrm{ATE}}_h$; double cohort 5's size and predict the direction of each | Which weight moves: $q_{g,h}$, $N_g/\sum N_g$, or both? | Default values in §1 to $10^{-8}$; direction of the change stated before running | 3 |
| 1, 2 | 6. A deliberately invalid comparison | [core] [computational] | On noiseless SIM12, with and without never-treated units, estimate: all rows; not yet treated at $t$; clean controls; static TWFE | Which rows carry effects that are still growing? | Naive $h=5$: 2.227941; no-never static TWFE −1.575; clean equals truth | 2 |
| 4 | 7. Which pre-trends can this specification test? | [core] [pencil] | Show that $y_{t-j}-y_{t-1}$ for $j\le5$ lies in the span of specification C's controls; predict which C and D coefficients are zero; write the anticipation bias at $h=2$ | Telescoping sum of first differences (L2) | Benchmark $\lvert b\rvert\le1.3\times10^{-17}$ at −2…−5; formula 1.337928 | 4 |
| 5 | 8. REP12 | [data] [computational] | Rerun Figure 3 from `get_data.do`; compare with the benchmark; run `lpdid` A/C/D; label EW and `nocomp` as course computations; write the discrepancy log | Separate "the same regression" from "the same specification" (B has future controls) | 144 pairs at $10^{-6}$; N by horizon equals `REP12-sample-audit.csv` | 5 |
| 3, 4 | 9. Four estimators, 200 samples | [computational] [extra] | Run `sim12.do` with `global R 200` plus the anticipation variant; tabulate bias, s.d., and coverage | Store every replication; summarize once | VW mean within 3 Monte Carlo s.e. of truth; naive coverage at $h=5$ ≤ 0.05 | 2, 4 |
| 5 | 10. When treatment switches off | [pencil] [extra] | For a unit treated in 1985–1987 then untreated, write the clean-control condition under a stabilization window $\bar k=3$ and under first-treatment-only; state each assumption | Draw the unit's $D$ path and shade $t+h$ | Answer key against `lpdid` help (DGJT §4.2.2–4.2.3; section numbers from the frozen version, page range to confirm, D31) | 4 |

Each outcome has evidence in at least two media: outcome 1 (§1 opening,
`fig-l12-cohort-timeline`, `fig-l12-twfe-weights`, exercises 1–2, labs 1–2);
2 (regression display, exercises 4 and 6, lab 1, STA12); 3 (derivation §6.2,
`fig-l12-reweighting`, exercises 3, 5, 9, lab 3); 4 (§6.4–6.5, exercise 7,
lab 4); 5 (`fig-l12-figure3`, exercises 8 and 10, lab 5, REP12).

## 6. Derivations to verify

**6.1 TWFE weights** (`#sec-l12-staggered-adoption`). *Source identity:*
Frisch–Waugh–Lovell (L3).
- Let $\tilde D_{i,t}$ be the residual of $D_{i,t}$ on unit and time effects.
  Then $\beta^{\mathrm{TWFE}}=\sum\tilde D_{i,t}y_{i,t}/\sum\tilde D_{i,t}^2$.
- $\sum\tilde D\eta=\sum\tilde D\phi=0$ and
  $\sum\tilde D^2=\sum\tilde D D$. With
  $y_{i,t}(\infty)=\eta_i+\phi_t+u_{i,t}$, this gives
  $\beta^{\mathrm{TWFE}}=\sum_{D=1}w_{i,t}\theta_{g_i,t-g_i}+\sum\tilde Du/\sum\tilde D^2$,
  where $w_{i,t}=\tilde D_{i,t}/\sum_{D=1}\tilde D$.
- In a balanced panel, $\tilde D_{i,t}=D_{i,t}-\bar D_{i\cdot}-\bar D_{\cdot t}+\bar D$.

*Toy:* A ($g=2$), B ($g=3$), C (never), $t=1,2,3$.
- Averages: $\bar D_{A\cdot}=\tfrac23$, $\bar D_{B\cdot}=\tfrac13$,
  $\bar D_{\cdot2}=\tfrac13$, $\bar D_{\cdot3}=\tfrac23$, $\bar D=\tfrac13$.
- Residuals: $\tilde D_{A,2}=\tfrac13$, $\tilde D_{A,3}=0$,
  $\tilde D_{B,3}=\tfrac13$, so the weights are $(\tfrac12,0,\tfrac12)$.
- With $\theta_{A,0}=1$, $\theta_{A,1}=3$, $\theta_{B,0}=1$:
  $\beta^{\mathrm{TWFE}}=1$, while the mean treated effect is $\tfrac53$.

*Second toy (drop C):* A ($g=2$), B ($g=3$), $t=1,2,3$.
- Averages: $\bar D_{A\cdot}=\tfrac23$, $\bar D_{B\cdot}=\tfrac13$,
  $\bar D_{\cdot1}=0$, $\bar D_{\cdot2}=\tfrac12$, $\bar D_{\cdot3}=1$,
  $\bar D=\tfrac12$.
- Residuals: $\tilde D_{A,2}=\tfrac13$, $\tilde D_{A,3}=-\tfrac16$,
  $\tilde D_{B,3}=\tfrac16$. They sum to $\tfrac13$, so the weights are
  $(1,-\tfrac12,\tfrac12)$.
- With the same effects:
  $\beta^{\mathrm{TWFE}}=1-\tfrac32+\tfrac12=0$, against a mean treated effect
  of $\tfrac53$. A at $t=3$ is B's only control, so A's largest effect enters
  with negative weight.

*Numerical check (banking):* manual $-0.012299165272$ equals `reghdfe`
−0.0122992. 150 of 489 weights are negative, summing to −0.17716114.

**6.2 LP-DiD weights and reweighting** (`#sec-l12-estimand`, eq.
`eq-l12-vw-weights`). *Source identity:* FWL within date.
- At date $t=g$, $\mathcal T_h$ contains $N_g$ treated and
  $N^{\mathrm{cc}}_{g,h}$ control rows. The residual of $\Delta D$ on date
  dummies is $\Delta D-p$, with $p=\overline{\Delta D}_{t,h}=N_g/(N_g+N^{\mathrm{cc}}_{g,h})$.
- Per-date numerator: $N_g(1-p)\bar Y^{T}-N^{\mathrm{cc}}p\,\bar Y^{C}=\frac{N_gN^{\mathrm{cc}}}{N_g+N^{\mathrm{cc}}}(\bar Y^{T}-\bar Y^{C})$.
  Per-date denominator: $(N_g+N^{\mathrm{cc}})p(1-p)$, the same factor.
  Dates with no treated rows contribute zero to both.
- Under no anticipation and parallel trends,
  $\mathbb E[\bar Y^{T}-\bar Y^{C}]=\theta_{g,h}$, hence $q_{g,h}$.
- *Reweighting:* a weight $1/(1-p)$ that is constant within a date leaves
  $p$ unchanged. It multiplies both per-date terms by $1/(1-p)$, so the
  cohort factor becomes $N_gN^{\mathrm{cc}}/[(N_g+N^{\mathrm{cc}})(1-p)]=N_g$.

*Checks (banking, spec. A, $h=0,\dots,9$):*
- the formula from `bank12_eligibility.csv` against the benchmark
  coefficients: largest gap $8.8\times10^{-10}$;
- the hand equal-weight average against `lpdid …, rw`: largest gap
  $9.1\times10^{-10}$, e.g. $h=0$: −0.0052035014 vs −0.0052035019. At
  $h=0$, 12 cohorts and 45 treated states; the 1993 state never has a clean
  control.

**6.3 SIM12 worked example** (lab defaults). Exact rational arithmetic, then
Stata on noiseless data (largest gap $<10^{-6}$ at printed precision).

| $h$ | $N^{\mathrm{cc}}_{g,h}$ for $g=5,8,11,14$ | $q_{g,h}$ | $\theta^{\mathrm{VW}}_h$ exact | Stata VW / RW |
|---|---|---|---|---|
| 0–2 | 34, 28, 22, 16 | 0.266749, 0.258442, 0.246575, 0.228234 | $(h+1)\cdot53468/83423$ | 0.640926, 1.281853, 1.922779 / $0.625(h+1)$ |
| 3–5 | 28, 22, 16, 16 | 0.268794, 0.256452, 0.237377, 0.237377 | $20507/8021$, $102535/32084$, $61521/16042$ | 2.556664, 3.195830, 3.834996 / 2.5, 3.125, 3.75 |
| No never-treated, 0 / 3 | 18, 12, 6, 0 / 12, 6, 0, 0 | 0.391, 0.348, 0.261, 0 / 0.571, 0.429, 0, 0 | $18/23$ / $25/7$ | 0.782609 / 3.571429; RW 0.75 / 3.5 |

The average effect over all 46 treated cells is $955/4\div46=5.190217$.
Noiseless static TWFE gives 2.263530, and −1.575000 without never-treated
units.

**6.4 Anticipation and divergent trends** (`#sec-l12-assumptions`).
- With $\theta_{g,-1}=a$, the treated baseline rises by $a$. Clean controls
  with $g_i=g+h+1$ also carry $a$ at $t+h$. So
  $\beta_h=\theta^{\mathrm{VW}}_h-a-a\sum_gq_{g,h}N_{g+h+1}/N^{\mathrm{cc}}_{g,h}$,
  and the pre-horizons equal $-a$.
  At $a=0.5$, $h=2$: $1.922779-0.5-0.5(0.266749\cdot\tfrac6{34}+0.258442\cdot\tfrac6{28}+0.246575\cdot\tfrac6{22})=1.337928$.
  Stata gives 1.337928, and 3.271226 at $h=5$.
- With $+0.1t$ for cohort 5: pre-horizon $-j$ equals
  $-0.1(j-1)q_{5,0}$, giving −0.026675, −0.053350, −0.080025. Post-horizon
  $h$ equals $\theta^{\mathrm{VW}}_h+0.1(h+1)q_{5,h}$, e.g. 0.667601 at
  $h=0$. Stata matches every value.

**6.5 Pre-trends zero by construction** (`#sec-l12-assumptions`).
- *Source identity:* L2's telescoping sum,
  $y_{t-j}-y_{t-1}=-\sum_{m=1}^{j-1}\Delta y_{t-m}$.
- For $j\le5$ the terms $\Delta y_{t-1},\dots,\Delta y_{t-4}$ are all
  regressors in specification C (`L(1/4).D.laborsh_private`). The dependent
  variable is then in the column space of the controls, so by FWL its
  coefficient on $\Delta D$ is exactly zero.
- Levels alone (`L(1/4).laborsh_private`) span $j\le4$. At $j=6$ the term
  $\Delta y_{t-5}$ is missing.
- *Check:* benchmark C and D, $h=-2,\dots,-5$, have
  $\lvert b\rvert\le1.32\times10^{-17}$; C at $h=-6$ is 0.0018751.

**6.6 Clean controls versus `reghdfe`** (`#sec-l12-manual-vs-lpdid`).
`regress Dy4 dD i.year if dD==1|F4.intbanking==0, vce(cluster statenum)`
returns −0.020740684950998, identical to `reghdfe`, but its s.e. is
0.006734934825195 with N=568. `reghdfe` gives 0.006723046140152 with N=566,
because it drops singleton groups. Flag each date's sample rows
(`bysort year: egen n=total(sample)`) and keep $n>1$. `regress` then
reproduces `reghdfe` to 15 digits: 0.006723046140152 with N=566 at $h=4$,
and 0.003051935993842 with N=522 at $h=-6$ (`check_singletons.do`).

## 7. HTML lab plan (Clean-Control Builder, `interactives/12-clean-control-builder.qmd`)

Five Observable JS labs, in chain order. Each has a setup paragraph, **Predict
before using the controls**, controls with units, a plot or table, a
reactive sentence, controlled comparisons, a collapsed explanation, and an
export. SIM12 labs are noiseless: every regression is computed live from
group means in closed form (§6.2) and is validated against
`sim12_noiseless.csv` to $10^{-6}$ before release. Banking panels are labeled
"stored result" (D30).

**Lab 1 — Build the eligibility table (live).**
- *Question:* at horizon $h$, which rows are treated, clean, or excluded?
- *Invariants:* cohort dates; no estimation.
- *Controls:*
  - dataset: SIM12 (default) or banking cohorts (stored counts);
  - horizon $h$: periods, SIM12 −4…5 (default 4), banking 0…9;
  - highlighted cohort (default 5 / 1985);
  - cohort sizes $N_g$: units, 0–12, default 6;
  - never-treated count: units, 0–30, default 16.
- *Output:* a timeline with rows coloured treated, clean, already treated,
  or switching before $t+h$, plus the cohort-by-horizon table.
- *Reactive sentence:* "At $h=4$, cohort 5 has 6 treated units and 28 clean
  controls; 6 units that switch at $t=8$ are excluded; its variance weight is
  0.269 against an equal weight of 0.25."
- *Comparisons:* $h$ from 0 to 5; never-treated set to 0; banking 1985 at
  $h=0$ versus $h=4$ (30 versus 5 clean controls).
- *Handoff:* `eligibility.csv` ($g,h,N_g,N^{\mathrm{cc}}_{g,h}$, already,
  between, $q_{g,h}$, equal weight). STA12 task 1 asserts it equals the
  Stata-built table.

**Lab 2 — Forbidden comparisons (live).**
- *Question:* what does admitting already-treated or switching units do to
  the estimate?
- *Invariants:* noiseless SIM12 and $\theta_{g,k}$.
- *Controls:*
  - control rule: $D_{i,t+h}=0$ (default), not yet treated at $t$, or all
    rows;
  - never-treated on or off;
  - effect shape: ramp (default) or constant in $k$;
  - impact responses $\theta_{g,0}$: outcome units, 0–2, defaults 1, 0.75, 0.5,
    0.25.
- *Output:* estimates by $h$ against $\theta^{\mathrm{VW}}_h$, plus a strip of
  static-TWFE weights with negative cells marked.
- *Reactive sentence:* "Admitting all rows gives 2.228 at $h=5$ against
  3.835, because units treated earlier are still rising; without never-treated
  units static TWFE is −1.575 though every effect is positive."
- *Comparisons:* switch the rule; switch to constant effects (every
  estimator is then correct); remove never-treated units.
- *Handoff:* a specification record (rule, shape, never-treated, predicted
  sign) for STA12 task 4 and exercise 6.

**Lab 3 — Which average? (live).**
- *Question:* when do $\theta^{\mathrm{VW}}_h$ and $\theta^{\mathrm{ATE}}_h$
  differ, and which does the question want?
- *Invariants:* $\theta_{g,h}$ fixed unless edited.
- *Controls:* $N_g$ (1–20); never-treated (0–30); weighting (variance or
  equal).
- *Output:* bars of $q_{g,h}$ against $N_g/\sum N_g$; the two averages.
- *Reactive sentence:* "Variance weights (0.267, 0.258, 0.247, 0.228) tilt
  toward cohort 5, whose effect is largest, so $\theta^{\mathrm{VW}}_0=0.641$
  exceeds $\theta^{\mathrm{ATE}}_0=0.625$."
- *Comparisons:* remove never-treated units (0.783 against 0.75); equal
  effects (gap 0); make cohort 14 large.
- *Handoff:* weights CSV for exercise 5.

**Lab 4 — What pre-trends can show (live, with one conceptual illustration).**
- *Question:* do negative horizons reveal anticipation and diverging trends?
- *Invariants:* noiseless SIM12, variance-weighted LP-DiD.
- *Controls:* anticipation $\theta_{g,-1}$ (outcome units, −1…1, default 0);
  cohort-5 trend (−0.2…0.2 per period, default 0).
- *Conceptual illustration, labeled as such:* a "4 lagged-outcome controls"
  toggle that greys out the horizons −2…−5 it forces to zero, shown beside
  the stored banking C rows.
- *Reactive sentence:* "Anticipation of 0.50 moves every pre-horizon to
  −0.50 and lowers $h=2$ by 0.585: 0.500 through the treated baseline and
  0.085 through controls anticipating their own treatment."
- *Comparisons:* anticipation alone; trend alone; both.
- *Handoff:* a prediction record for exercises 7 and 9.

**Lab 5 — The banking evidence (stored result).**
- *Question:* how much does DGJT's answer depend on sample rule, weighting,
  specification, and composition?
- *Invariants:* stored 19.5 outputs with metadata: archive 1.0, `lpdid`
  1.0.3, run date.
- *Controls:*
  - specification A–D;
  - reform: interstate banking or intrastate branching;
  - estimator: authors' loops (benchmark), or three course computations for
    banking A only: reweighted, `nocomp`, all rows.
- *Bands:* 1.96 × state-clustered s.e., as in the authors' figure.
- *Reactive sentence:* "Specification C at $h=-3$ is $3.7\times10^{-18}$:
  zero by construction, not evidence of parallel trends."
- *Handoff:* the selected cohort's eligibility row, for the REP12 audit.

## 8. Practicum plan (REP12, STA12, handoff)

### 8.1 REP12 — Banking deregulation and the labor share

- **Exact target (D17).** DGJT (2025), "A Local Projections Approach to
  Difference-in-Differences," *JAE* 40(7), 741–758, Figure 3 (§6.1; section
  numbers from the frozen version, page range to confirm, D31). The target
  is all eight curves (specifications A–D × interstate banking and
  intrastate branching) at $h=-9,\dots,9$: coefficients, state-clustered
  s.e., and 1.96 bands, plus N by horizon from the audit replay.
- **Replication kind.** Exact numerical replication through the authors'
  loops. `lpdid` 1.0.3 serves as a cross-check for A, C, and D. B is not
  single-command equivalent, because it controls for future switches of the
  other reform, `F(1/j)`. Equal weights, `nocomp`, and all-rows estimates are
  labeled course computations.
- **Data and vintage.** JAE data archive 1.0 (readme 4 June 2025),
  `dgjt_replication_package.zip`, 40,607,219 bytes, SHA-256
  `87173e49e1f2db095b1534f07598ef0842d0be4c574a897c2f6e6fb7c1143987`, from
  the public resource URL recorded in `evidence/jae-downloads.json`. The raw
  data are Leblebicioglu–Weinberger (2020).
- **Scripts and lines.** `collapse_lshare_dataset.do` (entire file) and
  `figure_3.do`: A 25–82 (banking loop 28–46), B 85–145, C 150–215, D
  218–285, assembly 291–330.
- **Benchmark numbers** (CSV; coefficient (s.e.) N):

| Curve | $h=0$ | $h=4$ | $h=9$ | $h=-6$ |
|---|---|---|---|---|
| Banking A | −0.004863 (0.001784) 752 | −0.020741 (0.006723) 566 | −0.030943 (0.013259) 330 | 0.008807 (0.003052) 522 |
| Banking C | −0.004753 (0.001898) 568 | −0.020827 (0.007927) 383 | −0.019158 (0.010945) 154 | 0.001875 (0.001757) 522 |
| Banking D | −0.003841 (0.001594) 502 | −0.017353 (0.005135) 326 | −0.015387 (0.010307) 139 | 0.002293 (0.001826) 456 |
| Branching A | −0.000984 (0.001605) 562 | −0.009064 (0.004295) 417 | −0.025828 (0.006570) 238 | 0.000874 (0.003809) 382 |

- **Tolerance.** Absolute $10^{-6}$ on coefficient, s.e., and band; exact N.
  The figure is checked for content, not pixels. The 19.5 rerun meets it
  at $4.9\times10^{-10}$ (D1).
- **Runtime (19.5).** Collapse 0.40 s; Figure 3 3.61 s; `bank12.do` with
  five `lpdid` calls 13.7 s. The `lpdid` author example takes 6 min 7 s and
  is instructor-only.
- **Dependencies (D4).** Nine SSC packages, at the versions the design runs
  loaded (from `replication-packages/runtime/ado/plus` via `adopath`):
  `reghdfe` 6.13.1 (workers; `lpdid`); `ftools` 2.50.0 and `require` 1.3.1
  (both for `reghdfe`); `blindschemes` (SSC 2020-08-07; `figure_3.do` line 2,
  `set scheme plotplainblind`); `coefplot` 1.8.8 (`figure_3.do` line 316);
  `lpdid` 1.0.3 (SSC 2026-08-05); `boottest` 4.5.3; `egenmore` (SSC
  2019-01-24; `pmd`); `listreg` 1.0.3 (`rw` with covariates). `lpdid` checks
  for `boottest`, `egenmore` (`_gclsst`), `reghdfe`, and `listreg` at startup
  and exits with error 198 if any is missing, so a machine set up from D4's
  current lists fails both REP12 and exercise 8. The master calls
  `check_deps.do` first: `capture which` for each command (`findfile
  scheme-plotplainblind.scheme` for `blindschemes`), and on failure it stops
  with the `ssc install` line to run. D4's required list in
  `docs/editor-decisions.md` must be amended to include these packages (§10,
  Q1). Porting `figure_3.do`'s loops to `regress … i.year` for students is
  not the course route, because D17 fixes the authors' loops as the target.
- **Departures, logged.**
  1. The workers run from a project root with `data/`, `processed/`, and
     `results/`, replacing the machine-specific `cd` in `bank_app_main.do`
     line 15.
  2. `figure_3.do` line 2 needs `blindschemes`, and line 316 needs
     `coefplot`.
  3. `xtset statenum year` must run before `lpdid`: the processed file
     carries stale panel metadata.
  4. Lines 77 and 142 set `b_lpl` and `b_lpl1`, not the branching
     variables, so branching A and B keep a missing reference. This is a
     presentation discrepancy only, because `mkmat … nomissing` drops that
     row anyway.
  5. Interpretation: C and D at −2 to −5 are zero by construction (§6.5).
- **Redistribution (D5).** The archive records no license. The project
  ships `data/raw/get_data.do`, which downloads the ZIP, verifies the SHA-256
  above, and extracts the two `.dta` inputs and the two workers. It stops
  with a clear message if the URL fails, and `PROVENANCE.md` gives the manual
  route (the landing page serves an Anubis challenge). `lpdid` is GPL-3,
  installed from SSC.

### 8.2 STA12 — construct, estimate, diagnose, interpret

**Common input.** Ship `sim12_draw1.csv` (800 rows: `id t g D y theta`;
seed 12) and `sim12.do` with `global R 200`, `H 5`, `Q 4` (D2). Master
`sta12_master.do` calls `check_deps.do` (§8.1), then `01_eligibility.do` …
`05_interpret.do`, then `06_rep12.do`. The last step runs
`data/raw/get_data.do`, the two unchanged workers
(`collapse_lshare_dataset.do`, `figure_3.do`), and `rep12_compare.do`. That
script asserts the 144 coefficient and s.e. pairs against the benchmark at
$10^{-6}$ and N by horizon against `REP12-sample-audit.csv`. The step then
runs `lpdid` for A, C, and D after `xtset statenum year` (departure 3),
reading Lab 5's exported eligibility row.

1. **Construct.** Build `cc_h` ($D_{i,t+h}=0$ or `dD==1`), `already_h`, and
   `between_h` before any `bysort`, then collapse to the eligibility table.
   `assert` that it equals the Lab 1 export and that
   $N^{\mathrm{cc}}_{g,0}=(34,28,22,16)$.
2. **Estimate.** Run `regress Dy`h' dD i.t if cc_`h', vce(cluster id)` for
   $h=0..5$ and $-4..-2$, then `lpdid y, unit(id) time(t) treat(D) pre(4) post(5) nograph`.
   `assert` $\lvert\hat\beta_h-$`e(results)`$\rvert<10^{-6}$. Expected values:
   $\hat\beta_0=0.198014$ with $\lvert\mathcal T_0\rvert=508$, and
   $\hat\beta_5=3.603860$ (s.e. 0.407779). Explain any s.e. gap (§6.6).
3. **Reweight.** Build `rw_h` $=1/(1-\overline{\Delta D}_{t,h})$. On
   noiseless data, `assert` VW $=\theta^{\mathrm{VW}}_h$ and RW
   $=\theta^{\mathrm{ATE}}_h$ to $10^{-8}$. On draw 1, match `lpdid, rw` to
   $10^{-6}$ (observed gap $\le1.2\times10^{-7}$; the command rounds its
   weights). Say which average a statewide policy question wants.
4. **Diagnose.** On noiseless data, estimate the all-rows and
   not-yet-at-$t$ samples and static TWFE, with and without never-treated
   units. `assert` all-rows $h=5$ = 2.227941 and no-never static TWFE =
   −1.575.
5. **Interpret.** In `05_interpret.md`, write parallel trends and no
   anticipation in potential outcomes for SIM12. Use the anticipation
   variant (pre-horizons −0.5; $h=2$ 1.337928) and name the reported
   estimand.

**Expected outputs.** `eligibility.csv`, `lpdid_compare.csv`, `weights.csv`,
`invalid.csv`, `sim_estimators.pdf`, `rep12_compare.csv`, and the log, with every assertion
passing.

### 8.3 Handoff and submission package

- *Handoff.* Lab 1–3 exports feed STA12 tasks 1, 3, and 4; the Lab 5
  eligibility row feeds the REP12 audit; the Lab 4 prediction record feeds
  exercises 7 and 9.
- *Submission package* (blueprint §4.2):
  - replication record: target, archive SHA, commands, 144-pair
    comparison, discrepancy log with software, presentation, specification,
    and interpretation rows;
  - Stata submission: master do-file, log, estimate CSVs, figures,
    assertions;
  - interpretation record: estimand (VW or EW), assumptions, units
    (percentage points of private GSP), clustering by state (46 clusters),
    and the limitation that only 3 cohorts and 4 states remain at $h=9$;
  - HTML lab record.

## 9. Slides arc

1. *Forty-six states, thirteen dates* — the question inherited from L11.
2. *One TWFE number, 150 negative weights* — the regression averages
   comparisons nobody chose.
3. *Cohorts on a timeline* — clean, already treated, switching.
4. *The toy's zero and negative weights* — a forbidden comparison, worked by
   hand, with and without the never-treated unit.
5. *Naive estimators on a known design* — SIM12: naive LP and TWFE miss;
   −1.575 without never-treated units.
6. *The LP-DiD regression* — one equation, one sample rule.
7. *The eligibility table at $h=4$* — the 1985 cohort's 5 clean controls.
8. *What $\beta_h$ averages* — $q_{g,h}$ from FWL.
9. *Reweighting* — VW or EW, and which question wants which.
10. *Pre-trends* — anticipation, diverging trends, zero by construction.
11. *The banking evidence* — Figure 3 across four specifications.
12. *When treatment switches off* — the stabilization window.
13. *Playground, exercises, and the question for Lecture 13.*

## 10. Open questions for the editor

1. **Amend D4 for P12.** §8.1 *Dependencies* lists the nine SSC packages
   P12 needs. D4 requires only `lpdid`, `coefplot`, and `estout`, lists
   `reghdfe` as optional, and omits `ftools`, `require`, `blindschemes`,
   `boottest`, `egenmore`, and `listreg`. `lpdid` will not start without
   `boottest`, `egenmore`, `reghdfe`, and `listreg`, and `figure_3.do` stops
   without `blindschemes`. D4's required list and the setup page must add
   them in the same change that approves this brief. Until then,
   `check_deps.do` stops the build with install instructions.
2. **ATE or ATT.** The ledger's $\theta^{\mathrm{ATE}}_h$ and the keys
   `equally-weighted-ate` and `variance-weighted-ate` name averages over
   treated cohorts (DGJT's ATT). Keep them with a one-sentence footnote, or
   rename before drafting?
3. **New symbols.** Approve the §2 rows marked *new* for ledger §7.
4. **Specification A pre-horizons.** Four of eight A bands exclude zero,
   while C and D are zero at −2 to −5 by construction. The notes would state
   both neutrally, citing the do-file lines, in the spirit of D14. Confirm.
5. **Author example.** At 6 min 7 s it fits D2 but uses most of the ceiling.
   Keep it instructor-only?
