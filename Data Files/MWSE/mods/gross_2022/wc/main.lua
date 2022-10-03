local questVariables = require("gross_2022.vars")
local utils = require("gross_2022.utils")

--- @param e simulateEventData
local function simulateCallback(e)
    if (tes3.getJournalIndex{id = questVariables.fogControl.journalOn.condition} == questVariables.fogControl.journalOn.value) then
        local dist = tes3.player.position:distance(tes3.getReference(questVariables.fogControl.targetObject).position)
        tes3.worldController.weatherController.currentSkyColor = tes3.worldController.weatherController.currentSkyColor:lerp(questVariables.fogControl.weatherData.skyColour, utils.bellCurve(dist, 1, 0, 1024))
        tes3.worldController.weatherController.currentFogColor = tes3.worldController.weatherController.currentFogColor:lerp(questVariables.fogControl.weatherData.skyColour, utils.bellCurve(dist, 1, 0, 1024))
        tes3.worldController.weatherController:updateVisuals()
    end
end

--- @param e initializedEventData
local function initializedCallback(e)
    event.register(tes3.event.simulate, simulateCallback)
end
event.register(tes3.event.initialized, initializedCallback)
