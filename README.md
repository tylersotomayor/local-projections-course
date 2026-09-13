# Local Projections: From First Principles to Empirical Research

Course site for the fourteen-lecture Columbia course on local projections.
Sibling of [nowcasting.tylersotomayor.com](https://nowcasting.tylersotomayor.com)
and [tylersotomayor.com](https://tylersotomayor.com); deploys to
`local-projections.tylersotomayor.com` through GitHub Pages.

## Architecture

**Shared sources, coordinated outputs.** Each lecture's body, exercises, and
glossary are authored once and reused across:

- the course **website** (HTML with KaTeX math, glossary and footnote
  popovers, collapsible hints and solutions),
- **lecture notes** as a LaTeX-compiled PDF ("Other Formats" on the page),
- a staged web and printable **solutions companion**,
- **slides** (reveal.js) as a sibling `slides.qmd`, and
- the aggregated **course handbook**, glossary, and index.

Every lecture has one **practicum** (`practica/pNN-slug/`) with three parts
designed together: a replication lab of a bounded published result, a Stata
problem set, and a browser lab (`interactives/`). Practica ship as
downloadable lab projects with starter do-files, data with provenance,
automated checks, and an executed instructor build whose Stata output is
committed as static assets. Browser labs are Observable JS cells in Quarto
pages; they run entirely in the reader's browser.

## Layout

- `_quarto.yml` — site config, nav, theme
- `theme.scss`, `theme-dark.scss` — typography (Archivo / IBM Plex Mono, matching the main site)
- `lectures/NN-slug/` — one folder per lecture: `_body.qmd`, `notes.qmd`,
  `exercises.qmd`, `solutions.qmd`, `glossary.qmd`, `slides.qmd`,
  `references.bib`, `figures/`
- `lectures/notes-chapter.html`, `lectures/notes-ebook.css`, `lectures/_pdf/` — shared web and PDF chapter apparatus
- `filters/course-apparatus.lua` — solution visibility, glossary links, footnotes, index entries
- `interactives/` — browser labs (OJS)
- `practica/` — practicum pages, lab projects, instructor builds
- `capstone/`, `setup/` — capstone specification; software setup and readiness exercise
- `shared/stata/` — course-wide Stata helpers copied into lab projects, such as `get_rz.do`, which downloads and checksums the Ramey–Zubairy data
- `docs/` — the authoring guide, course spine, notation ledger, terminology plan
- `scripts/audit_session.py` — fast structural audit of one lecture

## Commands

| Command | Action |
|---|---|
| `quarto preview` | Live dev server |
| `quarto render` | Full build to `_site/` (needs LaTeX for the PDFs) |
| `quarto render handbook.qmd` | Rebuild the course handbook PDF |
| `python3 scripts/audit_session.py lectures/NN-slug --playground interactives/NN-lab.qmd` | Structural audit of one lecture |
| `bash lectures/NN-slug/figures/build.sh` | Rebuild a lecture's SVG/PDF figures from TikZ |

Stata work targets StataNow/SE 19.5 and is run in batch:
`cd DIR && /Applications/StataNow/StataSE.app/Contents/MacOS/stata-se -e do FILE.do`.

## Authoring standard

Read `docs/lecture-authoring-guide.md` before creating or revising a lecture.
The intellectual architecture is frozen in `docs/course-spine.md`; notation in
`docs/notation-ledger.md`; glossary ownership in `docs/terminology-plan.md`.
Repository-specific agent instructions live in `AGENTS.md`.

## Deploying

Pushing `main` starts `.github/workflows/deploy.yml`, which installs Quarto and
TinyTeX, renders the site into `_site/`, and publishes through GitHub Pages at
the custom domain. Stata is not available in CI: every Stata output on the
site is executed locally and committed.

## Content sources

The course plan is `~/macro/local_projections/local_projections_course_blueprint.md`.
Replication targets come from the authors' public packages (Jordà–Taylor
JEL-Code, Inoue–Jordà–Kuersteiner, Ramey–Zubairy, Kolesár–Plagborg-Møller,
Li–Plagborg-Møller–Wolf, the JST macrohistory database, `lpdid`). All prose is
original.
