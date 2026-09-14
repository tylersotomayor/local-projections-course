-- Data for fig-l01-persistence: the causal response of the AR(1) economy,
--   theta_h = theta_0 rho^h,   theta_0 = 1,
-- for rho = 0.9 and rho = 0.5 at h = 0, ..., 12 (derivation D1 of the brief).

local L = dofile("lpfig.lua")

local H, mark = 12, 7
local h, hi, lo = {}, {}, {}
for k = 0, H do
  h[k + 1]  = k
  hi[k + 1] = 0.9 ^ k
  lo[k + 1] = 0.5 ^ k
end

L.check("0.9^7", hi[mark + 1], 0.4782969, 1e-12)
L.check("0.5^7", lo[mark + 1], 0.0078125, 1e-12)

L.macro("lpPsHi", L.coords(h, hi, 1, H + 1))
L.macro("lpPsLo", L.coords(h, lo, 1, H + 1))
L.macro("lpPsHiSeven", string.format("%.4f", hi[mark + 1]))
L.macro("lpPsLoSeven", string.format("%.4f", lo[mark + 1]))
L.macro("lpPsHiSevenLab", string.format("%.3f", hi[mark + 1]))
L.macro("lpPsLoSevenLab", string.format("%.4f", lo[mark + 1]))
