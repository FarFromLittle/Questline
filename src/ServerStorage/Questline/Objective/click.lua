local Objective = require(script.Parent)

local Click = { __index = setmetatable({}, Objective) }
local prototype = Click.__index
local super = Objective.__index

Click.new = Objective.new

local _detector = {}
local _evaluate = {}

local function default(player, target)
	return player == target
end

function Click:__tostring()
	return `click({self.ClickDetector.Parent.Name})`
end

function prototype:new(partOrModel)
	self.ClickDetector = Instance.new("ClickDetector", partOrModel)
end

function prototype:Assign(player, parent)
	local target = parent or self
	
	super.Assign(self, player)
	
	target:Connect(player, self.ClickDetector.MouseClick, function (...)
		if self:Evaluate(player, ...) then
			target:Disconnect(player, self.ClickDetector.MouseClick)
			
			self:Complete(player)
		end
	end)
end

function prototype:Evaluate(player, target)
	return player == target
end

return Click
