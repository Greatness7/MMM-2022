local lightning = require("firemoth.weather.lightning")
local utils = require("firemoth.utils")

local MIN_DISTANCE = 8192 * 0.25
local MAX_DISTANCE = 8192 * 3

--- @type mwseTimer
local lightningTimer = nil
local dissipationRate = 3
local damage = 5
local frequency = 5

--- @type table<tes3reference, number>
local npcTargetRate = {}
local playerTargetRate = 0

--- @param pos tes3vector3
--- @param f number
--- @return tes3vector3
local function offsetPos(pos, f)
    local rot = tes3matrix33.new()
    rot:fromEulerXYZ(0, 0, math.random(-180, 180))
    return tes3vector3.new(pos.x, pos.y, 0) + rot:transpose().y * (MAX_DISTANCE - math.lerp(MIN_DISTANCE, MAX_DISTANCE, f))
end

local function normalProx(dist)
    local f = math.clamp(dist, MIN_DISTANCE, MAX_DISTANCE)
    f = math.remap(f, MIN_DISTANCE, MAX_DISTANCE, 1.0, 0.0)

    return f
end

local function applyDamage(target)
    --- @type tes3effect
    tes3.applyMagicSource{
        reference = target,
        effects = {
            { id = tes3.effect.shockDamage, duration = dissipationRate, min = damage, max = damage }
        }
    }
end

local function update(e)
    if tes3.player.cell.isInterior then
        npcTargetRate = {}
        return
    end

    local currDist = utils.cells.getFiremothDistance()
    local prevDist = e.timer.data.prevDist or currDist
    
    if math.min(currDist, prevDist) <= MAX_DISTANCE
        and not math.isclose(currDist, prevDist, 0.001)
        and normalProx(currDist) > 0
    then
        lightningTimer = timer.start{
            duration = math.random(1, frequency),
            callback = function ()
                local strikePos = offsetPos(utils.cells.FIREMOTH_REGION_ORIGIN, math.random())
                
                -- target companions first
                for _, companion in ipairs(utils.cells.getNearbyCompanions()) do
                    if ((companion.position.z <= 0 and utils.math.xyDistance(strikePos, companion.position) < 1024) or utils.math.xyDistance(strikePos, companion.position) < 256) then
                        strikePos = companion.position
                        applyDamage(companion)
                    end
                end
                -- prefer targeting the player if they're closer 
                if ((tes3.player.position.z <= 0 and utils.math.xyDistance(strikePos, tes3.player.position) < 1024) or utils.math.xyDistance(strikePos, tes3.player.position) < 256) then
                    strikePos = tes3.player.position
                    applyDamage(tes3.player)
                end
                lightning.createLightningStrike(strikePos, true, (1 - utils.math.bellCurve(normalProx(currDist), 1, 0, frequency / 2)))
            end
        }
    end

    e.timer.data.prevDist = currDist
end
event.register(tes3.event.loaded, function()
    timer.start({
        iterations = -1,
        duration = 0.25,
        callback = update,
        data = { prevDist = 0 },
    })
end)
