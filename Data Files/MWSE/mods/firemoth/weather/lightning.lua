local this = {}

local VFX_EXPLODE = assert(tes3.getObject("fm_lightn_expl_vfx"))
local VFX_EXPLODE_DURATION = 0.20

local VFX_EXPLODE_LIGHT = assert(tes3.getObject("fm_lightn_expl_lit"))

local VFX_STRIKE = assert(tes3.getObject("fm_lightn_strike_vfx"))
local VFX_STRIKE_DURATION = 0.18

local VFX_SWITCH_CHILDREN = 4

local SIMULATION_TIME = require("ffi").cast("float*", 0x7C6708)

local UP = tes3vector3.new(0, 0, 1)

local function getRandomRotation(rangeX, rangeY, rangeZ)
    local x = math.rad(math.random(-rangeX, rangeX))
    local y = math.rad(math.random(-rangeY, rangeY))
    local z = math.rad(math.random(-rangeZ, rangeZ))
    local r = tes3matrix33.new()
    r:fromEulerXYZ(x, y, z)
    return r
end

local function setWorldTranslation(node, translation)
    if node.parent then
        local t = node.parent.worldTransform
        translation = (t.rotation * t.scale):transpose() * (translation - t.translation)
    end
    node.translation = translation
end

function this.createExplosionVFX(position)
    local direction = getRandomRotation(70, 70, 360) * UP

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
        intersection = position + direction * distance ---@diagnostic disable-line: cast-local-type
    end

    -- center point of the lightning, bias this upwards so we curve
    local curveCenter = position + direction * (distance / 3)
    local curveUpward = curveCenter + UP * (distance / 6)

    local vfx = tes3.createVisualEffect({
        object = VFX_EXPLODE, ---@diagnostic disable-line: assign-type-mismatch
        lifespan = VFX_EXPLODE_DURATION,
        position = position,
    })
    local sceneNode = vfx.effectNode
    sceneNode.scale = math.random() + 2

    -- controls the lightning strikes "grow" animation
    local anim = sceneNode:getObjectByName("Animation")
    anim.scale = distance

    -- controls the mid point of the lightning strike
    local bone2 = sceneNode:getObjectByName("2")
    setWorldTranslation(bone2, curveUpward)

    -- controls the end point of the lightning strike
    local bone3 = sceneNode:getObjectByName("3")
    setWorldTranslation(bone3, intersection)

    -- controls which lightning texture is used
    local switch = sceneNode:getObjectByName("LightningSwitch")
    switch.switchIndex = math.random(0, VFX_SWITCH_CHILDREN - 1)

    -- ensure controllers start from beginning
    local phase = -SIMULATION_TIME[0]
    anim.children[1].controller.phase = phase
end

function this.createLightningSound(position)
    local clip = 8192 * 2
    local dist = tes3.getPlayerEyePosition():distance(position)
    local volume = math.remap(math.min(dist, clip), 0, clip, 1, 0)

    tes3.playSound({
        sound = "AB_Thunderclap" .. math.random(0, 4),
        reference = tes3.player,
        volume = volume,
    })
end

function this.createLightningLight(position)
    local light = tes3.createReference({
        object = VFX_EXPLODE_LIGHT, ---@diagnostic disable-line: assign-type-mismatch
        position = position,
        cell = tes3.player.cell,
    })
    light.modified = false
end

function this.createLightningExplosion(position)
    -- avoid intersections inside mesh geometry
    position = position + UP * 32

    -- spawn multiple vfx objects
    for _ = 1, math.random(3, 12) do
        this.createExplosionVFX(position)
    end
end

function this.createLightningStrike(position, explode)
    local vfx = tes3.createVisualEffect({
        object = VFX_STRIKE, ---@diagnostic disable-line: assign-type-mismatch
        lifespan = VFX_STRIKE_DURATION + VFX_EXPLODE_DURATION,
        position = position,
    })
    local sceneNode = vfx.effectNode

    -- controls which lightning texture is used
    local switch = sceneNode:getObjectByName("LightningSwitch")
    switch.switchIndex = math.random(0, VFX_SWITCH_CHILDREN - 1)

    -- ensure controllers start from beginning
    local shape = switch:getActiveChild()
    local phase = -SIMULATION_TIME[0]
    shape.controller.phase = phase

    if explode then
        timer.start({
            duration = VFX_STRIKE_DURATION,
            iterations = 1,
            callback = function()
                this.createLightningExplosion(position)
                this.createLightningSound(position)
                this.createLightningLight(position)
            end,
        })
    end
end

return this
