local quest = require("firemoth.quests.lib")

event.register("firemoth:questReset", function()
    quest.setPersistentReferencesDisabled(true)
end)

event.register("firemoth:questAccepted", function()
    quest.setPersistentReferencesDisabled(false)
end)

event.register("firemoth:beginTraveling", function()
    tes3ui.leaveMenuMode()

    local darkHour = 12 + 9 -- 9pm
    local hour = tes3.worldController.hour.value
    if hour > darkHour then hour = hour + 24 end
    tes3.advanceTime({ hours = darkHour - hour })

    tes3.positionCell({
        reference = tes3.player,
        position = { -56000, -72700, 32 },
        orientation = { 0, 0, math.rad(-150) },
    })
end)
