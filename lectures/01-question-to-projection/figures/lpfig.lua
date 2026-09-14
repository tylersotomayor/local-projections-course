-- ————— Shared helpers for the Lecture 1 figures —————
-- Loaded by the fig-l01-*-data.lua scripts. Nothing here draws random numbers:
-- the simulated observations the figures use were drawn once in Stata and are
-- committed as CSV files beside the figures, so the browser lab, the Stata
-- practicum, and these figures all read identical rows.
--
-- Provides a CSV reader for Stata's `export delimited` output, a small
-- least-squares solver on the normal equations, the horizon-h local projection
-- y_{t+h} on (1, s_t, y_{t-1}), and emitters for pgfplots coordinate lists.

local M = {}

--- Read a comma-separated file with a header row. Returns a table of columns
--- keyed by header name; each column is an array of numbers (nil if missing).
function M.read_csv(path)
  local f = assert(io.open(path, "r"), "cannot open " .. path)
  local header, cols, n = nil, {}, 0
  for line in f:lines() do
    line = line:gsub("\r$", "")
    if line ~= "" then
      local fields = {}
      for field in (line .. ","):gmatch("([^,]*),") do
        fields[#fields + 1] = field
      end
      if not header then
        header = fields
        for _, name in ipairs(header) do cols[name] = {} end
      else
        n = n + 1
        for j, name in ipairs(header) do
          cols[name][n] = tonumber(fields[j])
        end
      end
    end
  end
  f:close()
  cols.__n = n
  return cols
end

--- Solve the least-squares problem y = X b by the normal equations
--- (X'X) b = X'y, using Gaussian elimination with partial pivoting.
--- X is an array of rows, each an array of k regressors.
function M.ols(X, y)
  local k = #X[1]
  local A, c = {}, {}
  for i = 1, k do
    A[i] = {}
    for j = 1, k do A[i][j] = 0 end
    c[i] = 0
  end
  for r = 1, #X do
    local x = X[r]
    for i = 1, k do
      c[i] = c[i] + x[i] * y[r]
      for j = 1, k do A[i][j] = A[i][j] + x[i] * x[j] end
    end
  end
  for p = 1, k do
    local best = p
    for i = p + 1, k do
      if math.abs(A[i][p]) > math.abs(A[best][p]) then best = i end
    end
    A[p], A[best] = A[best], A[p]
    c[p], c[best] = c[best], c[p]
    for i = p + 1, k do
      local m = A[i][p] / A[p][p]
      for j = p, k do A[i][j] = A[i][j] - m * A[p][j] end
      c[i] = c[i] - m * c[p]
    end
  end
  local b = {}
  for i = k, 1, -1 do
    local acc = c[i]
    for j = i + 1, k do acc = acc - A[i][j] * b[j] end
    b[i] = acc / A[i][i]
  end
  return b
end

--- Local projection at horizon h on series indexed 1..T:
---   y_{t+h} = mu_h + beta_h s_t + gamma_h y_{t-1} + u_{t,h},
--- over every row t with y_{t-1} and y_{t+h} observed, i.e. t = 2, ..., T-h,
--- so T_h = T - h - 1. Returns beta_h, gamma_h, mu_h, T_h.
function M.lp(y, s, h)
  local T = #y
  local X, yy = {}, {}
  for t = 2, T - h do
    X[#X + 1] = {1, s[t], y[t - 1]}
    yy[#yy + 1] = y[t + h]
  end
  local b = M.ols(X, yy)
  return b[2], b[3], b[1], #yy
end

-- ————— emitting pgfplots coordinate lists —————

--- Coordinates (x[i], v[i]) for i in [lo, hi], skipping nil entries.
function M.coords(x, v, lo, hi)
  local out = {}
  for i = lo, hi do
    if x[i] ~= nil and v[i] ~= nil then
      out[#out + 1] = string.format("(%.6g,%.6f)", x[i], v[i])
    end
  end
  return table.concat(out, " ")
end

--- Define a global TeX macro.
function M.macro(name, body)
  token.set_macro(name, body, "global")
end

--- Stop the build with a message if a figure number drifts from its source.
function M.check(label, got, want, tol)
  if math.abs(got - want) > tol then
    error(string.format("%s: got %.8f, expected %.8f (tolerance %g)",
                        label, got, want, tol))
  end
end

return M
