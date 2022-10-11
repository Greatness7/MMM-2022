local utils = require("firemoth.utils")
local MUSICDIR = "Data Files\\Music\\fm\\"
local SILENCE = "fm\\Special\\silence.mp3"
local registered

--- @type function
local isFiremothCell = utils.cells.isFiremothCell

--- @type string[]
local whitelistedTracks = {}

local waterLayer = { volume = 0 }
event.register("loaded", function()
    waterLayer.sound = assert(tes3.getSound("Water Layer"))
    waterLayer.prevVolume = waterLayer.sound.volume
end)

--- @param e musicSelectTrackEventData
local function prioritiseFiremothMusic(e)
    if (e.situation == tes3.musicSituation.explore and not table.find(whitelistedTracks, e.music)) then
        tes3.streamMusic{path = table.choice(whitelistedTracks), situation = tes3.musicSituation.explore}
        return false
    end
end

local function firemothConditionCheck(e)
    local cell = e.cell or tes3.getPlayerCell()
    local isFiremoth = isFiremothCell(cell)
    local wasFiremoth = e.previousCell and isFiremothCell(e.previousCell)

    if isFiremoth and not wasFiremoth then
        waterLayer.sound.volume = 0
        if not registered then
            event.register(tes3.event.musicSelectTrack, prioritiseFiremothMusic, { priority = 360 })
            event.register(tes3.event.combatStopped, firemothConditionCheck, { priority = 360 })
            registered = true
        end

        tes3.streamMusic{path = table.choice(whitelistedTracks), situation = tes3.musicSituation.explore}
    elseif wasFiremoth and not isFiremoth then
        waterLayer.sound.volume = waterLayer.prevVolume
        if registered then
            event.unregister(tes3.event.musicSelectTrack, prioritiseFiremothMusic, { priority = 360 })
            event.unregister(tes3.event.combatStopped, firemothConditionCheck, { priority = 360 })
            registered = false
        end

        tes3.streamMusic{path = SILENCE, situation = tes3.musicSituation.explore}
    end
end

local function populateTracks()
    for track in lfs.dir(MUSICDIR) do
		if track ~= ".." and track ~= "." and track ~= "Special" then
            table.insert(whitelistedTracks, #whitelistedTracks+1, "fm\\" .. track)
        end
    end
    assert(whitelistedTracks, "Missing music files!")
end

populateTracks()
event.register("cellChanged", firemothConditionCheck)
