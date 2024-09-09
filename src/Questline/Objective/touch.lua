local Objective = require(script.Parent)

local Touch = {}
local super = Objective.__index

local _connected = {}
local _touchPart = {}

function Touch:__tostring()
	return `touch({_touchPart[self]})`
end

function Touch:new(touchPart)
	_connected[self] = {}
	_touchPart[self] = touchPart
end

function Touch:Connect(player)
	local connected = _connected[self]
	local touchPart = _touchPart[self]
	
	super.Connect(self, player)
	
	connected[player] = touchPart.Touched:Connect(function (hitPart)
		if self:Evaluate(player, hitPart) then
			self:Complete(player)
		end
	end)
end

function Touch:Disconnect(player)
	local connected = _connected[self]
	
	if not connected[player] then
		return
	end
	
	if connected[player].Connected then
		connected[player]:Disconnect()
	end
	
	connected[player] = nil
end

function Touch:Evaluate(player, hitPart)
	return hitPart.Parent == player.Character
end

return Touch
