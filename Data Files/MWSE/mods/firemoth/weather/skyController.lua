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
    ["sunDayColor"] = {0.0065038478933275,0,0.00011165376054123},
    ["skySunsetColor"] = {0.1336452960968,0.14406704902649,0.13454793393612},
    ["fogSunsetColor"] = {0.2110009342432,0.31292769312859,0.25061112642288},
    ["fogDayColor"] = {0.23149907588959,0.3573169708252,0.22385853528976},
    ["skyNightColor"] = {0.042677965015173,0.090360872447491,0.021249016746879},
    ["fogSunriseColor"] = {0.21693943440914,0.26637265086174,0.1815433204174},
    ["ambientSunsetColor"] = {0.21177193522453,0.21176420152187,0.21174873411655},
    ["skyDayColor"] = {0.30822730064392,0.37651205062866,0.24763210117817},
    ["ambientDayColor"] = {0.30253541469574,0.30499342083931,0.21232399344444},
    ["sunNightColor"] = {0,0.00067067012423649,0},
    ["ambientNightColor"] = {0.16496916115284,0.21193534135818,0.1555439978838},
    ["sunSunsetColor"] = {0,0.00056773476535454,0},
    ["sundiscSunsetColor"] = {0.50196081399918,0.50196081399918,0.50196081399918},
    ["sunSunriseColor"] = {0,0.00070873933145776,0},
    ["ambientSunriseColor"] = {0.21178226172924,0.21176178753376,0.21174223721027},
    ["fogNightColor"] = {0.036167379468679,0.090743027627468,0.033697858452797},
    ["skySunriseColor"] = {0.13739524781704,0.1690034866333,0.10228496044874}
}
local FIREMOTH_OUTSCATTER = {0.07,0.36,0.76}
local FIREMOTH_INSCATTER = {0.25,0.38,0.48}

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