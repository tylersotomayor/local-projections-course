# Lecture 01 — apparatus and consistency audit

This audit covers `lectures/01-question-to-projection/` in the public course
repository: `_body.qmd`, `glossary.qmd`, `references.bib`, `notes.qmd`, and
`figures/`. It ran on 2026-09-13, after the mathematical verification
(`VERIFY-math.md`). The standards applied were BRIEF.md, the course spine
(Lecture 1 and the Lecture 2 seam), the notation ledger, the terminology plan,
the authoring guide, AGENTS.md, and the editor decisions. Scratch work is in
`build-01/`, a session-local scratch folder that is not published.
No git command changed anything; no Stata or MATLAB was run.

## 0. Outcome

| Check | Result |
|---|---|
| 1. Notation against the ledger | 3 deviations fixed in `_body.qmd`; 3 considered and kept, with reasons |
| 1b. Figure labels against body wording | 3 labels in 3 figures changed from "shock" to "intervention"; SVG and PDF rebuilt together |
| 2. Terminology | 20 marked keys, exactly Lecture 1's allocation; 20 definitions; one for one; alphabetized; nothing owned elsewhere is marked |
| 3. Cross-references | All 15 equation, 5 figure, 6 table, 12 section and 4 assumption targets resolve; the 10 exercise links wait for `exercises.qmd` (open issue 1) |
| 3b. Figure assets | 5 figure blocks; every `fig-l01-*` stem exists as `.svg` and `.pdf`; every SVG line has `fig-alt`; every caption opens with a small-caps title and interprets |
| 4. Citations | 11 keys cited, 11 entries, none unused; 7 match the master bib byte for byte; 4 checked on the web |
| 5. Structure | Every required skeleton section present; `##` headings follow the BRIEF chain and anchors in order; nothing above `##` |
| 6. `audit_session.py` | Real directory: stops at the missing `solutions.qmd` and `slides.qmd` (later stages). Scratch copy with stubs: everything passes except the exercise anchors |
| 7. Render | HTML and PDF both exit 0. No unresolved cross-reference warnings. The only HTML warnings are links to the slides, Explorer, and practicum pages that later stages create. All 39 PDF pages inspected; one table layout fixed |

## 1. Notation

Every symbol in `_body.qmd`, `glossary.qmd`, the captions, and the figure
sources (`figures/*.tex`, `lpfig.lua`) was compared with
`docs/notation-ledger.md` and D20 and D36.

### Fixed

| # | Where | Before | After | Why |
|---|---|---|---|---|
| N1 | §many-shock-dates, "How a Slope Uses Its Rows" | $y_{t+h}=a_h+\beta_hs_t+e_{t,h}$, "where $e_{t,h}$ is everything in $y_{t+h}$ that the intervention does not explain" | $y_{t+h}=\tilde\mu_h+\beta_hs_t+\tilde u_{t,h}$, "where $\tilde u_{t,h}$ is …" | The ledger gives $e$ to the shock value in $\theta_h(e)$ (Lecture 10) and $e_i$ to exposure (Lecture 11); $a$ is the Gaussian amplitude (Lecture 8, D20). The intercept keeps the ledger's letter $\mu$; the tilde marks this as the short regression's intercept, not the one in @eq-l01-projection. The Lecture 5 and 6 briefs already write $\tilde u_{t,h}$ for a regression residual, so the new symbol matches later use. |
| N2 | @eq-l01-estimation-error | $\hat\beta_h=\beta_h+\sum_t\omega_t\,e_{t,h}$ | $\hat\beta_h=\beta_h+\sum_t\omega_t\,\tilde u_{t,h}$ | Carries N1 into the numbered equation. Exercises, solutions, and slides must use $\tilde u_{t,h}$ if they cite it. |
| N3 | Same paragraph as N1, before it | "return exactly $b$ when every outcome equals $a+bs_t$" | "recover the slope exactly when every outcome lies on a line in $s_t$" | $b$ is Jordà–Taylor's peak parameter (D20) and $b_k(h)$ is a basis function in the ledger. The claim needs no symbols. |

### Checked and consistent

- The intercept is $\mu_h$ everywhere (@eq-l01-projection, @eq-l01-lp-toy,
  @eq-l01-lp, @tbl-l01-notation, and the intercept paragraph in
  §response-graph). $\alpha$ does not appear in the body, the glossary, or the
  figures.
- $s_t$ is the intervention variable. In @eq-l01-lp, $\mathbf w_t$ is bold and
  its coefficient is $\boldsymbol\gamma_h'$; the lecture's scalar control
  coefficient is $\gamma_h$ (BRIEF §2). The residual is always $u_{t,h}$ with
  two subscripts.
- The ledger's distinctions hold in the prose, tables, captions, and axis
  labels: $\theta_h$ is the causal response, $\beta_h$ the projection
  coefficient, $\hat\beta_h$ its estimate. $B_h$ appears nowhere (Lecture 2).
- D36 symbols are used as the ledger defines them: $v_t$, $\sigma_v$,
  $\sigma_s$, $\theta_0$, $y^{c}_t$. The residual is "at most MA($h$)".
- $T$, $T_h$, $\mathcal T_h$, $H$, $p$, $\rho$, and $R$ follow the ledger.
- The Stata names follow ledger §9: `h`, `beta_h`, `T_h`, `s`, `y`.
- Figure sources label their axes $\theta_h$, $\hat\beta_h$, $\rho$,
  $y^{c}_t$, $T_h$, calendar time $t$, and horizon $h$.

### Considered and kept

- **$\omega_t$, the row weights in @eq-l01-ols-slope.** The ledger's $\omega$
  entries are all weights, told apart by their decorations: $\omega^{*}_h$ is
  Lecture 7's bias weight and $\omega_h(e)$ is Lecture 10's causal weight.
  $\omega_t$ joins that family with its own subscript. Lecture 10's weights are
  built from exactly these regression weights, so the shared letter helps. The
  obvious replacement, $\psi$, is already a lecture-local parameter in the
  Lecture 3 and Lecture 5 briefs.
- **$k$ for lead and lag counts and for the distance between rows.** BRIEF §1
  and §5 use $y_{t\pm k}$ and $\operatorname{Corr}(u_{t,2},u_{t+k,2})$. The
  ledger's $k$ is Lecture 12's event time, which is also a count of periods, so
  a reader meets no contradiction.
- **$\tau$ as a row index.** D20's $\tau$ is a moving-average coefficient local
  to Lecture 7 and absent from the ledger table. $n$, $n_0$, and $n_1$ are not
  ledger symbols.
- **Timing of $\mathbf w_t$ in @tbl-l01-notation.** The table says "dated
  $t-1$ or earlier"; the ledger allows $t$ for Lecture 3's recursive exception.
  VERIFY-math X2 already records this, and it is correct for Lecture 1.

### Figure wording (figure files)

| Figure | Before | After |
|---|---|---|
| `fig-l01-persistence.tex` | x-axis "horizon $h$ (periods after the shock)" | "… (periods after the intervention)" |
| `fig-l01-one-draw.tex` | x-axis "horizon $h$ (periods after the shock)" | "… (periods after the intervention)" |
| `fig-l01-realized-counterfactual.tex` | label "counterfactual $y^{c}_t$: the $t=5$ shock switched off" (and two source comments) | "… the $t=5$ intervention switched off" |

Each caption already says "periods after the intervention", and the body calls
$s_t$ an intervention until Lecture 3 (BRIEF §3). The three figures were rebuilt
with `figures/build.sh` (lualatex, then pdftocairo), which regenerates the
`.pdf` and `.svg` together. The rebuilt PDFs were rasterized and inspected, and
the longer realized-counterfactual label still fits inside the axis box.
`fig-l01-first-contact` ("quarters after the news") and `fig-l01-row-staircase`
needed no change.

## 2. Terminology

- The body marks 20 `.glossary-term` keys. They are exactly the 20 keys the
  terminology plan allocates to Lecture 1. The BRIEF adds no keys, and no key
  owned by another lecture is marked, so no `.course-glossary-duplicate`
  wrapper is needed.
- Each key is marked once. Eighteen spans sit on one source line; two,
  `counterfactual` and `impulse-response-function`, break across lines, and a
  multi-line check confirmed each occurs once.
- `glossary.qmd` has 20 `.glossary-head` entries, one per marked key. They are
  alphabetized by displayed term (case-folded; "Estimand" before "Estimation
  sample", "Lag" before "Lead", "Regression row" before "Response graph").
- Every definition says what the object is and why it matters. VERIFY-math G01
  and G02 had already corrected the observed-shock and projection-coefficient
  entries.
- Terms owned by later lectures appear unmarked, as prose or inside footnotes:
  anticipation, identification, and Frisch–Waugh–Lovell (Lecture 3); serial
  correlation and confidence interval (Lecture 5); small-sample bias
  (Lecture 2); sensitivity analysis (Lecture 13). The 17 `.footnote-term`
  spans are local and not tracked.
- In the rendered HTML, the sets of `glossary-term` and `glossary-head` keys
  are identical (20 each).

## 3. Cross-references and figure assets

- Labels in the lecture's sources: 15 `eq-l01-*`, 5 `fig-l01-*`, 6 `tbl-l01-*`,
  12 `sec-l01-*` (the ten chain anchors, `#sec-l01-exercises`, and
  `#sec-l01-glossary`), and 4 `assumption-l01-a1`–`a4`. Every `@eq-`, `@fig-`,
  `@tbl-`, and `@sec-` reference and every `(#assumption-…)` link resolves.
  The audit's label check passes on these, Quarto printed no cross-reference
  warning, and the HTML contains no `quarto-unresolved-ref`.
- The ten links `(#exercise-l01-1)` to `(#exercise-l01-10)` have no target yet,
  because `exercises.qmd` is still the 51-byte placeholder for the exercises
  stage (open issue 1). The link numbers match the BRIEF §5 assessment map.
- The 5 figure blocks use `fig-l01-realized-counterfactual`,
  `fig-l01-persistence`, `fig-l01-row-staircase`, `fig-l01-one-draw`, and
  `fig-l01-first-contact`. Each exists in `figures/` as `.svg` and `.pdf`, and
  the body and figure builder agree on every name, so nothing was renamed. The
  BRIEF's two droppable candidates were dropped under D24:
  `fig-l01-sample-by-horizon` gave way to @eq-l01-sample-size and the
  staircase, and `fig-l01-news-variation` to @tbl-l01-news-variation. Source
  comments record both.
- Every SVG image line carries `fig-alt` text that describes the relationship.
  Every caption opens with `[Short title]{.smallcaps}.` and then interprets:
  it states the comparison, the units, and the lesson visible in the figure.

## 4. Citations

- Cited keys: `hetzelleach2001`, `inouejordakuersteiner2026`, `jorda2005`,
  `jordataylor2025`, `montieloleaplagborgmoller2021`,
  `montieloleaplagborgmollerqianwolf2026`, `ramey2011`, `rameyzubairy2018`,
  `rockoff1984`, `romerromer2010`, `stockwatson2018`. All 11 are in
  `references.bib`, and the file has no uncited entry.
- The seven required-reading entries were extracted from
  `replication-packages/references-master.bib` and diffed against the lecture
  file: all seven are byte-identical.
- Field coverage. Every article has author, title, year, journal, volume,
  pages, url, and urldate. All but `hetzelleach2001` also carry a DOI, and all
  but `montieloleaplagborgmollerqianwolf2026` carry a number. Hetzel and Leach
  have no DOI because *Economic Quarterly* assigns none, a fact the entry's
  comment records. The NBER *Macroeconomics Annual* entry is copied verbatim
  from the master file, which lists no issue. The book entry has publisher,
  address, DOI, url, and urldate. The notes-author field list was not in this
  stage's inputs, so these were checked against the master bib's field set.
- Checked on the web, 2026-09-13:
  - `hetzelleach2001`: Richmond Fed article page and RePEc
    `fip/fedreq/y2001iwinp33-55` confirm "The Treasury-Fed Accord: A New
    Narrative Account", by Robert L. Hetzel and Ralph F. Leach, *Economic
    Quarterly* 87(1), Winter 2001, pp. 33–55. Correct as written.
  - `rockoff1984`: the Cambridge Core record gives *Drastic Measures: A History
    of Wage and Price Controls in the United States*, print 29 June 1984, DOI
    10.1017/CBO9780511600999. Correct.
  - `ramey2011`: the Oxford Academic page prints the title as "Identifying
    Government Spending Shocks: It's all in the Timing", QJE 126(1), 1–50, and
    the bib keeps the publisher's capitalization. Correct.
  - `romerromer2010`: AER 100(3), 763–801, DOI 10.1257/aer.100.3.763, matching
    the AEA page the entry cites. No doubt was raised.

## 5. Structure

- `notes.qmd` equals `docs/templates/notes.qmd` with the substitutions applied
  (`diff` is empty). It includes `_body.qmd`, places a `\clearpage` before
  References, and carries the opener metadata.
- `_body.qmd` contains, in order:
  - the pairing note, hidden in PDF, linking the slides, the
    Shock-to-Response Explorer, and Practicum 01;
  - the opening situation;
  - five learning outcomes;
  - the prerequisites paragraph;
  - ten numbered `##` sections;
  - Exercises (`{.unnumbered #sec-l01-exercises}`) with the PDF
    solutions-companion note and the include;
  - Further Reading;
  - Lecture Glossary (`{.unnumbered #sec-l01-glossary}`) with the HTML and PDF
    notes and the include.
- The `##` titles and anchors follow BRIEF §1's dependency chain one to one:
  question, two-clocks, smallest-model, model-to-regression, many-shock-dates,
  rows-by-hand, response-graph, residual, first-contact, handoff. The
  template's closing section (`#sec-lNN-summary`) is the BRIEF's
  `#sec-l01-handoff`, which returns to the opening, lists what the reader can
  now produce, and ends with the Lecture 2 question from the spine.
- No level-1 heading exists; there are 25 `###` subsections. The four
  assumptions sit in one `.assumptions` block with anchors
  `#assumption-l01-a1`–`a4`, and each gives meaning, where it is used, what
  fails without it, and its kind.

## 6. `scripts/audit_session.py`

- On the real directory it reports only `missing required files:
  solutions.qmd, slides.qmd` and stops there, because the script returns
  before any other check when a required file is absent.
- To run the remaining checks, the lecture was copied to
  `build-01/audit-copy/` with stub `solutions.qmd` (including `exercises.qmd`)
  and `slides.qmd`, then audited with the repository script. Figure paths
  still resolve against the real repository. Result on the final sources:
  - PASS: includes wired; 20 glossary uses and definitions match one for one;
    alphabetized; all 5 teaching figures have SVG, PDF, and alt text.
  - ERROR: `cross-references without explicit targets: exercise-l01-1 …
    exercise-l01-10` (open issue 1).
  - Snapshot: 10 main sections, 25 subsections, 15 equation labels, 5 figure
    labels, 6 table labels, 20 glossary terms, 17 footnote terms.
  - With `--playground`, the script also reports that
    `interactives/01-shock-to-response-explorer.qmd` does not exist yet
    (a later stage).

## 7. Render and inspection

Commands, from the repository root, run on the final sources:
`quarto render lectures/01-question-to-projection/notes.qmd --to html`, then
`--to pdf`.

- **HTML.** Exit 0. The only warnings are `Unable to resolve link target` for
  `slides.qmd`, the Explorer, and `practica/p01-question-to-projection/index.qmd`,
  all created by later stages. No cross-reference warning.
  - In `_site/lectures/01-question-to-projection/notes.html`, the
    `glossary-term` keys equal the `glossary-head` keys (20 and 20), and
    `quarto-unresolved-ref` does not occur.
  - The two `??` strings in the file are JavaScript nullish operators.
  - The contents strip is built at runtime by `lectures/notes-chapter.html`
    from every `h2` outside callouts and floats. The page has 14 level-2
    sections: the ten `sec-l01-*` chain sections, `sec-l01-exercises`,
    `further-reading`, `sec-l01-glossary`, and `references`. The strip
    therefore lists every `##` section.
- **PDF.** Exit 0, no LaTeX warning in the render output, 39 letter pages.
  Every page was rasterized with `pdftoppm -r 60 -png` into
  `build-01/notes-pdf/` and read.
  - Page 1 carries the kicker "LECTURE 01", the title, the course line, and
    the ruled contents panel with page numbers for all ten sections, Exercises,
    Further Reading, Lecture Glossary, and References. The body begins on
    page 2.
  - All five figures appear whole, with the caption above and their labels
    legible.
  - Displayed equations, including the two-case @eq-l01-residual-acov and the
    long exact-decimal lines in §many-shock-dates and §rows-by-hand, stay
    inside the margins. A word-bounding-box scan (`pdftotext -bbox`) found no
    word more than 2 pt past the 540 pt text edge. The only hits are
    sentence-final periods hanging into the margin.
  - No heading is orphaned at a page foot, no page is clipped, and floats
    create no half-empty page.
  - Page 37 is one-third full because `notes.qmd` places `\clearpage` before
    References, as the template intends.
  - `pdftotext` finds no serial-number line from a Stata banner.
- **Fixed during inspection: @tbl-l01-notation.** Its four equal columns
  wrapped every Meaning and Units cell onto two or three lines and pushed the
  table across two pages. Relative dash widths in the pipe-table separator now
  set Symbol, Meaning, Timing, and Units to 8:32:23:23. The table's PDF length
  fell by about a third, every Units cell fits on one line, and §5 now starts
  on page 18. The HTML uses the same relative widths.
- **Acceptable as is.**
  - @tbl-l01-hand-table (a longtable) breaks after row 10 on page 5 and repeats
    its header above rows 11–12 on page 6.
  - The last line of the Stock–Watson reference falls alone on page 39.
  - Both will move when the exercises are added above Further Reading, so
    neither was forced with manual page breaks.

## 8. Open issues forwarded

1. **Exercise anchors.** `exercises.qmd` is still the placeholder
   `<!-- exercises: written by the exercises stage -->`. The ten body links
   `[Exercise K](#exercise-l01-K)`, K = 1…10, resolve only once that stage
   writes `### Exercise K: … {.unnumbered .exercise-title #exercise-l01-K}` as
   numbered in BRIEF §5. Until then the audit fails on them, and the rendered
   Exercises section holds only its introductory note.
2. **Later-stage files.** `solutions.qmd`, `slides.qmd`, the Explorer, and the
   practicum index do not exist yet. They produce the audit's missing-file
   error and the three HTML link warnings.
3. **Notation handed to downstream stages.** The estimation-error term is now
   $\tilde u_{t,h}$ with intercept $\tilde\mu_h$ in @eq-l01-estimation-error.
   Figure axes say "periods after the intervention". Slides, solutions, and the
   Explorer should use the same wording.
4. **Publication boundary.** A copy of BRIEF.md sits in the public
   `lectures/01-question-to-projection/`, and every other lecture directory
   also has a public BRIEF.md. D54 and AGENTS.md call briefs public; this
   pipeline's instructions keep them in a private directory outside the repository. The files are
   outside this stage's write scope and were not touched. The editor decides.
   The site render globs `**/*.qmd`, so the `.md` briefs are not rendered as
   pages, but they are in the public repository.
5. **Carried from VERIFY-math.**
   - AGENTS.md names `scripts/audit_lecture.py`, but the script is
     `scripts/audit_session.py`.
   - Disputed items X1, X2, and X4 stand.

## Resolved after this pass, September 14, 2026

Two items forwarded above are settled by later editor decisions and are not
open: the publication boundary (D54 makes briefs, logs, and solutions public,
so `BRIEF.md` stays in the lecture directory), and the audit script name
(AGENTS.md now names `scripts/audit_session.py`).
