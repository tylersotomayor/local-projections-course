# Lecture 05 brief — Pointwise inference, persistence, and lag augmentation

Planning author's brief for `lectures/05-pointwise-inference/`, `interactives/05-coverage-simulator.qmd`, and `practica/p05-pointwise-inference/`. Numbers come from StataNow/SE 19.5 runs (13 September 2026) in the scratch directory `design-05/` (path in §8), the benchmark CSVs, or closed forms in §6; reused logs were grepped for `^r\([0-9]+\);`. Coverage cells are quoted at D2's $R=500$: the first 500 replications of the seeded $R=1{,}000$ runs (`run3/r500/`), which equal a `global R 500` run because `simulate, seed()` draws replications in order (checked with `cf` on four stored $R=200$ prefixes). Not used: `acf_l05.log` (ends in `r(3000)`; replaced by `run2/acf2_l05.do`) and `shelter/shelter_transfer.do` (NW with $m=h$ and housing starts, contrary to D7; replaced by `run2/shelter_d7.do`).

---

## 1. Session brief

**Opening situation.**
Lecture 4 ended with a question: the interval around a multiplier is a claim about repeated samples; is the claim true? Lecture 5 answers on the shelter anchor of D7. Two researchers load the same file (`sigband_shelterinf.dta`, author archive of 13 August 2024, SHA-256 `efb9c72a…3832`). They run the same 49 regressions of the cumulative change in 100 × log shelter PCE prices on the Bauer–Swanson surprise, with 12 lags of shelter inflation, the funds rate and unemployment. At month 48 both report a point estimate of $-3.618$ percent. Researcher A follows `Figure4.do` and uses Newey–West with 48 lags: s.e. 1.828, 95% interval $[-7.201,\,-0.035]$, "significant". Researcher B adds a thirteenth lag of each control and uses HC3 standard errors: estimate $-3.799$, s.e. 3.018, interval $[-9.714,\,2.116]$, "not significant". The ratio of B's standard error to A's rises from 0.99 at month 1 to 1.65 at month 48. A cites Newey and West (1987); B cites Montiel Olea and Plagborg-Møller (2021). The data cannot adjudicate. Only the promise each interval makes, checked in economies where the truth is known, can.

**Decision or empirical question.**
At one horizon, in a given design, which standard error should be reported, and what shows that its nominal 95% interval covers $\beta_h$ about 95% of the time? The answer: coverage belongs to a procedure in a data-generating process; Newey–West must estimate the score's long-run variance and under-covers as persistence and $h$ grow; HC errors suffice when the score $\tilde s_tu_{t,h}$ is serially uncorrelated, which holds when the partialled-out regressor is an innovation (by construction in the IJK design; for the shelter surprise, the maintained Assumption 1, checkable only against the past); lag augmentation guarantees that for a regressor inside a VAR($p$), within a stated parameter space and horizon range, at a price in width a Monte Carlo can measure.

**Target student and prerequisites.**
Has completed Lectures 1–4:

- the horizon-$h$ regression and $\beta_h$ versus $\theta_h$ (L1, L3);
- long differences and horizon-specific samples $T_h$ (L2);
- Frisch–Waugh–Lovell partialling-out and predetermined controls (L3);
- LP-IV and the one-step multiplier with a HAC standard error (L4).

Statistics assumed: the OLS sandwich variance in scalar form, a CLT for averages, autocovariance and autocorrelation, normal quantiles, and a Bernoulli proportion's standard error. Stata assumed: `regress` with `vce(robust)` and `vce(hc3)`, `newey`, `predict, resid`, `forvalues`, `corrgram`, `simulate` or `postfile`.

Not assumed: HAC asymptotics, unit-root theory (stated, not proved), VAR theory (L7).

**Learning outcomes (five).**
1. State what a pointwise 95% interval promises (coverage of $\beta_h$ over repeated samples from a fixed economy at a fixed $h$). Distinguish nominal from achieved coverage, and report achieved coverage with its Monte Carlo standard error $\sqrt{\hat p(1-\hat p)/R}$.
2. Explain why $u_{t,h}$ is serially correlated by construction and why that alone does not settle the standard error: what matters is the autocorrelation of the score $\tilde s_tu_{t,h}$. Compute HC and Bartlett–Newey–West standard errors by hand on twelve rows and match Stata.
3. State the lag-augmented LP result exactly:
   - the regression and its HC standard error;
   - Assumption 1 (innovations mean-independent of past and future innovations);
   - the parameter space (at most one near-unit root per series; the remaining dynamics uniformly stable);
   - the horizon ranges ($h\le(1-\zeta)T$ when all roots lie in $[\zeta-1,1-\zeta]$; $h/T\to0$ otherwise; MOPM's $a$ is renamed $\zeta$ because $a$ is reserved for Lecture 8, D20);
   - what the 13 January 2026 corrigendum changed (the scaling matrix in Assumption 3, the proof of Lemma A.6) and did not change (procedures, simulations, conclusions).
4. Build and read a coverage Monte Carlo in Stata across $\rho$, $T$ and $h$. Report coverage, mean width, bias and the ratio of mean standard error to sampling standard deviation with their Monte Carlo uncertainty. Attribute under-coverage to a biased standard error or to a biased point estimate.
5. Choose and defend a pointwise procedure for an assigned design (observed shock, regressor inside a VAR, LP-IV, panel). Name the result that supports it and the features of the design that lie outside that result.

**Anchor examples.**

*A. Shelter anchor (D7; real data).*

| Element | Value |
|---|---|
| Data and source | `sigband_shelterinf.dta`, IJK author archive `340947c` (CC0) |
| Outcome | $y_t=100\log$ `lpcepi_house` (shelter PCE price index) |
| Dependent variable | $y_{t+h}-y_{t-1}$: the cumulative response of log shelter prices, in percent |
| Intervention | $s_t=$ `BSmonshock`, the Bauer–Swanson (2023) surprise, entered directly: 384 nonmissing months, s.d. 0.0473, 118 exact zeros |
| Controls | $\mathbf w_t$: 12 lags each of $\Delta y_t$, `stir`, `urate` (no housing starts, per D7) |
| Horizons and samples | $H=48$; $T_0=371$ down to $T_{48}=323$ |
| Authors' standard error | `newey …, lag(48)` at every $h$ |

Course variants (`run2/shelter_d7.do`, 112 s): NW($m=h$); HC3; lag-augmented (13 lags of each control) with HC3 and HC1; 13 lags of the shock (footnote).

Selected values (percent; standard errors in parentheses):

| $h$ | $\hat\beta_h$ | NW($m=48$) | NW($m=h$) | HC3, 12 lags | LA: $\hat\beta_h$ | LA-HC3 | LA-HC3 / NW(48) |
|---|---|---|---|---|---|---|---|
| 0 | $-0.066$ | 0.062 | 0.074 | 0.086 | $-0.069$ | 0.087 | 1.40 |
| 12 | $-0.225$ | 0.472 | 0.478 | 0.705 | $-0.192$ | 0.700 | 1.48 |
| 24 | $-1.502$ | 1.063 | 1.020 | 1.488 | $-1.469$ | 1.514 | 1.42 |
| 36 | $-2.679$ | 1.608 | 1.585 | 2.446 | $-2.705$ | 2.494 | 1.55 |
| 48 | $-3.618$ | 1.828 | 1.828 | 2.963 | $-3.799$ | 3.018 | 1.65 |

- **Benchmark agreement.** The NW(48) column equals `REP03-shelter-prices-author-20240813.csv` within $5\times10^{-7}$ in coefficient and s.e. at all 49 horizons, with identical $N$.
- **Where zero is excluded.** NW(48) intervals exclude zero only at $h=48$ ($t=-1.979$; $-1.921$ at 47, $-1.841$ at 46). HC3 and LA-HC3 exclude it nowhere.
- **What drives the gap.** HC3 without the extra lag is within 2% of LA-HC3 at every tabulated horizon, so the researchers' disagreement is Newey–West versus heteroskedasticity-robust, not the thirteenth lag.
- **Predictability.** Own 12 lags given the controls: $F(12,322)=1.47$, $p=0.134$; all 48 lagged regressors: $p=0.054$. §4 of the notes makes this condition precise.

*B. The known economy of IJK Figure 2 (REP05, D9).*
`Figure2.do`, commit `5e57e0b`, seed 12345, 1,000 burn-in rows, $T=150$. As coded (the two `replace` lines run sequentially; D9 footnote), with course labels $s=$ do-file `y` and $y=$ do-file `x`:
$$
s_t=\rho s_{t-1}+e_{1,t}+e_{2,t},\qquad y_t=\psi s_{t-1}+\rho y_{t-1}+e_{1,t},\qquad e_{j,t}\overset{\text{iid}}{\sim}N(0,1),\quad \rho=0.7,\ \psi=0.4 .
$$
The LP regresses $y_{t+h}$ on $s_t,s_{t-1},y_{t-1}$ for $h=0,\dots,13$.

- **Truth.** Response of $y$ per unit of the innovation in $s$: $\beta_h=\rho^{h-1}(0.5\rho+\psi h)$, i.e. 0.5, 0.75, 0.805, 0.7595, 0.66885, 0.564235, 0.462192, 0.370594, 0.292358, 0.227710, 0.175538, 0.134176, 0.101832, 0.076819.
- **The comment's system.** The simultaneous matrix $\begin{pmatrix}0.7&0.4\\0.4&0.7\end{pmatrix}$ described in the file's comment has eigenvalues 1.1 and 0.3 (`checks_l05.log`). The recursion as run is identical to the triangular system to machine zero (`bench/dgpcheck.log`).
- **Single realization.** Benchmark values from `REP05-pointwise-inference.csv`:

| $h$ | 0 | 2 | 4 | 6 | 8 | 10 | 13 |
|---|---|---|---|---|---|---|---|
| NW ($m=h$) $\hat\beta_h$ | 0.5135 | 0.8438 | 0.5642 | 0.3899 | 0.2762 | 0.2120 | 0.2185 |
| NW s.e. | 0.0335 | 0.0837 | 0.1297 | 0.1775 | 0.1467 | 0.1219 | 0.1270 |
| LA (2 lags) $\hat\beta_h$ | 0.5197 | 0.8592 | 0.5907 | 0.4022 | 0.2603 | 0.1857 | 0.1997 |
| LA-HC3 s.e. | 0.0346 | 0.0953 | 0.1449 | 0.1642 | 0.1592 | 0.1688 | 0.1822 |

In this draw every plotted NW interval ($h\le10$) contains the truth; one realization says nothing about coverage.

- **Repeated samples.** Course-built statistical reproduction, $R=500$ (D2), seed 20260501. At $h=8$:

| Procedure | Coverage | Mean width |
|---|---|---|
| NW ($m=h$) | 0.858 | 0.559 |
| HC3, one lag (the file's regression) | 0.898 | 0.612 |
| LA-HC3 | 0.892 | 0.623 |

Monte Carlo s.e. 0.014–0.016.

*C. JT Example 4 (as coded).* Same system with $\rho=0.85$, $\psi=0.2$, $T=300$, seed 12345, NW `lag(6)` at every horizon; truth $\beta_h=0.85^{h-1}(0.425+0.2h)$. The August 2024 working-paper text prints $\begin{pmatrix}0.7&0.2\\0.2&0.7\end{pmatrix}$ and 500 burn-in rows; the code uses 0.85 and 1,000 (discrepancy log). Course Monte Carlo ($R=500$, seed 20260913, `mc_l05.do`) at $h=12$ (truth 0.4727):

| Procedure | Coverage | Mean width |
|---|---|---|
| NW(6) | 0.874 | 0.524 |
| NW($m=h$) | 0.858 | — |
| HC3, one lag | 0.884 | — |
| LA-HC3 | 0.882 | 0.550 |

Mean bias is $-0.060$ against a sampling s.d. of 0.150 ($d_h\approx-0.40$). The shared bias alone costs about 1.9 points of coverage; standard errors 7 percent (LA-HC3) and 11 percent (NW(6)) too small alone cost 1.7 and 3.0 points (§6 D6).

*D. The MOPM AR(1) (smallest model; simulation).*
$y_t=\rho y_{t-1}+\varepsilon_t$, $y_0=0$, $\varepsilon_t\overset{\text{iid}}{\sim}N(0,1)$, $T=240$, regressor $s_t\equiv y_t$, $\beta_h=\rho^h$. At 95% (`mc_l05.do`, $R=500$, seed 20260913):

| $\rho$, $h$ | NW($m=h$), no lag | HC, no lag | LA-HC3 | LA-NW | Mean width NW / HC / LA-HC3 |
|---|---|---|---|---|---|
| 0.5, 12 | 0.904 | 0.862 | 0.944 | 0.922 | 0.301 / 0.258 / 0.300 |
| 0.95, 12 | 0.742 | 0.368 | 0.860 | 0.856 | 0.519 / 0.223 / 0.667 |
| 1, 12 | 0.418 | 0.096 | 0.752 | 0.698 | 0.389 / 0.151 / 0.815 |

At 90% ($R=500$, seeds 20260511–13; `run3/r500/cov_ar1_*_R500.csv`), LA-HC1 coverage is within 2 standard errors of the difference (0.0141) from MOPM Table 1's LP-LA column in 13 of 15 cells. Two cells differ by 2.1: $\rho=0.5$, $h=36$ (0.918 versus 0.889) and $\rho=1$, $h=60$ (0.306 versus 0.276). The $R=1{,}000$ authoring run had its largest gap at $\rho=0.95$, $h=12$ (0.774 versus 0.806, 3.1 standard errors of the difference). All three cells go in the discrepancy log. Median lengths agree within 0.020.

*E. Twelve-row hand example (`tbl-l05-hand`).* A new draw, not Lecture 1's hand table (`hand_table_final.csv`, which Lecture 2 reuses); the notes say so in one sentence. `hand_l05.do`: `set seed 1`, `set obs 13`. Thirteen unrounded $N(0,1)$ values of $s_t$ are drawn first, then thirteen of $v_t$, so $s_t$ is continuous. Then $y_1=s_1+v_1$ and $y_t=0.5y_{t-1}+s_t+v_t$, and row 13 supplies only the lead. The $h=1$ regression of $y_{t+1}$ on $(1,s_t)$ uses 12 rows. Numbers in §6 D2.

**Smallest useful model (ledger notation).**
Anchor D. Without augmentation,
$$
y_{t+h}=\mu_h+\beta_h s_t+u_{t,h},\qquad s_t=y_t,\qquad u_{t,h}=\sum_{j=1}^{h}\rho^{h-j}\varepsilon_{t+j}.
$$
With augmentation, $\mathbf w_t=y_{t-1}$ and
$$
y_{t+h}=\beta_h\,\varepsilon_t+\rho^{h+1}y_{t-1}+u_{t,h}.
$$
The two regressions have the same residual and the same $\beta_h$. The augmented one has partialled-out regressor $\tilde s_t=\varepsilon_t$, whose score $\varepsilon_tu_{t,h}$ is serially uncorrelated under Assumption 1. The non-augmented score $y_tu_{t,h}$ has autocorrelation 0.788, 0.596, 0.424, 0.268, 0.127, 0 at lags 1–6 when $\rho=0.95$, $h=6$. Everything else in the lecture elaborates this pair.

**Dependency chain of sections** (spine order; titles refined).

1. `#sec-l05-promise` *What an interval promises.* From the shelter disagreement to coverage over repeated samples, nominal versus achieved, and the Monte Carlo error of a coverage estimate; one draw (anchor B) cannot reveal it.
2. `#sec-l05-dependence` *Where the dependence comes from.* $u_{t,h}$ sums shocks after $t$, so rows overlap: at most MA($h$), MA($h-1$) when the regressor absorbs the date-$t$ innovation, and heteroskedastic in practice.
3. `#sec-l05-hac` *Newey–West and the bandwidth.* The Bartlett sandwich on twelve rows, the $m=h$ convention, and why a long-run variance estimated from $T_h$ rows is biased down as persistence and $h$ grow.
4. `#sec-l05-scores` *Residuals versus scores.* The variance of $\hat\beta_h$ depends on autocovariances of $\tilde s_tu_{t,h}$, which vanish under mean-independent innovations although $u_{t,h}$ is MA($h$); HC is then valid; the IJK design satisfies this by construction, while for the shelter surprise it is the maintained Assumption 1, which can be checked only against the past (own lags $p=0.134$; all lags $p=0.054$).
5. `#sec-l05-lag-augmentation` *Lag augmentation and its conditions.* Adding $y_{t-1}$ turns the regressor into $\varepsilon_t$ (FWL); MOPM's Proposition 1 gives uniform validity over a stated parameter space and horizon range; the 2026 corrigendum repairs Assumption 3, not the procedure.
6. `#sec-l05-evidence` *Evidence from known economies.* REP05 reproduces IJK Figure 2; the course Monte Carlo measures achieved coverage of NW, HC and LA across $\rho$, $T\in\{150,300\}$ and $h\le12$ (IJK, JT designs) and in the AR(1) at 95% and 90%.
7. `#sec-l05-width` *Width is not reliability.* The narrowest AR(1) interval covers least; coverage splits into an s.e. ratio and a bias ratio; augmentation buys coverage with width and leaves estimate bias.
8. `#sec-l05-scope` *Scope.* What carries over to observed shocks, LP-IV, panels and nonlinear designs; the bivariate $\rho=1$ design lies outside Definition 1; neither "LP means Newey–West" nor "always augment" is a rule.
9. `#sec-l05-summary` *Handoff.* Everything so far concerns one horizon; a sentence about the first year concerns thirteen.

**Central notation.** Ledger: $\alpha$, $z_{1-\alpha/2}$, $\operatorname{se}(\hat\beta_h)$ (estimator always named), $m$, $\rho$, $R$, $T_h$, $u_{t,h}$, $s_t$, $\mathbf w_t$, $\varepsilon_t$. Local (defined in §2): $\tilde s_t$, $g_{t,h}$, $\hat\Gamma_{h,j}$, $k_j$, $\hat J_h(m)$, $\hat q_h$, $n_h$, $\hat p$, $\varsigma_h$, $d_h$, $\psi$, $e_{1,t},e_{2,t}$, $\zeta$. Here $n_h$ counts regressors and $d_h$ is bias over sampling s.d., as in Lecture 7; $r$ and $b$ stay reserved for Lecture 8 (D20). A footnote maps MOPM's $u_t$ and $\xi_t(\rho,h)$ to $\varepsilon_t$ and $u_{t,h}$.

**Glossary terms** (owned keys only; one-line drafts).

- `confidence-interval`: a data rule $\hat\beta_h\pm z_{1-\alpha/2}\operatorname{se}$ whose promise concerns repeated samples.
- `coverage`: probability over repeated samples that the interval contains $\beta_h$.
- `nominal-coverage`: the claimed $1-\alpha$, true only under the standard error's assumptions.
- `achieved-coverage`: the share of simulated intervals containing the truth in a stated design.
- `heteroskedasticity`: non-constant conditional variance of the error or score.
- `serial-correlation`: correlation with the series' own past, built into $u_{t,h}$ by overlap.
- `hac-estimator`: a variance estimator adding weighted autocovariances of the score.
- `newey-west`: Bartlett-weighted HAC; nonnegative, downward-biased when scores are persistent.
- `bandwidth`: the lags $m$ in a HAC estimator; $m=h$ is a convention, not a theorem.
- `lag-augmentation`: one lag beyond identification, so the partialled-out regressor is an innovation.
- `heteroskedasticity-robust`: Eicker–Huber–White (HC0–HC3) errors that assume uncorrelated scores.
- `score`: $\tilde s_tu_{t,h}$; its autocorrelation, not the residual's, decides the valid standard error.
- `martingale-difference`: zero mean given the past; MOPM need mean zero given past and future.
- `overlapping-residuals`: nearby rows' $u_{t,h}$ share future shocks, so residuals correlate by construction.
- `interval-width`: $2z_{1-\alpha/2}\operatorname{se}$ averaged over replications; informative only if it covers.
- `monte-carlo-uncertainty`: simulation error, $\sqrt{\hat p(1-\hat p)/R}$ for a coverage rate.
- `unit-root`: an autoregressive root of one; permanent shocks and non-normal level regressions.
- `size-distortion`: actual minus nominal rejection rate of the $t$-test; equals the coverage shortfall.

**Likely footnotes.** D9's sequential `replace`; HC0/HC1/HC3 (IJK and JT use HC3, MOPM's theory EHW); `newey`'s factor $T_h/(T_h-n_h)$ and its $t$-based intervals; Bartlett weights keep the variance nonnegative; EWC and fixed-$b$ HAR (Lazarus, Lewis, Stock, and Watson 2018), MOPM's non-augmented benchmark; uniform versus pointwise validity; the corrigendum's quasi-differenced $G(A,h,\epsilon)$; MOPM's percentile-$t$ bootstrap; lags of the shock change the specification (shelter $h=48$: $-6.818$); the JT text-versus-code discrepancy; MOPM notation; one-sided claims belong to Lecture 6 (D25).

**Candidate figures.**

| Label | Question | Lesson visible | Data or formula |
|---|---|---|---|
| `fig-l05-two-bands` | How far apart are the two researchers' bands, and where? | Same path; the HC band is about 1.4–1.65 times wider after month 12; only NW excludes zero, once | `run2/shelter_d7.csv` |
| `fig-l05-residual-vs-score` | Which autocorrelation matters? | $u_{t,6}$ and the non-augmented score decay over five lags; the augmented score is flat at zero; theory markers sit on the bars | `run2/acf2_l05.log` ($T=20{,}000$) and the closed forms of §6 D3 |
| `fig-l05-hit-miss` | What does "95%" look like? | Sixty intervals at $h=6$ in the JT design, $\rho=0.95$: NW(6) hits 55, LA-HC3 58; binomial variation makes 60 draws inconclusive | `hitmiss_h6_rho95.csv` (first 60 of $R=200$, seed 20260913) |
| `fig-l05-coverage-by-horizon` | How does achieved coverage fall with $h$ and $\rho$? | Two panels (IJK design, $T=150$, $\rho=0.7$ and $0.95$): NW below HC and LA at every $h\ge2$; all fall at $\rho=0.95$; $\pm2$ MC s.e. band around 0.95 | `run3/r500/cov_r07_T150_R500.csv`, `cov_r095_T150_R500.csv` ($R=500$) |
| `fig-l05-width-vs-coverage` | Is the narrower interval the more reliable one? | AR(1) cells ($\rho\times h\times$ procedure): non-augmented HC sits bottom-left, LA-HC3 top-right | `run3/r500/mcB_summary_T240_R500.csv` |
| `fig-l05-coverage-decomposition` (droppable, D24) | Is the shortfall the s.e. or the estimate? | Contours of $\Phi(z\varsigma-d)-\Phi(-z\varsigma-d)$ with simulated cells overlaid | §6 D6 formula; the same CSVs |

**Exercise capabilities.** Reading a coverage claim with its Monte Carlo error; HC and NW arithmetic by hand; the residual and score autocorrelation derivation; the FWL identity as a unit test; a coverage Monte Carlo with `simulate`; decomposing a shortfall into s.e. bias and estimate bias; matching designs to the theorem; defending a band on the shelter data.

**Controlled experiments.** Hit-or-miss with fixed draws as the procedure changes; residual versus score autocorrelation as augmentation, $\rho$ and a lag-order violation change; a coverage map over $\rho\times T\times h$; width against coverage, ending in a prediction exported to Stata.

**Postponed.** Simultaneous bands and cross-horizon covariance (L6); bootstrap intervals (further reading); EWC and fixed-$b$ beyond a footnote; bias correction (L7); clustered and Driscoll–Kraay inference (L11); weak-IV-robust inference (L4 mention); proofs.

**Question handed on.** If each of five intervals covers with probability 0.95, what is the probability that all five do? It is $0.95^5=0.774$ only if the five estimates are independent, and adjacent horizons never are.

---

## 2. Concept and notation ledger

Rows marked *local* are new in this lecture; all others keep their ledger meaning.

| Symbol | Meaning | Dimensions | Timing | Units | First use | Later uses |
|---|---|---|---|---|---|---|
| $y_t$ | Outcome | scalar | $t$ | shelter: $100\log$ index; simulations: unitless | `#sec-l05-promise` | L6, L7 |
| $s_t$ | Intervention variable (Bauer–Swanson surprise; simulated $s$; $y_t$ itself in the AR(1)) | scalar | $t$ | as shipped (s.d. 0.0473) / innovation units | `#sec-l05-promise` | L6–L13 |
| $\mathbf w_t$ | Predetermined controls | $(n_h-2)\times1$ | $\le t-1$ | mixed | `#sec-l05-promise` | L6 |
| $\beta_h,\ \hat\beta_h$ | LP coefficient and estimate | scalar | row $t$, outcome $t+h$ | $y$ per unit $s$ (percent per unit surprise) | `#sec-l05-promise` | all |
| $u_{t,h}$ | Horizon-$h$ residual; sums shocks dated $t$ (part not in $s_t$) to $t+h$; at most MA($h$) | scalar | $t,\dots,t+h$ | units of $y$ | `#sec-l05-dependence` | L6 stacked scores |
| $\varepsilon_t$ | Innovation of the AR(1); MOPM's $u_t$ | scalar | $t$ | unit variance | `#sec-l05-dependence` | L7 |
| $T_h$ | Rows in the horizon-$h$ regression (shelter 371→323; IJK 149→136) | count | — | rows | `#sec-l05-promise` | L6 |
| $n_h$ *local* | Regressors including constant (IJK 4; shelter 38; LA shelter 41) | count | — | — | `#sec-l05-hac` | — |
| $\tilde s_t$ *local* | $s_t$ after partialling out $(1,\mathbf w_t)$ | scalar | $t$ | units of $s$ | `#sec-l05-scores` | L6 (same symbol) |
| $\hat q_h$ *local* | $T_h^{-1}\sum_t\tilde s_t^2$ | scalar | — | $s^2$ | `#sec-l05-scores` | L6 writes $q$ |
| $g_{t,h}$ *local* | Score $\tilde s_tu_{t,h}$; $\hat\beta_h-\beta_h=\sum_t g_{t,h}/\sum_t\tilde s_t^2$ | scalar | $t,\dots,t+h$ | $s\times y$ | `#sec-l05-scores` | L6 $\mathbf g_t$ |
| $\hat\Gamma_{h,j}$ *local* | Sample autocovariance of $\hat g_{t,h}$ at lag $j$ | scalar | lag $j$ | $(s\,y)^2$ | `#sec-l05-hac` | — |
| $m$ | HAC bandwidth | integer | lags | — | `#sec-l05-hac` | L4 (seen), L6 |
| $k_j$ *local* | Bartlett weight $1-j/(m+1)$ | scalar | lag $j$ | — | `#sec-l05-hac` | — |
| $\hat J_h(m)$ *local* | $\hat\Gamma_{h,0}+2\sum_{j\le m}k_j\hat\Gamma_{h,j}$; $\hat J_h(0)$ is the HC0 middle | scalar | — | $(s\,y)^2$ | `#sec-l05-hac` | L6 (matrix form) |
| $\operatorname{se}(\hat\beta_h)$ | $\{\tfrac{T_h}{T_h-n_h}\hat J_h(m)/(T_h\hat q_h^2)\}^{1/2}$ for NW($m$) and HC1 ($m=0$); HC3 reweights by leverage | scalar | — | units of $\beta_h$ | `#sec-l05-hac` | all |
| $\alpha,\ z_{1-\alpha/2}$ | Level; normal critical value (1.959964; 1.644854 at 90%) | scalar | — | — | `#sec-l05-promise` | L6 |
| $\rho$ | Own-lag persistence in every simulation | scalar | — | — | `#sec-l05-dependence` | L6–L8 |
| $\psi$ *local* | Cross coefficient of $y_t$ on $s_{t-1}$ (IJK 0.4, JT 0.2) | scalar | — | — | `#sec-l05-evidence` | L6 (as 0.4 in text) |
| $e_{1,t},e_{2,t}$ *local* | Simulation innovations (do-file `ux`, `uy`) | scalar | $t$ | $N(0,1)$ | `#sec-l05-evidence` | — |
| $R$ | Replications (students 200; instructor builds and stored results 500; D2) | count | — | — | `#sec-l05-promise` | L6–L8 |
| $\hat p$ *local* | Achieved coverage $R^{-1}\sum_r\mathbf 1\{\beta_h\in\hat C^{(r)}_h\}$ | proportion | — | — | `#sec-l05-promise` | L6 (joint coverage) |
| $\varsigma_h,\ d_h$ *local* | Mean s.e. over sampling s.d.; mean bias over sampling s.d. ($d_h$ as in Lecture 7) | scalars | — | — | `#sec-l05-width` | L7 (its biased-band formula is the $\varsigma_h=1$ case of `eq-l05-coverage-approx`) |
| $p$ | VAR lag order; augmentation uses $p$ lags where identification needs $p-1$ | integer | — | — | `#sec-l05-lag-augmentation` | L7 |
| $\mathbf y_t,\ \mathbf A(L)$ | VAR vector and lag polynomial (ledger) | $n\times1$ | $t$ | — | `#sec-l05-lag-augmentation` | L7 |
| $\rho_i,\ \zeta$ *local* | Near-unit root of series $i$ in MOPM Definition 1; distance of roots from $\pm1$ (MOPM's $a$) | scalars | — | — | `#sec-l05-lag-augmentation` | — |

## 3. Terminology ledger

| Phrase | Treatment | Key | Definition (one sentence) | First marked |
|---|---|---|---|---|
| confidence interval | glossary | `confidence-interval` | A data-dependent rule whose promise concerns repeated samples, not the interval in hand. | `#sec-l05-promise` |
| coverage | glossary | `coverage` | Probability over repeated samples that the rule's interval contains the true $\beta_h$. | `#sec-l05-promise` |
| nominal coverage | glossary | `nominal-coverage` | The coverage claimed, $1-\alpha$, valid only under the assumptions behind the standard error. | `#sec-l05-promise` |
| achieved coverage | glossary | `achieved-coverage` | The coverage delivered in a stated design, estimated by the share of simulated intervals that contain the truth. | `#sec-l05-promise` |
| Monte Carlo uncertainty | glossary | `monte-carlo-uncertainty` | Simulation sampling error, $\sqrt{\hat p(1-\hat p)/R}$ for a coverage rate. | `#sec-l05-promise` |
| heteroskedasticity | glossary | `heteroskedasticity` | A non-constant conditional variance of the error or score. | `#sec-l05-dependence` |
| serial correlation | glossary | `serial-correlation` | Correlation of a series with its own past. | `#sec-l05-dependence` |
| overlapping residuals | glossary | `overlapping-residuals` | Horizon-$h$ residuals of nearby rows share future shocks, so they are correlated by construction. | `#sec-l05-dependence` |
| HAC estimator | glossary | `hac-estimator` | A variance estimator adding weighted autocovariances of the score to its variance. | `#sec-l05-hac` |
| Newey–West | glossary | `newey-west` | The Bartlett-weighted HAC estimator, nonnegative by construction and downward-biased when the score is persistent. | `#sec-l05-hac` |
| bandwidth | glossary | `bandwidth` | The number of lags $m$ in a HAC estimator. | `#sec-l05-hac` |
| heteroskedasticity-robust | glossary | `heteroskedasticity-robust` | Eicker–Huber–White standard errors, valid when scores are serially uncorrelated. | `#sec-l05-hac` |
| score | glossary | `score` | $\tilde s_tu_{t,h}$, the term whose sum drives the estimation error. | `#sec-l05-scores` |
| martingale difference | glossary | `martingale-difference` | Zero mean given the past; MOPM need zero mean given past and future innovations. | `#sec-l05-scores` |
| lag augmentation | glossary | `lag-augmentation` | One more lag than identification needs, making the partialled-out regressor an innovation. | `#sec-l05-lag-augmentation` |
| unit root | glossary | `unit-root` | An autoregressive root of one; shocks never die out and level regressions have non-normal limits. | `#sec-l05-lag-augmentation` |
| size distortion | glossary | `size-distortion` | Actual minus nominal rejection rate of the $t$-test the interval inverts. | `#sec-l05-evidence` |
| interval width | glossary | `interval-width` | $2z_{1-\alpha/2}\operatorname{se}$, averaged over replications. | `#sec-l05-width` |
| innovation; effective regressor | prose | — | The unpredictable part of a variable; the regressor after partialling out controls. | `#sec-l05-scores` |
| uniform validity | footnote | — | Near-nominal coverage for the worst case in a parameter set. | `#sec-l05-lag-augmentation` |
| local-to-unity | footnote | — | A root modelled as $1-c/T$, the device for near-unit-root asymptotics. | `#sec-l05-lag-augmentation` |
| HC0/HC1/HC3 | footnote | — | Leverage and degrees-of-freedom variants of the robust sandwich. | `#sec-l05-hac` |
| EWC / fixed-$b$ HAR | footnote | — | HAR estimators with better small-sample size; MOPM's non-augmented benchmark. | `#sec-l05-hac` |
| percentile-$t$ bootstrap | footnote | — | MOPM §5 refinement of the LA interval. | `#sec-l05-lag-augmentation` |
| persistence; autoregressive process (L01); Monte Carlo simulation, statistical reproduction, small-sample bias (L02); Frisch–Waugh–Lovell (L03) | prose, linked to owner | — | — | — |

No new keys are proposed; the 18 owned keys cover the lecture (D22).

## 4. Evidence and visual ledger

| Claim | Evidence or calculation | Medium | Source | Asset status | Label |
|---|---|---|---|---|---|
| Same shelter path, standard errors differ by 0.99–1.65; only NW(48) excludes zero, at month 48 | 49 horizons, six estimators | figure + table | `run2/shelter_d7.csv`, `.log` | computed | `fig-l05-two-bands`, `tbl-l05-shelter` |
| The course's D7 path is the benchmark | max abs diff $5\times10^{-7}$ (coef, s.e.), $N$ identical | table note | REP03 CSV vs `shelter_d7.csv` | verified | `tbl-l05-shelter` |
| The disagreement is NW vs HC, not the extra lag | HC3 (12 lags) within 2% of LA-HC3 at $h=0,12,24,36,48$ | sentence | `shelter_d7.log` | computed | — |
| One draw reveals nothing about coverage | all 11 plotted NW intervals contain the truth | prose + REP05 figure | REP05 CSV; §6 D5 | benchmarked | `fig-rep05-figure2` (practicum) |
| $u_{t,h}$ is serially correlated; the augmented score is not | lag-1 ACF 0.831 (residual), 0.791 (score); augmented score $\le0.013$ | figure | `run2/acf2_l05.log`; §6 D3 | computed | `fig-l05-residual-vs-score` |
| HC and NW arithmetic | twelve rows; Mata = Stata to $5.6\times10^{-17}$ | table + equation | `hand_l05.log` | verified | `tbl-l05-hand`, `eq-l05-hac` |
| Lag augmentation is FWL on the innovation | $\hat\beta$ equal to $3.6\times10^{-15}$; HC1 s.e. equal to $2.0\times10^{-15}$ after df rescaling | equation | `fwl_l05.log` | verified | `eq-l05-la-identity` |
| NW($m=h$) under-covers in the IJK design; HC with one lag ≈ LA | $h=8$: 0.858 / 0.898 / 0.892 ($R=500$) | figure | `run3/r500/cov_r07_T150_R500.csv` | stored | `fig-l05-coverage-by-horizon` |
| Coverage falls with $\rho$, recovers with $T$; LA/NW width ratio 1.03–1.21 | six ($\rho,T$) cells at $h=6,12$ | table | `run3/r500/cov_*_R500.csv` | stored | `tbl-l05-grid` |
| Augmentation is decisive for a persistent own-lag regressor | AR(1), $\rho=1$, $h=12$: HC 0.096, NW 0.418, LA-HC3 0.752 | table + figure | `run3/r500/mcB_summary_T240_R500.csv` | stored | `tbl-l05-ar1`, `fig-l05-width-vs-coverage` |
| The course Monte Carlo is close to MOPM Table 1 (LP-LA) in 13 of 15 cells | 13 cells within 2 s.e. of the difference (0.0141); $\rho=0.5$, $h=36$ and $\rho=1$, $h=60$ at 2.1 (discrepancy log); median length within 0.020 | footnote table | `run3/r500/cov_ar1_*_R500.csv` | stored | `tbl-l05-mopm` |
| Coverage ≈ $\Phi(z\varsigma-d)-\Phi(-z\varsigma-d)$ | JT NW(6) $h=12$: 0.895 predicted, 0.874 observed; AR(1) $\rho=1$ LA: 0.788 vs 0.752 | equation (+ droppable figure) | §6 D6 | computed | `eq-l05-coverage-approx` |
| Sixty samples cannot tell 0.92 from 0.95 | $P(\text{hits}\le55\mid0.95)=0.180$ | figure + sentence | `hitmiss_h6_rho95.csv`; §6 D7 | computed | `fig-l05-hit-miss` |
| Bivariate $\rho=1$ lies outside Definition 1 | outcome I(2); coverage 0.452 at $h=12$, $T=150$ | prose | §6 D8; `run3/r500/cov_r100_T150_R500.csv` | derived | — |
| The corrigendum does not change procedures or simulations | corrigendum p. 1 | prose + footnote | `papers/corrigendum.txt` | read | — |

---

## 5. Assessment map

Nine exercises in dependency order: five Stata [computational], one [data]; Monte Carlo defaults per D2 and D26.

| Outcome | Exercise | Tags | Mode | Hint strategy | Solution check | Lab |
|---|---|---|---|---|---|---|
| 1 | 1. What sixty intervals can tell you | [core] [pencil] | JT $\rho=0.95$, $h=6$: NW(6) 55/60, LA-HC3 58/60. MC s.e.? Does 55/60 reject 0.95? What $R$ gives $2\,$s.e. $\le0.025$? | Treat each hit as a Bernoulli draw; name the null | $P(\le55\mid0.95)=0.180$; $R\ge304$ (§6 D7) | 1 |
| 2 | 2. HC and Newey–West on twelve rows | [core] [pencil] | Given `tbl-l05-hand` ($\tilde s_t$, $\hat u_{t,1}$): compute HC0, HC1, NW($m=1,2$). Explain why NW is *smaller* here. Which 95% interval contains $\beta_1=0.5$? | Build the column $g_t$ first; the sign of $\hat\Gamma_1$ decides | §6 D2 values to 6 digits; the NW(1) interval misses, HC1's covers; one draw proves nothing | — |
| 2 | 3. Residuals versus scores in the AR(1) | [core] [pencil] | Derive the autocorrelations of $u_{t,h}$ and of $y_tu_{t,h}$ at $\rho=0.95$, $h=6$. Show the augmented score's autocovariance is zero; mark where Assumption 1 is used | Write both scores as sums of products of dated $\varepsilon$'s; find an index that appears once | 0.829/0.788 at lag 1, zero from lag 6; $\varepsilon_{t-k}$ appears once (§6 D3–D4) | 2 |
| 2, 3 | 4. Lag augmentation is Frisch–Waugh–Lovell (Stata) | [core] [computational] | Seed 20260913, AR(1) $\rho=0.95$, $T=240$, $h=6$: LA regression versus regressing residualized $y_{t+6}$ on $\hat\varepsilon_t$; `corrgram` both scores | Recall L3's partialling-out; watch the df factor | `assert` equal $\hat\beta$ ($0.98950465096$) and HC1 s.e. ($0.15512352606$) within $10^{-10}$ | 2 |
| 1, 4 | 5. Coverage of the IJK design (Stata) | [core] [computational] | Wrap REP05's regressions in an `rclass` program. `simulate` $R=200$, seed 20260913, $T=150$, $h=0..12$. Report coverage, mean width, MC s.e. for NW($m=h$), HC3, LA-HC3 | Store every replication, summarize once; truth from the as-coded system | Matches `expected/cov_r07_T150_R200.csv` to $10^{-6}$ (e.g. $h=8$: 0.850 / 0.925 / 0.930; widths 0.5541 / 0.6337) | 3 |
| 4 | 6. Persistence, sample size, and what breaks (Stata) | [core] [computational] | AR(1), $\rho\in\{0.5,0.95,1\}$, $h\in\{1,6,12\}$, $R=200$; add $\varsigma_h$, $d_h$; predict by `eq-l05-coverage-approx`; then compare your own STA05 Task 2 runs at $\rho=0.95$, $T=150$ and $T=300$ | Ask whether $\hat\beta$ or $\operatorname{se}$ moved | $\rho=1$, $h=12$: HC 0.110, NW 0.450, LA-HC3 0.805 ($R=200$); predictions within 0.05 for LA cells; own Task 2 runs at $h=12$: NW 0.690 → 0.870, LA-HC3 0.775 → 0.885 | 3, 4 |
| 3, 5 | 7. Does the theorem cover this design? | [core] [pencil] | Classify: AR(1) $\rho=1$, $h=12$, $T=240$; bivariate triangular $\rho=1$; the shelter LP with an observed shock; the L4 one-step LP-IV multiplier; a 48-state panel. Then say what the corrigendum changed | Check Definition 1, the horizon range, Assumption 1 in turn | Covered (ii), finite-sample 0.75; outside (I(2) outcome, §6 D8); score argument on the shock, not Prop. 1; not covered; not covered; Assumption 3 only | 4 |
| 5 | 8. Defend a band on shelter prices (Stata) | [core] [data] [computational] | Reproduce the D7 NW(48) path, then NW($m=h$), HC3, LA-HC3. Test shock predictability; write a 150-word defence of one band for month 48 | Separate "is $s_t$ an innovation?" from "is the path persistent?" | `assert` NW(48) vs REP03 within $10^{-6}$ at 49 horizons; ratio 1.65 at $h=48$; $p=0.134$ | 4 |
| 3, 4 | 9. Reproduce MOPM Table 1 (Stata) | [extra] [computational] | 90%, $T=240$, $\rho=1$, $h\in\{1,6,12,36,60\}$, $R=200$ (D26); LA-HC1 vs NW($m=h$); explain the departure from EWC | Coverage error at $R=200$ is 0.021 | LA within 2 MC s.e. of 0.874/0.777/0.676/0.428/0.276; NW column below MOPM's EWC column | 3 |

Each outcome appears in at least two media:

| Outcome | Taught and tested in |
|---|---|
| 1 | prose, `fig-l05-hit-miss`, exercises 1 and 5, Lab 1 |
| 2 | `fig-l05-residual-vs-score`, exercises 2–4, Lab 2 |
| 3 | prose, `eq-l05-la-identity`, exercises 4 and 7 |
| 4 | tables, figures, exercises 5, 6 and 9, Labs 3–4, STA05 |
| 5 | exercises 7–8, REP05 interpretation record |

## 6. Derivations to verify

**D1. The pointwise interval and its promise.** $\hat C_h=[\hat\beta_h\pm z_{1-\alpha/2}\operatorname{se}(\hat\beta_h)]$ contains $\beta_h$ exactly when $|t_h|\le z_{1-\alpha/2}$, with $t_h=(\hat\beta_h-\beta_h)/\operatorname{se}$. Coverage therefore equals $1-P(|t_h|>z_{1-\alpha/2})$, one minus the actual size, and a size distortion equals the coverage shortfall.

**D2. HC and NW on twelve rows (worked example, `eq-l05-hac`).**

- *Source identity.* By Frisch–Waugh–Lovell, $\hat\beta_h-\beta_h=\sum_tg_{t,h}/\sum_t\tilde s_t^2$. Hence $\operatorname{Var}\approx\sum_t\sum_{t'}\operatorname{Cov}(g_t,g_{t'})/(\sum\tilde s_t^2)^2$.
- *Estimator.* Truncating the double sum at $|t-t'|\le m$ with weights $k_j$ and adding `newey`'s factor gives $\operatorname{se}_{\rm NW}(m)=\sqrt{T_h/(T_h-n_h)}\,\{S_0+2\sum_{j\le m}k_jS_j\}^{1/2}/D$, where $S_j=\sum_t\hat g_t\hat g_{t-j}$ and $D=\sum_t\tilde s_t^2$.
- *Inputs* (`hand_l05.do`: a new draw, not Lecture 1's table; seed 1, 13 unrounded values of $s_t$ then 13 of $v_t$, 12 rows used, $n_h=2$): $\bar s=0.2133361089$, $\hat\beta_1=-0.2433763901$, $\hat\mu_1=0.1974106523$. Also $D=13.91094908$, $S_0=27.01274804$, $S_1=-9.271042423$, $S_2=3.83360647$.
- *Results.*

| Estimator | Arithmetic | s.e. |
|---|---|---|
| HC0 | $\sqrt{S_0}/D$ | $0.3736178551$ |
| HC1 (= `vce(robust)` = `newey, lag(0)`) | HC0 $\times\sqrt{12/10}$ | $0.4092778543$ |
| NW(1) | $\sqrt{1.2}\sqrt{S_0+S_1}/D=\sqrt{1.2}\sqrt{17.741705617}/D$ | $0.3316893647$ |
| NW(2) | $\sqrt{1.2}\sqrt{S_0+\tfrac43S_1+\tfrac23S_2}/D$ | $0.3266537515$ |

- *Check.* Mata equals Stata within $5.55\times10^{-17}$.
- *Reading.* The negative first autocovariance shrinks NW below HC.
- *Intervals.* Normal 95% intervals: HC1 $[-1.0455,\ 0.5588]$ contains $\beta_1=0.5$; NW(1) $[-0.8935,\ 0.4067]$ does not. That is one draw, not a coverage statement.

**D3. Residual and score autocorrelation in the AR(1).**

- *Residual.* $u_{t,h}=\sum_{j=1}^h\rho^{h-j}\varepsilon_{t+j}$, so $\operatorname{Cov}(u_{t,h},u_{t-k,h})=\sum_{j=1}^{h-k}\rho^{2h-2j-k}$ for $k<h$ and zero for $k\ge h$ (MA($h-1$)).
- *Non-augmented score.* For $y_tu_{t,h}$ with Gaussian innovations, apply the four-moment identity. Only $E[y_ty_{t-k}]E[u_{t,h}u_{t-k,h}]$ survives, because $u_{t,h}$ is uncorrelated with $y_t$ and $y_{t-k}$, and $u_{t-k,h}$ with $y_{t-k}$; the pair $E[y_tu_{t-k,h}]E[y_{t-k}u_{t,h}]$ is zero through its second factor. So $\operatorname{corr}_k=\rho^k\sum_{j=1}^{h-k}\rho^{2h-2j-k}\big/\sum_{j=1}^h\rho^{2h-2j}$.
- *Values* at $\rho=0.95$, $h=6$, lags 1–6:

| Series | Theory | Simulated ($T=20{,}000$, seed 20260913) |
|---|---|---|
| Residual $u_{t,6}$ | 0.8293, 0.6609, 0.4941, 0.3287, 0.1641, 0 | 0.8312, 0.6652, 0.5008, 0.3357, 0.1732, 0.0105 |
| Non-augmented score | 0.7879, 0.5964, 0.4237, 0.2677, 0.1270, 0 | 0.7907, 0.5993, 0.4260, 0.2680, 0.1276, −0.0003 |
| Augmented score | 0 at every lag | −0.0048, 0.0026, −0.0131, 0.0029, 0.0022, 0.0102 |

- *Design A* ($\rho=0.85$, $h=6$, one lag of each variable, no augmentation). Residual 0.844 … 0.034 (lag 6), 0.008 (lag 7), which is MA(6). Score within $\pm0.008$.

**D4. Why the augmented score is uncorrelated (uses Assumption 1).**

- For $k\ge1$, $E[\varepsilon_tu_{t,h}\,\varepsilon_{t-k}u_{t-k,h}]$ is a weighted sum of $E[\varepsilon_t\varepsilon_{t+i}\varepsilon_{t-k}\varepsilon_{t-k+j}]$ with $i,j\ge1$.
- The date $t-k$ appears exactly once in each product: $t+i>t$, $t-k+j>t-k$, and $t\ne t-k$.
- Condition on all other innovations; Assumption 1, $E(\varepsilon_{t-k}\mid\{\varepsilon_s\}_{s\ne t-k})=0$, sets each term to zero. A martingale-difference assumption (past only) would not, because $\varepsilon_{t-k}$ is conditioned on future innovations here.
- For $y_tu_{t,h}$ the argument fails: $y_t$ contains $\varepsilon_{t-k+1},\dots,\varepsilon_t$, which can pair with $u_{t-k,h}$.
- The feasible regressor $\hat\varepsilon_t$ differs from $\varepsilon_t$ by $(\hat\rho-\rho)y_{t-1}$; MOPM's Lemma A.3 controls that term uniformly.

**D5. Lag augmentation as FWL (`eq-l05-la-identity`) and the as-coded truths.**

- *Identity.* $y_{t+h}=\rho^hy_t+u_{t,h}=\rho^h(\rho y_{t-1}+\varepsilon_t)+u_{t,h}=\beta_h\varepsilon_t+\rho^{h+1}y_{t-1}+u_{t,h}$. Regressing on $(y_t,y_{t-1})$ spans the same space as $(\varepsilon_t,y_{t-1})$, so the coefficient on $y_t$ equals that on $\varepsilon_t$.
- *Check* (`fwl_l05.do`, seed 20260913, $T=240$, $\rho=0.95$, $h=6$, 233 rows): $\hat\beta=0.9895046509644059$ vs $0.9895046509644094$. HC1 s.e. $0.1551235260563434$ vs $0.1551235260563454$ after rescaling by $\sqrt{232/230}$. First-order autocorrelation of $\hat\varepsilon_t$: $-0.0165$.
- *Truths.* For $\mathbf A=\begin{pmatrix}\rho&0\\\psi&\rho\end{pmatrix}$, $\mathbf A^h=\begin{pmatrix}\rho^h&0\\h\psi\rho^{h-1}&\rho^h\end{pmatrix}$. The impact vector is $(1,\tfrac12)'$ because $\operatorname{Cov}(e_1,e_1+e_2)/\operatorname{Var}(e_1+e_2)=\tfrac12$. Hence $\beta_h=\rho^{h-1}(\rho/2+\psi h)$.
- *Truth check.* IJK: 0.5, 0.75, 0.805, 0.7595, 0.66885. JT: 0.5, 0.625, 0.70125, 0.740563, 0.752303. Both equal `bench_ijk.csv` / `bench_jt.csv` column `btrue` at float precision.

**D6. Coverage from two ratios (`eq-l05-coverage-approx`).**

- *Approximation.* If $(\hat\beta_h-\beta_h)/\sigma_h\approx N(d_h,1)$ and $\operatorname{se}\approx\varsigma_h\sigma_h$, then coverage $\approx\Phi(z\varsigma_h-d_h)-\Phi(-z\varsigma_h-d_h)$. With $\varsigma_h=1$ this is Lecture 7's biased-band formula $\Phi(1.96-d_h)-\Phi(-1.96-d_h)$, which should cite this equation rather than re-derive it.
- *Special cases.* $\varsigma=1,d=0$ gives 0.95; $\varsigma=0.86,d=0$ gives 0.908; $\varsigma=0.53,d=0$ gives 0.701.
- *One factor at a time.* Standard error only: $\Phi(z\varsigma_h)-\Phi(-z\varsigma_h)$. Bias only: $\Phi(z-d_h)-\Phi(-z-d_h)$.
- *Against simulation* ($R=500$):

| Cell | $\varsigma_h$ | $d_h$ | Predicted | S.e. only | Bias only | Simulated |
|---|---|---|---|---|---|---|
| JT, $h=12$, NW(6) | 0.892 | $-0.401$ | 0.895 | 0.920 | 0.931 | 0.874 |
| JT, $h=12$, LA-HC3 | 0.933 | $-0.402$ | 0.910 | 0.933 | 0.931 | 0.882 |
| AR(1) $\rho=1$, $h=12$, LA-HC3 | 0.858 | $-0.861$ | 0.788 | 0.907 | 0.862 | 0.752 |
| AR(1) $\rho=1$, $h=12$, non-augmented NW | 0.523 | $-1.329$ | 0.371 | 0.695 | 0.735 | 0.418 |

- *Reading.* It ignores the randomness of the s.e. and its correlation with $\hat\beta$.

**D7. Monte Carlo arithmetic.**

- $\sqrt{0.95\cdot0.05/R}=0.01541$, $0.00975$, $0.00689$ at $R=200$, 500, 1,000. At 90%, $R=500$ gives 0.0134, and the s.e. of a difference with MOPM's 5,000 is 0.0141 (0.0104 at $R=1{,}000$).
- $P(\text{hits}\le55\mid n=60,p=0.95)=0.1803$; for $\le52$ it is 0.0098.
- $2\sqrt{0.0475/R}\le0.025$ requires $R\ge304$.
- Independence benchmark: $0.95^5=0.77378$, $0.95^{13}=0.51334$, $0.95^{49}=0.08099$.

**D8. The bivariate design with $\rho=1$ is outside MOPM Definition 1.**

- Definition 1 requires $\mathbf A(L)=\mathbf B(L)(\mathbf I-\operatorname{diag}(\rho_i)L)$ with $\mathbf B(L)$ of order $p-1$ and geometrically stable.
- With $p=1$, $\mathbf B=\mathbf I$, so $\mathbf A_1$ must be diagonal; here it has $\psi\ne0$.
- Writing the system as a VAR(2) forces either $\mathbf A_1$ diagonal or a $\mathbf B_1$ with eigenvalue $-1$, which is not stable.
- Economically, $s_t$ is a random walk and $y_t=\psi s_{t-1}+y_{t-1}+e_{1,t}$ is I(2), two unit roots in the response variable. Coverage 0.452 (LA-HC3, $R=500$) at $h=12$, $T=150$ is outside the theorem, not a counterexample.

---

## 7. HTML lab plan (Confidence-Interval Coverage Simulator)

Four labs in Observable JS, following predict → manipulate → observe → explain → transfer.

Live draws come from `mulberry32(seed)`. Innovations are generated once per seed at the largest $T$ the lab offers, plus burn-in; the first $T$ rows are used, and outcomes are rebuilt when $\rho$ changes. Changing a procedure, bandwidth, $h$, $T$ or a parameter therefore never redraws shocks. Every panel is labelled "live calculation" or "stored result (Stata 19.5, $R$, seed, do-file)". The browser OLS/HC3/NW routine is validated against Stata on an exported draw ($\hat\beta$, s.e. to $10^{-8}$) before release (blueprint §5.3).

**Lab 1 — Hit or miss.**

- *Question.* Does the narrower interval cover more often?
- *Invariants.* Truth from §6 D5; the sample set is fixed while procedures change.
- *Controls.* Design (JT as coded, default; IJK; AR(1)); $\rho$ 0–1 (0.95); $T$ 150/300 (300); $h$ 0–12 (6); NW($m$) with $m$ 0–12 (6), HC3, LA-HC3; samples 20/60/200 (60); seed (20260913).
- *Computation.* By default the lab loads 60 stored Stata samples, so lab and `fig-l05-hit-miss` agree. The build reruns the seed-20260913 draws, saves each sample's $s_t$ and $y_t$, and checks that the first 60 reproduce `hitmiss_h6_rho95.csv`, which holds only $\hat\beta_6$ and the NW(6), HC3 and LA-HC3 standard errors. Changing the procedure, bandwidth or $h$ recomputes on these stored samples, labelled "live calculation on stored Stata draws". Only design, $\rho$, $T$, sample count or seed switch to live draws.
- *Reactive sentence.* "Of 60 samples, NW(6) covered 55 (0.917 ± 0.036) with mean width 0.532; LA-HC3 covered 58 (0.967 ± 0.023), width 0.564. At true coverage 0.95, 55 or fewer hits occur 18% of the time, so these samples cannot rank the two."
- *Comparisons.* Change only the procedure (same stored samples); raise samples to 200 (live draws); raise $\rho$ with $T$ fixed (live draws, same shocks).
- *Prediction.* "Which covers more often, the narrower or the wider interval?"

**Lab 2 — Residual or score?** (live)

- *Question.* Which autocorrelation decides the standard error?
- *Invariants.* One draw of $T=5{,}000$ fixed by seed.
- *Controls.* $\rho$ (0.95); $h$ 1–12 (6); augmentation on/off; innovations i.i.d. normal (default) or stochastic volatility $\tau_t\varepsilon_t$ (MOPM footnote 3(a)); MA(1) contamination $\theta$ 0–0.8 (0), an order the one-lag regression omits.
- *Output.* ACF bars (lags 1–12) for $u_{t,h}$ and both scores, theory markers from §6 D3, and a $\pm2/\sqrt T=\pm0.028$ band.
- *Reactive sentence (template).* "Residual lag-1 autocorrelation $\{\cdot\}$, non-augmented score $\{\cdot\}$; augmented score at most $\{\cdot\}$, inside the band, so HC suffices."
- *Comparisons.* Toggle augmentation; lower $\rho$ to 0.5; set $\theta=0.5$ with augmentation on and watch the lag-1 bar return.

**Lab 3 — Coverage map** (stored results)

- *Question.* Where does each procedure keep its promise?
- *Stored cells* (each panel labelled "stored result (Stata 19.5, $R=500$, seed, do-file)": `mc_cov.do` seeds 20260501–06, `mc_l05.do` seed 20260913, `mc_ar1.do` seeds 20260511–13). Bivariate design ($\psi=0.4$) at ($\rho,T$) = (0.7,150), (0.85,300), (0.95,150), (0.95,300), (1,150), (1,300), $h=0..12$, NW($m=h$)/HC3/LA-HC3; JT design; AR(1) at 95% ($h=1,6,12$) and 90% ($h=1,6,12,36,60$) with MOPM Table 1 overlaid.
- *Controls.* design, $\rho$, $T$, procedures, level. Cells with $\rho=1$ in the bivariate design carry an "outside Definition 1" badge.
- *Reactive sentence.* "IJK design, $T=150$, $\rho=0.95$, $h=12$: NW covers 0.654, LA-HC3 0.748 (MC s.e. 0.019); LA is 21% wider. At $T=300$: 0.852 and 0.888."
- *Comparisons.* Fix $h$ and vary $\rho$; fix $\rho$ and double $T$; same $\rho$ in the bivariate design versus the AR(1) (augmentation matters only in the latter).

**Lab 4 — Predict, then run** (live, $R\le500$ in a web worker)

- *Question.* Can you forecast coverage and width before simulating?
- *Controls.* As Lab 1, plus $R$ 100/200/500 (default 200) and prediction sliders for each procedure's coverage and for the width ratio.
- *Output.* Achieved versus predicted, with MC s.e.
- *Reactive sentence.* "You predicted $\{0.93\}$ for LA-HC3; achieved $\{\cdot\}\pm\{\cdot\}$, $\{within/outside\}$ two Monte Carlo standard errors."
- *Stata handoff.* `l05_settings.do` (globals `design rho T h R seed`; scalars for the predictions) and the first draw as CSV. STA05 Task 2 runs the settings, validates the JS arithmetic on the CSV, and records the prediction error; a printable completion record follows.

## 8. Practicum plan

The scratch directory is `/private/tmp/claude-501/-Users-tylersotomayor-macro-local-projections/c072337f-0f2c-4cf4-bb71-22a0631666a1/scratchpad/design-05/`.

### REP05 — Newey–West versus lag-augmented intervals

| Item | Specification |
|---|---|
| Target | Inoue, Jordà, and Kuersteiner, "Inference for local projections", *Econometrics Journal* 29(1), 2–26, 2026 (doi 10.1093/ectj/utaf004; frozen as R03 in `VERIFIED.md`), Figure 2 and the section containing it (section numbers from the frozen version; page range to confirm, D31). Mapping note only: in FRBSF WP 2024-29 (August 2024) the design is §4.2, "Lag-augmentation of LPs" |
| Code | `Replication Code/Figure2.do`, repository commit `5e57e0b` (CC0). DGP block `set seed 12345` … `drop if _n <= $burn`; regressions and bands lines 70–85; plotted rows 89–109 |
| Estimates | $h=0..13$; plotted $h\le10$ |
| Data and vintage | Simulated inside the script, no data file |
| Kind | Exact numerical replication of the single realization (D9). Achieved coverage is a course-built statistical reproduction in STA05 |
| Tolerance | $10^{-5}$ for log-printed values; $10^{-6}$ for stored float series |
| Runtime | 0.779 s (18.5 benchmark); 1.25 s wall in 19.5 |

*Benchmark* (`REP05-pointwise-inference.csv`, 39 rows): values as in §1B; $N$ 149→136 (NW) and 148→135 (LA); the author's red band centers the LA-HC3 s.e. on the NW coefficient (e.g. $h=10$: $[-0.1188,\ 0.5428]$).

*D1 check.* The 19.5 rerun (`bench/bench.do`, same recursion and estimators) against the 18.5 CSV at $h=0..12$: max abs differences $3\times10^{-8}$ (coefficient), $3\times10^{-8}$ (NW s.e.), $6\times10^{-8}$ (LA coefficient), $4\times10^{-8}$ (LA s.e.); $N$ identical. $h=13$ is compared in the build.

*Departures.* None in author code. `replication/rep05.do` adds three things:

1. the as-coded truth (§6 D5);
2. an LA interval centered on its own coefficient beside the author's construction;
3. discrepancy-log rows for the sequential `replace` (specification), the mixed centering with a one-row $N$ difference (presentation), and the JT working-paper matrix, burn-in and $T$ text versus code (documentation, if Example 4 is shown).

*Achieved coverage.* Instructor build and stored result at $R=500$ (D2, seed 20260501): at $h=8$, 0.858 / 0.898 / 0.892.

*Redistribution (D5).* `Figure2.do` ships unmodified in `replication/original/` (CC0). The MOPM MIT package is not executed or shipped (link only). The corrigendum PDF has no recorded redistribution licence (`packages/lag-augmented-lp/SOURCE.md`), so it is linked, not shipped.

### STA05 — lab project `practica/p05-pointwise-inference/lab-project/`

Layout: `master.do`; `code/lp_programs.do` (`rclass` programs `lpsim_var`, options `t rho psi h burn`, and `lpsim_ar1`, options `t rho hlist`, returning `b_h se_nw_h se_hc3_h bla_h sela_h`); `code/cover_summary.do` (coverage, width, MC s.e., $\varsigma_h$, $d_h$); `data/raw/sigband_shelterinf.dta` with `PROVENANCE.md` (CC0; SHA-256 `efb9c72a…3832`); `replication/`; `expected/` (19.5 outputs at $R=200$); `starter/pset.do` (`TASK 1`–`TASK 4`); `solution/`; `tests/checks.do`; `handoff/`; `output/`.

Tasks, runtimes and checks:

| Task | Work | Runtime | Assertions and expected outputs |
|---|---|---|---|
| 1. Construct | Twelve-row HC/NW by Mata and `newey`; FWL identity (§6 D2, D5) | seconds | Mata = `newey` within $10^{-12}$; identity within $10^{-10}$ |
| 2. Estimate | IJK design, $R=200$, seed 20260913, three `simulate` calls at $(\rho,T)=(0.7,150)$, $(0.95,150)$, $(0.95,300)$; then Lab 4's `l05_settings.do` | 39.8 s + 39.8 s + 44.1 s | Match `expected/cov_r07_T150_R200.csv`, `cov_r095_T150_R200.csv` and `cov_r095_T300_R200.csv` within $10^{-6}$ (otherwise within 2 MC s.e. of the $R=500$ build). $(0.7,150)$ NW/HC3/LA coverage: $h=0$ 0.950/0.960/0.955; $h=4$ 0.890/0.905/0.905; $h=8$ 0.850/0.925/0.930; $h=12$ 0.865/0.920/0.925. At $\rho=0.95$, $h=12$: $T=150$ 0.690/0.775/0.775; $T=300$ 0.870/0.895/0.885. `assert` that NW and LA-HC3 coverage at $\rho=0.95$, $h=12$ rise from $T=150$ to $T=300$, and that NW at $h=12$, $T=150$ falls from $\rho=0.7$ to $0.95$ |
| 3. Diagnose | AR(1), $\rho\in\{0.5,0.95,1\}$, $h\in\{1,6,12\}$, $R=200$; separate movement in $\hat\beta$ from movement in s.e. | about 45 s | $\rho=0.95$, $h=12$: 0.755/0.375/0.885. $\rho=1$, $h=12$: 0.450/0.110/0.805, with mean bias $-0.222\to-0.173$ while width $0.144\to0.827$. `assert` LA/HC width ratio $>2.5$ at $\rho\ge0.95$, $h\ge6$ |
| 4. Interpret | Shelter D7 path under NW(48), NW($m=h$), HC3, LA-HC3; predictability test; 300-word defence and a paragraph on what the simulations cannot generalize (DGP, $h/T$, observed-shock argument, IV, panels) | 112 s | Checks from exercise 8 |

`master.do`: about 5 minutes (D2; Task 2's two added cells add 84 s).

**Handoff.** Lab 4 exports settings and a prediction; Task 2 tests them; the lab record reports the prediction error.

**Submission package.** Replication record (target, versions, benchmark table, D1 row, discrepancy log); Stata submission (`master.do`, log, `output/`, assertions); interpretation record (estimand, units, supporting result, nominal versus achieved coverage with $R$ and MC s.e., limits); lab record (predictions, settings, completion record).

## 9. Slides arc

1. *Title.* Does a band tell the truth about repeated samples?
2. *Two bands, one path.* Shelter, month 48: $[-7.20,-0.04]$ versus $[-9.71,2.12]$.
3. *What 95% promises.* Coverage belongs to the procedure; sixty hit-or-miss intervals.
4. *Overlap.* $u_{t,h}$ shares future shocks.
5. *Newey–West in one table.* Twelve rows, Bartlett weights, bandwidth.
6. *Residual versus score.* The augmented score is flat.
7. *One index appears once.* Assumption 1 in three lines.
8. *Lag augmentation.* $y_{t+h}=\beta_h\varepsilon_t+\rho^{h+1}y_{t-1}+u_{t,h}$.
9. *Fine print.* Parameter space, horizon range, 2026 corrigendum.
10. *REP05.* IJK Figure 2 and the truth as coded.
11. *Coverage map.* NW falls with $h$ and $\rho$; LA holds longer; $\rho=1$ lies outside.
12. *Width is not reliability.* The narrowest AR(1) interval covers 10%.
13. *Choosing and defending.* The shelter decision; scope for IV and panels.
14. *Lab and practicum.* Predict, run, hand off.
15. *Next.* Five intervals: $0.95^5=0.774$ only under independence.

## 10. Open questions for the editor

1. **Spine opening.** The spine says the bands differ "by a factor of two at long horizons"; under D7 the ratio peaks at 1.65 (month 48), and the gap is NW versus HC, not the extra lag. Amend the spine or accept these numbers?
2. **Notation ledger.** $u_{t,h}$ is "MA($h$) by construction", but it is MA($h-1$) when the regressor absorbs the date-$t$ innovation (AR(1), $h=6$: lag-6 autocorrelation 0.011). Change to "at most MA($h$)"?
3. **Seam with Lecture 6.** Resolved: L06 §1 now quotes the benchmark (month 48 only, $[-7.201,-0.035]$ with `newey` s.e., $t=-1.979$; $-1.921$ and $-1.841$ at months 47 and 46).
4. **Published labels.** In IJK Figure 2 and JT Example 4 the one-lag regression already has an innovation regressor (score autocorrelation $\le0.008$; HC3 within 0.012 of LA-HC3 in all twelve grid cells at $h=6,12$, $R=500$), so the "lag-augmented" band differs mainly by using HC. May the notes say so neutrally, citing do-file lines?
5. **LA default.** HC3 (IJK, JT) or HC1 (MOPM's EHW)? HC3 covers 0.000–0.014 more in the MOPM reproduction ($R=500$).
6. **Stored results.** Resolved per D2. Every quoted and stored coverage cell is now the $R=500$ build: the first 500 replications of the seeded $R=1{,}000$ runs, identical to `global R 500` (`run3/r500/`; about 180–300 s per cell). The $R=1{,}000$ runs (515–599 s per cell) stay in the scratch directory as authoring evidence; they are quoted only for the MOPM gap logged in anchor D.
