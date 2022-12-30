-- Authored by FarFromLittle

export type QuestLine = {
	Event:"event",
	Score:"score",
	Timer:"timer",
	Touch:"touch",
	Value:"value",
	
	interval:number,
	
	getQuestById:(questId:string)->QuestLine,
	register:(player:Player, progressTable:{[string]:number}?)->nil,
	unregister:(player:Player)->{[string]:number},
	
	new:(questId:string, playerData:{[string]:number})->QuestLine,
	
	AddObjective:(self:QuestLine, objType:Objective, ...any)->number,
	
	Assign:(self:QuestLine, player:Player)->nil,
	Cancel:(self:QuestLine, player:Player)->nil,
	
	GetCurrentProgress:(self:QuestLine, player:Player)->(number, number),
	GetObjectiveValue:(self:QuestLine, index:number)->number,
	GetProgress:(self:QuestLine, player:Player)->number,
	
	IsAccepted:(self:QuestLine, player:Player)->boolean,
	IsCanceled:(self:QuestLine, player:Player)->boolean,
	IsComplete:(self:QuestLine, player:Player)->boolean,
	
	OnAccept:(self:QuestLine, player:Player)->nil,
	OnAssign:(self:QuestLine, player:Player)->nil,
	OnCancel:(self:QuestLine, player:Player)->nil,
	OnComplete:(self:QuestLine, player:Player)->nil,
	OnProgress:(self:QuestLine, player:Player, progress:number, index:number)->nil
}

export type Objective = "event"|"score"|"timer"|"touch"|"value"

local Objective = {}

function Objective.event(event:RBXScriptSignal, count:number?)
	if not count then count = 1 end
	
	local function thread(player:Player, progress:number)
		for i = 1, count - progress do
			repeat until coroutine.yield(progress, event) == player
			progress += 1
		end
		
		return progress
	end
	
	return thread, count
end

function Objective.score(statName:string, amount:number)
	local function thread(player:Player, progress:number)
		local ldr = player:FindFirstChild("leaderstats")
		while not(ldr and ldr.Name == "leaderstats") do ldr = coroutine.yield(progress, player.ChildAdded) end
		
		local int = ldr:FindFirstChild(statName)::IntValue
		while not(int and int.Name == statName) do int = coroutine.yield(progress, ldr.ChildAdded) end
		
		if amount <= int.Value then return amount end
		
		progress = int.Value
		
		while progress < amount do progress = coroutine.yield(progress, int.Changed) end
		
		return amount
	end
	
	return thread, amount
end

function Objective.timer(seconds:number, steps:number?)
	local skip = if steps then seconds / math.clamp(steps, 1, seconds) else seconds
	
	local function thread(player:Player, progress:number)
		local event = Instance.new("BindableEvent")
		
		while progress < seconds do
			task.delay(skip, event.Fire, event, progress + skip)
			
			progress = coroutine.yield(progress, event.Event)
		end
		
		event:Destroy()
		
		return seconds
	end
	
	return thread, seconds
end

function Objective.touch(touchPart:BasePart)
	local function thread(player:Player, progress:number)
		local hit
		
		repeat
			hit = coroutine.yield(progress, touchPart.Touched)
		until hit.Parent == player.Character
		
		return 1
	end
	
	return thread, 1
end

function Objective.value(intValue:IntValue, amount:number)
	local function thread(player:Player, progress:number)
		while progress < amount do
			progress = coroutine.yield(progress, intValue.Changed)
		end
		
		return amount
	end
	
	return thread, amount
end

local QuestLine = {
	Event = "event",
	Score = "score",
	Timer = "timer",
	Touch = "touch",
	Value = "value",
	
	interval = 1.0
}
QuestLine.__index = QuestLine

local questIndex:{[QuestLine]:string} = {}
local questTable:{[string]:QuestLine} = {}

local playerConnection:{[Player]:{[QuestLine]:RBXScriptConnection}} = {}
local playerObjective:{[Player]:{[QuestLine]:thread}} = {}
local playerProgress:{[Player]:{[string]:number}} = {}

local objectiveCount:{[QuestLine]:number} = {}
local objectiveTable:{[QuestLine]:{(plr:Player, prg:number)->(number, RBXScriptSignal?)}} = {}
local objectiveValue:{[QuestLine]:{number}} = {}

local EMPTY = "[QuestLine:%s] Quest is empty."
local EXISTS = "[QuestLine:%s] Duplicate quest."
local REGISTER = "[QuestLine:%s] Register %s."
local NO_INDEX = "[QuestLine:%s] Index '%d' not found."
local NO_ACCEPT = "[QuestLine:%s] %s could not accept."
local NO_ASSIGN = "[QuestLine:%s] Could not assign %s."
local NO_CANCEL = "[QuestLine:%s] Could not cancel %s."

local dead, empty = coroutine.wrap(function () end)(), {}

local function disconnect(player:Player, quest:QuestLine)
	local conn = playerConnection[player][quest]
	local obj = playerObjective[player][quest]
	
	if conn and conn.Connected then conn:Disconnect() end
	if obj and coroutine.status(obj) ~= "dead" then coroutine.close(obj) end
	
	playerConnection[player][quest] = nil
	playerObjective[player][quest] = nil
end

function QuestLine.getQuestById(questId:string):QuestLine
	return questTable[tostring(questId):sub(1, 50)]
end

function QuestLine.registerPlayer(player:Player, questData:{[string]:number})
	playerConnection[player] = {}
	playerObjective[player] = {}
	playerProgress[player] = questData
	
	for qid, prg in pairs(questData) do
		local quest = QuestLine.getQuestById(qid)
		
		if not quest then continue end
		
		if 0 <= prg and not quest:IsComplete(player) then quest:Assign(player) end
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

function QuestLine.new(questId:string, self:any)
	if not self then self = {} end
	
	setmetatable(self, QuestLine)
	
	questId = tostring(questId):sub(1, 50)
	
	assert(questTable[questId] == nil, EXISTS:format(questId))
	
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

function QuestLine:AddObjective(objType:string, ...:any):number
	local obj, val = Objective[objType](...)
	
	local index = #objectiveTable[self] + 1
	
	objectiveCount[self] += val
	objectiveTable[self][index] = obj
	objectiveValue[self][index] = val
	
	return index
end

function QuestLine:Assign(player:Player)
	local questId = questIndex[self]
	
	assert(playerProgress[player], REGISTER:format(questId, player and player.Name or "Unknown"))
	assert(0 < objectiveCount[self], EMPTY:format(questId))
	assert(not (self:IsComplete(player) or self:IsCanceled(player)), NO_ACCEPT:format(questId, player.Name))
	
	local index = 1
	local currentProgress, progress
	
	if not self:IsAccepted(player) then
		progress = 0
		currentProgress = 0
		
		playerProgress[player][questId] = 0
		
		self:OnAccept(player)
	else
		progress = self:GetProgress(player)
		currentProgress = progress
		
		while objectiveValue[self][index] <= currentProgress do
			currentProgress -= objectiveValue[self][index]
			index += 1
		end
	end
	
	self:OnAssign(player)
	self:OnProgress(player, currentProgress, index)
	
	local conn
	local coro = objectiveTable[self][index]
	local event = empty
	local obj = coroutine.create(coro or dead)
	
	local function connect(...)
		if coroutine.status(obj) == "dead" then
			index += 1
			currentProgress = 0
			coro = objectiveTable[self][index]
			
			if not coro then
				disconnect(player, self)
				self:OnComplete(player)
				return
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
			
			playerProgress[player][questIndex[self]] = progress
			
			currentProgress = prg
			
			self:OnProgress(player, currentProgress, index)
		end
		
		if event == evt then return end
		
		if conn and conn.Connected then conn:Disconnect() end
		
		if not evt then task.delay(QuestLine.interval, connect, player, 0) return end
		
		conn = evt:Connect(connect)
		event = evt
		playerConnection[player][self] = conn
	end
	
	connect(player, currentProgress)
end

function QuestLine:Cancel(player:Player)
	assert(self:IsAccepted(player), NO_CANCEL:format(player.Name))
	
	disconnect(player, self)
	
	local progress = self:GetProgress(player)
	
	playerProgress[player][questIndex[self]] = -(progress + 1)
	
	self:OnCancel(player)
end

function QuestLine:GetCurrentProgress(player:Player):(number?, number?)
	if not self:IsAccepted(player) then
		return nil
	elseif self:IsComplete(player) then
		return objectiveValue[self][objectiveCount[self]], objectiveCount[self]
	end
	
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

function QuestLine:GetObjectiveValue(index)
	assert(objectiveValue[self][index], NO_INDEX:format(questIndex[self], index))
	
	return objectiveValue[self][index]
end

function QuestLine:GetProgress(player:Player)
	return playerProgress[player] and playerProgress[player][questIndex[self]]
end

function QuestLine:IsAccepted(player:Player):boolean
	return playerProgress[player] ~= nil and playerProgress[player][questIndex[self]] ~= nil
end

function QuestLine:IsCanceled(player:Player):boolean
	return self:IsAccepted(player) and playerProgress[player][questIndex[self]] < 0
end

function QuestLine:IsComplete(player)
	local progress = self:GetProgress(player)
	return self:IsAccepted(player) and objectiveCount[self] <= playerProgress[player][questIndex[self]]
end

function QuestLine:OnAccept(player:Player) end

function QuestLine:OnAssign(player:Player) end

function QuestLine:OnCancel(player:Player) end

function QuestLine:OnComplete(player:Player) end

function QuestLine:OnProgress(player:Player, progress:number, index:number) end

return QuestLine
