# Lecture 14 brief — Research synthesis, replication audit, and defense

Planning brief (Phases 1–2 of the authoring guide), applying D1, D2, D5, D11
and D19. Numbers come from:
- the REP04 benchmark CSV (Stata 18.5);
- Ramey–Zubairy Table 1 (JPE p. 871);
- StataNow/SE 19.5 runs in `…/scratchpad/design-14/` (`pilot19/`,
  `rep14_flaws.do`, `rep14_combined.do`, `rep14_arwide.do`; logs free of
  `r(…)` lines);
- or the derivations in §6.

Displayed values are rounded from full precision.

---

## 1. Session brief

**Opening situation.**
A replication package arrives from another team. It contains:
- a `master.do`;
- an acquisition script;
- a README;
- a design memo;
- a two-row discrepancy log;
- a table and a figure.

The README promises Table 1 of Ramey and Zubairy (2018) "to within rounding,"
in under a minute, with no add-ons. Table 1's linear military-news
multipliers are .66 (.067) at two years and .71 (.044) at four. The package
prints 0.55 (0.128) and 0.44 (0.109).

In a clean directory `master.do` stops on line 1 with `r(170)`. After that is
fixed, it stops again with `r(111)` because `ivreg2` is missing. When it
finally runs, its "2-year" row uses 466 rows, where the benchmark has 493 at
the horizon the paper means. Nothing is fraudulent: every printed number is
what the code computes.

The auditor must reproduce the published result, log and classify every
difference, and decide which one matters. The author's job was to make that
possible. The package is the course's own teaching package (REP14, D19): the
REP04 pilot with eight documented flaws, benchmarked against the target of
D11.

**Decision or empirical question.**
Can another researcher reproduce, understand, and challenge this analysis from
what has been written down?
- As auditor: which discrepancies are real, what class is each, and which
  most threatens the published conclusion?
- As author: what must the methods section, memo, and log record so that the
  audit is possible?

The lecture's answer has four parts:
- A reported cell is a function of data, specification, software, variance
  estimator, and presentation.
- Each class changes one argument and leaves a signature in the coefficient,
  SE, and $T_H$ columns.
- Tolerance follows the noise source, and an exact $T_H$ is the sharpest test.
- Several flaws together do not add up, so the most consequential issue is
  judged by its effect on the claim, not by the order of fixes.

**Target student and prerequisites.**
The student has finished Lectures 1–13 and has a capstone package ready for
audit. Assumed from earlier lectures:
- the horizon-$h$ regression and its IV form (L1, L4);
- one-step $M_H=B^Y_H/B^G_H$ versus two-step $\tilde M_H$ (L4);
- the robust first-stage $F$ (L4) and the Anderson–Rubin test named in L4
  (its inversion into a set is taught here, in `#sec-l14-null-results`);
- HAC and bandwidth (L5);
- sample changes versus specification changes, and the three-way
  classification of claims (L13).

Assumed Stata: `ivregress 2sls`, `ivreg2`, `postfile`, `merge`, `assert`. New
here: `sysdir`/`adopath` for a clean ado path, SHA-256 checks, and inverting
the Anderson–Rubin test over a grid of $M^{0}$. No new estimator is
introduced.

**Learning outcomes (five).**

1. Write the four-paragraph methods section of an LP paper, and a
   consequential-choices ledger that tags each choice by whether it changes
   the estimand, the identifying assumptions, precision, or nothing.
2. Classify a discrepancy as data, specification, software, inference, or
   presentation from its signature, using a tolerance set by the noise
   source. The signature answers four questions: Is $T_H$ exact? Are the
   coefficients within tolerance? Do only the SEs differ? Does the schedule
   align after a horizon shift?
3. Report an uninformative response with its interval, its first-stage
   strength, and a weak-instrument-robust set, keeping "not significant,"
   "zero," and "not identified" distinct.
4. Answer an identification challenge with a pre-specified check, reporting
   what it changes and what it does not.
5. Audit an unfamiliar package against its published benchmark in a clean
   directory. Name the most consequential unresolved issue and whether it
   changes the conclusion, then defend one's own capstone under the same
   protocol. This is the mastery requirement.

**Anchor example.**

*Published benchmark (D11, D19).*
- Paper: Ramey and Zubairy (2018), JPE 126(2), 850–901, Table 1, linear
  column, military news: .66 (.067) and .71 (.044).
- Code: February 2018 package, `jordagk.do` (February 24, 2018), lines
  442–446 and 500.
- Data: `RZDAT.xlsx`, sheet `rzdat`, April 7, 2016 update; 508 quarters,
  1889Q1–2015Q4.
- Series: $y_t$ = `rgdp/rgdp_pott6` and $g_t$ = `(ngov/pgdp)/rgdp_pott6`,
  both ratios to sixth-degree-trend potential; $z_t$ =
  `news/(L.rgdp_pott6*L.pgdp)`.
- Controls: $\mathbf w_t$ = constant and lags 1–4 of $z,y,g$. WWII retained;
  no trend; no taxes.
- Inference: HAC from `ivreg2, robust bw(auto)`, bandwidth 29 (28 at
  $h=11$–14; `design-04/rz/l04_linear.csv`).
- Horizons: the 2- and 4-year integrals are $H=7$ and $H=15$.

| $H$ | $\hat M_H$ | HAC s.e. | $T_H$ | KP $F$ | $\tilde M_H$ |
|---|---|---|---|---|---|
| 0 | 1.306460 | 0.351669 | 500 | 7.33 | 1.306460 |
| 7 | 0.663715 | 0.067114 | 493 | 19.38 | 0.663167 |
| 15 | 0.713361 | 0.043575 | 485 | 11.22 | 0.711636 |
| 20 | 0.729480 | 0.059379 | 480 | 10.43 | 0.726344 |

*Software row (D1).* The unchanged REP04 pilot passes all 84 rows in
StataNow/SE 19.5 (revision August 12, 2026). The largest differences are
$2.93\times10^{-7}$ for coefficients and $4.75\times10^{-8}$ for SEs; $T_H$
is exact; the run takes 14.7 s.

*The teaching package as shipped (F1–F8 on; `rep14_combined.csv`).*

| Printed row | Horizon used | $\hat M$ | s.e. printed | $T_H$ | KP $F$ |
|---|---|---|---|---|---|
| "2-year integral" | 8 | 0.545860 | 0.127836 (HC, labeled HAC) | 466 | 9.36 |
| "4-year integral" | 16 | 0.444215 | 0.108819 (HC, labeled HAC) | 450 | 96.96 |
| (correct 2-year) | 7 | 0.546170 | 0.086499 (HAC) | 468 | 7.15 |
| (correct 4-year) | 15 | 0.464387 | 0.130885 (HAC) | 452 | 83.03 |

*The package's extension: post-WWII sample, 1947Q1–2015Q4, clean
specification.* The Anderson–Rubin 95% sets use a 0.02 grid (§6.6 gives the
wide grid at $H=0$). The report calls the impact multiplier "insignificant,
so spending has no short-run effect after 1947."

| $H$ | $\hat M_H$ | s.e. | $T_H$ | KP $F$ | $\mathcal C^{\mathrm{AR}}_H$ |
|---|---|---|---|---|---|
| 0 | $-8.316$ | 9.395 | 272 | 1.09 | $(-\infty,-1.70]\cup[13.50,\infty)$ |
| 7 | 0.746 | 0.157 | 265 | 187.3 | $[0.44,1.04]$ |
| 20 | 0.490 | 0.198 | 252 | 38.05 | $[0.08,0.88]$ |

No simulation is used. Every variant is a deterministic re-estimation (9.0 s
for twelve variants; 25.6 s for the factorial and grids), so D2's replication
count does not arise.

**Smallest useful model (ledger notation).**

The estimated object is the one-step cumulative LP-IV:
$$
\sum_{j=0}^{H}y_{t+j}=\mu_H+M_H\sum_{j=0}^{H}g_{t+j}+\boldsymbol\gamma_H'\mathbf w_t+u_{t,H},\qquad \sum_{j=0}^{H}g_{t+j}\ \text{instrumented by } z_t,\ t\in\mathcal T_H .
$$

The audit treats each reported cell as
$$
\text{cell}_H=\mathsf P\big(\hat M_H(\mathsf D,\mathsf S,\mathsf W),\ \widehat{\operatorname{se}}_H(\mathsf D,\mathsf S,\mathsf W,\mathsf V),\ T_H(\mathsf D,\mathsf S)\big),
$$
where:
- $\mathsf D$ is data (file, vintage, construction);
- $\mathsf S$ is specification (controls, lags, sample rule, estimator
  definition);
- $\mathsf W$ is software (version, dependencies, precision, paths);
- $\mathsf V$ is the variance estimator;
- $\mathsf P$ is presentation (indexing, rounding, labels, plotted series).

A discrepancy class is a change in one argument. Its signature follows from
the dependence: $T_H$ moves only with $\mathsf D$ and $\mathsf S$, only the SE
depends on $\mathsf V$, and $\mathsf P$ changes which numbers appear, never the
numbers themselves.

Write $d_H=\text{reproduced}_H-\text{published}_H$. A row passes when
$\lvert d_H\rvert\le\operatorname{tol}$. With several arguments changed, $d_H$
is not the sum of the one-at-a-time changes (§6.4).

**Dependency chain of sections** (the spine's seven steps in order, with the
opening and the evidence made explicit).

1. `#sec-l14-package-arrives` *A package arrives.* The shipped table (0.55
   and 0.44, against .66 and .71) fails twice in a clean directory, so "does
   it replicate?" must become a list of checkable objects.
2. `#sec-l14-methods-section` *The methods section.* Four paragraphs
   (estimand, identification, implementation, inference) fix those objects,
   and the package's memo (WWII retained, sixth-degree trend) already
   contradicts its code.
3. `#sec-l14-consequential-choices` *Documenting consequential choices.*
   Tagging each switch in `jordagk.do` lines 29–41 and 90 by what it changes
   predicts which flaws can move $\hat M_H$, $T_H$, or only the SE.
4. `#sec-l14-discrepancy-taxonomy` *Five classes and their signatures.*
   Single flaws leave the patterns the model predicts ($T_H{+}4$, SE only, a
   one-quarter shift). Because tolerance follows the noise source, a
   $2.2\times10^{-6}$ vintage difference is real but immaterial.
5. `#sec-l14-null-results` *Reporting an uninformative response.* L4 named
   the Anderson–Rubin test; inverting it is new here. For each $M^{0}$ on a
   grid, regress $\sum_j y_{t+j}-M^{0}\sum_j g_{t+j}$ on $z_t$ and
   $\mathbf w_t$ with the IV regression's HAC and bandwidth, and keep the
   $M^{0}$ whose $t$ on $z_t$ is not rejected at $\alpha$. As
   $\lvert M^{0}\rvert\to\infty$ that $t$ tends to the first-stage $t$, so a
   first stage indistinguishable from zero leaves both tails in the set
   (§6.6). The extension's impact multiplier ($-8.3$, s.e. 9.4, $F=1.09$)
   has a Wald interval that contains 0, but its robust set
   $(-\infty,-1.70]\cup[13.50,\infty)$ excludes 0 and 1 and is unbounded:
   the data reject a zero multiplier yet cannot bound it. Output responds to
   news on impact (reduced-form $t=4.06$) while spending does not
   (first-stage $t=-1.07$), which questions the exclusion restriction at
   $h=0$. Under the package's own identifying assumptions R2 is
   contradicted, not merely unsupported; if exclusion fails at $h=0$, R2 has
   no support at all. The robust set is not a null result in the glossary's
   sense.
6. `#sec-l14-criticism` *Answering an identification challenge.* The claim
   "your multiplier is WWII rationing" is answered by the pre-specified
   leave-WWII-out check: 0.772 (0.201), with $F_7$ falling from 19.4 to 4.1.
   It uses the same `omit` endpoint rule as L13's grid
   (`#sec-l13-influential-episodes`; $M_{20}=0.7152$, $T_{20}=440$). The
   answer concedes the first-stage consequence rather than defending the
   point estimate.
7. `#sec-l14-audit-protocol` *The audit protocol.* A clean directory and ado
   path, a fixed target, a tolerance written down first, and a log turn the
   previous sections into five audit questions and a rubric.
8. `#sec-l14-audit-evidence` *Auditing the teaching package.* The eight flaws
   are found and classified. The $2^3$ factorial shows that fix order is not a
   ranking: F8 moves $\hat M_7$ by $+0.108$ added alone and by $-0.100$
   added last. F8 is therefore ranked most consequential by what it does to the
   memo and the first stage.
9. `#sec-l14-closing-the-loop` *From June 1950 to a defended response.*
   Lecture 1's Korean War question is answered with an estimand, an
   identifying argument, a band, a replication record, and a survived audit,
   and what remains open is stated.

**Central notation.**
- From the ledger: $t,h,H,T_H,\mathcal T_H$; $y_t$, $s_t$ (written $g_t$, as
  in L4), $z_t$, $\mathbf w_t$, $p$; $\mu_H,\boldsymbol\gamma_H,u_{t,H}$;
  $B^Y_H,B^G_H,M_H$; $\alpha$, $\operatorname{se}(\cdot)$, $m$; $[t_0,t_1]$,
  $\mathcal S$.
- From L4: $\tilde M_H$, $F_H$.
- New (§2):
  - $\mathsf D,\mathsf S,\mathsf W,\mathsf V,\mathsf P$, set in sans-serif so
    that none reuses $D_{i,t}$, $\mathbf S$ or $\mathcal S$;
  - $d_H$ and $\operatorname{tol}$;
  - $f$ with $d^{\mathrm{add}}_{f,H}$, $d^{\mathrm{last}}_{f,H}$,
    $d^{\mathrm{Sh}}_{f,H}$;
  - $M^{0}$, the Anderson–Rubin hypothesized value (chosen to avoid the
    bandwidth $m$);
  - $\mathcal C^{\mathrm{AR}}_H$;
  - the labels F1–F8 and R1–R2.
- Reserved: $\tau,\kappa,\delta_k,k$.

**Glossary terms (the ten keys owned by L14; no new keys, per D22).**
- `replication-audit`: an independent, clean-environment reproduction of a
  designated published result, ending in a classified log and a judgment on
  the most consequential open issue.
- `reproducibility-package`: a directory a stranger can run without asking a
  question: README, master do-file, data or acquisition script, code,
  outputs, memo, log, report.
- `master-do-file`: the single entry point that rebuilds every output from raw
  data with relative paths and declared dependencies.
- `discrepancy-log`: every difference from the target, with object, values,
  class, diagnosis, and status. An empty log is suspicious.
- `methods-section`: four paragraphs (estimand, identification,
  implementation, inference) that fix what a replication is checked against.
- `consequential-choice`: a decision that changes the estimand, the
  assumptions, or precision, recorded with its alternative.
- `numerical-tolerance`: the largest difference counted as agreement. It is
  set by the noise source before comparing, and it is exact for integers.
- `null-result`: an interval containing zero. It is informative only if it
  also excludes important values, and it never means "no effect" under weak
  identification.
- `referee-report`: an assessment that names the most consequential weakness
  and a check that could change the conclusion.
- `defense`: the author's evidence-based answer: what the check changed, what
  it did not, and the updated log.

**Likely explanatory footnotes.**
- Batch Stata returns exit code 0 after an error.
- Float versus double storage, and the $10^{-6}$ tolerance.
- `bw(29)` means 28 Bartlett lags.
- Anderson–Rubin sets can be unbounded.
- Shapley averages.
- D5 acquisition scripts.
- D6 on author contact.

**Required reading** (blueprint, Lecture 14; D31).
- R16, Montiel Olea, Plagborg-Møller, Qian, and Wolf (2026), *NBER
  Macroeconomics Annual* 40, 111–152: revisit its practical recommendations,
  read with `#sec-l14-methods-section` and `#sec-l14-consequential-choices`.
  The guide names sections of the version frozen in `VERIFIED.md`: "section
  numbers from the frozen version; page range to confirm."
- The selected capstone paper and its replication documentation, in full.
- The design memo of the project the student audits (in part (a), the
  teaching package's memo).

**Candidate figures** (TikZ/pgfplots via `figures/build.sh`, reading committed CSVs).

| Label | Question | Visible lesson | Data |
|---|---|---|---|
| `fig-l14-methods-template` | What must each methods paragraph contain? | Four boxes (estimand, identification, implementation, inference), each pinned to its REP04 fact and to the classes it rules out | conceptual |
| `fig-l14-discrepancy-signatures` | Can the class be read from $d_H$ by horizon? | Rows F3–F8 by columns coefficient, SE, $T_H$: SE only (F5), $T_H{+}4$ (F4), growing $T_H$ gap (F8), one-quarter shift (F6) | `rep14_flaws.csv`, benchmark |
| `fig-l14-audit-workflow` | In what order does an audit run? | Clean directory → run → $T_H$, coefficients, SE → classify → rank → report → response | conceptual |
| `fig-l14-ar-sets` | Why is "insignificant" not "zero"? | AR $p$-value curves: full-sample and post-WWII dips at $H=7$; post-WWII $H=0$ above 0.05 in both tails, rejecting 0 and 1; Wald intervals beneath | `rep14_ar.csv`, `rep14_arwide.csv` |
| `fig-l14-order-dependence` (droppable, D24) | Does a fix's effect depend on the other flaws? | $H=7$ bars: add-one, added-last, Shapley | §6.4 |

The discrepancy log is a table (`tbl-l14-discrepancy-log`), not a figure
(D24).

**Exercise capabilities to test.**
- Write a methods section and a choices ledger.
- Predict signatures from the five-argument model.
- Set a tolerance before comparing.
- Run a package in a clean directory.
- Compare 21 horizons with `merge` and `assert`.
- Localize a difference by bisection.
- Decompose a gap caused by several flaws.
- Invert the Anderson–Rubin test over a grid of $M^{0}$ into a set, and say
  when it is unbounded (taught in `#sec-l14-null-results`, not assumed from
  L4).
- Answer a referee with one check.
- Write the audit and the response.

**Candidate controlled experiments.**
- One flaw at a time against the benchmark.
- The $2^3$ factorial of F3, F4, F8.
- A log-scale tolerance slider.
- Full, WWII-omitted, and post-WWII windows at a fixed specification.
- A one-quarter horizon shift under rounding.

**What this session postpones.** Nothing in the course. Beyond it:
- multiple-testing corrections over a specification search;
- pre-registration;
- journal data-editor procedures;
- author contact (D6).

**Question handed on.** None within the course; the student now writes the
question. The last slide asks for three sentences: the capstone's estimand,
its identifying argument, and its most consequential unresolved issue.

---

## 2. Concept and notation ledger

Inherited symbols keep their ledger meaning. New ones are proposed for
`notation-ledger.md` §8 (see §10). First-use entries abbreviate
`#sec-l14-…`.

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $h$, $H$ | Horizon; horizon of a reported cell | integers $\le20$ | quarters after $t$ | quarters | `package-arrives` (L1) | F6 shifts $H$ |
| $T_H$, $\mathcal T_H$ | Rows and row set at $H$ | integer; set | fixed by $\mathsf D,\mathsf S$ | rows | `package-arrives` (L1) | first check; tolerance 0 |
| $y_t$, $g_t$ | GDP and government spending over potential ($g_t$ is $s_t$) | scalars | $t$ | ratio to potential | `methods-section` (L4) | F3 |
| $z_t$ | Military news | scalar | $t$ | ratio to lagged nominal potential | `methods-section` (L4) | F4 |
| $\mathbf w_t$ | Constant and lags 1–4 of $z,y,g$ | $13\times1$ | $t-1,\dots,t-4$ | as series | `methods-section` (L1, L4) | $9\times1$ under F4 |
| $M_H$, $\hat M_H$ | One-step cumulative multiplier | scalar | $t,\dots,t+H$ | dollars per dollar | `package-arrives` (L2, L4) | throughout |
| $\tilde M_H$ | Two-step ratio | scalar | rows vary with $h$ | as $M_H$ | `discrepancy-taxonomy` (L4) | F7 |
| $B^Y_H$, $B^G_H$ | Common-sample cumulative reduced forms | scalars | $\mathcal T_H$ | cumulated ratio per unit news | `audit-evidence` (L4) | §6.1 |
| $F_H$ | Kleibergen–Paap robust first-stage $F$ | scalar | $H$ | none | `criticism` (L4) | F8; Lab 4 |
| $\operatorname{se}(\hat M_H)$; $m$ | Standard error, estimator named; HAC truncation lag | scalar; integer | — | as $M_H$; lags | `package-arrives` (L5) | F5; `bw(29)` is $m=28$ |
| $\alpha$; $[t_0,t_1]$; $\mathcal S$ | Level; sample window; pre-specified set | — | — | — | `null-results`, `criticism` (L5, L13) | AR sets; leave-WWII-out |
| $\mathsf D,\mathsf S,\mathsf W,\mathsf V,\mathsf P$ | Arguments of a reported cell | records | per run | — | `discrepancy-taxonomy` | protocol; Labs 1–4 |
| $\text{cell}_H$ | Reported entry (estimate, s.e., $T_H$, label) | tuple | per run | as reported | `discrepancy-taxonomy` | — |
| $d_H$ | Reproduced minus published value | scalar | per run | the object's | `discrepancy-taxonomy` | log; Lab 2 |
| $\operatorname{tol}$ | Largest $\lvert d_H\rvert$ counted as agreement | scalar | set before comparing | the object's | `discrepancy-taxonomy` | $10^{-6}$; 0 for $T_H$ |
| $f$; $d^{\mathrm{add}}_{f,H}$, $d^{\mathrm{last}}_{f,H}$, $d^{\mathrm{Sh}}_{f,H}$ | Flaw index; add-one, added-last, and Shapley contributions | label; scalars | — | as $M_H$ | `audit-evidence` | §6.4; exercise 7; Lab 3 |
| $M^{0}$ | Hypothesized multiplier in the Anderson–Rubin test | scalar | — | as $M_H$ | `null-results` | replaces the L4 glossary's $m$ |
| $\mathcal C^{\mathrm{AR}}_H$ | $M^{0}$ values not rejected at $\alpha$ | subset of $\mathbb R$ | $H$ | as $M_H$ | `null-results` | `fig-l14-ar-sets`; exercise 6 |
| F1–F8, R1–R2 | Seeded flaws and seeded report claims | labels | — | — | `audit-evidence` | §8.1; Lab 4 |

---

## 3. Terminology ledger

| Phrase | Treatment | Key | Definition or note | First marked |
|---|---|---|---|---|
| replication audit | glossary | `replication-audit` | Clean-environment reproduction of a designated published result, ending in a classified log. | `#sec-l14-package-arrives` |
| reproducibility package | glossary | `reproducibility-package` | A directory a stranger can run without asking a question. | `#sec-l14-package-arrives` |
| master do-file | glossary | `master-do-file` | The single entry point that rebuilds every output from raw data. | `#sec-l14-package-arrives` |
| discrepancy log | glossary | `discrepancy-log` | Every difference from the target, with class, diagnosis, and status. | `#sec-l14-package-arrives` |
| methods section | glossary | `methods-section` | Estimand, identification, implementation, and inference in four paragraphs. | `#sec-l14-methods-section` |
| consequential choice | glossary | `consequential-choice` | A decision that changes the estimand, assumptions, or precision. | `#sec-l14-consequential-choices` |
| numerical tolerance | glossary | `numerical-tolerance` | The largest difference counted as agreement, fixed by the noise source. | `#sec-l14-discrepancy-taxonomy` |
| null result | glossary | `null-result` | An interval containing zero; not "no effect" under weak identification. | `#sec-l14-null-results` |
| referee report | glossary | `referee-report` | Names the most consequential weakness and a check that could change the conclusion. | `#sec-l14-criticism` |
| defense | glossary | `defense` | What the requested check changed, what it did not, and the updated log. | `#sec-l14-criticism` |
| exit code 0 after an error | footnote | — | Batch Stata returns 0 after `r(…)`, so the log is checked. | `#sec-l14-package-arrives` |
| float vs double; `bw(29)` | footnote | — | Double accumulation moves $\hat M_1$ by $1.6\times10^{-6}$; `bw(29)` is 28 lags. | `#sec-l14-discrepancy-taxonomy` |
| unbounded Anderson–Rubin sets | footnote | — | A weak first stage gives rays; the tail $p$-value tends to the first-stage $p$-value. | `#sec-l14-null-results` |
| Shapley average | footnote | — | Mean contribution over removal orders; a summary, not a causal split. | `#sec-l14-audit-evidence` |
| D5, D6 | footnote | — | Acquisition script; no author contact. (R16 is required reading, §1.) | `#sec-l14-audit-protocol` |
| discrepancy class, signature, seeded flaw, clean directory, bisection | prose | — | Defined in place; `discrepancy-class` is a candidate key (§10). | `#sec-l14-discrepancy-taxonomy` |

Earlier-owned terms, used as linked prose:
- L2: common sample, statistical reproduction.
- L3: specification record.
- L4: cumulative, one-step, and two-step multiplier; weak instrument; robust F
  statistic; Anderson–Rubin test.
- L5: HAC estimator, bandwidth.
- L13: specification grid, sample window, unsupported claim.

---

## 4. Evidence and visual ledger

Asset status: *computed* means a validated number exists in the scratch run
named; *to build* means the course asset (figure source, CSV, JSON) is still
to be produced from that run by the instructor build.

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| Table 1's cells are $H=7$ and $H=15$ | 0.6637145→.66, 0.0671140→.067; 0.7133608→.71, 0.0435753→.044 (§6.3) | table | benchmark CSV; JPE p. 871 | computed | `tbl-l14-benchmark` |
| The benchmark reruns in 19.5 within tolerance (D1) | 84 rows; max $\lvert d\rvert$ $2.93\times10^{-7}$ (coef), $4.75\times10^{-8}$ (SE); $T_H$ exact; 14.7 s | log row | `pilot19/outputs/d1rerun/checks.csv` | computed; instructor build reruns | `tbl-l14-discrepancy-log` |
| The shipped package prints 0.55 (0.128) and 0.44 (0.109) on 466 and 450 rows | shipped variant, HC, $H=8,16$ | table | `rep14_combined.csv` | computed; package to build | `tbl-l14-shipped` |
| The package fails twice in a clean directory | `cd` to an absent absolute path → `r(170)`; empty PLUS → `which ivreg2` `r(111)` | prose + log excerpt | `rep14_flaws.log` | computed | — |
| Each class leaves a signature | single flaws vs benchmark, $h=0..20$: F4 $T_H{+}4$; F5 SE only (ratio 1.53 at $H=0$, 0.89 at $H=20$); F8 $T_H$ gap 22–40; F3 coef only, $T_H$ exact | figure | `rep14_flaws.csv` | computed; figure to build | `fig-l14-discrepancy-signatures` |
| Tolerance is tied to the noise source | 19.5 rerun $2.9\times10^{-7}$; double storage $1.58\times10^{-6}$ ($H=1$); CSV vintage $2.25\times10^{-6}$ ($H=1$); two-step gap $5.5\times10^{-4}$–$3.1\times10^{-3}$ | table | `rep14_flaws.csv`, benchmark | computed | `tbl-l14-tolerance` |
| `ivregress, vce(hac bartlett 28)` equals `ivreg2, robust bw(29)` | $d=0$ at 9 horizons | footnote | `design-04/rz/l04_hac_check.csv` (log clean) | reused | — |
| One-step IV is the common-sample ratio | $H=20$: 3.549573/4.865896 vs 0.729480, error $<10^{-12}$ | equation | `pilot19/.../components.csv` | computed | `eq-l14-ratio` |
| Fix order changes a flaw's apparent size | $H=7$: F4 $-0.027$ / $-0.165$ / Shapley $-0.094$; F8 $+0.108$ / $-0.100$ / $+0.007$ | table (figure droppable) | 2³ factorial, §6.4 | computed | `tbl-l14-factorial`, `fig-l14-order-dependence` |
| Leave-WWII-out answers the referee with numbers | $\hat M_7=0.772$ (0.201), $T_7=464$, $F_7=4.11$ vs 19.38 | table | `rep14_flaws.csv` (S3) | computed | `tbl-l14-leave-wwii-out` |
| The extension changes the estimand and instrument strength | post-WWII $\hat M_7=0.746$ (0.157), $T_7=265$, $F_7=187.3$; $\hat M_0=-8.32$ (9.40), $F_0=1.09$ | table | `rep14_flaws.csv` (E1) | computed | `tbl-l14-extension` |
| "Insignificant" is not "zero" | $\mathcal C^{\mathrm{AR}}_0=(-\infty,-1.70]\cup[13.50,\infty)$; rejects $M^0=0$ and 1; tail $p\to0.2845$ | figure | `rep14_ar.csv`, `rep14_arwide.csv` | computed; figure to build | `fig-l14-ar-sets` |
| A methods section has four jobs | template with the REP04 facts | figure | §1 anchor | to build | `fig-l14-methods-template` |
| An audit has an order | workflow | figure | `capstone/index.qmd` | to build | `fig-l14-audit-workflow` |
| A log has six fields | Object, Published, Reproduced, Class, Diagnosis, Status | table | `capstone/index.qmd` | exists | `tbl-l14-discrepancy-log` |
| The June 1950 news was large | 1950Q3 news 0.600 of lagged nominal trend GDP (L1 brief); residualized 0.592, second only to 1941Q4 (L4 brief) | prose | L01, L04 `BRIEF.md` | quoted | — |

---

## 5. Assessment map

Ten exercises. Three are Stata [computational], and one of those is also
[data].

| Outcome | Exercise | Tags | Mode | Hint | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. Four paragraphs for REP04 | [core] [pencil] | Methods section plus a ledger of `jordagk.do` switches (lines 29–41, 90) | "If flipped, is the cell a different number of the same object?" | `sample`, `omit` change the estimand; `shock` the identifying assumption; `p`, `trends`, `tax` the conditioning; `ynorm` data construction; `state` nothing in the linear column | 1 |
| 2 | 2. Signatures from a model | [core] [pencil] | Mark which outputs each argument can move; classify six anonymized $d_H$ patterns | Start with $T_H$ | F5 SE only; F4 $T_H+4$; F8 gap $22+\min(H,18)$; F6 aligns after a shift; F3 coefficient-only with exact $T_H$ (read the code); double storage below $2\times10^{-6}$ | 1 |
| 2 | 3. Tolerance first | [core] [pencil] | Set $\operatorname{tol}$ for five rows before looking; mark each resolved, explained, or open | Name each row's noise source | $T_H$ exact; double storage and CSV vintage fail $10^{-6}$ but are explained; the two-step gap is a specification row | 2 |
| 5 | 4. Clean-directory run | [core] [computational] | Fresh path with a space, empty PERSONAL/PLUS; run `master.do`; grep `^r\(`; apply minimal fixes; write `audit/run-record.md` | The exit code is 0 even after an error | `r(170)` then `r(111)`; the fixed run reproduces the package's own `output/package_results.csv` exactly | 4 |
| 2, 5 | 5. Compare, bisect, log | [core] [computational] [data] | `get_data.do` with SHA-256 (D5); `audit/compare.do` asserts $T_H$, coefficients, SEs at 21 horizons; bisect with the package's switches; write `discrepancy-log.csv` | Compare $T_H$ first; revert one switch at a time | Ten rows (F1–F8, 19.5 rerun, CSV vintage); $T_7=468$ vs 493; after F3, F4, F8 are reverted, coefficients within $3\times10^{-7}$; after F5, SEs within $5\times10^{-8}$ | 3 |
| 3 | 6. An uninformative extension | [computational] | Anderson–Rubin sets after 1947 at $H=0,7,20$ beside Wald intervals; a three-sentence paragraph replacing R2 | What does the statistic become as $\lvert M^{0}\rvert\to\infty$? | $(-\infty,-1.70]\cup[13.50,\infty)$, $[0.44,1.04]$, $[0.08,0.88]$ (± grid step); tail $p\to0.2845$; at $H=0$ zero and 1 are rejected but the set is unbounded, so R2 is contradicted and the exclusion restriction at $h=0$ is questioned | 4 |
| 2, 5 | 7. Fix order is not a ranking | [core] [pencil] | From the $2^3$ table at $H=7$ compute $d^{\mathrm{add}},d^{\mathrm{last}},d^{\mathrm{Sh}}$; explain F8's sign change; rank by consequence | Draw the cube and walk its edges | Numbers in §6.4; F8 or F4 accepted when argued from the memo, the first stage, and L4's A3 | 3 |
| 4 | 8. Answer the referee | [core] [pencil] | 150-word defense against "your multiplier is WWII rationing" | Say what the check was pre-specified to detect | Reports 0.772 (0.201), $T_7=464$, $F_7=4.11$ vs 19.38; concedes the first-stage consequence; no "robust," no adjectives | 4 |
| 5 | 9. Audit report and response | [core] | Five-question audit of the teaching package, then the author response and updated log | Answer question 4 last | §8.2 rubric; the model answer names F8 and says the package does not reproduce Table 1 (2-year band $[0.30,0.80]$), while the benchmark itself stands | 4 |
| 2 | 10. Where $T_H$ comes from | [pencil] [extra] | Derive $500-H$, $504-H$, and the WWII exclusion count | List what each of `L4.omit`, `F{h}.omit`, `omit` removes | $478-2H$ for $H\le18$; 1941Q2 survives when $H\ge19$ (§6.5) | 1 |

Each outcome has evidence in at least two media:
- Outcome 1: `#sec-l14-methods-section`, `fig-l14-methods-template`,
  exercise 1, Lab 1.
- Outcome 2: `fig-l14-discrepancy-signatures`, `tbl-l14-tolerance`,
  exercises 2, 3, 5, 7, 10, Labs 1–3.
- Outcome 3: `fig-l14-ar-sets`, exercise 6, Lab 4.
- Outcome 4: `tbl-l14-leave-wwii-out`, exercise 8, Lab 4.
- Outcome 5: `fig-l14-audit-workflow`, exercises 4, 5, 7, 9, REP14, STA14.

---

## 6. Derivations to verify

**6.1 One-step IV is the common-sample ratio (`eq-l14-ratio`).**
*Source identity:* Frisch–Waugh–Lovell (L3) and the just-identified IV normal
equation.
*Steps:*
- Residualize $\sum_j y_{t+j}$, $\sum_j g_{t+j}$ and $z_t$ on $\mathbf w_t$
  over $\mathcal T_H$; call the residuals $\tilde Y$, $\tilde G$, $\tilde z$.
- The IV normal equation $\tilde z'(\tilde Y-M\tilde G)=0$ gives
  $\hat M_H=\tilde z'\tilde Y/\tilde z'\tilde G$.
- Divide numerator and denominator by $\tilde z'\tilde z$. This gives
  $\hat M_H=\hat B^Y_H/\hat B^G_H$, both reduced forms estimated on the same
  rows.

*Check (19.5, `pilot19/.../components.csv`):*
- $H=7$: $1.127305603774036/1.698479609642739=0.6637145346779614$ against IV
  $0.6637145346772381$, so $d=7.2\times10^{-13}$.
- $H=20$: $3.549572844441838/4.865895536884554=0.7294798701565414$ against
  $0.7294798701569558$, so $d=-4.1\times10^{-13}$.
- The two-step ratios 0.66316748 and 0.72634429 differ because each summed
  response uses its own $T_h=500-h$.

**6.2 Signatures follow from the model.**
In $\text{cell}_H$, a change in $\mathsf V$ alone leaves $\hat M_H$ and $T_H$
fixed.
- *Check F5.* The maximum coefficient $\lvert d\rvert$ is $2.93\times10^{-7}$
  (the same as the unflawed rerun) and $T_H$ is exact. The HC/HAC SE ratios
  are 1.5314, 1.0799, 0.9459 and 0.8857 at $H=0,7,15,20$. With
  `vce(hac bartlett 4)` they are 1.4519, 1.0071, 0.9203 and 0.8148.
- `ivregress, vce(hac bartlett 28)` reproduces `ivreg2, robust bw(29)` with
  $d=0$ at nine horizons (`design-04/rz/l04_hac_check.csv`).

A change in $\mathsf D$ that keeps missingness keeps $T_H$.
- *Check F3.* $T_H$ is exact, $\hat M_7=0.670819$, and the maximum
  $\lvert d\rvert$ is 0.0123.

**6.3 Rounding hides half of a horizon shift.**

| $H$ | $\hat M_H$ | s.e. | Rounded | Published |
|---|---|---|---|---|
| 7 | 0.6637145 | 0.0671140 | .66 (.067) | .66 (.067) |
| 8 | 0.6689613 | 0.0587844 | .67 (.059) | — |
| 15 | 0.7133608 | 0.0435753 | .71 (.044) | .71 (.044) |
| 16 | 0.7096114 | 0.0441816 | .71 (.044) | — |

Under F6 alone the 4-year cell survives rounding and the 2-year cell does not.
Only the full-precision schedule exposes the shift.

**6.4 Order dependence (`tbl-l14-factorial`).**
Let $\mathcal F=\{\text{F3},\text{F4},\text{F8}\}$ and $\hat M_7(\mathcal A)$
the estimate with flaw set $\mathcal A$ on.

| Flaws on | none | F3 | F4 | F8 | F3,F4 | F3,F8 | F4,F8 | all |
|---|---|---|---|---|---|---|---|---|
| $\hat M_7$ | 0.663715 | 0.670819 | 0.636393 | 0.771875 | 0.645807 | 0.711464 | 0.620135 | 0.546170 |

The three contributions are
$$
\begin{aligned}
d^{\mathrm{add}}_{f}&=\hat M(\{f\})-\hat M(\varnothing),\\
d^{\mathrm{last}}_{f}&=\hat M(\mathcal F)-\hat M(\mathcal F\setminus\{f\}),\\
d^{\mathrm{Sh}}_{f}&=\sum_{\mathcal A\subseteq\mathcal F\setminus\{f\}}\frac{\lvert\mathcal A\rvert!\,(2-\lvert\mathcal A\rvert)!}{3!}\big[\hat M(\mathcal A\cup\{f\})-\hat M(\mathcal A)\big].
\end{aligned}
$$

| $H=7$ | $d^{\mathrm{add}}$ | $d^{\mathrm{last}}$ | $d^{\mathrm{Sh}}$ |
|---|---|---|---|
| F3 | $+0.007105$ | $-0.073965$ | $-0.030786$ |
| F4 | $-0.027321$ | $-0.165294$ | $-0.093664$ |
| F8 | $+0.108160$ | $-0.099637$ | $+0.006905$ |

*Checks:*
- The Shapley terms sum to $-0.117545$, and the total is
  $0.546170-0.663715=-0.117544$ (rounding in the last digit).
- The add-one terms sum to $+0.087944$, so additivity fails.
- At $H=0$ the Shapley terms are $+0.014444$, $-0.259136$, $+0.465143$, summing
  to $+0.220450$.
- At $H=20$ they are $-0.012416$, $-0.023372$, $-0.061206$, summing to
  $-0.096993$.

**6.5 Sample sizes.** In the data, `news` is first nonmissing at 1890Q1
($t=5$), and every other input is complete for $t=1,\dots,508$.
- Benchmark: $z_t$ exists from $t=5$ and $L^4 z_t$ from $t=9$. The last row is
  $508-H$, so $T_H=500-H$.
- F4: lags of $y,g$ need $t\ge5$, so $T_H=504-H$ (504 at $H=0$ ✓).
- $p=2$: $T_H=502-H$ ✓.
- F8: a row drops if WWII (1941Q3–1945Q4, 18 quarters) contains $t$, $t-4$,
  or $t+H$. The excluded dates are
  $[1941\text{Q3}-H,\ 1945\text{Q4}-H]\cup[1941\text{Q3},1946\text{Q4}]$.
  - For $H\le18$ the two intervals are contiguous, with $22+H$ dates, so
    $T_H=478-2H$: 478, 464, 442 at $H=0,7,18$ ✓.
  - For $H\ge19$ they leave 1941Q2 in, with 40 dates, so $T_{19}=441$ and
    $T_{20}=440$ ✓.
- Post-WWII: rows start at $t=233$ (1947Q1) and four lags require $t\ge237$,
  so $T_H=272-H$: 272, 265, 252 ✓.

**6.6 The Anderson–Rubin set at impact after 1947.**
*Statistic:* the HAC $t$ on $z_t$ in the regression of
$\sum_j y_{t+j}-M^{0}\sum_j g_{t+j}$ on $(z_t,\mathbf w_t)$, bandwidth fixed at
the IV regression's (22).

*Limit:* dividing through by $M^{0}$, as $\lvert M^{0}\rvert\to\infty$ the
statistic tends to the first-stage $t=-1.070225$. So
$p\to2\Phi(-1.070225)=0.284518$. The grid gives 0.2846 at $-10^5$ and 0.2845
at $+10^5$ ✓.

*At $M^{0}=0$:* the statistic is the reduced-form $t=4.0560774$, so
$p=4.99\times10^{-5}$ and zero is rejected. At $M^{0}=1$, $p<10^{-4}$.

*Boundaries:*
- $p(-1.70)=0.0518$ and $p(-1.68)=0.0499$.
- $p(13.25)=0.0487$ and $p(13.50)=0.0509$.
- So $\mathcal C^{\mathrm{AR}}_0=(-\infty,-1.70]\cup[13.50,\infty)$ at grid
  resolution.

*Wald interval:* $-8.316022\pm1.96\times9.395350=[-26.7309,\,10.0989]$. The
first-stage coefficient is $-0.00445$: after 1947, spending does not rise on
impact.

*Other sets (step 0.02):*
- Post-WWII $H=7$: $[0.44,1.04]$ against Wald $[0.439,1.053]$.
- Post-WWII $H=20$: $[0.08,0.88]$ against $[0.102,0.877]$.
- Full sample $H=7$: $[0.58,0.86]$ against $[0.532,0.795]$.

**6.7 Rows near the tolerance (`tbl-l14-tolerance`).**

| Row | Max $\lvert d\rvert$ | Where | Class | Status |
|---|---|---|---|---|
| StataNow 19.5 vs Stata 18.5 benchmark (D1) | coef $2.93\times10^{-7}$, SE $4.75\times10^{-8}$ | $H=0$–20 | software | resolved |
| Double-precision accumulation | coef $1.575\times10^{-6}$ | $H=1$ | software | explained |
| `rzdatnew.csv` instead of `RZDAT.xlsx` (SHA-256 `433ba651…` vs `b2d85087…`) | coef $2.248\times10^{-6}$, SE $8.70\times10^{-7}$ | $H=1$ | data | explained: CSV prints 1–9 decimals |
| Two-step ratio vs one-step | $3.1356\times10^{-3}$ | $H=20$ | specification | explained: varying samples |

*Leave-WWII-out Wald:* $0.771875\pm1.96\times0.200942=[0.378,1.166]$. The
shipped 2-year row with HC s.e. gives $0.545860\pm1.96\times0.127836=[0.295,0.796]$.

---

## 7. HTML lab plan (Replication Referee Desk, `interactives/14-replication-referee-desk.qmd`)

Four Observable JS labs on one page, in chain order. Each has a setup, a
**Predict before using the controls** prompt, labeled controls, a plot or
table, a reactive sentence, controlled comparisons, and a collapsed
explanation.

Estimates are **stored results** from StataNow 19.5. They are exported from
`rep14_flaws.csv`, `rep14_combined.csv` and `rep14_ar*.csv` to JSON with
metadata (do-file, revision, input SHA-256, date). Only differences, pass/fail
flags, and decompositions are computed live. No approximation appears, so D30
does not arise.

**Lab 1 — Read the signature (stored; live $d_H$).**
- *Question:* can the class be named from the pattern before reading code?
- *Invariants:* the REP04 benchmark; every argument but one at its benchmark
  value.
- *Controls:* pattern A–G (F3–F8 and the double-storage decoy, labels
  hidden); object tabs (coefficient, SE, $T_H$); horizons 0–20 quarters.
- *Reactive sentence:* "Pattern C: coefficients within $3\times10^{-7}$,
  $T_H$ exact, SEs off by a factor 0.89–1.53. Only the variance estimator does
  that: inference."
- *Comparisons:* F5 against Newey–West(4); F3 against F4.
- *Handoff:* a classification CSV for exercise 2.

**Lab 2 — Set the tolerance (live).**
- *Question:* which rows change status as the tolerance moves, and is a
  change of status a finding?
- *Invariants:* the §6.7 rows and the F5 SE row.
- *Controls:* $\log_{10}\operatorname{tol}$ from $-9$ to $-2$ (default $-6$);
  $T_H$ tolerance locked at 0; a commit-before-reveal switch.
- *Reactive sentence:* "At $10^{-6}$, double storage ($1.58\times10^{-6}$)
  and CSV vintage ($2.25\times10^{-6}$) fail. Both have a known noise source,
  so they are explained, not open."
- *Comparisons:* at $10^{-7}$ the 19.5 rerun fails too; at $10^{-3}$ the
  two-step gap passes at $H=7$ and fails at $H=20$.
- *Handoff:* a tolerance record for `audit/compare.do`.

**Lab 3 — The shipped package, decomposed (stored cube; live contributions).**
- *Question:* what is "the effect of fixing F4" when two other flaws remain?
- *Invariants:* the eight stored cells at $H\in\{0,7,15,20\}$ with KP $F$;
  F5–F7 off.
- *Controls:* F3, F4, F8 switches (default on); horizon (default 7); one of six
  fix orders.
- *Reactive sentence:* "Fixing F4 first raises the 2-year multiplier by 0.165;
  fixing it last raises it by 0.027. Its Shapley share is 0.094."
- *Prediction:* "Which single fix brings $\hat M_7$ closest to .66?" (F8:
  0.646, on 497 rows.)
- *Handoff:* the cube as CSV. Exercise 5's bisection must reproduce it to
  $10^{-6}$.

**Lab 4 — Referee desk (stored).**
- *Question:* which check most changes the verdict on the package's claims?
  - R1: "replicates Table 1 within rounding."
  - R2: "post-WWII impact multiplier insignificant, so no short-run effect."
- *Invariants:* the shipped table, figure, and memo excerpt.
- *Controls:* eight checks with a budget of three:
  - clean-directory run;
  - $T_H$ comparison;
  - HAC recompute;
  - horizon alignment;
  - one- versus two-step series;
  - WWII retained;
  - $F_H$ by horizon;
  - Anderson–Rubin set.

  Verdicts on R1 and R2 are committed before and after each check.
- *Reactive sentence:* "After the $T_H$ comparison and the WWII check,
  $\hat M_7=0.646$ on 497 rows. That is close to .66 but four rows too many,
  so one more argument is wrong."
- *Handoff (blueprint):* a referee checklist in Markdown, and
  `audit/proposed_check.do` for STA14 task 4.

The closing prompt asks, without formulas:
- why a reproducible package can fail to replicate;
- why $T_H$ comes first;
- why fix order is not a ranking;
- why "insignificant" is not "zero."

It links to `#sec-l14-audit-protocol` and exercises 4–8.

---

## 8. Practicum plan (REP14, STA14, HTML14 handoff)

### 8.1 REP14 — Independent reproduction audit

**Target (D11, D19).**
Ramey–Zubairy (2018), Table 1, linear column, military news: the 2-year
($H=7$) and 4-year ($H=15$) integrals. The comparison object is the full
one-step schedule for $h=0,\dots,20$ (coefficient, HAC s.e., $T_H$).
- Part (a) audits `rep14-teaching-package/`.
- Part (b), in a live offering, audits another team's capstone benchmark.

**Paper version.** JPE 126(2), 850–901 (`VERIFIED.md`, R05). Package of
February 2018; `jordagk.do` dated February 24, 2018.

**Data and vintage.** `RZDAT.xlsx`, sheet `rzdat`, April 7, 2016 update; 508
quarters. SHA-256
`b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120`.

**Script and lines.** `jordagk.do` lines 29–41 (defaults), 48–56 (import),
90–108 (normalization), 127–141 (accumulation), 442–446 (estimation), 500
(export).

**Replication kind.** An exact numerical replication by the auditor's
corrected run, plus a replication audit. There is no simulation, so D2 does
not arise.

| $H$ | $\hat M_H$ | s.e. | $T_H$ |
|---|---|---|---|
| 0 | 1.30646 | 0.3516687 | 500 |
| 7 | 0.6637145 | 0.067114 | 493 |
| 15 | 0.7133608 | 0.0435753 | 485 |
| 20 | 0.7294798 | 0.0593791 | 480 |

**Tolerance.**
- Coefficients and SEs: $10^{-6}$.
- $T_H$: exact.
- Common-sample reconstruction: $10^{-8}$.
- The D1 row passes (§6.7).

**Runtime (StataNow 19.5).**
- Pilot: 14.7 s.
- Twelve variants: 9.0 s.
- Factorial and Anderson–Rubin grids: 25.6 s.
- Student commands: under 10 minutes each (D2).

**Departures.**
- Course-written code replaces `jordagk.do`.
- The linear column only.
- The corrected build uses `ivregress 2sls, vce(hac bartlett m)` with $m=28$,
  or 27 at $h=11$–14.
- Course Stata figures, not the MATLAB graphics.

**Redistribution (D5).** No license is recorded.
- The package ships `data/raw/get_data.do`: it downloads from the authors'
  archive, checks SHA-256 on the extracted workbook, and stops with a message
  on failure.
- It also ships `PROVENANCE.md`.
- Course-written code and templates ship.

**The seeded flaws (instructor key; `global FLAW_Fk 0/1` toggles each).**

| Flaw | Seeded in | Class | Effect alone | Detection |
|---|---|---|---|---|
| F1 | `master.do` line 1: `cd "/Users/rz-author/Dropbox/capstone"` | software | `r(170)` in any other directory | fresh path; grep `^r\(` |
| F2 | `code/03_figure.do` needs `ivreg2`; README says "no add-ons" | software | `r(111)` with an empty PLUS | clean ado path; `which` |
| F3 | `code/01_build.do` divides by `rgdp_potcbo` (memo: sixth-degree trend) | data | $T_H$ exact; $\hat M_7=0.670819$; max $\lvert d\rvert=0.0123$ | rebuild $y,g$ from raw; `assert` |
| F4 | `code/00_settings.do` omits `L(1/4).newsy` (like `jordagk.do` line 186's `bplinxlist`) | specification | $T_H=504-H$; $\hat M_0=1.0128$, $\hat M_7=0.6364$ | $T_H+4$ everywhere; control list against memo |
| F5 | `code/02_table.do`: `vce(robust)` labeled HAC | inference | coefficients unchanged; SE ×1.53 ($H=0$) to ×0.89 ($H=20$) | coefficients match, SEs do not; `e(vce)` |
| F6 | `code/02_table.do` prints $H=8$ and $H=16$ as the 2- and 4-year rows | presentation | .67 (.059) vs .66 (.067); the 4-year cell survives rounding | full schedule aligns after a shift |
| F7 | `code/03_figure.do` plots $\tilde M_H$ labeled one-step | specification | gap $5.5\times10^{-4}$ ($H=7$), $3.1\times10^{-3}$ ($H=20$); as shipped at $H=20$, 0.494 vs 0.632 | overlay both benchmark series |
| F8 | `code/00_settings.do`: `omit wwii` (memo: WWII retained) | specification (sample rule) | $T_H=478-2H$; $\hat M_7=0.772$ (0.201); $F_7=4.11$; $F<10$ at $H\le11$ and 19–20 | $T_H$ gap grows with $H$; settings against memo |
| R1 | `report.md`: "replicates Table 1 within rounding" | claim | 0.55 (0.128) vs .66 (.067) | audit question 2 |
| R2 | `report.md`: impact multiplier "insignificant, so no short-run effect"; memo: extension "changes precision only" | claim | $F_0=1.09$; AR set rejects 0; $T_7=265$ | audit question 5 |

As shipped, the extension inherits F3 and F4:
- $\hat M_0=11.52$ (18.97), $F_0=0.34$;
- $\hat M_7=0.627$ (0.135), $T_7=265$;
- $\hat M_{20}=0.620$ (0.135).

The shipped `discrepancy-log.md` has two resolved rows, "fonts differ" and
"Stata version."

### 8.2 Audit protocol and templates

**Protocol.**
1. Copy the package and record a SHA-256 inventory.
2. Use a fresh path containing a space. Set PERSONAL and PLUS to empty and
   install only declared dependencies.
3. Run `master.do`, grep the log, and record each intervention with its
   `r()` code.
4. Compare with the published benchmark: $T_H$, then coefficients, then SEs,
   at tolerances written down first.
5. Compare with the author's own outputs. Reproducible is not the same as
   replicated.
6. Localize by bisection, then classify and diagnose.
7. Rank by consequence to the published claim and answer the five questions
   of `capstone/index.qmd`.

**Templates** (`practica/p14-synthesis-and-audit/templates/`):
- `design-memo.md`: the capstone's six headings, plus a
  consequential-choices ledger (choice, value, alternative, what it changes,
  evidence).
- `discrepancy-log.csv`: the six capstone fields, plus `horizon`,
  `tolerance`, `detected_by`, `audit_question`.
- `audit-report.md`: run record, interventions, the five questions.
- `audit-response.md`: one reply per row, with status change and date.

**Audit rubric** (meets / partly / not):

| Criterion | Meets |
|---|---|
| Execution | Every intervention logged with its `r()` code and minimal fix |
| Benchmark | All 21 horizons; $T_H$ first; tolerance fixed beforehand |
| Classification | Each class supported by a signature and a code line or bisection step |
| Consequence | One issue argued from the claim (memo, first stage, sample), with a yes or no on the conclusion |
| Extension | States correctly what the extension changes |
| Response (author) | Every row answered; log updated; no adjectives |

### 8.3 STA14 — Integrated research submission

The teaching package is the rehearsal; the capstone is the submission.

1. *Master do-file.* `master.do`:
   - sets `global ROOT "`c(pwd)'"` and stops unless `c(stata_version)>=19.5`,
     with the message "requires StataNow/SE 19.5 (D1)"; a comment notes that a
     capstone package audited outside the course may lower this to 18 once
     its benchmark rerun passes there;
   - logs `about`;
   - runs `data/raw/get_data.do` (hash assert) and `code/01`–`05`;
   - writes only under `output/`;
   - asserts `_rc==0` after each step.
2. *Benchmark comparison.* `code/compare_benchmark.do`:
   - merges results with the target CSV;
   - asserts 21 matched rows, $T_H$ exact, and $\lvert d\rvert\le\operatorname{tol}$;
   - writes `output/benchmark_checks.csv`.

   Teaching run: $T_7=493$, $\hat M_7=0.663715$ (0.067114).
3. *One justified extension.* Pre-specified in the memo. It reports
   $\hat M_H$, s.e., $T_H$, $F_H$ and the Anderson–Rubin set (teaching run:
   §1, §6.6).
4. *Specification and data-construction checks.*
   - Rebuild derived variables from raw with `assert`.
   - Assert the $T_H$ formula (§6.5).
   - Run Lab 4's `proposed_check.do`.
5. *Methods-and-results report.* `report.md`: the four paragraphs, tables read
   from `output/`, limitations, and each results sentence classified as in
   L13.
6. *Audit responses.* `audit-response.md` and a dated `discrepancy-log.csv`.

**Starter structure:** the capstone tree, plus `audit/` and
`tests/test_benchmark.do`.

**Expected outputs:**
- `benchmark_checks.csv` (21 passing rows after correction);
- `extension.csv`;
- `ar_sets.csv`;
- two figures;
- `master.log` with no `r(…)` lines.

### 8.4 Handoff and submission package

**HTML14 handoff.**
- Lab 2's tolerance record goes into `audit/compare.do`.
- Lab 3's cube is what exercise 5's bisection must reproduce.
- Lab 4's checklist and `proposed_check.do` feed STA14 task 4.

**Submission.**
- The replication record: target, versions, SHA-256, comparison table,
  departures.
- The audit report, log, and rubric self-assessment for the package audited.
- The student's own package, with `master.log` and tests.
- The interpretation record.
- The HTML lab record: predictions, verdicts before and after, exports.
- The defense: the author response plus the three closing sentences.

---

## 9. Slides arc

1. *Local projections, defended.* Title and the one question.
2. *A package arrives.* 0.55 against .66, and `r(170)` on line 1.
3. *Reproducible is not replicated.* A package can run perfectly and still
   miss the benchmark.
4. *Four paragraphs.* The methods template with the REP04 facts.
5. *Which choices matter.* The `jordagk.do` switches tagged by what they
   change.
6. *One cell, five arguments.* $\text{cell}(\mathsf D,\mathsf S,\mathsf W,\mathsf V,\mathsf P)$ and why $T_H$ is checked first.
7. *Signatures.* Small multiples of single flaws.
8. *Tolerance comes from the noise.* $10^{-6}$, and two explained failures.
9. *Fix order is not a ranking.* The cube at $H=7$.
10. *Insignificant is not zero.* Anderson–Rubin sets after 1947.
11. *Answering a referee.* Leave-WWII-out: 0.772 (0.201), $F=4.1$.
12. *The audit protocol.* Clean directory, target, tolerance, log, five
    questions.
13. *Referee desk and practicum.* What the lab exports and what STA14 asks.
14. *From June 1950 to a defended response.* Three sentences each student now
    writes.

---

## 10. Open questions for the editor

1. **Lecture 13 alignment.** Resolved: the L13 brief hands over the RZ
   specification grid and the three-way claim classification, and its
   no-WWII cell uses the same `omit` endpoint rule ($M_{20}=0.7152$,
   $T_{20}=440$). `#sec-l14-criticism` cites `#sec-l13-influential-episodes`
   and adds only the $H=7$ cell.
2. **Answer-key custody.** Students must not see §8.1's flaw table before the
   audit. `benchmarks/REP14-capstone-audit.csv` is empty and outside this
   brief's write scope. Should the instructor key live there, or in an
   instructor-only folder of the course repository?
3. **Acquisition object (D5).** The author link is a Google Drive file. Confirm
   that the SHA-256 check applies to the extracted `RZDAT.xlsx`, and that a
   teaching package may depend on that URL.
4. **Glossary (D22).** `discrepancy-class` and `clean-directory-run` recur in
   STA14 and the capstone. Should they become keys (which requires editing
   `terminology-plan.md`), or stay prose?
5. **Notation ledger.** Add the new symbols of §2 to §8 of
   `notation-ledger.md`? L4's glossary uses $m$ for the Anderson–Rubin
   hypothesized value, which collides with the HAC truncation lag; should L4
   adopt $M^{0}$?
6. **F8's class.** A sample rule set in code is classed here as specification.
   The capstone taxonomy does not decide between data and specification; the
   answer key needs one ruling.
7. **Live pairing (D19).** Who audits whom, and is the teaching-package audit
   graded or practice?

---
