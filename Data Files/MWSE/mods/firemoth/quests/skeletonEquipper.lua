---@type tes3armor[]
local armorObjects = {
    assert(tes3.getObject("imperial boots")),
    assert(tes3.getObject("imperial helmet armor")),
    assert(tes3.getObject("imperial left gauntlet")),
    assert(tes3.getObject("imperial left pauldron")),
    assert(tes3.getObject("imperial right gauntlet")),
    assert(tes3.getObject("imperial right pauldron")),
    assert(tes3.getObject("imperial cuirass_armor")),
    assert(tes3.getObject("imperial skirt_clothing")),
}

local nodes = {}
do
    local mesh = tes3.loadMesh("base_anim.nif")
    for _, name in pairs({
        "Chest",
        "Groin",
        "Head",
        "Left Ankle",
        "Left Clavicle",
        "Left Foot",
        "Left Forearm",
        "Left Hand",
        "Left Knee",
        "Left Upper Arm",
        "Left Upper Leg",
        "Left Wrist",
        "Neck",
        "Right Ankle",
        "Right Clavicle",
        "Right Foot",
        "Right Forearm",
        "Right Hand",
        "Right Knee",
        "Right Upper Arm",
        "Right Upper Leg",
        "Right Wrist",
        "Shield",
        "Weapon",
    }) do
        local node = assert(mesh:getObjectByName(name))
        nodes[node:clone()] = node.parent.name
    end
end

local partConfig = {
    [1] = { name = "Head", offset = tes3vector3.new(0, 2.8, 2.0) },
    [4] = { name = "Chest" },
    [8] = { name = "Right Upper Arm" },
    [9] = { name = "Right Foot" },
    [10] = { name = "Right Ankle" },
    [13] = { name = "Right Clavicle" },
}
local function attachRegular(sceneNode, partNode, partIndex)
    local config = partConfig[partIndex]
    if config then
        sceneNode:getObjectByName(config.name):attachChild(partNode)
        if config.offset then
            partNode.translation = partNode.translation + config.offset
        end
    end
end

local function attachSkinned(sceneNode, partNode)
    for node in table.traverse(partNode.children) do
        local skin = node.skinInstance
        if skin then
            skin.root = sceneNode:getObjectByName(skin.root.name)
            for i, bone in ipairs(skin.bones) do
                skin.bones[i] = sceneNode:getObjectByName(bone.name)
            end
            skin.root:attachChild(node)
        end
    end
end

local function isSkinned(root)
    for node in table.traverse(root.children) do
        if node.skinInstance then
            return true
        end
    end
end

local function patchMesh(sceneNode)
    for node, parentName in pairs(nodes) do
        local parentNode = assert(sceneNode:getObjectByName(parentName))
        local attachNode = node:clone()
        parentNode:attachChild(attachNode)
    end
    for _, armor in pairs(armorObjects) do
        for _, p in pairs(armor.parts) do
            if p.male then
                local root = tes3.loadMesh(p.male and p.male.mesh)
                if root then
                    if isSkinned(root) then
                        attachSkinned(sceneNode, root:clone())
                    else
                        attachRegular(sceneNode, root:clone(), p.male.part)
                    end
                end
            end
        end
    end
end


local targetMeshes = table.invert({
    "meshes\\fm\\r\\skeleton_rising_1.nif",
    "meshes\\fm\\r\\xskeleton_rising_1.nif",
    "meshes\\fm\\r\\skeleton_rising_2.nif",
    "meshes\\fm\\r\\xskeleton_rising_2.nif",
})
event.register(tes3.event.meshLoaded, function(e)
    if targetMeshes[e.path:lower()] then
        patchMesh(e.node)
    end
end)


local targetObjects = table.invert({
    assert(tes3.getObject("fm_skeleton_1")),
    assert(tes3.getObject("fm_skeleton_2")),
})
event.register(tes3.event.referenceSceneNodeCreated, function(e)
    if targetObjects[e.reference.baseObject] then
        local bip01 = e.reference.sceneNode:getObjectByName("Bip01")
        for _, name in pairs({ "Head", "Right Upper Arm", "Right Foot", "Right Ankle", "Right Clavicle" }) do
            if math.random() > 0.5 then
                local node = bip01:getObjectByName(name)
                node.appCulled = true
                node:update()
            end
        end
        for _, name in pairs({ "Groin", "Chest" }) do
            if math.random() > 0.5 then
                for _, child in pairs(bip01.children) do
                    if child.name:gsub("Tri ", ""):startswith(name) then
                        child.appCulled = true
                        child:update()
                    end
                end
            end
        end
    end
end)
