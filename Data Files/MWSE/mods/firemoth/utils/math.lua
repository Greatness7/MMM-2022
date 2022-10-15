local this = {}

local XY = tes3vector3.new(1, 1, 0)

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

---@param rangeX number
---@param rangeY number
---@param rangeZ number
---@return tes3matrix33
function this.getRandomRotation(rangeX, rangeY, rangeZ)
    local x = math.rad(math.random(-rangeX, rangeX))
    local y = math.rad(math.random(-rangeY, rangeY))
    local z = math.rad(math.random(-rangeZ, rangeZ))
    local r = tes3matrix33.new()
    r:fromEulerXYZ(x, y, z)
    return r
end

---@param node niNode
---@param translation tes3vector3
function this.setWorldTranslation(node, translation)
    if node.parent then
        local t = node.parent.worldTransform
        translation = (t.rotation * t.scale):transpose() * (translation - t.translation)
    end
    node.translation = translation
end

---@param a tes3vector3
---@param b tes3vector3
---@return number
function this.xyDistance(a, b)
    return (a * XY):distance(b * XY)
end

return this
