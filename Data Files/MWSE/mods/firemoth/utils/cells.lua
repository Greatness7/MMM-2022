local this = {}

local XY = tes3vector3.new(1, 1, 0)

this.FIREMOTH_REGION_ORIGIN = tes3vector3.new(-57344, -77824, 0)

local INTERIORS = {
    ["Firemoth, Keep"] = true,
    ["Firemoth, Great Hall"] = true,
    ["Firemoth, Upper Chambers"] = true,
    ["Firemoth, Guard Quarters"] = true,
    ["Firemoth, Dungeon"] = true,
    ["Firemoth, Lower Cavern"] = true,
    ["Firemoth, Tomb"] = true,
    ["Firemoth, Guard Towers"] = true,
    ["Firemoth, Upper Cavern"] = true,
    ["Firemoth, Mine"] = true,
}

--- @param cell tes3cell
--- @returns boolean
function this.isFiremothCell(cell)
    if cell.isInterior then
        return INTERIORS[cell.name] or false
    end

    -- Our exterior grid ranges from (-6, -8) to (-9, -12)

    local x = cell.gridX
    if (x > -6) or (x < -9) then
        return false
    end

    local y = cell.gridY
    if (y > -8) or (y < -12) then
        return false
    end

    return true
end

function this.getNearbyCompanions()
    local nearbyCompanions = {}
    for companion in tes3.iterate(tes3.mobilePlayer.friendlyActors) do
        if tes3.getCurrentAIPackageId(companion) == tes3.aiPackage.follow then
            table.insert(nearbyCompanions, companion)
        end
    end
    return nearbyCompanions
end

--- Distance from the center for Firemoth Region.
---
--- @return number
function this.getFiremothDistance()
    local cell = tes3.player.cell
    if cell.isInterior then
        return (INTERIORS[cell.name] and 0) or math.fhuge
    else
        return (tes3.player.position * XY):distance(this.FIREMOTH_REGION_ORIGIN)
    end
end

return this
