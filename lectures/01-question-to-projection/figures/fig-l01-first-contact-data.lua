-- Data for fig-l01-first-contact: OLS local projections of real GDP relative
-- to potential on Ramey-Zubairy military news, toy specification
-- y_{t+h} on (1, newsy_t, y_{t-1}), h = 0, ..., 20.
--
-- fig-l01-first-contact.csv is written by fig-l01-first-contact-data.do
-- (StataNow/SE 19.5) from RZDAT.xlsx; it holds coefficients and sample sizes
-- only. Column beta_h_rz is the Ramey-Zubairy linear-controls specification,
-- quoted in the caption and equal to REP04 irf_gdp_linear.

local L = dofile("lpfig.lua")

local d = L.read_csv("fig-l01-first-contact.csv")
assert(d.__n == 21, "expected h = 0..20")

local peak = 1
for i = 1, d.__n do
  assert(d.T_h[i] == 504 - d.h[i], "T_h must equal 504 - h")
  if d.beta_h[i] > d.beta_h[peak] then peak = i end
end

L.check("beta-hat_0",  d.beta_h[1],  0.080313, 1e-6)
L.check("beta-hat_10", d.beta_h[11], 0.404210, 1e-6)
assert(d.h[peak] == 10, "peak expected at h = 10")
L.check("rz controls, h = 10", d.beta_h_rz[11], 0.29376385, 1e-6)

L.macro("lpFcBhat",  L.coords(d.h, d.beta_h, 1, d.__n))
L.macro("lpFcPeakH", string.format("%d", math.floor(d.h[peak] + 0.5)))
L.macro("lpFcPeakB", string.format("%.6f", d.beta_h[peak]))
L.macro("lpFcPeakLab", string.format("%.3f", d.beta_h[peak]))
