local Objective = require(script.Parent)

local Touch = { __index = {} }

local prototype = setmetatable(Touch.__index, Objective)
local super = Objective.__index

function Touch.new(_, touchPart, touchTarget, touchCount)
	local self = Objective.new(Touch, {
		TouchPart = touchPart
	})

	if touchTarget then
		self.TouchTarget = touchTarget
		self.TouchCount = touchCount or 1
	end
	
	return self
end

function prototype:Assign(player)
	local target = self.TouchTarget

	local function touched(otherPart)
		if target then
			if otherPart:HasTag(target) then
				self:Complete(player)

				return true
			end
		elseif otherPart.Parent == player.Character then
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
