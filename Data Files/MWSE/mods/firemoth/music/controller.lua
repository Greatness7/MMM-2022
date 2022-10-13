local utils = require("firemoth.utils")
local MUSICDIR = "Data Files\\Music\\fm\\"
local SILENCE = "fm\\Special\\silence.mp3"
local previousCell

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
    local cell = tes3.getPlayerCell()
    if (isFiremothCell(cell) and e.situation == tes3.musicSituation.explore and not table.find(whitelistedTracks, e.music)) then
        tes3.streamMusic{path = table.choice(whitelistedTracks), situation = tes3.musicSituation.explore}
        return false
    end
end

local function onCombatStopped()
    if tes3.player.mobile.inCombat then return end -- Because MW can be really dumb with that one
    local cell = tes3.getPlayerCell()
    local isFiremoth = isFiremothCell(cell)
    if isFiremoth then
        tes3.streamMusic{path = table.choice(whitelistedTracks), situation = tes3.musicSituation.explore}
    end
end

--- @param e cellChangedEventData
local function firemothConditionCheck(e)
    local cell = tes3.getPlayerCell()
    local isFiremoth = isFiremothCell(cell)
    local wasFiremoth = previousCell and isFiremothCell(previousCell)

    if isFiremoth and not wasFiremoth then
        waterLayer.sound.volume = 0
        tes3.streamMusic{path = table.choice(whitelistedTracks), situation = tes3.musicSituation.explore}
    elseif wasFiremoth and not isFiremoth then
        waterLayer.sound.volume = waterLayer.prevVolume
        tes3.streamMusic{path = SILENCE, situation = tes3.musicSituation.explore}
    end
    previousCell = cell
end

local function populateTracks()
    for track in lfs.dir(MUSICDIR) do
		if (track ~= ".." and track ~= "." and track ~= "Special") and (string.endswith(track, ".mp3")) then
            table.insert(whitelistedTracks, #whitelistedTracks+1, "fm\\" .. track)
        end
    end
    assert(whitelistedTracks, "Missing music files!")
end

local function resetOnLoad()
    previousCell = nil
end

populateTracks()
event.register(tes3.event.musicSelectTrack, prioritiseFiremothMusic, { priority = 360 })
event.register(tes3.event.cellChanged, firemothConditionCheck)
event.register(tes3.event.combatStopped, onCombatStopped)
event.register(tes3.event.load, resetOnLoad)
