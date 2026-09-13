# Lecture authoring guide

## Purpose and authority

This is the editorial and production standard for future chapters of
*Local Projections: From First Principles to Empirical Research*. It is based on a close audit of Session 1
as it stood on August 3, 2026: the notes and handbook chapter, web edition,
glossary and footnotes, exercises and worked solutions, slides, figures, and
Kalman playground.

Session 1 is the reference implementation. That does **not** mean every session
should have ten sections, eight figures, ten exercises, or five labs. It means
that future work should apply the same judgment about what deserves a section,
what needs a derivation, what belongs in a footnote, and which medium teaches a
particular idea best.

The standard has two aims:

1. preserve a coherent authorial voice across the course; and
2. make the work efficient by settling the intellectual architecture before
   multiplying it across formats.

## Completion judgment for Session 1

Session 1 is complete as a course unit and can be used as the model for later
sessions. “Complete” here means that its components form one instructional
system rather than a collection of files:

- the notes take the reader from the release-calendar problem to a full
  state-space workflow;
- the web and PDF editions present the same authored material in forms suited
  to their media;
- durable vocabulary is defined, linked, and collected;
- local clarifications remain footnotes rather than interrupting the argument;
- the exercise sequence retraces the conceptual spine and supplies staged
  help;
- the slides preserve the lecture's decisions without reproducing the chapter;
- the playground turns five difficult distinctions into controlled
  experiments; and
- the handbook reuses the chapter source while aggregating glossary terms and
  index entries.

The audit found two small bookkeeping defects: one glossary definition lacked
an in-text anchor, and one table of rounded results was called “unrounded.” Both
were corrected. They are useful reminders that a polished chapter still needs
mechanical consistency checks.

## What Session 1 contains

### Artifact map and sources of truth

| Component | Primary source | Function |
|---|---|---|
| Session wrapper | `lectures/01-question-to-projection/notes.qmd` | Metadata, format settings, chapter opener, references |
| Chapter prose | `lectures/01-question-to-projection/_body.qmd` | The shared intellectual body used by the standalone notes and handbook |
| Terms | `lectures/01-question-to-projection/glossary.qmd` | One authored definition for end glossary, hover text, PDF targets, and handbook aggregation |
| Problems and help | `lectures/01-question-to-projection/exercises.qmd` | One source for problems, hints, and solutions |
| Solutions companion | `lectures/01-question-to-projection/solutions.qmd` | A staged web companion and fully expanded printable manual |
| Figures | `lectures/01-question-to-projection/figures/` | Editable sources and paired SVG/PDF assets |
| Slides | `lectures/01-question-to-projection/slides.qmd` | A concise lecture sequence built from the stable chapter spine |
| Playground | `interactives/01-shock-to-response-explorer.qmd` | Five browser-native controlled experiments |
| HTML chapter apparatus | `lectures/notes-chapter.html` and `lectures/notes-ebook.css` | Opener, contents strip, typography, captions, term popovers, and quiet callouts |
| PDF apparatus | `lectures/_pdf/` | Front page, contents, running heads, captions, black links, and handbook parts |
| Cross-format filter | `filters/course-apparatus.lua` | Solution visibility, glossary links, footnotes, and index entries |
| Course collection | `handbook.qmd` | Shared chapter bodies, course glossary, references, and index |

Generated files in `_site/`, `_freeze/`, or the root `handbook.pdf` are outputs,
not alternate sources. Edit the files in the table and rebuild.

### Quantitative snapshot

The figures below describe Session 1; they are not quotas for another session.

| Element | Session 1 |
|---|---:|
| Main numbered sections | 10 |
| Numbered subsections | 31 |
| Numbered equations | 24 |
| Chapter tables | 6 |
| Purpose-built teaching figures | 8 |
| Formal assumptions | 4 |
| Formal lemmas | 1 |
| Glossary definitions and linked terms | 38 |
| Explanatory footnote terms | 48 |
| Exercises | 10 |
| Exercise hints | 10 |
| Detailed solutions | 10 |
| Slides including title | 13 |
| Playground labs | 5 |
| Playground controls | 19 |

The chapter body is roughly 9,700 words. Its sentences average about sixteen
words, but the distribution matters more than the mean: compact claims sit next
to longer explanatory sentences, and short sentences are saved for distinctions
worth remembering.

### The intellectual spine

Session 1 is organized by a sequence of needs. Each answer exposes the next
question.

| Stage | Driving question | What the reader leaves with | Why the next stage follows |
|---|---|---|---|
| 1. The data problem | How can GDP be estimated before its first release? | Forecast/nowcast/backcast, two clocks, vintages, ragged edges | The information problem is clear; now the reader needs the smallest useful updating rule |
| 2. Scalar update | How much should one noisy release move an estimate? | Innovation, variance, gain, prediction, missing observations, signal-to-noise intuition | A release calendar breaks the scalar rhythm and requires notation that scales |
| 3. State-space model | How can several states and measurements be represented coherently? | Transition and measurement equations, dimensions, assumptions, filtered moments | The model is stated; its update must be derived rather than memorized |
| 4. Kalman filter | Where do the prediction and update equations come from? | Conditional-normal projection, full recursion, a hand calculation, initialization | The generic recursion still lacks the real-time data layer |
| 5. GDP implementation | How do calendars and mixed frequencies enter a production nowcast? | Selection matrices, monthly-to-quarterly aggregation, target extraction, uncertainty | A new nowcast has been produced; a user will ask why it changed |
| 6. News | Which releases moved the nowcast, and by how much? | Exact conditional contributions and simultaneous attribution | The attribution treated the model matrices as known; they must be estimated |
| 7. Estimation and diagnostics | How are parameters chosen, and how can a bad specification be detected? | Innovation likelihood, optimization, residual checks | Filtering deliberately ignores future observations, which raises the hindsight question |
| 8. Smoothing | How should later data revise earlier state estimates? | Filtered versus smoothed estimates and the backward projection | Real-time and hindsight objects must be kept distinct in evaluation |
| 9. Backtesting | Did the procedure work using only information available at the time? | Vintage replay, losses, benchmarks, and uncertainty in comparisons | The entire workflow can now be summarized and its limitation identified |
| 10. Handoff | What does the filter solve, and what does it leave open? | A production output checklist and the need for a multivariate economic model | Session 2 becomes the answer to a question already earned by Session 1 |

This dependency chain is more important than the table of contents. A section
does not exist because the syllabus says it is next; it exists because the
reader now has a question that the section can answer.

## The editorial voice

### Tone

The house voice is natural, sober, and academically confident. It assumes the
reader is intelligent but may be meeting the method for the first time. It does
not talk down to the reader, advertise its own clarity, or hide uncertainty
behind ornate language.

The characteristic balance is:

- formal enough to state assumptions and derive results exactly;
- concrete enough to keep release dates, units, and economic interpretation in
  view;
- conversational enough to pose real questions and read notation aloud; and
- restrained enough to distinguish what the model establishes from what the
  author is choosing or inferring.

“We” normally means author and reader reasoning together. “You” is reserved for
an instruction, a check, or a decision the reader can make. Assertions use
active, specific verbs: a release *arrives*, a covariance *widens*, a row
*selects*, an innovation *moves* the state. Abstract nouns do not carry a
paragraph when a concrete process can.

### The paragraph and section rhythm

A strong technical passage normally follows this rhythm:

1. **Motivate.** State the practical difficulty or question.
2. **Reduce.** Strip the situation to the smallest model that retains the
   difficulty.
3. **Formalize.** Introduce notation or an equation after the reader knows why
   it is needed.
4. **Read.** Translate the symbols, usually in the order a person would compute
   or reason through them.
5. **Interpret.** Return to economic meaning, units, direction, and magnitude.
6. **Check.** Use a limiting case, numerical example, figure, or unit test.
7. **Qualify.** State the scope of the claim and what would change outside it.
8. **Bridge.** End with the unresolved issue that motivates the next passage.

Not every paragraph contains all eight moves. A section generally does.

Session 1 often uses a compact bridge rather than a generic preview. Examples
include “For that we need a second clock,” “Between releases, the model still
has to move,” and “Those steps produce a revised number. The next question is
why.” These lines work because they name a real dependency. “In the next
section, we will discuss…” usually does not.

### Openings and endings

Open a session with a situation in which a decision must be made before the
desired target is observed. Session 1 uses the minute before and after an
economic release. The opening supplies a number, an event, and questions about
revision and uncertainty. It gives the reader a reason to care before naming
the Kalman filter.

Open a major section by recovering the unresolved question from the preceding
one. If a section “jumps right in,” the repair is rarely an extra summary. It is
usually one paragraph that explains why the current tools are insufficient.

End a section with both a result and a cost or limitation. End the session by
returning to the opening problem, inventorying what can now be produced, and
making the next session necessary. A teaser is weaker than a question whose
answer has become unavoidable.

### Sentences that sound authored rather than generated

Natural prose comes from judgment and specificity, not from sprinkling in
informality. The following practices matter:

- Vary cadence according to the claim. Use a short sentence when the contrast
  deserves force: “Neither date can replace the other.” Do not make every
  sentence the same medium length.
- Let one paragraph do one intellectual job. Avoid restating the same claim in
  an opening sentence, three bullets, and a closing sentence.
- Use the language of the subject. “The release is 0.8 percentage point below
  the model's expectation” is better than “This provides a valuable insight.”
- Prefer earned transitions over connective filler. “Row selection answers
  which observations are available, not which frequency they measure” creates
  the next problem. “Moreover” does not.
- Preserve qualifications that a human expert would care about: fixed model
  versus estimated parameters, exact arithmetic versus finite precision,
  model expectation versus survey consensus, reference period versus release
  date.
- Allow asymmetry. A difficult assumption may need three paragraphs; an easy
  one may need a sentence. Do not force every item into identical prose.
- Use questions only when the answer organizes what follows. A row of rhetorical
  questions used merely for energy quickly feels synthetic.
- Use parentheses, colons, semicolons, and dashes for their ordinary functions.
  Do not build an artificial voice from repeated em dashes or dramatic
  sentence fragments.

During the final style pass, remove or rewrite:

- generic announcements such as “This section delves into,” “It is important
  to note,” or “This comprehensive framework”;
- inflated adjectives such as “powerful,” “seamless,” “robust,” or “elegant”
  unless the sentence establishes the relevant property;
- false quotations, imagined reader reactions, and stage directions;
- conclusions that repeat the introduction without adding a limitation or
  handoff;
- strings of perfectly parallel three-item lists created for cadence rather
  than content; and
- claims of intuition that do not actually explain a mechanism.

This is not a banned-word exercise. A word is acceptable when it is the right
word. The test is whether each sentence advances the reasoning and whether an
expert could defend its precision.

### Citations and evidence

Cite a source when the prose relies on an external result, empirical value,
historical release, algorithm, or convention. Do not attach citations to every
definition merely to create the appearance of scholarship. Further reading is
curated by purpose: foundational treatment, implementation, a method used in
the chapter, or preparation for what comes next.

For a real-data example, record the series, units, transformation, reference
period, release date, vintage or retrieval date, and source. Distinguish a
historical first release, a later final estimate, and a current-vintage value.

## Presenting technical material

### Selecting the key lessons

A key lesson is not simply a topic mentioned in the source literature. It is a
change in what the student can explain, calculate, diagnose, or build after the
session. Promote an idea to the session's central spine when it meets several of
these tests:

- it answers the opening economic or empirical question;
- later course material depends on it;
- the student can state it in ordinary language as well as notation;
- it changes a modeling, data, or interpretation decision;
- it supports a meaningful counterfactual or diagnostic check; and
- an exercise can reveal whether the student actually understands it.

Classify candidate material as **essential**, **supporting**, or **extension**.
Essential lessons belong in the main dependency chain and learning outcomes.
Supporting material supplies a derivation, qualification, or implementation
detail. Extensions belong in a footnote, further reading, an extra exercise, or
a later session unless omitting them would make an essential claim misleading.

Each learning outcome should have evidence in at least two places: an
explanation plus a calculation, figure, exercise, or lab. Repetition across
media is useful when the medium changes the kind of understanding; repetition
of the same paragraph is not.

### Start scalar and concrete when possible

Session 1 postpones matrices until the reader understands one release. This is
not simplification for its own sake. The scalar case exposes the innovation,
its variance, the gain, and the posterior variance without allowing dimensions
to obscure the mechanism. The multivariate formulas then feel like a genuine
generalization.

Use the smallest model that preserves the conceptual difficulty. Introduce
greater generality when the previous representation fails to handle the next
real problem.

### Equation standard

Every consequential equation should answer four questions nearby:

1. What object is on the left-hand side?
2. What does each term on the right contribute?
3. In what order should the expression be read or computed?
4. What changes in an informative special case?

For a displayed derivation:

- state the source identity or assumption before manipulating it;
- show intermediate equalities when a student could not reproduce the jump;
- name the algebraic operation (“add and subtract,” “apply the chain rule,”
  “take the conditional covariance,” “complete the projection”);
- preserve dimensions when matrices first appear;
- interpret the final line in ordinary language; and
- verify a limiting or numerical case when practical.

“Read this equation from right to left” or “read the three lines as weight,
revise, learn” is useful because it supplies an action order. “It is easy to
show” is not an explanation.

Number an equation when it will be referenced later, anchors a derivation,
belongs in an exercise, or carries a named algorithmic step. Leave one-off
arithmetic unnumbered. Cross-reference the equation from prose; do not rely on
its visual proximity.

### Probability statements and conditioning

For every distribution, say what is random, what is conditioned on, what the
center means, and whether the second parameter is a variance, covariance, or
standard deviation. If units are transformed or annualized, state the units
before interpreting a number.

Conditional claims should name the conditioning set at least once. “The
variance falls” is incomplete if the result is conditional on a fixed model and
known parameters.

### Assumptions

An assumption is not complete when it has only a label and formula. For each
assumption, give:

- a plain-language meaning;
- the step in the derivation or algorithm that uses it;
- what becomes invalid or more difficult without it; and
- whether the assumption is a mathematical convenience, an identifying
  restriction, or an empirical claim.

Give assumptions stable anchors such as `#assumption-a3` and link every later
use. A figure may clarify a dependence assumption, but it does not replace the
prose consequence.

### Notation

Introduce notation when the corresponding object becomes necessary, then give
a compact reference table once the set is large enough to burden memory. A
notation table is a map, not an examination requirement. Include dimensions,
timing, conditioning, and units where ambiguity is likely.

Use the same symbols in notes, slides, exercises, solutions, figures, and labs.
If notation changes, update all six before release.

### Numerical examples

An anchor example should recur across media. Session 1's release update appears
in the notes, exercise workflow, slides, and first lab. This reduces setup time
and lets each medium deepen a familiar case.

A numerical example should contain:

- interpretable units and plausible values;
- the model belief before the observation;
- the realized observation and its surprise;
- the full calculation without hidden intermediate values;
- an interpretation of the mean and uncertainty separately; and
- at least one counterfactual, such as an expected release or noisier
  measurement.

Round for presentation only. Compute with unrounded values, say how displayed
values are rounded, and avoid feeding a rounded intermediate into later work
unless the example explicitly demonstrates hand arithmetic.

## Deciding what becomes apparatus

### Glossary, footnote, or ordinary prose

| Treatment | Use it when | Do not use it when |
|---|---|---|
| Glossary term | The phrase is durable course vocabulary, will recur, or names an object students should be able to define independently | The phrase is only a local algebraic convenience or a familiar word used technically once |
| Explanatory footnote | A local prerequisite, convention, qualification, or secondary method helps a reader continue without belonging to the main memory burden | The idea is necessary to understand the section's argument; then it belongs in the prose |
| Ordinary prose | The explanation is immediate, intuitive, and not a reusable named concept | A student will need to find or recall the definition later |
| Formal assumption or lemma | A stable claim is used in later reasoning and its scope matters | The statement is merely a definition or a prose observation |

A glossary definition should say both **what the object is** and **why it
matters or how it behaves**. Dictionary fragments are not enough. Mark the term
once, at the first meaningful use, with bold text and a stable `data-term` key.
Do not mark every repetition. Alphabetize the session glossary by its displayed
term so it remains useful as a reference page.

Example:

```markdown
[**innovation**]{.glossary-term data-term="innovation"}
```

The matching entry is:

```markdown
[Innovation]{.glossary-head data-term="innovation"}
: The observed release minus its conditional expectation just before it
  arrives. It is the portion of the observation that is new relative to the
  model's information set.
```

An explanatory footnote attaches to the term itself so HTML can expose the
same note on hover or focus while PDF places it at the foot of the page. Keep
the note concise enough to remain local. If it grows into an argument, promote
it to the body.

Before release, the sets of glossary-use keys and glossary-definition keys
must be identical. Session 1 deliberately keeps the authored definition as the
single source for the end glossary and web popup.

### Cross-references and links

Link whenever the reader may reasonably want to move to the supporting object:

- equations, figures, tables, sections, assumptions, and lemmas;
- the first marked use of every glossary term;
- exercises and their solutions companion;
- notes, slides, and playground when they offer complementary treatments; and
- course-level glossary and index destinations where the format supports them.

Links should remain visually quiet. On the web, normal site links may use the
site accent. In PDF, internal, citation, URL, and file links remain functional
but print in black.

### Figure, table, equation, or lab?

Choose the medium by the relationship the reader must see.

| Need | Best first choice |
|---|---|
| Exact values, notation mappings, release records | Table |
| Shape, timing, dependence, path, comparison, diagnostic pattern | Figure |
| A precise relationship to derive or reuse | Equation |
| A counterfactual whose result changes with inputs | Interactive lab |
| A single claim or interpretation | Prose |

Do not add a figure to decorate a long section. If its caption cannot state the
question the figure answers and the lesson visible in it, the figure probably
does not belong.

### The Session 1 figure set

The eight chapter figures cover eight distinct visual jobs:

| Figure | Visual job |
|---|---|
| Ragged edge | Show asynchronous availability as a staircase rather than arbitrary missingness |
| State variation versus measurement noise | Contrast movement of the latent path with scatter around it |
| Steady-state gain | Show the monotone response to the signal-to-noise ratio |
| Data outage | Show a sequence: skipped updates, widening uncertainty, and the return of information |
| State-space graph | Expose conditional dependence and connect it to an assumption |
| Aggregation weights | Make the five-month tent and its symmetry visible |
| Diagnostic patterns | Build a visual vocabulary for five different model failures |
| Filter and smoother | Compare real-time and hindsight paths and uncertainty bands |

Each follows the same compact contract:

1. prose poses the comparison or problem;
2. the figure displays the relationship;
3. the caption names both subject and conclusion; and
4. following prose extracts the implication and moves on.

Editable figure sources live beside committed `.svg` and `.pdf` versions. Use
SVG for HTML and PDF for LaTeX. Both must come from the same source and share
geometry, labels, colors, and data. The Session 1 palette uses a restrained blue
for the principal quantity, orange for contrast or observations, and muted gray
for scaffolding. Direct annotation is preferred to large legends. Axes and
grids are as light as comprehension permits.

Every web figure needs useful alt text. The alt text should describe the
relationship, not repeat “Figure showing…”. Captions belong above figures in
both formats and should interpret rather than merely inventory marks.

## Exercises, hints, and solutions

### Curating the set

The exercise sequence should retrace the chapter's dependency spine while
changing the kind of work asked of the student. Session 1 progresses through:

1. a release-calendar ledger and reproducibility;
2. a scalar hand update;
3. an implementation and missing-value unit test;
4. a derivation and signal-to-noise interpretation;
5. ragged-edge timing;
6. a fixed-target variance argument;
7. mixed-frequency aggregation;
8. news decomposition;
9. a real-vintage evaluation; and
10. optional state-space extensions and numerical stability.

The tags `[core]`, `[pencil]`, `[computational]`, `[data]`, and `[extra]` tell
students what kind of effort is expected. Use tags consistently; they are not
decoration.

An exercise belongs when it asks the student to perform or explain a move that
the session treats as central. Do not inflate the set with near-duplicate
arithmetic. Vary representation: words to notation, notation to calculation,
calculation to interpretation, code to unit test, and vintage records to an
evaluation design.

### Hint standard

A hint gives the first productive move, the relevant representation, or the
right diagnostic question. It should not reveal the final numerical result or
collapse all reasoning into a formula to substitute into.

Good hints often do one of the following:

- identify the state that must be carried into the next step;
- suggest a table, diagram, or conditioning set;
- name a limiting case to check; or
- separate two effects students are likely to conflate.

### Detailed-solution standard

A detailed solution is a miniature lesson, not an answer key. It should:

1. restate the relevant notation and plan;
2. show every consequential algebraic or computational step;
3. keep units and conditioning clear;
4. interpret the result conceptually;
5. check it with a special case, assertion, alternative derivation, or source
   record; and
6. identify a common mistake when one is predictable.

Code solutions should be runnable, avoid hard-coded intermediate answers, and
include assertions. Data solutions should retain provenance. If a table shows
rounded output, label it as rounded and compute from full precision.

The main notes website places collapsible hints and solutions beside each
problem. The main notes PDF omits them and links to the solutions companion.
The companion HTML collapses each stage; the companion PDF prints every hint
and solution in full. All four views must come from the same `exercises.qmd`.

## Slides

Slides are built after the notes, examples, and notation are stable. Their job
is to guide a live explanation and help the room know what to look at next.
They are not a smaller PDF chapter.

Session 1 uses thirteen slides including the title. The arc is:

- a release-morning hook;
- the forecast/nowcast/backcast distinction;
- the two clocks;
- three real-time data difficulties;
- the state-space unifier;
- prediction;
- updating;
- the practical value of the update;
- the local-level signal-to-noise result;
- the playground;
- the exercise workflow; and
- the question for Session 2.

Use one governing idea per slide. Prefer one equation, one table, one figure, or
one short progression over a wall of bullets. Fragments may stage a derivation,
but the final state of the slide must remain intelligible. Keep citations and
links when the audience may use the deck afterward.

Update the slides whenever the conceptual spine, notation, anchor example,
figure, key term, exercise workflow, or handoff changes. A purely typographic
or sentence-level correction in the notes does not require a slide edit unless
the corrected text is on a slide.

Inspect every slide at presentation size. A successful render does not detect
small type, cramped equations, or content hidden below the viewport.

## The playground

The playground is a sequence of experiments, not a dashboard and not a game.
Session 1's five labs match the conceptual chain:

1. one release and one Kalman update;
2. missing observations in a local-level filter;
3. reference periods and release-date vintages;
4. monthly-to-quarterly aggregation; and
5. a news decomposition.

Each lab uses the same learning loop:

1. a concise setup reconnects the lab to the notes;
2. **Predict before using the controls** asks about direction or invariance;
3. a small set of controls varies meaningful quantities with visible units;
4. a plot or table shows the exact consequence;
5. a reactive sentence interprets the current state;
6. controlled comparisons ask the learner to change one thing at a time; and
7. a collapsed explanation is opened only after the learner has committed to
   an answer.

Defaults should reproduce a familiar example when possible. Fixed random seeds
are pedagogical controls: if the learner toggles a missing observation, the
underlying simulated shocks should not also change. A comparison is causal only
when irrelevant variation remains fixed.

Use semantic labels, units, accessible controls, theme-aware colors, and
responsive plots. Hide implementation code in the student view. Reactive text
must explain the current output, not merely echo input values. The final lab
should ask the learner to explain the entire chain without relying on formulas
and should link back to the notes or exercises.

## Web, PDF, and handbook presentation

### Web notes

The web edition reads like a quiet digital chapter inside the larger course
site. Its defining elements are:

- a session kicker, large title, course line, and compact contents strip;
- a serif reading column with generous line height and a bounded measure;
- upright bold headings with hanging numbers;
- full-width vector figures and narrower interpretive captions;
- flattened, low-contrast callouts rather than colored teaching boxes;
- dotted-underlined glossary and footnote terms;
- accessible popovers on hover, keyboard focus, and click; and
- a typeface preference that does not alter the surrounding site chrome.

The popup definition is cloned from the glossary entry and the popup footnote
from the actual note. Never author a second tooltip definition in JavaScript.
The ordinary footnote list remains collected at the end of the web chapter, so
the popover is a convenient second route rather than the only route.

Check the page at a wide desktop width and a narrow mobile width, in light and
dark themes. Test a glossary term, a footnote term, a section link, a citation,
a PDF link, an exercise hint, and a detailed solution with both pointer and
keyboard navigation.

### Standalone PDF notes

The first page contains the session kicker, title, course line, and a ruled
contents panel with page numbers. The notes begin on page 2. The title page does
not say “Lecture notes” and does not show a date unless a future document has a
substantive reason to date itself.

The body uses:

- letter paper with the established margins;
- double spacing, no paragraph indentation, and modest paragraph spacing;
- small-caps running heads with a hairline;
- bold upright section headings;
- top captions at 86 percent of the text measure;
- footnotes at the bottom of the page where the term occurs;
- quiet white callouts; and
- functional links that print in black.

Render every page to images and inspect all of them. Look for overflow,
orphaned headings, stranded captions, unreadable figures, equation collisions,
long-table breaks, footnotes that overwhelm a page, and unexpected blank
pages. The front page and last glossary/reference pages deserve deliberate
inspection because source-only review misses their navigation role.

### Solutions PDF

The solutions companion has its own front page and contents. Hints and
solutions print in full. Long calculations and code should break across pages
without shrinking into illegibility. Tables may span pages, but their repeated
headers and column widths must remain readable. Whitespace is acceptable when
it preserves a coherent worked solution; accidental half-empty pages caused by
an avoidable float or table constraint are not.

### Course handbook

The handbook includes the same `_body.qmd`, not a copied chapter. It restarts
section numbering within each session, collects references, appends the course
glossary, and prints an index. Glossary and explanatory-footnote terms become
index entries through the shared filter.

Whenever a session body, glossary, footnote term, label, citation, or title
changes, render the handbook. Confirm that:

- the session's numbering matches the standalone notes;
- course-level cross-references resolve;
- the glossary contains the new terms once;
- the index contains useful page destinations rather than duplicate noise; and
- part dividers and the overall contents panel remain balanced.

## The efficient workflow

The main efficiency principle is simple: settle the intellectual structure once,
then let every format express that structure. Most wasted work comes from
designing the notes, slides, exercises, and interactive independently and
reconciling them late.

### Phase 0: audit before drafting

Read the existing session, its exercises, slides, playground, neighboring
sessions, and shared apparatus. Inventory user requests against the actual
source. Record broken references, duplicated definitions, unverified numbers,
and format-specific defects separately from editorial wishes.

Do not begin by rewriting paragraphs. First determine what is missing and what
already works.

### Phase 1: write the session brief

Before prose, complete this brief:

```text
Opening situation:
Decision or empirical question:
Target student and prerequisites:
Five or fewer learning outcomes:
Anchor numerical or data example:
Smallest useful model:
Dependency chain of sections:
Central notation:
Likely glossary terms:
Likely explanatory footnotes:
Candidate figures and the question each answers:
Exercise capabilities to test:
Candidate controlled experiments:
What this session deliberately postpones:
Question handed to the next session:
```

If the dependency chain cannot be expressed in one sentence per section, the
outline is not yet stable.

### Phase 2: maintain four ledgers

Keep four small planning tables while drafting:

1. **Concept and notation ledger:** symbol, meaning, dimensions, timing, units,
   first use, and later uses.
2. **Terminology ledger:** phrase, treatment (glossary/footnote/prose), stable
   key, definition or note, and first marked occurrence.
3. **Evidence and visual ledger:** claim, evidence or calculation, best medium,
   source, asset status, and cross-reference label.
4. **Assessment map:** learning outcome, exercise, mode of work, hint strategy,
   solution check, and any linked lab.

These ledgers prevent late searches for inconsistent symbols, orphaned terms,
decorative figures, and exercises that test something the chapter barely
taught.

### Phase 3: draft the notes as one argument

Draft the opening, section questions, and transitions before filling every
derivation. Then write the scalar or concrete case, followed by the general
case. At the end of each section, ask:

- What question has been answered?
- What remains impossible with the tools now available?
- Does that limitation genuinely motivate the next heading?

Write in the shared `_body.qmd`. Add stable labels as objects appear rather
than retrofitting them after cross-references proliferate.

### Phase 4: derive and verify

Work through every displayed derivation independently. Recompute numerical
examples with full precision. Check dimensions, signs, timing subscripts,
conditioning sets, and units. Add a unit test or limiting case before polishing
the prose around the result.

Only after the calculation is correct should the explanation be tightened.

### Phase 5: choose figures

For every proposed figure, write its one-sentence question and one-sentence
lesson. Drop figures that duplicate a table or prose claim. Build the editable
source and paired SVG/PDF outputs together, then place the figure between its
setup and interpretation.

### Phase 6: build exercises and solutions

Use the assessment map to cover the dependency spine without repeating the
same operation. Draft the problem first, then a hint that exposes only the
first move, then a solution that could teach a student who was stuck. Run every
calculation and code example.

### Phase 7: build controlled labs

Choose only relationships that benefit from counterfactual manipulation. For
each lab, fix its learning question and invariants before writing code. Add the
prediction prompt before the controls, not as an afterthought. Test defaults,
endpoints, missing-data states, and narrow screens.

### Phase 8: build slides last

Extract the lecture arc from the stable chapter. Decide what must be said aloud
and what the slide must display. Reuse notation and figures; do not
copy paragraphs. Add links to the playground and exercise workflow where they
will be used.

### Phase 9: build once, inspect by medium

Render the affected notes, solutions, slides, playground, and handbook. Source
sharing prevents textual drift, but each medium still needs its own inspection:
popovers and collapsing on the web; page breaks and footnotes in PDF; distance
legibility in slides; reactivity and invariants in labs.

### Phase 10: perform the authorial pass

Read the rendered chapter continuously, preferably aloud. Remove generic
openings, duplicated explanations, unnecessary headings, unearned transitions,
and sentences that advertise importance instead of establishing it. Check that
short sentences land on real distinctions and that questions receive answers.

This pass should come after technical correctness. Line editing unstable math
is wasted work.

### Phase 11: release deliberately

Run the automated audit, inspect all artifacts, review the diff, and render the
handbook. Deploy only with authorization. After deployment, open the live notes,
slides, playground, solutions, PDF downloads, and handbook link. Test at least
one interaction rather than checking only HTTP success.

### Safe parallel work

When a project has explicitly assigned multiple agents, parallel work becomes
useful only after the brief and conceptual spine are frozen. Good bounded
streams are source verification, figure production, numerical checking, and
exercise-solution validation. Keep one editorial owner for the chapter voice
and transitions. Do not have separate writers draft neighboring prose sections
without a final single-author pass; the seams are usually visible.

## Definition of done

A session is complete only when all relevant gates pass.

### Intellectual gate

- The opening creates a real need for the method.
- Learning outcomes match what the session actually teaches.
- Every main section has a purpose and an earned transition.
- Every important equation is derived or justified and then interpreted.
- Assumptions say what they do and what fails without them.
- The conclusion returns to the opening and earns the next session.

### Editorial gate

- The voice is specific, restrained, and consistent with the course.
- Technical terms are neither undefined nor over-marked.
- Glossary definitions explain significance, not only category.
- Footnotes remain local and do not hide necessary reasoning.
- Claims distinguish model conditions, data facts, and authorial choices.
- No generic filler, inflated language, or repetitive summary scaffolding
  remains.

### Mathematical and empirical gate

- Equations, dimensions, conditioning sets, timing, and units are correct.
- Numerical examples reproduce from full-precision calculations.
- Code examples run and include appropriate checks.
- Data examples retain release/vintage provenance.
- Captions, tables, and prose use the same numbers and terminology.

### Apparatus gate

- Glossary-use keys and definition keys match one for one.
- Footnote terms resolve to the intended notes.
- Equation, figure, table, section, assumption, exercise, and solution links
  resolve.
- Every figure has an interpretive caption, alt text, and paired SVG/PDF asset.
- The session glossary appears at the end; the handbook glossary and index are
  updated.

### Exercise gate

- The set covers the conceptual spine with varied modes of work.
- Every exercise has exactly one hint and one detailed solution.
- Hints reveal a first move, not the answer.
- Solutions show approach, steps, interpretation, and a check.
- Web collapsing and PDF inclusion/omission behave as designed.

### Presentation gate

- The web opener, contents strip, typography, callouts, captions, and responsive
  layout are intact.
- Glossary and footnote popovers work with hover, focus, and click.
- Every PDF page has been visually inspected; no clipping or accidental blank
  pages remain.
- The standalone notes begin on page 2 after the title/contents page.
- PDF links are functional and visually black.
- Every slide fits and is readable at presentation distance.
- Every lab loads, responds, preserves its intended invariants, and explains the
  current state.

### Release gate

- `scripts/audit_session.py` reports no errors.
- The affected files render locally without errors or unresolved references.
- The handbook renders after any shared-body or apparatus change.
- The diff contains source changes, not accidental generated or temporary
  files.
- If deployment was authorized, the live notes, solutions, slides, playground,
  PDF downloads, and handbook destination have been checked.

## Commands and practical checks

Run commands from the repository root. Replace paths with the session being
edited.

```bash
# Fast structural audit
python3 scripts/audit_session.py lectures/01-question-to-projection \
  --playground interactives/01-shock-to-response-explorer.qmd

# Rebuild a session's dual-format figures
bash lectures/01-question-to-projection/figures/build.sh

# Render the affected artifacts
quarto render lectures/01-question-to-projection/notes.qmd
quarto render lectures/01-question-to-projection/solutions.qmd
quarto render lectures/01-question-to-projection/slides.qmd
quarto render interactives/01-shock-to-response-explorer.qmd

# Rebuild the aggregated course handbook
quarto render handbook.qmd

# Full-site integration build
quarto render
```

Render PDFs to page images for inspection. Use a task-specific temporary
directory under `tmp/` and remove it after review.

The final review should answer one question: could a student move from the
opening situation, through the notation and derivation, into an exercise and a
controlled experiment, and then explain the result in ordinary economic
language? If not, the session may be rendered, but it is not finished.
