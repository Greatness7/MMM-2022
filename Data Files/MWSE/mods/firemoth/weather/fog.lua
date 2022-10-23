local this = {}

local NUM_FOG_VOLUMES = 2

local fogVolumes = {
    fogCenters = {
        0, 0, 0,
        0, 0, 0,
    },
    fogRadi = {
        0, 0, 0,
        0, 0, 0,
    },
    fogColors = {
        0, 0, 0,
        0, 0, 0,
    },
    fogDensities = {
        0,
        0,
    },
}

--- Associates each active fog volume to a specific available index.
---@type table<string, number>
local activeFogVolumes = {}

---@class fogParams
---@field color tes3vector3
---@field center tes3vector3
---@field radius tes3vector3
---@field density number


---@return number|nil
local function getNextAvailableIndex()
    for i = 1, NUM_FOG_VOLUMES do
        if not activeFogVolumes[i] then
            return i
        end
    end
end


---@param id string
---@return number|nil
local function getFogVolumeIndex(id)
    local index = activeFogVolumes[id]
    return index or getNextAvailableIndex()
end


---@param i number
---@param params fogParams
local function setParamsForIndex(i, params)
    fogVolumes.fogCenters[i] = params.center.x
    fogVolumes.fogCenters[i + 1] = params.center.y
    fogVolumes.fogCenters[i + 2] = params.center.z

    fogVolumes.fogRadi[i] = params.radius.x
    fogVolumes.fogRadi[i + 1] = params.radius.y
    fogVolumes.fogRadi[i + 2] = params.radius.z

    fogVolumes.fogColors[i] = params.color.x
    fogVolumes.fogColors[i + 1] = params.color.y
    fogVolumes.fogColors[i + 2] = params.color.z

    fogVolumes.fogDensities[i] = params.density
end


local function applyShaderParams()
    this.shader = mge.shaders.load({ name = "fog_box" })
    if this.shader then
        this.shader.enabled = true
        this.shader.fogColors = fogVolumes.fogColors
        this.shader.fogCenters = fogVolumes.fogCenters
        this.shader.fogRadi = fogVolumes.fogRadi
        this.shader.fogDensities = fogVolumes.fogDensities
    end
end


---@param id string
---@param params fogParams
function this.updateFog(id, params)
    local index = getFogVolumeIndex(id)
    if index then
        setParamsForIndex(index, params)
        applyShaderParams()
    end
end


---@param id string
function this.deleteFog(id)
    local index = getFogVolumeIndex(id)
    if index then
        setParamsForIndex(index, {
            color = tes3vector3.new(),
            center = tes3vector3.new(),
            radius = tes3vector3.new(),
            density = 0,
        })
        fogVolumes[id] = nil
        if not next(fogVolumes) then
            this.shader.enabled = false
        end
    end
end


function this.enable()
    this.shader.enabled = true
end


function this.disable()
    this.shader.enabled = false
end


---@return boolean
function this.isEnabled()
    return this.shader.enabled
end


return this
