# Terminology plan

Glossary terms are course vocabulary. Each term is **owned** by the lecture
that introduces it, marked there once with `[**term**]{.glossary-term
data-term="key"}`, and defined once in that lecture's `glossary.qmd`. The
audit script requires every marked key in a lecture to have a definition in
that lecture's glossary and vice versa.

Rules for later lectures:

1. If a term owned by an earlier lecture is used again, write it as ordinary
   prose (no span). Link to the owning lecture's glossary section if a reader
   may want the definition, e.g. `[local projection](../01-question-to-projection/notes.qmd#sec-l01-glossary)`.
2. If a later lecture needs to *re-define* an earlier term with materially more
   content, mark it as a glossary term in the body and wrap the definition in
   `::: {.course-glossary-duplicate}` in the glossary so the handbook keeps
   only the first course definition. Use this sparingly.
3. Keys are kebab-case, stable, and unique across the course. The lists below
   are allocations, not quotas; a lecture may add keys it needs, but it must
   not use a key owned elsewhere.
4. Explanatory footnotes (`.footnote-term`) are local and are not tracked
   here.

| Lecture | Owned glossary keys |
|---|---|
| 01 | impulse-response-function, local-projection, horizon, calendar-time, intervention-variable, observed-shock, counterfactual, causal-response, realized-path, estimand, projection-coefficient, estimation-sample, lead, lag, regression-row, impact-response, population-projection, persistence, autoregressive-process, response-graph |
| 02 | level-response, long-difference, first-difference, cumulative-response, same-regressor-equivalence, telescoping-identity, percentage-point, percent-change, log-approximation, shock-normalization, common-sample, horizon-specific-sample, trend-normalization, small-sample-bias, monte-carlo-simulation, statistical-reproduction |
| 03 | identification, identifying-assumption, structural-shock, policy-action, policy-surprise, proxy, confounder, omitted-variable-bias, anticipation, predetermined-control, post-treatment-control, mediator, partialling-out, frisch-waugh-lovell, recursive-identification, information-set, predictability-test, specification-record, conditional-exogeneity, timing-convention |
| 04 | instrument, external-instrument, endogenous-regressor, relevance, exogeneity, exclusion-restriction, lead-lag-exogeneity, first-stage, reduced-form, two-stage-least-squares, lp-iv, wald-ratio, weak-instrument, robust-f-statistic, cumulative-multiplier, one-step-multiplier, two-step-multiplier, delta-method, anderson-rubin-test |
| 05 | confidence-interval, coverage, nominal-coverage, achieved-coverage, heteroskedasticity, serial-correlation, hac-estimator, newey-west, bandwidth, lag-augmentation, heteroskedasticity-robust, score, martingale-difference, overlapping-residuals, interval-width, monte-carlo-uncertainty, unit-root, size-distortion |
| 06 | cross-horizon-covariance, pointwise-band, simultaneous-band, sup-t-band, bonferroni-band, joint-hypothesis, wald-test, significance-band, multiplicity, curve-difference-test, stacked-regression, family-wise-error-rate, accumulated-response-uncertainty |
| 07 | vector-autoregression, direct-estimation, iterated-estimation, population-equivalence, invertibility, bias-variance-tradeoff, mean-squared-error, misspecification, lag-length, bias-correction, shrinkage, model-averaging, data-generating-process |
| 08 | unrestricted-lp, basis-function, gaussian-basis-function, b-spline, penalized-regression, roughness-penalty, tuning-parameter, cross-validation, shape-restriction, nonlinear-least-squares, restricted-estimation, unimodality |
| 09 | state-dependence, state-indicator, interacted-lp, main-effect, state-specific-control, support, threshold, sign-asymmetry, fixed-state-experiment, initial-state-response, endogenous-state, direct-difference-test, kitagawa-oaxaca-blinder, specification-search |
| 10 | marginal-effect, finite-shock-effect, causal-weight, weighted-average-effect, shock-distribution, nonlinear-response-function, linear-approximation, negative-weights, policy-relevant-effect |
| 11 | panel-local-projection, unit-fixed-effect, time-fixed-effect, common-shock, exposure, exposure-interaction, cross-sectional-dependence, clustered-standard-errors, driscoll-kraay, effective-sample-size, nickell-bias, heterogeneous-response, conditional-comparison, financial-recession |
| 12 | staggered-adoption, absorbing-treatment, treatment-cohort, event-time, clean-control, not-yet-treated, already-treated, forbidden-comparison, parallel-trends, no-anticipation, variance-weighted-ate, equally-weighted-ate, reweighting, pre-trend, two-way-fixed-effects, nonabsorbing-treatment |
| 13 | sensitivity-analysis, specification-grid, influential-episode, leave-one-out, sample-window, counterfactual-path, policy-invariance, lucas-critique, conditional-forecast, policy-experiment, assumption-dependent-interpretation, unsupported-claim |
| 14 | methods-section, discrepancy-log, replication-audit, numerical-tolerance, null-result, reproducibility-package, master-do-file, referee-report, defense, consequential-choice |

Stable anchor conventions (also in the notation ledger): sections
`#sec-lNN-slug`, equations `#eq-lNN-slug`, figures `#fig-lNN-slug`, tables
`#tbl-lNN-slug`, exercises `#exercise-lNN-K`, assumptions
`#assumption-lNN-aK`, the lecture glossary `#sec-lNN-glossary`, and the
exercises heading `#sec-lNN-exercises`.
