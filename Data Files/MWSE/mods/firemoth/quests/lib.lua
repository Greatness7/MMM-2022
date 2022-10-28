local this = {
    id = "fm_2022",
}

local quest = assert(tes3.dataHandler.nonDynamicData:findDialogue(this.id))

--[[
    Quest Events
--]]

local events = {
    [-1] = "firemoth:questReset",
    [200] = "firemoth:questAccepted",
    [250] = "firemoth:beginTraveling",
}

---@param e journalEventData
local function onJournalUpdated(e)
    if (e.topic.id == quest.id) and events[e.index] then
        event.trigger(events[e.index])
    end
end
event.register(tes3.event.journal, onJournalUpdated)

--[[
    Quest Persistent References
--]]

---@type table<string, tes3reference>
this.npcs = {} -- set in loaded event

---@type table<string, tes3reference>
this.clutter = {} -- set in loaded event

local function onLoaded()
    this.npcs.mara = assert(tes3.getReference("fm_mara"))
    this.npcs.aronil = assert(tes3.getReference("fm_aronil"))
    this.npcs.hjrondir = assert(tes3.getReference("fm_hjrondir"))
    -- this.npcs.jhanir = assert(tes3.getReference("fm_jhanir"))
    this.npcs.silmdar = assert(tes3.getReference("fm_silmdar"))
    this.clutter.seydaBoat = assert(tes3.getReference("fm_seyda_boat"))
    this.clutter.mudcrabDead = assert(tes3.getReference("fm_mudcrab_dead"))

    if quest.journalIndex < 200 then
        event.trigger("firemoth:QuestReset")
    end
end
event.register(tes3.event.loaded, onLoaded, { priority = 7000 })

--[[
    Utility Functions
--]]

local function setDisabled(ref, disabled)
    if disabled and not ref.disabled then
        ref:disable()
    elseif ref.disabled and not disabled then
        ref:enable()
    end
end

function this.setPersistentReferencesDisabled(disabled)
    for _, ref in pairs(this.npcs) do
        setDisabled(ref, disabled)
    end
    for _, ref in pairs(this.clutter) do
        setDisabled(ref, disabled)
    end
end

return this
