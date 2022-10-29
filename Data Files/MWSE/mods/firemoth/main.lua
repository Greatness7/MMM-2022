--[[
    Firemoth Reclaimed
    by team Ceaseless Centurions
    MMM 2022
--]]

if tes3.getFileExists("MWSE\\mods\\hrnchamd\\weatheradjust\\main.lua") then
    dofile("firemoth.weather.skyController")
end

event.register("initialized", function()
    if tes3.isModActive("firemoth.esm") then
        require("firemoth.weather.camera")
        dofile("firemoth.weather.lightningController")
        dofile("firemoth.weather.fogController")
        dofile("firemoth.weather.fogDensityController")
        dofile("firemoth.weather.fogInteriorController")
        dofile("firemoth.shaders.tonemap")
        dofile("firemoth.music.controller")
        dofile("firemoth.sounds.controller")
        dofile("firemoth.puzzles.infiniteCorners")
        dofile("firemoth.puzzles.alternatingStairs")
        dofile("firemoth.puzzles.skeletonSpawner")
        -- dofile("firemoth.puzzles.secretWall")
        dofile("firemoth.testing")
        dofile("firemoth.quests")
    end
end)

event.register("modConfigReady", function()
    dofile("Data Files\\MWSE\\mods\\firemoth\\mcm\\menu.lua")
end)
