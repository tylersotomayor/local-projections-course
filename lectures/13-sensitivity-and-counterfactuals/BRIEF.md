# Lecture 13 brief — Sensitivity analysis and policy counterfactuals

Planning brief for `lectures/13-sensitivity-and-counterfactuals/` (notes,
exercises, glossary, slides, figures), `interactives/13-counterfactual-workbench.qmd`
("Counterfactual and Sensitivity Workbench"), and
`practica/p13-sensitivity-and-counterfactuals/`. It follows the course spine
(Lecture 13 and the seams with Lectures 12 and 14), the notation ledger (§8),
the terminology plan, the blueprint (Sections 1, 4, 5, Lecture 13, R02, R16),
the authoring guide, MANIFEST §REP13, and decisions D1–D5, D11, D18, D20,
D24–D26, D30, D31.

Verification status. Every number below comes from a benchmark CSV, a run made
for this brief in StataNow/SE 19.5 (revision 12 Aug 2026, D1), or arithmetic
shown in §6. All runs are in `…/scratchpad/design-13/`, and no log contains a
Stata error line.

1. `rep13/run_rep13.do` ran the unmodified `GMM_GBF_counterfactual_clean.do`
   (SHA-256 `5e0aa102…`) in 40.3 s. It reproduces `REP13-counterfactual.csv`
   with maximum absolute coefficient difference 0 and SE difference
   $1.05\times10^{-7}$. The six parameters and the 6×6 covariance agree to
   $5\times10^{-16}$. The authors' stored `gmmgbfjoint.ster` has mreldif 0 against
   the fresh estimate.
2. `rzgrid/rz_grid.do` (22 s) is a course-built grid over the REP04 switches.
   Its baseline cell reproduces `REP04-linear-fiscal-multiplier.csv` to
   $2.9\times10^{-7}$, with $N$ exact.
3. `jtwin/jt_windows.do` (224 s) re-estimates the Example 8 GMM on four sample
   windows. It is course-built, not the author script.
4. Python scripts `cf_check.py`, `policy_path.py`, `loo_identity.py`,
   `cf_bands.py`, `grid_analysis.py`, and `checks2.py` do the arithmetic in §6.
5. Repair checks in `…/scratchpad/repair13/` (19.5): `rz_grid_builtin.do`
   reruns the grid with `ivregress 2sls …, vce(hac nwest opt)` and no
   `ivreg2` (§8.2); `theta0.py` checks the unrestricted funds-rate impact
   response and recomputes §6.2 with $\theta^R_0=1$; `sterchk2.do` reads the
   shipped `ivbet.dta` and `output.dta` (§8.1).

Readings (D31). Reading-guide section numbers for R16 and R02 come from the
versions frozen in `replication-packages/VERIFIED.md`: R16 is the chapter in
*NBER Macroeconomics Annual* 40 (2026), pp. 111–152, and R02 is the article
in *JEL* 63(1) (2025), pp. 59–110. Each guide says "section numbers from the
frozen version; page range to confirm". The R16 section references in this
brief (§4: "R16 §7(a), (f)") were read from the January 23, 2025 draft
(`~/Downloads/LocalProjections/lp_var_primer.pdf`, 37 pp.) and must be
checked against the frozen chapter before the guide is written. No local
copy of R02 exists.

---

## 1. Session brief

**Opening situation.**
Jordà and Taylor estimate two responses over 1985m1–2000m12 by joint GMM, each
restricted to a Gaussian shape. One is the unemployment response to a
funds-rate move instrumented by the Romer–Romer shock; it peaks at 1.23
percentage points after 26 months. The other is the funds rate's own
response, which peaks at 2.17 points after 4.66 months. Then they ask what
unemployment would have done had the funds-rate peak come one standard error
earlier, at 4.54 months. That shift moves the funds-rate path by at most
0.037 points in any month. Yet their counterfactual unemployment response
rises by up to 0.292 points, at month 18. That is 1.93 times the original
response's standard error there (0.292/0.151). A "plausibility" $p$-value of
0.08 is printed under the figure.

Now feed the same two estimated responses through the course's counterfactual
formula. The same funds-rate change moves unemployment by at most 0.011
points. The authors' first number (the response) is an estimate. The second
(the counterfactual) is a calculation. It borrows the estimate and adds
assumptions the figure never names; its size comes from the estimates'
sampling covariance, not from how policy is transmitted.

The spine sets this opening in a 1990–1992 calendar path. Example 8 alters a
response's shape rather than a dated path, so the brief uses the object the
code actually computes (§10, Q5).

**Decision or empirical question.**
Suppose a results section reports an LP estimate, a set of robustness checks,
and a policy counterfactual. Which of its sentences does the estimate support
by itself? Which need named additional assumptions? Which are not supported
at all? What checks move a sentence from one category to another? The lecture
answers in two parts:

- **Before any counterfactual,** check that the estimate is stable. Use a
  pre-specified grid that reports sample and specification changes
  separately, plus leave-one-episode-out and first stages in every cell.
- **After the counterfactual,** classify it as one of three readings. It can
  be a shock response, a statistical conditioning on estimated responses, or
  a causal intervention on a policy path. Only the third is a policy
  experiment, and it needs linearity, policy invariance, and an intervention
  modest enough that the Lucas critique does not bite. Reproducing the
  numbers establishes none of these.

**Target student and prerequisites.**
The student has completed Lectures 1–12:

- the LP-IV one-step cumulative multiplier and the robust first-stage $F$
  (L4);
- common versus horizon-specific samples (L2);
- the Wald test and horizon sets (L6);
- the Gaussian response $a\exp\{-(h-h^\star)^2/c^2\}$ and Jordà–Taylor's
  joint GMM (L8);
- a pre-registered threshold grid and specification search (L9);
- the dominance of a few large military-news quarters in the linear
  coefficient (L10).

Stata skills assumed: `ivregress 2sls` with `vce(hac nwest opt)` (L4, L9),
`gmm`, `estimates use`, matrix
subscripts, `postfile`, and `assert`. Introduced from scratch: conditional
normal formulas for partitioned covariance matrices, and block deletion
formulas for least squares.

**Learning outcomes.**

1. Build a pre-specified sensitivity grid that tabulates sample changes
   separately from specification changes. Report each cell's estimate,
   standard error, $T_h$, and first-stage $F$, and recognise redundant cells.
2. Measure an episode's influence with the block leave-one-out identity. State
   what "leaving out an episode" means when the dependent variable is
   cumulative, and trace the influence through a multiplier's numerator and
   denominator.
3. Compute a policy-path counterfactual from estimated responses. Map a rate
   path into an intervention sequence, then into the outcome. Reproduce
   Jordà–Taylor's conditional counterfactual from their parameters and
   covariance.
4. Distinguish the three readings of a counterfactual, and name the
   assumptions each needs: linearity, policy invariance, no anticipation of
   the altered path, and a modest intervention.
5. Classify each sentence of a results section as a statistical result, an
   assumption-dependent interpretation, or an unsupported claim, and name the
   evidence that would reclassify it.

**Anchor example.**

*Counterfactual (REP13).* Jordà–Taylor `JEL-Code`, commit `655696c`, CC0.
The file is `Example8_Counterfactuals/data_fred.dta` (SHA-256 `08a1225f…`,
byte-identical to Example 6's): 517 monthly rows, 1965m12–2008m12. Lines
39–40 keep 1985m1–2000m12, which is 192 rows. Series:

- `urate`: unemployment rate, percent;
- `infl`: PCE inflation, annualized percent;
- `ffr`: federal funds rate, percent;
- `RRCGShock`: Romer–Romer shock extended by Coibion–Gorodnichenko–Kueng–Silvia,
  percentage points.

Transformations:

- **Outcomes.** $y_{t+h}-y_{t-1}$ for `urate` and `ffr`, $h=0,\dots,48$.
- **Residualizing.** Each outcome, `ffr`, and `RRCGShock` is regressed on six
  lags of `urate`, `infl`, and `ffr`. The residuals are `r·`, `effr_f·`,
  `rffr`, and `rz`.
- **Estimation.** Joint two-step GMM of 98 equations (49 horizons × 2
  outcomes) with 196 moments. The instrument is `rz`. Six parameters:
  $(a^U,h^{\star U},c^U)$ for unemployment and $(a^R,h^{\star R},c^R)$ for the
  funds rate. The authors' code calls the peaks `b0` and `br0` (D20).
- **Inference.** HAC Bartlett with 190 lags on the common sample $N=138$.

Estimates, with standard errors in parentheses:

| $a^U$ | $h^{\star U}$ | $c^U$ | $a^R$ | $h^{\star R}$ | $c^R$ |
|---|---|---|---|---|---|
| 1.227591 (0.138896) | 25.796708 (0.640277) | 14.850801 (0.435657) | 2.171119 (0.037903) | 4.659906 (0.120534) | 6.100567 (0.141985) |

These differ from Lecture 8's Example 6 estimates ($a=1.388$, $h^\star=26.19$,
$c=13.00$; 1985m1–2000m1, $T_H=127$, 179 HAC lags) because Example 8 keeps
1985m1–2000m12 (192 rows) and estimates the unemployment and funds-rate
shapes jointly on $N=138$ with 190 lags. A footnote in `#sec-l13-evidence`
repeats this (§3).

*Sensitivity grid (STA13).* Ramey–Zubairy `rzdat.xlsx` (508 quarters, 1889Q1–2015Q4;
SHA-256 `b2d85087…6c8c6120`, as in L01, L09). The target is the REP04 linear one-step
cumulative multiplier $M_h$ for $h=0,\dots,20$:

- $y$ = real GDP over `rgdp_pott6`, $g$ = real spending over `rgdp_pott6`, and
  the military news `newsy`;
- four lags each of news, $y$, and $g$;
- `ivregress 2sls …, vce(hac nwest opt)`, the built-in equivalent of
  `jordagk.do`'s `ivreg2, robust bw(auto)` (L09 footnote (ii); D4), with
  $F_h$ from the first-stage HAC $t$ (L4 §6.8, L09 §6.7).

The baseline $M_{20}=0.729480$ ($T_{20}=480$) is D11's number. The switches
are those of `jordagk.do` lines 29–41:

- **Sample changes:** `sample` (full / post-1947) and `omit` (none / WWII,
  1941Q3–1945Q4).
- **Specification changes:** `trends` (none / quartic, quadratic post-1947)
  and `tax` (none / four lags of federal receipts over GDP).

The data are acquired by script (D5).

*Episodes* (a course choice, fixed before estimation):

| Episode | Quarters |
|---|---|
| WWI | 1917Q1–1918Q4 |
| WWII | 1941Q3–1945Q4 |
| Korea | 1950Q3–1953Q3 |
| Vietnam | 1965Q1–1969Q4 |
| Reagan | 1980Q1–1986Q4 |

No simulation enters the notes. The lab's leave-one-out toy (§7, Lab 3) uses
the seeded design stated there.

**Smallest useful model (ledger notation).**
Let $s_t$ be a monetary intervention, $y^R_t$ the policy rate, and $y_t$ the
outcome. Their responses to $s_t$ are $\theta^R_h$ and $\theta^U_h$
(superscripts name the outcome, as in $\beta^Y_h,\beta^G_h$). Assume the
responses are linear, and invariant to which path of $s$ is chosen. Then a
change in the intervention sequence, $\Delta s^c_j\equiv s^c_{t+j}-s^0_{t+j}$,
moves both variables as

$$
\Delta y^{R,c}_h\equiv y^{R,c}_{t+h}-y^{R,0}_{t+h}=\sum_{j=0}^{h}\theta^R_{h-j}\Delta s^c_j,\qquad
\Delta y^c_h\equiv y^c_{t+h}-y^0_{t+h}=\sum_{j=0}^{h}\theta^U_{h-j}\Delta s^c_j .
$$

A proposed rate path fixes the left side of the first equation. When
$\theta^R_0\neq0$, $\Delta s^c$ solves it recursively, and the second equation
then gives the outcome.

*Toy numbers.* Take $\theta^R=(1,0.5,0.25,0.125)$ and $\theta^U=(0,0.1,0.2,0.3)$.
The baseline is one unit intervention, $s^0=(1,0,0,0)$. In the counterfactual
the rate is held at $+1$ for four periods. Then
$s^c=(1,0.5,0.5,0.5)$, $y^0=(0,0.1,0.2,0.3)$, and $y^c=(0,0.1,0.25,0.45)$.

*The contrasting object.* Jordà–Taylor never solve for $\Delta s^c$. They
treat the parameter estimates $(\hat{\boldsymbol\vartheta}^U,\hat{\boldsymbol\vartheta}^R)$
as jointly normal with covariance $\mathbf V$ and report the conditional mean

$$
\boldsymbol\vartheta^U_c=\hat{\boldsymbol\vartheta}^U+\mathbf V_{UR}\mathbf V_{RR}^{-1}(\boldsymbol\vartheta^R_c-\hat{\boldsymbol\vartheta}^R).
$$

This shift is zero whenever the two equations' estimation errors are
uncorrelated, whatever policy change is proposed. So it is a statement about
the estimator, not about transmission.

**Dependency chain.**

1. `#sec-l13-estimate-and-calculation` **An estimate and a calculation.**
   Example 8 turns a 0.037-point change in the funds-rate path into a
   0.292-point change in unemployment, while the ledger formula applied to the
   same responses gives 0.011. So the gap is an assumption, not a number to
   re-estimate.
2. `#sec-l13-sensitivity-grid` **A pre-specified sensitivity grid.** The four
   Ramey–Zubairy switches give 16 cells but only 12 distinct estimates (a
   post-1947 sample contains no WWII quarters). At $H=20$, adding trends moves
   $M_{20}$ by $+0.211$ and taxes by $+0.003$. Dropping WWII moves it by
   $-0.014$ and starting in 1947 by $-0.240$. Sample and specification effects
   must therefore be reported apart.
3. `#sec-l13-influential-episodes` **Influential episodes.** The WWII and
   Korea quarters, 31 of 480 rows, carry 72 percent of the partialled news
   variation. Dropping Korea lowers $M_{20}$ from 0.729 to 0.653. Dropping
   WWII collapses both reduced forms, 3.550 to 1.607 and 4.866 to 2.265, but
   leaves their ratio at 0.710, with the standard error multiplied by 3.4.
4. `#sec-l13-weak-identification` **Weak identification across the grid.**
   The robust first-stage $F$ falls below 10 in 88 of the 252 distinct
   cell-horizons (12 cells × 21 horizons). That includes every no-WWII cell at
   $h\le 10$, and $F=0.00007$ at $h=1$ in the post-1947 trend cell, where
   $\hat M_1=1{,}193.9$. A grid without first stages ranks noise.
5. `#sec-l13-counterfactual-arithmetic` **The counterfactual calculation.**
   The superposition formula, the recursive inversion of a rate path, and its
   stability condition (roots of $\theta^R(z)$ outside the unit circle). A
   25-basis-point cut held for a year needs a first-month intervention of
   $-0.206$ (1.11 residual standard deviations) and lowers unemployment by
   0.175 points after two years.
6. `#sec-l13-three-readings` **Three readings.** A response to a shock, a
   conditioning on estimated responses (Example 8's conditional mean, and a
   conditional forecast), and an intervention on a policy path. Policy
   invariance and the Lucas critique separate the second from the third, and
   Example 8's 0.08 "plausibility" $p$-value is a statement about the
   estimator's covariance, $\mathcal W_c=1/(1-\zeta^2)$, not about agents'
   expectations.
7. `#sec-l13-classifying-claims` **Classifying conclusions.** Every sentence
   of a results section is a statistical result, an assumption-dependent
   interpretation (naming its assumption), or an unsupported claim. The
   classification is applied to ten sentences about Examples 8 and REP04.
8. `#sec-l13-evidence` **Auditing Example 8.** The exact rerun, the plotted
   horizon offset (D18), the 190-lag HAC on 138 rows, and window sensitivity:
   the Gaussian fit fails when the window starts in 1980, and the plausibility
   $p$ is below $10^{-30}$ in two neighbouring windows. A numerical
   replication certifies the calculation, not its reading.
9. `#sec-l13-handoff` **Could someone else check this?** Everything above
   depended on written-down choices (grid, episode windows, horizon indexing,
   HAC lag), which leads to Lecture 14's methods section and audit.

**Central notation.**

- *From the ledger:* $y_t$, $s_t$, $\mathbf w_t$, $p$, $h$, $H$,
  $\beta_h$, $\theta_h$, $\mathcal T_h$, $T_h$, $M_H$, $B^Y_H$, $B^G_H$,
  $z_t$, $\alpha$, and §8's $s^c_{t+j}$, $y^0_{t+h}$, $y^c_{t+h}$,
  $\mathcal S$, $[t_0,t_1]$.
- *From D20:* $a,h^\star,c$, and $R$ (replications only).
- *New in this lecture:* $y^R_t$ (policy rate), $\theta^R_h,\theta^U_h$,
  $\Delta s^c_j$, $\Delta y^c_h$, $\Delta y^{R,c}_h$, $\boldsymbol\vartheta^U,\boldsymbol\vartheta^R$, $\mathbf V$ and its
  blocks, $\mathbf d$, $\mathcal W_c$, $\zeta^2$, $\mathcal E$,
  $\mathcal T_h(\mathcal E)$, $\hat\beta_{h,(-\mathcal E)}$, and $F_h$
  (first-stage $F$). See §2.

**Glossary terms** (the twelve keys owned by L13, all used; no new keys):

- `sensitivity-analysis` — Re-estimating a result under a stated set of
  alternative samples and specifications to learn which conclusions survive.
  It is informative only when the set is fixed before results are seen.
- `specification-grid` — The table of cells in $\mathcal S$, each recording
  sample, controls, estimate, standard error, $T_h$, and first-stage strength.
  Sample changes and specification changes are separate dimensions.
- `influential-episode` — A contiguous set of dates whose removal changes an
  estimate by more than its sampling uncertainty would suggest. In LPs its
  reach extends $p$ periods before and $h$ after the episode.
- `leave-one-out` — Re-estimating with one observation or block removed. For
  least squares, the change has a closed form in the block's residuals and
  leverage.
- `sample-window` — The estimation dates $[t_0,t_1]$. Changing it changes the
  population the estimate describes as well as its precision.
- `counterfactual-path` — A proposed sequence $\{s^c_{t+j}\}$ or policy-rate
  path compared with a baseline. Its outcome consequence is a calculation that
  uses estimated responses.
- `policy-invariance` — The assumption that the responses $\theta_h$ do not
  change when the policy path does. It is needed to reuse estimates under a
  different policy.
- `lucas-critique` — Lucas's argument that reduced-form relationships shift
  when agents understand policy to have changed, so estimates from one regime
  can mislead about another.
- `conditional-forecast` — A forecast or response computed conditional on an
  assumed path for some variables. It is a statistical statement about joint
  movements, silent on what causes them.
- `policy-experiment` — A counterfactual in which policy is changed by
  intervention while everything that does not respond to policy is held
  fixed. It requires identification, linearity, and policy invariance.
- `assumption-dependent-interpretation` — A conclusion that follows from the
  estimates only together with a named assumption that the data do not test.
- `unsupported-claim` — A conclusion that neither the estimates nor any stated
  assumption delivers.

**Likely footnotes.** Leeper–Zha (2003) modest interventions and McKay–Wolf (2023)
(verify both with `/verify-cites`); the conditional normal formula; the
190-lag HAC default (confirm in the `gmm` manual); endpoint versus window
omission; the D18 offset; Example 6 versus Example 8 Gaussian estimates (L8); float storage in `jordagk.do`; the R16 draft versus
the frozen chapter; why no bands are drawn from $\mathbf V_c$ (§6.4, §10 Q7).

**Candidate figures** (TikZ/pgfplots via `figures/build.sh` and `lpfig.tex`).
Data are Lua-read CSVs committed from the named runs.

| Label | Question | Lesson visible | Data or formula |
|---|---|---|---|
| `fig-l13-estimate-and-calculation` | How large is Example 8's counterfactual compared with the policy change behind it? | Top: funds-rate paths, original and shifted, which differ by at most 0.037. Bottom: GBF unemployment response with its 95% band, the conditional counterfactual (+0.292 at $h=18$), and the ledger policy-path counterfactual (at most 0.011). | REP13 CSV; `policy_path.csv` |
| `fig-l13-sensitivity-grid` | Which switches move $M_h$? | 3×4 small multiples, $h=0..20$ (rows: full, no WWII, post-1947; columns: none, tax, trends, both). Caption: shading marks $F_h<10$ (the whole no-WWII row at $h\le10$); first-stage strength by cell is in `tbl-l13-grid`. | `rz_grid.csv` |
| `fig-l13-leave-one-episode-out` | Which episodes carry the multiplier? | Left: $M_h$ baseline and five leave-one-out paths. Right: each episode's share of partialled news variation (WWII 0.387, Korea 0.332, WWI 0.140, Vietnam 0.003, Reagan 0.004). | `rz_grid.csv`; `loo_identity.py` |
| `fig-l13-plausibility-geometry` | Why is a one-standard-error shift "implausible" at $p=0.08$? | Marginal density of $\hat h^{\star R}$ (sd 0.1205) against its density conditional on $(\hat a^R,\hat c^R)$ (sd 0.0468). The same 0.1205 shift is 1 marginal SE but 2.575 conditional SEs, and $2.575^2=6.63=\mathcal W_c$. | REP13 covariance; §6.5 |
| `fig-l13-three-readings` | What does each reading of a counterfactual assume? | A schematic of the three readings, with the assumptions added at each step. | none (diagram) |

The window-sensitivity evidence is a table (`tbl-l13-windows`), not a figure.

**Exercise capabilities and controlled experiments.** See §5 (ten exercises) and §7 (four labs). Each lab
changes one input while the responses, estimates, or grid cells stay fixed.

**Postponed.**

- Optimal policy and policy-rule counterfactuals built from several
  identified shocks (one footnote and further reading).
- Structural (DSGE) counterfactuals.
- Specification-curve inference and multiple-testing corrections across grids
  (L9 owns `specification-search`).
- Anderson–Rubin bands across the grid.

**Question handed on.** Could another researcher reproduce, understand, and
challenge this analysis from what has been written down?

---

## 2. Concept and notation ledger

No ledger symbol is reassigned. Avoided on purpose: $R^2$ ($R$ is the
replication count, D20; use $\zeta^2$), a hat matrix $\mathbf H$ ($H$ is the
maximum horizon; use $\mathbf P$), $\delta$ (L8; use $\Delta s^c_j$),
$\boldsymbol\Sigma$ (L6; use $\mathbf V$), $r$ (L8's penalty order, D20; write
the policy rate $y^R_t$), $\tilde s_t$ and $\tilde y_{t,h}$ (partialled-out
residuals in L3, L5, L6, L8, L10; use $\Delta s^c_j$, $\Delta y^c_h$), and
$\boldsymbol\vartheta$ (L8 writes the Gaussian parameter vector
$\boldsymbol\vartheta$; use it). A $\Delta$ that carries the superscript $c$
and is indexed by $j$ or $h$ is counterfactual minus baseline, never the first
difference $\Delta y_t$ of ledger §2. Jordà–Taylor's `b0`/`br0` appear only
when quoting code (D20).

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $y^R_t$; $y^{R,c}_{t+h},\ y^{R,0}_{t+h}$ | Policy rate (effective federal funds rate); its counterfactual and baseline paths | scalar | $t$ | percent | §1 | §5, §6, §8 |
| $\theta^R_h,\ \theta^U_h$ | Responses of $y^R$ and of $y$ (unemployment) to the intervention $s_t$ | scalar per $h$ | $t+h$ on $t$ | percentage points per unit $s$ | §1 | §5–§8, Labs 1–2, Ex 1, 8 |
| $s^c_{t+j},\ s^0_{t+j}$ | Counterfactual and baseline intervention sequences (ledger §8) | scalar per $j$ | $t+j$, $j=0..h$ | units of $s$ (Example 8: percentage points of instrumented funds-rate innovation) | §5 | §6, Lab 1 |
| $\Delta s^c_j$ | $s^c_{t+j}-s^0_{t+j}$ | scalar per $j$ | $t+j$ | units of $s$; also in residual sd units (Example 8: 0.1858) | §5 | Ex 1, 8; Lab 1 |
| $\Delta y^c_h,\ \Delta y^{R,c}_h$ | $y^c_{t+h}-y^0_{t+h}$ and $y^{R,c}_{t+h}-y^{R,0}_{t+h}$ | scalar per $h$ | $t+h$ | percentage points | §1 | §5, §6.2, Ex 1, 8; Lab 1 |
| $y^0_{t+h},\ y^c_{t+h}$ | Baseline and counterfactual outcome paths (ledger §8) | scalar per $h$ | $t+h$ | units of $y$ | §5 | §6–§7 |
| $\theta^R(z)$ | $\sum_{h=0}^{H}\theta^R_h z^h$; the recursion inverting a rate path is stable iff its roots lie outside the unit circle | polynomial | — | — | §5 | Ex 8 |
| $\boldsymbol\vartheta^U,\ \boldsymbol\vartheta^R$ | Gaussian response parameters $(a,h^\star,c)'$ for unemployment and for the funds rate | 3×1 | — | $a$: points per point; $h^\star$, $c$: months | §6 | §8, Ex 2–3, Lab 2 |
| $\boldsymbol\vartheta^R_c,\ \boldsymbol\vartheta^U_c$ | Counterfactual funds-rate parameters, and the conditional-mean unemployment parameters they imply | 3×1 | — | as above | §6 | §8 |
| $\mathbf V$; $\mathbf V_{UU},\mathbf V_{UR},\mathbf V_{RR}$ | GMM covariance of $(\hat{\boldsymbol\vartheta}^{U\prime},\hat{\boldsymbol\vartheta}^{R\prime})'$ and its 3×3 blocks | 6×6; 3×3 | — | products of parameter units | §6 | Ex 2–3, Lab 2 |
| $\mathbf V_c$ | $\mathbf V_{UU}-\mathbf V_{UR}\mathbf V_{RR}^{-1}\mathbf V_{RU}$; conditional covariance of $\hat{\boldsymbol\vartheta}^U$ | 3×3 | — | as above | §6 (footnote) | Ex 10 |
| $\mathbf d$ | $\boldsymbol\vartheta^R_c-\hat{\boldsymbol\vartheta}^R$; Example 8: $(0,-0.120534,0)'$ | 3×1 | — | parameter units | §6 | Ex 3 |
| $\mathcal W_c$ | $\mathbf d'\mathbf V_{RR}^{-1}\mathbf d$, the "plausibility" statistic, referred to $\chi^2_3$ | scalar | — | unitless | §6 | §8, Lab 2 |
| $\zeta^2$ | Squared multiple correlation of $\hat h^{\star R}$ with $(\hat a^R,\hat c^R)$ under $\mathbf V_{RR}$ | scalar in $[0,1)$ | — | unitless | §6 | Ex 3 |
| $\mathcal S$ | Pre-specified set of specifications (ledger §8) | set | — | — | §2 | §4, Lab 4 |
| $[t_0,t_1]$ | Estimation window (ledger §8) | dates | calendar | months or quarters | §2 | §8, Ex 10 |
| $\mathcal E$ | An episode: a contiguous set of calendar dates | set | calendar | quarters | §3 | Lab 3, Ex 6 |
| $\mathcal T_h(\mathcal E)$ | Rows $t\in\mathcal T_h$ whose window $[t-p,t+h]$ meets $\mathcal E$ | set | row $t$ | — | §3 | Ex 6 |
| $\hat\beta_{h,(-\mathcal E)}$ | Estimate on $\mathcal T_h\setminus\mathcal T_h(\mathcal E)$ | scalar | — | units of $\beta_h$ | §3 | Lab 3 |
| $\mathbf X_h$, $\mathbf P_{\mathcal E\mathcal E}$, $\hat{\mathbf u}_{h,\mathcal E}$ | Regressor matrix of the horizon-$h$ regression; its projection-matrix block for rows in $\mathcal T_h(\mathcal E)$; their residuals | $T_h\times k$; $n_{\mathcal E}\times n_{\mathcal E}$; $n_{\mathcal E}\times1$ | row $t$ | — | §3 (derivation box) | Ex 6 |
| $z^\perp_t$ | Military news after partialling the controls (Frisch–Waugh–Lovell) | scalar | $t$ | ratio to lagged nominal trend GDP | §3 | fig `leave-one-episode-out` |
| $F_h$ | Robust (Kleibergen–Paap) first-stage $F$ at horizon $h$ | scalar | — | unitless | §4 | Lab 3, Ex 7 |
| $M_h$, $B^Y_h$, $B^G_h$ | Reused from L2/L4: one-step multiplier and its same-sample reduced-form numerator and denominator | scalar | $t..t+h$ | GDP-ratio sums per unit news | §2 | §3–§4 |

---

## 3. Terminology ledger

| Phrase | Treatment | Key | One-sentence definition | First marked |
|---|---|---|---|---|
| sensitivity analysis | glossary | `sensitivity-analysis` | Re-estimating a result under a stated set of alternatives to learn which conclusions survive; it is informative only if the set was fixed first. | `#sec-l13-sensitivity-grid` |
| specification grid | glossary | `specification-grid` | The table of cells in $\mathcal S$ recording sample, controls, estimate, standard error, $T_h$, and first-stage strength, with sample and specification as separate dimensions. | `#sec-l13-sensitivity-grid` |
| sample window | glossary | `sample-window` | The dates $[t_0,t_1]$; changing them changes the population described as well as the precision. | `#sec-l13-sensitivity-grid` |
| influential episode | glossary | `influential-episode` | A contiguous set of dates whose removal moves an estimate by more than its standard error suggests; in an LP its reach runs $p$ periods before and $h$ after. | `#sec-l13-influential-episodes` |
| leave-one-out | glossary | `leave-one-out` | Re-estimation without one observation or block; for least squares the change is a closed form in that block's residuals and leverage. | `#sec-l13-influential-episodes` |
| counterfactual path | glossary | `counterfactual-path` | A proposed sequence for the intervention or policy rate, compared with a baseline sequence. | `#sec-l13-counterfactual-arithmetic` |
| policy invariance | glossary | `policy-invariance` | The assumption that estimated responses stay the same under the proposed policy path. | `#sec-l13-three-readings` |
| Lucas critique | glossary | `lucas-critique` | Reduced-form relations shift when agents perceive a change in policy, so responses estimated under one regime may not carry to another. | `#sec-l13-three-readings` |
| conditional forecast | glossary | `conditional-forecast` | A path computed conditional on assumed values of some variables; it describes joint movement, not cause. | `#sec-l13-three-readings` |
| policy experiment | glossary | `policy-experiment` | A counterfactual that changes policy by intervention while holding fixed what does not respond to it; it needs identification, linearity, and policy invariance. | `#sec-l13-three-readings` |
| assumption-dependent interpretation | glossary | `assumption-dependent-interpretation` | A conclusion that follows only with a named assumption the data do not test. | `#sec-l13-classifying-claims` |
| unsupported claim | glossary | `unsupported-claim` | A conclusion delivered neither by the estimates nor by any stated assumption. | `#sec-l13-classifying-claims` |
| statistical result | prose (see §10 Q4) | — | A statement about an estimate and its sampling uncertainty under the maintained identification. | `#sec-l13-classifying-claims` |
| modest intervention | footnote | — | Leeper–Zha's check that the implied policy surprises are small relative to historical ones (citation to verify). | `#sec-l13-three-readings` |
| conditional normal distribution | footnote | — | For a partitioned Gaussian vector, the conditional mean shifts by $\mathbf V_{UR}\mathbf V_{RR}^{-1}$ times the deviation of the conditioning block. | `#sec-l13-three-readings` |
| HAC lag default in `gmm` | footnote | — | Example 8's `vce(hac nw)` records 190 Bartlett lags on $N=138$; 190 equals 192 rows in memory minus 2 (manual to confirm). | `#sec-l13-evidence` |
| endpoint omit rule | footnote | — | `jordagk.do` excludes row $t$ when the flag is set at $t-4$, $t$, or $t+h$; the course's window rule also excludes rows whose window spans the episode. | `#sec-l13-influential-episodes` |
| plotted horizon offset | footnote | — | GBF paths evaluated at $h=1..48$ are drawn at $0..47$ (lines 180–187, 230–231); logged per D18. | `#sec-l13-evidence` |
| Example 6 versus Example 8 Gaussian estimates | footnote | — | Lecture 8's Example 6 fit ($a=1.388$, $h^\star=26.19$, $c=13.00$; 1985m1–2000m1, $T_H=127$, 179 HAC lags) differs from Example 8's because Example 8 keeps 1985m1–2000m12 (192 rows) and estimates the unemployment and funds-rate shapes jointly on $N=138$ with 190 lags. | `#sec-l13-evidence` |
| counterfactual, specification search, weak instrument, robust $F$ statistic, one-step multiplier, Gaussian basis function, shape restriction, Wald test, common sample, statistical reproduction, specification record, anticipation, conditional comparison | prose, linked to owners (L01, L09, L04, L08, L06, L02, L03, L11) | — | reused without spans | first use |

---

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Medium | Source | Status | Label |
|---|---|---|---|---|---|
| The 19.5 rerun reproduces REP13 | Coefficient difference 0; SE ≤ $1.05\times10^{-7}$; parameters and covariance ≤ $5\times10^{-16}$; 40.3 s (18.5: 48.0 s) | table | `run_rep13.do` against the REP13 CSV | computed | `tbl-l13-rep13-check` |
| A small rate change produces a large conditional shift | Rate change ≤ 0.0368 (at $h=9$); conditional shift 0.2922 at $h=18$ (1.93 SE); ledger formula ≤ 0.0110 | figure | `cf_check.py`, `policy_path.py` | computed; figure to build | `fig-l13-estimate-and-calculation` |
| The conditional counterfactual is a conditional mean | $\boldsymbol\vartheta^U_c=(1.464616,24.573877,15.518622)'$; path matches CSV to $9\times10^{-8}$ | equation + Lab 2 | §6.4 | computed | `eq-l13-conditional-mean` |
| $p=0.08$ reflects $\zeta^2$ only | $\zeta^2=0.849139$, $\mathcal W_c=6.628637$, $p=0.084725$ | equation + figure | §6.5 | computed | `fig-l13-plausibility-geometry` |
| Sample and specification effects differ in size | 16 switches give 12 cells; $M_{20}$ ranges 0.490–1.366; trends $+0.211$, tax $+0.003$, no WWII $-0.014$, post-1947 $-0.240$ | figure + table | `rz_grid.csv` | computed; figure to build | `fig-l13-sensitivity-grid`, `tbl-l13-grid` |
| Weak identification is widespread in the grid | $F_h<10$ in 88 of 252 cell-horizons; $\hat M_1=1193.9$ at $F_1=0.00007$ | figure shading + sentence | `rz_grid.csv`, `checks2.py` | computed | `fig-l13-sensitivity-grid` |
| Two episodes carry the news variation | Partialled shares: WWII 0.387, Korea 0.332; Korea removed: $M_{20}=0.653$; WWII removed: $B^Y$ 3.550→1.607, $B^G$ 4.866→2.265, ratio 0.710, SE ×3.4 | figure | `rz_grid.csv`, `loo_identity.py` | computed; figure to build | `fig-l13-leave-one-episode-out` |
| The omission rule matters | 1941Q1–Q2 kept by the endpoint rule: $F_{20}$ 3.38 vs 29.01; SE 0.108 vs 0.205 | footnote + exercise | `rz_grid.csv` | computed | `#exercise-l13-6` |
| The block leave-one-out identity is exact | Differences ≤ $4.4\times10^{-11}$ (WWI, WWII, Korea; $h=20$) | derivation box | `loo_identity.py` | computed | `eq-l13-block-deletion` |
| A realistic path needs large surprises | A −25 bp cut held 12 months: $\Delta s^c_0=-0.2064$ (1.11 sd), $\Delta y^c_{24}=-0.1749$; roots of $\theta^R(z)$ ≥ 1.180; with the unrestricted impact $\theta^R_0=1$, $\Delta s^c_0=-0.25$ (1.35 sd), $\Delta y^c_{24}=-0.1768$ | worked example + Lab 1 | `policy_path.py`, `theta0.py` | computed | `eq-l13-superposition` |
| Example 8 is window-fragile | Four windows (§6.8) | table | `jt_windows.csv` | computed | `tbl-l13-windows` |
| Example 8's HAC uses 190 lags on $N=138$ | `e(vce)` = "hac bartlett 190" | footnote + log | `ster_meta.log` | computed | `#sec-l13-evidence` |
| GBF paths are plotted one month early | Evaluated at $h$, drawn at $h-1$; raw LP at $h$ | footnote + log (D18) | REP13 README | recorded | `#sec-l13-evidence` |
| The three readings require different assumptions | Conceptual | diagram | — | to build | `fig-l13-three-readings` |
| LPs and VARs do not solve identification | R16 §7(a), (f) (draft numbering; check against the frozen chapter, D31) | prose | primer draft | read in draft; sections to check | `#sec-l13-classifying-claims` |

---

## 5. Assessment map

Ten exercises: seven Stata, three with data. Exercise 10 takes about four
minutes and is tagged [extra] (D26).

| LO | Exercise | Tags | Mode | Hint | Solution check | Lab |
|---|---|---|---|---|---|---|
| 3 | 1. Holding the rate by hand | [core] [pencil] | Invert the toy $\theta^R$ to hold $y^R$ at $+1$ for $h=0..3$, then for the path $(1,1,0,0)$; compute $y^c$ | Carry forward the rate deviation already explained by earlier interventions | $s^c=(1,.5,.5,.5)$, $y^c=(0,.1,.25,.45)$; then $s^c=(1,.5,-.5,0)$, $y^c=(0,.1,.25,.35)$ | 1 |
| 4 | 2. Conditioning is not transmission | [core] [pencil] | Scalar case, then the 3×3 case using $\mathbf V_{UR}\mathbf V_{RR}^{-1}$ and $\mathbf d$ from §6.4 | What is the shift when $\mathbf V_{UR}=\mathbf 0$? Whose uncertainty is in $\mathbf V$? | $\boldsymbol\vartheta^U_c$ to six decimals; the shift vanishes with uncorrelated errors | 2 |
| 4 | 3. Why $p=0.08$ | [core] [pencil] | Prove $\mathcal W_c=1/(1-\zeta^2)$ for a one-SE single-parameter shift; compute it from $\mathbf V_{RR}$ | Use the partitioned inverse | $\zeta^2=0.849139$, $p=0.084725$ | 2 |
| 3 | 4. Rerun Example 8 | [core] [computational] | Run `REESTIMATE 0`, then `1`; compare with the benchmark CSV; log the offset | Merge on the evaluation horizon, not the plotted coordinate | `assert` coefficients within $10^{-6}$, $N=138$, printed $p$ 0.08 | — |
| 1 | 5. A pre-registered grid | [core] [computational] [data] | Write `sensitivity_plan.txt` before estimating; run 16 combinations; collapse duplicates | Which cells must be identical, and why? | `assert` $M_{20}=0.729480\pm10^{-6}$, $T_{20}=480$; post-1947 omit cells identical; $H=8,20$ tables match notes | 3 |
| 2 | 6. Leave one episode out | [computational] [data] | Five episodes under window and endpoint rules; Mata block identity for Korea at $h=20$ | Write the window condition as a running count | Korea $M_{20}=0.6533$; WWII rules differ by rows 1941Q1–Q2; identity within $10^{-8}$ | 3 |
| 1, 2 | 7. Numerators, denominators, first stages | [computational] [data] | Map $F_h$, $B^Y_h$, $B^G_h$ across cells | Report both reduced forms before the ratio | 88 of 252 below 10; $\hat M_1=1193.9$ flagged | 3 |
| 3 | 8. A policy path through Example 8 | [core] [computational] | Mata: invert $\theta^R$ for the authors' shift and for a −25 bp, 12-month path | Check the roots of $\theta^R(z)$ first | max $\lvert\Delta y^c\rvert=0.0110$ vs 0.2922; $\Delta s^c_0=-0.2064$, $\Delta y^c_{24}=-0.1749$ | 1 |
| 5 | 9. Ten sentences | [core] [pencil] | Classify ten sentences from a mock results section; name the assumption or evidence | What would have to be true for this sentence to follow? | Answer key citing sections | 4 |
| 2, 4 | 10. Moving the window | [extra] [computational] | Re-estimate Example 8 GMM on four windows; report $\mathcal W_c$ and the maximum shift | Read parameter signs before $p$ | `tbl-l13-windows` to four decimals; 1980 window diagnosed as a fit failure | 2 |

Each outcome has evidence in at least two media:

| LO | Evidence |
|---|---|
| 1 | §2, figure, Ex 5, 7, Lab 3 |
| 2 | §3, derivation, figure, Ex 6, 7, Lab 3 |
| 3 | §5, worked example, Ex 1, 4, 8, Lab 1 |
| 4 | §6, figure, Ex 2, 3, 10, Lab 2 |
| 5 | §7, diagram, Ex 9, Lab 4 |

---

## 6. Derivations to verify

**6.1 Superposition** (`eq-l13-superposition`).

*Source assumptions:*

- (i) The effect of an intervention at $t+j$ on $y_{t+h}$ is $\theta^U_{h-j}$
  whatever happened before (linearity; L9–L10 show when this fails).
  *Without it,* the effect of two interventions is not the sum of their
  effects, so the contrast depends on the baseline $s^0$ as well as on
  $\Delta s^c$. With L10's quadratic $\psi(e)=e+0.05e^2$ (L10 Exercise 1), one
  unit moves $y$ by $\psi(1)=1.05$, but one unit added to a baseline unit
  moves it by $\psi(2)-\psi(1)=1.15$.
- (ii) $\theta$ does not depend on the chosen path (policy invariance).
  *Without it,* $\theta^U$ and $\theta^R$ estimated under the historical rule
  are not the responses under the new path. The sum then uses the wrong
  weights and §6.2 inverts the wrong $\theta^R$, and nothing in the sample
  reveals it (the Lucas critique, `#sec-l13-three-readings`).
- (iii) Interventions after $t$ are not anticipated at $t$ (L3).
  *With anticipation,* agents who learn at $t$ of a later $\Delta s^c_j$ react
  before $t+j$. Then $y$ and $y^R$ move at horizons where the sum assigns
  $\Delta s^c_j$ no effect, and §6.2 attributes that early rate movement to
  earlier interventions.

*Steps:* write $y^c_{t+h}$ as the baseline plus the effect of each dated
intervention. Subtract $y^0_{t+h}$; the common terms cancel, leaving
$\sum_{j=0}^{h}\theta^U_{h-j}\Delta s^c_j$.

*Check:* the toy values of §1 and Exercise 1 (`policy_path.py`, confirmed).

**6.2 Inverting a rate path.**
From $\Delta y^{R,c}_h=\sum_{j\le h}\theta^R_{h-j}\Delta s^c_j$:

$$
\Delta s^c_h=\Big(\Delta y^{R,c}_h-\sum_{j<h}\theta^R_{h-j}\Delta s^c_j\Big)\Big/\theta^R_0 .
$$

The recursion stays bounded for every bounded $\Delta y^{R,c}$ only if $\theta^R(z)$
has no root with $|z|\le1$.

*Example 8 inputs.* The funds-rate response is
$\theta^R_h=2.171119\exp\{-((4.659906-h)/6.100566)^2\}$ for $h=0..48$, so
$\theta^R_0=1.211403$. The smallest root modulus is 1.1804.

- *The authors' shift* ($h^{\star R}$ reduced by 0.120534):
  - $\Delta y^{R,c}_0=0.036635$, and $\max_h|\Delta y^{R,c}_h|=0.036778$ at $h=9$;
  - $\Delta s^c_0=0.030242$ and $\sum|\Delta s^c_j|=0.087334$;
  - $\max_h|\Delta y^c_h|=0.010971$.
- *A −25 bp cut held 12 months* ($\Delta y^{R,c}_h=-0.25$ for $h\le11$, then 0):
  - $\Delta s^c_0=-0.25/1.211403=-0.206372$, and $\Delta s^c_{12}=+0.1992$;
  - $\Delta y^c_{6},\Delta y^c_{12},\Delta y^c_{18},\Delta y^c_{24}=-0.0292,\,-0.0700,\,-0.1359,\,-0.1749$.

The residual sd of `rffr` is 0.185774 ($N=186$), so
$0.206372/0.185774=1.111$ sd.

*Impact normalization: a shape-restriction artifact.* Without the Gaussian
restriction, the impact response of the funds-rate long difference to its own
instrumented move is exactly 1. `ffr_f0` and `ffr` are residualized on the
same rows and controls, which include $y^R_{t-1}$, so `effr_f0` equals `rffr`
(L2's same-regressor equivalence; `theta0.py`: largest difference
$1.2\times10^{-14}$, IV coefficient 1 to $10^{-15}$ on 186 and on 138 rows).
The Gaussian shape sets $\theta^R_0=1.211403$, 21 percent above 1, so every
implied intervention is rescaled by the restriction. Setting only
$\theta^R_0=1$ and keeping the Gaussian $\theta^R_h$ for $h\ge1$:

| Recursion | $\theta^R_0$ | Held cut $\Delta s^c_0$ (sd) | $\Delta s^c_{12}$ | $\Delta y^c_{6},\Delta y^c_{12},\Delta y^c_{18},\Delta y^c_{24}$ | Smallest root modulus | Authors' shift $\Delta s^c_0$ |
|---|---|---|---|---|---|---|
| Gaussian | 1.211403 | −0.206372 (1.111) | +0.1992 | −0.0292, −0.0700, −0.1359, −0.1749 | 1.1804 | 0.030242 |
| Impact set to 1 | 1 | −0.25 (1.346) | +0.2420 | −0.0301, −0.0689, −0.1377, −0.1768 | 1.1933 | 0.036635 |

The notes call the gap a shape-restriction artifact and link to
[shape restriction](../08-smoothing-and-restrictions/notes.qmd#sec-l08-glossary).

**6.3 Evaluation versus plotting.**
Lines 180–187 evaluate the GBF at $h=1..48$, and lines 230–231 plot it at
$h-1$ (CSV `b_gbf`, horizon 12, plot_horizon 11: 0.51787215). The raw LP `bj`
is plotted at $h$. The notes plot at $h$ and log the offset (D18).

**6.4 The conditional mean** (`eq-l13-conditional-mean`).

*Source:* if $(\hat{\boldsymbol\vartheta}^U,\hat{\boldsymbol\vartheta}^R)$ is jointly
normal with covariance $\mathbf V$, then
$\mathbb E[\hat{\boldsymbol\vartheta}^U\mid\hat{\boldsymbol\vartheta}^R=\boldsymbol\vartheta^R_c]$
shifts by $\mathbf V_{UR}\mathbf V_{RR}^{-1}\mathbf d$. Line 212 applies this
with estimates in place of means.

*Inputs* (from `REP13-covariance.csv`):

$$
\mathbf V_{UR}\mathbf V_{RR}^{-1}=
\begin{pmatrix}3.474965&-1.966464&1.728544\\-16.031035&10.145102&-7.421049\\13.079585&-5.540519&3.538834\end{pmatrix},\qquad
\mathbf d=(0,-0.120534,0)' .
$$

*Steps:* only the second column enters. Multiplying it by $-0.120534$ gives
$(0.237026,-1.222831,0.667821)'$. Adding $\hat{\boldsymbol\vartheta}^U$ gives
$\boldsymbol\vartheta^U_c=(1.464616,\ 24.573877,\ 15.518622)'$.

*Checks:*

- The path matches CSV `bc_gbf` to $9.1\times10^{-8}$ from the rounded CSV
  parameters, and exactly in the 19.5 rerun. At $h=12$ it is 0.75964612.
- Special case: $\mathbf V_{UR}=\mathbf 0$ gives $\boldsymbol\vartheta^U_c=\hat{\boldsymbol\vartheta}^U$.
- Footnote only: $\mathbf V_c$ has diagonal square roots
  $(0.031769,0.257764,0.335003)$. The delta-method SE at $h=12$ is 0.034401
  conditional, against 0.112243 unconditional (the CSV gives 0.11224252).

**6.5 The plausibility identity.**
Write $\sigma_2$ for the SE of $\hat h^{\star R}$. Since
$\mathbf d=-\sigma_2\mathbf e_2$,

$$
\mathcal W_c=\sigma_2^2[\mathbf V_{RR}^{-1}]_{22}=\frac{\sigma_2^2}{\sigma_2^2-\mathbf v_{2}'\mathbf V_{-2}^{-1}\mathbf v_{2}}=\frac{1}{1-\zeta^2}
$$

(partitioned inverse). The result does not depend on where the estimates lie.

*Numbers:*

- $\zeta^2=0.849139$, so $\mathcal W_c=6.628637$ and
  $p=\Pr(\chi^2_3>6.628637)=0.084725$ (printed "0.08").
- The conditional sd is $0.120534\sqrt{1-\zeta^2}=0.046816$. The shift is
  therefore 2.574614 conditional sd, and $2.574614^2=6.6286$.
- With only $(a^R,h^{\star R})$, $1/(1-0.6747^2)=1.8356$, below the 2-df 90%
  value 4.6052. It is holding $c^R$ fixed as well that makes the shift
  "implausible".

**6.6 Block deletion** (`eq-l13-block-deletion`).

*Source:* the OLS normal equations with $\mathcal T_h(\mathcal E)$ removed:

$$
\hat{\boldsymbol\beta}_{(-\mathcal E)}=\hat{\boldsymbol\beta}-(\mathbf X_h'\mathbf X_h)^{-1}\mathbf X_{\mathcal E}'(\mathbf I-\mathbf P_{\mathcal E\mathcal E})^{-1}\hat{\mathbf u}_{h,\mathcal E}.
$$

*Steps:* apply Woodbury to $(\mathbf X'\mathbf X-\mathbf X_{\mathcal E}'\mathbf X_{\mathcal E})^{-1}$,
subtract $\mathbf X_{\mathcal E}'\mathbf y_{\mathcal E}$, and collect terms.

*Check at $h=20$ (window rule):*

| Episode | Rows removed | $B^Y$ (full 3.549573) | $B^G$ (full 4.865896) |
|---|---|---|---|
| WWII | 42 | 1.607201 | 2.264568 |
| Korea | 37 | 4.257979 | 6.518132 |
| WWI | 32 | 3.764247 | 5.165592 |

Formula and direct re-estimation agree to within $4.4\times10^{-11}$. The
same-sample ratios (D11) are $1.607201/2.264568=0.709716$ and
$4.257979/6.518132=0.653251$, which equal Stata's IV leave-one-out estimates.

**6.7 Episode shares.**
By Frisch–Waugh–Lovell, $B^G_{20}=\sum z^\perp_t g_{t..t+20}/\sum (z^\perp_t)^2$,
where $z^\perp$ is news residualized on the constant and twelve lags
($T_{20}=480$). Shares of $\sum(z^\perp_t)^2$ by quarters in each episode:

| Episode | WWI | WWII | Korea | Vietnam | Reagan |
|---|---|---|---|---|---|
| Share | 0.1396 | 0.3867 | 0.3318 | 0.0031 | 0.0036 |
| Rows | 8 | 18 | 13 | 20 | 28 |

The largest single quarters are 1941Q4 (0.2276) and 1950Q3 (0.2231).

**6.8 Grid facts** (`tbl-l13-grid`).

- *Redundancy:* a post-1947 sample with the WWII flag is the post-1947 sample
  (difference 0, equal $N$).
- *Ratio equals IV:* the same-sample reduced-form ratio equals IV within
  $9\times10^{-7}$ everywhere except post-1947 with trends at $h=1$. There
  $B^G_1=0.000064$ and $F_1=0.00007$, so a gap of 0.0207 comes from dividing
  by a near-zero first stage, not from software.

$M_{20}$ (SE; $F_{20}$) by cell:

| Sample ($T_{20}$) | none | tax | trends | both |
|---|---|---|---|---|
| full (480) | 0.7295 (0.0594; 10.4) | 0.7329 (0.0602; 11.0) | 0.9401 (0.1335; 8.6) | 0.9465 (0.1257; 8.7) |
| no WWII (440) | 0.7152 (0.1081; 3.4) | 0.7201 (0.1086; 3.4) | 1.1415 (0.2957; 2.6) | 1.2697 (0.2599; 2.6) |
| post-1947 (252) | 0.4899 (0.1977; 38.0) | 0.8177 (0.2490; 10.5) | 0.8872 (0.4180; 19.5) | 1.3661 (0.4612; 17.9) |

**6.9 Window sensitivity of Example 8** (`tbl-l13-windows`, course re-estimation).
$F$ is the robust first stage of `rffr` on `rz`.

| Window | $N$ | $\hat h^{\star R}$ (SE) | $\mathcal W_c$ | $p$ | max $\lvert\Delta$ unemployment$\rvert$ | max $\lvert\Delta$ funds rate$\rvert$ | $F$ |
|---|---|---|---|---|---|---|---|
| 1985m1–2000m12 | 138 | 4.6599 (0.1205) | 6.63 | 0.085 | 0.2922 | 0.0368 | 39.9 |
| 1980m1–2000m12 | 198 | −541.2 (79,698) | $1.19\times10^{7}$ | 0 | 4.5636 | 0.8824 | 12.0 |
| 1988m1–2000m12 | 102 | 5.9922 (0.1598) | 143.5 | $6.6\times10^{-31}$ | 0.2427 | 0.0323 | 37.7 |
| 1985m1–2004m12 | 186 | 7.1292 (0.6537) | 371.3 | prints 0 | 1.5112 | 0.1648 | 33.7 |

In the 1980 window the Gaussian fit fails: $a^U=0.018$, $c^U=-6.45$,
$a^R=72.6$. The notes call this a fit failure, not an estimate.

---

## 7. HTML lab plan (`interactives/13-counterfactual-workbench.qmd`)

Four Observable JS labs on one page, in chain order. Each has a setup, a
**Predict** prompt, controls with units, a plot, a reactive sentence,
comparisons, and a collapsed explanation. Outputs are labeled live, stored
result, or conceptual (D30). No Ramey–Zubairy row-level data ship (D5).

**Lab 1 — From a rate path to unemployment** (live).

- *Question:* what interventions does a proposed funds-rate path require, and
  what do they imply?
- *Invariants:* $\theta^R,\theta^U$ fixed at Example 8's GBF estimates
  ($h=0..48$). A banner lists linearity, policy invariance, and no
  anticipation.
- *Controls:*
  - path type: authors' peak shift, held cut, or custom;
  - size, basis points (−100 to 100, default −25);
  - duration, months (1–24, default 12);
  - shift, SE units (−2 to 2, default 1).
- *Computation:* the §6.2 recursion. Panels show $\Delta y^{R,c}$, $\Delta s^c$ (also
  in residual sd units, 0.1858), and $\Delta y^c$.
- *Reactive sentence:* "Holding the rate 25 bp lower for 12 months needs a
  first-month intervention of −0.206 (1.11 sd) and a +0.199 reversal at month
  12; unemployment is 0.175 points lower after 24 months."
- *Comparisons:* halve the size; double the duration; switch to the authors'
  shift ($\max|\Delta y^c|=0.011$).
- *Predict:* "Does a twice-as-long hold need twice-as-large surprises?"
- *Handoff:* `counterfactual_spec.json` (path, response source, assumptions
  ticked), used in Exercise 8.

**Lab 2 — What conditioning does** (live on stored CC0 estimates).

- *Question:* where does Example 8's counterfactual come from?
- *Invariants:* $\hat{\boldsymbol\vartheta}$ and $\mathbf V$ from REP13.
- *Controls:*
  - shift of each funds-rate parameter, SE units (−2 to 2, step 0.1,
    default $(0,-1,0)$);
  - toggle $\mathbf V_{UR}=\mathbf 0$;
  - toggle for the ledger path;
  - toggle for the authors' plotting coordinate.
- *Computation:* a 3×3 solve;
  $p=\operatorname{erfc}(\sqrt{\mathcal W/2})+\sqrt{2\mathcal W/\pi}\,e^{-\mathcal W/2}$.
  The default must reproduce `bc_gbf` to $10^{-6}$ and $p=0.084725$ (build
  test).
- *Reactive sentence:* "Moving the funds-rate peak 0.12 months earlier changes
  the rate path by at most 0.037 points but the conditional unemployment
  response by 0.292 at month 18; with $\mathbf V_{UR}=\mathbf 0$ the shift is
  zero."
- *Comparisons:* shift $a^R$ instead; shift all three together; toggle
  $\mathbf V_{UR}$.
- *Predict:* "If the two responses came from independent samples, how large
  would the counterfactual be?"

**Lab 3 — Grid and episodes** (stored Stata results, plus a live toy).

- *Question:* which choices move $M_h$, and which cells are identified?
- *Pre-registration:* the learner selects cells and horizons and locks them
  before anything renders.
- *Controls:*
  - sample (full, no WWII, post-1947);
  - trends and tax (each on or off);
  - $h$ (0–20, default 20);
  - episode removed (none or one of five);
  - rule (window or endpoint).
- *Plot:* $M_h$ with 95% pointwise band, an $F_h$ strip shaded below 10, and
  $B^Y_h,B^G_h$.
- *Reactive sentence:* "At $H=20$, adding trends raises the multiplier from
  0.729 to 0.940 on the same 480 rows while $F_{20}$ falls from 10.4 to 8.6."
- *Comparisons:* one switch at a time; WWII under both rules; Korea.
- *Live toy* (simulated, seed 13): delete blocks and watch the §6.6
  identity hold.
- *Predict:* "Will dropping WWII raise or lower the standard error?"
- *Handoff:* `sensitivity_plan.txt`, used in Exercise 5 and STA Task 1.

**Lab 4 — Classify the claims** (conceptual).

- Ten sentences about Example 8 and REP04. The learner picks a category and,
  where relevant, the missing assumption, then sees the evidence that would
  reclassify the sentence.
- Produces an exportable completion record.
- *Handoff:* the classification table, used in STA Task 5.

---

## 8. Practicum plan (REP13, STA13, handoff)

### 8.1 REP13 — Reproduce and scrutinize a counterfactual

| Item | Specification |
|---|---|
| Target | Jordà–Taylor (2025), *JEL* 63(1), 59–110, Example 8, Figure 8a–b: conditional GBF unemployment and funds-rate paths, six GMM parameters, plausibility $p$. |
| Code | `JEL-Code` commit `655696c1c576b7537c5a939d2c261f0a111ae663`, `Example8_Counterfactuals/GMM_GBF_counterfactual_clean.do`. Lines 39–40: window. 43–74: residualizing. 103–120: raw LP-IV (`xtivreg28`, stacked $N=7{,}938$). 136–174: joint GMM. 180–187: GBF and `nlcom` SEs. 199–226: counterfactual. 230–231: offset. 262–315: figures. |
| Data | `data_fred.dta` as committed (SHA-256 `08a1225f…`). |
| Kind | Exact numerical replication (D18), plus an interpretation audit. |
| Benchmark | `REP13-counterfactual.csv` (199 rows): parameters as in §1; $p$ 0.08. At $h=1$: `b_gbf` 0.075553231 (SE 0.027361018), `bc_gbf` 0.14573273, `br_gbf_c` 1.5506036. At $h=12$: `b_gbf` 0.51787215 (SE 0.11224252), `bc_gbf` 0.75964612, `br_gbf_c` 0.48658693, `bj` 0.66812062 (SE 0.516615815, $n=174$). |
| Tolerance | $10^{-6}$ absolute for coefficients and SEs; $N$ exact; $p$ to two decimals. |
| Runtime | 40.3 s (19.5); 48.0 s (18.5). |
| D3 | Ship the authors' six `.ster` files. `global REESTIMATE 0` (default) loads `gmmgbfjoint.ster` in place of lines 154–157 (verified mreldif 0); `1` runs the file unchanged (Q1). |
| Dependencies | Not shipped. With `REESTIMATE 0` the project loads `gmmgbfjoint.ster` for lines 154–157. It also merges the shipped CC0 `ivbet.dta` (the stored raw LP-IV results: 48 nonmissing `bj`, 0.668120623 at $h=12$, equal to the benchmark) in place of lines 103–120 (`xtivreg28`). And it replaces the `matselrc` calls at lines 164–167 with built-in subscripts (`matrix Vrr = V[4..6,4..6]`, and likewise for the other blocks). So no user-written command runs by default. `REESTIMATE 1` runs the file unchanged and needs `ssc install xtivreg28`, `ssc install ivreg2` (which installs the `ivreg28` helper), `ssc install ranktest`, and `net install dm79, from("https://www.stata.com/stb/stb56")` (`matselrc`), as in `replication-packages/DEPENDENCIES.md`. D4's optional list must gain `xtivreg28` and `ivreg28` in `docs/editor-decisions.md` (Q2). The shipped `ivbet.ster` is an October 2023 `xtivreg2` result ($N=7{,}938$) that the script never loads. |
| Discrepancy log | *Presentation:* the plotting offset; `br_gbf_c` computed but never drawn. *Inference:* 190 HAC lags on 138 rows; no counterfactual bands. *Software:* none beyond tolerance. *Interpretation:* a conditional mean labeled a counterfactual; a covariance statistic stored in a macro named `lucas` (line 209). |
| D5 | CC0: code, data, `.ster` files, and `ivbet.dta` ship with `SOURCE.md`. No SSC or STB file ships, because no `SOURCE.md` records a license for them. |
| Outputs | `rep13_check.csv`, `discrepancy_log.csv`, and a one-page `interpretation_audit.md`. |

### 8.2 STA13

Ramey–Zubairy data arrive through `data/raw/get_data.do`. It downloads from
the author URL in `packages/ramey-zubairy/SOURCE.md`, verifies SHA-256
`b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120` (as in
L01, L09), and stops with a message on
failure. The Jordà–Taylor files are a CC0 copy.

| Task | Starter | Assertions | Output |
|---|---|---|---|
| 1. Pre-specified grid | `sensitivity_plan.txt` locked first; program `rzcell sample omit trends tax` runs `ivregress 2sls …, vce(hac nwest opt)` (L09 footnote (ii); no `ivreg2`, D4), takes $F_h$ from the first-stage HAC $t$ at lag `e(hac_lag)` (L09 §6.7), and posts `h M se N F BY BG` | $M_{20}=0.729480\pm10^{-6}$; $N=480$; baseline s.e. within $10^{-6}$ of `REP04-linear-fiscal-multiplier.csv` at all 21 horizons; post-1947 omit cells identical | `grid.csv` |
| 2. Sample vs specification | `decompose.do` | $H=20$ effects +0.211, +0.003, −0.014, −0.240 (±0.001) | `tbl_grid_h20.csv`, figure |
| 3. Influential episodes | `episodes.do` (window and endpoint rules) | Korea $M_{20}=0.6533\pm10^{-4}$; WWII $N$ 438 vs 440 | `loo.csv`, figure |
| 4. Counterfactual | `counterfactual.do`: stored estimate, conditional mean, Mata inversion | `bc_gbf` within $10^{-6}$; $\max\lvert\Delta y^c\rvert=0.0110\pm10^{-4}$ | `cf_paths.csv` |
| 5. Unsupported claims | `report/claims.md` | at least 6 sentences, each with a category and a named assumption | table |

Runtimes: grid 22 s; Task 4 a few seconds; the [extra] windows 224 s.

*Built-in check* (`repair13/rz_grid_builtin.do`, 19.5). In the eight cells
without gaps (full and post-1947 samples, no omission), `ivregress 2sls …,
vce(hac nwest opt)` reproduces the `ivreg2` grid: $M_h$, s.e., and $F_h$ agree
within $10^{-6}$ and $N$ exactly at every horizon. The one exception is the
post-1947 trend cell at $h=1$, where $F_1=0.00007$ and $\hat M_1$ is 1193.83
against 1193.85. The count of $F_h<10$ stays 88 of 252. In the four no-WWII
cells, which have gaps, $M_h$ and $N$ agree to $10^{-9}$, but the automatic
lag and the HAC s.e. do not. At $h=20$ the s.e. are 0.1077, 0.1082, 0.2955,
0.2413 against 0.1081, 0.1086, 0.2957, 0.2599, and $F_{20}$ is 3.38, 3.39,
2.60, 2.74 against 3.38, 3.39, 2.58, 2.56. The build re-quotes gapped-sample
s.e. and $F$ (the no-WWII row of `tbl-l13-grid`, and the leave-one-episode-out
and endpoint-rule numbers) from the built-in run, and logs each difference as
a *software* row (Q8).

### 8.3 Handoff and submission

Lab 3's plan feeds Task 1, Lab 1's JSON feeds Task 4, and Lab 4's table feeds
Task 5. The submission follows blueprint §4.2: a replication record; master
do-file, logs, `.ster`, figures, and assertions; an interpretation record
(estimand, assumptions, units, uncertainty, limitations, claims table); and
the HTML lab record.

---

## 9. Slides arc

1. **Which conclusions follow?** — The title slide states the guiding
   question.
2. **An estimate and a calculation** — The rate moves 0.037; conditional
   unemployment moves 0.292; the ledger formula gives 0.011.
3. **Check the estimate first** — Grid, episodes, and first stages come
   before any counterfactual.
4. **Sixteen switches, twelve cells** — Report sample and specification
   separately.
5. **What moves $M_{20}$** — Trends +0.211; post-1947 −0.240; taxes and WWII
   small.
6. **Two episodes, 72 percent** — Dropping Korea gives 0.653; dropping WWII
   keeps the ratio but multiplies the SE by 3.4.
7. **First stages across the grid** — 88 of 252 cell-horizons are below 10;
   $\hat M_1=1{,}193.9$.
8. **Superposition** — The ledger formula and its three assumptions.
9. **Holding a cut** — A −0.206 surprise gives −0.175 after two years.
10. **What Example 8 computes** — A conditional mean, which is zero if
    $\mathbf V_{UR}=\mathbf 0$.
11. **Why $p=0.08$** — $1/(1-\zeta^2)$; neighbouring windows give $p\approx0$.
12. **Three readings** — Shock response, conditioning, and policy experiment,
    separated by the Lucas critique.
13. **Classify the sentence** — Lab 4 and the exercise workflow.
14. **For Lecture 14** — Could someone else reproduce and challenge this?

---

## 10. Open questions for the editor

1. **Example 8 under D3.** D3 treats Example 8 (part 1) as over 10 minutes.
   The target script runs in 40 s and uses only `gmmgbfjoint.ster`; the other
   five `.ster` files are not written by it, and `gmm.ster` differs from
   Example 6's. Should the default stay `REESTIMATE 0`, or become
   re-estimation?
2. **D4's optional list.** It omits `xtivreg28` and `ivreg28`, which line 103
   requires under `REESTIMATE 1`. They must be added to D4's optional list in
   `docs/editor-decisions.md` (not changed by this brief). The default path
   needs neither (§8.1, Dependencies).
3. **D5 and derived estimates.** Lab 3 ships Ramey–Zubairy cell estimates but
   no data rows. Does D5 permit that?
4. **The first category's key.** "Statistical result" has no glossary key.
   Add `statistical-result` under D22, or keep it in prose?
5. **The spine's opening.** The spine describes a 1990–1992 path; Example 8
   shifts a response's peak. Should the spine sentence change?
6. **Episode rules.** The episode windows and the window rule are course
   choices, while `omit` uses the endpoint rule. Approve both?
7. **Conditional bands.** Should $\mathbf V_c$ bands appear even in a footnote,
   when their width (0.034 at $h=12$) invites a precision reading?
8. **HAC with gaps.** `ivregress 2sls …, vce(hac nwest opt)` and `ivreg2,
   robust bw(auto)` agree on every gap-free grid cell but not on the no-WWII
   or leave-one-episode-out samples (§8.2, built-in check). Should gapped
   cells follow the built-in (D4) with the `ivreg2` values logged, or keep
   `ivreg2` there as an optional cross-check?
