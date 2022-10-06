--- @type function
local boundsIntersect = require("firemoth.utils.math").boundsIntersect

local r = tes3.getReference("fm_mf_corner_r")
local b = tes3.getReference("fm_mf_corner_b")
local g = tes3.getReference("fm_mf_corner_g")
local y = tes3.getReference("fm_mf_corner_y")

local function getCornerReferences()
    for ref in tes3.player.cell:iterateReferences() do
        if ref.id:lower() ~= "in_impsmall_corner_01" then
            -- pass
        elseif ref.position:distance(r.position) <= 1e-9 then
            r.tempData.fm_corner = ref
        elseif ref.position:distance(b.position) <= 1e-9 then
            b.tempData.fm_corner = ref
        elseif ref.position:distance(g.position) <= 1e-9 then
            g.tempData.fm_corner = ref
        end
    end
end

local wasInsideB = false
local function controller(e)
    local isInsideB = boundsIntersect(tes3.player.sceneNode, b.sceneNode)

    if wasInsideB and not isInsideB then
        local isInsideY = boundsIntersect(tes3.player.sceneNode, y.sceneNode)

        local needsSwap = false
        if isInsideY then
            needsSwap = r.position.z > g.position.z
        else
            needsSwap = r.position.z < g.position.z
        end

        if needsSwap then
            r.position, g.position = g.position:copy(), r.position:copy()
            r.tempData.fm_corner.position = r.position
            g.tempData.fm_corner.position = g.position
        end
    end

    wasInsideB = isInsideB
end

event.register("cellChanged", function(e)
    if e.cell == y.cell then
        getCornerReferences()
        event.register(tes3.event.simulate, controller)
    else
        event.unregister(tes3.event.simulate, controller)
    end
end)
