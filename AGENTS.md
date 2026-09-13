# Repository instructions for course-lecture work

## Governing standard

Before drafting, revising, reviewing, or publishing a lecture, read
[`docs/lecture-authoring-guide.md`](docs/lecture-authoring-guide.md) in full.
It records the editorial, pedagogical, visual, and production decisions that
make the nowcasting workshop's Lecture 1 and this course's Lecture 1 the reference implementations for the course.

Use the reference lecture as a standard of care, not as a page-count template. Future
lectures should inherit its decision logic and house style; their number of
sections, figures, terms, exercises, and labs must follow the material.

## Non-negotiable principles

- Maintain one authored source for shared material. A lecture body feeds the
  standalone notes and the handbook; one exercise source feeds the notes and
  solutions companion; one glossary source feeds the lecture and course
  glossaries. Do not patch generated files in `_site/` or `_freeze/`.
- Begin from an economic or empirical question, then introduce the machinery
  needed to answer it. Preserve the chain from motivation to notation,
  derivation, interpretation, qualification, and transition.
- Explain how to read every consequential equation. Define units and
  conditioning information, interpret each line, and state what changes when
  an assumption fails.
- Mark durable course vocabulary as glossary terms once, at its first useful
  occurrence. Use explanatory footnotes for local prerequisites or secondary
  qualifications. Do not turn every technical phrase into apparatus.
- Add a figure only when shape, timing, dependence, sequence, or comparison is
  easier to understand visually. Add a table when exact mappings or values
  matter. Every figure needs an interpretive caption and web alt text.
- Exercises must test the lecture's conceptual spine. Every exercise receives
  a useful hint and a worked solution that shows the approach, all steps,
  interpretation, and a check or common mistake when appropriate.
- Slides are lecture prompts, not compressed notes. Playgrounds are controlled
  experiments, not demonstrations to click through without prediction.
- Preserve the natural academic voice described in the guide. Do not add
  generic scene-setting, inflated claims, formulaic summaries, fake quotations,
  or prose whose only function is to sound polished.
- Preserve working cross-references and quiet black PDF links. Glossary terms,
  assumptions, equations, figures, tables, exercises, solutions, and relevant
  internal destinations should be linked.

## Required workflow

1. Audit the lecture and its neighbors before editing.
2. Freeze the lecture's question, learning outcomes, dependency spine, anchor
   example, and handoff to the next lecture.
3. Build a terminology/notation ledger and an evidence/figure/exercise map.
4. Draft or revise the notes first. Derive and numerically verify the math.
5. Build figures, exercises and solutions, and the playground from the stable
   conceptual spine.
6. Build the slides last, after notation and examples have settled.
7. Run `python3 scripts/audit_lecture.py SESSION_DIR` (add `--playground PATH`
   when the lecture has one), render every affected format, and inspect the
   rendered output rather than relying on source review alone.
8. Render the handbook when a lecture body, glossary term, footnote term, or
   cross-lecture reference changes.
9. Deploy only when the user has authorized deployment. After deployment,
   verify the live pages and downloads rather than treating a successful build
   as proof of a successful release.

## Source and output conventions

- Lecture source lives in `lectures/NN-slug/`.
- Use `_body.qmd`, `notes.qmd`, `exercises.qmd`, `solutions.qmd`,
  `glossary.qmd`, `slides.qmd`, and `references.bib` following Lecture 1.
- Store editable figure sources beside committed `.svg` and `.pdf` outputs in
  the lecture's `figures/` directory. HTML uses SVG; PDF uses PDF.
- Put browser-native labs in `interactives/` and link them from the notes,
  slides, lecture index, and any relevant exercise.
- Shared behavior belongs in `filters/course-apparatus.lua`,
  `lectures/notes-chapter.html`, `lectures/notes-ebook.css`, or
  `lectures/_pdf/`; do not duplicate it in one lecture without a documented
  reason.

## Verification baseline

- No unused or undefined glossary identifiers.
- No unresolved equation, figure, table, assumption, exercise, or section
  references.
- Every web figure has alt text and a corresponding PDF asset.
- Every exercise has exactly one hint and one detailed solution.
- HTML term and footnote popovers work with pointer and keyboard focus.
- Interactive defaults load, controls change the intended quantity, and fixed
  comparisons keep irrelevant randomness fixed.
- PDFs have a deliberate front page, body begins on the following page, links
  print in black, footnotes remain on the relevant page, and no page clips or
  overflows.
- Slides have no overflow and remain legible at presentation distance.
- The handbook contains the new lecture material, aggregated glossary, and
  updated index.


## Course-specific constraints

- `docs/course-spine.md` freezes each lecture's opening situation, section
  chain, anchors, and handoff. `docs/notation-ledger.md` is binding notation.
  `docs/terminology-plan.md` allocates glossary keys; a later lecture does not
  mark a key owned by an earlier one.
- Stata is StataNow/SE 19.5, run in batch:
  `cd DIR && /Applications/StataNow/StataSE.app/Contents/MacOS/stata-se -e do FILE.do`.
  The exit code is 0 even on error; grep the log for `r(`.
- Every practicum distinguishes exact replication, statistical reproduction,
  and conceptual reproduction, and says which it is. Reduced-replication
  Monte Carlos are never called replications.
- Stata outputs on the site are executed locally and committed as static
  assets under `practica/pNN-slug/build/`; CI cannot run Stata.
- Data shipped in a lab project carries `PROVENANCE.md` (source, version,
  vintage, license, redistribution terms).
