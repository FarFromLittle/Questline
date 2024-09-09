local Questline = require(script.Parent.Parent)
local Objective = require(script.Parent)

local Score = {}
local super = Objective.__index

local _connected = {}
local _statName = {}
local _targetValue = {}

function Score:__tostring()
	return `score({_statName[self]}, {_targetValue[self]})`
end

function Score:new(statName, targetValue)
	_connected[self] = {}
	_statName[self] = statName
	_targetValue[self] = targetValue
end

function Score:Connect(player)
	local connected = _connected[self]
	local statName = _statName[self]
	local targetValue = _targetValue[self]

	super.Connect(self, player)
	
	if targetValue <= Questline.getStat(player, statName) then
		return self:Complete(player)
	end
	
	local leaderstats = player:FindFirstChild("leaderstats")
	
	if not leaderstats then
		error(`Leaderstats not found.`)
	end
	
	local intVal:IntValue = leaderstats:FindFirstChild(statName)
	
	if not intVal then
		error(`Leaderstat "{statName}" not found.`)
	end
	
	connected[player] = intVal.Changed:Connect(function (newVal)
		if targetValue <= newVal then
			self:Complete(player)
		end
	end)
end

function Score:Disconnect(player)
	local connected = _connected[self]
	
	if not connected[player] then
		return
	end
	
	if connected[player].Connected then
		connected[player]:Disconnect()
	end
	
	connected[player] = nil
end

return Score
