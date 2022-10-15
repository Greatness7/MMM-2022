local lightning = require("firemoth.weather.lightning")

local function onKeyDownZ(e)
    if not e.isAltDown then return end

    local rayhit = tes3.rayTest {
        position = tes3.getPlayerEyePosition(),
        direction = tes3.getPlayerEyeVector(),
        ignore = tes3.player,
    }

    if rayhit and rayhit.intersection then
        local position = rayhit.intersection:copy()
        lightning.createLightningStrike(position, --[[strength]] 1.0, --[[expode]] true)
    end

    return false
end
event.register(tes3.event.keyDown, onKeyDownZ, { filter = tes3.scanCode.z })
