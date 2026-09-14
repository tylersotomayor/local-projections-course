# Lecture 01 — authorial pass (editorial voice)

Stage: the single-owner voice pass that the authoring guide prescribes after
technical correctness ("Phase 10: perform the authorial pass" and the
editorial gate of "Definition of done"). Date: 2026-09-14.

Files read continuously and edited (prose only):

- `lectures/01-question-to-projection/_body.qmd`
- `lectures/01-question-to-projection/exercises.qmd`
- `lectures/01-question-to-projection/glossary.qmd` (read; no change needed)
- `practica/p01-question-to-projection/index.qmd`
- `interactives/01-shock-to-response-explorer.qmd` (markdown prose only; no
  Observable JS cell, control label, or reactive-sentence template was touched)

Method. A snapshot of the five files was taken before any change
(`build-01/edit-baseline/`, in a session-local scratch folder that is not
published). Every edit was applied by
`build-01/apply_edits.py`, which asserts that each replaced passage
occurs exactly once and writes nothing if any assertion fails. The script
records the reason for each edit beside it. `build-01/check_invariants.py`
then compared the edited files with the snapshot, strictly, for display math and
equation labels, section/figure/table/assumption/exercise anchors,
cross-references, citations, glossary spans, footnote-term spans together with
the full text of each note, code blocks, table rows, table and figure captions,
and figure alt text; inline math and numbers outside math were listed for
manual review.

## Kinds of change

1. **Generic announcements.** Three section openings announced their own
   contents ("This section names the three parts and then shows…", "This
   section shows … and it is careful about which step makes that true", "This
   section builds the rows …, computes each slope …, and shows …"). Each now
   states the difficulty instead: the first two parts of a causal question can
   be measured and the third cannot; the work lies in finding which step makes
   the population regression causal; the twelve-period economy is small enough
   to list its rows and compute every slope by hand.
2. **Seams from section-by-section drafting.** Three bridges and the openings
   after them made the same point twice:
   - the end of `#sec-l01-question` and the start of `#sec-l01-two-clocks` both
     described the gap at $t=7$ by date and by distance from the intervention;
     the bridge now names the new problem (a regression pools interventions, so
     it must decide how to date a gap), and the opening keeps the example;
   - the end of `#sec-l01-smallest-model` listed the rows data provide, and the
     opening of `#sec-l01-model-to-regression` listed them again; the opening now
     refers to "those rows";
   - the end of `#sec-l01-model-to-regression` and the opening of
     `#sec-l01-many-shock-dates` both said that a sample has finitely many dates
     and asked how the slope uses them; the bridge keeps the first point and the
     opening keeps the second.
3. **A formulaic recap.** The paragraph closing `#sec-l01-residual` listed four
   things the toy economy had shown ("what…, how…, why…, and what…") and ended
   "The regression can finally meet the data". It now ends with a result and a
   limitation: past this point there is no known response to check an estimate
   against.
4. **Advertising, inflated, or vague language.** "an honest list", "an honest
   band", "something every published response graph shows", "matter for
   everything that follows", "the limiting cases behave sensibly", "says
   something useful about estimation error", "it pays to see", "makes this
   concrete", "a hair below", and, in Exercise 6, "the only design decision
   that matters".
5. **Imagined reader reaction.** "A reader shown only this curve would conclude
   that the response turns negative after ten periods" now says what the curve
   shows when read on its own.
6. **Unearned transitions.** "That raises a question:" and "the next section
   does it by hand".
7. **Repeated tics.** Eight sentences began "Read @eq-…" or "Read the …";
   four keep it where it supplies an action order (across, left to right, as a
   vote, outside in), and "Sort @eq-l01-residual by date" gives the reader a
   different action. Six sentences opened "Now …"; four remain. Nine of the ten
   worked solutions labeled their common error "a predictable mistake" or "two
   mistakes are predictable"; eight are now varied, two of them with run-in
   labels that name the error (*What the first assertion catches.*,
   *Seeding inside the loop.*). Exercise 9 keeps "Two mistakes are
   predictable."
8. **Person.** The handoff's inventory "What you can now produce … What you
   cannot yet produce" became "We can now produce … We cannot yet defend",
   following the guide ("we" reasons with the reader, "you" instructs) and the
   reference implementation's closing ("We can now trace…").
9. **Precision and grammar in prose.** "The two sides of
   @eq-l01-change-decomposition agree with $\theta_h$" became "The left side …
   equals $\theta_h$"; "simplifies to an arithmetic" became "simplifies to
   arithmetic"; the practicum's opening "matches the published benchmark once
   the number of draws matches" became "reproduces the published benchmark
   once the number of draws matches".
10. **A summary restating a list just given.** After the four numbered slots of
    a response graph, "A complete caption therefore names the intervention, the
    units of $s$ and $y$, the horizon unit, and the counterfactual" repeated
    the list, and its "therefore" followed a sentence about the intercept. It now
    reads "A complete caption fills the four slots and leaves the intercept
    out".
11. **Other small repetitions.** An empty topic sentence ("The two random inputs
    have simple descriptions") and a repeated "drawn independently each
    period" were removed. In `#sec-l01-response-graph`, "keeps each coefficient
    attached to the number of rows behind it" repeated the section opening's
    phrase. "The two numbers from the opening now look different" had an
    ambiguous referent, because the second number is computed only in the
    handoff.
12. **Browser lab.** Lab 3's collapsed explanation copied a sentence verbatim
    from the notes ("the draw is kept because its failure is informative"); it
    is reworded. The closing section, "From One Gap to One Coefficient", stated
    the whole chain and only then asked the learner to explain it. It now asks
    for the learner's one-sentence-per-lab version first and then shows the
    chain for comparison. That follows the guide's lab loop (commit before
    reading the explanation). The chain paragraph itself is unchanged.

The glossary was read against the body and needed no change: each definition
says what the object is and why it matters, and no key is defined twice.

## Checks

| Check | Result |
|---|---|
| `check_invariants.py` against the pre-edit snapshot | Strict classes unchanged in all five files: display math with equation labels, section/figure/table/assumption/exercise anchors, cross-references, citations, glossary spans and heads, footnote terms with the full text of every note, code blocks, table rows, captions, and alt text. Numbers outside math: unchanged. Inline math: five spans fewer in `_body.qmd`, each inside a removed duplicate phrase (`$t=7$` in the old bridge to Two Clocks; `$s_t$` and `$h$` in the re-listed rows at the start of From the Model to a Regression; `$s$` and `$y$` in the caption sentence that repeated the four slots). No other file lost or gained a math span. |
| `python3 scripts/audit_session.py lectures/01-question-to-projection --playground interactives/01-shock-to-response-explorer.qmd` | PASS. Snapshot identical to the run before editing: 10 sections, 25 subsections, 15 equation labels, 5 figures, 6 tables, 20 glossary terms, 17 footnote terms, 10 exercises, 15 slides, 17 lab controls, 4 prediction prompts, 4 collapsed explanations, 47 cross-references resolved. |
| `quarto render lectures/01-question-to-projection/notes.qmd --to html` | Exit 0, no warning. `_site/lectures/01-question-to-projection/notes.html` contains no `?@` and no `??`; each of the 28 edited body passages (41 edits in all: 28 body, 10 exercises, 1 practicum, 2 Explorer) was located in the rendered text and read in context (the sentences that now open with a cross-reference render as "Equation 4 is an account…" and "Equation 12 is the episode's outcome…"). |
| `quarto render` of `solutions.qmd`, the Explorer, and the practicum index, `--to html --output-dir build-01/edit-render-out` | Exit 0 each, no warning; rendered outside `_site/`. |
| Files changed | Only `_body.qmd`, `exercises.qmd`, the practicum `index.qmd`, and the Explorer source; no stray render directories. `glossary.qmd` unchanged. |
| Slides | None of the replaced sentences appears in `slides.qmd`, so the guide's rule for on-slide text does not call for a slide edit. |
| Length (same counting script before and after) | `_body.qmd` prose before the exercises: 10,869 → 10,784 words (−0.8%), 613 sentences before and after, mean sentence length 17.7 → 17.6 words, median 17. Exercises 7,412 → 7,416; practicum 2,443 unchanged; Explorer prose 2,836 → 2,856. |
| Sentences changed (estimate) | 54: body 40, exercises 10, practicum 1, Explorer 3. |

No Stata was run in this pass, so no log was produced or published.

## Left for an authorial decision

1. **"Impact effect" and "impact response."** The glossary key is
   `impact-response`, and the course notation ledger calls $\theta_0$ the
   impact response. The body calls the coefficient $\theta_0$ "the impact
   effect" once (`#sec-l01-smallest-model`); the Explorer uses "impact effect"
   in its closing paragraph, in a control label, and in one reactive sentence
   (the last two inside Observable JS code); the brief's own ledger says
   "Impact effect of $s_t$ on $y_t$". Separating the parameter from the
   response it produces is defensible. Making the notes, glossary, and lab code
   agree is a terminology decision, and the lab occurrences are in code this
   pass did not touch.
2. **The Lecture 5 preview in `#sec-l01-residual`.** It is one sentence of about
   sixty words, because D43 allows a preview of a later lecture in one labeled
   sentence. Two sentences would read better but would no longer be the one
   sentence D43 describes.
3. **"And most of what the full-sample coefficient reports comes from before
   1947."** The sentence interprets the fall from 0.3619 to 0.0587 when the
   sample starts in 1947Q1 (268 rows). Whether the first-contact section should
   draw that inference, or state only the two numbers and the change of sample,
   is the author's call.
4. **Notation table placement.** `@tbl-l01-notation` closes
   `#sec-l01-model-to-regression` but lists $\mathcal T_h$ and $T_h$, which are
   defined in `#sec-l01-rows-by-hand` (its caption says so). Moving the table
   would remove the forward reference but changes the chapter's structure.
5. **Sentence length in derivations.** The body averages 17.6 words per
   sentence against the guide's figure of about sixteen for the reference
   session. The longest sentences state conditions: A2's *Without it*, the
   large-sample standard deviation of $\hat\beta_0$ in "Why Include the Lagged
   Outcome?", and the covariance counting in "Shared Terms Between Rows".
   Splitting them touches the wording of stated conditions, which a prose-only
   pass should not risk without the author.
6. **The Explorer's closing chain.** The reorder asks for the learner's
   explanation before showing the chain. A stronger version would put the chain
   in a collapsed callout, as the four labs do with their explanations; that
   changes the page structure and the audit's count of collapsed explanations,
   so it was not done.
7. **Definitions restated in exercises.** Exercise 3 restates the
   difference-in-means result, and Exercise 7 defines the Monte Carlo standard
   error again. Both stay because the solutions companion must read on its own.
8. **Publication boundary.** The public repository contains
   `lectures/01-question-to-projection/BRIEF.md`, a file with the same name and
   byte size as the private brief. The instructions for this stage keep
   planning briefs in a private directory only, while D54 as recorded in
   `docs/editor-decisions.md` says planning briefs are public. The owner should
   reconcile the two; this pass neither moved nor deleted the file.

## Resolved after this pass, 2026-09-14

Item 1 is settled by editor decision D55: $\theta_0$ is the *impact response*
everywhere, including lab labels and reactive sentences. The body, the
Explorer's closing paragraph, its control label, and its reactive sentence now
use that term, and the phrase the item names occurs nowhere in the lecture, the
Explorer, or the practicum.

Item 8 is settled by D54: everything is public, briefs included, so
`BRIEF.md` stays in `lectures/01-question-to-projection/`. The same decision
publishes these logs, the practicum's solved problem set, and the instructor
build.
