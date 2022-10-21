local fog = require("firemoth.weather.fog")
local utils = require("firemoth.utils")

local MAX_DISTANCE = 8192 * 3

local fogId = "Firemoth Exterior"

---@type fogParams
local fogParams = {
    color = tes3vector3.new(0.07, 0.32, 0.35),
    center = utils.cells.FIREMOTH_REGION_ORIGIN,
    radius = tes3vector3.new(MAX_DISTANCE, MAX_DISTANCE, 128),
    density = 15,
}

local function update(e)
    if tes3.player.cell.isInterior then
        return
    end

    local currDist = utils.cells.getFiremothDistance()
    local prevDist = e.timer.data.prevDist or currDist

    if math.min(currDist, prevDist) <= MAX_DISTANCE
        and not math.isclose(currDist, prevDist, 0.001)
    then
        fogParams.density = utils.math.bellCurve(currDist, 15, 0, MAX_DISTANCE)
        fog.updateFog(fogId, fogParams)
    end

    e.timer.data.prevDist = currDist
end

--- @param e cellChangedEventData
local function cellChangedCallback(e)
    if e.cell.isInterior then
        fog.deleteFog(fogId)
    else
        -- ?
    end
end
event.register(tes3.event.cellChanged, cellChangedCallback)

local function loadFog()
    fog.updateFog(fogId, fogParams)

    if tes3.player.cell.isInterior then
        fog.deleteFog(fogId)
    end

    timer.start({ iterations = -1, duration = 1 / 10, callback = update, data = {} })
end
event.register(tes3.event.loaded, loadFog)
