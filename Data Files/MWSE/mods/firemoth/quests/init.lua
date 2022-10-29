local quest = require("firemoth.quests.lib")

local diversion = dofile("firemoth.quests.diversion")

--[[
    Journal Events
--]]

event.register("firemoth:questReset", function()
    quest.setPersistentReferencesDisabled(true)
end)

event.register("firemoth:questAccepted", function()
    quest.setPersistentReferencesDisabled(false)
end)

event.register("firemoth:travelAccepted", function()
    tes3ui.leaveMenuMode()

    -- Disable skeleton spawning until NPCs are ready.
    tes3.player.data.fm_skeletonSpawnerDisabled = true

    -- Position player and companions beside the boat.
    tes3.positionCell({
        reference = tes3.player,
        position = { -56035.83, -72520.91, 14.56 },
        orientation = { 0.00, 0.00, -3.10 },
    })
    tes3.positionCell({
        reference = quest.npcs.hjrondir,
        position = { -55987.22, -72829.97, 30.80 },
        orientation = { 0.00, 0.00, -0.12 },
    })
    tes3.positionCell({
        reference = quest.npcs.aronil,
        position = { -56195.62, -72756.86, 12.85 },
        orientation = { 0.00, 0.00, 0.55 },
    })
    tes3.positionCell({
        reference = quest.npcs.mara,
        position = { -55812.18, -72776.85, 46.03 },
        orientation = { 0.00, 0.00, -0.50 },
    })
    tes3.positionCell({
        reference = quest.npcs.silmdar,
        position = { -55663.70, -72566.48, 64.11 },
        orientation = { 0.00, 0.00, -1.71 },
    })

    -- Disable greetings; we play custom sounds instead.
    quest.npcs.mara.mobile.hello = 0
    quest.npcs.aronil.mobile.hello = 0
    quest.npcs.hjrondir.mobile.hello = 0
    quest.npcs.silmdar.mobile.hello = 0

    timer.start({
        duration = 1.5,
        callback = function()
            tes3.say({ reference = quest.npcs.mara, soundPath = "vo\\w\\f\\Idl_WF006.mp3" })
        end,
    })

    timer.start({
        duration = 3.5,
        callback = function()
            tes3.say({ reference = quest.npcs.aronil, soundPath = "vo\\h\\m\\Hlo_HM060.mp3" })
        end,
    })

    timer.start({
        duration = 6.5,
        callback = function()
            tes3.say({ reference = quest.npcs.hjrondir, soundPath = "vo\\n\\m\\bIdl_NM013.mp3" })
        end,
    })

    diversion.start()
end)


event.register(tes3.event.activate, function(e)
    if e.activator ~= tes3.player then
        return
    elseif quest.backdoorEntered() then
        return
    end

    local destination = e.target.destination
    local cell = destination and destination.cell
    if cell and (cell.id == "Firemoth, Keep") then
        tes3.messageBox("Unusual magic seals this door. You'll have to find another way in.")
        return false
    end
end)
