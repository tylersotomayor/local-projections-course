*! check_handoff.do  Check the Shock-to-Response Explorer's handoff record in Stata
*
*  Local Projections: From First Principles to Empirical Research, Practicum 01.
*
*  The "Transfer to Stata" section of the Explorer writes three files:
*  l01-explorer-handoff.json, hand_table.csv, and the draw file chosen in Lab 3
*  (onedraw_rho09_seed2.csv or onedraw_rho05_seed2.csv). Put them in this
*  folder. A sample record, written by the Explorer's own code with the
*  settings listed in handoff/README.md, ships with the project; your record
*  replaces it.
*
*  For each lab this file reruns in Stata what the browser computed:
*    Lab 2  the rows and the slope for the recorded h, control, and
*           single-episode setting (row count exact, slope within 1e-6)
*    Lab 3  thirteen row counts and slopes for the recorded draw, T, and
*           control (within 1e-6)
*    Lab 4  the stored coefficient for the recorded h, controls, and rows,
*           re-estimated from RZDAT.xlsx when data/raw holds a verified copy
*           (Task 5 of the problem set downloads it), and the written
*           hypothesis set beside the estimate. The outcome is real GDP over
*           trend GDP (rgdp_pott6), which Ramey and Zubairy call potential GDP
*           and estimate as a sixth-degree polynomial trend in real GDP
*
*  Writes output/handoff-check.log and output/handoff-check.csv.
*  Run from the lab project's top folder: do handoff/check_handoff.do

version 19
clear
set more off
capture program list lp_assert
if _rc do helpers/lp_helpers.do
lp_root
capture mkdir output
capture log close handoff
log using "output/handoff-check.log", text replace name(handoff)
global LP_STEP handoff

local rec "handoff/l01-explorer-handoff.json"
capture confirm file "`rec'"
if _rc {
    display as text "No handoff record in handoff/. Download l01-explorer-handoff.json from the Explorer to check it."
    log close handoff
    exit
}

tempname T
postfile `T' str6 lab str44 quantity double(browser stata difference) str44 result ///
    using "output/handoff-check.dta", replace

* A value of null in the record means the browser had no finite number.
capture program drop _lp_num
program define _lp_num, rclass
    args text
    if inlist(`"`text'"', "", "null") return scalar x = .
    else return scalar x = `text'
end

lp_json_get using "`rec'", key(lecture)
local lecture "`r(value)'"
lp_assert "Handoff: the record comes from the Lecture 01 Explorer" : "`lecture'" == "01"

*==========================================================================
* Lab 2: the rows of the horizon-h regression in the hand table
*==========================================================================
lp_json_get using "`rec'", key(lab2.settings.h)
local h2 = `r(value)'
lp_json_get using "`rec'", key(lab2.settings.control_y_lag)
local ctl2 = ("`r(value)'" == "true")
lp_json_get using "`rec'", key(lab2.settings.single_episode)
local one2 = ("`r(value)'" == "true")
lp_json_get using "`rec'", key(lab2.T_h)
local Th2 = `r(value)'
lp_json_get using "`rec'", key(lab2.beta_h)
_lp_num "`r(value)'"
local b2 = r(x)
display as text _n "Lab 2 record: h = `h2', control = `ctl2', single episode = `one2', T_h = `Th2', slope = `b2'"

local hand "data/raw/hand_table.csv"
capture confirm file "handoff/hand_table.csv"
if _rc == 0 {
    import delimited using "handoff/hand_table.csv", clear
    rename (s v y) (s_b v_b y_b)
    tempfile browser
    save `browser'
    import delimited using "data/raw/hand_table.csv", clear
    merge 1:1 t using `browser', nogenerate
    lp_assert "Handoff Lab 2: handoff/hand_table.csv holds the shipped observations" : ///
        abs(s - s_b) < 1e-7 & abs(v - v_b) < 1e-7 & abs(y - y_b) < 1e-7
    lp_sha256 "handoff/hand_table.csv"
    local sha_b "`r(sha256)'"
    lp_sha256 "data/raw/hand_table.csv"
    display as text "SHA-256 of the browser export " cond("`sha_b'" == "`r(sha256)'", "equals", "differs from") " the shipped file."
    local hand "handoff/hand_table.csv"
}
import delimited using "`hand'", clear
tsset t
local regressor "s"
if `one2' {
    generate byte s_one = (t == 5)
    local regressor "s_one"
}
local control = cond(`ctl2', "L.y", "")
display as text "regress F`h2'.y `regressor' `control' if t >= 2"
regress F`h2'.y `regressor' `control' if t >= 2
lp_assert "Handoff Lab 2: `Th2' rows at h = `h2', as in the browser" : e(N) == `Th2'
local b2s = _b[`regressor']
lp_close `b2s' `b2', tol(1e-6) label(Handoff Lab 2: the slope at h = `h2' against the browser)
post `T' ("Lab 2") ("slope at h = `h2'") (`b2') (`b2s') (`b2s' - `b2') ("agrees within 1e-6")

*==========================================================================
* Lab 3: thirteen local projections on the recorded draw
*==========================================================================
lp_json_get using "`rec'", key(lab3.settings.rho)
local rho3 "`r(value)'"
lp_json_get using "`rec'", key(lab3.settings.T)
local T3 = `r(value)'
lp_json_get using "`rec'", key(lab3.settings.control_y_lag)
local ctl3 = ("`r(value)'" == "true")
lp_json_get using "`rec'", key(lab3.file)
local file3 "`r(value)'"
lp_json_get using "`rec'", key(lab3.beta_h)
local b3 "`r(value)'"
local nb3 = r(n)
lp_json_get using "`rec'", key(lab3.T_h)
local n3 "`r(value)'"
display as text _n "Lab 3 record: rho = `rho3', T = `T3', control = `ctl3', file `file3'"
lp_assert "Handoff Lab 3: the record names one of the two shipped draws" : ///
    inlist("`file3'", "onedraw_rho09_seed2.csv", "onedraw_rho05_seed2.csv")
lp_assert "Handoff Lab 3: thirteen browser estimates" : `nb3' == 13

local draw "data/raw/`file3'"
capture confirm file "handoff/`file3'"
if _rc == 0 {
    import delimited using "handoff/`file3'", clear
    rename (s v y) (s_b v_b y_b)
    tempfile browser
    save `browser'
    import delimited using "data/raw/`file3'", clear
    merge 1:1 t using `browser', nogenerate
    lp_assert "Handoff Lab 3: handoff/`file3' holds the shipped observations" : ///
        abs(s - s_b) < 1e-7 & abs(v - v_b) < 1e-7 & abs(y - y_b) < 1e-7
    local draw "handoff/`file3'"
}
import delimited using "`draw'", clear
tsset t
keep if t <= `T3'
local control = cond(`ctl3', "L.y", "")
forvalues h = 0/12 {
    local i = `h' + 1
    local bb : word `i' of `b3'
    local nn : word `i' of `n3'
    _lp_num "`bb'"
    local bb = r(x)
    quietly regress F`h'.y s `control'
    lp_assert "Handoff Lab 3: `nn' rows at h = `h'" : e(N) == `nn'
    local bs = _b[s]
    lp_close `bs' `bb', tol(1e-6) label(Handoff Lab 3: the slope at h = `h' against the browser)
    post `T' ("Lab 3") ("slope at h = `h'") (`bb') (`bs') (`bs' - `bb') ("agrees within 1e-6")
}

*==========================================================================
* Lab 4: the stored military-news estimate and the written hypothesis
*==========================================================================
lp_json_get using "`rec'", key(lab4.settings.h)
local h4 = `r(value)'
lp_json_get using "`rec'", key(lab4.settings.controls)
local spec4 "`r(value)'"
lp_json_get using "`rec'", key(lab4.settings.rows)
local rows4 "`r(value)'"
lp_json_get using "`rec'", key(lab4.stored.beta_h)
_lp_num "`r(value)'"
local b4 = r(x)
lp_json_get using "`rec'", key(lab4.stored.T_h)
local n4 = `r(value)'
lp_json_get using "`rec'", key(lab4.stored.beta_h_full_sample)
_lp_num "`r(value)'"
local b4full = r(x)
lp_json_get using "`rec'", key(lab4.stored.T_h_full_sample)
local n4full = `r(value)'
display as text _n "Lab 4 record: h = `h4', controls `spec4', rows `rows4'; stored estimate `b4' on `n4' rows"
display as text "Written hypothesis:"
lp_json_get using "`rec'", key(lab4.hypothesis) display
local dir4 "`r(direction)'"
local num4 "`r(number)'"
lp_assert "Handoff Lab 4: recognized controls and rows" : ///
    inlist("`spec4'", "toy", "rz") & inlist("`rows4'", "full", "drop1941q4", "drop1950q3", "dropboth", "from1947q1")

local rz_ok 0
capture confirm file "data/raw/RZDAT.xlsx"
if _rc == 0 {
    lp_sha256 "data/raw/RZDAT.xlsx"
    if "`r(sha256)'" == "b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120" local rz_ok 1
}
if !`rz_ok' {
    display as text "Lab 4 re-estimation skipped: data/raw has no verified RZDAT.xlsx. Run  do data/raw/get_rz.do  first."
    post `T' ("Lab 4") ("estimate at h = `h4'") (`b4') (.) (.) ("skipped: RZDAT.xlsx not acquired")
}
else {
    import excel using "data/raw/RZDAT.xlsx", sheet("rzdat") firstrow clear
    drop if quarter < 1889
    generate qdate = yq(1889, 1) + _n - 1
    format qdate %tq
    tsset qdate, quarterly
    generate double y     = rgdp/rgdp_pott6                 // real GDP / trend GDP
    generate double g     = (ngov/pgdp)/rgdp_pott6          // real government spending / trend GDP
    generate double newsy = news/(L.rgdp_pott6*L.pgdp)      // news / lagged nominal trend GDP
    local control = cond("`spec4'" == "toy", "L.y", "L(1/4).newsy L(1/4).y L(1/4).g")
    local keep ""
    if "`rows4'" == "drop1941q4" local keep "if qdate != tq(1941q4)"
    if "`rows4'" == "drop1950q3" local keep "if qdate != tq(1950q3)"
    if "`rows4'" == "dropboth"   local keep "if qdate != tq(1941q4) & qdate != tq(1950q3)"
    if "`rows4'" == "from1947q1" local keep "if qdate >= tq(1947q1)"

    quietly regress F`h4'.y newsy `control'
    local bfull = _b[newsy]
    local nfull = e(N)
    display as text "regress F`h4'.y newsy `control' `keep'"
    regress F`h4'.y newsy `control' `keep'
    local bsel = _b[newsy]
    local nsel = e(N)
    lp_assert "Handoff Lab 4: `n4' rows, as stored in the browser" : `nsel' == `n4'
    lp_close `bsel' `b4', tol(1e-6) label(Handoff Lab 4: the selected estimate against the browser)
    lp_assert "Handoff Lab 4: `n4full' rows on the full sample" : `nfull' == `n4full'
    lp_close `bfull' `b4full', tol(1e-6) label(Handoff Lab 4: the full-sample estimate against the browser)
    post `T' ("Lab 4") ("estimate at h = `h4', `rows4'") (`b4') (`bsel') (`bsel' - `b4') ("agrees within 1e-6")
    post `T' ("Lab 4") ("estimate at h = `h4', full sample") (`b4full') (`bfull') (`bfull' - `b4full') ("agrees within 1e-6")

    * The hypothesis: direction relative to the full sample, and the number.
    local actual = cond(abs(`bsel' - `bfull') < 5e-7, "unchanged", cond(`bsel' > `bfull', "raise", "lower"))
    if "`rows4'" == "full" local verdict "no rows were dropped, so there is no direction to test"
    else if "`dir4'" == "" local verdict "the hypothesis names no single direction"
    else if "`dir4'" == "`actual'" local verdict "direction confirmed"
    else local verdict "direction refuted"
    display as text _n "Hypothesis direction: " as result cond("`dir4'" == "", "(none found)", "`dir4'") ///
        as text ".  Stata: the estimate moves from " as result %8.6f `bfull' as text " (`nfull' rows) to " ///
        as result %8.6f `bsel' as text " (`nsel' rows), so the rows " as result "`actual'" as text " it."
    display as text "Verdict: `verdict'."
    local hyp_num = .
    if "`num4'" != "" {
        local hyp_num = `num4'
        display as text "Hypothesized value " as result %8.4f `hyp_num' as text "; estimate " as result %8.6f `bsel' ///
            as text "; miss " as result %8.4f abs(`bsel' - `hyp_num')
    }
    post `T' ("Lab 4") ("hypothesis: `dir4'") (`hyp_num') (`bsel') (`bsel' - `hyp_num') ("`verdict'")
}

postclose `T'
use "output/handoff-check.dta", clear
format browser stata difference %12.8f
list, clean noobs
export delimited using "output/handoff-check.csv", replace datafmt
display as text _n "Handoff check complete."
log close handoff
