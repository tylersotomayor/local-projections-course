-- Data for fig-l01-one-draw: one simulated sample against the truth and the
-- sampling spread of the estimator.
--
-- onedraw_rho09_seed2.csv   one draw of y_t = 0.9 y_{t-1} + s_t + v_t with
--                           s_t, v_t iid N(0,1): Stata `set seed 2`, s then v,
--                           300 periods, first 100 dropped, T = 200 (columns
--                           t, s, v, y). The same file ships with the browser
--                           lab and the Lecture 1 practicum.
-- mc_toy_R500_summary.csv   stored simulation result: the same design repeated
--                           R = 500 times from `set seed 3` (s then v in every
--                           replication), LP with y_{t-1}; mean, sd, 5th and
--                           95th percentiles of beta-hat_h by rho and h.
--                           Produced by l01-brief-checks.do, part C, from
--                           mc_v2_results.dta (lecture design runs).
--
-- The local projections themselves are estimated here, by OLS on the normal
-- equations, and checked against the Stata estimates at 1e-6.

local L = dofile("lpfig.lua")

local H = 12

-- ————— one draw: beta-hat_h from y_{t+h} on (1, s_t, y_{t-1}) —————
local d = L.read_csv("onedraw_rho09_seed2.csv")
assert(d.__n == 200, "expected T = 200 rows")
for i = 1, d.__n do assert(d.t[i] == i, "rows must be ordered by t") end

local hs, bhat, theta = {}, {}, {}
for h = 0, H do
  local b, _, _, Th = L.lp(d.y, d.s, h)
  assert(Th == 199 - h, "T_h must equal 199 - h")
  hs[h + 1], bhat[h + 1], theta[h + 1] = h, b, 0.9 ^ h
end

-- Stata, regress F`h'.y s L.y (brief, anchor B and log D09)
local stata = {[0] = 0.878940, [4] = 0.548477, [8] = 0.240595, [12] = -0.293297}
for h, want in pairs(stata) do
  L.check("beta-hat_" .. h, bhat[h + 1], want, 1e-6)
end

-- ————— stored band: 5th and 95th percentiles across R = 500 samples —————
local m = L.read_csv("mc_toy_R500_summary.csv")
local p5, p95 = {}, {}
for i = 1, m.__n do
  if math.abs(m.rho[i] - 0.9) < 1e-6 then
    local h = math.floor(m.h[i] + 0.5)
    p5[h + 1], p95[h + 1] = m.p5[i], m.p95[i]
  end
end
for h = 0, H do assert(p5[h + 1] and p95[h + 1], "band missing at h = " .. h) end
L.check("p5_12", p5[H + 1], -0.106968, 1e-6)

L.macro("lpOdBhat",  L.coords(hs, bhat, 1, H + 1))
L.macro("lpOdTheta", L.coords(hs, theta, 1, H + 1))
L.macro("lpOdLo",    L.coords(hs, p5, 1, H + 1))
L.macro("lpOdHi",    L.coords(hs, p95, 1, H + 1))
L.macro("lpOdBtwelve", string.format("%.6f", bhat[H + 1]))
L.macro("lpOdBtwelveLab", string.format("%.3f", bhat[H + 1]))
L.macro("lpOdPtwelve", string.format("%.6f", p5[H + 1]))
