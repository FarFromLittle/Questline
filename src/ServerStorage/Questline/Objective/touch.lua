local Objective = require(script.Parent)

local touch = { __index = setmetatable({}, Objective) }
local prototype = touch.__index
local super = Objective.__index

touch.new = Objective.new

function touch:__tostring()
	return `touch({self.TouchPart.Name})`
end

function prototype:new(touchPart)
	self.TouchPart = touchPart
end

function prototype:Assign(player, parent)
	super.Assign(self, player)
	
	local target = parent or self
	
	target:Connect(player, self.TouchPart.Touched, function (hitPart)
		if self:Evaluate(player, hitPart) then
			target:Disconnect(player, self.TouchPart.Touched)
			
			self:Complete(player)
		end
	end)
end

function prototype:Evaluate(player, hitPart)
	return hitPart.Parent == player.Character
end

return touch
