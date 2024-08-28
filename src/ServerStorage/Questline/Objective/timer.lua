local Objective = require(script.Parent)

local Timer = { __index = setmetatable({}, Objective) }
local prototype = Timer.__index
local super = Objective.__index

function Timer:__tostring()
	return `timer({self.Duration})`
end

function prototype:new(duration)
	self.Duration = duration
end

function prototype:Assign(player, parent)
	super.Assign(self, player)
	
	task.delay(self.Duration, self.Complete, self, player)
end

return Timer
