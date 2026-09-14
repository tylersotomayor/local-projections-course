*! master.do  Practicum 01 lab project: the one entry point
*
*  Local Projections: From First Principles to Empirical Research
*  Practicum 01 . From an Economic Question to a Local Projection
*  Replication lab REP01, Stata problem set STA01, and the Shock-to-Response
*  Explorer handoff. Tested with StataNow/SE 19.5 (editor decision D1).
*
*  Usage, with Stata's working folder set to this folder:
*      do master.do             checks, REP01, your problem set, handoff check
*      do master.do solution    the same, with solution/pset_solution.do
*                               in place of starter/pset.do
*  In batch:
*      stata-se -e do master.do
*
*  Order of work
*    1. tests/checks.do            network-free checks on the data and helpers
*    2. replication/rep01.do       REP01 against its benchmarks
*    3. starter/pset.do            STA01, your code
*       (solution/pset_solution.do with the argument solution)
*    4. handoff/check_handoff.do   the Explorer's record, rerun in Stata
*  The first failed assertion stops the run. Everything lands in output/:
*  master.log and one log per step, assertions.csv (every check and its
*  result), and the REP01 benchmark record and figures.
*
*  Globals you may set before running
*    R             Monte Carlo draws for REP01 and Task 4. Default 200, or
*                  500 with the argument solution (editor decision D2).
*    AUTHOR_CHECK  1 also runs the authors' script at the same R. Default 1.

version 19
args mode
clear all
set more off
set linesize 120

local here = c(pwd)
capture confirm file "`here'/master.do"
local rc1 = _rc
capture confirm file "`here'/helpers/lp_helpers.do"
if `rc1' | _rc {
    display as error "Set Stata's working folder to the lab project's top folder (the one that holds master.do), then run  do master.do"
    exit 601
}
if !inlist("`mode'", "", "solution") {
    display as error "master.do takes no argument, or the single argument solution."
    exit 198
}
if "`mode'" == "solution" {
    capture confirm file "`here'/solution/pset_solution.do"
    if _rc {
        display as error "solution/pset_solution.do is missing from this copy of the lab project; the archive on the Practicum 01 page includes it."
        display as error "Run  do master.do  (no argument) to run the checks, REP01, and your own starter/pset.do."
        exit 601
    }
}

capture mkdir "`here'/output"
capture log close _all
log using "`here'/output/master.log", text replace name(master)

do "`here'/helpers/lp_helpers.do"
global LP_NPASS 0
global LP_NFAIL 0
global LP_SELFTEST 0
global LP_RECORD "output/assertions.csv"
capture erase "$LP_RECORD"
if "$R" == "" global R = cond("`mode'" == "solution", 500, 200)
if "$AUTHOR_CHECK" == "" global AUTHOR_CHECK 1
local problem_set = cond("`mode'" == "solution", "solution/pset_solution.do", "starter/pset.do")

display as text _n "Practicum 01 lab project"
display as text "  problem set   `problem_set'"
display as text "  draws         R = $R;  authors' script cross-check AUTHOR_CHECK = $AUTHOR_CHECK"
display as text "  Stata         `c(stata_version)', edition `c(edition_real)', `c(os)'"
display as text "  started       `c(current_date)' `c(current_time)'"

timer clear 1
timer on 1

*--------------------------------------------------------------------------
* 1. Checks on the data files and the helper programs
*--------------------------------------------------------------------------
do "tests/checks.do"

*--------------------------------------------------------------------------
* 2. Replication lab REP01
*--------------------------------------------------------------------------
do "replication/rep01.do"

*--------------------------------------------------------------------------
* 3. Stata problem set STA01
*--------------------------------------------------------------------------
if "`mode'" == "solution" {
    display as text _n "Running solution/pset_solution.do. Its commands and written answers go only to"
    display as text "output/pset/pset.log; the checks it passes are listed in output/assertions.csv."
    local npass_before = $LP_NPASS
    log off master
    capture noisily do "solution/pset_solution.do"
    local rc = _rc
    log on master
    if `rc' {
        display as error "solution/pset_solution.do stopped with r(`rc'); see output/pset/pset.log."
        exit `rc'
    }
    display as text "STA01 instructor solution: " as result $LP_NPASS - `npass_before' as text " assertions passed."
}
else {
    do "starter/pset.do"
}

*--------------------------------------------------------------------------
* 4. The Explorer's handoff record, rerun in Stata
*--------------------------------------------------------------------------
do "handoff/check_handoff.do"

timer off 1
quietly timer list 1
local seconds = r(t1)
display as text _n "Assertions passed: " as result $LP_NPASS as text ";  failed: " as result $LP_NFAIL
display as text "Runtime: " as result %8.1f `seconds' as text " seconds (R = $R)"
display as text "Finished `c(current_date)' `c(current_time)'"
display as result "MASTER COMPLETE"
log close master
