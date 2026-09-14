# Course notation ledger

This ledger is the single source of notation for every lecture, exercise,
solution, figure, slide, playground, and practicum in *Local Projections: From
First Principles to Empirical Research*. A lecture may introduce new symbols
for objects that only it needs, but it may not reassign a symbol listed here.
When a symbol is introduced in prose, the lecture should read it aloud once and
state its units, timing, and conditioning.

Where the course follows a specific reference convention, the source is named
so students can move between the notes and the readings without translation.

## 1. Time, horizon, and the projection

| Symbol | Meaning | Convention and notes |
|---|---|---|
| $t$ | Calendar time index of an observation, $t=1,\dots,T$ | The regression *row* is dated $t$, the date of the intervention. |
| $T$ | Length of the time series | Not to be confused with $T_h$, the horizon-$h$ estimation sample size. |
| $h$ | Horizon, $h=0,1,\dots,H$ | Number of periods after $t$ at which the outcome is measured. $h=0$ is the impact period. |
| $H$ | Maximum horizon estimated | Chosen by the researcher; every claim "over the first year" fixes an $H$. |
| $y_t$ | Outcome variable at date $t$ | Units stated at first use (level, log × 100, percent, percentage points, ratio to trend). |
| $s_t$ | Intervention variable dated $t$ | Generic name for the right-hand-side variable whose response we want: an observed shock, a policy action, a treatment switch. It is called a *shock* only once identification has been argued. Follows the blueprint's $s_t$. |
| $\mathbf w_t$ | Vector of predetermined controls dated $t$ or earlier | Contains lags of $y$, lags of $s$, and other pre-shock variables. Written as a column vector; individual controls $w_{j,t}$. |
| $p$ | Number of lags in $\mathbf w_t$ | "Lag length." Lag augmentation adds one more lag of $y$ beyond the lags needed for identification. |
| $\beta_h$ | Population local-projection coefficient on $s_t$ at horizon $h$ | What a local projection targets: the coefficient on $s_t$ in the population linear projection of $y_{t+h}$ on $(1, s_t, \mathbf w_t)$. The causal estimand is $\theta_h$; the two coincide under the identifying assumptions (D56). |
| $\hat\beta_h$ | OLS (or 2SLS) estimate of $\beta_h$ | Always distinguished from $\beta_h$ in prose and figures. |
| $\theta_h$ | Causal (structural) impulse response at horizon $h$ | The difference between the outcome path with and without the intervention. $\beta_h=\theta_h$ only under the identifying assumptions stated in Lecture 3. In nonlinear settings (Lecture 10) $\theta_h$ is a function of the shock size. |
| $\mu_h$ | Intercept of the horizon-$h$ regression | The blueprint's $\alpha_h$; renamed so that $\alpha$ can denote a significance level. |
| $\boldsymbol\gamma_h$ | Coefficient vector on $\mathbf w_t$ at horizon $h$ | Nuisance coefficients; never interpreted as responses. |
| $u_{t,h}$ | Horizon-$h$ projection residual in row $t$ | Contains the disturbances dated $t,\dots,t+h$ that the regressors do not absorb and the shocks dated $t+1,\dots,t+h$, so it is at most MA($h$) (D36). Written with two subscripts to remind the reader that it belongs to row $t$ of the horizon-$h$ regression. |
| $v_t,\ \sigma_v$ | Outcome disturbance in a simulated model and its standard deviation | Lecture 1 onward (D36). |
| $\theta_0$ | Impact response | $\theta_h$ at $h=0$. |
| $y^{c}_t$ | Counterfactual outcome path | The path without the intervention; $\theta_h$ compares $y_{t+h}$ with $y^{c}_{t+h}$. |
| $\mathcal T_h$, $T_h$ | Estimation sample for horizon $h$ and its size | $T_h=T-h-p$ when leads and lags are the only source of missingness. A *common sample* uses $\mathcal T_H$ at every horizon. |

The canonical horizon-$h$ regression is therefore

$$
y_{t+h}=\mu_h+\beta_h s_t+\boldsymbol\gamma_h'\mathbf w_t+u_{t,h},\qquad h=0,1,\dots,H,
$$

and the impulse response is the sequence $\{\hat\beta_h\}_{h=0}^{H}$.

## 2. Transformations and accumulation (Lecture 2)

| Symbol | Meaning | Notes |
|---|---|---|
| $\Delta y_t$ | First difference, $y_t-y_{t-1}$ | |
| $y_{t+h}-y_{t-1}$ | Long difference from the pre-intervention level | The telescoping identity $y_{t+h}-y_{t-1}=\sum_{j=0}^{h}\Delta y_{t+j}$ is the algebraic link between differenced and long-difference LPs. |
| $B_h$ | Cumulative response through horizon $h$, $B_h=\sum_{j=0}^{h}\beta_j$ | "Accumulated response." Capital $B$; its estimate is $\hat B_h$. |
| $\beta^{Y}_h,\ \beta^{G}_h$ | Responses of two different outcomes to the same intervention | Superscripts name the outcome (e.g. output $Y$, government spending $G$). |
| $M_H$ | Cumulative multiplier through horizon $H$, $M_H=B^{Y}_H/B^{G}_H$ | A ratio of two accumulated responses; requires both in the same units. |
| $\sigma_s$ | Standard deviation of the intervention variable | Used when responses are normalized to a one-standard-deviation shock; available from Lecture 1. |
| $\beta^{\mathrm{LD}}_h,\ \beta^{\Delta}_h,\ \beta^{\Sigma}_h,\ \beta^{\mathrm{lag}}_h$ | Coefficients for transformations of one outcome: long difference, period change, accumulated level, and $y_{t-1}$ on $s_t$ | Distinct from outcome superscripts such as $\beta^{Y}_h$ (D36). |
| $\Xi_s$ | Constant by which a shock is rescaled | Lecture 2 (D36). |

Units vocabulary: *percent* changes come from logs × 100; *percentage points* are differences of rates; "a 1 percent of GDP shock" means the intervention is measured as a ratio to (trend) GDP.

## 3. Identification (Lectures 3–4)

| Symbol | Meaning | Notes |
|---|---|---|
| $\varepsilon_t$ | The structural shock of interest at date $t$ | Latent; $s_t$ is an observed measure, action, or proxy for it. |
| $\boldsymbol\varepsilon_t$ | Vector of all structural shocks at $t$ | $\varepsilon_{1,t}$ is the shock of interest when a vector is needed. |
| $\Omega_{t-1}$ | Information available just before the intervention | The pre-shock information set that $\mathbf w_t$ is meant to span. |
| $z_t$ | External instrument for $s_t$ | Lecture 4. |
| $\pi$ | First-stage coefficient of $s_t$ on $z_t$ | First-stage strength is reported as the robust $F$ statistic. |
| $\beta_h^{\mathrm{IV}}$ | LP-IV estimand, $\operatorname{Cov}(y_{t+h},z_t\mid\mathbf w_t)/\operatorname{Cov}(s_t,z_t\mid\mathbf w_t)$ | The ratio of two reduced-form projections. |

Identifying assumptions are numbered per lecture (A1, A2, …) with stable anchors `#assumption-lNN-aK`; later lectures cite them by number and lecture.

## 4. Inference (Lectures 5–6)

| Symbol | Meaning | Notes |
|---|---|---|
| $\alpha$ | Significance level; $1-\alpha$ is the nominal confidence level | Reserved; never an intercept. |
| $\operatorname{se}(\hat\beta_h)$ | Standard error of $\hat\beta_h$ | The estimator (HC, HAC, lag-augmented, clustered) is always named beside it. |
| $m$ | HAC bandwidth (lag truncation) | Newey–West with $m$ lags; the "rule" $m=h$ is a convention, not a theorem. |
| $\rho$ | Persistence parameter of a simulated AR(1) | Used in every Monte Carlo; $\rho=1$ is the unit-root case. |
| $R$ | Number of Monte Carlo replications | Students $R=200$, instructor builds $R=500$ by default (D2). |
| $\hat{\boldsymbol\beta}$ | Stacked vector $(\hat\beta_0,\dots,\hat\beta_H)'$ | $(H+1)\times 1$. |
| $\boldsymbol\Sigma$ | Covariance matrix of $\hat{\boldsymbol\beta}$ across horizons | $(H+1)\times(H+1)$; its off-diagonal elements are what a pointwise interval ignores. |
| $z_{1-\alpha/2}$ | Standard normal critical value for a pointwise interval | |
| $c_{1-\alpha}$ | Critical value of a simultaneous (sup-$t$) band | Computed from $\boldsymbol\Sigma$; satisfies $c_{1-\alpha}\ge z_{1-\alpha/2}$. |
| $\mathcal H$ | A set of horizons named in a claim | "Negative throughout the first year" is a claim about $\mathcal H=\{0,\dots,4\}$ at quarterly frequency. |

Coverage vocabulary: *nominal* coverage is $1-\alpha$; *achieved* (or *actual*) coverage is the Monte Carlo frequency with which the interval contains the true value.

## 5. Estimator comparison and smoothing (Lectures 7–8)

| Symbol | Meaning | Notes |
|---|---|---|
| $\mathbf y_t$ | Vector of variables in a VAR | Bold lowercase for vectors of series. |
| $\mathbf A(L)$ | VAR lag polynomial, $\mathbf A(L)=\mathbf A_1L+\dots+\mathbf A_pL^p$ | $L$ is the lag operator. |
| $\theta^{\mathrm{LP}}_h,\ \theta^{\mathrm{VAR}}_h$ | Population responses implied by the LP and by the VAR | Equal in population under the Plagborg-Møller–Wolf conditions; the superscripts matter only for estimators, $\hat\theta^{\mathrm{LP}}_h$ versus $\hat\theta^{\mathrm{VAR}}_h$. |
| $\mathbf S$ | Residual covariance matrix of a VAR | Keeps $\boldsymbol\Sigma$ free for the cross-horizon covariance of $\hat{\boldsymbol\beta}$ (D20). |
| $\mathbf A_{\mathrm c}$ | Companion matrix of a VAR | Lecture 7. |
| $\omega^{*}_h$ | Bias weight at which LP and VAR have equal loss at horizon $h$ | Lecture 7. |
| $\operatorname{Bias},\ \operatorname{Var},\ \operatorname{MSE}$ | Bias, variance, and mean squared error of an estimator at horizon $h$ | Reported per horizon and, when summarized, as an average over horizons with the averaging stated. |
| $b_k(h)$ | Linear basis function $k$ evaluated at horizon $h$ | B-splines in Barnichon–Brownlees. Reserved for linear expansions (D20). |
| $a,\ h^\star,\ c$ | Amplitude, peak horizon, and width of the Gaussian response $a\exp\{-(h-h^\star)^2/c^2\}$ | A three-parameter parametric family, not a linear basis expansion (D21). Jordà–Taylor's code calls the peak $b$. |
| $r$ | Order of the roughness penalty | Course default $r=2$, shrinkage toward a line (D23). |
| $\delta_k$ | Coefficient on basis function $k$ | The restricted response is $\beta_h=\sum_{k=1}^{K}\delta_k b_k(h)$. |
| $K$ | Number of basis functions | |
| $\lambda$ | Smoothing penalty | Larger $\lambda$ imposes more smoothness; $\lambda=0$ recovers the unrestricted LP within the basis. |

## 6. State dependence and nonlinearity (Lectures 9–10)

| Symbol | Meaning | Notes |
|---|---|---|
| $I_{t-1}$ | State indicator dated $t-1$, $I_{t-1}\in\{0,1\}$ | $I_{t-1}=1$ in the "slack" (or high-unemployment) state, following Ramey–Zubairy. Dated $t-1$ so that the state is predetermined. |
| $\beta^{A}_h,\ \beta^{B}_h$ | Responses in state $A$ ($I=1$) and state $B$ ($I=0$) | Reported with the direct difference $\beta^{A}_h-\beta^{B}_h$ and its standard error. |
| $s^{+}_t,\ s^{-}_t$ | Positive and negative parts of the intervention, $s^{+}_t=\max(s_t,0)$, $s^{-}_t=\min(s_t,0)$ | Sign asymmetry. |
| $\theta_h(e)$ | Marginal response at horizon $h$ when the shock equals $e$ | Lecture 10; a function, not a number. |
| $\varpi$ | State-feedback parameter in the Lecture 9 simulation | $\lambda$ stays the smoothing penalty (D36). |
| $\omega_h(e)$ | Weight the linear LP places on $\theta_h(e)$ | Nonnegative, integrates to one under the Kolesár–Plagborg-Møller conditions; $\beta_h=\int\omega_h(e)\,\theta_h(e)\,de$. |
| $f_s$ | Density of the shock | Changing $f_s$ changes $\omega_h$ and hence $\beta_h$ even when $\theta_h(\cdot)$ is fixed. |

## 7. Panels and LP-DiD (Lectures 11–12)

| Symbol | Meaning | Notes |
|---|---|---|
| $i$, $N$ | Unit index and number of units | Countries, states, firms. |
| $y_{i,t+h}$, $s_{i,t}$ | Outcome and intervention for unit $i$ | The same letters as the time-series case, with a unit subscript. |
| $\eta_i$ | Unit fixed effect | Not $\alpha_i$. |
| $\phi_t$ | Time fixed effect | Horizon-specific when needed: $\phi^{(h)}_t$. |
| $e_i$ | Exposure of unit $i$ to a common shock | The interaction $e_i s_t$ is what survives time fixed effects. |
| $D_{i,t}$ | Absorbing treatment indicator, $D_{i,t}\in\{0,1\}$ | Lecture 12. |
| $g_i$ | Treatment date (cohort) of unit $i$; $g_i=\infty$ if never treated | |
| $\Delta D_{i,t}$ | Treatment switch, equal to one in the period unit $i$ enters treatment | The LP-DiD regressor. |
| $k$ | Event time, $k=t-g_i$ | |
| $\theta^{\mathrm{EW}}_h$, $\theta^{\mathrm{VW}}_h$ | Equally weighted and variance-weighted average effects on the treated at horizon $h$ | Averages over treated cohorts (D37); which one an LP-DiD regression targets depends on the weighting scheme. |

Inference vocabulary for panels: *clustered by unit*, *Driscoll–Kraay*, and *two-way clustered* are named explicitly; "robust" alone is never sufficient.

## 8. Counterfactuals and sensitivity (Lecture 13)

| Symbol | Meaning | Notes |
|---|---|---|
| $M^{0}$ | Hypothesized multiplier in an Anderson–Rubin inversion | Lectures 4 and 13; $m$ stays the HAC bandwidth (D36). |
| $\{s^{c}_{t+j}\}_{j\ge 0}$ | A proposed counterfactual path of the intervention | Superscript $c$ marks counterfactual objects. |
| $y^{0}_{t+h}$, $y^{c}_{t+h}$ | Baseline and counterfactual outcome paths | The counterfactual path is $y^{c}_{t+h}=y^{0}_{t+h}+\sum_{j=0}^{h}\theta_{h-j}\,(s^{c}_{t+j}-s^{0}_{t+j})$ under linearity and policy invariance of $\theta$. |
| $\mathcal S$ | A pre-specified set of specifications | A sensitivity grid is a list of elements of $\mathcal S$ together with the sample used for each. |
| $[t_0,t_1]$ | Estimation window | Sample changes and specification changes are reported separately. |

## 9. Typographic conventions

- Vectors are bold lowercase ($\mathbf w_t$), matrices bold uppercase ($\boldsymbol\Sigma$), scalars italic.
- Estimates carry hats; population objects do not. Sample averages carry bars.
- Expectations and variances name their conditioning set at least once per section: $\mathbb E[\,\cdot\mid\Omega_{t-1}]$.
- Equations are numbered only when referenced later; labels use `eq-lNN-slug`, figures `fig-lNN-slug`, tables `tbl-lNN-slug`, sections `sec-lNN-slug`, exercises `exercise-lNN-K`, assumptions `assumption-lNN-aK`, where `NN` is the two-digit lecture number.
- Stata variable names in the practica mirror the notation: `y`, `s`, `w1`–`wp`, `h`, `beta_h`, `se_h`, `B_h`, `z` (instrument), `I_lag` (state), `D` and `dD` (treatment level and switch).
