local utils = require("firemoth.utils")

local MAX_SKELETONS = 12

local MAX_SPAWN_DISTANCE = 2048

local SKELETON_OBJECTS = {
    [tes3.getObject("fm_skeleton_1")] = --[[Anim Duration]] 7.7,
    [tes3.getObject("fm_skeleton_2")] = --[[Anim Duration]] 6.2,
}

local SKELETON_SPAWNERS = {
    [tes3.getObject("fm_skeleton_spawner")] = true,
}

local SKELETON_SOUNDS = {
    [tes3.getSound("tew_fm_skelerise")] = true,
}

local SKELETON_VFX = {
    [tes3.getObject("fm_skeleton_rising_vfx")] = true,
}

---@type table<tes3reference, boolean>
local spawners = {}

---@type table<tes3reference, boolean>
local skeletons = {}

---@type table<tes3reference, boolean>
local corpses = {}

---@type mwseTimer
local spawnTimer = nil

local randomSkeletonObject = utils.math.nonRepeatTableRNG(table.keys(SKELETON_OBJECTS))
local randomSkeletonSound = utils.math.nonRepeatTableRNG(table.keys(SKELETON_SOUNDS))
local randomSkeletonVFX = utils.math.nonRepeatTableRNG(table.keys(SKELETON_VFX))


local function availableSpawners(timestamp)
    return coroutine.wrap(function()
        for spawner in pairs(spawners) do
            local time = spawner.data.fm_spawnTime or math.fhuge
            if math.abs(timestamp - time) >= 10 then -- min 10s since last spawn
                coroutine.yield(spawner)
            end
        end
    end)
end


local function getClosestAvailableSpawner(position, timestamp)
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


local function getFarthestReference(references)
    local position = tes3.player.position

    local farthestSkeleton = nil
    local distance = 0

    for skeleton in pairs(references) do
        local dist = position:distance(skeleton.position)
        if dist > distance then
            farthestSkeleton = skeleton
            distance = dist
        end
    end

    return farthestSkeleton, distance
end


local function resetSpawnerTimes()
    for spawner in pairs(spawners) do
        spawner.data.fm_spawnTime = nil
    end
end


local function attackClosestHuman(skeleton)
    local nearbyHumanActors = {}
    for _, actor in pairs(tes3.findActorsInProximity({ reference = skeleton, range = 1024 })) do
        if not SKELETON_OBJECTS[actor.object.baseObject] then
            table.insert(nearbyHumanActors, actor)
        end
    end
    local actor = table.choice(nearbyHumanActors)
    if actor then
        skeleton.mobile:startCombat(actor)
    end
end


local function spawnSkeleton()
    local timestamp = tes3.getSimulationTimestamp()
    if tes3.player.data.fm_skeletonSpawnerDisabled then
        return
    end

    -- Position override is set during the quest battle.
    local position = tes3.player.data.fm_skeletonSpawnerPosition
    if position then
        position = tes3vector3.new(unpack(position))
        -- Revert override if we're far from the battle.
        if position:distance(tes3.player.position) > 2048 then
            position = nil
        end
    end

    if position == nil then
        position = tes3.getPlayerEyePosition() + tes3.getPlayerEyeVector() * 256
    end

    local spawner = getClosestAvailableSpawner(position, timestamp)
    if not spawner then
        resetSpawnerTimes()
        return
    end

    -- If we're at the max number of skeletons then 'respawn' the farthest one.
    -- Otherwise player can just spawn all skeletons on an island and ditch it.
    if table.size(skeletons) >= MAX_SKELETONS then
        local skeleton, distance = getFarthestReference(skeletons)
        if distance <= 1024 then
            return
        end
        skeleton:disable()
        skeleton:delete()
    end

    if table.size(corpses) >= MAX_SKELETONS * 2 then
        local corpse = getFarthestReference(corpses)
        if corpse then
            corpse:disable()
            corpse:delete()
        end
    end

    local skeleton = tes3.createReference({
        object = randomSkeletonObject(),
        position = spawner.position,
        cell = spawner.cell,
    })
    attackClosestHuman(skeleton)

    skeleton.position = spawner.position
    skeleton.orientation.z = math.rad(math.random(360))

    tes3.playAnimation({
        reference = skeleton,
        group = tes3.animationGroup.idle9,
        loopCount = 0,
    })

    tes3.playSound({
        sound = randomSkeletonSound(),
        reference = skeleton,
        mixChannel = tes3.soundMix.master,
        volume = 1.0,
    })

    tes3.createVisualEffect({
        object = randomSkeletonVFX(),
        lifespan = 20.0,
        position = skeleton.position,
    })

    -- Workaround for skeletons turning during animation playback. Yuck.
    local animDuration = assert(SKELETON_OBJECTS[skeleton.baseObject])
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
    -- Fix skeletons that were in the middle of animation when save/reload.
    for _, cell in pairs(tes3.getActiveCells()) do
        for ref in cell:iterateReferences(tes3.objectType.creature) do
            if SKELETON_OBJECTS[ref.baseObject] and not ref.isDead then
                if tes3.getAnimationGroups({ reference = ref }) == tes3.animationGroup.idle9 then
                    tes3.playAnimation({ reference = ref, group = tes3.animationGroup.idle })
                    tes3.removeEffects({ reference = ref, effect = tes3.effect.paralyze })
                    skeletons[ref] = true
                end
            end
        end
    end
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


---@param e referenceActivatedEventData|mobileActivatedEventData
local function onReferenceCreated(e)
    local object = e.reference.baseObject
    if object == nil then
        return
    end

    if SKELETON_SPAWNERS[object] then
        spawners[e.reference] = true
        return
    end

    if SKELETON_OBJECTS[object] then
        if e.reference.isDead then
            corpses[e.reference] = true
        else
            skeletons[e.reference] = true
        end
        return
    end
end
event.register(tes3.event.mobileActivated, onReferenceCreated)
event.register(tes3.event.referenceActivated, onReferenceCreated)


---@param e referenceDeactivatedEventData|objectInvalidatedEventData
local function onReferenceDeleted(e)
    spawners[e.reference or e.object] = nil
    skeletons[e.reference or e.object] = nil
    corpses[e.reference or e.object] = nil
end
event.register(tes3.event.referenceDeactivated, onReferenceDeleted)
event.register(tes3.event.objectInvalidated, onReferenceDeleted)


---@param e deathEventData
local function onDeath(e)
    local object = e.reference.baseObject
    if SKELETON_OBJECTS[object] then
        skeletons[e.reference] = nil
        corpses[e.reference] = true
    end
end
event.register(tes3.event.death, onDeath)
