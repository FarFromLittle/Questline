local Questline = require(script.Parent.Parent)
local Objective = require(script.Parent)

local Value = {}
local super = Objective.__index

local _connected = {}
local _statName = {}
local _targetValue = {}

function Value:__tostring()
	return `value({_statName[self]}, {_targetValue[self]})`
end

function Value:new(statName, targetValue)
	_connected[self] = {}
	_statName[self] = statName
	_targetValue[self] = targetValue
end

function Value:Connect(player)
	local connected = _connected[self]
	local statName = _statName[self]
	local targetValue = _targetValue[self]
	
	super.Connect(self, player)

	local playerstats = player:FindFirstChild("playerstats")
	
	if not playerstats then
		return error(`Player not registered.`)
	end
	
	local intVal:IntValue = playerstats:FindFirstChild(statName)

	local function onChange(...)
		if self:Evaluate(player, ...) then
			self:Complete(player)
		end
	end
	
	if intVal then
		if targetValue <= intVal.Value then
			task.defer(self.Complete, self, player)
		end

		connected[player] = intVal.Changed:Connect(onChange)
	else
		connected[player] = playerstats.ChildAdded:Connect(function(child)
			if child.Name == statName then
				self:Disconnect(player)

				if targetValue <= child.Value then
					task.defer(self.Complete, self, player)
				end
		
				connected[player] = child.Changed:Connect(onChange)
			end
		end)
	end
end

function Value:Disconnect(player)
	local connected = _connected[self]
	
	if not connected[player] then
		return
	end
	
	if connected[player].Connected then
		connected[player]:Disconnect()
	end
	
	connected[player] = nil
end

function Value:Evaluate(player, value)
	local targetValue = _targetValue[self]

	return targetValue <= value
end

return Value
