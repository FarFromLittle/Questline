local Objective = require(script.Parent)

local Click = {}

local _connected = {}
local _detector = {}
local _evaluate = {}

local function default(player, target)
	return player == target
end

function Click:__tostring()
	return `click({self.ClickDetector})`
end

function Click:new(partOrModel)
	_connected[self] = {}
	_detector[self] = Instance.new("ClickDetector", partOrModel)
end

function Click:Connect(player)
	local connected = _connected[self]
	local detector = _detector[self]
	
	connected[player] = detector.MouseClick:Connect(function (...)
		if self:Evaluate(player, ...) then
			self:Complete(player)
		end
	end)
end

function Click:Disconnect(player)
	local connected = _connected[self]
	local detector = _detector[self]
	
	if not connected[player] then
		return
	end
	
	if connected[player].Connected then
		connected[player]:Disconnect()
	end
	
	connected[player] = nil
end

function Click:Evaluate(player, target)
	return player == target
end

return Click
