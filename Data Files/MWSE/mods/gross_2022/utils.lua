local utils = {}

---@param x number Time function
---@param a number Amplitude
---@param o number Offset
---@param w number Width / 2
function utils.bellCurve(x, a, o, w)
    return a * math.exp(-(x - o) ^ 2 / (2 * (w * 0.25) ^ 2))
end

return utils
