local var = {
    fogControl = {
        journalOn = {
            condition = "MS_FargothRing",
            value = 100
        },
        -- journalOff = {condition = "MS_FargothRing", value = 100},
        targetObject = "Fargoth",
        triggerDistance = 8192,
        weatherData = {
            skyColour = tes3vector3.new(0, 255, 0 / 255)
        }
    }
}

return var
