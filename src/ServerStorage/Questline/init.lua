local DataStore = game:GetService("DataStoreService")

local Objective = require(script.Objective)

local Questline = { __index = {} }

local prototype = setmetatable(Questline.__index, Objective)
local super = Objective.__index

local canSave = {}
local dataStore = {}
--local playerProgress = {}
local questTable = {}

local ATTEMPT_COUNT = 3
local ATTEMPT_DELAY = 3

Questline.Objective = Objective

local function attempt(...)
	local cnt = 0
	local ok, res
	
	while true do
		ok, res = pcall(...)
		
		cnt += 1
		
		if ok or ATTEMPT_COUNT <= cnt then
			break
		end
		
		task.wait(ATTEMPT_DELAY)
	end
	
	return ok, res
end

local function saveStat(player, name, value)
	local ds = dataStore[player]
	
	if not ds then return end
	
	attempt(ds.SetAsync, ds, name, value)
end

local function loadStat(player, name)
	local ds = dataStore[player]
	
	if not ds then return end
	
	local ok, res = attempt(ds.GetAsync, ds, name)
	
	return ok and res or nil
end

local function objectiveCanceled(objective, player)
	local self = objective.Parent
	
	super.Cancel(objective, player)
	
	self:Cancel(player)
end

local function objectiveComplete(objective, player)
	local self = objective.Parent
	
	local progress = playerData[player][self.QuestId] + 1
	
	super.Complete(objective, player)
	
	playerData[player][self.QuestId] = progress
	
	saveStat(player, self.QuestId, progress)
	
	if #self.Objectives <= progress then
		self:Complete(player)
	else
		self.Objectives[progress + 1]:Assign(player)
	end
end

function Questline.getQuestById(questId)
	return questTable[questId]
end

local function loadPlayerData(ds, player, data)
	local ok, pages = attempt(ds.GetSortedAsync, ds, false, 100)
	
	if not ok then return data end
	
	repeat
		for _, entry in pages:GetCurrentPage() do
			data[entry.key] = entry.value
		end
	until pages.IsFinished or not attempt(pages.AdvanceToNextPageAsync, pages)
	
	return data
end

function Questline.register(player, saveData)
	local ok, ds = attempt(DataStore.GetOrderedDataStore, DataStore, player.UserId, "Questline")
	
	if ok then
		dataStore[player] = ds
		saveData = loadPlayerData(ds, player, saveData or {})
	else
		
	end
	
	
	
	
	local playerstats = Instance.new("Folder")
	playerstats.Name = "playerstats"
	
	for key, val in saveData do
		local stat = questTable[key]
		
		if not stat then
			stat = Instance.new("IntValue")
			
			stat.Name = key
			stat.Value = val
			stat.Parent = playerstats
			
			continue
		end
		
		if 0 <= val and val <= #stat.Objectives then
			stat:Assign(player, val)
		end
	end
	
	playerstats.Parent = player
end

function Questline.unregister(player)
	local saveData = playerData[player]
	
	if not saveData then return end
	
	for questId, progress in saveData do
		local quest = questTable[questId]
		
		if quest and quest.Connected[player] then
			quest:Disconnect(player)
		end
	end
	
	playerData[player] = nil
	
	if canSave[player] then canSave[player] = nil
	else return end
	
	for name, value in saveData do
		saveStat(player.UserId, name, value)
	end
	
	local dataStore = DataStore:GetOrderedDataStore(player.UserId, "Questline")
	
	local ok, res
	local attempt = 0
	
	for questId, progress in saveData do repeat
		attempt += 1
		ok, res = pcall(dataStore.SetAsync, dataStore, questId, progress)
	until ok or 3 <= attempt or not task.wait(2) end
end

function Questline.new(questId)
	local self = Objective.new(Questline, {
		Objectives = {},
		Progress = {},
		QuestId = questId
	})
	
	questTable[questId] = self
	
	return self
end

function prototype:AddObjective(objType, ...)
	local obj
	
	if type(objType) == "string" then
		obj = Objective[objType](...)
	else
		obj = objType
	end
	
	obj.Cancel = objectiveCanceled
	obj.Complete = objectiveComplete
	obj.Index = #self.Objectives + 1
	obj.Parent = self
	
	self.Objectives[obj.Index] = obj
	
	return obj
end

function prototype:Assign(player, progress)
	super.Assign(self, player)
	
	local progress = playerData[player][self.QuestId]
	
	if not progress then
		progress = 0
		playerData[player][self.QuestId] = 0
	end
	
	if #self.Objectives <= progress then
		self:Complete(player)
	else
		self.Objectives[progress + 1]:Assign(player)
	end
end

function prototype:Disconnect(player)
	local connected = self.Connected[player]
	
	if not connected then return end
	
	super.Disconnect(self, player)
	
	local progress = playerData[player][self.QuestId]
	
	self.Objectives[progress]:Disconnect(player)
	
	playerData[player][self.QuestId] = nil
end

function prototype:IsComplete(player)
	return playerData[player] and #self.Objectives <= playerData[player][self.QuestId] or false
end

return Questline
