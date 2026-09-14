*! lp_helpers.do  Helper programs for the Practicum 01 lab project
*
*  Local Projections: From First Principles to Empirical Research, Practicum 01.
*  Every do-file in the project loads this file before it does anything else,
*  and tests/checks.do exercises each program before the replication runs.
*
*  lp_root                                  stop unless Stata is in the project's top folder
*  lp_assert "label" : exp [if exp]         assert exp, then count and record the result
*  lp_close a b, tol(#) label(text)         assert |a - b| < tol and print both numbers
*  lp_sha256 "file"                         SHA-256 of a file in r(sha256), by shelling out (D35)
*  lp_json_get using file, key(a.b.c)       one entry of the Explorer's handoff record
*
*  Globals the programs read, all optional:
*    LP_RECORD    CSV file that receives one line per check (master.do sets it)
*    LP_STEP      name of the step that is writing checks
*    LP_SELFTEST  1 while tests/checks.do exercises the failure path

version 19

*--------------------------------------------------------------------------
capture program drop lp_root
program define lp_root
    version 19
    capture confirm file "master.do"
    local rc1 = _rc
    capture confirm file "helpers/lp_helpers.do"
    if `rc1' | _rc {
        display as error "Run this file from the lab project's top folder, the one that holds master.do."
        display as error "Current folder: `c(pwd)'"
        exit 601
    }
end

*--------------------------------------------------------------------------
capture program drop lp_record
program define lp_record
    version 19
    args label result
    if `"$LP_RECORD"' == "" exit
    if "$LP_SELFTEST" == "1" exit
    capture confirm file `"$LP_RECORD"'
    local new = (_rc != 0)
    local clean = subinstr(`"`label'"', char(34), "'", .)
    tempname fh
    file open `fh' using `"$LP_RECORD"', write append text
    if `new' file write `fh' "step,check,result" _n
    file write `fh' `"$LP_STEP,"`clean'",`result'"' _n
    file close `fh'
end

*--------------------------------------------------------------------------
capture program drop lp_assert
program define lp_assert
    version 19
    * lp_assert "label" : expression [if exp]
    gettoken label 0 : 0, parse(":")
    gettoken colon 0 : 0, parse(":")
    if `"`colon'"' != ":" {
        display as error `"lp_assert: write  lp_assert "label" : expression"'
        exit 198
    }
    if "$LP_NPASS" == "" global LP_NPASS 0
    if "$LP_NFAIL" == "" global LP_NFAIL 0
    capture noisily assert `0'
    local rc = _rc
    if `rc' {
        if "$LP_SELFTEST" != "1" global LP_NFAIL = $LP_NFAIL + 1
        display as error `"FAIL  `label'"'
        lp_record `"`label'"' "fail"
        exit `rc'
    }
    if "$LP_SELFTEST" != "1" global LP_NPASS = $LP_NPASS + 1
    display as text `"pass  `label'"'
    lp_record `"`label'"' "pass"
end

*--------------------------------------------------------------------------
capture program drop lp_close
program define lp_close
    version 19
    * lp_close a b, tol(#) label(text)
    * a and b are numbers or expressions; wrap an expression with spaces in ( ).
    syntax anything(name=pair equalok), Tol(real) Label(string)
    gettoken a rest : pair, match(paren1)
    gettoken b rest : rest, match(paren2)
    if `"`b'"' == "" | `"`rest'"' != "" {
        display as error "lp_close: give exactly two numbers or parenthesized expressions"
        exit 198
    }
    tempname va vb
    scalar `va' = (`a')
    scalar `vb' = (`b')
    local d = abs(`va' - `vb')
    display as text `"`label'"' _n                                    ///
        as text "      value " as result %15.8f `va'                    ///
        as text "   target " as result %15.8f `vb'                      ///
        as text "   |diff| " as result %9.2e `d' as text "   tol " %7.1e `tol'
    lp_assert `"`label'"' : `d' < `tol'
end

*--------------------------------------------------------------------------
capture program drop lp_sha256
program define lp_sha256, rclass
    version 19
    args filename
    confirm file `"`filename'"'
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
            local cand = lower(subinstr(strtrim(`"`macval(line)'"'), " ", "", .))
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

*--------------------------------------------------------------------------
capture program drop lp_json_get
program define lp_json_get, rclass
    version 19
    * lp_json_get using file, key(lab2.settings.h) [display]
    * Reads the record the Shock-to-Response Explorer writes with
    * JSON.stringify(record, null, 2): one key or array element per line and
    * two spaces of indentation per level. Returns
    *   r(found)      1 if the key exists
    *   r(n)          number of values (elements, for an array)
    *   r(value)      the value; array elements separated by spaces; strings
    *                 unquoted, with characters that Stata macros cannot hold
    *                 replaced
    *   r(direction)  for a string: raise, lower, unchanged, or empty
    *   r(number)     for a string: the first decimal number it contains
    syntax using/, Key(string) [Display]
    confirm file `"`using'"'
    local value ""
    local found 0
    local n 0
    local direction ""
    local number ""
    mata: _lp_json_get(`"`using'"', `"`key'"', "`display'" != "")
    return local number `"`number'"'
    return local direction `"`direction'"'
    return local value `"`value'"'
    return scalar n = `n'
    return scalar found = `found'
end

capture mata: mata drop _lp_json_get()
capture mata: mata drop _lp_json_scalar()
capture mata: mata drop _lp_macro_safe()
mata:
string scalar _lp_json_scalar(string scalar s)
{
    string scalar q, bs, out
    q = char(34)
    bs = char(92)
    out = s
    if (strlen(out) >= 2 & substr(out, 1, 1) == q & substr(out, strlen(out), 1) == q) {
        out = substr(out, 2, strlen(out) - 2)
        out = subinstr(out, bs + q, q, .)
        out = subinstr(out, bs + "n", " ", .)
        out = subinstr(out, bs + "t", " ", .)
        out = subinstr(out, bs + bs, bs, .)
    }
    return(out)
}

string scalar _lp_macro_safe(string scalar s)
{
    string scalar out
    out = subinstr(s, char(96), char(39), .)
    out = subinstr(out, char(36), "S", .)
    out = subinstr(out, char(34), char(39), .)
    out = subinstr(out, char(92), "/", .)
    out = subinstr(out, char(39), uchar(8217), .)
    return(out)
}

void _lp_json_get(string scalar fn, string scalar key, real scalar show)
{
    string colvector lines
    string rowvector stack
    string scalar line, content, k, rest, path, values, elem, q, re, raw, low, dir
    real scalar i, j, indent, level, collecting, clevel, found, n, hits

    q = char(34)
    re = "^" + q + "([^" + q + "]+)" + q + ":[ ]*(.*)"
    lines = cat(fn)
    stack = J(1, 50, "")
    collecting = 0
    clevel = 0
    found = 0
    n = 0
    values = ""
    raw = ""
    for (i = 1; i <= rows(lines); i++) {
        line = lines[i]
        content = strtrim(line)
        if (content == "") continue
        indent = strlen(line) - strlen(strltrim(line))
        level = indent / 2
        if (collecting) {
            if (level == clevel & (content == "]" | content == "],")) {
                found = 1
                break
            }
            if (substr(content, strlen(content), 1) == ",") content = substr(content, 1, strlen(content) - 1)
            if (content == "[" | content == "]") continue
            elem = _lp_json_scalar(content)
            values = values + (n > 0 ? " " : "") + elem
            n = n + 1
            continue
        }
        if (level < 1 | level > 50) continue
        if (!ustrregexm(content, re)) continue
        k = ustrregexs(1)
        rest = ustrregexs(2)
        stack[level] = k
        for (j = level + 1; j <= 50; j++) stack[j] = ""
        path = invtokens(stack[1..level], ".")
        if (path != key) continue
        if (substr(rest, strlen(rest), 1) == ",") rest = substr(rest, 1, strlen(rest) - 1)
        if (rest == "[") {
            collecting = 1
            clevel = level
            continue
        }
        if (rest == "[]") {
            found = 1
            break
        }
        if (rest == "{") {
            found = 1
            values = "{object}"
            n = 1
            break
        }
        raw = _lp_json_scalar(rest)
        values = raw
        n = 1
        found = 1
        break
    }
    if (show & found) printf("%s\n", (raw != "" ? raw : values))
    st_local("value", _lp_macro_safe(values))
    st_local("found", strofreal(found))
    st_local("n", strofreal(n))
    if (raw != "") {
        low = ustrlower(raw)
        dir = ""
        hits = 0
        if (ustrregexm(low, "\b(raise|raises|raised|rise|rises|higher|increase|increases|up)\b")) {
            dir = "raise"
            hits = hits + 1
        }
        if (ustrregexm(low, "\b(lower|lowers|lowered|reduce|reduces|fall|falls|decrease|decreases|down|smaller)\b")) {
            dir = "lower"
            hits = hits + 1
        }
        if (ustrregexm(low, "\b(unchanged|no change|leave it)\b")) {
            dir = "unchanged"
            hits = hits + 1
        }
        if (hits != 1) dir = ""
        st_local("direction", dir)
        if (ustrregexm(raw, "(-?[0-9]*[.][0-9]+)")) st_local("number", ustrregexs(1))
    }
}
end
