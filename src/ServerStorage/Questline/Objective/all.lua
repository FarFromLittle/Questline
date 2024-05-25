local Objective = require(script.Parent)

local All = { __index = {} }

local prototype = setmetatable(All.__index, Objective)
local super = Objective.__index

local function objectiveCanceled(objective, player)
	local self = objective.Parent
	
	super.Cancel(objective, player)
	
	self:Cancel(player)
end

local function objectiveComplete(objective, player)
	local self = objective.Parent
	
	local progress = self.Progress[player] + 1
	
	super.Complete(objective, player)
	
	if #self.Objectives <= progress then
		self:Complete(player)
	else
		self.Progress[player] = progress
	end
end

function All.new(_, ...)
	local self = Objective.new(All, {
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
		if self.Connected[player] then
			obj:Assign(player)
		else
			return
		end
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

return All