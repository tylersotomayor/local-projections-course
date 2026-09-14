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
