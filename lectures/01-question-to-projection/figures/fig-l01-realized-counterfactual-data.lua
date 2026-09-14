-- Data for fig-l01-realized-counterfactual: the twelve-period hand economy
--   y_t = 0.5 y_{t-1} + s_t + v_t,   y_0 = 0,
-- with the disturbances and shock dates of the hand table (Stata seed 1,
-- v = round(rnormal(),0.1) then s = rbinomial(1,0.3); see the Lecture 1
-- practicum's hand_table.csv). The counterfactual y^c_t switches off the
-- t = 5 shock and holds every v_t fixed. The values are typed exactly, as the
-- hand table prints them, so the recursion here is exact up to double rounding.

local L = dofile("lpfig.lua")

local rho, theta0 = 0.5, 1.0
local s = {1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1}
local v = {0.9, 0.5, 0.6, -0.6, -1.7, 0.2, 2.1, -1.3, 0.8, 0.6, -0.9, 1.5}
local T = #s

local y, yc, t = {}, {}, {}
local prev, prevc = 0, 0
for i = 1, T do
  t[i] = i
  local sc = (i == 5) and 0 or s[i]
  y[i]  = rho * prev  + theta0 * s[i] + v[i]
  yc[i] = rho * prevc + theta0 * sc   + v[i]
  prev, prevc = y[i], yc[i]
end

-- the numbers the notes quote (BRIEF anchor A, hand_table_final.csv)
L.check("y_12", y[12], 2.532275390625, 1e-9)
for k, want in ipairs({1, 0.5, 0.25, 0.125}) do
  L.check("gap t=" .. (4 + k), y[4 + k] - yc[4 + k], want, 1e-12)
end
L.check("y_5 - y_4", y[5] - y[4], -0.73125, 1e-12)
L.check("y_7 - y_4", y[7] - y[4], 1.9703125, 1e-12)

L.macro("lpRcY",  L.coords(t, y, 1, T))
L.macro("lpRcYc", L.coords(t, yc, 4, T))       -- the paths part at t = 5

-- values placed by the annotations
local function set(name, x) L.macro(name, string.format("%.6f", x)) end
for i = 4, 8 do
  set("lpRcY"  .. string.char(96 + i), y[i])    -- \lpRcYd = y_4, \lpRcYe = y_5, ...
  set("lpRcYc" .. string.char(96 + i), yc[i])
end
