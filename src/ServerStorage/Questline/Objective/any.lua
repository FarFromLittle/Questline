local Objective = require(script.Parent)

local Any = { __index = {} }

local prototype = setmetatable(Any.__index, Objective)
local super = Objective.__index

local function objectiveCanceled(objective, player)
	local self = objective.Parent
	
	super.Cancel(objective, player)
	
	local progress = self.Progress[player] + 1
	
	if #self.Objectives <= progress then
		self:Cancel(player)
	else
		self.Progress[player] = progress
	end
end

local function objectiveComplete(objective, player)
	local self = objective.Parent
	
	super.Complete(objective, player)
	
	self:Complete(player)
end

function Any.new(_, ...)
	local self = Objective.new(Any, {
		Objectives = { ... },
		Progress = {}
	})
	
	for _, obj in self.Objectives do
		obj.Cancel = objectiveCanceled
		obj.Complete = objectiveComplete
		
		obj.Parent = self
	end
	
	return self
end

function prototype:Assign(player)
	super.Assign(self, player)
	
	self.Progress[player] = 0
	
	for _, obj in self.Objectives do
		obj:Assign(player)
	end
end

function prototype:Disconnect(player)
	local connected = self.Connected[player]
	
	if not connected then return end
	
	super.Disconnect(self, player)
	
	for _, obj in self.Objectives do
		obj:Disconnect(player)
	end
	
	self.Progress[player] = nil
end

return Any