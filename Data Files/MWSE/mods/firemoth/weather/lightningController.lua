local lightning = require("firemoth.weather.lightning")
local utils = require("firemoth.utils")

local MIN_DISTANCE = 8192 * 0.25
local MAX_DISTANCE = 8192 * 3

--- @type mwseTimer
local lightningTimer = nil
--- @type mwseTimer[]
local npcLightningTimers = {}
local dissipationRate = 3
local damage = 25
local frequency = 5

--- @type table<tes3reference, number>
local npcTargetRate = {}
local playerTargetRate = 0

local function offsetPos(pos, f)
    local rot = tes3matrix33.new()
    rot:fromEulerXYZ(0, 0, 180 + math.random(-135, 135))
    return pos + (tes3.player.sceneNode.rotation + rot):transpose().y * (4096 - math.lerp(256, 4096, f))
end

local function normalProx(dist)
    local f = math.clamp(dist, MIN_DISTANCE, MAX_DISTANCE)
    f = math.remap(f, MIN_DISTANCE, MAX_DISTANCE, 1.0, 0.0)

    return f
end

local function calculateTargetRate(dist)
    return frequency * normalProx(dist)
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
        and normalProx(currDist) > 0
    then
        playerTargetRate = calculateTargetRate(currDist)
        -- debug.log(playerTargetRate - 1)
        -- debug.log(frequency)
        -- debug.log(1 - utils.math.bellCurve(normalProx(currDist), (frequency - 1) * playerTargetRate, 0, frequency) + (frequency - 1))
        if (lightningTimer == nil or lightningTimer.state == timer.expired) then
            lightningTimer = timer.start{
                duration = math.max(1, 1 - utils.math.bellCurve(normalProx(currDist), (frequency - 1) * playerTargetRate, 0, frequency) + (frequency - 1)),
                callback = function ()
                    lightning.createLightningStrike(offsetPos(tes3.player.position, normalProx(currDist)), true, (1 - utils.math.bellCurve(normalProx(currDist), 1, 0, frequency / 2)))
                    --- @type tes3spell
                    local me = tes3.getObject("lightning bolt")
                    me.effects[1].duration = 1
                    me.effects[1].min = damage
                    me.effects[1].max = damage
                    tes3.applyMagicSource{
                        reference = tes3.player,
                        source = me
                    }
                end
            }
        end
    end
    for companion, compDist in pairs(currCompDist) do
        if math.min(compDist, prevCompDist[companion]) <= MAX_DISTANCE
            and not math.isclose(compDist, prevCompDist[companion], 0.001)
            and normalProx(compDist) > 0
        then
            npcTargetRate[companion] = calculateTargetRate(compDist)
            if (npcLightningTimers[companion] == nil or npcLightningTimers[companion].state == timer.expired) then
                npcLightningTimers[companion] = timer.start{
                    duration = math.max(1, 1 - utils.math.bellCurve(normalProx(compDist), (frequency - 1) * npcTargetRate[companion], 0, frequency) + (frequency - 1)),
                    callback = function ()
                        lightning.createLightningStrike(offsetPos(companion.position, normalProx(compDist)), true, (1 - utils.math.bellCurve(normalProx(currDist), 1, 0, frequency / 2)))
                        --- @type tes3spell
                        local me = tes3.getObject("lightning bolt")
                        me.effects[1].duration = 1
                        me.effects[1].min = damage
                        me.effects[1].max = damage
                        tes3.applyMagicSource{
                            reference = companion,
                            source = me
                        }
                    end
                }
            end
        end
    end

    e.timer.data.prevDist = currDist
    e.timer.data.prevCompDist = currCompDist
end
event.register(tes3.event.loaded, function()
    timer.start({
        iterations = -1,
        duration = 1 / 10,
        callback = update,
        data = { prevDist = 0, prevCompDist = {} },
    })
end)
