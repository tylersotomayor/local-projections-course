# Lecture 01 — render and release inspection

Stage: release inspection by medium (notes HTML/PDF, solutions HTML/PDF,
slides, browser lab, practicum index, instructor build, full site).
Date: 2026-09-13. Quarto 1.10.18, LuaHBTeX (TeX Live 2024).
Scratch: `build-01/`, a session-local scratch folder that is not published
(render logs, page images, kept `.tex`).

## 1. Commands and outcomes

All run from the repository root.

| Command | Result |
|---|---|
| `python3 scripts/audit_session.py lectures/01-question-to-projection --playground interactives/01-shock-to-response-explorer.qmd` | PASS, no errors (before and after the fixes): 10 sections, 25 subsections, 15 equations, 5 figures, 6 tables, 20 glossary terms, 17 footnote terms, 10 exercises with one hint and one solution each, 47 cross-references resolved, 15 slides, 17 lab controls, 4 prediction prompts |
| `quarto render lectures/01-question-to-projection/notes.qmd` | exit 0, HTML and PDF; no WARN, no unresolved reference; makeindex 37 entries, 0 warnings |
| `quarto render lectures/01-question-to-projection/solutions.qmd` | exit 0, HTML and PDF; no WARN |
| `quarto render lectures/01-question-to-projection/slides.qmd` | exit 0; no WARN |
| `quarto render interactives/01-shock-to-response-explorer.qmd` | exit 0; no WARN |
| `quarto render practica/p01-question-to-projection/index.qmd` | exit 0; no WARN |
| `quarto render practica/p01-question-to-projection/build/index.qmd` | exit 0; no WARN |

The final PDFs: notes 43 pages, solutions companion 33 pages.

## 2. PDF inspection

Both PDFs were rasterized with `pdftoppm -r 60 -png` and every page was read,
then re-read after each fix that moved pagination (notes pages 23–43 after the
Table 4 fix; all 33 solutions pages after the callout fix). Ambiguous glyph
spacing at 60 dpi (glossary "periods $h$") was checked against `pdftotext`;
the space is present.

### Notes (`notes.pdf`, 43 pages)

- Page 1 is the opener: kicker "LECTURE 01", title, course line, and the ruled
  "Contents of this lecture" panel with page numbers for sections 1–10,
  Exercises, Further Reading, Lecture Glossary, References. No date, no
  "Lecture notes" label.
- The body starts on page 2 (Korea opening, footnotes 1–3 at the foot of the
  same page).
- Captions sit above all five figures (Figures 1–5) and all six tables, in
  small caps with interpretive text. Figures are vector and legible at page
  size; the row staircase (Figure 3) is the smallest and still readable.
- Footnotes appear on the page where the term occurs. Footnote 15 begins on
  page 28 and finishes at the foot of page 29, a normal split.
- Exercises (pages 34–39) print problems only. No "Hint" or "Detailed
  solution" appears anywhere in the notes PDF; the PDF-only notice points to
  `solutions.pdf`.
- Further Reading, then Lecture Glossary (pages 40–42, alphabetized, bold
  heads), then References last (page 43, eleven entries).
- Long tables that break (Table 1 at 10/2 rows, Table 3 notation) repeat their
  headers. Keeping Table 1 whole would leave half of page 5 empty, so the break
  stays.
- No clipping, no overflow into margins, no accidental blank pages. The
  glossary's last entry ends near the top of page 42 before the forced page
  break for the references; that is a section end, not a stray page.

### Solutions companion (`solutions.pdf`, 33 pages)

- Own opener: kicker, "Exercise Hints & Worked Solutions", course line,
  "Contents of this companion" listing all ten exercises with page numbers.
- Every exercise prints Problem, Hint, and Detailed solution in full.
- The four do-files (Exercises 4, 6, 7, 9) break across pages at full size and
  are complete through `log close`; the Stata log listings and the Exercise 7
  summary table print in full.
- Ends on page 33 with the last paragraph of Exercise 10's solution.

## 3. Defects found and fixed

Five defects; every fix is in a source file, followed by a re-render and a
re-read of the affected pages.

1. **Solutions PDF: code listings clipped and tables stranded.** Hints and
   solutions are Quarto callouts. In LaTeX each became a breakable `tcolorbox`,
   and the `Shaded` code blocks (framed `snugshade`) and longtables nested
   inside could not break with the box. The do-files of Exercises 4, 6 and 7
   were cut off at the foot of a page: Exercise 4 stopped at
   `quietly summarize F\`h'.y if t >= 2 & s == 1`, so the regressions and
   assertions never printed. Tables and code were pushed down, leaving
   half-empty pages 3, 9, 11, 16, 20 and 22, and the Exercise 7 summary table
   sat under an empty page 22. Fix in the shared filter
   `filters/course-apparatus.lua`: a `Callout` handler that runs only for LaTeX
   in a `solutions-document` prints each `.exercise-hint` / `.exercise-solution`
   callout as ordinary blocks under its label (`\par\addvspace{\medskipamount}
   \noindent Hint\par\nopagebreak`). The HTML callouts, the notes PDF (which
   drops `.solution-material` before this matters) and the handbook (no
   `solutions-document`) are unaffected. A first version dropped every hint
   body, because Quarto 1.10 stores a callout's body as one Div block rather
   than a block list; the handler now accepts both. Result: 36 pages became 33,
   the listings are complete and break legibly, and no half-empty pages remain.
2. **Notes PDF: three-row Table 4 split across pages 23–24.** The header and
   the $h=0$ row were on page 23; the header repeated with $h=1,2$ on page 24.
   Fix in `_body.qmd`: a raw-LaTeX conditional page break before
   `tbl-l01-hand-slopes` (`\ifdim\dimexpr\pagegoal-\pagetotal\relax
   <0.42\textheight\newpage\fi`). Table 4 is now whole on page 24. Page 23 ends
   about a quarter-page early, the accepted cost. HTML ignores the block.
3. **Notes PDF: references overran by one line.** The last line of Stock and
   Watson (2018) was alone on an otherwise blank final page. Fix in
   `notes.qmd`: `\enlargethispage{2\baselineskip}` after the References
   heading. After fix 2 moved pagination, the whole list fits on page 43.
4. **Solutions companion: empty References section.** `exercises.qmd` cites
   nothing, so the companion printed a lone "References" heading on a blank
   page 34, and an empty heading on the web. Fix in `solutions.qmd`: the
   section is removed, with a comment to restore it if an exercise adds a
   citation.
5. **Stata batch log in the site.** `setup/readiness/readiness_solution.log`
   was a batch-mode log (StataNow banner, license line, serial number). It is
   git-ignored, but `_quarto.yml` publishes `setup/readiness/*.log`, so the
   copy in `_site/setup/readiness/` carried the serial number. Nothing links to
   it: the setup page links the `.do` file, and the do-file's own log is
   `readiness_expected_output.log`, written with `log using`. Deleted; the full
   render removed the `_site` copy. The first `grep -rIl` over the repository
   missed this file (binary detection), so every final license grep also ran
   with `-a`.

## 4. HTML inspection (`_site/`)

- **Link integrity.** A script resolved every relative `href`/`src` and every
  `#anchor` against target ids, first on the six Lecture 01 pages and again
  after the full render on those pages plus the four overview pages. Problems:
  0 on every page. Relative links checked: notes 37, solutions 29, slides 32,
  lab 53, practicum 36, build 41.
- **Pairing note.** "These notes pair with the slides, the Shock-to-Response
  Explorer browser lab, and Practicum 01" resolves to `slides.html`,
  `../../interactives/01-shock-to-response-explorer.html` and
  `../../practica/p01-question-to-projection/index.html`, all existing.
- **Other Formats.** Present on notes and solutions; `notes.pdf` and
  `solutions.pdf` exist beside the HTML (43 and 33 pages after the full
  render).
- **Glossary popovers.** 20 `glossary-term` keys and 20 `glossary-head` keys
  in `notes.html`, identical sets; 17 `footnote-term` spans.
- **Practicum index.** Links `p01-question-to-projection-lab.zip` (exists,
  66,320 bytes, identical to the source archive) and the instructor build.
- **Build page.** Every `output/` reference exists under
  `_site/practica/p01-question-to-projection/build/output/`:
  `fig-rep01-levels-mean.svg`, `fig-rep01-first-draw.svg`, `rep01-benchmark.csv`,
  `assertions.csv`, `handoff-check.csv`, and the `log using` logs `master.log`,
  `checks.log`, `rep01.log`, `handoff-check.log` (none contains a serial
  number).

### Cross-page links (rendered hrefs, all resolving)

| From | To | Rendered href |
|---|---|---|
| notes | lab | `../../interactives/01-shock-to-response-explorer.html` |
| notes | practicum | `../../practica/p01-question-to-projection/index.html` |
| notes PDF | solutions | `solutions.pdf` (PDF-only companion notice) |
| lab | practicum | `../practica/p01-question-to-projection/index.html` |
| lab | notes | `../lectures/01-question-to-projection/notes.html` plus 21 anchored links (`#sec-l01-question`, `#eq-l01-theta`, `#fig-l01-one-draw`, `#exercise-l01-9`, …) |
| practicum | lab | `../../interactives/01-shock-to-response-explorer.html` |
| practicum | notes | `../../lectures/01-question-to-projection/notes.html` (also `#eq-l01-lp-toy`, `#sec-l01-residual`, `#sec-l01-exercises`) |
| practicum | archive | `p01-question-to-projection-lab.zip` |
| slides | lab, practicum, exercises, solutions | `../../interactives/…`, `../../practica/…`, `notes.html#sec-l01-exercises`, `solutions.html` |

## 5. Slides

All 15 slides were captured with headless Chrome at 1280×720 using
`slides.html?fragments=false#/N`, so each shows its final fragment state, and
every capture was read. Every slide fits above the footer at presentation
size. The fullest, "The forward equation is a regression" and "Inside the
residual", end just above the footer without overlap. Figures (two paths,
persistence, row staircase, one draw, first contact) are sharp, and slide
links to the lab, practicum, exercises and solutions resolve.

## 6. Browser lab

`01-shock-to-response-explorer.qmd` renders without warnings. The audit counts
17 controls, 4 prediction prompts and 4 collapsed explanations, and all 53
relative links resolve. A full-page headless screenshot never finished (the
Observable page never reached idle within three minutes) and was stopped, so
this stage did not drive the controls or confirm the default outputs in a
browser.

## 7. License check (final, after the full render)

In this published copy the search pattern is written `Serial numbe[r]`, which
matches the same lines as the literal phrase but not this file.

- `grep -rIl 'Serial numbe[r]' . --exclude-dir=.git --exclude-dir=_site` lists
  only `AGENTS.md`; the `-a` variant lists only `AGENTS.md`.
- `grep -rIl 'Serial numbe[r]' _site` and `grep -rl -a 'Serial numbe[r]' _site`
  find nothing.
- `unzip -p practica/p01-question-to-projection/p01-question-to-projection-lab.zip | grep -a -c 'Serial numbe[r]'`
  returns 0. The archive contains no `.log` or `.smcl`, so it was not rebuilt.

## 8. Overview pages marked live

- `index.qmd`: the Lecture 01 schedule title is wrapped in
  `<a href="lectures/01-question-to-projection/notes.html">`.
- `lectures/index.qmd`: row 1 links notes, solutions, slides, lab (Lecture
  cell) and P01 (Practicum cell); status `live`.
- `practica/index.qmd`: P01 title links `p01-question-to-projection/index.qmd`,
  lecture number links the notes; status `live`.
- `interactives/index.qmd`: the Shock-to-Response Explorer title links the lab,
  lecture number links the notes; status `live`.

`quarto render` (full site, 12 files, 34.5 s) exited 0 with no WARN line and
no "Unable to resolve link target". The four overview pages' new links all
resolve.

## 9. Open items for the editor

1. **Publication boundary.** `lectures/01-question-to-projection/BRIEF.md` in
   the public repository is byte-identical to the brief in the build's private
   directory.
   `docs/editor-decisions.md` D54 and `AGENTS.md` say planning briefs are
   public; this stage's instructions say briefs live only in a private
   directory outside the repository. It was not deleted, because that is outside this stage's
   write scope. It is not rendered to the site (the render list covers `.qmd`
   only), but it would be committed. The editor should decide and, if needed,
   update D54.
2. **Handbook.** `filters/course-apparatus.lua` changed, and the guide asks for
   a handbook render after an apparatus change. The new handler is gated on
   `solutions-document`, which the handbook does not set, and `quarto render
   handbook.qmd` was not part of this stage.
3. **Template.** `docs/templates/solutions.qmd` still ends with a References
   section. A lecture whose exercises cite nothing will print the same blank
   page unless the section is dropped, as here.
4. **Lab interactivity.** Controls and default outputs were not exercised in a
   browser in this stage (section 6).
5. **Accepted layout.** Table 1 breaks 10/2 with repeated headers. The
   glossary's last entry sits alone at the top of notes page 42 before the
   forced page break for the references.

## Resolved after this pass, September 14, 2026

Two items forwarded above are settled by later editor decisions and are not
open: the publication boundary (D54 makes briefs, logs, and solutions public,
so `BRIEF.md` stays in the lecture directory), and the audit script name
(AGENTS.md now names `scripts/audit_session.py`).
