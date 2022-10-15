local camera = require("firemoth.weather.camera")
local utils = require("firemoth.utils")

local this = {}

local VFX_EXPLODE = assert(tes3.getObject("fm_lightn_expl_vfx")) ---@cast VFX_EXPLODE tes3static
local VFX_EXPLODE_DURATION = 0.20

local VFX_EXPLODE_LIGHT = assert(tes3.getObject("fm_lightn_expl_lit")) ---@cast VFX_EXPLODE_LIGHT tes3light
local VFX_CHILDREN_COUNT = 4

local VFX_STRIKE = assert(tes3.getObject("fm_lightn_strike_vfx")) ---@cast VFX_STRIKE tes3static
local VFX_STRIKE_DURATION = 0.15

local UP = tes3vector3.new(0, 0, 1)
local SIMULATION_TIME = require("ffi").cast("float*", 0x7C6708)

function this.createLightningFlash()
    local weather = tes3.getCurrentWeather()
    if weather and weather.index == tes3.weather.thunder then
        local f = weather.thunderFrequency
        weather.thunderFrequency = 1e+6
        timer.delayOneFrame(function()
            weather.thunderFrequency = f
            weather.thunderSound1:stop()
            weather.thunderSound2:stop()
            weather.thunderSound3:stop()
            weather.thunderSound4:stop()
        end)
    end
end

---@param position tes3vector3
function this.createExplosionVFX(position)
    local direction = utils.math.getRandomRotation(70, 70, 360) * UP

    local rayhit = tes3.rayTest({
        position = position,
        direction = direction,
        maxDistance = 1024,
        root = tes3.game.worldObjectRoot,
    })

    local distance = rayhit and rayhit.distance
    local intersection = rayhit and rayhit.intersection

    -- if we didn't hit any object, use some randomized intersection
    if not (distance and intersection) then
        distance = math.random(256, 1024)
        intersection = position + direction * distance
    end

    -- center point of the lightning, bias this upwards so we curve
    local curveCenter = position + direction * (distance / 3)
    local curveUpward = curveCenter + UP * (distance / 6)

    local vfx = tes3.createVisualEffect({
        object = VFX_EXPLODE,
        lifespan = VFX_EXPLODE_DURATION,
        position = position,
    })
    local sceneNode = vfx.effectNode
    sceneNode.scale = math.random() + 2

    -- controls the lightning strikes "grow" animation
    local anim = sceneNode:getObjectByName("Animation")
    anim.scale = distance

    -- controls the mid point of the lightning strike
    local bone2 = sceneNode:getObjectByName("2") ---@cast bone2 niNode
    utils.math.setWorldTranslation(bone2, curveUpward)

    -- controls the end point of the lightning strike
    local bone3 = sceneNode:getObjectByName("3") ---@cast bone3 niNode
    utils.math.setWorldTranslation(bone3, intersection)

    -- controls which lightning texture is used
    local switch = sceneNode:getObjectByName("LightningSwitch")
    switch.switchIndex = math.random(0, VFX_CHILDREN_COUNT - 1)

    -- ensure controllers start from beginning
    local phase = -SIMULATION_TIME[0]
    anim.children[1].controller.phase = phase
end

---@param position tes3vector3
function this.createLightningSound(position)
    local clip = 8192 * 2
    local dist = tes3.getPlayerEyePosition():distance(position)
    local volume = math.remap(math.min(dist, clip), 0, clip, 0.8, 0)

    tes3.playSound({
        sound = "tew_fm_thunder" .. math.random(1, 6),
        reference = tes3.player,
        volume = volume,
        mixChannel = tes3.soundMix.master,
    })
end

---@param position tes3vector3
function this.createLightningLight(position)
    for _, cell in tes3.getActiveCells() do
        if cell:isPointInCell(position.x, position.y) then
            local modified = cell.modified
            local light = tes3.createReference({ object = VFX_EXPLODE_LIGHT, position = position, cell = cell })
            light.modified = false
            cell.modified = modified
            return light
        end
    end
end

---@param position tes3vector3
function this.createLightningExplosion(position)
    -- avoid intersections inside mesh geometry
    position = position + UP * 32

    -- spawn multiple vfx objects
    for _ = 1, math.random(3, 12) do
        this.createExplosionVFX(position)
    end
end

---@param position tes3vector3
---@param explode boolean
function this.createLightningStrike(position, explode, strength)
    local vfx = tes3.createVisualEffect({
        object = VFX_STRIKE,
        lifespan = VFX_STRIKE_DURATION + VFX_EXPLODE_DURATION,
        position = position,
    })
    local sceneNode = vfx.effectNode

    -- controls which lightning texture is used
    local switch = sceneNode:getObjectByName("LightningSwitch")
    local randIndex = math.random(1, VFX_CHILDREN_COUNT)
    local nextIndex = randIndex % VFX_CHILDREN_COUNT + 1

    local s1 = switch.children[randIndex]
    local s2 = switch.children[nextIndex]

    local c1 = switch.controller
    local c2 = c1.nextController
    local c3 = c2.nextController
    local c4 = c3.nextController

    local phase = -SIMULATION_TIME[0]

    c1:setTarget(s1)
    c1.phase = phase
    c1.active = true

    c2:setTarget(s2)
    c2.phase = phase
    c2.active = true

    c3:setTarget(s1)
    c3.phase = phase
    c3.active = true

    c4:setTarget(s2)
    c4.phase = phase
    c4.active = true

    if explode then
        timer.start({
            duration = VFX_STRIKE_DURATION,
            iterations = 1,
            callback = function()
                this.createLightningExplosion(position)
                this.createLightningSound(position)
                this.createLightningLight(position)
                this.createLightningFlash()
                camera.startCameraShake(--[[duration]] 5, --[[strength]] strength or 1.0)
            end,
        })
    end
end

return this
