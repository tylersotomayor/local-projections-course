# Course spine

This document freezes the intellectual architecture of the fourteen lectures
before any prose is multiplied across formats. Each lecture entry records the
opening situation, the guiding question, the dependency chain of sections (one
sentence per section, each earned by the previous one), the anchor examples,
what the lecture deliberately postpones, and the question it hands to the next
lecture. Lecture authors work from this spine and the
[notation ledger](notation-ledger.md), and the [editor decisions](editor-decisions.md); they may refine section titles but may
not reorder the chain or move an idea to a different lecture without updating
this file.

The course follows one sequence: question → estimand → identification →
estimation → inference → interpretation → evaluation. Four parts:

| Part | Lectures | What the student can do afterwards |
|---|---|---|
| I. Define and identify the dynamic effect | 1–4 | State an estimand, build the regression, argue identification, use an instrument |
| II. Evaluate estimation and uncertainty | 5–8 | Choose and defend an inference procedure, compare estimators, restrict responsibly |
| III. Heterogeneity, nonlinearity, panels | 9–12 | Interpret interacted, nonlinear, panel, and staggered-treatment designs |
| IV. Use and defend LP evidence | 13–14 | Bound the conclusions, reproduce someone else's work, survive an audit |

## Recurring empirical anchors

A small set of real datasets recurs so that later lectures deepen familiar
cases rather than restarting. Whether a dataset ships inside a lab project or
is fetched by an acquisition script follows editor decision D5; every copy
carries its provenance. Validated benchmarks for each target are in
`~/macro/local_projections/replication-packages/benchmarks/`.

| Anchor | Source | Used in |
|---|---|---|
| **Fiscal.** U.S. quarterly data 1889Q1–2015Q4: real GDP and government spending as ratios to trend GDP, the military-news shock, the Blanchard–Perotti shock, unemployment, and the slack and ZLB indicators | Ramey and Zubairy (2018) replication package (`RZDAT.xlsx`, sheet `rzdat`; frozen at `replication-packages/packages/ramey-zubairy/supplied-local-copy/`; portable pilot at `replication-packages/pilots/REP04/`) | L1, L2, L4, L9, L13 |
| **Monetary, shelter prices.** Monthly log shelter PCE price (cumulative response, percent) and the Bauer–Swanson (2023) monetary policy surprise, 1988m1–2019m12; specification fixed by editor decision D7 | Inoue, Jordà, and Kuersteiner (2026), August 13, 2024 official archive (`replication-packages/packages/econometrics-journal/author-20240813/`; benchmark `REP03-shelter-prices-author-20240813.csv`) | L3, L5, L6 |
| **Monetary, unemployment.** Monthly U.S. unemployment rate, PCE inflation, federal funds rate, and the Romer–Romer shock extended by Coibion, Gorodnichenko, Kueng, and Silvia (2017) | Jordà and Taylor (2025) `Example6_JointInference/data_fred.dta` and `Example8_Counterfactuals` (local copy at `~/JEL-Code-main 3/LP_JEL_Replication/`) | L6, L8, L13 |
| **Macrohistory panel.** The historical *When Credit Bites Back* panel (`panel14_1_oj.dta`, 1870–2008) for the replication; JST release 6 only for labeled extensions (D16) | `replication-packages/packages/macrohistory/historical-original/` and `.../macrohistory/` R6 | L11 |
| **Ramey HOM shock series.** Government spending, monetary, tax, and technology shocks from Ramey's Handbook chapter | Kolesár and Plagborg-Møller replication repository (`~/macro/local_projections/upstream/nonlinear_dynamic_causal/data/`) | L10 |

Simulations are the second kind of anchor. Every simulation in the course is
deterministic: a stated seed, a stated design, and a stated number of
replications. When a classroom run uses fewer replications than a published
study, the notes call it a *statistical reproduction*, never a replication.

---

## Part I — Define and identify the dynamic effect

### Lecture 1 — From an economic question to a local projection

**Guiding question.** How does a regression coefficient become one point on an impulse-response function?

**Opening situation.** June 1950. The Korean War begins, newspapers report large planned increases in military spending, and a policymaker asks what will happen to output over the next three years. The realized path of GDP after 1950Q3 is one draw; other things happened during those years. The question is not "what happened next" but "what happened *because of* the news," and answering it requires a counterfactual we never observe.

**Dependency chain.**

1. *The question.* Shock, outcome, and the no-shock counterfactual; the causal response is a difference between two paths, not a difference from the pre-shock level.
2. *Two clocks.* Calendar time $t$ dates the intervention; horizon $h$ counts periods after it; an impulse-response function is a function of $h$, and a single coefficient is one point on it.
3. *The smallest model.* An AR(1) outcome with an observed exogenous shock, $y_t=\rho y_{t-1}+\theta_0 s_t+v_t$, whose response $\theta_h=\theta_0\rho^h$ can be derived by iterating forward; the counterfactual difference is exact here.
4. *From the model to a regression.* Substituting forward gives $y_{t+h}=\theta_h s_t+\rho^{h+1}y_{t-1}+(\text{future shocks})$, which is a regression of $y_{t+h}$ on $s_t$ and $y_{t-1}$ with a composite error orthogonal to both regressors; this is the local projection, and $\beta_h=\theta_h$.
5. *Why many shock dates.* The coefficient averages across every date at which a shock occurred; one episode cannot separate the shock from everything else that happened, and the estimation sample $\mathcal T_h$ shrinks by one row per horizon.
6. *Building the rows by hand.* A twelve-period table with $h=0,1,2$ makes the leads, the lost rows, and the OLS arithmetic visible before any loop.
7. *Reading the response graph.* Units of $s$, units of $y$, the intercept, and the horizon axis; a caption that names intervention, units, and counterfactual.
8. *What the residual contains.* $u_{t,h}$ is a sum of the shocks between $t+1$ and $t+h$, so it is serially correlated by construction; this is noted, not solved.
9. *First contact with data.* The military-news shock and GDP relative to trend, estimated as in the toy model, with the honest statement of what has not yet been argued: units, controls, and identification.
10. *Handoff.* The regression used the level of $y$; a differenced outcome looks like a different answer, and the next lecture asks whether it is.

**Anchor examples.** The twelve-period hand table (simulated with seed 1, $\rho=0.5$, $\theta_0=1$); the AR(1) Monte Carlo at $\rho\in\{0.5,0.9\}$, $T=200$; the RZ military-news response of GDP.

**Figures (question each answers).** Realized versus counterfactual paths (what is the response?); regression-row staircase (which rows enter the $h=2$ regression?); $\theta_h=\theta_0\rho^h$ for two $\rho$ (how does persistence shape the response?); one-sample LP estimates against the truth (how noisy is one draw?); estimation-sample size by horizon (what does $h$ cost?).

**Postpones.** Transformations and units (L2), identification and controls (L3), standard errors (L5).

**Handoff question.** If we regress $y_{t+h}-y_{t-1}$ instead of $y_{t+h}$, is the answer different, or the same answer in different clothes?

### Lecture 2 — Levels, differences, cumulative responses, and units

**Guiding question.** When does changing the dependent variable change the estimand, and when is it merely a reparameterization?

**Opening situation.** One dataset gives four numbers for the response of output to military-spending news in Ramey and Zubairy's quarterly data: 0.29, the peak of the level response; 1.76, the same peak per one-standard-deviation shock; 3.53, the sum of level responses through quarter 20; and 0.73, that sum divided by spending's. None contradicts another. The reader who cannot say what each axis measures will think they do.

**Dependency chain.**

1. *Four dependent variables.* $y_{t+h}$, $y_{t+h}-y_{t-1}$, $\Delta y_{t+h}$, and $\sum_{j=0}^{h}y_{t+j}$ each answer a different question, and the units of $\beta_h$ change accordingly.
2. *The same-regressor equivalence.* If $y_{t-1}$ is a regressor, subtracting it from the dependent variable leaves every other OLS coefficient unchanged (the coefficient on $y_{t-1}$ falls by exactly one); the proof is three lines of OLS algebra and the conditions are identical regressors and identical rows.
3. *The telescoping identity.* $y_{t+h}-y_{t-1}=\sum_{j=0}^{h}\Delta y_{t+j}$ links the long-difference LP to the sum of period-change LPs in population; in finite samples the period-change regressions use different rows, so the sums need not agree.
4. *Accumulating changes is not accumulating levels.* The cumulative response $B_h=\sum_{j\le h}\theta_j$ answers "how much output in total," which is what a multiplier needs; the level response $\theta_h$ answers "how much output at $h$."
5. *Units.* Percent (logs × 100) versus percentage points; normalization of the shock to one unit, one standard deviation, or one percent of GDP; rescaling $s_t$ by $c$ divides $\hat\beta_h$ by $c$ and leaves the response to the same economic intervention unchanged.
6. *When the equivalence fails.* Jordà–Taylor's Example 1: with $\rho$ near one and $T=100$, a levels LP and a long-differences LP that do not share regressors can differ in bias; the Monte Carlo is reproduced at reduced replications and labeled as such.
7. *Common versus horizon-specific samples.* Fixing the sample at $\mathcal T_H$ for every $h$ makes coefficients comparable across horizons at the cost of rows; the choice is recorded, not defaulted.
8. *The fiscal anchor's units.* Ramey–Zubairy divide GDP and spending by trend GDP so that both responses are in percent of trend GDP and their ratio is dimensionless; a reader must know this to read their axes.
9. *Handoff.* Every transformation defines what is analyzed; none of them establishes the no-shock counterfactual.

**Anchor examples.** One simulated AR(1) path shown under all four transformations; the same-regressor equivalence verified numerically with an assertion; the JT Example 1 reproduction at $\rho\in\{0.95,1.00\}$; the RZ cumulative variables `f`i'cumuly`.

**Figures.** Four transformations of one response; identical fits under the equivalence; Monte Carlo bias by horizon for levels and long differences at two $\rho$; one response on three axes (units).

**Postpones.** Identification (L3), inference for accumulated responses (L6).

**Handoff question.** Which of these regressions, if any, estimates a causal effect?

### Lecture 3 — Identification, controls, and the pre-shock information set

**Guiding question.** What makes an estimated dynamic relationship causal?

**Opening situation.** An FOMC statement is tighter than markets expected. Rents are set in leases and move slowly. Does a monetary surprise lower shelter prices, and when? The regression of future shelter prices on today's surprise looks exactly like the regression of future prices on today's federal funds rate. One of them can carry a causal reading and the other cannot; the lecture is about the difference.

**Dependency chain.**

1. *Four right-hand variables.* A policy action, a surprise, a structural shock, and a noisy proxy make different demands; each is an instance of $s_t$ with a different relation to $\varepsilon_t$.
2. *The identifying assumption.* $\beta_h=\theta_h$ requires $s_t$ to be uncorrelated with $u_{t,h}$ given $\mathbf w_t$; the operational content is that $s_t$ is unpredictable from $\Omega_{t-1}$ and uncorrelated with the other shocks that move $y_{t+h}$ (assumptions A1–A3 with anchors).
3. *Confounding.* An omitted common cause of $s_t$ and $y_{t+h}$ produces the omitted-variable bias formula for $\beta_h$; the sandbox simulation shows the coefficient drifting from the known effect as the confounder strengthens.
4. *Anticipation.* If agents respond before $t$, $s_t$ is not news, $y_{t-1}$ has already moved, and the response is mistimed and attenuated; predictability regressions of $s_t$ on $\Omega_{t-1}$ are the diagnostic.
5. *Predetermined versus post-treatment controls.* Controls must belong to $\Omega_{t-1}$; a control dated $t$ or later that responds to $s_t$ is a mediator and changes the estimand to a direct effect, or biases it; the exception is recursive identification, where contemporaneous variables ordered before the shock are included deliberately and the ordering is the assumption.
6. *Partialling out.* Frisch–Waugh–Lovell: the shock coefficient equals the slope of residualized $y_{t+h}$ on residualized $s_t$, which both verifies a specification and is how the reference code estimates.
7. *Frequency, zeros, and missing.* A shock series that is zero outside announcement dates says "no news"; a missing value says "unknown" and drops the row; misaligned dates silently shift the horizon.
8. *The specification record.* Shock, outcome, controls, sample, timing, and normalization written down once, so that the identification argument can be audited.
9. *The shelter anchor.* Reproduce the point estimates of the IJK cumulative shelter-price response (D7, D8), audit its timing and sample, and write the identification memo.
10. *Handoff.* When the shock itself is not observed but an instrument for it is.

**Anchor examples.** The three-mechanism sandbox economy (confounder, anticipation, mediator) with a known $\theta_h$; IJK Figure 4 point estimates.

**Figures.** Timeline of confounding, anticipation, and mediation; bias against confounder strength; predictability test; reproduced shelter response.

**Postpones.** Instruments (L4), standard errors (L5), interpretation of the bands in IJK (L6).

**Handoff question.** How can a variable that is correlated with the shock but not the shock itself identify a response?

### Lecture 4 — LP-IV and cumulative multipliers

**Guiding question.** How can an external instrument identify a response, and how does that response become a multiplier?

**Opening situation.** Government spending responds to the state of the economy, so its regression coefficient is not a spending effect. Ramey and Zubairy use professional forecasts and newspaper accounts of military buildups to isolate the part of spending that is news about defense, not a reaction to output. The multiplier question is then: for each dollar of spending caused by that news, how many dollars of output?

**Dependency chain.**

1. *The endogenous regressor.* Why $\beta_h$ from regressing $y_{t+h}$ on spending is not a spending effect.
2. *Instrument conditions.* Relevance, contemporaneous exogeneity, and lead–lag exogeneity (Stock–Watson), and how lagged controls substitute for lead–lag exogeneity when it fails.
3. *The LP-IV estimand.* The ratio of two reduced-form projections, $\operatorname{Cov}(y_{t+h},z_t\mid\mathbf w_t)/\operatorname{Cov}(s_t,z_t\mid\mathbf w_t)$, and its 2SLS implementation horizon by horizon.
4. *First stages.* One per horizon because the sample changes; the robust $F$; what "weak" means for the bias and the distribution of the ratio.
5. *From responses to a multiplier.* $M_H=B^Y_H/B^G_H$; the two-step ratio of accumulated responses versus the one-step 2SLS of accumulated output on accumulated spending instrumented by news; why the one-step standard error is the honest one.
6. *When the denominator is small.* A ratio of two estimates is unstable when the denominator is imprecise; a simulation shows the multiplier's sampling distribution fattening and shifting.
7. *Units and normalization.* Both responses in percent of trend GDP makes the multiplier dimensionless; a per-unit normalization of the instrument does not change it.
8. *Relevance is not validity.* A large $F$ says the instrument moves spending; it says nothing about whether it moves output only through spending.
9. *The fiscal anchor.* Reproduce the RZ linear cumulative multipliers (military news, full sample, four lags) and reconstruct numerator, denominator, and units.
10. *Handoff.* Every band drawn so far has been decorative; the next lecture asks what a band promises.

**Anchor examples.** RZ linear multipliers; a simulated IV economy with adjustable instrument strength and contamination.

**Figures.** First-stage scatter; output and spending responses; multiplier schedule; ratio instability under a weak denominator; LP-IV as a ratio of two reduced forms.

**Postpones.** Coverage (L5), state dependence (L9), weak-IV-robust inference beyond a mention (Anderson–Rubin as further reading).

**Handoff question.** The confidence interval around a multiplier is a claim about repeated samples. Is it true?

## Part II — Evaluate estimation and uncertainty

### Lecture 5 — Pointwise inference, persistence, and lag augmentation

**Guiding question.** How reliable is the confidence interval at one horizon?

**Opening situation.** Two researchers estimate the same response from the same data and report the same points. One draws Newey–West bands; the other draws heteroskedasticity-robust bands from a regression with one extra lag. On the shelter anchor the Newey–West band is up to 1.65 times as wide, at month 48, and most of that gap comes from Newey–West versus heteroskedasticity-robust errors rather than from the extra lag. Both cite a theorem. The only way to adjudicate is to ask what a band promises and then check whether it delivers.

**Dependency chain.**

1. *What an interval promises.* Coverage in repeated samples; nominal versus achieved; a narrow interval is not a reliable one.
2. *Where dependence comes from.* $u_{t,h}$ is MA($h$) by construction and heteroskedastic in practice; the overlap grows with $h$.
3. *HAC inference.* The Newey–West estimator, the bandwidth $m$, the $m=h$ convention, and the small-sample distortion when $\rho$ is near one.
4. *Residuals versus scores.* Inference on $\beta_h$ depends on the autocorrelation of $s_t u_{t,h}$, not of $u_{t,h}$; when $s_t$ is unpredictable, the score is uncorrelated at the lags that matter.
5. *Lag augmentation.* Adding one lag of $y$ beyond what identification needs makes the regressor of interest behave like an innovation, so HC standard errors are valid even under persistence and at long horizons (Montiel Olea–Plagborg-Møller); the conditions are stated exactly, including what the January 2026 corrigendum changed.
6. *Evidence.* Coverage of Newey–West and lag-augmented intervals across $\rho$, $T$, and $h$ in a bivariate design (JT Example 4 and IJK Figure 2).
7. *Width and reliability.* The lag-augmented interval is often wider; that is the price of coverage, and the Monte Carlo separates the two.
8. *Scope.* What extends to IV, nonlinear, and panel designs and what does not; "LP means Newey–West" is not a rule.
9. *Handoff.* Every statement so far is about one horizon; most claims in papers are about several.

**Anchor examples.** The bivariate VAR(1) design of JT Example 4 ($T=300$, $a_{yy}=a_{xx}=0.85$); IJK Figure 2; a coverage simulator with a known economy.

**Figures.** Autocorrelogram of $u_{t,h}$; coverage by horizon for the two procedures; width against coverage; a hit-or-miss panel of repeated samples.

**Postpones.** Simultaneous bands (L6), bootstrap methods (further reading).

**Handoff question.** If each of five intervals covers with probability 0.95, what is the probability that all five do?

### Lecture 6 — Inference about the response path

**Guiding question.** What changes when the claim concerns several horizons rather than one?

**Opening situation.** A paper states that "the response is negative throughout the first year." That sentence names five horizons. If those horizons were fixed before estimation, five one-sided pointwise tests combined by the intersection–union rule support it at level $\alpha$. If the window was chosen after seeing the estimates, or the claim is "different somewhere", pointwise bands used five times do not, and the reader cannot tell by how much.

**Dependency chain.**

1. *Three claims.* Negative at month six; negative at every horizon in $\mathcal H$; different somewhere; each is a different null hypothesis and needs a different procedure.
2. *The joint distribution.* The stacked vector $\hat{\boldsymbol\beta}$ and its cross-horizon covariance $\boldsymbol\Sigma$; how to estimate $\boldsymbol\Sigma$ from stacked regressions or joint GMM.
3. *Pointwise versus simultaneous coverage.* The multiplicity problem, the Bonferroni band, and the sup-$t$ band with critical value $c_{1-\alpha}$ computed from $\boldsymbol\Sigma$ (Montiel Olea–Plagborg-Møller 2019).
4. *Joint tests.* A Wald test over a pre-specified horizon set; what it does and does not say about individual horizons.
5. *Differences between curves.* A direct test with the covariance of the difference; why overlapping bands and star-counting are not tests.
6. *Accumulated responses.* $\operatorname{Var}(\sum_h\hat\beta_h)=\sum_h\sum_k\operatorname{Cov}(\hat\beta_h,\hat\beta_k)$, so a cumulative multiplier's uncertainty needs the whole matrix.
7. *Significance bands.* IJK's bands under the null of no response; what they answer and how they differ from confidence bands.
8. *Evidence.* IJK Figure 3 reproduced exactly on its simulated design (Newey–West pointwise versus sup-$t$), then a course-built sup-$t$ band on the shelter anchor, labeled as an extension (D10).
9. *Handoff.* Two methods that target the same response can still disagree in a sample.

**Anchor examples.** IJK Figure 3 (simulated design) and the shelter anchor of D7; the JT Example 6 unemployment response to the Romer shock (joint LP-IV); a claims-and-procedures matcher.

**Figures.** Pointwise and simultaneous bands on one response; the multiplicity calculation; a difference-of-curves test versus overlapping bands; accumulated-response variance decomposition.

**Postpones.** Bootstrap bands, Bayesian LPs (further reading).

**Handoff question.** Why can an LP and a VAR fitted to the same data give different responses when they estimate the same object in population?

### Lecture 7 — LPs versus VARs: estimands, bias, and variance

**Guiding question.** Why can two methods targeting the same response produce different estimates?

**Opening situation.** Two papers use the same monthly data and the same identifying assumption. One fits a VAR and iterates; the other runs local projections. Their responses differ at every horizon past six months. Neither has made an error.

**Dependency chain.**

1. *Same estimand.* Plagborg-Møller–Wolf: with unrestricted lags, the LP and the VAR estimate the same impulse response in population, and every LP identification scheme has a VAR counterpart.
2. *Different estimators.* Direct estimation projects $y_{t+h}$ on $s_t$; iterated estimation projects one step ahead and extrapolates through the lag structure.
3. *Bias and variance.* The VAR extrapolation reduces variance and adds bias when the lag structure is wrong; the LP has the opposite profile; MSE weighs them.
4. *Lag length and sample size.* How each estimator responds to more lags and more data; when the two converge.
5. *Coverage.* Point-estimation performance and interval performance are different criteria and can rank the methods differently.
6. *Thousands of DGPs.* Li–Plagborg-Møller–Wolf's simulation design, its main findings, and the estimators between the two poles (shrinkage, penalized LP, model averaging).
7. *A bounded port.* A small, instructor-validated Stata reproduction of a handful of designs, with what it can and cannot claim.
8. *Handoff.* Reducing variance by restricting the response's shape.

**Anchor examples.** A two-variable ARMA design where the VAR(1) is misspecified; the ported subset of LPW designs.

**Figures.** LP and VAR estimates against the truth from one sample; bias and variance by horizon; MSE ranking as the DGP changes; coverage by method.

**Postpones.** Bayesian VARs, structural identification beyond recursive and IV.

**Handoff question.** What do we gain, and what do we assume, when we tell the estimator the response must be smooth?

### Lecture 8 — Smoothing and restrictions across horizons

**Guiding question.** What do we gain, and assume, when we restrict the shape of the response?

**Opening situation.** An unrestricted LP of unemployment on a monetary shock rises, dips, rises again, and crosses zero twice in forty-eight months. A referee asks whether the second hump is a finding or noise. The estimator, as written, cannot answer, because it treated every horizon as a free parameter.

**Dependency chain.**

1. *The unrestricted LP as $H+1$ parameters.* Freedom is variance.
2. *Low-dimensional bases.* Jordà–Taylor's Gaussian basis $\beta_h=a\exp(-(h-b)^2/c^2)$: three parameters, estimated by nonlinear least squares or GMM, with standard errors that condition on the shape.
3. *Penalized splines.* Barnichon–Brownlees: a B-spline basis with a roughness penalty $\lambda$, chosen by cross-validation; ridge-like shrinkage toward a polynomial.
4. *What each restriction imposes.* Unimodality and symmetry for the Gaussian basis; local smoothness for the spline; neither can represent a shape it excludes.
5. *Misspecification.* A true response with a second hump or a sign reversal under each estimator; what the fitted curve does and what the reported uncertainty omits.
6. *Uncertainty after restriction.* Standard errors are conditional on the restriction; a wrong restriction gives confident wrong answers.
7. *Evidence.* JT Figure 6: unrestricted versus Gaussian-basis unemployment responses.
8. *Handoff.* Heterogeneity across states of the economy.

**Anchor examples.** JT Example 6 (urate, Romer shock, GBF); a simulated response with a second hump.

**Figures.** Unrestricted and Gaussian-basis fits on one response; basis functions; penalty path for the spline; misspecification under each estimator.

**Postpones.** Bayesian shrinkage; MIDAS-type restrictions.

**Handoff question.** Is the response the same in a recession as in an expansion, and what would "the same" even mean?

## Part III — Heterogeneity, nonlinearity, and panel designs

### Lecture 9 — State dependence and asymmetric responses

**Guiding question.** Does the response depend on the initial state or the direction of the shock?

**Opening situation.** The multiplier debate after 2009 was about slack: is spending more effective when unemployment is high? Ramey and Zubairy split their century of data by a 6.5 percent unemployment threshold and estimate two multipliers. The estimate is easy; saying what it means is not.

**Dependency chain.**

1. *The interacted LP.* State-specific intercepts, shock coefficients, and controls; why the main effects and state-specific controls are required.
2. *The estimand.* A response conditional on the state at $t-1$, during which the state may change; this is not the response of an economy held in that state (Gonçalves–Herrera–Kilian–Pesavento).
3. *Support.* How many shocks, and how large, occur within each state; a state with three shocks identifies little.
4. *The direct test.* $\beta^A_h-\beta^B_h$ with its standard error, not two bands.
5. *Sign asymmetry.* $s^+_t$ and $s^-_t$; the same logic, a different partition.
6. *Thresholds.* Alternative definitions as labeled sensitivity, not as a search for a preferred result.
7. *Decomposing the difference.* Jordà–Taylor's Kitagawa–Oaxaca–Blinder decomposition of state differences into coefficient and composition components.
8. *Evidence.* RZ slack versus non-slack multipliers with the original state definition.
9. *Handoff.* When the response depends on the shock's size, a linear coefficient is an average of something; of what?

**Anchor examples.** RZ Table 1 state-dependent column; the KOB simulation of JT Example 9.

**Figures.** State-specific responses with the difference; shock support by state; fixed-state versus initial-state experiments in simulation; threshold sensitivity.

**Postpones.** Regime-switching models; nonlinear estimation.

**Handoff question.** If large shocks and small shocks have different effects, what does one linear coefficient measure?

### Lecture 10 — What linear LPs mean in nonlinear economies

**Guiding question.** What causal effect does a linear coefficient summarize when responses vary with shock size?

**Opening situation.** A monetary shock series is skewed: a few large easings, many small tightenings. If the economy responds more to large shocks than to small ones, the linear LP coefficient is a weighted average whose weights the researcher never chose. Kolesár and Plagborg-Møller show how to compute them.

**Dependency chain.**

1. *A nonlinear response.* $\theta_h(e)$ as a function of the shock size; marginal versus finite-sized effects.
2. *The good.* With an observed exogenous shock, $\beta_h=\int\omega_h(e)\theta_h(e)\,de$ with nonnegative weights that integrate to one; the weights are computable from the shock's distribution.
3. *The bad.* Kolesár and Plagborg-Møller's label for identification through heteroskedasticity; the Lecture 10 brief §1 records what the linear estimand does and does not retain there.
4. *The ugly.* Their label for identification through non-Gaussianity, with the same treatment.
5. *Computing the weights.* From a shock series to $\omega_h(e)$, following the authors' Stata sequence.
6. *Changing the distribution versus changing the response.* Holding $\theta_h(\cdot)$ fixed and reshaping $f_s$ changes $\beta_h$; a moved coefficient is not a moved response function.
7. *Evidence.* Reproduce a weight figure for one Ramey shock series.
8. *Handoff.* Panels add units; do they add identification?

**Anchor examples.** A response function with curvature applied to the Ramey monetary shock series; the weight computation.

**Figures.** A nonlinear $\theta_h(e)$ with the linear coefficient; weight function for a skewed shock; the same $\theta$ under two shock distributions.

**Postpones.** Nonparametric estimation of $\theta_h(\cdot)$.

**Handoff question.** What identifying information does a cross-section of countries add to a common shock?

### Lecture 11 — Panel LPs and common macroeconomic shocks

**Guiding question.** What identifying information does a panel add?

**Opening situation.** Jordà, Schularick, and Taylor ask whether recessions that follow credit booms are deeper, using a historical archive of 14 advanced economies from 1870 to 2008. The regression behind their Figure 4 uses 121 business-cycle peaks, which fall in only 58 distinct years. The number of rows is not the amount of identifying information.

**Dependency chain.**

1. *The panel LP.* Unit fixed effects, horizon by horizon; the estimation sample by horizon.
2. *Common shocks and time effects.* A shock common to all units is absorbed by $\phi_t$; the exposure interaction $e_i s_t$ survives and identifies a difference in responses across exposure, not the level.
3. *Micro responses to macro shocks.* Almuzara–Sancibrián: the estimand of a unit-level regression on a common shock, and why the effective sample size is the number of shocks.
4. *Inference under aggregate dependence.* Clustering by unit, by time, Driscoll–Kraay; which one matches the design.
5. *Heterogeneity and averaging.* What a pooled $\beta_h$ averages when units differ.
6. *The recession-path comparison.* JST's normal versus financial recessions is a conditional comparison of paths, not the response to an exogenous shock; the notes say so.
7. *Bias with lags and fixed effects.* Nickell bias at short $T$; when it matters here.
8. *Evidence.* Reproduce the *When Credit Bites Back* Figure 4 GDP panel from the historical archive (D16), preserving the vintage.
9. *Handoff.* Units that enter treatment at different dates.

**Anchor examples.** JST macrohistory panel; a simulated panel with a common shock and exposure.

**Figures.** Absorption of a common shock by time effects; exposure interaction; effective sample size against $N$; normal versus financial recession paths.

**Postpones.** Interactive fixed effects; spatial dependence.

**Handoff question.** How should the projection be built when treatment switches on at different dates for different units?

### Lecture 12 — LP difference-in-differences

**Guiding question.** How should LPs be constructed when units enter treatment at different dates?

**Opening situation.** U.S. states deregulated interstate banking in different years. A regression of the labor share on a treatment dummy with two-way fixed effects compares each newly treated state with states that are already treated, whose outcomes are themselves responding. Dube, Girardi, Jordà, and Taylor rebuild the comparison so that only clean controls enter.

**Dependency chain.**

1. *Staggered absorbing treatment.* $D_{i,t}$, $g_i$, event time; the naive TWFE event study and the forbidden comparisons it makes.
2. *The LP-DiD regression.* $y_{i,t+h}-y_{i,t-1}$ on $\Delta D_{i,t}$ with time effects, restricted to newly treated units and units still untreated at $t+h$.
3. *The estimand.* A variance-weighted average effect by default; an equally weighted one under reweighting; which one a research question wants.
4. *Pre-trends and assumptions.* Negative horizons as a parallel-trends diagnostic; no anticipation.
5. *Manual construction versus `lpdid`.* Build the cohort-by-horizon eligibility table by hand, then match the package.
6. *Nonabsorbing treatment.* The extension and its extra assumptions.
7. *Evidence.* Reproduce a selected banking-deregulation result; simulated examples are kept separate and labeled.
8. *Handoff.* With a defended estimate in hand, which conclusions follow from it?

**Anchor examples.** The banking-deregulation panel; a simulated staggered design with known effects.

**Figures.** Cohort timeline with eligible controls at one horizon; forbidden comparisons; LP-DiD versus TWFE on the simulated design; reweighting.

**Postpones.** Continuous treatments; synthetic controls.

**Handoff question.** Which of a paper's conclusions follow from the estimated response, and which require assumptions it has not stated?

## Part IV — Use and defend LP evidence

### Lecture 13 — Sensitivity analysis and policy counterfactuals

**Guiding question.** Which conclusions follow from the estimated response, and which require additional assumptions?

**Opening situation.** Jordà and Taylor estimate the unemployment response to a funds-rate move instrumented by the Romer–Romer shock, then ask what unemployment would have done had the funds-rate response peaked one standard error earlier. The first number is an estimate. The second is a calculation that borrows the first and adds assumptions the calculation cannot check.

**Dependency chain.**

1. *A pre-specified sensitivity grid.* Specification changes and sample changes tabulated separately.
2. *Influential episodes.* Leave-one-episode-out; what a single episode can do to a coefficient with $T_h$ rows.
3. *Weak identification checks.* First stages and reduced forms across the grid.
4. *The counterfactual calculation.* $y^c_{t+h}=y^0_{t+h}+\sum_{j\le h}\theta_{h-j}(s^c_{t+j}-s^0_{t+j})$; its arithmetic with estimated responses (JT Example 8).
5. *Three readings.* An estimated shock response; a statistical conditioning on estimated responses; a causal intervention on a policy path. Policy invariance and the Lucas critique separate the second from the third.
6. *Classifying conclusions.* Statistical result, assumption-dependent interpretation, or unsupported claim; each sentence of a results section is one of these.
7. *Evidence.* Reproduce the JT counterfactual and audit its interpretation.
8. *Handoff.* Can someone else reproduce, understand, and challenge the whole analysis?

**Anchor examples.** JT Example 8 counterfactual (unemployment, alternative FFR path, GBF responses); the RZ specification grid.

**Figures.** Sensitivity grid as a small-multiple; leave-one-episode-out paths; baseline and counterfactual paths; a three-way classification of claims.

**Postpones.** Optimal policy; structural models.

**Handoff question.** Could another researcher reproduce, understand, and challenge this analysis from what has been written down?

### Lecture 14 — Research synthesis, replication audit, and defense

**Guiding question.** Can another researcher reproduce, understand, and challenge the analysis?

**Opening situation.** A replication package arrives: a master do-file, a dataset, a README, and a figure. The auditor's job is to reproduce the published figure, log every discrepancy, classify it, and decide which one matters. The author's job is to have made that possible.

**Dependency chain.**

1. *The methods section.* Estimand, identification, implementation, inference: four paragraphs every LP paper needs, with a template.
2. *Documenting consequential choices.* Which choices change the estimand, which change precision, which change nothing.
3. *Discrepancy taxonomy.* Data, specification, software, inference, presentation; how to reconcile each kind.
4. *Null results.* How to report an uninformative response without either burying or overselling it.
5. *Criticism.* Responding to a referee's identification challenge with evidence, not adjectives.
6. *The audit protocol.* A clean directory, a fixed target, a tolerance, a log.
7. *Closing the loop.* From the June 1950 question to a defended response: what the course has built and what remains open.

**Anchor examples.** The capstone packages; a deliberately flawed replication package for the referee desk.

**Figures.** The four-paragraph methods template as a diagram; discrepancy log structure; audit workflow.

**Postpones.** Nothing; this lecture closes the course.

**Handoff question.** None. The student now writes the question.
