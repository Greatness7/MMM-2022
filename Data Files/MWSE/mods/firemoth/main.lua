--[[
    Firemoth Reclaimed
    By Team Ceaseless Centurians
--]]

event.register("initialized", function()
    if debug.log(tes3.isModActive("firemoth.esm")) then
        dofile("firemoth.weather.controller.lua")
    end
end)
