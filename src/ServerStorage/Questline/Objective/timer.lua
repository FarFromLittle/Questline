local Objective = require(script.Parent)

local Timer = { __index = {} }

local prototype = setmetatable(Timer.__index, Objective)
local super = Objective.__index

function Timer.new(_, duration)
	local self = Objective.new(Timer, {
		Duration = duration
	})
	
	return self
end

function prototype:Assign(player)
	super.Assign(self, player)
	
	task.delay(self.Duration, self.Complete, self, player)
end

return Timer
