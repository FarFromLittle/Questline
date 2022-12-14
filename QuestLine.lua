--!strict

-- Authored by FarFromLittle

local Objective = {}

function Objective.event(event:RBXScriptSignal, count:number)
	local function objective(player:Player, progress:number)
		local plr
		
		for i = 1, count - progress do
			repeat plr = coroutine.yield(progress, event)
			until plr == player
			progress += 1
		end
		
		return progress
	end
	
	return objective, count
end

function Objective.score(name:string, amount:number)
	local function objective(player:Player, progress:number)
		local ldr = player:FindFirstChild("leaderstats")
		while not(ldr and ldr.Name == "leaderstats") do ldr = coroutine.yield(progress, player.ChildAdded) end
		
		local int = ldr:FindFirstChild(name)::IntValue
		while not(int and int.Name == name) do int = coroutine.yield(progress, ldr.ChildAdded) end
		
		if amount <= int.Value then return amount end
		
		progress = int.Value
		
		while progress < amount do progress = coroutine.yield(progress, int.Changed) end
		
		return amount
	end
	
	return objective, amount
end

function Objective.timer(sec:number, one:boolean?)
	local function objective(player:Player, progress:number)
		local event = Instance.new("BindableEvent")
		
		while progress < sec do
			task.delay(1, event.Fire, event, progress)
			
			if one then
				coroutine.yield(0, event.Event)
			else
				progress = coroutine.yield(progress, event.Event)
			end
			
			progress += 1
		end
		
		event:Destroy()
		
		return one and 1 or progress
	end
	
	return objective, one and 1 or sec
end

function Objective.touch(touchPart:BasePart)
	local function objective(player:Player, progress:number)
		local hit
		
		repeat
			hit = coroutine.yield(progress, touchPart.Touched)
		until hit.Parent == player.Character
		
		return 1
	end
	
	return objective, 1
end

function Objective.value(intValue:IntValue, amount:number)
	local function objective(player:Player, progress:number)
		while progress < amount do
			progress = coroutine.yield(progress, intValue.Changed)
		end
		
		return amount
	end
	
	return objective, amount
end


local QuestLine = {
	Event = "event",
	Score = "score",
	Timer = "timer",
	Touch = "touch",
	Value = "value"
}
QuestLine.__index = QuestLine

export type QuestLine = typeof(QuestLine)
export type Objective = "event"|"score"|"timer"|"touch"|"value"

QuestLine.timeout = 1

function QuestLine:OnAccept(player:Player) end
function QuestLine:OnAssign(player:Player, progress:number, index:number) end
function QuestLine:OnCancel(player:Player) end
function QuestLine:OnComplete(player:Player) end
function QuestLine:OnProgress(player:Player, progress:number, index:number) end

local questIndex:{[QuestLine]:string} = {}
local questTable:{[string]:QuestLine} = {}

local playerConnection:{[Player]:{[QuestLine]:RBXScriptConnection}} = {}
local playerObjective:{[Player]:{[QuestLine]:thread}} = {}
local playerProgress:{[Player]:{[string]:number}} = {}

local objectiveCount:{[QuestLine]:number} = {}
local objectiveTable:{[QuestLine]:{(plr:Player, prg:number)->(number, RBXScriptSignal?)}} = {}
local objectiveValue:{[QuestLine]:{number}} = {}

local Error = {
	NOT_REGISTERED = "%s is not registered.",
	QUEST_EMPTY = "%s assigned to empty quest.",
	ASSIGNED_COMPLETE = "%s assigned to completed quest. Cancel before assigning again.",
	QUEST_NOT_ACCEPTED = "%s has not accepted quest.",
	DUPLICATE_QUEST = "Quest '%s' already exists."
}

local dead, empty = coroutine.wrap(function()end)(), {}

local function disconnect(player:Player, quest:QuestLine)
	local conn = playerConnection[player][quest]
	local obj = playerObjective[player][quest]
	
	if conn and conn.Connected then conn:Disconnect() end
	if obj and coroutine.status(obj) ~= "dead" then coroutine.close(obj) end
	
	playerConnection[player][quest] = nil
	playerObjective[player][quest] = nil
end

function QuestLine.registerPlayer(player:Player, questData:{[string]:number})
	playerConnection[player] = {}
	playerObjective[player] = {}
	playerProgress[player] = questData
	
	for questId in pairs(questData) do
		local quest = QuestLine.getQuestById(questId)
		
		if not quest then continue end
		
		if not quest:IsComplete(player) then quest:Assign(player) end
	end
end

function QuestLine.unregisterPlayer(player:Player):{[string]:number}
	local res = playerProgress[player]
	
	for _, conn in pairs(playerConnection[player]) do if conn.Connected then conn:Disconnect() end end
	for _, obj in pairs(playerObjective[player]) do if coroutine.status(obj) ~= "dead" then coroutine.close(obj) end end
	
	playerConnection[player] = nil
	playerObjective[player] = nil
	playerProgress[player] = nil
	
	return res
end

function QuestLine.getQuestById(questId:string):QuestLine
	return questTable[tostring(questId):sub(1, 50)]
end

function QuestLine.new(questId:string, obj:{any}?)
	local self = setmetatable(obj or {}, QuestLine)::QuestLine
	
	questId = tostring(questId):sub(1, 50)
	
	assert(questTable[questId] == nil, Error.DUPLICATE_QUEST:format(questId))
	
	questIndex[self] = questId
	questTable[questId] = self
	
	objectiveCount[self] = 0
	objectiveTable[self] = {}
	objectiveValue[self] = {}
	
	return self
end

function QuestLine:__tostring():string
	return questIndex[self]
end

function QuestLine:IsAccepted(player:Player):boolean
	return (playerProgress[player] and playerProgress[player][questIndex[self]]) and true or false
end

function QuestLine:IsCanceled(player:Player):boolean
	local progress = playerProgress[player] and playerProgress[player][questIndex[self]]
	
	return progress and progress < 0 or false
end

function QuestLine:IsComplete(player:Player):boolean
	local progress = playerProgress[player] and playerProgress[player][questIndex[self]]
	
	return progress and objectiveCount[self] <= progress or false
end

function QuestLine:Assign(player:Player)
	local questId = questIndex[self]
	
	assert(playerProgress[player], Error.NOT_REGISTERED:format(player and player.Name or "Unknown"))
	assert(0 < objectiveCount[self], Error.QUEST_EMPTY:format(player.Name))
	assert(not self:IsComplete(player), Error.ASSIGNED_COMPLETE:format(player.Name))
	
	local currentProgress, index, progress
	
	if not self:IsAccepted(player) then
		index = 1
		progress = 0
		currentProgress = 0
		
		playerProgress[player][tostring(self)] = 0
		
		self:OnAccept(player)
	else
		progress = self:GetProgress(player)
		currentProgress, index = self:GetCurrentProgress(player)
	end
	
	local coro = objectiveTable[self][index]
	
	self:OnAssign(player, currentProgress, index)
	self:OnProgress(player, currentProgress, index)
	
	local conn
	local event = empty
	local obj = coroutine.create(coro or dead)
	
	local function connect(...)
		if coroutine.status(obj) == "dead" then
			index += 1
			currentProgress = 0
			coro = objectiveTable[self][index]
			
			if not coro then
				disconnect(player, self)
				
				return self:OnComplete(player)
			end
			
			event = empty
			obj = coroutine.create(coro)
			playerObjective[player][self] = obj
			
			self:OnProgress(player, currentProgress, index)
		end
		
		local ok, prg, evt = coroutine.resume(obj, ...)
		
		if not ok then error(prg) end
		
		if prg and currentProgress < prg then
			progress += prg - currentProgress
			
			playerProgress[player][tostring(self)] = progress
			
			currentProgress = prg
			
			self:OnProgress(player, currentProgress, index)
		end
		
		if event == evt then return end
		
		if conn and conn.Connected then conn:Disconnect() end
		
		if not evt then return task.delay(QuestLine.timeout, connect, player, 0) end
		
		conn = evt:Connect(connect)
		event = evt
		playerConnection[player][self] = conn
	end
	
	connect(player, currentProgress)
end

function QuestLine:Cancel(player:Player)
	assert(self:IsAccepted(player), Error.QUEST_NOT_ACCEPTED:format(player.Name))
	
	disconnect(player, self)
	
	local progress = self:GetProgress(player)
	
	playerProgress[player][questIndex[self]] = -(progress + 1)
	
	self:OnCancel(player)
end

function QuestLine:GetProgress(player:Player)
	assert(playerProgress[player], Error.NOT_REGISTERED:format(player.Name))
	
	return playerProgress[player][tostring(self)] or 0
end

function QuestLine:GetCurrentProgress(player:Player):(number, number)
	if not self:IsAccepted(player) or self:IsComplete(player) then return 0, 0 end
	
	local progress = self:GetProgress(player)
	
	if progress < 0 then progress = -(progress + 1) end
	
	progress = math.min(progress, objectiveCount[self])
	
	local objectives = objectiveTable[self]
	local values = objectiveValue[self]
	
	if not objectives then return 0, 0 end
	
	local currentProgress = progress
	local index = 1
	
	while values[index] <= currentProgress do
		currentProgress -= values[index]
		index += 1
	end
	
	return currentProgress, index
end

function QuestLine:AddObjective(objType:Objective, ...:any):number
	local obj, val = Objective[objType](...)
	
	local index = #objectiveTable[self] + 1
	
	objectiveCount[self] += val
	objectiveTable[self][index] = obj
	objectiveValue[self][index] = val
	
	return index
end

function QuestLine:GetObjectiveValue(index:number):number
	return objectiveValue[self][index]
end

return QuestLine
