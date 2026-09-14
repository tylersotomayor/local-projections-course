*! make_sim_data.do  Regenerate the simulated inputs of the Practicum 01 lab project
*
*  Local Projections: From First Principles to Empirical Research, Practicum 01.
*
*  The three CSV files in data/raw were written by exactly these commands in
*  StataNow/SE 19.5 on 2026-09-13, and they are the observations the
*  Shock-to-Response Explorer displays (Labs 2 and 3):
*
*    hand_table.csv            the twelve-period economy of Lecture 01 (seed 1)
*    onedraw_rho05_seed2.csv   one sample of T = 200 periods, rho = 0.5 (seed 2)
*    onedraw_rho09_seed2.csv   one sample of T = 200 periods, rho = 0.9 (seed 2)
*
*  Usage, from the lab project's top folder:
*      do data/raw/make_sim_data.do "some/other/folder"
*
*  The file refuses to write into data/raw, so the shipped inputs are never
*  modified in place. tests/checks.do runs it into a temporary folder and
*  asserts that the regenerated files match the shipped ones.
*
*  Seeds were fixed before any estimate was computed (editor decision D32).

version 19
args outdir
if `"`outdir'"' == "" {
    display as error "usage: do data/raw/make_sim_data.do outdir   (any folder except data/raw)"
    exit 198
}
local check = subinstr(subinstr(`"`outdir'"', "\", "/", .), "./", "", .)
if inlist(`"`check'"', "data/raw", "data/raw/") {
    display as error "make_sim_data.do never overwrites the shipped files in data/raw; choose another folder"
    exit 198
}
capture mkdir `"`outdir'"'

*--------------------------------------------------------------------------
* 1. The twelve-period economy: y_t = 0.5 y_(t-1) + s_t + v_t, y_0 = 0.
*    All twelve disturbances are drawn first, then all twelve interventions.
*--------------------------------------------------------------------------
clear
set seed 1
set obs 12
generate t = _n
tsset t
generate v = round(rnormal(), 0.1)          // standard normal, rounded to 0.1
generate s = rbinomial(1, 0.3)              // intervention: 1 with probability 0.3
generate double y = s + v in 1              // y_0 = 0
replace y = 0.5*L.y + s + v in 2/12
export delimited t s v y using `"`outdir'/hand_table.csv"', replace

*--------------------------------------------------------------------------
* 2. One sample for each rho: y_t = rho y_(t-1) + s_t + v_t with s_t and v_t
*    independent standard normal. 300 periods, all s drawn before any v, the
*    first 100 periods discarded, so T = 200.
*--------------------------------------------------------------------------
foreach rho in 0.5 0.9 {
    clear
    set seed 2
    set obs 300
    generate t = _n
    tsset t
    generate s = rnormal()
    generate v = rnormal()
    generate y = .
    replace y = s + v in 1
    replace y = `rho'*L.y + s + v in 2/300
    drop if t <= 100
    replace t = _n
    tsset t
    local tag = subinstr("`rho'", ".", "", .)
    export delimited t s v y using `"`outdir'/onedraw_rho`tag'_seed2.csv"', replace
}
clear
