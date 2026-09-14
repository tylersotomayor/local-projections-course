*! get_rz.do  Fetch and verify the Ramey-Zubairy (2018) data
*
*  Local Projections: From First Principles to Empirical Research
*  Source of truth: shared/stata/get_rz.do in the course repository. Each lab
*  project that needs these data carries a copy at data/raw/get_rz.do.
*
*  Usage, from the lab project's top folder:
*      do data/raw/get_rz.do            (writes to data/raw)
*      do data/raw/get_rz.do "otherdir" (writes to otherdir)
*
*  Result: RZDAT.xlsx and rzdatnew.csv in the destination folder, each checked
*  against the SHA-256 of the February 2018 replication package.
*
*  Why a download rather than a copy: Ramey and Zubairy distribute their
*  replication package publicly but state no redistribution license, so the
*  course points to their copy instead of shipping one (editor decisions D5
*  and D35). If the automatic download fails, the file prints the manual steps.

version 18

args dest
if `"`dest'"' == "" local dest "data/raw"

local url "https://drive.google.com/uc?export=download&id=0Bx--MzAt0xM-VklPRWZMcXN3c1k&resourcekey=0-f55VTU8E6JWk1Xn8dMZnQA"
* A test hook: a course maintainer can point the script elsewhere.
if `"$LP_RZ_URL"' != "" local url `"$LP_RZ_URL"'

local sha_xlsx "b2d850872e566ebc6b95a1e057dac2226ef18b58d5a21548594f5ba86c8c6120"
local sha_csv  "433ba651f862ec40c5ebee3a533dbd93e2a91011c27fa3e486b4644b9be2d8af"
local folder   "Ramey_Zubairy_replication_codes"

* ---------- SHA-256 by shelling out (course convention, D35) ----------
capture program drop _lp_sha256
program define _lp_sha256, rclass
    args filename
    tempfile out
    if c(os) == "Windows" {
        shell certutil -hashfile "`filename'" SHA256 > "`out'"
    }
    else {
        shell (shasum -a 256 "`filename'" || sha256sum "`filename'") > "`out'" 2>/dev/null
    }
    local hash ""
    capture confirm file "`out'"
    if _rc == 0 {
        tempname fh
        file open `fh' using "`out'", read text
        file read `fh' line
        while r(eof) == 0 {
            local cand = lower(subinstr(strtrim(`"`line'"'), " ", "", .))
            if ustrregexm(`"`cand'"', "^([0-9a-f]{64})") {
                local hash = ustrregexs(1)
                continue, break
            }
            file read `fh' line
        }
        file close `fh'
    }
    return local sha256 "`hash'"
end

capture program drop _lp_rz_verified
program define _lp_rz_verified, rclass
    args dest sha_xlsx sha_csv
    local ok 1
    foreach pair in "RZDAT.xlsx `sha_xlsx'" "rzdatnew.csv `sha_csv'" {
        gettoken fname expect : pair
        local expect = strtrim("`expect'")
        capture confirm file "`dest'/`fname'"
        if _rc {
            local ok 0
            continue
        }
        _lp_sha256 "`dest'/`fname'"
        if "`r(sha256)'" != "`expect'" {
            display as error "`dest'/`fname' has SHA-256 `r(sha256)'; expected `expect'."
            local ok 0
        }
    }
    return scalar ok = `ok'
end

* ---------- make the destination, one folder level at a time ----------
* Stata's mkdir creates a single level, so data/raw needs data first.
local sofar ""
local rest `"`dest'"'
while `"`rest'"' != "" {
    gettoken part rest : rest, parse("/\")
    local sofar `"`sofar'`part'"'
    if !inlist(`"`part'"', "/", "\") capture mkdir `"`sofar'"'
}

* ---------- already present? ----------
_lp_rz_verified "`dest'" `sha_xlsx' `sha_csv'
if r(ok) {
    display as text "Ramey-Zubairy data present in `dest' and verified (SHA-256)."
    exit
}

* ---------- download, unzip, copy, verify ----------
local here `"`c(pwd)'"'
local work `"`c(tmpdir)'/lp_rz_download"'
capture mkdir `"`work'"'
local zip `"`work'/Ramey_Zubairy_replication_codes.zip"'

display as text "Downloading the Ramey-Zubairy replication package from the authors' public link ..."
capture noisily copy `"`url'"' `"`zip'"', replace
local rc_download = _rc

local rc_unzip 1
if `rc_download' == 0 {
    quietly cd `"`work'"'
    capture noisily unzipfile `"`zip'"', replace
    local rc_unzip = _rc
    quietly cd `"`here'"'
}

local rc_copy 1
if `rc_unzip' == 0 {
    capture noisily {
        copy `"`work'/`folder'/RZDAT.xlsx"' `"`dest'/RZDAT.xlsx"', replace
        copy `"`work'/`folder'/rzdatnew.csv"' `"`dest'/rzdatnew.csv"', replace
    }
    local rc_copy = _rc
}

_lp_rz_verified "`dest'" `sha_xlsx' `sha_csv'
if r(ok) {
    display as text "Downloaded and verified: `dest'/RZDAT.xlsx and `dest'/rzdatnew.csv."
    exit
}

* ---------- manual fallback ----------
display as error _n "The automatic download did not produce verified files."
display as text  "Get the data by hand, then run this file again:"
display as text  "  1. Open Sarah Zubairy's research page, https://sites.google.com/site/sarahzubairy/research,"
display as text  "     and download the replication codes for Ramey and Zubairy (2018, JPE), or use"
display as text  "     https://drive.google.com/file/d/0Bx--MzAt0xM-VklPRWZMcXN3c1k/view?resourcekey=0-f55VTU8E6JWk1Xn8dMZnQA"
display as text  "  2. Unzip Ramey_Zubairy_replication_codes.zip."
display as text  "  3. Copy RZDAT.xlsx and rzdatnew.csv from that folder into `dest'/."
display as text  "This file checks both SHA-256 values before any analysis uses the data."
exit 601
