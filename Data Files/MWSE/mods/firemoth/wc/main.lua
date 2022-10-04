local questVariables = require("firemoth.vars")
local utils = require("firemoth.utils")

local properties = {
    "skySunriseColor",
    "skyDayColor",
    "skySunsetColor",
    "skyNightColor",
    "fogSunriseColor",
    "fogDayColor",
    "fogSunsetColor",
    "fogNightColor",
    "ambientSunriseColor",
    "ambientDayColor",
    "ambientSunsetColor",
    "ambientNightColor",
    "sunSunriseColor",
    "sunDayColor",
    "sunSunsetColor",
    "sunNightColor",
    "sundiscSunsetColor",
}

local localWeather = {}
local weatherFlip = false

local function updateColours(k)
    local weathCon = tes3.worldController.weatherController
    for _, name in pairs(properties) do
        local newCol = localWeather[name]:lerp(questVariables.skyControl.weatherData.airColour, utils.bellCurve(k, 1, 0, questVariables.skyControl.triggerDistance))
        weathCon.currentWeather[name].r = newCol.r
        weathCon.currentWeather[name].g = newCol.g
        weathCon.currentWeather[name].b = newCol.b
    end
    tes3.worldController.weatherController:updateVisuals()
end

--- @param e simulateEventData
local function simulateCallback(e)
    -- Confirm local weather has been gathered.
    if (localWeather) then
        -- Confirm toggle condition and outside...
        if (tes3.getJournalIndex { id = questVariables.skyControl.journalOn.condition } == questVariables.skyControl.journalOn.value and tes3.getPlayerCell().isInterior == false) then
            local dist = tes3.player.position:distance(questVariables.skyControl.targetPosition)
            updateColours(dist)
            debug.log(dist)
            if (weatherFlip == false) then
                weatherFlip = true
            end
        -- ...or in fort.
        elseif (tes3.getPlayerCell().name == questVariables.skyControl.cellOn) then
            updateColours(0)
            if (weatherFlip == false) then
                weatherFlip = true
            end
        -- Reset weather otherwise.
        elseif (weatherFlip == true) then
            local weathCon = tes3.worldController.weatherController
            for _, name in pairs (properties) do
                weathCon.currentWeather[name].r = localWeather[name].r
                weathCon.currentWeather[name].g = localWeather[name].g
                weathCon.currentWeather[name].b = localWeather[name].b
            end
            weatherFlip = false
        end
    end
end

--- @param e cellChangedEventData
local function cellChangedCallback(e)
    if (e.cell.isInterior == false) then
        for _, name in pairs(properties) do
            localWeather[name] = e.cell.region.weather[name]:copy()
        end
    end
end

--- @param e initializedEventData
local function initializedCallback(e)
    event.register(tes3.event.simulate, simulateCallback)
    event.register(tes3.event.cellChanged, cellChangedCallback)
end

event.register(tes3.event.initialized, initializedCallback)
