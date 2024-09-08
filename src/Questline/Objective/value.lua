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
	
	if targetValue <= Questline.getStat(player, statName) then
		return self:Complete(player)
	end
	
	local playerstats = player:FindFirstChild("playerstats")
	
	if not playerstats then
		return error(`Playerstats not found.`)
	end
	
	local intVal:IntValue = playerstats:FindFirstChild(statName)
	
	connected[player] = intVal.Changed:Connect(function (newVal)
		if targetValue <= newVal then
			self:Complete(player)
		end
	end)
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

return Value
