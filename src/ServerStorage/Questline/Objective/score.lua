local Objective = require(script.Parent)

local Score = { __index = setmetatable({}, Objective) }
local prototype = Score.__index
local super = Objective.__index

function Score:__tostring()
	return `score({self.Duration})`
end

function prototype:new(statName, targetValue)
	self.StatName = statName
	self.TargetValue = targetValue
end

function prototype:Assign(player, parent)
	super.Assign(self, player)
	
	local target = parent or self
	
	local leaderstats = player:FindFirstChild("leaderstats")
	
	if not leaderstats then
		return error(`Leaderstats not found.`)
	end
	
	local intVal = leaderstats:FindFirstChild(self.StatName)
	
	if not intVal then
		return error(`{self.StatName} is not a leaderstat.`)
	end
	
	target:Connect(player, intVal.Changed, function (newVal)
		if self.TargetValue <= newVal then
			target:Disconnect(player, intVal.Changed)
			
			self:Complete(player)
		end
	end)
end

return Score
