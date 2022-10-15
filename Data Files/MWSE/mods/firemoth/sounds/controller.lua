local utils = require("firemoth.utils")
local isFiremothCell = utils.cells.isFiremothCell

local durations = {5, 8, 10, 12, 14, 15, 18, 20, 23, 25, 28, 30}
local interiorTimer

local function playInteriorSound()
    tes3.playSound({
        sound = "tew_fm_int" .. math.random(1, 13),
        reference = tes3.player,
        volume = 1.0 * math.random(4,10) / 10,
        mixChannel = tes3.soundMix.master
    })
end

local function resolveCell()
	local cell = tes3.getPlayerCell()

	if cell.isInterior and isFiremothCell(cell) then
		local dur = table.choice(durations)
		interiorTimer = timer.start{
			type = timer.simulate,
			duration = dur,
			callback = function()
				playInteriorSound()
				resolveCell()
			end
		}
	else
		if (interiorTimer) and not (interiorTimer.state == timer.expired) then
			interiorTimer:pause()
			interiorTimer:cancel()
			interiorTimer = nil
		end

	end

end

event.register(tes3.event.cellChanged, resolveCell)

