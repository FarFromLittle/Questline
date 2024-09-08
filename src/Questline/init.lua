---!strict
local DataStore = game:GetService("DataStoreService")
local Objective = require(script.Objective)

export type Questline = typeof(setmetatable({}::Object, {}::Class))

export type Class = {
	Objective: Objective.Class,
	
	new: (questId:string) -> (Questline),
	
	getQuestById: (questId:string) -> (Questline?),
	
	getStat: (player:Player, statName:string) -> (number),
	setStat: (player:Player, statName:string, newValue:number) -> (),
	
	register: (player:Player, progress:PlayerProgress?) -> (),
	unregister: (player:Player) -> (PlayerProgress)
}

export type Object = {
	Cancel: (self:Questline, player:Player) -> (),
	Complete: (self:Questline, player:Player) -> (),
	
	Connect: (self:Questline, player:Player) -> (),
	Disconnect: (self:Questline, player:Player) -> (),
	
	--Destroy: (self:Questline) -> (),
	
	GetQuestId: (self:Questline) -> string,
	
	GetProgress: (self:Questline, player:Player) -> string,
	SetProgress: (self:Questline, player:Player, progress:number) -> string,
	
	IsComplete: (self:Questline, player:Player) -> string,
	IsConnected: (self:Questline, player:Player) -> boolean,
	
	OnAssign: (self:Questline, player:Player) -> (),
	OnCancel: (self:Questline, player:Player) -> (),
	OnComplete: (self:Questline, player:Player) -> (),
	OnProgress: (self:Questline, player:Player, index:number) -> ()
}

type PlayerProgress = { [string]: number }
type QuestTable = { [string]: Questline }

local Quest = Objective.quest::Class

local PAGE_SIZE = 100
local LOAD_ATTEMPTS = 3
local SAVE_ATTEMPTS = 3

local Questline = setmetatable({}::Class, Quest)
Questline.__index = Questline

local _progress = {}
local _questIndex = {}
local _questTable = {}

Questline.Objective = Objective

local function attempt(try:number, ...)
	local ok, res
	
	while true do
		ok, res = pcall(...)
		
		try -= 1
		
		if not ok and 0 < try then
			task.wait(3)
		else
			break
		end
	end
	
	return ok, res
end

local function getQuestData(target:string, source:string, default:PlayerProgress?, minValue:number?, maxValue:number?)
	local data:PlayerProgress = default or {}
	
	local ok:boolean, ds:OrderedDataStore = pcall(DataStore.GetOrderedDataStore, DataStore, target, source)
	
	local pages:DataStorePages
	
	if ok then
		ok, pages = attempt(LOAD_ATTEMPTS, ds.GetSortedAsync, ds, false, PAGE_SIZE, minValue, maxValue)
	else
		warn("Unable to load player data.")
		
		return data
	end
	
	while true do
		for _, entry in pages:GetCurrentPage() do
			data[entry.key] = entry.value
		end
		
		if pages.IsFinished then
			break
		end
		
		if not attempt(LOAD_ATTEMPTS, pages.AdvanceToNextPageAsync, pages) then
			warn("Failed to load page.")
			
			break
		end
	end
	
	return data
end

function Questline.getQuestById(questId)
	local quest = _questTable[questId]
	
	if not quest then
		task.wait()
		quest = _questTable[questId]
	end
	
	return quest or warn(`{questId} not found`)
end

function Questline.isLoaded(player)
	return _progress[player] ~= nil
end

function Questline.register(player:Player, defaultProgress:PlayerProgress?)
	if _progress[player] then error(`{player.Name} has already registered.`) end
	
	local playerstats:Folder = Instance.new("Folder")
	playerstats.Name = "playerstats"
	
	for name, value in getQuestData(player.UserId, "playerstats") do
		local intVal:IntValue = Instance.new("IntValue")
		intVal.Name = name
		intVal.Value = value
		intVal.Parent = playerstats
	end
	
	playerstats.Parent = player
	
	local progress:PlayerProgress = getQuestData(player.UserId, "Questline", defaultProgress, 0)
	
	_progress[player] = progress
	
	for questId, currentProgress in progress do
		local quest:Questline = _questTable[questId]
		
		if quest and currentProgress < quest:GetObjectiveCount() then
			quest:Connect(player, currentProgress)
		end
	end
end

function Questline.unregister(player:Player)
	local progress = _progress[player]
	
	if not progress then return end
	
	_progress[player] = nil
	
	for questId, currentProgress in progress do
		local quest:Questline = _questTable[questId]
		
		if quest and quest:IsConnected(player) then
			quest:Disconnect(player)
		end
	end
end

function Questline.getStat(player:Player, statName:string)
	local playerstats:Folder? = player:FindFirstChild("playerstats")
	
	if not playerstats then
		error("Player not registered.")
	end
	
	local intVal:IntValue? = playerstats:FindFirstChild(statName)
	
	if intVal then
		return intVal.Value
	end
	
	local ok:boolean, ds:DataStore = pcall(DataStore.GetOrderedDataStore, DataStore, player.UserId, "playerstats")
	
	local res:number?
	
	if ok then
		ok, res = attempt(LOAD_ATTEMPTS, ds.GetAsync, ds, statName)
	end
	
	intVal = Instance.new("IntValue")
	intVal.Name = statName
	intVal.Value = res or 0
	intVal.Parent = playerstats
	
	return intVal.Value
end

function Questline.setStat(player:Player, statName:string, value:number)
	local playerstats = player:FindFirstChild("playerstats")
	
	if not playerstats then
		error("Player not registered.")
	end
	
	local intVal:IntValue? = playerstats:FindFirstChild(statName)
	
	if intVal then
		intVal.Value = value
	else
		intVal = Instance.new("IntValue")
		intVal.Name = statName
		intVal.Value = value
		intVal.Parent = playerstats
		
		if value == 0 then
			return
		end
	end
	
	local ok:boolean, ds:OrderedDataStore = pcall(DataStore.GetOrderedDataStore, DataStore, player.UserId, "playerstats")
	
	if not ds then
		return
	end
	
	if value == 0 then
		task.spawn(attempt, SAVE_ATTEMPTS, ds.RemoveAsync, ds, statName, value)
	else
		task.spawn(attempt, SAVE_ATTEMPTS, ds.SetAsync, ds, statName, value)
	end
end

function Questline:__tostring()
	return _questIndex[self]
end

function Questline.new(questId)
	local self = setmetatable({}, Questline)
	
	Quest.new(self)
	
	_questIndex[self] = questId
	_questTable[questId] = self
	
	return self
end

function Questline:GetProgress(player)
	return _progress[player] and _progress[player][_questIndex[self]] or 0
end

function Questline:GetQuestId()
	return _questIndex[self]
end

function Questline:IsComplete(player)
	return self:GetObjectiveCount() <= Questline:GetProgress(player)
end

function Questline:SetProgress(player, newValue)
	local progress = _progress[player]
	local questId = self:GetQuestId()
	
	if not progress then
		error("Player not registered.")
	end
	
	if newValue == progress[questId] then
		return
	end
	
	progress[questId] = newValue
	
	if newValue == 0 then
		self:OnAccept(player)
	end
	
	local ok:boolean, ds:OrderedDataStore = pcall(DataStore.GetOrderedDataStore, DataStore, player.UserId, "Questline")
	
	if not ok then
		warn("Unable to save progress.")
		
		return
	end
	
	task.spawn(attempt, SAVE_ATTEMPTS, ds.SetAsync, ds, questId, newValue)
end

function Questline:OnAccept(player) end

return Questline
