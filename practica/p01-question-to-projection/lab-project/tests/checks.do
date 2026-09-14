*! checks.do  Network-free checks on the data files and the helper programs
*
*  Local Projections: From First Principles to Empirical Research, Practicum 01.
*
*  master.do runs this file first. It needs no internet connection: the
*  Ramey-Zubairy workbook is checked only when data/raw already holds a copy,
*  and Task 5 of the problem set fetches it with data/raw/get_rz.do.
*  The SHA-256 values below are the ones recorded in data/PROVENANCE.md.
*
*  Writes output/checks.log.
*  Run from the lab project's top folder: do tests/checks.do

version 19
clear
set more off
capture program list lp_assert
if _rc do helpers/lp_helpers.do
lp_root
capture mkdir output
capture log close checks
log using "output/checks.log", text replace name(checks)
global LP_STEP checks
local npass0 = cond("$LP_NPASS" == "", 0, $LP_NPASS)

*==========================================================================
* 1. The helper programs
*==========================================================================
lp_assert "helpers: lp_assert passes a true statement" : 2 + 2 == 4

global LP_SELFTEST 1
capture lp_assert "helpers: a deliberately false statement" : 2 + 2 == 5
local rc_assert = _rc
capture lp_close 1 1.1, tol(1e-6) label(helpers: two numbers that differ)
local rc_close = _rc
global LP_SELFTEST 0
lp_assert "helpers: lp_assert stops with r(9) on a false statement" : `rc_assert' == 9
lp_assert "helpers: lp_close stops with r(9) when two numbers differ by more than tol" : `rc_close' == 9
lp_close 0.617322 (0.61732178 + 2e-7), tol(1e-6) label(helpers: lp_close accepts a difference below tol)

* lp_sha256 on a text whose SHA-256 is known
tempfile known
tempname fh
file open `fh' using "`known'", write binary replace
file write `fh' %17s "local projections" %1bu (10)
file close `fh'
lp_sha256 "`known'"
local sha "`r(sha256)'"
lp_assert "helpers: lp_sha256 returns the SHA-256 of a known text" : ///
    "`sha'" == "d38550f8bb1ce55e64840a41105667865068f82bcada6c073fee3184649717e0"

* lp_json_get on a small record laid out as the Explorer writes it
tempfile json
file open `fh' using "`json'", write text replace
file write `fh' "{" _n
file write `fh' `"  "lecture": "01","' _n
file write `fh' `"  "lab2": {"' _n
file write `fh' `"    "settings": {"' _n
file write `fh' `"      "h": 1,"' _n
file write `fh' `"      "control_y_lag": true"' _n
file write `fh' `"    },"' _n
file write `fh' `"    "beta_h": -1.050405,"' _n
file write `fh' `"    "intervention_rows": ["' _n
file write `fh' `"      5,"' _n
file write `fh' `"      10"' _n
file write `fh' `"    ]"' _n
file write `fh' `"  },"' _n
file write `fh' `"  "lab4": {"' _n
file write `fh' `"    "hypothesis": "It will raise the estimate to about 0.43.","' _n
file write `fh' `"    "used_in": 9"' _n
file write `fh' `"  }"' _n
file write `fh' "}" _n
file close `fh'

lp_json_get using "`json'", key(lecture)
local v "`r(value)'"
local f = r(found)
lp_assert "helpers: lp_json_get reads a top-level string" : "`v'" == "01" & `f' == 1
lp_json_get using "`json'", key(lab2.settings.h)
local v "`r(value)'"
lp_assert "helpers: lp_json_get reads a nested number" : `v' == 1
lp_json_get using "`json'", key(lab2.settings.control_y_lag)
local v "`r(value)'"
lp_assert "helpers: lp_json_get reads a boolean" : "`v'" == "true"
lp_json_get using "`json'", key(lab2.beta_h)
local v "`r(value)'"
lp_assert "helpers: lp_json_get reads a negative number exactly" : abs(`v' - (-1.050405)) < 1e-12
lp_json_get using "`json'", key(lab2.intervention_rows)
local v "`r(value)'"
local n = r(n)
lp_assert "helpers: lp_json_get reads an array" : "`v'" == "5 10" & `n' == 2
lp_json_get using "`json'", key(lab4.hypothesis)
local d "`r(direction)'"
local x "`r(number)'"
lp_assert "helpers: lp_json_get finds the direction and the number in a hypothesis" : "`d'" == "raise" & "`x'" == "0.43"
lp_json_get using "`json'", key(lab9.missing)
local f = r(found)
lp_assert "helpers: lp_json_get reports a missing key" : `f' == 0

*==========================================================================
* 2. The simulated inputs in data/raw
*==========================================================================
local sha_hand_table          "d58b48a56e73d38c682ee621250d25c64ce542bc11c73c73da281edb8a98041f"
local sha_onedraw_rho05_seed2 "5c85f2054698ca65681045ec0e8092460ae44e10867e30a23dc6f242b47232cd"
local sha_onedraw_rho09_seed2 "202051448cb02e7ab55f5cf0af399a76d29969b4de6cdb0a2d0699e725aa34cb"

lp_sha256 "data/raw/hand_table.csv"
local s "`r(sha256)'"
lp_assert "data: hand_table.csv has the SHA-256 in PROVENANCE.md" : "`s'" == "`sha_hand_table'"
import delimited using "data/raw/hand_table.csv", clear
capture confirm numeric variable t s v y
local rc = _rc
lp_assert "data: hand_table.csv has 12 rows and the variables t, s, v, y" : `rc' == 0 & c(k) == 4 & _N == 12
lp_assert "data: hand_table.csv dates run t = 1, ..., 12" : t == _n
lp_assert "data: interventions exactly at t = 1, 5, 10, 12" : s == inlist(t, 1, 5, 10, 12)
lp_assert "data: v is rounded to one decimal" : abs(v - round(v, 0.1)) < 1e-6
generate double yrule = cond(t == 1, s + v, 0.5*y[_n-1] + s + v)
lp_assert "data: y follows y_t = 0.5 y_(t-1) + s_t + v_t with y_0 = 0 (1e-6)" : abs(y - yrule) < 1e-6

foreach tag in 05 09 {
    local rho "0.`=substr("`tag'", 2, 1)'"
    lp_sha256 "data/raw/onedraw_rho`tag'_seed2.csv"
    local s "`r(sha256)'"
    lp_assert "data: onedraw_rho`tag'_seed2.csv has the SHA-256 in PROVENANCE.md" : "`s'" == "`sha_onedraw_rho`tag'_seed2'"
    import delimited using "data/raw/onedraw_rho`tag'_seed2.csv", clear
    capture confirm numeric variable t s v y
    local rc = _rc
    lp_assert "data: onedraw_rho`tag'_seed2.csv has 200 rows and the variables t, s, v, y" : `rc' == 0 & c(k) == 4 & _N == 200
    lp_assert "data: onedraw_rho`tag'_seed2.csv dates run t = 1, ..., 200" : t == _n
    generate double yrule = `rho'*y[_n-1] + s + v
    lp_assert "data: y follows y_t = `rho' y_(t-1) + s_t + v_t (1e-5, float storage)" : abs(y - yrule) < 1e-5 if _n > 1
    quietly summarize s
    local ms = r(mean)
    local ss = r(sd)
    lp_assert "data: s in onedraw_rho`tag' has mean near 0 and standard deviation near 1" : abs(`ms') < 0.25 & `ss' > 0.8 & `ss' < 1.2
}

* The generator reproduces all three files byte for byte.
local simdir "`c(tmpdir)'/p01_simcheck"
capture mkdir "`simdir'"
quietly do "data/raw/make_sim_data.do" "`simdir'"
foreach f in hand_table onedraw_rho05_seed2 onedraw_rho09_seed2 {
    lp_sha256 "`simdir'/`f'.csv"
    local s "`r(sha256)'"
    lp_assert "data: make_sim_data.do regenerates `f'.csv byte for byte" : "`s'" == "`sha_`f''"
}

*==========================================================================
* 3. The authors' files in vendor/jel-code (CC0)
*==========================================================================
local sha_ssbias "2afefb0b1f786fea687ccc29c392c74809812fa1b7b8f91fc75c2d5befd91fc1"
local sha_allsim "960719e2c52d0b91438a2873f5aa9cfbbb17fa220eae63706c8ab566a77662b1"
local sha_means  "720462bff571cccca5e504bda2eb7b230cfacc82abfc23c923088c8366f102a4"
local sha_cc0    "a2010f343487d3f7618affe54f789f5487602331c0a8d03f49e9a7c547cf0499"
foreach pair in "SSBias_IntcpYLagdiffN_95.do ssbias" "all-simulate.do allsim" "SSBias_IntcpYLagdiffN_95.dta means" "LICENSE cc0" {
    gettoken f key : pair
    local key = strtrim("`key'")
    lp_sha256 "vendor/jel-code/`f'"
    local s "`r(sha256)'"
    lp_assert "vendor: `f' has the SHA-256 recorded in vendor/jel-code/SOURCE.md" : "`s'" == "`sha_`key''"
}
use "vendor/jel-code/SSBias_IntcpYLagdiffN_95.dta", clear
capture confirm numeric variable t rl rt
local rc = _rc
lp_assert "vendor: the authors' shipped means hold 11 horizons with t, rl, rt" : `rc' == 0 & _N == 11
lp_assert "vendor: horizons 0 to 10 and true response 0.95^h (1e-6)" : t == _n - 1 & abs(rt - 0.95^t) < 1e-6

*==========================================================================
* 4. The benchmark files in replication/benchmark
*==========================================================================
lp_sha256 "replication/benchmark/REP01-levels-lp.csv"
local s "`r(sha256)'"
lp_assert "benchmark: REP01-levels-lp.csv has the SHA-256 in PROVENANCE.md" : ///
    "`s'" == "1899da92df8a682ec9e13a45c7d9bebf307d2ccce78e71f31d4e9eb135ccdb30"
import delimited using "replication/benchmark/REP01-levels-lp.csv", clear varnames(1) encoding(utf8)
lp_assert "benchmark: REP01-levels-lp.csv holds 11 REP01 rows" : _N == 11 & replication == "REP01"
lp_assert "benchmark: horizons 0 to 10 with n = 99 - h" : horizon == _n - 1 & n == 99 - horizon
lp_assert "benchmark: every horizon has a mean" : coefficient < .

lp_sha256 "replication/benchmark/REP01-author-R200-v195.csv"
local s "`r(sha256)'"
lp_assert "benchmark: REP01-author-R200-v195.csv has the SHA-256 in PROVENANCE.md" : ///
    "`s'" == "72cea43bb335f4c572c1ab3fcc97d8ec1a740278ae059593f447edf5341346c5"
import delimited using "replication/benchmark/REP01-author-R200-v195.csv", clear varnames(1)
lp_assert "benchmark: REP01-author-R200-v195.csv holds horizons 0 to 10 with rl and rt" : _N == 11 & h == _n - 1 & rl < . & rt < .

*==========================================================================
* 5. Files that may or may not be present yet
*==========================================================================
capture confirm file "handoff/l01-explorer-handoff.json"
if _rc == 0 {
    lp_json_get using "handoff/l01-explorer-handoff.json", key(lecture)
    local v "`r(value)'"
    lp_assert "handoff: l01-explorer-handoff.json is a Lecture 01 record" : "`v'" == "01"
    lp_json_get using "handoff/l01-explorer-handoff.json", key(lab3.beta_h)
    local n = r(n)
    lp_assert "handoff: the record holds thirteen Lab 3 estimates" : `n' == 13
}
else display as text "handoff: no record in handoff/ yet; the Explorer's Transfer to Stata section writes one."

capture confirm file "data/raw/RZDAT.xlsx"
if _rc == 0 {
    lp_sha256 "data/raw/RZDAT.xlsx"
    local s "`r(sha256)'"
    lp_assert "data: RZDAT.xlsx is the file of the February 2018 package (SHA-256)" : ///
        "`s'" == "b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120"
    import excel using "data/raw/RZDAT.xlsx", sheet("rzdat") firstrow clear
    capture confirm numeric variable quarter rgdp rgdp_pott6 pgdp news ngov
    local rc = _rc
    lp_assert "data: sheet rzdat has quarter, rgdp, rgdp_pott6, pgdp, news, ngov" : `rc' == 0
    drop if quarter < 1889
    lp_assert "data: 508 quarters from 1889Q1 to 2015Q4" : ///
        _N == 508 & abs(quarter[1] - 1889) < 1e-6 & abs(quarter[_N] - 2015.75) < 1e-6
    quietly count if news < .
    local nn = r(N)
    lp_assert "data: news is recorded in 504 of those quarters" : `nn' == 504
}
else display as text "data: RZDAT.xlsx is not in data/raw yet; Task 5 runs data/raw/get_rz.do to fetch and verify it."

clear
local npass = $LP_NPASS - `npass0'
display as text _n "Checks complete: " as result `npass' as text " assertions passed."
log close checks
