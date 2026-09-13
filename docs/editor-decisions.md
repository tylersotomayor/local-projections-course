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
minutes (Jordà–Taylor Example 6 and Example 8, part 1), the lab project ships
the authors' stored `.ster` files from the CC0 package and re-estimates behind
`global REESTIMATE 1`. The instructor build runs the re-estimation once and
records agreement.

**D4. User-written commands.** Required and on the setup page: `lpdid`,
`coefplot`, `estout`. Optional, needed only to run original author scripts:
`xtscc`, `matselrc`, `wildbootstrap`, `ivreg2`, `ranktest`, `reghdfe`. Course
code uses built-ins (`regress`, `newey`, `ivregress 2sls`, `gmm`, `lpirf`)
wherever they suffice.

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
