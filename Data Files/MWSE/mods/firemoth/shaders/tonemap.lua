local utils = require("firemoth.utils")

local MIN_DISTANCE = 8192 * 0.25
local MAX_DISTANCE = 8192 * 3.5

local shader = assert(mge.shaders.load({ name = "fm_tonemap" }))
shader.fogColor = tes3vector3.new(0.5, 0.0, 0.35)
shader.enabled = false

local exposure = -0.050
local saturation = -0.100
local defog = 0.1

local function toggleShader(enabled)
    if shader.enabled ~= enabled then
        shader.enabled = enabled
    end
end

local function updateColors(dist)
    local f = math.clamp(dist, MIN_DISTANCE, MAX_DISTANCE)
    f = math.remap(f, MIN_DISTANCE, MAX_DISTANCE, 1.0, 0.0)
    -- tes3.messageBox("tonemap: %s", f)
    shader.exposure = exposure * f
    shader.saturation = saturation * f
    shader.defog = defog * f
end

local function update(e)
    if tes3.player.cell.isInterior then
        toggleShader(false)
        return
    end

    local currDist = utils.cells.getFiremothDistance()
    local prevDist = e.timer.data.prevDist or currDist

    -- are we within the trigger distance
    -- and has the distance been modified
    if math.min(currDist, prevDist) <= MAX_DISTANCE
        and not math.isclose(currDist, prevDist, 0.001)
    then
        toggleShader(currDist <= MAX_DISTANCE)
        updateColors(currDist)
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
