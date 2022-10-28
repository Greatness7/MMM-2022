-- World controller does not exist at this point, so we need hardcoded values
local weathers = {
    ["Clear"] = "Data Files\\Textures\\tx_sky_clear.tga",
    ["Cloudy"] = "Data Files\\Textures\\tx_sky_cloudy.tga",
    ["Foggy"] = "Data Files\\Textures\\tx_sky_foggy.tga",
    ["Overcast"] = "Data Files\\Textures\\tx_sky_overcast.tga",
    ["Rain"] = "Data Files\\Textures\\tx_sky_rainy.tga",
    ["Thunderstorm"] = "Data Files\\Textures\\tx_sky_thunder.tga",
    ["Ashstorm"] = "Data Files\\Textures\\tx_sky_ashstorm.tga",
    ["Blight"] = "Data Files\\Textures\\tx_sky_blight.tga",
    ["Snow"] = "Data Files\\Textures\\tx_bm_sky_snow.tga",
    ["Blizzard"] = "Data Files\\Textures\\tx_mb_sky_blizzard.tga"
}

-- That's what we're injecting into WA preset
local FIREMOTH_COLORS = {
    ["sunDayColor"] = {0,0,0},
    ["skySunsetColor"] = {0,0.16,0.12},
    ["fogSunsetColor"] = {0,0.175,0.155},
    ["fogDayColor"] = {0,0.175,0.155},
    ["skyNightColor"] = {0,0.16,0.12},
    ["fogSunriseColor"] = {0,0.175,0.155},
    ["ambientSunsetColor"] = {0.07,0.17,0.09},
    ["skyDayColor"] = {0,0.16,0.12},
    ["ambientDayColor"] = {0.07,0.17,0.09},
    ["sunNightColor"] = {0,0,0},
    ["ambientNightColor"] = {0.07,0.17,0.09},
    ["sunSunsetColor"] = {0,0,0},
    ["sundiscSunsetColor"] = {0,0,0},
    ["sunSunriseColor"] = {0,0,0},
    ["ambientSunriseColor"] = {0.07,0.17,0.09},
    ["fogNightColor"] = {0,0.175,0.155},
    ["skySunriseColor"] = {0,0.16,0.12}
}
local FIREMOTH_OUTSCATTER = {0.005,0.005,0.005}
local FIREMOTH_INSCATTER = {0.005,0.005,0.005}

local function overridePreset()
    local preset = mwse.loadConfig("Weather Adjuster")
    mwse.saveConfig("Weather Adjuster_backup", preset)
    if preset then
        preset.presets["CC_Firemoth"] = {}
        for name, tex in pairs(weathers) do
            preset.presets["CC_Firemoth"][name] = FIREMOTH_COLORS
            preset.presets["CC_Firemoth"][name]["cloudTexture"] = tex
        end
        preset.presets["CC_Firemoth"].outscatter = FIREMOTH_OUTSCATTER
        preset.presets["CC_Firemoth"].inscatter = FIREMOTH_INSCATTER
        preset.regions["Firemoth Region"] = "CC_Firemoth"
        mwse.saveConfig("Weather Adjuster", preset)
    end
end

local function restorePreset()
    local preset = mwse.loadConfig("Weather Adjuster_backup")
    if preset then
        mwse.saveConfig("Weather Adjuster", preset)
    end
end

local function rebindExitButton(e)
	-- Try to find the options menu exit button.
	local exitButton = e.element:findChild(tes3ui.registerID("MenuOptions_Exit_container"))
	if (exitButton == nil) then return end

	-- Set our new event handler.
	exitButton:registerAfter("mouseClick", restorePreset)
end
event.register("uiCreated", rebindExitButton, { filter = "MenuOptions" })


overridePreset()