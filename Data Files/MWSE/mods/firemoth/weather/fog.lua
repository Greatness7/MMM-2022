local this = {}

---@class fogParams
---@field colors number[]
---@field centers number[]
---@field radi number[]
---@field densities number[]

---comment
---@param t fogParams
---@return mgeShaderHandle
function this.createFog(t)
    local shader = mge.shaders.load({ name = "fog_box" })
    shader:reload()
    shader.enabled = true

    shader.fogColors = t.colors
    shader.fogCenters = t.centers
    shader.fogRadi = t.radi
    shader.fogDensities = t.densities

    return shader
end

return this
