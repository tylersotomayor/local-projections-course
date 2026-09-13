* fig-l01-first-contact-data.do
*
* Writes fig-l01-first-contact.csv, the coefficients plotted in
* fig-l01-first-contact: OLS local projections of real GDP relative to
* potential on the Ramey-Zubairy military news variable, h = 0,...,20.
*
*   toy specification      y_{t+h} on (1, newsy_t, y_{t-1})                T_h = 504 - h
*   RZ linear controls     y_{t+h} on (1, newsy_t, 4 lags of newsy, y, g)  T_h = 500 - h
*
* Only the toy specification is drawn; the controls column supplies the value
* quoted in the caption and matches irf_gdp_linear in the REP04 benchmark
* (replication-packages/benchmarks/REP04-linear-fiscal-multiplier.csv).
* The CSV holds estimated coefficients only, never data rows (D5, D33).
*
* Data: Ramey and Zubairy (2018), RZDAT.xlsx, sheet rzdat (February 2018
* package), SHA-256
*   b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120.
* Obtain it with shared/stata/get_rz.do (D35), which verifies the hash.
*
* Usage (StataNow/SE 19.5, D1), from any scratch directory:
*   stata-se -e do /path/to/fig-l01-first-contact-data.do "/path/to/RZDAT.xlsx" "/path/to/fig-l01-first-contact.csv"

version 19
clear all
set more off
args xlsx outcsv
if `"`xlsx'"' == "" | `"`outcsv'"' == "" {
    di as error "usage: do fig-l01-first-contact-data.do RZDAT.xlsx out.csv"
    exit 198
}

import excel `"`xlsx'"', sheet("rzdat") firstrow clear
drop if quarter < 1889
gen qdate = q(1889q1) + _n - 1
format qdate %tq
tsset qdate, quarterly

gen double y     = rgdp/rgdp_pott6                    // real GDP / potential GDP
gen double g     = (ngov/pgdp)/rgdp_pott6             // real government spending / potential GDP
gen double newsy = news/(L.rgdp_pott6*L.pgdp)         // news / lagged nominal potential GDP

quietly count if newsy < .
assert r(N) == 504

tempname P
tempfile res
postfile `P' h double(beta_h) T_h double(beta_h_rz) T_h_rz using `res'
forvalues h = 0/20 {
    quietly regress F`h'.y newsy L.y
    local bt = _b[newsy]
    local nt = e(N)
    quietly regress F`h'.y newsy L(1/4).newsy L(1/4).y L(1/4).g
    post `P' (`h') (`bt') (`nt') (_b[newsy]) (e(N))
}
postclose `P'

use `res', clear
assert T_h    == 504 - h
assert T_h_rz == 500 - h
assert abs(beta_h[1]     - 0.080313)   < 1e-6      // h = 0
assert abs(beta_h[11]    - 0.404210)   < 1e-6      // h = 10, the peak
assert abs(beta_h_rz[1]  - 0.050987698) < 1e-6     // REP04 irf_gdp_linear, h = 0
assert abs(beta_h_rz[11] - 0.29376385)  < 1e-6     // REP04 irf_gdp_linear, h = 10
quietly summarize beta_h
assert beta_h[11] == r(max)

format beta_h beta_h_rz %11.8f
list, clean noobs
export delimited h beta_h T_h beta_h_rz T_h_rz using `"`outcsv'"', replace datafmt
