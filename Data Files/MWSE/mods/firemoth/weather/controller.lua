--[[
    Controls how weather updates as you approach or leave Firemoth.
--]]

local utils = require("firemoth.utils")

--- Distance at which the controller is triggered
--- If player is beyond this distance nothing happens.
local TRIGGER_DISTANCE = 5 * 8192

--- The final color that we transition toward.
--- We interpolate from the weathers base color to this color, based on distance.
local FIREMOTH_COLOR = tes3vector3.new(0.0, 1.0, 0.0) --- TODO: pick nicer value

--- The color properties that will be modified.
local MODIFIED_COLOR_PROPS = {
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

--- @alias WeatherIndex number
--- @alias WeatherColors table<string, tes3vector3>
--- @alias WeatherColorsCache table<WeatherIndex, WeatherColors>
--- @type WeatherColorsCache
local WEATHER_COLORS_CACHE = {}


--- @return WeatherColorsCache
local function getCachedWeatherColors()
    local weather = tes3.getCurrentWeather()

    --- @type WeatherColorsCache
    local cache = WEATHER_COLORS_CACHE

    -- store current colors so they can be restored when leaving Firemoth
    if not cache[weather.index] then
        local colors = {}
        for _, prop in ipairs(MODIFIED_COLOR_PROPS) do
            colors[prop] = weather[prop]
        end
        cache[weather.index] = colors
    end

    return cache
end

--- @param weather tes3weather
--- @param colors WeatherColors
local function resetWeatherColors(weather, colors)
    for _, prop in ipairs(MODIFIED_COLOR_PROPS) do
        local color = colors[prop]
        weather[prop].r = color.r
        weather[prop].g = color.g
        weather[prop].b = color.b
    end
end

--- @param weather tes3weather
--- @param colors WeatherColors
--- @param scalar number
local function interpWeatherColors(weather, colors, scalar)
    for _, prop in ipairs(MODIFIED_COLOR_PROPS) do
        local color = colors[prop]:lerp(FIREMOTH_COLOR, scalar)
        weather[prop].r = color.r
        weather[prop].g = color.g
        weather[prop].b = color.b
    end
end

--- @param distance number
local function updateWeatherColors(distance)
    local curve = utils.math.bellCurve(distance, 1, 0, TRIGGER_DISTANCE)

    local wc = tes3.worldController.weatherController
    local currentIndex = wc.currentWeather.index
    local weathers = wc.weathers

    local cache = getCachedWeatherColors()

    for index, colors in pairs(cache) do
        local weather = weathers[index]
        if index == currentIndex then
            interpWeatherColors(weather, colors, curve)
        else
            resetWeatherColors(weather, colors)
            cache[index] = nil
        end
    end

    wc:updateVisuals()
end

local function update(e)
    -- TODO: we probably want some static color overrides in interiors.
    if tes3.player.cell.isInterior then
        return
    end

    local currDist = utils.cells.getFiremothDistance()
    local prevDist = e.timer.data.prevDist or currDist

    -- are we within the trigger distance
    -- and has the distance been modified
    if math.min(currDist, prevDist) <= TRIGGER_DISTANCE
        and not math.isclose(currDist, prevDist, 0.001)
    then
        updateWeatherColors(currDist)
    end

    e.timer.data.prevDist = currDist
end
event.register(tes3.event.loaded, function()
    timer.start({ iterations = -1, duration = 1 / 10, callback = update, data = {} })
end)
