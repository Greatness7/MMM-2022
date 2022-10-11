--[[
    Firemoth Reclaimed
    By Team Ceaseless Centurians
--]]

event.register("initialized", function()
    if debug.log(tes3.isModActive("firemoth.esm")) then
        require("firemoth.weather.camera")
        -- dofile("firemoth.weather.controller")
        dofile("firemoth.shaders.tonemap")
        dofile("firemoth.music.controller")
        dofile("firemoth.puzzles.infiniteCorners")
        dofile("firemoth.puzzles.alternatingStairs")
        -- dofile("firemoth.puzzles.secretWall")
        dofile("firemoth.testing")
    end
end)
