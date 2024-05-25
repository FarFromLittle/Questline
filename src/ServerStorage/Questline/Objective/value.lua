local Objective = require(script.Parent)

local Value = { __index = {} }

local prototype = setmetatable(Value.__index, Objective)
local super = Objective.__index

function Value.new(_, intValue, targetValue)
	local self = Objective.new(Value, {
		IntValue = intValue,
		TargetValue = targetValue
	})
	
	return self
end

local function getIntValue(path, parent)
	if not parent then parent = game end
	
	local last = path:match("[%P]+$")
	
	for objName in path:gmatch("[^%p]+") do
		local obj = parent:FindFirstChild(objName)
		
		if not obj then
			obj = Instance.new(objName == last and "IntValue" or "Folder")
			obj.Name = objName
			obj.Parent = parent
		end
		
		parent = obj
	end
	
	return parent
end

function prototype:Assign(player)
	local intValue = self.IntValue
	
	if type(intValue) == "string" then
		intValue = getIntValue(intValue, player)
	end
	
	if self.TargetValue <= intValue.Value then return end
	
	super.Assign(self, player)
	
	local event = intValue.Changed
	
	self.Connected[player][event] = event:Connect(function (newValue)
		if self.TargetValue <= newValue then
			self:Complete(player)
		end
	end)
end

return Value
