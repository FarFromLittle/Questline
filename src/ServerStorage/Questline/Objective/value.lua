local Questline = require(script.Parent.Parent)
local Objective = require(script.Parent)

local Value = { __index = setmetatable({}, Objective) }
local prototype = Value.__index
local super = Objective.__index

function Value:__tostring()
	return `value({self.StatName}, {self.TargetValue})`
end

function prototype:new(statName, targetValue)
	self.StatName = statName
	self.TargetValue = targetValue
end

function prototype:Assign(player, parent)
	super.Assign(self, player)
	
	local target = parent or self
	
	local playerstats = player:FindFirstChild("playerstats")
	
	if not playerstats then
		return error(`Playerstats not found.`)
	end
	
	local intVal = playerstats:FindFirstChild(self.StatName)
	
	if not intVal then
		return error(`{self.StatName} is not a playerstat.`)
	end
	
	target:Connect(player, intVal.Changed, function (newVal)
		if self.TargetValue <= newVal then
			target:Disconnect(player, intVal.Changed)
			
			self:Complete(player)
		end
	end)
end

return Value
