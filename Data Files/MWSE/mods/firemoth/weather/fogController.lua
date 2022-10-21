local fog = require("firemoth.weather.fog")
local utils = require("firemoth.utils")

local MAX_DISTANCE = 8192 * 3

---@type mgeShaderHandle
local fogShader = nil

local function update(e)
    if tes3.player.cell.isInterior or fogShader == nil then
        return
    end

    local currDist = utils.cells.getFiremothDistance()
    local prevDist = e.timer.data.prevDist or currDist

    debug.log(utils.math.bellCurve(currDist, 15, 0, MAX_DISTANCE))

    if math.min(currDist, prevDist) <= MAX_DISTANCE
        and not math.isclose(currDist, prevDist, 0.001)
    then
        fogShader.fogDensities[1] = utils.math.bellCurve(currDist, 15, 0, MAX_DISTANCE)
    end

    e.timer.data.prevDist = currDist
end

--- @param e cellChangedEventData
local function cellChangedCallback(e)
    if (fogShader) then
        if (e.cell.isInterior) then
            fogShader.enabled = false
        else
            fogShader.enabled = true
        end
    end
end

local function loadFog()
    ---@type fogParams
    local fogParams = {
        colors = {
            0.07, 0.32, 0.35,
            0.0, 0.0, 0.0
        },
        centers = {
            utils.cells.FIREMOTH_REGION_ORIGIN.x, utils.cells.FIREMOTH_REGION_ORIGIN.y, utils.cells.FIREMOTH_REGION_ORIGIN.z,
            0.0, 0.0, 0.0
        },
        radi = {
            MAX_DISTANCE, MAX_DISTANCE, 128,
            0.0, 0.0, 0.0
        },
        densities = {
            15,
            0
        }
    }
    fogShader = fog.createFog(fogParams)

    if (tes3.getPlayerCell().isInterior) then
        fogShader.enabled = false
    end

    timer.start({ iterations = -1, duration = 1 / 10, callback = update, data = {} })
end

event.register(tes3.event.cellChanged, cellChangedCallback)
event.register(tes3.event.loaded, loadFog)
