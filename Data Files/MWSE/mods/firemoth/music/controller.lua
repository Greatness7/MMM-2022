local utils = require("firemoth.utils")

--- @type function
local isFiremothCell = utils.cells.isFiremothCell

--- @type string[]
local whitelistedTracks = {"fm\\Haunted-Castle.mp3"}

local waterLayer = { volume = 0 }
event.register("loaded", function()
    waterLayer.sound = assert(tes3.getSound("Water Layer"))
    waterLayer.prevVolume = waterLayer.sound.volume

    --- am unsure how to assert music file exists
    -- for _, track in ipairs(whitelistedTracks) do
    --     assert(exists)
    -- end
end)

--- @param e musicSelectTrackEventData
local function prioritiseFiremothMusic(e)
    if (table.find(whitelistedTracks, e.music) == false and e.situation == tes3.musicSituation.explore) then
        return false
    end
end

local function overrideWaterLayerVolume(e)
    local isFiremoth = isFiremothCell(e.cell)
    local wasFiremoth = e.previousCell and isFiremothCell(e.previousCell)

    if isFiremoth and not wasFiremoth then
        waterLayer.sound.volume = 0
        event.register(tes3.event.musicSelectTrack, prioritiseFiremothMusic, { priority = 360 })

        -- tes3.streamMusic{path = whitelistedTracks[1], situation = tes3.musicSituation.explore}
    elseif wasFiremoth and not isFiremoth then
        waterLayer.sound.volume = waterLayer.prevVolume
        event.unregister(tes3.event.musicSelectTrack, prioritiseFiremothMusic, { priority = 360 })
    end
end
event.register("cellChanged", overrideWaterLayerVolume)
