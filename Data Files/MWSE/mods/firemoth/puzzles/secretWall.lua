--- @type tes3reference[]
local referencesToCheck = {}

local wall = tes3.getReference("sb_secretWall")

local function checkLighting()
    local lightFound = false
    for _, ref in ipairs(referencesToCheck) do
        --- @type tes3light
        local light = tes3.getEquippedItem { actor = ref, objectType = tes3.objectType.light }.object
        if ((ref.position + tes3vector3.new(0, 0, 128)):distance(wall.position) <= light.radius * 1.5) then
            wall:setNoCollisionFlag(false, true)
            lightFound = true
            break
        end
    end
    if (lightFound == false) then
        wall:setNoCollisionFlag(true, true)
    end
end

event.register(tes3.event.equipped, function(e)
    if (e.item.objectType == tes3.objectType.light) then
        table.insert(referencesToCheck, e.reference)
    end
end)

event.register(tes3.event.unequipped, function(e)
    if (e.item.objectType == tes3.objectType.light) then
        table.removevalue(referencesToCheck, e.reference)
    end
end)

event.register(tes3.event.referenceDeactivated, function(e)
    if (e.reference.mobile) then
        local light = tes3.getEquippedItem { actor = e.reference, objectType = tes3.objectType.light }
        if (light and light.object.objectType == tes3.objectType.light) then
            table.removevalue(referencesToCheck, e.reference)
        end
    end
end)

event.register(tes3.event.loaded, function()
    timer.start { iterations = -1, duration = 1 / 10, callback = checkLighting, data = {} }
end)
