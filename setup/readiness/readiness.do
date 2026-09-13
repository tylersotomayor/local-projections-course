* readiness.do — Local Projections course, readiness exercise
* Run from this directory:  do readiness.do
* Fill in each TASK; the completed version is readiness_solution.do.
* Tested in batch with StataNow/SE 19.5.

version 19
clear all
set more off

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

* TASK 1a. In a comment, say why y_lead2 is missing in row 7 and in rows 23
*          and 24, and why row 9 is still usable while row 10 is not.
* TASK 1b. Predict how many rows `regress F2.y L1.y` uses, then check e(N).
quietly regress F2.y L1.y
display "Rows used: " e(N)

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

* TASK 2a. Explain in a comment why N falls by one each time h rises.
* TASK 2b. Reproduce the same table with postfile / post / postclose.

* ---------- 3. Logs, differences, percent, and percentage points ----------
clear
set obs 3
gen level = 100 * 1.02^(_n - 1)
gen log100 = 100 * ln(level)
gen pct_change = 100 * (level / level[_n-1] - 1)
gen logdiff    = log100 - log100[_n-1]
gen rate = 4 + _n
gen rate_change_pp = rate - rate[_n-1]
list, clean noobs

* TASK 3a. State the units of each generated column in a comment.
* TASK 3b. Say why the change in rate is 1 percentage point and not 20 percent,
*          and when logdiff approximates pct_change well.

* ---------- 4. A coefficient, a counterfactual, and an interval ----------
clear
set seed 20260913
set obs 200
gen s = rnormal()
gen y = 1.5 + 0.8 * s + rnormal(0, 2)
regress y s

* TASK 4a. Write the sentence the coefficient on s supports: intervention,
*          units, and the comparison it makes.
* TASK 4b. Compute the 95% interval by hand from _b[s], _se[s], and
*          invttail(e(df_r), 0.025); compare with r(table).
* TASK 4c. Say what the interval is a claim about, and what it is not.
