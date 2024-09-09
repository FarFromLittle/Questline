local Objective = require(script.Parent)

local Timer = {}
local super = Objective.__index

local _connected = {}
local _timeDelay = {}

function Timer:__tostring()
	return `timer({_timeDelay[self]})`
end

function Timer:new(timeDelay)
	_connected[self] = {}
	_timeDelay[self] = timeDelay
end

function Timer:Connect(player)
	local connected = _connected[self]
	local timeDelay = _timeDelay[self]
	
	super.Connect(self, player)

	if connected[player] then
		self:Disconnect(player)
	end
	
	connected[player] = task.delay(timeDelay, self.Complete, self, player)
end

function Timer:Disconnect(player)
	local connected = _connected[self]
	
	if not connected[player] then
		return
	end
	
	if coroutine.status(connected[player]) == "suspended" then
		task.cancel(connected[player])
	end
	
	connected[player] = nil
end

return Timer
