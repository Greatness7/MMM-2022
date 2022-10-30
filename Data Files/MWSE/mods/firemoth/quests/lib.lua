local this = {}

local quest = assert(tes3.dataHandler.nonDynamicData:findDialogue("fm_2022"))

--[[
    Quest Events
--]]

local events = {
    [200] = "firemoth:questAccepted",
    [300] = "firemoth:travelAccepted",
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
        this.setPersistentReferencesDisabled(true)
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

function this.companionReferences()
    return coroutine.wrap(function()
        coroutine.yield(this.npcs.mara)
        coroutine.yield(this.npcs.aronil)
        coroutine.yield(this.npcs.hjrondir)
    end)
end


function this.travelFinished()
    return quest.journalIndex >= 300
end

function this.backdoorEntered()
    return quest.journalIndex >= 400
end

function this.companionsRecalled()
    return quest.journalIndex >= 450
end

function this.undeadHjrondir()
    return quest.journalIndex >= 475
end


function this.setFightingStarted()
    tes3.updateJournal({ id = quest.id, index = 350, showMessage = true })
end

function this.setBackdoorEntered()
    tes3.updateJournal({ id = quest.id, index = 400, showMessage = true })
end

function this.setCompanionsRecalled()
    tes3.updateJournal({ id = quest.id, index = 450, showMessage = true })
end


local function recallCompanions(e)
    for _, ref in pairs({ this.npcs.mara, this.npcs.aronil }) do
        if ref.cell ~= tes3.player.cell then
            tes3.positionCell({
                reference = ref,
                position = tes3.player.position,
                cell = tes3.player.cell,
                forceCellChange = true,
            })
            return
        end
        if ref.mobile.aiPlanner:getActivePackage() == nil then
            tes3.messageBox("setAIFollow({ reference=%s, target=%s)", ref, tes3.player)
            tes3.setAIFollow({ reference = ref, target = tes3.player })
            return
        end
    end

    tes3.removeItem({ reference = tes3.player, item = "fm_sc_recall" })

    e.timer:cancel()
end
timer.register("firemoth:recallCompanions", recallCompanions)


return this
