# Practicum 01 verification log: the archive, reproduced as a student

Published on 2026-09-14 under editor decision D54. The audit ran on 2026-09-13,
when the solution was kept outside the public repository, so sections 4 and 7
still describe that state; where a claim about the archive has since changed,
the sentence says so and gives the published value. The solution now ships in
`lab-project/solution/` and in the archive, its log and figures are published in
`build/output/`, and the authors' folder paths in `vendor/jel-code/` have since
been commented out. References below to files outside the repository have been
replaced by their public counterparts. Section 1 records a re-run of the
published archive on 2026-09-14.

Auditor pass on `practica/p01-question-to-projection/` (lab project, archive,
`index.qmd`, `build/index.qmd`), 2026-09-13, StataNow/SE 19.5 in batch (D1).
All runs were made in a scratch folder outside the repository, called `audit/`
below. Batch-mode logs (the `master.log` that `-e` writes in the working folder) were
renamed there (`batch-*.log`) and are never copied, quoted, or published. Every
log grepped below is a `log using` log written by the do-files.

## 1. The runs

| Run | Folder | Command | Result | Time |
|---|---|---|---|---|
| Student, starter | `audit/student/lab-project` (archive unzipped, nothing added) | `stata-se -e do master.do` | 45 checks and 65 REP01 assertions pass at $R=200$; the starter stops at `FAIL  Task 1: T_h = 11 - h at h = 0, 1, 2 (T = 12, p = 1)` with `r(9)`, after listing the all-missing `results_hand.dta` it posted. The four Ramey–Zubairy checks are skipped with a message, because the workbook is fetched only in Task 5 | 28 s wall; REP01 26.50 s (Monte Carlo 5.85 s, authors' script 18.55 s) |
| Student, solution argument | same folder | `stata-se -e do master.do solution` | On the 2026-09-13 archive, which held no `solution/`, this stopped before any work with the missing-file message and `r(601)`. On the published archive it runs the solution; the row below is that run | < 2 s then; 162 s now |
| Instructor | `audit/instructor/lab-project` (archive unzipped, the solution copied in from outside the repository) | `stata-se -e do master.do solution` ($R=500$ by default in solution mode) | `Assertions passed: 196;  failed: 0`, `MASTER COMPLETE`. 45 checks + 65 REP01 + 48 STA01 + 38 handoff. `get_rz.do` downloaded the Ramey–Zubairy package from the authors' link into the empty folder and verified both SHA-256 values | 140 s wall; 139.0 s by Stata's timer; REP01 62.86 s (Monte Carlo 14.76 s, authors' script 45.97 s); STA01 75.2 s (Monte Carlo 70.01 s) |
| Student, published archive | fresh unzip, empty folder, 2026-09-14 | `stata-se -e do master.do solution` | `Assertions passed: 196;  failed: 0`, `MASTER COMPLETE`, the same 45 + 65 + 48 + 38. `get_rz.do` downloaded and verified both files. No `^r\([0-9]+\);` and no `Serial number` in any `log using` log | 162 s wall; REP01 75.57 s (Monte Carlo 18.08 s, authors' script 55.02 s) |

Judgment on the starter path. The stop is the designed one: `pset.do`'s
header, the README, and the practicum page all say that the first failed check
stops the file, and the failing line names the task and the property tested.
The only `r(` lines in the starter's logs are the `r(9)` that follows that
`FAIL`, and in the 2026-09-13 solution-argument run the `r(601)` that followed
the missing-file message. No other error line occurs.

Log greps. `^r\([0-9]+\);` finds nothing in the instructor run's
`output/master.log`, `output/pset/pset.log`, or the batch log. `Serial number`
finds nothing in any `log using` log of the three runs, in
`build/output/*.log`, or in the solution's own `pset.log`, now published in
`build/output/`.

The 200 assertions reported on the build page come from the build run in
`lab-project/`, where `RZDAT.xlsx` was already present when `tests/checks.do`
ran, so the four workbook checks counted (49 checks). In an empty folder they
are skipped, which gives 196; the build page states both counts correctly
(200 for the build, 45 checks in the empty-folder run).

## 2. Numbers: logs against the pages

The audit's instructor run reproduces the committed build outputs exactly:
`rep01-benchmark.csv`, `handoff-check.csv`, `fig-rep01-levels-mean.svg`, and
`fig-rep01-first-draw.svg` are byte-identical to `build/output/`, and
`sta01-news-shares.csv`, both STA01 figures, both caption files, and
`not-yet-argued.txt` are byte-identical to the build's own copies, now
published in `build/output/`.
`assertions.csv` differs only by the four workbook checks skipped in an empty
folder. `rep01.log` differs only in temp-file names and timings. No number
changed, so `build/output/` was not recopied.

Checked on `index.qmd` against the logs, at the rounding printed:

- Target table: benchmark 1.00175750 … 0.43152007 (`REP01-levels-lp.csv`); authors' 200-draw run 0.99686521 … 0.42771590; shipped 10,000-draw means 0.99697095 … 0.42890212; largest difference $4\times10^{-8}$ (h = 0, −0.00000004). Runtime 15.1 / 46.4 / 63.7 s (build `rep01.log`: 15.10, 46.39, 63.71); student default 26.6 / 18.6 s (builder's empty-folder run; this audit 26.50 / 18.55).
- Step 2: 1.060351 on 99 rows; target 1.06035137; double 1.06035143; gap 5.95e-08 ("6e-8").
- Step 3: the eleven six-decimal draw-1 values equal the authors' stored values in `DRAW1`; $0.95^{10}=0.599$; negative from h = 7, 0.243 at h = 10.
- Step 4 table: all 36 cells equal the build log (θ, benchmark, reproduced, difference, MCSE 0.0047 … 0.0178). h = 6 prints `-0.00000000` in the log and `0.00000000` on the page, the same value. Gap to truth 0.025 at h = 1 (0.95 − 0.92489526) and 0.167 at h = 10 (0.16721686), 9.42 MCSE.
- Step 5: authors' script against `rep01.do` within 4e-8 at R = 500 (all eleven `lp_close` pass at 1e-6); largest 10,000-draw gap 0.0179 at h = 2, z = 1.71, the largest |z|.
- Part B checks: 0.617322, −0.983356, 2.050024; 0.575667, −1.050405, 2.153022; 0.878940, −0.293297; 0.370337, 0.211226; 0.600073; 0.361906, 0.404210; 0.261211, 0.195838; 0.433969 on 495 rows; 0.29376385 on 490 rows. Each passed in the instructor run.
- Part C and mastery: 0.361906 → 0.433969; 0.261211 + 0.195838 = 0.457049 ("46 percent"); 0.433969 − 0.361906 = 0.072 ("0.07").

Checked on `build/index.qmd`: start/finish 22:46:54 / 22:49:11 and 137.1 s (`build/output/master.log`); STA01 72.3 s and Monte Carlo 70.8 s (`build/output/pset.log`: 72.3, 70.79); 200 = 49 + 65 + 48 + 38 (`assertions.csv`); 194 and 46 at R = 200 (builder's run, consistent with this audit's 45 + 65 + 38 and the two R = 500 checks that do not apply); every line of the four `text` excerpts occurs in the committed logs; the handoff table's 17 rows equal `handoff-check.csv`; the benchmark table's 121 numeric cells equal the log listing (two negative zeros shown as 0.00000000).

Against the published values the BRIEF cites (§8.1): the CSV column, the 19.5 R = 500 column (the authors' script: equals the CSV at every printed digit; the build's cross-check passes at 1e-6), and the R = 200 column all match the page. The BRIEF's "within 0.018 of the 10,000-draw file, largest at h = 2, 1.7 MCSE" is what the page claims and what the log shows (0.0179, z = 1.71 with the nested standard error $\mathrm{sd}_R\sqrt{1/R+1/10{,}000}$). The tolerance claim $\lvert z\rvert<3$ holds at every horizon at R = 500 (largest 1.71) and at R = 200 (largest 0.93). The BRIEF's runtimes (48.43 s, 28 s) came from planning runs; the page quotes the build's own timings, which is correct. The REP04 value 0.29376385 on 490 rows equals `irf_gdp_linear` at h = 10 in `replication-packages/benchmarks/REP04-linear-fiscal-multiplier.csv`. The 21 planning logs of the design stage, in a scratch folder outside the repository, contain no line matching `^r\([0-9]+\);`.

Step 3's Checkpoint is answerable: from `lab-project/output/rep01-draws.dta`, draw 1 lies below the 5th percentile of the 500 draws at h = 7, 8, 9 (−0.148 < 0.034, −0.282 < −0.073, −0.251 < −0.145) and inside the band elsewhere, three adjacent horizons.

## 3. Provenance and the archive

`shasum -a 256` on every file listed in `data/PROVENANCE.md` returns the
recorded value: the three simulated CSVs, both benchmarks, the handoff JSON,
`handoff/hand_table.csv`, `handoff/onedraw_rho09_seed2.csv`, and (via
`vendor/jel-code/SOURCE.md`) the four vendor files. The vendor files and
`REP01-levels-lp.csv` also equal the originals in
`replication-packages/packages/jel-code/original/…` and `benchmarks/`. The
Ramey–Zubairy values equal both the infrastructure's
`packages/ramey-zubairy/supplied-local-copy/` and the files `get_rz.do`
downloaded in this audit. Retrieval time (16:23 UTC), commit, CC0, the `.dta`
timestamp (29 Oct 2023 13:56), and the absence of a Ramey–Zubairy license
agree with the `SOURCE.md` files. One inaccuracy: the header said
`tests/checks.do` asserts every value, but the section 5 handoff files are not
asserted (students replace them). Fixed in `PROVENANCE.md`, and in the matching
sentence of `index.qmd`.

The 2026-09-13 archive held 38 entries; the published one holds 40, the two
added being `solution/` and `solution/pset_solution.do` (D54). Neither holds
`output/`, a `.log` or `.smcl`, `RZDAT.xlsx` or `rzdatnew.csv`, or a
`.DS_Store`. `grep -rn /Users/`
finds only the authors' own `cap cd` lines in `vendor/jel-code/SSBias_IntcpYLagdiffN_95.do`
(lines 5, 7) and `all-simulate.do` (lines 7, 9). They stay: the files ship
byte for byte under CC0, `tests/checks.do` asserts their SHA-256, and
`SOURCE.md` explains that the lines fail silently. No course file in the
archive contains an absolute path. (On 2026-09-14 the finalization commented
those four lines out as well, so the archive now holds no absolute path at all;
`SOURCE.md` and `tests/checks.do` carry the new hashes.)

Re-zipped after the `PROVENANCE.md` edit, from
`practica/p01-question-to-projection/`. Under D54 the `solution/` exclusion is
dropped, and the command below reproduces the published archive's 40-entry list
exactly:

```bash
rm -f p01-question-to-projection-lab.zip
zip -r -q p01-question-to-projection-lab.zip lab-project \
  -x 'lab-project/output/*' \
     'lab-project/data/raw/RZDAT.xlsx' 'lab-project/data/raw/rzdatnew.csv' \
     '*.log' '*.smcl' '*.DS_Store'
```

The new archive was unzipped into `audit/student2/`, compared with the tree
(`diff -r`, identical apart from `output/`), and run again with
`do master.do`: 45 checks, 65 REP01 assertions, the same stop at Task 1, no
`Serial number`.

## 4. Solution material on public pages

Searched `index.qmd`, `build/index.qmd`, the lab project, and the Explorer page
for the solution's distinctive code and every written answer (the two
captions and the five "not yet argued" sentences). None occurs. The build page
lists only the check labels the starter already contains and says the
solution's code, log, captions, and paragraph stay with the instructor
materials. `handoff/check_handoff.do` builds `y`, `newsy`, and `g` and runs
the h = 8 regressions; the same lines already appear in the public worked
solution of Exercise 9 (`lectures/01-question-to-projection/exercises.qmd`),
so they give away no graded answer. Under D54 the build page now publishes the
solution's code, its log excerpts, both captions, and the paragraph, in its
section 2.

A byte-identical copy of `pset_solution.do` sat, gitignored, in the public
working tree at `lab-project/solution/`. Under that stage's publication
boundary the solution was kept outside the public repository, so the copy was
deleted. Under D54 it has since returned to `lab-project/solution/`, ships in
the archive, and is the file `do master.do solution` runs.

## 5. The page read as a student

- **How to use.** The two-line block runs. Everything the section promises about `output/`, the globals, and the stop at the first failed check is what the runs did.
- **Part A code blocks, run in sequence.** Every `stata` block of Steps 2–5 was extracted from `index.qmd` and run in one fresh session after `do helpers/lp_helpers.do`, in a copy of the student folder that had already run `master.do`. Before the fix, Step 4 stopped with `r(198)`: `$R` is empty outside `master.do`, so `forvalues r = 1/$R` is invalid. Step 5 could not have run either: after `keep t rl rt`, neither `sd_R` nor `author_10000` is in memory. After the fix, all four blocks run: 5 `lp_assert` or `lp_close` checks pass. Step 5's new listing equals the R = 200 log (means, the authors' 200-draw means, and z from −0.66 to 0.93). Step 1's block is a quotation of the authors' lines, introduced as such ("Read them before running anything").
- **Checkpoints.**
  - Step 1: no random numbers are drawn after the data step, so the later regressions cannot change the draws.
  - Step 2: row 1 has no `L.y`.
  - Step 3: h = 7–9, adjacent because the residuals share terms (§sec-l01-residual).
  - Step 4: the R = 200 file and the seed diagnosis are both true of `rep01.do`.
  - Step 5: an independent stream adds variances.
  - Step 6: a writing task.
  
  Each can be answered from the page, the lecture, and the student's own run.
- **Tasks.** Each task's deliverables and checks on the page match `starter/pset.do` label for label. Task 4's "the given code summarizes the first 200 samples" and Task 5's reliance on `get_rz.do` match the file. The linked anchors `#eq-l01-lp-toy`, `#sec-l01-residual`, and `#sec-l01-exercises` exist in `_body.qmd`. `jordataylor2025` and `rameyzubairy2018` are in `references.bib`.
- **One practicum, and a handoff that is consumed.** Part A's regression is the lecture's LP, and Part B repeats it on the lecture's anchors. Part C's files are read by tasks, not only by the check:
  - Tasks 1–2 read `handoff/hand_table.csv`; the log prints "Tasks 1 and 2 read handoff/hand_table.csv".
  - Task 3 reads `handoff/onedraw_rho09_seed2.csv` after a value comparison.
  - Task 5 prints the Lab 4 hypothesis beside its own estimates.
  - `check_handoff.do` reruns all 16 browser numbers and refutes the sample hypothesis (0.30, lower) against 0.433969.

## 6. Fixes made

| # | File | Defect | Fix |
|---|---|---|---|
| 1 | `index.qmd`, Step 4 | Block fails with `r(198)` when run as the page instructs, because `$R` is set only by `master.do` | Block now begins `capture mkdir output` and `if "$R" == "" global R 200`, as `rep01.do` does |
| 2 | `index.qmd`, Step 5 | Block is two fragments of `rep01.do`; `sd_R`, `mean_R`, and `author_10000` are not in memory where it uses them | Rewritten as a runnable block: saves the Step 4 summary, runs the authors' script, merges, asserts agreement at 1e-6, merges the 10,000-draw means, computes and lists z, asserts \|z\| < 3. Setup sentence now says to run Steps 2–5 in order in one session, and "come from that file" became "follow that file". Verified by rerunning the blocks |
| 3 | `lab-project/data/PROVENANCE.md`; `index.qmd`, "How to use", item 1 | Claimed `tests/checks.do` asserts every recorded SHA-256; it does not assert the replaceable handoff sample files | Both sentences now name the files that are asserted |
| 4 | `build/index.qmd`, alt text of `fig-p01-first-draw` | Band at h = 0 given as "about 0.85 to 1.15"; the stored 5th–95th percentiles are 0.838 and 1.176 (h = 10: −0.176, 1.112) | "about 0.84 to 1.18 … about minus 0.18 to 1.11" |
| 5 | `lab-project/solution/` (public working tree) | Gitignored duplicate of the solution, which was then kept outside the repository | Deleted at the time; restored and published under D54 on 2026-09-14 |

Archive rebuilt after fix 3 (fixes 1, 2, and 4 are page-only). No rendered
output was produced: `quarto render` was not run, because it writes into
`_site/`; the edits are plain Markdown and fenced code.

## 7. Open for the editor

1. **Publication policy conflict.** This stage's instructions put graded problem-set solutions outside the public repository, and the practicum followed that: `.gitignore` excluded `solution/`, `master.do solution` stopped in the archive, and both pages said so. But `docs/editor-decisions.md` D54 now reads "Everything is public … lab projects with starter and solution do-files, instructor builds with the solved problem sets". Commit `f6426cb` ("Publish all course materials, including briefs and solutions") publishes on that basis, and `lectures/01-question-to-projection/BRIEF.md` is a public byte-identical copy of the planning brief that was kept outside the repository. If repository D54 governs, these would change: `lab-project/.gitignore`, the missing-solution branch of `master.do`, the README, the last paragraph of "How to use", the build page's Section 2, its "Logs" row, and the empty-folder paragraph. The solution would return to `lab-project/solution/`, and the archive would be
rebuilt. **Resolved on 2026-09-14:** repository D54 governs, and all of that was
done.
2. `instructor-solutions.md` said the solution was "identical to the copy in the lab project's gitignored `solution/` folder", and that copy no longer existed. Corrected on 2026-09-14, when the file was published beside this one and the solution returned to `lab-project/solution/`.
3. The committed `log using` logs in `build/output/` carry Stata's header line with the build machine's absolute path (`/Users/tylersotomayor/local-projections-course/…`). There is no license banner or serial number. Stripping the path would mean editing genuine logs, so they were left as run.
4. The starter's stop is clear but terse (a `FAIL` label after a listing of missing values, then `r(9)`). A one-line "Task 1 is not written yet" message before each task's first check would help, but it would also break the solution header's claim that starter and solution differ only in TASK lines, so it was not added.
