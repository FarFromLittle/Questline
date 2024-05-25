local Objective = require(script.Parent)

local Touch = { __index = {} }

local prototype = setmetatable(Touch.__index, Objective)
local super = Objective.__index

function Touch.new(_, touchPart)
	local self = Objective.new(Touch, {
		TouchPart = touchPart
	})
	
	return self
end

function prototype:Assign(player)
	local function touched(otherPart)
		if otherPart.Parent == player.Character then
			self:Complete(player)
			
			return true
		end
		
		return false
	end
	
	for _, part in self.TouchPart:GetTouchingParts() do
		if touched(part) then return end
	end
	
	super.Assign(self, player)
	
	local event = self.TouchPart.Touched
	
	self.Connected[player][event] = event:Connect(touched)
end

return Touch
