local quest = require("firemoth.quests.lib")
local pathingController = require("firemoth.quests.pathingController")

local FIGHTING_POSITION = { -56195.49, -75071.70, 93.58 }

local states = {
    arrived = 0,
    walking = 1,
    spawning = 2,
    fighting = 3,
}


local function arrivedHandler(data)
    -- Allow player to enter dialogue himself
    -- but if they walk too far away force it
    local distance = tes3.player.position:distance(quest.npcs.mara.position)
    if distance < 700 then
        return
    end

    tes3.showDialogueMenu({ reference = quest.npcs.mara })

    -- start walking inland

    pathingController.startPathing(quest.npcs.mara, {
        { -56110.94, -73762.62, 67.36 },
        { -56109.00, -74270.00, 92.00 },
    })

    pathingController.startPathing(quest.npcs.hjrondir, {
        { -56110.94, -73762.62, 67.36 },
        { -56180.00, -74523.00, 102.00 },
    })

    pathingController.startPathing(quest.npcs.aronil, {
        { -56110.94, -73762.62, 67.36 },
        { -56327.00, -74309.00, 76.00 },
    })

    -- play some fun voice lines

    data.timestamp = nil
    data.state = states.walking
end

local function walkingHandler(data)
    if data.secondsPassed < 10.0 then
        return
    end

    for _, ref in pairs({ quest.npcs.mara, quest.npcs.hjrondir, quest.npcs.aronil }) do
        tes3.setAIWander({ reference = ref, range = 200, idles = { 75, 25, 0, 0, 0, 0, 0 } })
    end

    tes3.say({ reference = quest.npcs.mara, soundPath = "vo\\w\\f\\Idl_WF009.mp3" })

    timer.start({
        duration = 1.5,
        callback = function()
            tes3.say({ reference = quest.npcs.hjrondir, soundPath = "vo\\n\\m\\bAtk_NM006.mp3" })
        end,
    })

    data.timestamp = nil
    data.state = states.spawning
end

local function spawningHandler(data)
    if data.secondsPassed < 3.0 then
        return
    end

    tes3.player.data.fm_skeletonSpawnerPosition = FIGHTING_POSITION
    tes3.player.data.fm_skeletonSpawnerDisabled = false

    data.timestamp = nil
    data.state = states.fighting
end

local function fightingHandler(data)
    if data.secondsPassed < 3.0 then
        return
    end
    data.timestamp = nil

    for _, ref in pairs({ quest.npcs.mara, quest.npcs.hjrondir, quest.npcs.aronil }) do
        local mob = assert(ref.mobile)
        mob.health.current = 500
        mob.fatigue.current = 500
        mob.magicka.current = 500

        if not mob.inCombat then
            local nearbyActors = tes3.findActorsInProximity({ reference = ref, range = 2048 })
            for _, actor in pairs(nearbyActors) do
                if actor.object.objectType == tes3.objectType.creature then
                    if not actor.isDead then
                        mob:startCombat(actor)
                    end
                    break
                end
            end
        end
    end
end

local function update(e)
    local data = e.timer.data

    ---@diagnostic disable-next-line: redundant-parameter
    local timestamp = tes3.getSimulationTimestamp(false)

    data.timestamp = data.timestamp or timestamp
    data.secondsPassed = timestamp - data.timestamp

    if data.state == states.arrived then
        arrivedHandler(data)
    elseif data.state == states.walking then
        walkingHandler(data)
    elseif data.state == states.spawning then
        spawningHandler(data)
    elseif data.state == states.fighting then
        fightingHandler(data)
    end
end
timer.register("firemoth:diversion", update)


local this = {}

function this.start()
    timer.start({
        iterations = -1,
        duration = 1.0,
        callback = "firemoth:diversion", ---@diagnostic disable-line
        persist = true,
        data = {
            state = 0,
        },
    })
end

return this
