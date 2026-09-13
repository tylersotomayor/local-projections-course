# Editor decisions

Binding for every brief, chapter, exercise, lab, practicum, and slide deck.
Cite a decision by number (e.g. "per D6"). Recorded September 13, 2026, after
the first design pass raised questions in the Lecture 6–8 briefs. A later
decision that changes one of these must edit this file in the same change.

The course owner may override any default here; the ones most likely to need
that are marked **(owner)**.

## Software, runtime, and redistribution

**D1. Stata version.** Every course run uses StataNow/SE 19.5
(`/Applications/StataNow/StataSE.app/Contents/MacOS/stata-se -e do FILE.do`).
The validated benchmarks in `~/macro/local_projections/replication-packages/`
were produced with Stata/SE 18.5. Each practicum build reruns its target in
19.5 and compares with the 18.5 benchmark CSV at that benchmark's stated
tolerance. A difference beyond tolerance is a *software* row in the build's
discrepancy log.

**D2. Runtime ceilings.** No single command in an authoring run or a student
task runs longer than 10 minutes. Monte Carlo do-files expose `global R`:
students default to `R = 200`, instructor builds to `R = 500`. A published
replication count is quoted, never claimed. Reduced runs are labeled
*statistical reproductions*.

**D3. Stored estimates.** When an author's estimation step exceeds 10
minutes (Jordà–Taylor Example 6, part 1), the lab project ships the authors'
stored `.ster` files from the CC0 package and re-estimates behind
`global REESTIMATE 1`. The instructor build runs the re-estimation once and
records agreement. Example 8's target script runs in under a minute, so
Lecture 13 re-estimates by default (`REESTIMATE 1`) and keeps the stored files
only as a cross-check.

**D4. User-written commands.** Required and on the setup page: `coefplot`,
`estout`, and, for Lecture 12, `lpdid` with the packages it and the authors'
`figure_3.do` need: `reghdfe`, `ftools`, `require`, `boottest`, `egenmore`,
`listreg`, `blindschemes`. Optional, needed only to run original author scripts
or one-time validations in instructor builds: `xtscc`, `matselrc`,
`wildbootstrap`, `ivreg2`, `ranktest`, `weakivtest`, `xtivreg28`, `ivreg28`.
Course code uses built-ins (`regress`, `newey`, `ivregress 2sls`, `gmm`,
`lpirf`) wherever they suffice.

**D5. Redistribution (owner).** A dataset ships inside a lab project only when
its `SOURCE.md` in `replication-packages/packages/` records a license that
permits redistribution (CC0, CC BY, CC BY-NC-SA with the notice reproduced,
MIT/BSD/GPL for code). Otherwise the project ships `data/raw/get_data.do`,
which downloads from the authors' public URL, verifies SHA-256, and stops with
a clear message if the URL fails; `PROVENANCE.md` documents the manual
fallback. The builder verifies each classification against `SOURCE.md`; the
expected result is: Jordà–Taylor `JEL-Code` (CC0) ship; Inoue–Jordà–Kuersteiner
(CC0) ship; `lp_var_simul` (MIT) ship code and exported draws; JST macrohistory
R6 (CC BY-NC-SA 4.0) ship with notice; Ramey–Zubairy, the *When Credit Bites
Back* historical archive, the Dube–Girardi–Jordà–Taylor JAE archive, and any
package without an explicit license use an acquisition script.

**D6. Authors.** Do not contact authors about discrepancies. Whether to do so
is the owner's decision **(owner)**.

## The shelter anchor and the IJK targets

**D7. Canonical shelter specification (Lectures 3, 5, 6).** Use the August 13,
2024 official author archive of Inoue–Jordà–Kuersteiner (commit `340947c`),
`Figure4.do` exactly as shipped there: dependent variable the unsmoothed long
difference of 100 × log shelter PCE price (so the response is the cumulative
percent change in shelter prices), Bauer–Swanson (2023) monetary shock, 12
control lags, Newey–West with 48 lags, $h=0,\dots,48$, sample 1988m1–2019m12
with 384 nonmissing shocks. Its pointwise regressions omit lagged housing
starts; its Frisch–Waugh–Lovell significance and joint steps include them.
The benchmark is
`replication-packages/benchmarks/REP03-shelter-prices-author-20240813.csv`.
The November 2024 archive's `Figure4.do` selects housing completions with a
centered moving average; it appears once, as a diagnostic row in the Lecture 3
discrepancy log, and is never used as the anchor. In prose the object is "the
cumulative response of log shelter prices" in percent. Any brief number
computed from a different "paper-text" specification must be recomputed.

**D8. REP03** is an exact replication of D7's point estimates and sample sizes
by horizon. Bands are deferred to Lectures 5–6.

**D9. REP05** is an exact replication of IJK `Figure2.do`'s single realization
(benchmark `REP05-pointwise-inference.csv`). Repeated-sample coverage is a
course-built Monte Carlo in STA05, labeled as such. The sequential `replace`
commands make the simulated system triangular rather than the simultaneous
VAR its comments describe; the Lecture 5 notes disclose this in a footnote
where the design is described, the discrepancy log records it, and every
"true response" the lab or exercises use is computed from the design as
actually coded.

**D10. REP06** is an exact replication of IJK `Figure3.do` (simulated design:
14 horizons estimated, 12 in the simulated covariance, 11 plotted), plus a
course-built sup-$t$ band on the D7 shelter anchor, labeled as an extension.

## Other replication targets

**D11. REP04** is Ramey–Zubairy Table 1, linear column, military news, full
sample: the one-step cumulative IV multipliers with HAC standard errors and
sample sizes for $h=0,\dots,20$ from `jordagk.do` (`junkmultse.csv`). The
two-step ratio of response sums is a teaching comparison. The notes explain
sample alignment with the audited numbers: at $H=20$ the common-sample
cumulative IV multiplier is 0.729480 and the varying-sample ratio of response
sums is 0.726344. The validated portable pilot in
`replication-packages/pilots/REP04/` is the model for the lab project.

**D12. REP09** runs the same program with `state slack`: the published
state-dependent multipliers and the HAC $p$-value for their difference.

**D13. REP07** follows the Lecture 7 brief's Option A: four `spec_id = 1`
Li–Plagborg-Møller–Wolf designs (fiscal G2 and G3, and a monetary pair chosen
by the same rule), 500 MATLAB draws exported and shipped, a Stata port of
least-squares LP, bias-corrected LP, and the recursive VAR validated draw by
draw at $10^{-6}$. The Pope bias correction of the VAR is reported from the
MATLAB benchmark and not ported.

**D14. REP08** is an exact replication of Jordà–Taylor Figure 6a–b (Example 6,
parts 1 and 2) with the authors' HAC choice reported as theirs. Any horizon
offset between estimation and plotting is logged as a presentation
discrepancy, corrected in the course figure, and may be stated neutrally in
the notes with the do-file lines cited. The Example 6 sample follows the code
(through 2000m1) and the difference from the figure note is logged.

**D15. REP10** is Kolesár–Plagborg-Møller Figure 1, government-spending
weights for the Ramey military-news series, against `REP10-causal-weights.csv`.

**D16. REP11** is an exact replication of the *When Credit Bites Back* Figure 4
GDP panel from the historical archive (`panel14_1_oj.dta`), never from JST R6.
The notes call it a conditional comparison of recession paths, not the
response to an exogenous shock. R6 may appear in an extension, labeled.

**D17. REP12** is an exact replication of Dube–Girardi–Jordà–Taylor Figure 3
(banking deregulation and the labor share) through the authors' manual loops,
with `lpdid` on the same data as a cross-check where the specifications
coincide (see `benchmarks/raw/REP12-command-comparison.json`). Simulated
LP-DiD examples are separate and labeled.

**D18. REP13** is Jordà–Taylor Example 8 against `REP13-counterfactual.csv`,
with horizon indexing as in the author code and any plotting offset logged.

**D19. REP14** audits the course's own teaching package: a fiscal-multiplier
replication package derived from REP04, with seeded and documented flaws, whose
published benchmark is Ramey–Zubairy Table 1. In a live offering it also
audits another team's capstone.

## Notation and terminology

**D20. Approved symbols.** $R$ is the Monte Carlo replication count across the
course. Lecture 7 adds $\mathbf S$ (VAR residual covariance), $\mathbf
A_{\mathrm c}$ (companion matrix), $\tau$ and $\kappa$ (moving-average
coefficients of its toy model), and $\omega^{*}_h$ (bias weight). Lecture 8
adds $r$ (penalty order) and writes the Gaussian response as
$a\exp\{-(h-h^\star)^2/c^2\}$ with $h^\star$ the peak horizon; Jordà–Taylor's
$b$ appears only when quoting their code or output, with one sentence mapping
$b$ to $h^\star$. $b_k(h)$ stays reserved for linear basis functions. The
notation ledger records these.

**D21. The Gaussian response** is described as a three-parameter parametric
family, not a linear basis expansion.

**D22. New glossary keys.** Approved: Lecture 6 `horizon-set`,
`linear-combination-test`; Lecture 7 `companion-form`, `bias-weight`,
`encompassing-model`. Any further key is added to `terminology-plan.md` in the
same change that marks it.

**D23. Penalty order and scale.** The course default is $r=2$ (shrink toward a
line). If Barnichon–Brownlees's published estimator uses another order,
record the course choice as a deliberate departure. Report $\lambda/T$, with
one footnote mapping to their $\lambda$.

## Scope

**D24. Figures.** Each figure answers one stated question. When a brief lists
more candidates than the spine, keep those whose question a table or a
sentence cannot answer, and drop the ones the brief marked droppable (Lecture
6: `fig-l06-covariance-structure`, `fig-l06-significance-vs-confidence`).

**D25. One-sided claims.** Two-sided bands in the body; the one-sided sup-$t$
band in a footnote and one exercise.

**D26. Long exercises.** A Monte Carlo exercise that takes more than a few
minutes is tagged [extra] and defaults to $R=200$.

**D27. Lecture 8 overidentification test.** Included: the every-sixth-horizon
version is the headline; the all-horizon sequence illustrates the
near-singular covariance.

**D28. Penalized spline on the Jordà–Taylor data.** In STA08 and in one
paragraph of the Lecture 8 evidence section, labeled an instructional
extension.

**D29. Lecture 7 opening.** Uses the Jordà–Taylor monetary-unemployment data,
so one dataset runs through Part II.

**D30. Approximate bands in labs.** Allowed only when the panel label says
"approximation" and the collapsed note explains it; otherwise use stored Stata
results labeled "stored result".

**D31. Reading excerpts.** Reading guides name sections from the versions
frozen in `replication-packages/VERIFIED.md`. Where a published page range
could not be checked, the guide says "section numbers from the frozen version;
page range to confirm".

## Second round, after the complete briefs

Recorded September 13, 2026, from the open questions in section 10 of all
fourteen briefs.

**D32. Hand table and seeds.** Lecture 1's hand table uses a binary shock, so
each slope is a difference in means; Lecture 2 reuses that table exactly.
Seeds are fixed before results are seen and never changed to obtain a tidier
draw; an unusual draw is kept and explained.

**D33. Derived estimates in browser labs (owner).** A lab may display
coefficients, moments, weights, and figures estimated from any course dataset,
with attribution. A lab never embeds raw data rows from a package that D5
routes through an acquisition script.

**D34. CC0 archives with third-party components.** The IJK archive ships as the
authors distribute it; `PROVENANCE.md` reproduces the third-party notice from
its `SOURCE.md` (FRED series, Bauer–Swanson shocks).

**D35. Ramey–Zubairy acquisition.** One source file, `shared/stata/get_rz.do`,
is copied into every lab project that needs the data (Lectures 1, 2, 4, 9, 13,
14) when its archive is built. It attempts the download from the authors'
public link, verifies the SHA-256 of the extracted `RZDAT.xlsx`, and otherwise
prints manual download instructions; the manual route is expected to be the
common one. The course computes SHA-256 by shelling out (`shasum -a 256` on
macOS and Linux, `certutil -hashfile … SHA256` on Windows).

**D36. Notation.** The course ledger lists symbols used in more than one
lecture; a symbol used in one lecture only lives in that lecture's notation
table and brief. Added to the ledger: $v_t$ and $\sigma_v$ (outcome
disturbance and its standard deviation), $\theta_0$ (impact response),
$y^{c}_t$ (counterfactual path), $\sigma_s$ from Lecture 1; the transformation
superscripts $\beta^{\mathrm{LD}}_h,\beta^{\Delta}_h,\beta^{\Sigma}_h,
\beta^{\mathrm{lag}}_h$ for one outcome; $\Xi_s$ (shock rescaling constant);
$\varpi$ (state-feedback parameter); $M^{0}$ (hypothesized multiplier in an
Anderson–Rubin inversion), so $m$ remains the HAC bandwidth. The residual
$u_{t,h}$ is "at most MA($h$)". The renames in the Lecture 6 and 7 briefs are
approved as lecture-local.

**D37. Glossary keys.** Not keys: "accumulated change" and "accumulated level"
(footnote terms under `cumulative-response`), "synthetic time series"
(footnote). New keys: `statistical-result` (Lecture 13),
`discrepancy-class` and `clean-directory-run` (Lecture 14). Lecture 12's
averages are over treated cohorts, so its keys become `equally-weighted-att`
and `variance-weighted-att`, and the ledger writes $\theta^{\mathrm{EW}}_h$ and
$\theta^{\mathrm{VW}}_h$.

**D38. Spine corrections.** The spine adopts the briefs' corrections: computed
Ramey–Zubairy numbers in the Lecture 2 opening; the unsourced "third of core
inflation" dropped from Lecture 3 unless a verified source for the PCE shelter
share is cited; the measured band ratio and the Newey–West-versus-HC reading in
Lecture 5; the intersection–union correction in Lecture 6; Kolesár and
Plagborg-Møller's own meaning of "bad" and "ugly" in Lecture 10; the archive's
counts in Lecture 11; Example 8's shifted peak in Lecture 13.

**D39. Author discrepancies, generally.** D14's rule applies course-wide: a
discrepancy between an author's code, figure, note, or text may be stated
neutrally in the notes with the lines cited, is logged, and course figures
follow the code as run. This covers the IJK Figure 4 note, the observation that
in IJK Figure 2 and JT Example 4 the "lag-augmented" band differs mainly by its
HC standard errors, the JT Example 9 storage offset and $x_{t-1}$/$x_t$
mismatch, the KPM plotting convention, and the DGJT specification A
pre-horizons. Course constructions built on an author's equation (the Lecture 9
two-group Kitagawa–Oaxaca–Blinder split, Lecture 13's episode windows) are
labeled instructional extensions.

**D40. Shock units.** A shock's units are stated only after checking the
source documentation; otherwise the notes say "per unit as shipped" and also
report the response per one standard deviation.

**D41. Weak instruments.** Course tables report the Kleibergen–Paap robust $F$
from built-ins and footnote the Montiel Olea–Pflueger effective $F$ that
Ramey–Zubairy report; `weakivtest` (optional, D4) reproduces those in the
instructor build.

**D42. HAC ports.** Replications use each author's bandwidth choice exactly.
Non-replication course code uses the lecture's stated rule. REP04 and REP09
share one built-in port of `jordagk.do`, `ivregress 2sls, vce(hac nwest opt)`,
provided it reproduces both benchmarks within tolerance; `ivreg2` is an
optional cross-check. On samples with gaps (no-WWII, leave-one-episode-out) the
built-in is used and the `ivreg2` values are logged.

**D43. Previews.** A handoff may preview a later lecture's concept in one
labeled sentence.

**D44. Lag-augmented default.** Course code uses HC1 (`vce(robust)`), the
Eicker–Huber–White estimator of Montiel Olea and Plagborg-Møller; replications
use the authors' HC3.

**D45. Lecture 6.** The sup-$t$ extension uses the course covariance for the
plotted path, with the authors' joint step as a labeled comparison. Exercise
10 keeps its lesson: finite-sample HAC undercoverage, bridging back to Lecture
5. Brief length is not a constraint; the word targets apply to chapters.

**D46. Lecture 7.** The opening's specification differs from Lectures 6 and 8,
and the brief's paragraph relating them stands. The handoff to Lecture 8's
first section is confirmed.

**D47. Lecture 8.** Unless the build verifies from Barnichon and Brownlees's
text how they treat controls, the notes describe the estimator as smooth local
projections "as implemented by Li, Plagborg-Møller, and Wolf." The $T=181$
design stays, with restricted-estimator bias read against both $\theta_h$ and
the OLS mean path. Stata/Mata timings decide [extra] tags. Prototype numbers
reach the notes only after the Stata build regenerates them.

**D48. Lecture 9.** Section references to Gonçalves–Herrera–Kilian–Pesavento
follow D31. The instructor build runs `jordagk_ar.do` once if it finishes
within the D2 ceiling; otherwise the notes quote the published Anderson–Rubin
$p$-values, labeled. Ramey–Zubairy's "two-year integral" is written "through
quarter 7 (eight quarters)" in Lectures 4, 9, and 13. The brief's simulation
design is approved.

**D49. Lecture 11.** The course Driscoll–Kraay routine is validated once
against `xtscc` in the instructor build (optional install, D4); if that fails,
it is labeled "course implementation". The financial-recession timing rule is
quoted from the frozen article under D31. Inference taught is time-clustered
and lag-augmented; Almuzara–Sancibrián's lag rule and small-sample refinement
are further reading, not ported. Exercise 6's stored comparison comes from a
`regress` run so the small-sample factors match.

**D50. Lecture 12.** The authors' standalone example (about six minutes) is
instructor-only.

**D51. Lecture 13.** Episode windows and the window rule are approved as
labeled course choices. Conditional-path bands appear only in a footnote that
warns against reading their width as precision.

**D52. Lecture 14.** The REP14 flaw key and any other answer key that must stay
hidden until an audit lives outside the public repository, under
`~/macro/local_projections/course-private/instructor-only/` (D54). A sample rule set in code is a
*specification* discrepancy. In a live offering the instructor assigns audit
pairs; the teaching-package audit is formative and the capstone audit is graded
**(owner)**.

**D53. Exercise runtimes.** Runtimes quoted as estimates in briefs are timed in
the build, and [extra] tags follow D26.

**D54. Publication boundary (owner).** Public, in this repository and on the
site: lecture notes with their exercise hints and worked solutions, slides,
browser labs, practicum pages, starter do-files, data or acquisition scripts,
automated checks, replication code and outputs, and the instructor build's
replication results and checks. Private, in the local repository
`~/macro/local_projections/course-private/` and never committed here: planning
briefs (`course-private/lectures/NN-slug/BRIEF.md`), verification and editing
logs, solutions to the graded Stata problem sets, the REP14 flaw key, and
grading keys. Student lab archives exclude `solution/`; `master.do solution`
explains that solutions are not distributed when the folder is absent.
