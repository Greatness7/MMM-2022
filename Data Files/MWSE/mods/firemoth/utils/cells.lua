local this = {}

local XY = tes3vector3.new(1, 1, 0)

local FIREMOTH_REGION_ORIGIN = tes3vector3.new(-57344, -77824, 0)

local INTERIORS = {
    ["firemoth, keep"] = true,
    ["firemoth, great hall"] = true,
    ["firemoth, upper chambers"] = true,
    ["firemoth, guard quarters"] = true,
    ["firemoth, dungeon"] = true,
    ["firemoth, lower cavern"] = true,
    ["firemoth, tomb"] = true,
    ["firemoth, guard towers"] = true,
    ["firemoth, upper cavern"] = true,
    ["firemoth, mine"] = true,
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

--- Distance from the center for Firemoth Region.
---
--- @return number
function this.getFiremothDistance()
    local cell = tes3.player.cell
    if cell.isInterior then
        return (INTERIORS[cell.name] and 0) or math.fhuge
    else
        return (tes3.player.position * XY):distance(FIREMOTH_REGION_ORIGIN)
    end
end

return this
