local fog = require("firemoth.weather.fog")
local utils = require("firemoth.utils")

local fogId = "Firemoth Interior"

---@type fogParams
local fogParams = {
    color = tes3vector3.new(0.06, 0.13, 0.11),
    center = tes3vector3.new(),
    radius = tes3vector3.new(),
    density = 2.5,
}

local function calcInteriorFogCenter(cell)
    -- get the min z position of static's bonding boxes
    local minimumZ = tes3.player.position.z
    if not (cell.name == "Firemoth, Chapel of Kynareth") then
        for ref in cell:iterateReferences(tes3.objectType.static) do
            minimumZ = math.min(minimumZ, (ref.position + ref.object.boundingBox.min).z)
        end
    end

    local root = tes3.game.worldObjectRoot
    local origin = root.worldBoundOrigin
    local radius = root.worldBoundRadius

    -- center fog then lower it to bounding box minimum z
    fogParams.center.x = origin.x
    fogParams.center.y = origin.y
    fogParams.center.z = minimumZ

    -- update radius to cover 64 units above player (feet)
    fogParams.radius.x = radius
    fogParams.radius.y = radius
    fogParams.radius.z = tes3.player.position.z - minimumZ + 64
end

--- @param e cellChangedEventData
local function cellChangedCallback(e)
    if utils.cells.isFiremothInterior(e.cell) then
        calcInteriorFogCenter(e.cell)
        fog.createOrUpdateFog(fogId, fogParams)
    else
        fog.deleteFog(fogId)
    end
end
event.register(tes3.event.cellChanged, cellChangedCallback)
