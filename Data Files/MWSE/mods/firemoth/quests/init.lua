local quest = require("firemoth.quests.lib")

event.register("firemoth:QuestReset", function(e)
    quest.setPersistentReferencesDisabled(true)
end)

event.register("firemoth:QuestAccepted", function(e)
    quest.setPersistentReferencesDisabled(false)
end)
