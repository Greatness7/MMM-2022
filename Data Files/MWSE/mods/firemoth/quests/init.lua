local quest = require("firemoth.quests.lib")

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
end)
