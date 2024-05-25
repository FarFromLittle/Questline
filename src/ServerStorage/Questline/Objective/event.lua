local Objective = require(script.Parent)

local Event = { __index = {} }

local prototype = setmetatable(Event.__index, Objective)
local super = Objective.__index

prototype.Filter = super.IsConnected

function Event.new(_, event, filter)
	local self = Objective.new(Event, {
		Event = event
	})
	
	if filter then
		self.Filter = filter
	end
	
	return self
end

function prototype:Assign(player)
	super.Assign(self, player)
	
	self.Connected[player][self.Event] = self.Event:Connect(function (...)
		if self:Filter(...) then
			self:Complete(player)
		end
	end)
end

return Event
