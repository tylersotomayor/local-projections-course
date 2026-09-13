* readiness_solution.do — Local Projections course, readiness exercise
* Completed version. Run from this directory:  do readiness_solution.do
* Tested in batch with StataNow/SE 19.5.

version 19
clear all
set more off
capture log close
* The published log is written here, not by batch mode: batch logs print the
* Stata license banner, which must never be committed or served.
log using readiness_expected_output.log, text replace

* ---------- 1. Time-series setup, leads, lags, and missing values ----------
clear
set obs 24
gen t = _n
tsset t
gen y = 0.7 * (t - 12)^2 / 50 + 2
replace y = . in 9
gen y_lead2 = F2.y
gen y_lag1  = L1.y
list t y y_lag1 y_lead2 in 7/12, clean noobs

* F2.y is missing in row 7 because it reaches the missing row 9, and in rows
* 23 and 24 because the lead runs off the end of the sample. Row 9 itself is
* still usable (its lead and lag both exist); row 10 is not (its lag is row 9).
* A regression of F2.y on L1.y therefore loses rows 1, 7, 10, 23, and 24.
quietly regress F2.y L1.y
display "Rows used by regress F2.y L1.y: " e(N)
assert e(N) == 24 - 5

* ---------- 2. Loops, stored results, and a coefficient table ----------
matrix results = J(4, 3, .)
forvalues h = 0/3 {
    quietly regress F`h'.y L1.y
    matrix results[`h' + 1, 1] = `h'
    matrix results[`h' + 1, 2] = _b[L1.y]
    matrix results[`h' + 1, 3] = e(N)
}
matrix colnames results = h b_lag N
matrix list results, format(%9.4f)

* The same table with postfile. N falls by one per horizon because each extra
* lead removes one more row at the end of the sample (and, here, one more row
* before the missing observation).
tempname handle
tempfile table
postfile `handle' h b_lag N using `table', replace
forvalues h = 0/3 {
    quietly regress F`h'.y L1.y
    post `handle' (`h') (_b[L1.y]) (e(N))
}
postclose `handle'
preserve
use `table', clear
list, clean noobs
forvalues h = 1/3 {
    assert N[`h' + 1] == N[`h'] - 1
}
restore

* ---------- 3. Logs, differences, percent, and percentage points ----------
clear
set obs 3
gen level = 100 * 1.02^(_n - 1)          // a level, index units
gen log100 = 100 * ln(level)             // log points
gen pct_change = 100 * (level / level[_n-1] - 1)   // percent
gen logdiff    = log100 - log100[_n-1]   // log points, approx. percent
gen rate = 4 + _n                        // a rate, in percent
gen rate_change_pp = rate - rate[_n-1]   // percentage points
list, clean noobs

* rate rises from 5 to 6: one percentage point (a difference of two
* percentages), which is also a 20 percent increase (a ratio). The log
* difference approximates the percent change when the change is small:
assert abs(logdiff[2] - pct_change[2]) < 0.05
display "percent change: " %6.3f pct_change[2] "   log-difference: " %6.3f logdiff[2]

* ---------- 4. A coefficient, a counterfactual, and an interval ----------
clear
set seed 20260913
set obs 200
gen s = rnormal()
gen y = 1.5 + 0.8 * s + rnormal(0, 2)
regress y s

* The coefficient on s is the average difference in y between observations
* whose s differs by one unit, holding nothing else fixed. It is a response
* only if s is unrelated to everything else that moves y; here that is true by
* construction.
scalar b   = _b[s]
scalar se  = _se[s]
scalar lo  = b - invttail(e(df_r), 0.025) * se
scalar hi  = b + invttail(e(df_r), 0.025) * se
display "95% interval by hand: [" %6.3f lo ", " %6.3f hi "]"
matrix ci = r(table)
assert abs(ci["ll", "s"] - lo) < 1e-6 & abs(ci["ul", "s"] - hi) < 1e-6
display "The interval is a claim about repeated samples of 200 observations,"
display "not about where the coefficient lies with 95 percent probability."
display "READINESS CHECKS PASSED"
log close
