local lightning = require("firemoth.weather.lightning")
local utils = require("firemoth.utils")

local MAX_DISTANCE = 8192 * 3

local DOWN = tes3vector3.new(0, 0, -1)
local XY = tes3vector3.new(1, 1, 0)

local STRIKE_DAMAGE = 20
local STRIKE_MAX_RANGE = 8192 * 0.6 -- test values for easier visibility

--- @return number
local function nearestAntiMarkerDistance(strikePos)
    ---@type number
    local closestMarkerDistance

    ---@param cell tes3cell
    for _, cell in ipairs(tes3.getActiveCells()) do
        ---@param reference tes3reference
        for reference in cell:iterateReferences(tes3.objectType.static) do
            if (reference.id == "fm_anti_strike") then
                if (closestMarkerDistance == nil or utils.math.xyDistance(reference.position, strikePos) < closestMarkerDistance) then
                    closestMarkerDistance = utils.math.xyDistance(reference.position, strikePos)
                end
            end
        end
    end

    return closestMarkerDistance
end

--- @return tes3vector3, boolean
local function getStrikePos()
    local x = STRIKE_MAX_RANGE * (math.random() * 2 - 1)
    local y = STRIKE_MAX_RANGE * (math.random() * 2 - 1)

    local offset = tes3vector3.new(x, y, 8192)
    local origin = utils.cells.FIREMOTH_REGION_ORIGIN + offset

    local rayhit = tes3.rayTest({ position = origin, direction = DOWN })
    local position = rayhit and rayhit.intersection:copy() or (origin * XY)

    local waterLevel = tes3.player.cell.waterLevel or 0
    position.z = math.max(position.z, waterLevel)

    return position, (position.z <= waterLevel)
end

---@param target tes3reference
---@param position tes3vector3|nil
local function applyDamage(target, position)
    target.mobile:applyDamage({
        damage = STRIKE_DAMAGE,
        resistAttribute = tes3.effectAttribute.resistShock,
    })
    tes3.createVisualEffect({
        position = position or target.position,
        object = "VFX_LightningArea",
        lifespan = 1.0,
    })
end

local lastStrikeTime = os.clock()
local function update()
    if tes3.player.cell.isInterior then
        return
    end

    local distance = utils.cells.getFiremothDistance()
    if distance > MAX_DISTANCE then
        return
    end

    --- Ticks 4 times per second.
    --- Forces at least one strike per 2.35 seconds.
    --- Strikes must be at least 1.35 seconds apart.
    --- Each tick has 5% chance of making a strikes.
    local dt = os.clock() - lastStrikeTime
    if dt < 2.35 then
        if dt <= 1.35 then -- last strike too recent
            return
        elseif math.random() > 0.05 then -- rng skip
            return
        end
    end
    lastStrikeTime = os.clock()

    local strikePos, isWaterStrike = getStrikePos()
    local strikeAoE = isWaterStrike and 3072 or 1024

    local antiStrikePos = nearestAntiMarkerDistance(strikePos)

    if (antiStrikePos ~= nil and antiStrikePos <= 512) then
        return
    end

    -- target companions first
    for _, companion in ipairs(utils.cells.getNearbyCompanions()) do
        if utils.math.xyDistance(strikePos, companion.position) <= strikeAoE then
            strikePos = companion.position
            applyDamage(companion)
        end
    end

    -- prefer targeting the player if they're closer
    local eyepos = tes3.getPlayerEyePosition()
    local strikeDist = utils.math.xyDistance(strikePos, eyepos)
    if strikeDist <= strikeAoE then
        local eyevec = tes3.getPlayerEyeVector()
        strikePos = (eyepos + eyevec * 512) * XY
        applyDamage(tes3.player, eyepos + eyevec * 128)
    end

    --- TODO: move strength calculating into `createLightningStrike`
    local shakeStrength = math.remap(math.min(strikeDist, MAX_DISTANCE), 0, MAX_DISTANCE, 0.3, 0)
    lightning.createLightningStrike(strikePos, shakeStrength)

    -- tes3.messageBox("distance: %.2f | shake: %.2f", strikeDist, shakeStrength)
end

event.register(tes3.event.loaded, function()
    timer.start({
        iterations = -1,
        duration = 0.25,
        callback = update,
    })
end)
