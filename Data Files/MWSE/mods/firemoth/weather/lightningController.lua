local utils = require("firemoth.utils")

local MIN_DISTANCE = 8192 * 0.25
local MAX_DISTANCE = 8192 * 3.5

local lightningObject = tes3.getObject("glass war axe")
local npcLightningObjects = {}
local dissipationRate = 3
local damage = 25
local frequency = 5

--- @type table<tes3reference, number>
local npcTargetRate = {}
local playerTargetRate = 0

local function updateProx(dist)
    local f = math.clamp(dist, MIN_DISTANCE, MAX_DISTANCE)
    f = math.remap(f, MIN_DISTANCE, MAX_DISTANCE, 1.0, 0.0)

    return frequency * f
end

local function update(e)
    if tes3.player.cell.isInterior then
        npcTargetRate = {}
        return
    end

    local currDist = utils.cells.getFiremothDistance()
    local prevDist = e.timer.data.prevDist or currDist
    
    local currCompDist = utils.cells.getCompanionsFiremothDistance()
    local prevCompDist = e.timer.data.prevCompDist or currCompDist

    -- are we within the trigger distance
    -- and has the distance been modified
    if math.min(currDist, prevDist) <= MAX_DISTANCE
        and not math.isclose(currDist, prevDist, 0.001)
    then
        playerTargetRate = updateProx(currDist)
        for companion, dist in pairs(currCompDist) do
            npcTargetRate[companion] = updateProx(dist)
        end
    end

    e.timer.data.prevDist = currDist
end
event.register(tes3.event.loaded, function()
    timer.start({
        iterations = -1,
        duration = 1 / 10,
        callback = update,
        data = { prevDist = 0 },
    })
end)
