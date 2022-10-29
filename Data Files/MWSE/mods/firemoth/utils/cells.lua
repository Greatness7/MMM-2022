local this = {}

local XY = tes3vector3.new(1, 1, 0)

local FIREMOTH_GRID_ORIGIN = tes3vector2.new(-8, -10)

this.FIREMOTH_REGION_ORIGIN = tes3vector3.new(
    (FIREMOTH_GRID_ORIGIN.x + 0.5) * 8192,
    (FIREMOTH_GRID_ORIGIN.y + 0.5) * 8192,
    0
)

--- @param cell tes3cell
--- @returns boolean
function this.isFiremothCell(cell)
    if cell == nil then
        return false
    elseif cell.isInterior then
        return string.startswith(cell.name, "Firemoth") or false
    end

    -- Our exterior grid ranges from (-7, -9) to (-9, -11)

    local x = cell.gridX
    if (x > -7) or (x < -9) then
        return false
    end

    local y = cell.gridY
    if (y > -9) or (y < -11) then
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
        return cell.name:startswith("Firemoth") and 0 or math.fhuge
    else
        return (tes3.player.position * XY):distance(this.FIREMOTH_REGION_ORIGIN)
    end
end

return this
