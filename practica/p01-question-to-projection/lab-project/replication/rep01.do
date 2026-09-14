*! rep01.do  REP01 . Recover the basic local-projection estimator
*
*  Local Projections: From First Principles to Empirical Research, Practicum 01.
*
*  Target   Jorda and Taylor (2025), "Local Projections," Journal of Economic
*           Literature 63(1), 59-110, Figure 1a: the Monte Carlo mean of the
*           levels local projection at h = 0,...,10, with an intercept and
*           without the lagged difference.
*  Package  ojorda/JEL-Code, commit 655696c1c576b7537c5a939d2c261f0a111ae663
*           (CC0), Example1_LongDifferences/SSBias_IntcpYLagdiffN_95.do,
*           shipped in vendor/jel-code/ with the authors' cap cd folder
*           paths commented out.
*  Kind     Statistical reproduction. The published figure averages 10,000
*           draws; this file averages $R draws (instructor build 500, student
*           default 200; editor decision D2). At a matched draw count the
*           reproduction is exact: every mean within 1e-6.
*  Mapping  vy = s_t (the intervention), e = v_t (the disturbance),
*           theta_0 = 1, rho = 0.95, T = 100 after 500 burn-in periods,
*           p = 1, so T_h = 99 - h.
*
*  Reads    replication/benchmark/REP01-levels-lp.csv          500 draws, Stata 18.5
*           replication/benchmark/REP01-author-R200-v195.csv   authors' script, 200 draws, StataNow 19.5
*           vendor/jel-code/SSBias_IntcpYLagdiffN_95.dta       authors' shipped means, 10,000 draws
*           vendor/jel-code/SSBias_IntcpYLagdiffN_95.do        run as shipped when AUTHOR_CHECK = 1
*  Writes   output/rep01.log, output/rep01-draws.dta, output/rep01-benchmark.csv,
*           output/fig-rep01-levels-mean.svg/.png, output/fig-rep01-first-draw.svg/.png
*  Globals  R             number of draws (default 200)
*           AUTHOR_CHECK  1 runs the authors' script at the same R (default 1)
*
*  Run from the lab project's top folder: do replication/rep01.do

version 19
clear
set more off
capture program list lp_assert
if _rc do helpers/lp_helpers.do
lp_root
capture mkdir output
capture log close rep01
log using "output/rep01.log", text replace name(rep01)
if "$R" == "" global R 200
if "$AUTHOR_CHECK" == "" global AUTHOR_CHECK 1
global LP_STEP rep01
local R = $R
confirm integer number `R'
timer clear 11
timer on 11
local npass0 = cond("$LP_NPASS" == "", 0, $LP_NPASS)

*==========================================================================
* 0. Settings, with the lines of SSBias_IntcpYLagdiffN_95.do they come from
*==========================================================================
local nobs = 100                  // all-simulate.do line 18
local burn = 500                  // line 20
local tobs = `nobs' + `burn'      // line 21
local hmax = 10                   // line 24
local rho  = 0.95                 // line 27
local seed = 12345                // line 39
display as text _n "REP01: levels LP, rho = `rho', T = `nobs', burn-in `burn', h = 0,...,`hmax', R = `R'"

*==========================================================================
* 1. One realization, one horizon: draw 1 of the authors' loop, rebuilt
*    outside the loop
*==========================================================================
clear
set seed `seed'
set obs `tobs'
generate t = _n
tsset t
generate vy = rnormal()           // line 52: the intervention s_t, drawn first
generate y  = 0                   // line 53: stored as float, as in the authors' code
generate e  = rnormal()           // line 56: the disturbance v_t, drawn second
* line 59 reads  y = $rho*l.y + $a*l.d.y + vy + e  if _n > 2,  with $a = 0.00 (line 57)
replace y = `rho'*L.y + vy + e if _n > 2
drop if _n <= `burn'              // line 62: keep the last 100 periods
replace t = _n
tsset t

regress F0.y vy L.y               // line 87 at h = 0
lp_assert "REP01 step 1: the h = 0 regression has T_0 = 99 rows" : e(N) == 99
lp_close _b[vy] 1.06035137, tol(1e-6) label(REP01 step 1: draw 1 at h = 0)

*==========================================================================
* 2. The same draw at every horizon: one regression per point of the curve
*==========================================================================
tempfile draw1
tempname D
postfile `D' h double b_draw1 T_draw1 using `draw1'
forvalues h = 0/`hmax' {
    quietly regress F`h'.y vy L.y
    post `D' (`h') (_b[vy]) (e(N))
}
postclose `D'
preserve
use `draw1', clear
format b_draw1 %12.8f
list, clean noobs
matrix input DRAW1 = (1.06035137, 0.99981713, 0.59646147, 0.55573124, 0.40316078, ///
    0.21355943, 0.08826523, -0.14803843, -0.28229347, -0.25071168, 0.24310037)
lp_assert "REP01 step 2: T_h = 99 - h in draw 1" : T_draw1 == 99 - h
forvalues h = 0/`hmax' {
    local i = `h' + 1
    lp_close b_draw1[`i'] DRAW1[1,`i'], tol(1e-6) label(REP01 step 2: draw 1 at h = `h')
}
restore

*==========================================================================
* 3. The Monte Carlo: R draws from one seeded stream (line 39), the levels
*    LP at h = 0,...,10 in each (lines 84-90)
*==========================================================================
display as text _n "Monte Carlo with R = `R' draws ..."
timer clear 12
timer on 12
tempname M
postfile `M' rep h double b T_h using "output/rep01-draws.dta", replace
set seed `seed'
quietly forvalues r = 1/`R' {
    clear
    set obs `tobs'
    generate t = _n
    tsset t
    generate vy = rnormal()
    generate y  = 0
    generate e  = rnormal()
    replace y = `rho'*L.y + vy + e if _n > 2
    drop if _n <= `burn'
    replace t = _n
    tsset t
    forvalues h = 0/`hmax' {
        regress F`h'.y vy L.y
        post `M' (`r') (`h') (_b[vy]) (e(N))
    }
}
postclose `M'
timer off 12
quietly timer list 12
local mc_seconds = r(t12)
display as text "Monte Carlo runtime: " as result %8.2f `mc_seconds' as text " seconds for R = `R'"

use "output/rep01-draws.dta", clear
lp_assert "REP01: every draw has T_h = 99 - h rows" : T_h == 99 - h
lp_assert "REP01: R draws at each of 11 horizons" : _N == 11*`R'

*--------------------------------------------------------------------------
* 4. Means over all R draws, and over the first 200 and 500 draws, which are
*    the matched counts of the two exact benchmarks
*--------------------------------------------------------------------------
preserve
collapse (mean) mean_R=b (sd) sd_R=b (p5) p5_R=b (p95) p95_R=b (count) draws=b, by(h)
tempfile summary
save `summary'
restore
foreach m in 200 500 {
    tempfile sum`m'
    preserve
    if `R' >= `m' {
        keep if rep <= `m'
        collapse (mean) mean_`m'=b, by(h)
    }
    else {
        keep if rep == 1
        keep h
        generate double mean_`m' = .
    }
    save `sum`m''
    restore
}

import delimited using "replication/benchmark/REP01-levels-lp.csv", clear varnames(1) encoding(utf8)
lp_assert "REP01 benchmark file: 11 rows of the levels series" : _N == 11 & series == "levels"
keep horizon coefficient true_response n
rename (horizon coefficient true_response n) (h published_500 published_theta published_T_h)
tempfile bench
save `bench'

import delimited using "replication/benchmark/REP01-author-R200-v195.csv", clear varnames(1)
rename (rl rt) (author_200 author_theta_200)
tempfile author200
save `author200'

use "vendor/jel-code/SSBias_IntcpYLagdiffN_95.dta", clear
keep t rl rt
rename (t rl rt) (h author_10000 author_theta)
tempfile author10000
save `author10000'

use `summary', clear
foreach f in sum200 sum500 bench author200 author10000 {
    merge 1:1 h using ``f'', nogenerate assert(match)
}
generate double theta_h = `rho'^h
generate T_h = 99 - h
generate double mcse_R = sd_R/sqrt(`R')
generate double diff_500 = mean_500 - published_500
generate double diff_200 = mean_200 - author_200
generate double se_10000 = sd_R*sqrt(1/`R' + 1/10000)
generate double z_10000 = (mean_R - author_10000)/se_10000
generate double se_500 = sd_R*sqrt(abs(1/`R' - 1/500))
generate double z_500 = cond(`R' == 500, 0, (mean_R - published_500)/se_500)

format theta_h published_500 mean_500 diff_500 author_200 mean_200 diff_200 author_10000 mean_R sd_R mcse_R %11.8f
format z_10000 z_500 %6.2f
display as text _n "REP01 comparison by horizon"
list h T_h theta_h published_500 mean_500 diff_500 author_200 mean_200 diff_200, clean noobs
list h author_10000 mean_R sd_R mcse_R z_10000 z_500, clean noobs

*--------------------------------------------------------------------------
* 5. Assertions against the benchmarks
*--------------------------------------------------------------------------
lp_assert "REP01: the benchmark's derived row count is T_h = 99 - h" : published_T_h == 99 - h
lp_assert "REP01: the true response equals the authors' rt (1e-6)" : abs(author_theta - theta_h) < 1e-6
lp_assert "REP01: the true response equals the benchmark's true_response (1e-6)" : abs(published_theta - theta_h) < 1e-6

if `R' >= 500 {
    forvalues h = 0/`hmax' {
        local i = `h' + 1
        lp_close mean_500[`i'] published_500[`i'], tol(1e-6) ///
            label(REP01 exact: first 500 draws against the published benchmark at h = `h')
    }
}
else display as text "Fewer than 500 draws: the exact comparison with the 500-draw benchmark is skipped."

if `R' >= 200 {
    forvalues h = 0/`hmax' {
        local i = `h' + 1
        lp_close mean_200[`i'] author_200[`i'], tol(1e-6) ///
            label(REP01 exact: first 200 draws against the authors' script at 200 draws at h = `h')
    }
}
else display as text "Fewer than 200 draws: the exact comparison with the 200-draw run is skipped."

* Statistical comparisons. The published figure's 10,000 draws are treated as
* an independent stream, which gives the wider of the two possible bounds.
forvalues h = 0/`hmax' {
    local i = `h' + 1
    local z = z_10000[`i']
    lp_assert "REP01 statistical: mean of `R' draws within 3 Monte Carlo SE of the 10,000-draw mean at h = `h' (z = `: display %5.2f `z'')" : abs(`z') < 3
}
if `R' != 500 {
    forvalues h = 0/`hmax' {
        local i = `h' + 1
        local z = z_500[`i']
        lp_assert "REP01 statistical: mean of `R' draws within 3 nested Monte Carlo SE of the 500-draw benchmark at h = `h' (z = `: display %5.2f `z'')" : abs(`z') < 3
    }
}
tempfile results
save `results'

*--------------------------------------------------------------------------
* 6. Cross-check: the authors' script at the same number of draws
*--------------------------------------------------------------------------
local author_seconds = .
if "$AUTHOR_CHECK" == "1" {
    save `results', replace
    local here = c(pwd)
    capture mkdir "output/rep01-author"
    quietly cd "output/rep01-author"
    global nobs = `nobs'
    global nreps = `R'
    display as text _n "Running vendor/jel-code/SSBias_IntcpYLagdiffN_95.do with nreps = `R' (progress counter follows)"
    timer clear 13
    timer on 13
    capture noisily quietly do "`here'/vendor/jel-code/SSBias_IntcpYLagdiffN_95.do"
    local rc = _rc
    timer off 13
    quietly cd "`here'"
    if `rc' {
        display as error "The authors' script stopped with r(`rc')."
        exit `rc'
    }
    quietly timer list 13
    local author_seconds = r(t13)
    display as text _n "Authors' script runtime: " as result %8.2f `author_seconds' as text " seconds"
    keep t rl rt
    rename (t rl rt) (h author_script_R author_script_theta)
    merge 1:1 h using `results', nogenerate assert(match)
    sort h
    forvalues h = 0/`hmax' {
        local i = `h' + 1
        lp_close author_script_R[`i'] mean_R[`i'], tol(1e-6) ///
            label(REP01 cross-check: authors' script against this file at R = `R' and h = `h')
    }
    lp_assert "REP01 cross-check: the authors' true response equals 0.95^h (1e-6)" : abs(author_script_theta - theta_h) < 1e-6
    macro drop nobs nreps burn tobs hmax rho a
}
else {
    display as text "AUTHOR_CHECK = 0: the authors' script was not run."
    generate double author_script_R = .
}
generate double diff_author = author_script_R - mean_R
sort h

*--------------------------------------------------------------------------
* 7. The benchmark record, one row per horizon
*--------------------------------------------------------------------------
tempname B
postfile `B' h T_h double(theta_h published_R500 reproduced_R500 diff_R500      ///
    author_R200_v195 reproduced_R200 diff_R200 author_R10000 reproduced_R      ///
    sd_R mcse_R z_vs_R10000 author_script diff_author_script) draws            ///
    double tolerance using "output/rep01-benchmark.dta", replace
forvalues i = 1/11 {
    post `B' (h[`i']) (T_h[`i']) (theta_h[`i']) (published_500[`i'])            ///
        (mean_500[`i']) (diff_500[`i']) (author_200[`i']) (mean_200[`i'])      ///
        (diff_200[`i']) (author_10000[`i']) (mean_R[`i']) (sd_R[`i'])          ///
        (mcse_R[`i']) (z_10000[`i']) (author_script_R[`i']) (diff_author[`i']) ///
        (`R') (1e-6)
}
postclose `B'
preserve
use "output/rep01-benchmark.dta", clear
format theta_h-diff_author_script %12.8f
export delimited using "output/rep01-benchmark.csv", replace datafmt
restore

*--------------------------------------------------------------------------
* 8. Figures
*--------------------------------------------------------------------------
set scheme stcolor
merge 1:1 h using `draw1', nogenerate assert(match)
local ink    "82 81 78"
local muted  "137 135 129"
local blue   "42 120 214"
local orange "217 96 31"
local rule   "195 194 183"

twoway (line theta_h h, lcolor("`ink'") lwidth(medthick))                              ///
       (line author_10000 h, lcolor("`muted'") lpattern(dash) lwidth(medium))          ///
       (scatter published_500 h, msymbol(Oh) mcolor("`orange'") msize(large) mlwidth(medthick)) ///
       (connected mean_R h, lcolor("`blue'") mcolor("`blue'") msymbol(O) msize(small) lwidth(medthick)), ///
       xlabel(0(1)10, nogrid)                                                          ///
       ylabel(0.4(0.1)1.0, format(%3.1f) angle(0) glcolor("`rule'") glpattern(solid) glwidth(vthin)) ///
       xtitle("Horizon h (periods after the intervention)")                            ///
       ytitle("Mean of the estimate across draws")                                     ///
       legend(order(1 "True response 0.95{sup:h}"                                      ///
                    2 "Authors' shipped mean, 10,000 draws"                            ///
                    3 "Course benchmark, 500 draws (Stata 18.5)"                       ///
                    4 "This run, `R' draws (StataNow 19.5)")                           ///
              cols(1) position(1) ring(0) region(lstyle(none) fcolor(white)) size(small)) ///
       graphregion(color(white)) plotregion(color(white)) xsize(6.5) ysize(4.2)
graph export "output/fig-rep01-levels-mean.svg", replace
graph export "output/fig-rep01-levels-mean.png", replace width(1950)

twoway (rarea p5_R p95_R h, color("`blue'%15") lwidth(none))                           ///
       (line theta_h h, lcolor("`ink'") lwidth(medthick))                              ///
       (connected mean_R h, lcolor("`blue'") mcolor("`blue'") msymbol(O) msize(small) lwidth(medthick)) ///
       (connected b_draw1 h, lcolor("`orange'") mcolor("`orange'") msymbol(D) msize(small) lwidth(medium)), ///
       yline(0, lcolor("`rule'")) xlabel(0(1)10, nogrid)                               ///
       ylabel(-0.4(0.2)1.4, format(%3.1f) angle(0) glcolor("`rule'") glpattern(solid) glwidth(vthin)) ///
       xtitle("Horizon h (periods after the intervention)")                            ///
       ytitle("Estimate (units of y per unit of s)")                                   ///
       legend(order(2 "True response 0.95{sup:h}" 3 "Mean of `R' draws"                ///
                    4 "Draw 1 (seed 12345)" 1 "Middle 90 percent of the `R' draws")    ///
              cols(2) position(6) region(lstyle(none)) size(small))                    ///
       graphregion(color(white)) plotregion(color(white)) xsize(6.5) ysize(4.4)
graph export "output/fig-rep01-first-draw.svg", replace
graph export "output/fig-rep01-first-draw.png", replace width(1950)

*--------------------------------------------------------------------------
timer off 11
quietly timer list 11
local total_seconds = r(t11)
local npass = $LP_NPASS - `npass0'
display as text _n "REP01 complete: " as result `npass' as text " assertions passed; R = `R'; Monte Carlo " ///
    as result %7.2f `mc_seconds' as text " s; authors' script " as result %7.2f `author_seconds' ///
    as text " s; total " as result %7.2f `total_seconds' as text " s"
log close rep01
