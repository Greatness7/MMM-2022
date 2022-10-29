local fog = require("firemoth.weather.fog")
local utils = require("firemoth.utils")

local fogId = "Firemoth Exterior"

---@type fogParams
local fogParams = {
    color = tes3vector3.new(0.06, 0.13, 0.11),
    center = tes3vector3.new(0, 0, 0),
    radius = tes3vector3.new(8192 * 3, 8192 * 3, 220),
    density = 20,
}

local function calcInteriorFogParams(cell)
    local pos = { x = 0, y = 0, z = 0 }
    local denom = 0

    for stat in cell:iterateReferences() do
        pos.x = pos.x + stat.position.x
        pos.y = pos.y + stat.position.y
        pos.z = pos.z + stat.position.z
        denom = denom + 1
    end

    return tes3vector3.new(pos.x / denom, pos.y / denom, pos.z / denom)
end

--- @param e cellChangedEventData
local function cellChangedCallback(e)
    if utils.cells.isFiremothInterior(e.cell) then
        fogParams.center = calcInteriorFogParams(e.cell)
        fog.createOrUpdateFog(fogId, fogParams)
        tes3.messageBox("ADDED INTERIOR FOG")
    else
        fog.deleteFog("Firemoth Interior")
    end
end
event.register(tes3.event.cellChanged, cellChangedCallback)
