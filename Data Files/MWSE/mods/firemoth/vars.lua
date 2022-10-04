local var = {
    skyControl = {
        journalOn = {
            condition = "MS_FargothRing",
            value = 100
        },
        -- journalOff = {condition = "MS_FargothRing", value = 100},
        cellOn = "Seyda Neen, Census and Excise Office",
        targetObject = "Fargoth",
        triggerDistance = 8192,
        weatherData = {
            airColour = tes3vector3.new(18 / 255, 83 / 255, 89 / 255)
        }
    }
}

return var
