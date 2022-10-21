local this = {}

---@class fogParams
---@field colors number[] {r, g, b, r, g, b, r, g, b}
---@field centers number[] {x, y, z, x, y, z, x, y, z}
---@field radi number[] {x, y, z, x, y, z, x, y, z}
---@field densities number[] {a, b, c}

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
    shader.fogDensities = { 15.0, 15.0 }

    return shader
end

return this
