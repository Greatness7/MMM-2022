--- @type function
local isBoxVisible = require("firemoth.utils.visibility").isBoxVisible

local a = tes3.getReference("fm_mf_stairs_a")
local b = tes3.getReference("fm_mf_stairs_b")
assert(a.cell == b.cell)

local aabb = nil
local function getAABB()
    local ref = tes3.getReference("fm_mf_stairs_aabb")

    local wt = ref.sceneNode.worldTransform
    local rs = wt.rotation * wt.scale

    aabb = ref.object.boundingBox:copy()
    aabb.min = rs * aabb.min + wt.translation
    aabb.max = rs * aabb.max + wt.translation
end

local function getAssociatedReferences()
    for ref in tes3.player.cell:iterateReferences() do
        if ref.id:lower() ~= "in_impsmall_stairs_01" then
            -- pass
        elseif ref.position:distance(a.position) <= 1e-9 then
            a.tempData.fm_stairs = ref
        elseif ref.position:distance(b.position) <= 1e-9 then
            b.tempData.fm_stairs = ref
        end
    end
    a.tempData.fm_stairs:enable()
    b.tempData.fm_stairs:disable()
end

local alternate = true
local wasVisible = false
local function controller()
    if tes3.player.position.x < math.min(aabb.min.x, aabb.max.x) then
        return
    end

    local isVisible = isBoxVisible(aabb)

    if wasVisible and not isVisible then
        alternate = not alternate
        if alternate then
            a.tempData.fm_stairs:enable()
            b.tempData.fm_stairs:disable()
        else
            a.tempData.fm_stairs:disable()
            b.tempData.fm_stairs:enable()
        end
    end

    wasVisible = isVisible
end

event.register("cellChanged", function(e)
    if e.cell == a.cell then
        getAABB()
        getAssociatedReferences()
        event.register(tes3.event.simulate, controller)
    else
        event.unregister(tes3.event.simulate, controller)
    end
end)
