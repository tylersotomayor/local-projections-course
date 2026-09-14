# P01 · STA01 solved: the instructor record

*Local Projections: From First Principles to Empirical Research*, Practicum 01,
"Recover the Basic LP Estimator." Written 2026-09-13 from the executed build.

Published on 2026-09-14 under editor decision D54, which makes the solved
problem set and the answer key public. The solved tasks, with their code, log
excerpts, and figures, are also section 2 of the instructor build page. When
this record was written the build stage kept the solution outside the public
repository; the paths below are the public ones.

## The runs

| Run | Draws | Result | Runtime |
|---|---|---|---|
| Instructor build, `do master.do solution` in `practica/p01-question-to-projection/lab-project/` | $R=500$ | 200 assertions passed (49 checks, 65 REP01, 48 STA01, 38 handoff), none failed | 137.1 s by Stata's timer; STA01 72.3 s |
| Student archive unzipped into an empty folder, solution copied in, `global R 200` | $R=200$ | 194 assertions passed (45 checks, 65 REP01, 46 STA01, 38 handoff); `get_rz.do` downloaded and verified the Ramey–Zubairy files | 59.2 s; STA01 31.7 s |
| Student archive unzipped into an empty folder, `do master.do` with the unedited starter | $R=200$ | Checks and REP01 passed; the starter stopped at `FAIL  Task 1: T_h = 11 - h ...`; `do master.do solution` stopped with `r(601)` | 28 s wall |

The solution's own log and outputs from the instructor build are published in
`build/output/`: `pset.log`, both figures in SVG and PNG, the two caption
files, `not-yet-argued.txt`, and `sta01-news-shares.csv`. The datasets it
writes are not published; `do master.do solution` regenerates them. The do-file
is `lab-project/solution/pset_solution.do`, which ships in the archive.

## The solution do-file

As shipped in `lab-project/solution/`. Its header comments were revised on
2026-09-14 for D54 and D55; every command below is the one the build ran.

```stata
*! pset_solution.do  STA01 . Instructor solution
*
*  Local Projections: From First Principles to Empirical Research, Practicum 01.
*  Shipped with the lab project. Attempt the tasks in starter/pset.do first.
*
*  Solves the five tasks of starter/pset.do and passes every assertion in it.
*  The assertions are identical to the starter's, in the same order; only the
*  lines marked TASK in the starter are filled in, plus the written answers
*  (the two captions and the five-sentence paragraph).
*
*  Task 5 scales by trend GDP, the series rgdp_pott6, which Ramey and Zubairy
*  call potential GDP and estimate as a sixth-degree polynomial trend in real
*  GDP.
*
*  Writes output/pset/: pset.log, results_hand.dta, results_onedraw.dta,
*  mc_draws.dta, mc_R200_summary.dta (and mc_R500_summary.dta when R >= 500),
*  first_contact.dta, sta01-news-shares.csv, fig-sta01-one-draw.svg/.png,
*  fig-sta01-first-contact.svg/.png, and the text files with the written answers.
*
*  Run through master.do (do master.do solution) or, from the top folder,
*  do solution/pset_solution.do

version 19
clear
set more off
capture program list lp_assert
if _rc do helpers/lp_helpers.do
lp_root
capture mkdir output
capture mkdir output/pset
capture log close pset
log using "output/pset/pset.log", text replace name(pset)
if "$R" == "" global R 200
global LP_STEP sta01
local R = $R
confirm integer number `R'
local npass0 = cond("$LP_NPASS" == "", 0, $LP_NPASS)
set scheme stcolor
timer clear 21
timer on 21
local ink    "82 81 78"
local blue   "42 120 214"
local orange "217 96 31"
local rule   "195 194 183"

*==========================================================================
* TASK 1 . Construct the rows for h = 0, 1, 2              (Exercise 3; Lab 2)
*==========================================================================
local handfile "data/raw/hand_table.csv"
capture confirm file "handoff/hand_table.csv"
if _rc == 0 {
    lp_sha256 "handoff/hand_table.csv"
    local sha_handoff "`r(sha256)'"
    lp_sha256 "data/raw/hand_table.csv"
    if "`sha_handoff'" == "`r(sha256)'" local handfile "handoff/hand_table.csv"
    else display as error "handoff/hand_table.csv differs from data/raw/hand_table.csv; Tasks 1-2 read data/raw."
}
display as text "Tasks 1 and 2 read `handfile'"
import delimited using "`handfile'", clear
tsset t

tempname H
postfile `H' h T_h n1 n0 first last using "output/pset/results_hand.dta", replace
forvalues h = 0/2 {
    generate double yh = F`h'.y
    generate byte inrow = (t >= 2 & yh < .)
    quietly count if inrow
    local T_h = r(N)
    quietly count if inrow & s == 1
    local n1 = r(N)
    quietly count if inrow & s == 0
    local n0 = r(N)
    quietly summarize t if inrow
    local first = r(min)
    local last  = r(max)
    display as text _n "h = `h': rows `first'-`last'"
    list t s y yh if inrow, clean noobs
    post `H' (`h') (`T_h') (`n1') (`n0') (`first') (`last')
    drop yh inrow
}
postclose `H'

use "output/pset/results_hand.dta", clear
list, clean noobs
lp_assert "Task 1: T_h = 11 - h at h = 0, 1, 2 (T = 12, p = 1)" : T_h == 11 - h
lp_assert "Task 1: every row is an intervention row or a comparison row" : n1 + n0 == T_h
lp_assert "Task 1: the rows run from t = 2 to t = 12 - h" : first == 2 & last == 12 - h
lp_assert "Task 1: 3 intervention rows at h = 0 and 2 at h = 1 and h = 2" : n1 == cond(h == 0, 3, 2)

*==========================================================================
* TASK 2 . Estimate the slopes from the rows                (Exercises 3-4)
*==========================================================================
import delimited using "`handfile'", clear
tsset t
tempname E
postfile `E' h double(ybar1 ybar0 b_hand b_reg b_ctrl) byte same_rows ///
    using "output/pset/results_hand_slopes.dta", replace
forvalues h = 0/2 {
    generate double yh = F`h'.y
    generate byte inrow = (t >= 2 & yh < .)

    quietly summarize yh if inrow & s == 1
    local ybar1 = r(mean)
    quietly summarize yh if inrow & s == 0
    local ybar0 = r(mean)

    quietly summarize s if inrow
    local sbar = r(mean)
    generate double num = (s - `sbar')*yh if inrow
    generate double den = (s - `sbar')^2 if inrow
    quietly summarize num
    local sum_num = r(sum)
    quietly summarize den
    local b_hand = `sum_num'/r(sum)

    quietly regress F`h'.y s if t >= 2
    local b_reg = _b[s]
    quietly count if e(sample) != inrow
    local mismatch = r(N)
    quietly regress F`h'.y s L.y if t >= 2
    local b_ctrl = _b[s]
    quietly count if e(sample) != inrow
    local same_rows = (`mismatch' + r(N) == 0)

    post `E' (`h') (`ybar1') (`ybar0') (`b_hand') (`b_reg') (`b_ctrl') (`same_rows')
    drop yh inrow num den
}
postclose `E'

use "output/pset/results_hand_slopes.dta", clear
merge 1:1 h using "output/pset/results_hand.dta", nogenerate assert(match)
save "output/pset/results_hand.dta", replace
format ybar1 ybar0 b_hand b_reg b_ctrl %12.8f
list h T_h ybar1 ybar0 b_hand b_reg b_ctrl same_rows, clean noobs
lp_assert "Task 2: the slope by hand equals the difference in means (1e-6)" : abs(b_hand - (ybar1 - ybar0)) < 1e-6
lp_assert "Task 2: regress returns the slope computed by hand (1e-6)" : abs(b_reg - b_hand) < 1e-6
lp_assert "Task 2: the regressions with and without y_(t-1) use the same rows" : same_rows == 1
lp_assert "Task 2: slopes without the control 0.617322, -0.983356, 2.050024 (1e-6)" : ///
    abs(b_reg - cond(h == 0, 0.617322, cond(h == 1, -0.983356, 2.050024))) < 1e-6
lp_assert "Task 2: slopes with y_(t-1) 0.575667, -1.050405, 2.153022 (1e-6)" : ///
    abs(b_ctrl - cond(h == 0, 0.575667, cond(h == 1, -1.050405, 2.153022))) < 1e-6

*==========================================================================
* TASK 3 . A response in a loop                            (Exercise 6; Lab 3)
*==========================================================================
local drawfile "data/raw/onedraw_rho09_seed2.csv"
capture confirm file "handoff/onedraw_rho09_seed2.csv"
if _rc == 0 {
    import delimited using "handoff/onedraw_rho09_seed2.csv", clear
    rename (s v y) (s_b v_b y_b)
    tempfile browser
    save `browser'
    import delimited using "data/raw/onedraw_rho09_seed2.csv", clear
    merge 1:1 t using `browser', nogenerate
    quietly count if missing(s_b) | abs(s - s_b) > 1e-7 | abs(v - v_b) > 1e-7 | abs(y - y_b) > 1e-7
    if r(N) == 0 local drawfile "handoff/onedraw_rho09_seed2.csv"
    else display as error "handoff/onedraw_rho09_seed2.csv differs from the shipped draw; Task 3 reads data/raw."
}
display as text "Task 3 reads `drawfile'"
import delimited using "`drawfile'", clear
tsset t
lp_assert "Task 3: the draw holds T = 200 periods" : _N == 200

tempname P
postfile `P' h double beta_h T_h using "output/pset/results_onedraw.dta", replace
forvalues h = 0/12 {
    quietly regress F`h'.y s L.y
    post `P' (`h') (_b[s]) (e(N))
}
postclose `P'

use "output/pset/results_onedraw.dta", clear
generate double theta_h = 0.9^h
format beta_h theta_h %9.6f
list, clean noobs
lp_assert "Task 3: T_h = 199 - h at every horizon" : T_h == 199 - h
lp_close beta_h[1] 0.878940, tol(1e-6) label(Task 3: beta_0 = 0.878940)
lp_close beta_h[13] -0.293297, tol(1e-6) label(Task 3: beta_12 = -0.293297)
quietly count if beta_h < theta_h
local below = r(N)
lp_assert "Task 3: the estimate lies below theta_h at all 13 horizons" : `below' == 13
save "output/pset/results_onedraw.dta", replace

*==========================================================================
* TASK 4 . Many draws, then the response graph and its caption   (Exercises 6-7)
*==========================================================================
display as text _n "Monte Carlo: R = `R' samples for each rho"
timer clear 22
timer on 22
tempname MC
postfile `MC' rep double rho h double(b_ctrl b_noctrl) n_ctrl n_noctrl ///
    using "output/pset/mc_draws.dta", replace
foreach rho in 0.5 0.9 {
    set seed 3                                   // once for each rho, outside the loop
    quietly forvalues r = 1/`R' {
        clear
        set obs 300
        generate t = _n
        tsset t
        generate s = rnormal()                   // all of s first,
        generate v = rnormal()                   // then all of v
        generate y = .
        replace y = s + v in 1                   // y_0 = 0
        replace y = `rho'*L.y + s + v in 2/300
        drop if t <= 100                         // burn-in of 100 periods
        replace t = _n
        tsset t
        forvalues h = 0/12 {
            regress F`h'.y s L.y
            local b_c = _b[s]
            local n_c = e(N)
            regress F`h'.y s
            post `MC' (`r') (`rho') (`h') (`b_c') (_b[s]) (`n_c') (e(N))
        }
    }
}
postclose `MC'
timer off 22
quietly timer list 22
display as text "Monte Carlo runtime: " as result %7.2f r(t22) as text " seconds for R = `R'"

use "output/pset/mc_draws.dta", clear
lp_assert "Task 4: 199 - h rows with the control and 200 - h without" : n_ctrl == 199 - h & n_noctrl == 200 - h
foreach m in 200 500 {
    if `R' >= `m' {
        preserve
        keep if rep <= `m'
        generate double theta_h = rho^h
        collapse (mean) theta_h mean_ctrl=b_ctrl mean_noctrl=b_noctrl      ///
                 (sd) sd_ctrl=b_ctrl sd_noctrl=b_noctrl                    ///
                 (p5) p5=b_ctrl (p95) p95=b_ctrl, by(rho h)
        generate double bias = mean_ctrl - theta_h
        generate double mcse = sd_ctrl/sqrt(`m')
        generate R = `m'
        format theta_h mean_* sd_* p5 p95 bias mcse %9.6f
        display as text _n "Summary of the first `m' samples"
        list rho h theta_h mean_ctrl bias mcse sd_ctrl p5 p95 mean_noctrl sd_noctrl, clean noobs
        save "output/pset/mc_R`m'_summary.dta", replace
        restore
    }
}
if `R' >= 200 {
    use "output/pset/mc_R200_summary.dta", clear
    quietly summarize mean_ctrl if rho == 0.9 & h == 8
    local m8 = r(mean)
    quietly summarize sd_ctrl if rho == 0.9 & h == 8
    local s8 = r(mean)
    lp_close `m8' 0.370337, tol(1e-6) label(Task 4: with R = 200 the mean at rho = 0.9 and h = 8 is 0.370337)
    lp_close `s8' 0.211226, tol(1e-6) label(Task 4: with R = 200 the standard deviation at rho = 0.9 and h = 8 is 0.211226)
    lp_assert "Task 4: without y_(t-1) the spread is larger at every h when rho = 0.9 (R = 200)" : sd_noctrl > sd_ctrl if rho == 0.9
}
else {
    use "output/pset/mc_draws.dta", clear
    quietly summarize b_ctrl if rho == 0.9 & h == 8
    local z = (r(mean) - 0.370337)/(r(sd)*sqrt(1/`R' - 1/200))
    lp_assert "Task 4: with R = `R' the mean at rho = 0.9 and h = 8 lies within 3 nested Monte Carlo SE of the R = 200 value" : abs(`z') < 3
}
if `R' >= 500 {
    use "output/pset/mc_R500_summary.dta", clear
    quietly summarize mean_ctrl if rho == 0.9 & h == 8
    local m8 = r(mean)
    quietly summarize sd_ctrl if rho == 0.9 & h == 8
    local s8 = r(mean)
    lp_close `m8' 0.397256, tol(1e-6) label(Task 4: with R = 500 the mean at rho = 0.9 and h = 8 is 0.397256)
    lp_close `s8' 0.228403, tol(1e-6) label(Task 4: with R = 500 the standard deviation at rho = 0.9 and h = 8 is 0.228403)
}

* The graph: this sample against the truth, with the simulated band.
local band = cond(`R' >= 500, 500, 200)
use "output/pset/results_onedraw.dta", clear
capture confirm file "output/pset/mc_R`band'_summary.dta"
if _rc == 0 {
    preserve
    use "output/pset/mc_R`band'_summary.dta", clear
    keep if rho == 0.9
    keep h p5 p95
    tempfile bandfile
    save `bandfile'
    restore
    merge 1:1 h using `bandfile', nogenerate
}
else {
    generate double p5 = .
    generate double p95 = .
}

local cap_intervention "Response of y to a one-unit intervention s_t, where one unit is one standard deviation because sigma_s = 1, estimated by local projections of y_(t+h) on a constant, s_t, and y_(t-1) in one simulated sample of T = 200 periods with rho = 0.9 (seed 2)."
local cap_outcome "The vertical axis is in units of y."
local cap_horizon "Horizons are periods after the intervention; h = 0 is the period in which it occurs."
local cap_counterfactual "The vertical axis measures the gap between the path with the intervention and the path without it, so zero means no different from that path, not y back where it started; the dashed line is the true response 0.9^h, and the band holds the middle 90 percent of estimates across `band' simulated samples (seed 3), which describes the estimator and is not a confidence interval."

twoway (rarea p5 p95 h, color("`blue'%15") lwidth(none))                               ///
       (line theta_h h, lcolor("`ink'") lpattern(dash) lwidth(medthick))              ///
       (connected beta_h h, lcolor("`blue'") mcolor("`blue'") msymbol(O) msize(small) lwidth(medthick)), ///
       yline(0, lcolor("`rule'")) xlabel(0(2)12)                                      ///
       ylabel(-0.4(0.2)1.2, format(%3.1f) angle(0) glcolor("`rule'"))                 ///
       xtitle("Horizon h (periods after the intervention)")                            ///
       ytitle("Gap from the no-intervention path (units of y)")                        ///
       legend(order(3 "Estimate, this sample" 2 "True response 0.9{sup:h}"            ///
                    1 "Middle 90 percent, `band' simulated samples") rows(1) position(6) ///
              size(small) region(lstyle(none)))                                        ///
       graphregion(color(white)) plotregion(color(white)) xsize(6.5) ysize(4.2)
graph export "output/pset/fig-sta01-one-draw.svg", replace
graph export "output/pset/fig-sta01-one-draw.png", replace width(1950)

tempname cf
file open `cf' using "output/pset/fig-sta01-one-draw-caption.txt", write text replace
file write `cf' `"`cap_intervention' `cap_outcome' `cap_horizon' `cap_counterfactual'"' _n
file close `cf'
foreach slot in intervention outcome horizon counterfactual {
    local len_`slot' = ustrlen(`"`cap_`slot''"')
}
lp_assert "Task 4: the caption names the intervention and its unit" : `len_intervention' >= 20
lp_assert "Task 4: the caption gives the outcome's units" : `len_outcome' >= 20
lp_assert "Task 4: the caption gives the horizon unit" : `len_horizon' >= 20
lp_assert "Task 4: the caption names the counterfactual" : `len_counterfactual' >= 20
capture confirm file "output/pset/fig-sta01-one-draw.svg"
local rc = _rc
lp_assert "Task 4: the response graph is exported to output/pset/fig-sta01-one-draw.svg" : `rc' == 0

*==========================================================================
* TASK 5 . Where the military-news coefficient's variation comes from
*          (Exercise 9; Lab 4)
*==========================================================================
do "data/raw/get_rz.do" "data/raw"
import excel using "data/raw/RZDAT.xlsx", sheet("rzdat") firstrow clear
drop if quarter < 1889
generate qdate = yq(1889, 1) + _n - 1
format qdate %tq
tsset qdate, quarterly
lp_assert "Task 5: 508 consecutive quarters, 1889Q1-2015Q4" : _N == 508 & abs(quarter - (1889 + (_n - 1)/4)) < 1e-6

generate double y     = rgdp/rgdp_pott6                  // real GDP / trend GDP
generate double newsy = news/(L.rgdp_pott6*L.pgdp)       // news / lagged nominal trend GDP
generate double g     = (ngov/pgdp)/rgdp_pott6           // real government spending / trend GDP
quietly count if newsy < .
local nnews = r(N)
lp_assert "Task 5: newsy has 504 nonmissing quarters" : `nnews' == 504
local k1950q3 = tq(1950q3) - tq(1889q1) + 1
lp_close newsy[`k1950q3'] 0.600073, tol(1e-6) label(Task 5: newsy in 1950Q3 is 0.600073)

tempname F
postfile `F' h double beta_h T_h using "output/pset/first_contact.dta", replace
forvalues h = 0/20 {
    quietly regress F`h'.y newsy L.y
    post `F' (`h') (_b[newsy]) (e(N))
}
postclose `F'

* shares of the variation in the h = 8 sample
quietly regress F8.y newsy L.y
local b8 = _b[newsy]
generate byte in8 = e(sample)
quietly summarize newsy if in8
generate double dev2 = (newsy - r(mean))^2 if in8
quietly summarize dev2
generate double share = dev2/r(sum)
preserve
keep if in8
gsort -share
generate double cumshare = sum(share)
keep in 1/10
generate rank = _n
keep rank qdate newsy share cumshare
format newsy share cumshare %9.6f
list rank qdate newsy share cumshare, clean noobs
lp_assert "Task 5: 1941Q4 has the largest share, 0.261211 (1e-6)" : qdate[1] == tq(1941q4) & abs(share[1] - 0.261211) < 1e-6
lp_assert "Task 5: 1950Q3 has the second largest share, 0.195838 (1e-6)" : qdate[2] == tq(1950q3) & abs(share[2] - 0.195838) < 1e-6
local share2 = cumshare[2]
local share6 = cumshare[6]
export delimited using "output/pset/sta01-news-shares.csv", replace datafmt
restore

* one episode out
quietly regress F8.y newsy L.y if qdate != tq(1950q3)
local b_drop = _b[newsy]
local n_drop = e(N)
lp_assert "Task 5: without 1950Q3 the h = 8 regression has 495 rows" : `n_drop' == 495
lp_close `b_drop' 0.433969, tol(1e-6) label(Task 5: at h = 8 without 1950Q3 the estimate is 0.433969)

* a source record: Ramey and Zubairy's controls at h = 10 (REP04 benchmark, irf_gdp_linear)
quietly regress F10.y newsy L(1/4).newsy L(1/4).y L(1/4).g
local b_rz10 = _b[newsy]
local n_rz10 = e(N)
lp_assert "Task 5: with Ramey-Zubairy controls the h = 10 regression has 490 rows" : `n_rz10' == 490
lp_close `b_rz10' 0.29376385, tol(1e-6) label(Task 5: with Ramey-Zubairy controls the h = 10 estimate is 0.29376385)

capture confirm file "handoff/l01-explorer-handoff.json"
if _rc == 0 {
    display as text _n "Lab 4 hypothesis in the Explorer record:"
    lp_json_get using "handoff/l01-explorer-handoff.json", key(lab4.hypothesis) display
    display as text "Stata: at h = 8 the estimate is " as result %8.6f `b8' as text " on the full sample and " ///
        as result %8.6f `b_drop' as text " on the `n_drop' rows without 1950Q3."
}

use "output/pset/first_contact.dta", clear
format beta_h %9.6f
list, clean noobs
lp_assert "Task 5: T_h = 504 - h" : T_h == 504 - h
lp_close beta_h[9] 0.361906, tol(1e-6) label(Task 5: beta_8 = 0.361906)
lp_close beta_h[11] 0.404210, tol(1e-6) label(Task 5: beta_10 = 0.404210)
quietly summarize beta_h
local gap_peak = abs(beta_h[11] - r(max))
lp_assert "Task 5: the response peaks at h = 10" : `gap_peak' < 1e-12
local b10 = beta_h[11]

local fc_intervention "Response to military-spending news worth one percent of the previous quarter's nominal trend GDP, from least squares of y_(t+h) on a constant, the news, and y_(t-1) over 1890Q1-2015Q4, with T_h = 504 - h rows (Ramey-Zubairy data, February 2018 package)."
local fc_outcome "The vertical axis is real GDP in percent of trend GDP, which is numerically beta_h per unit of the scaled news variable."
local fc_horizon "Horizons are quarters after the news arrives."
local fc_counterfactual "Read causally, the vertical axis is the gap between GDP and the path it would have followed without the news, a reading not yet argued; no bands are shown."

twoway (connected beta_h h, lcolor("`blue'") mcolor("`blue'") msymbol(O) msize(small) lwidth(medthick)), ///
       yline(0, lcolor("`rule'")) xlabel(0(2)20)                                     ///
       ylabel(0(0.1)0.5, format(%3.1f) angle(0) glcolor("`rule'"))                   ///
       xtitle("Quarters after the news arrives")                                      ///
       ytitle("Percent of trend GDP, per news worth 1 percent")                       ///
       legend(off) graphregion(color(white)) plotregion(color(white)) xsize(6.5) ysize(4)
graph export "output/pset/fig-sta01-first-contact.svg", replace
graph export "output/pset/fig-sta01-first-contact.png", replace width(1950)

local nya_units "The coefficients are responses of a level relative to a fitted trend per unit of scaled news, and whether that level, its change, or its accumulation answers the policymaker's question is not yet settled."
local nya_controls "One lag of GDP is a choice, and Ramey and Zubairy's controls lower the ten-quarter coefficient from `: display %5.3f `b10'' to `: display %5.3f `b_rz10''."
local nya_identification "Reading the curve as the effect of the news requires the news to be unpredictable and unrelated to the taxes, monetary policy, price controls, and wars that arrived with it, which nothing here has shown."
local nya_uncertainty "No standard error or band has been computed, and the overlapping horizons make the residuals serially correlated."
local nya_episodes "Two quarters, 1941Q4 and 1950Q3, supply `: display %4.1f 100*`share2'' percent of the variation in the news, and dropping 1950Q3 alone moves the eight-quarter estimate from `: display %5.3f `b8'' to `: display %5.3f `b_drop''."

tempname nf
file open `nf' using "output/pset/fig-sta01-first-contact-caption.txt", write text replace
file write `nf' `"`fc_intervention' `fc_outcome' `fc_horizon' `fc_counterfactual'"' _n
file close `nf'
file open `nf' using "output/pset/not-yet-argued.txt", write text replace
file write `nf' "What has not yet been argued" _n _n
foreach slot in units controls identification uncertainty episodes {
    file write `nf' `"`slot': `nya_`slot''"' _n
}
file close `nf'

foreach slot in intervention outcome horizon counterfactual {
    local len_`slot' = ustrlen(`"`fc_`slot''"')
}
lp_assert "Task 5: the caption names the intervention and its unit" : `len_intervention' >= 20
lp_assert "Task 5: the caption gives the outcome's units" : `len_outcome' >= 20
lp_assert "Task 5: the caption gives the horizon unit" : `len_horizon' >= 20
lp_assert "Task 5: the caption names the counterfactual" : `len_counterfactual' >= 20
foreach slot in units controls identification uncertainty episodes {
    local len = ustrlen(`"`nya_`slot''"')
    lp_assert "Task 5: the not-yet-argued paragraph has a sentence on `slot'" : `len' >= 40
}
capture confirm file "output/pset/fig-sta01-first-contact.svg"
local rc = _rc
lp_assert "Task 5: the response graph is exported to output/pset/fig-sta01-first-contact.svg" : `rc' == 0

*--------------------------------------------------------------------------
timer off 21
quietly timer list 21
local seconds = r(t21)
local npass = $LP_NPASS - `npass0'
display as text _n "STA01 complete: " as result `npass' as text " assertions passed in " as result %7.1f `seconds' as text " seconds (R = `R')."
log close pset
```

## Task 1 · Construct the rows

```text
    h   T_h   n1   n0   first   last  
    0    11    3    8       2     12  
    1    10    2    8       2     11  
    2     9    2    7       2     10  
```

Each horizon costs the last row, and row 1 never enters because $y_0$ is not
data, so $T_h=11-h$ with rows $2,\dots,12-h$. Row 12's intervention leaves at
$h=1$, which is why the count of intervention rows falls from 3 to 2.

## Task 2 · Estimate the slopes from the rows

```text
    h   T_h         ybar1        ybar0        b_hand         b_reg        b_ctrl   same_r~s  
    0    11    1.26420899   0.64688720    0.61732179    0.61732179    0.57566744          1  
    1    10   -0.03491210   0.94844359   -0.98335570   -0.98335570   -1.05040516          1  
    2     9    2.28254390   0.23251953    2.05002437    2.05002437    2.15302240          1  
```

Without the control each slope is exactly the difference in means (the by-hand
slope and `regress` agree to every printed digit). With $y_{t-1}$ added on the
same rows the slopes move to 0.575667, −1.050405, and 2.153022; they are no
longer differences in means, and none is close to $\theta_h=1, 0.5, 0.25$.
Common mistake: omitting `if t >= 2` in the regression without the control,
which adds row 1 and makes the two regressions differ in rows as well as in the
control; the `same_rows` check catches it.

## Task 3 · A response in a loop

```text
     h      beta_h   T_h    theta_h  
     0    0.878940   199   1.000000  
     1    0.853260   198   0.900000  
     2    0.612737   197   0.810000  
     3    0.611046   196   0.729000  
     4    0.548477   195   0.656100  
     5    0.583099   194   0.590490  
     6    0.509120   193   0.531441  
     7    0.417788   192   0.478297  
     8    0.240595   191   0.430467  
     9    0.130293   190   0.387420  
    10   -0.028821   189   0.348678  
    11   -0.117200   188   0.313811  
    12   -0.293297   187   0.282430  
```

All thirteen estimates lie below $0.9^h$, and the curve is negative from
$h=10$. Neighbouring regressions share almost every row, so this is one error
seen repeatedly, not thirteen independent misses.

## Task 4 · Many draws, one graph, a caption

Monte Carlo runtime:   70.79 seconds for R = 500

Summary of the first 200 samples (the student default):

```text
    rho    h    theta_h   mean_ctrl        bias       mcse    sd_ctrl          p5        p95   mean_no~l   sd_noc~l  
     .5    0   1.000000    1.002761    0.002761   0.005071   0.071711    0.880033   1.117130    0.999387   0.096966  
     .5    1   0.500000    0.494828   -0.005172   0.008053   0.113883    0.294760   0.678332    0.496249   0.128961  
     .5    2   0.250000    0.232267   -0.017733   0.008040   0.113710    0.035818   0.412721    0.234528   0.121862  
     .5    3   0.125000    0.121774   -0.003226   0.007859   0.111147   -0.060430   0.308080    0.124842   0.114561  
     .5    4   0.062500    0.050701   -0.011799   0.008545   0.120847   -0.145857   0.243852    0.054800   0.121705  
     .5    5   0.031250    0.007191   -0.024059   0.008711   0.123195   -0.199955   0.212555    0.009891   0.123062  
     .5    6   0.015625    0.001802   -0.013823   0.008127   0.114940   -0.181853   0.184973    0.003596   0.114311  
     .5    7   0.007812   -0.008515   -0.016328   0.008089   0.114389   -0.195957   0.169463   -0.008256   0.115351  
     .5    8   0.003906   -0.016926   -0.020832   0.008297   0.117341   -0.206495   0.190073   -0.017240   0.117785  
     .5    9   0.001953   -0.010661   -0.012614   0.008140   0.115117   -0.198407   0.187885   -0.011848   0.115334  
     .5   10   0.000977    0.000753   -0.000224   0.007707   0.108990   -0.200145   0.156481   -0.000948   0.109092  
     .5   11   0.000488    0.002017    0.001529   0.008242   0.116554   -0.182660   0.195506    0.000946   0.116997  
     .5   12   0.000244   -0.010543   -0.010787   0.008466   0.119724   -0.203434   0.176446   -0.012039   0.120607  
     .9    0   1.000000    1.003131    0.003131   0.005090   0.071985    0.878326   1.113471    0.969027   0.220908  
     .9    1   0.900000    0.894057   -0.005943   0.009274   0.131152    0.682830   1.098370    0.869197   0.241536  
     .9    2   0.810000    0.786719   -0.023281   0.010789   0.152578    0.547784   1.060211    0.769041   0.251736  
     .9    3   0.729000    0.711365   -0.017635   0.011950   0.169004    0.445724   1.031556    0.700163   0.251454  
     .9    4   0.656100    0.627893   -0.028207   0.013425   0.189863    0.342378   0.941757    0.621921   0.265053  
     .9    5   0.590490    0.544802   -0.045688   0.014593   0.206374    0.201156   0.881283    0.541070   0.273479  
     .9    6   0.531441    0.486864   -0.044577   0.014759   0.208729    0.177696   0.860008    0.484828   0.269452  
     .9    7   0.478297    0.426909   -0.051388   0.015196   0.214902    0.094284   0.787177    0.426730   0.269052  
     .9    8   0.430467    0.370337   -0.060131   0.014936   0.211226    0.060754   0.694442    0.370547   0.256791  
     .9    9   0.387420    0.330438   -0.056983   0.014930   0.211144    0.004052   0.683974    0.330391   0.253195  
     .9   10   0.348678    0.302101   -0.046577   0.014149   0.200101   -0.013349   0.652989    0.302043   0.236977  
     .9   11   0.313811    0.271528   -0.042282   0.014644   0.207097   -0.050096   0.655288    0.272526   0.235713  
     .9   12   0.282430    0.230255   -0.052174   0.015452   0.218525   -0.113795   0.616738    0.231969   0.244894  
```

Summary of all 500 samples (the instructor build):

```text
    rho    h    theta_h   mean_ctrl        bias       mcse    sd_ctrl          p5        p95   mean_no~l   sd_noc~l  
     .5    0   1.000000    1.003858    0.003858   0.003265   0.073010    0.884293   1.124763    1.002742   0.094623  
     .5    1   0.500000    0.494072   -0.005928   0.004852   0.108490    0.324066   0.668889    0.496172   0.122518  
     .5    2   0.250000    0.239261   -0.010739   0.005142   0.114985    0.048416   0.425116    0.241607   0.122087  
     .5    3   0.125000    0.119185   -0.005815   0.005272   0.117886   -0.073805   0.318912    0.121798   0.120197  
     .5    4   0.062500    0.052331   -0.010169   0.005522   0.123479   -0.155622   0.265203    0.055230   0.123591  
     .5    5   0.031250    0.022620   -0.008630   0.005349   0.119597   -0.171586   0.215089    0.024345   0.119270  
     .5    6   0.015625    0.016781    0.001156   0.005008   0.111976   -0.169706   0.207499    0.018153   0.110955  
     .5    7   0.007812    0.001311   -0.006502   0.005246   0.117295   -0.192440   0.198605    0.001800   0.117218  
     .5    8   0.003906   -0.003416   -0.007323   0.005517   0.123374   -0.196747   0.204976   -0.003526   0.122919  
     .5    9   0.001953   -0.011378   -0.013331   0.005186   0.115957   -0.196546   0.187885   -0.011679   0.116012  
     .5   10   0.000977   -0.008075   -0.009052   0.005269   0.117828   -0.220363   0.164701   -0.008561   0.117370  
     .5   11   0.000488   -0.004016   -0.004504   0.005245   0.117272   -0.197534   0.195079   -0.004621   0.117738  
     .5   12   0.000244   -0.012124   -0.012368   0.005381   0.120330   -0.199652   0.181641   -0.012426   0.120773  
     .9    0   1.000000    1.003997    0.003997   0.003281   0.073358    0.879349   1.125300    0.966631   0.217674  
     .9    1   0.900000    0.893112   -0.006888   0.005532   0.123704    0.692191   1.093415    0.864973   0.236824  
     .9    2   0.810000    0.793152   -0.016848   0.006790   0.151828    0.553873   1.054064    0.771481   0.252025  
     .9    3   0.729000    0.710382   -0.018618   0.007845   0.175423    0.427804   1.035753    0.695100   0.260046  
     .9    4   0.656100    0.629828   -0.026272   0.008847   0.197828    0.319972   0.957689    0.620102   0.269301  
     .9    5   0.590490    0.560434   -0.030056   0.009378   0.209691    0.203801   0.922669    0.553606   0.272672  
     .9    6   0.531441    0.507759   -0.023682   0.009233   0.206460    0.177696   0.868040    0.504130   0.263219  
     .9    7   0.478297    0.447708   -0.030589   0.009802   0.219180    0.098724   0.807388    0.446639   0.266741  
     .9    8   0.430467    0.397256   -0.033211   0.010215   0.228403    0.046705   0.792668    0.397905   0.266387  
     .9    9   0.387420    0.345643   -0.041778   0.009744   0.217883   -0.007893   0.693560    0.347581   0.249609  
     .9   10   0.348678    0.306574   -0.042104   0.009695   0.216781   -0.043725   0.658474    0.309561   0.242949  
     .9   11   0.313811    0.273331   -0.040479   0.009710   0.217112   -0.066248   0.669901    0.277622   0.238000  
     .9   12   0.282430    0.233538   -0.048891   0.010044   0.224580   -0.106968   0.635417    0.239032   0.241695  
```

At $\rho=0.9$ the mean falls short of $\theta_h$ by more than two Monte Carlo
standard errors at most horizons, the small-sample bias of Lecture 2; the
control cuts the spread at impact by a factor of three (0.0720 against 0.2209
at $R=200$) and matters less as $h$ grows. At $h=8$ the Task 3 sample,
0.240595, lies inside the band; at $h=12$, −0.293297, it lies below the 5th
percentile.

**Model caption** (graded on four slots: the intervention and its unit, the
outcome's units, the horizon unit, the counterfactual):

> Response of y to a one-unit intervention s_t, where one unit is one standard deviation because sigma_s = 1, estimated by local projections of y_(t+h) on a constant, s_t, and y_(t-1) in one simulated sample of T = 200 periods with rho = 0.9 (seed 2). The vertical axis is in units of y. Horizons are periods after the intervention; h = 0 is the period in which it occurs. The vertical axis measures the gap between the path with the intervention and the path without it, so zero means no different from that path, not y back where it started; the dashed line is the true response 0.9^h, and the band holds the middle 90 percent of estimates across 500 simulated samples (seed 3), which describes the estimator and is not a confidence interval.

Grading: one point per slot. Common mistakes: a vertical axis labeled "response
of y" with nothing saying that zero means "no different from the path without
the intervention"; calling the simulated band a confidence interval; omitting
that one unit of $s$ is one standard deviation.

## Task 5 · Military news

First-contact response, $h=0,\dots,20$:

```text
     h     beta_h   T_h  
     0   0.080313   504  
     1   0.127363   503  
     2   0.173289   502  
     3   0.195597   501  
     4   0.259141   500  
     5   0.299480   499  
     6   0.335977   498  
     7   0.337931   497  
     8   0.361906   496  
     9   0.397627   495  
    10   0.404210   494  
    11   0.384037   493  
    12   0.342677   492  
    13   0.305247   491  
    14   0.270833   490  
    15   0.221056   489  
    16   0.171908   488  
    17   0.133997   487  
    18   0.116266   486  
    19   0.095899   485  
    20   0.079552   484  
```

The ten largest shares of $\sum_t(s_t-\bar s)^2$ in the $h=8$ sample (496
quarters, 1890Q1–2013Q4):

```text
    rank    qdate       newsy      share   cumshare  
       1   1941q4    0.691893   0.261211   0.261211  
       2   1950q3    0.600073   0.195838   0.457049  
       3   1942q3    0.432791   0.100897   0.557946  
       4   1950q4    0.402163   0.086893   0.644839  
       5   1917q2    0.372915   0.074496   0.719335  
       6   1941q2    0.340130   0.061734   0.781069  
       7   1918q2    0.275022   0.039941   0.821010  
       8   1940q2    0.259757   0.035515   0.856526  
       9   1945q3   -0.219500   0.028682   0.885208  
      10   1944q2   -0.196432   0.023145   0.908353  
```

Without 1950Q3 the $h=8$ estimate rises from 0.361906 (496 rows) to 0.433969
(495 rows). With Ramey and Zubairy's controls the $h=10$ estimate is 0.29376385
on 490 rows, equal to `irf_gdp_linear` in the REP04 benchmark. The sample
handoff record's hypothesis ("lower ... to about 0.30") is refuted.

**Model caption** (graded on the same four slots):

> Response to military-spending news worth one percent of the previous quarter's nominal trend GDP, from least squares of y_(t+h) on a constant, the news, and y_(t-1) over 1890Q1-2015Q4, with T_h = 504 - h rows (Ramey-Zubairy data, February 2018 package). The vertical axis is real GDP in percent of trend GDP, which is numerically beta_h per unit of the scaled news variable. Horizons are quarters after the news arrives. Read causally, the vertical axis is the gap between GDP and the path it would have followed without the news, a reading not yet argued; no bands are shown.

**Model paragraph** (graded on five sentences: units, controls, identification,
uncertainty, episode dependence; each must use the student's own computed
numbers where it cites one):

```text
What has not yet been argued

units: The coefficients are responses of a level relative to a fitted trend per unit of scaled news, and whether that level, its change, or its accumulation answers the policymaker's question is not yet settled.
controls: One lag of GDP is a choice, and Ramey and Zubairy's controls lower the ten-quarter coefficient from 0.404 to 0.294.
identification: Reading the curve as the effect of the news requires the news to be unpredictable and unrelated to the taxes, monetary policy, price controls, and wars that arrived with it, which nothing here has shown.
uncertainty: No standard error or band has been computed, and the overlapping horizons make the residuals serially correlated.
episodes: Two quarters, 1941Q4 and 1950Q3, supply 45.7 percent of the variation in the news, and dropping 1950Q3 alone moves the eight-quarter estimate from 0.362 to 0.434.
```

Common mistakes: dividing the news by the same quarter's nominal trend GDP
instead of the previous quarter's (the 1950Q3 check, 0.600073, catches it);
forcing $T_h=503-h$ from the formula by dropping a quarter of data; reading the
coefficient per unit of news instead of per 0.01; treating the "not yet argued"
paragraph as a defense rather than a list.

## The 48 STA01 checks the solution passed at $R=500$

```text
 1. Task 1: T_h = 11 - h at h = 0, 1, 2 (T = 12, p = 1)
 2. Task 1: every row is an intervention row or a comparison row
 3. Task 1: the rows run from t = 2 to t = 12 - h
 4. Task 1: 3 intervention rows at h = 0 and 2 at h = 1 and h = 2
 5. Task 2: the slope by hand equals the difference in means (1e-6)
 6. Task 2: regress returns the slope computed by hand (1e-6)
 7. Task 2: the regressions with and without y_(t-1) use the same rows
 8. Task 2: slopes without the control 0.617322, -0.983356, 2.050024 (1e-6)
 9. Task 2: slopes with y_(t-1) 0.575667, -1.050405, 2.153022 (1e-6)
10. Task 3: the draw holds T = 200 periods
11. Task 3: T_h = 199 - h at every horizon
12. Task 3: beta_0 = 0.878940
13. Task 3: beta_12 = -0.293297
14. Task 3: the estimate lies below theta_h at all 13 horizons
15. Task 4: 199 - h rows with the control and 200 - h without
16. Task 4: with R = 200 the mean at rho = 0.9 and h = 8 is 0.370337
17. Task 4: with R = 200 the standard deviation at rho = 0.9 and h = 8 is 0.211226
18. Task 4: without y_(t-1) the spread is larger at every h when rho = 0.9 (R = 200)
19. Task 4: with R = 500 the mean at rho = 0.9 and h = 8 is 0.397256
20. Task 4: with R = 500 the standard deviation at rho = 0.9 and h = 8 is 0.228403
21. Task 4: the caption names the intervention and its unit
22. Task 4: the caption gives the outcome's units
23. Task 4: the caption gives the horizon unit
24. Task 4: the caption names the counterfactual
25. Task 4: the response graph is exported to output/pset/fig-sta01-one-draw.svg
26. Task 5: 508 consecutive quarters, 1889Q1-2015Q4
27. Task 5: newsy has 504 nonmissing quarters
28. Task 5: newsy in 1950Q3 is 0.600073
29. Task 5: 1941Q4 has the largest share, 0.261211 (1e-6)
30. Task 5: 1950Q3 has the second largest share, 0.195838 (1e-6)
31. Task 5: without 1950Q3 the h = 8 regression has 495 rows
32. Task 5: at h = 8 without 1950Q3 the estimate is 0.433969
33. Task 5: with Ramey-Zubairy controls the h = 10 regression has 490 rows
34. Task 5: with Ramey-Zubairy controls the h = 10 estimate is 0.29376385
35. Task 5: T_h = 504 - h
36. Task 5: beta_8 = 0.361906
37. Task 5: beta_10 = 0.404210
38. Task 5: the response peaks at h = 10
39. Task 5: the caption names the intervention and its unit
40. Task 5: the caption gives the outcome's units
41. Task 5: the caption gives the horizon unit
42. Task 5: the caption names the counterfactual
43. Task 5: the not-yet-argued paragraph has a sentence on units
44. Task 5: the not-yet-argued paragraph has a sentence on controls
45. Task 5: the not-yet-argued paragraph has a sentence on identification
46. Task 5: the not-yet-argued paragraph has a sentence on uncertainty
47. Task 5: the not-yet-argued paragraph has a sentence on episodes
48. Task 5: the response graph is exported to output/pset/fig-sta01-first-contact.svg
```

STA01 complete: 48 assertions passed in    72.3 seconds (R = 500).
