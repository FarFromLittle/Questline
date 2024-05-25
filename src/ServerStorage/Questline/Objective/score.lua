local Objective = require(script.Parent)

local Score = { __index = {} }

local prototype = setmetatable(Score.__index, Objective)
local super = Objective.__index

function Score.new(_, statName, targetValue)
	local self = Objective.new(Score, {
		StatName = statName,
		TargetValue = targetValue
	})
	
	return self
end

function prototype:Assign(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	
	if not leaderstats then error("Leaderstat folder not found.") end
	
	local intValue = leaderstats:FindFirstChild(self.StatName)
	
	if not intValue then error("Leaderstat not found.") end
	
	if self.TargetValue <= intValue.Value then return end
	
	super.Assign(self, player)
	
	local event = intValue.Changed
	
	self.Connected[player][event] = event:Connect(function (newValue)
		if self.TargetValue <= newValue then
			self:Complete(player)
		end
	end)
end

return Score
