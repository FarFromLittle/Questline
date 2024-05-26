local Objective = require(script.Objective)

local Questline = { __index = {} }

local prototype = setmetatable(Questline.__index, Objective)
local super = Objective.__index

local dataStore = {}
local playerData = {}
local questTable = {}

local ATTEMPT_COUNT = 1
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

local function saveStat(player, name, value)
	local ds = dataStore[player]
	
	if not ds then return end
	
	task.spawn(attempt, ds.SetAsync, ds, name, value)
end

local function objectiveCanceled(objective, player)
	local self = objective.Parent
	
	super.Cancel(objective, player)
	
	self:Cancel(player)
end

local function objectiveComplete(objective, player)
	local self = objective.Parent
	
	local progress = objective.Index
	
	super.Complete(objective, player)
	
	saveStat(player, self.QuestId, progress)

	self.Progress[player] = progress
	
	if #self.Objectives <= progress then
		self:Complete(player)
	else
		self.Objectives[progress + 1]:Assign(player)
	end
end

function Questline.getQuestById(questId)
	return questTable[questId]
end

function Questline.register(player, questData)
	local ok, ds = attempt(game.DataStoreService.GetOrderedDataStore, game.DataStoreService, player.UserId, "Questline")
	
	if not questData then questData = {} end
	
	if ok then
		dataStore[player] = ds
		loadPlayerData(ds, player, questData)
	end
	
	local playerstats = Instance.new("Folder")
	playerstats.Name = "playerstats"
	
	for questId, progress in questData do
		local quest = questTable[questId]
		
		if not quest then
			local stat = Instance.new("IntValue")
			stat.Name = questId
			stat.Value = progress
			stat.Parent = playerstats
			continue
		end
		
		if 0 <= progress and progress <= #quest.Objectives then
			quest:Assign(player, progress)
		end
	end
	
	playerstats.Parent = player
end

function Questline.unregister(player)
	local ds = dataStore[player]

	if not ds then return end

	dataStore[player] = nil

	local leaderstats = player:FindFirstChild("leaderstats")

	if not leaderstats then return end

	for _, child in leaderstats:GetChildren() do
		task.spawn(attempt, ds.SetAsync, ds, child.Name, child.Value)
	end
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
	
	if not progress then
		progress = 0
	end

	self.Progress[player] = progress
	
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
	
	local progress = self.Progress[player]

	if not progress then return end

	local currentObjective = self.Objectives[progress + 1]

	if currentObjective then
		currentObjective:Disconnect(player)
	end

	self.Progress[player] = nil
end

function prototype:IsComplete(player)
	return self.Progress[player] and #self.Objectives <= self.Progress[player] or false
end

return Questline
