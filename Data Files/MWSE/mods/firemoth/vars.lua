local var = {
    skyControl = {
        journalOn = {
            condition = "A1_1_FindSpymaster",
            value = 1
        },
        -- journalOff = {condition = "MS_FargothRing", value = 100},
        cellOn = "Seyda Neen, Census and Excise Office",
        targetObject = "sb_greenfog",
        targetPosition = tes3vector3.new(-59689.488, -77121.930, 0),
        triggerDistance = 8192 * 5,
        weatherData = {
            airColour = tes3vector3.new(18 / 255, 83 / 255, 89 / 255)
        }
    }
}

return var
