local fog = require("firemoth.shaders.fog")

local fogId = "Firemoth Interior"

---@type fogParams
local fogParams = {
    color = tes3vector3.new(0.09, 0.2, 0.15),
    center = tes3vector3.new(),
    radius = tes3vector3.new(),
    density = 60,
}

local function calcInteriorFogParams(marker)
    local root = tes3.game.worldObjectRoot

    local origin = root.worldBoundOrigin
    local radius = root.worldBoundRadius

    fogParams.center.x = origin.x
    fogParams.center.y = origin.y
    fogParams.center.z = marker.position.z

    fogParams.radius.x = radius
    fogParams.radius.y = radius
    fogParams.radius.z = math.deg(marker.orientation.z)

    -- encoded such that 1.04 scale is 4 density
    fogParams.density = (marker.scale - 1.0) * 100
end


local fogLayerMarker = assert(tes3.getObject("fm_fog_layer"))

event.register(tes3.event.referenceActivated, function(e)
    if e.reference.object == fogLayerMarker then
        calcInteriorFogParams(e.reference)
        fog.createOrUpdateFog(fogId, fogParams)
    end
end)

event.register(tes3.event.referenceDeactivated, function(e)
    if e.reference.object == fogLayerMarker then
        fog.deleteFog(fogId)
    end
end)
