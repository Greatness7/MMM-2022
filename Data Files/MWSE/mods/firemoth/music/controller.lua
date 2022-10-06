local utils = require("firemoth.utils")

--- @type function
local isFiremothCell = utils.cells.isFiremothCell

local waterLayer = { volume = 0 }
event.register("loaded", function()
    waterLayer.sound = assert(tes3.getSound("Water Layer"))
    waterLayer.prevVolume = waterLayer.sound.volume
end)

local function overrideWaterLayerVolume(e)
    local isFiremoth = isFiremothCell(e.cell)
    local wasFiremoth = e.previousCell and isFiremothCell(e.previousCell)

    if isFiremoth and not wasFiremoth then
        waterLayer.sound.volume = 0
    elseif wasFiremoth and not isFiremoth then
        waterLayer.sound.volume = waterLayer.prevVolume
    end
end
event.register("cellChanged", overrideWaterLayerVolume)
