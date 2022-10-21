local fog = require("firemoth.weather.fog")
local utils = require("firemoth.utils")

local MAX_DISTANCE = 8192 * 3

---@type mgeShaderHandle
local fogShader = nil

local function loadFog()
    ---@type fogParams
    local fogParams = {
        colors = { 0.07, 0.32, 0.35 },
        centers = {
            utils.cells.FIREMOTH_REGION_ORIGIN.r,
            utils.cells.FIREMOTH_REGION_ORIGIN.g,
            utils.cells.FIREMOTH_REGION_ORIGIN.b
        },
        radi = { MAX_DISTANCE, MAX_DISTANCE, 128 },
        densities = { 10 }
    }
    fogShader = fog.createFog(fogParams)
end

event.register(tes3.event.loaded, loadFog)
