local this = {}

---@param x number Time function
---@param a number Amplitude
---@param o number Offset
---@param w number Width / 2
function this.bellCurve(x, a, o, w)
    return a * math.exp(-(x - o) ^ 2 / (2 * (w * 0.25) ^ 2))
end

---@param a niNode
---@param b niNode
---@return boolean
function this.boundsIntersect(a, b)
    local dist = a.worldBoundOrigin:distance(b.worldBoundOrigin)
    local radi = a.worldBoundRadius + b.worldBoundRadius
    return dist <= radi
end

return this
