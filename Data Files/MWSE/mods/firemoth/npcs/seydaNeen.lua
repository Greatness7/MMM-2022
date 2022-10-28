event.register(tes3.event.referenceSceneNodeCreated, function(e)
    if e.reference.baseObject.id == "fm_mudcrab_dead" then
        local arrows = assert(tes3.loadMesh("fm\\f\\mudcrab_arrows.nif"))
        e.reference.sceneNode:attachChild(arrows:clone()) ---@diagnostic disable-line
    end
end)
