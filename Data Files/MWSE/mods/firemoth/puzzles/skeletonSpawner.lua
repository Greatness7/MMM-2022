local utils = require("firemoth.utils")

local MAX_SKELETONS = 12

local MAX_SPAWN_DISTANCE = 2048

local SKELETON_OBJECTS = {
    ["fm_skeleton_1"] = --[[Anim Duration]] 7.7,
    ["fm_skeleton_2"] = --[[Anim Duration]] 6.2,
}

local SKELETON_SPAWNERS = {
    ["fm_skeleton_spawner"] = true,
}

---@type table<tes3reference, boolean>
local spawners = {}

---@type table<tes3reference, boolean>
local skeletons = {}

---@type mwseTimer
local spawnTimer = nil


local function availableSpawners(timestamp)
    return coroutine.wrap(function()
        for spawner in pairs(spawners) do
            local spawnTime = spawner.data.fm_spawnTime or math.huge
            if math.abs(timestamp - spawnTime) >= 20 then
                coroutine.yield(spawner)
            end
        end
    end)
end


local function getClosestAvailableSpawner(timestamp)
    local position = tes3.player.position + (tes3.player.forwardDirection * 768)

    local closestSpawner = nil
    local distance = MAX_SPAWN_DISTANCE

    for spawner in availableSpawners(timestamp) do
        local dist = position:distance(spawner.position)
        if dist < distance then
            closestSpawner = spawner
            distance = dist
        end
    end

    return closestSpawner, distance
end


local function getFarthestSkeleton()
    local position = tes3.player.position

    local farthestSkeleton = nil
    local distance = 0

    for skeleton in pairs(skeletons) do
        local dist = position:distance(skeleton.position)
        if dist > distance then
            farthestSkeleton = skeleton
            distance = dist
        end
    end

    return farthestSkeleton, distance
end


local randomSkeletonId = utils.math.nonRepeatTableRNG(table.keys(SKELETON_OBJECTS))
local function spawnSkeleton()
    local timestamp = tes3.getSimulationTimestamp()
    local spawner = getClosestAvailableSpawner(timestamp)
    if not spawner then
        return
    end

    -- If we're at the max number of skeletons then 'respawn' the farthest one.
    -- Otherwise player can just spawn all skeletons on an island and ditch it.
    if table.size(skeletons) >= MAX_SKELETONS then
        local skeleton, distance = getFarthestSkeleton()
        if distance <= 1024 then
            return
        end
        skeleton:disable()
        skeleton:delete()
    end

    local skeleton = tes3.createReference({
        object = randomSkeletonId(),
        position = spawner.position,
        cell = spawner.cell,
    })

    skeleton.position = spawner.position
    skeleton.orientation.z = math.rad(math.random(360))

    tes3.playAnimation({
        reference = skeleton,
        group = tes3.animationGroup.idle9,
        loopCount = 0,
    })

    tes3.playSound({
        sound = "tew_fm_skelerise",
        reference = skeleton,
        volume = 1.0,
    })

    -- Workaround for skeletons turning during animation playback. Yuck.
    local animDuration = SKELETON_OBJECTS[skeleton.baseObject.id]
    tes3.applyMagicSource({
        reference = skeleton,
        bypassResistances = true,
        effects = { { id = tes3.effect.paralyze, min = 100, max = 100, duration = animDuration } },
        name = "Skeleton Rising",
    })

    -- We use the timestamp to avoid repeat spawns from the same spawner.
    spawner.data.fm_spawnTime = timestamp
end
event.register(tes3.event.loaded, function()
    spawnTimer = timer.start({ iterations = -1, duration = 1.0, callback = spawnSkeleton })
    spawnTimer:pause()
end)


---@param e cellChangedEventData
local function enteredFiremoth(e)
    local isFiremoth = utils.cells.isFiremothCell(e.cell)
    local wasFiremoth = utils.cells.isFiremothCell(e.previousCell)
    if isFiremoth and not wasFiremoth then
        spawnTimer:resume()
    elseif wasFiremoth and not isFiremoth then
        spawnTimer:pause()
    end
end
event.register(tes3.event.cellChanged, enteredFiremoth)


---@param e referenceActivatedEventData
local function onReferenceCreated(e)
    local object = e.reference.baseObject
    if object == nil then
        return
    end

    if SKELETON_SPAWNERS[object.id] then
        spawners[e.reference] = true
        return
    end

    if SKELETON_OBJECTS[object.id] then
        skeletons[e.reference] = true
        return
    end
end
event.register(tes3.event.referenceActivated, onReferenceCreated)


---@param e referenceDeactivatedEventData|objectInvalidatedEventData
local function onReferenceDeleted(e)
    spawners[e.reference or e.object] = nil
    skeletons[e.reference or e.object] = nil
end
event.register(tes3.event.referenceDeactivated, onReferenceDeleted)
event.register(tes3.event.objectInvalidated, onReferenceDeleted)
