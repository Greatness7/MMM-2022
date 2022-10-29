local this = {}

local XY = tes3vector3.new(1, 1, 0)

local FIREMOTH_GRID_ORIGIN = tes3vector2.new(-8, -10)

this.FIREMOTH_REGION_ORIGIN = tes3vector3.new(
    (FIREMOTH_GRID_ORIGIN.x + 0.5) * 8192,
    (FIREMOTH_GRID_ORIGIN.y + 0.5) * 8192,
    0
)

function this.isFiremothInterior(cell)
    return cell.name:startswith("Firemoth") or false
end

function this.isFiremothExterior(cell)
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

--- @param cell tes3cell
--- @returns boolean
function this.isFiremothCell(cell)
    if cell == nil then
        return false
    elseif cell.isInterior then
        return this.isFiremothInterior(cell)
    else
        return this.isFiremothExterior(cell)
    end
end

--- Distance from the center for Firemoth Region.
---
--- @return number
function this.getFiremothDistance()
    local cell = tes3.player.cell
    if cell.isInterior then
        return this.isFiremothInterior(cell) and 0 or math.fhuge
    else
        return (tes3.player.position * XY):distance(this.FIREMOTH_REGION_ORIGIN)
    end
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

function this.calcInteriorFogPosition(cell)
    local pos = { x = 0, y = 0, z = 0 }
	local denom = 0

	for stat in cell:iterateReferences() do
		pos.x = pos.x + stat.position.x
		pos.y = pos.y + stat.position.y
		pos.z = pos.z + stat.position.z
		denom = denom + 1
	end

    return tes3vector3.new(pos.x/denom, pos.y/denom, pos.z/denom)
end

return this
