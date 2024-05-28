local Objective = require(script.Objective)

local Questline = { __index = {} }

local prototype = setmetatable(Questline.__index, Objective)
local super = Objective.__index

local dataStore = {}
local questData = {}
local questTable = {}

Questline.Objective = Objective

local function attempt(times, ...)
	local ok, res
	
	while true do
		ok, res = pcall(...)
		
		times -= 1
		
		if ok or times <= 0 then
			break
		end
		
		task.wait(3)
	end

	return ok, res
end

local function loadPlayerData(player, playerData)
	local ok, ds = attempt(1, game.DataStoreService.GetOrderedDataStore, game.DataStoreService, player.UserId, "Questline")
	
	if ok then dataStore[player] = ds
	else return end

	local ok, pages = attempt(3, ds.GetSortedAsync, ds, false, 100)
	
	if not ok then return end
	
	print("Loading player data...")

	repeat
		for _, data in pages:GetCurrentPage() do
			playerData[data.key] = data.value
		end
	until pages.IsFinished or not attempt(3, pages.AdvanceToNextPageAsync, pages)

	print("Player data loaded.")

	return playerData
end

local function saveData(player, name, value)
	if value == questData[player][name] then return end

	questData[player][name] = value

	local ds = dataStore[player]

	if not ds then return end

	attempt(5, ds.SetAsync, ds, name, value)
end

local function objectiveCanceled(objective, player)
	local self = objective.Parent
	
	super.Cancel(objective, player)
	
	self:Cancel(player)
end

local function objectiveComplete(objective, player)
	local self = objective.Parent
	local progress = questData[player] and questData[player][self.QuestId] + 1

	if progress ~= objective.Index then return end
	
	saveData(player, self.QuestId, progress)
	
	super.Complete(objective, player)

	self:OnProgress(player, progress)
	
	if self.ObjectiveCount <= progress then
		self:Complete(player)
	else
		self.Objectives[progress + 1]:Assign(player)
	end
end

function Questline.getQuestById(questId)
	return questTable[questId]
end

function Questline.register(player, playerData)
	if not playerData then playerData = {} end

	loadPlayerData(player, playerData)
	
	questData[player] = playerData
	
	for questId, progress in playerData do
		local quest = questTable[questId]

		if not quest then continue end

		if 0 <= progress and progress < quest.ObjectiveCount then
			quest:Assign(player, progress)
		end
	end
end

function Questline.unregister(player)
	local ds = dataStore[player]

	if not ds then return end

	dataStore[player] = nil
	questData[player] = nil
end

function Questline.new(questId)
	local self = setmetatable({
		QuestId = questId,
		Objectives = {},
		ObjectiveCount = 0
	}, Questline)
	
	questTable[questId] = self
	
	return self
end

function prototype:AddObjective(obj)
	local index = self.ObjectiveCount + 1

	obj.Index = index
	obj.Parent = self

	obj.Cancel = objectiveCanceled
	obj.Complete = objectiveComplete

	table.freeze(obj)

	self.Objectives[index] = obj
	self.ObjectiveCount = index
	
	return obj
end

function prototype:Assign(player, progress)
	if not progress then progress = 0 end

	self:Disconnect(player)
	
	saveData(player, self.QuestId, progress)

	self:OnAssign(player)
	
	if self.ObjectiveCount <= progress then
		self:Complete(player)
	else
		self.Objectives[progress + 1]:Assign(player)
	end
end

function prototype:Disconnect(player)
	local currentObjective = self.Objectives[self:GetProgress(player) + 1]

	if currentObjective then
		currentObjective:Disconnect(player)
	end
end

function prototype:GetProgress(player)
	local progress = questData[player] and questData[player][self.QuestId]
	if not progress then return 0 end
	if progress < 0 then return -(progress + 1) end
	return progress
end

function prototype:IsComplete(player)
	local progress = questData[player] and questData[player][self.QuestId]
	return progress and self.ObjectiveCount <= progress or false
end

function prototype:IsConnected(player)
	local progress = questData[player] and questData[player][self.QuestId]
	return progress and 0 <= progress and progress < self.ObjectiveCount or false
end

function prototype:IsCanceled(player)
	local progress = questData[player] and questData[player][self.QuestId]
	return progress and progress < 0 or false
end

function prototype:OnProgress(player, progress) end

return Questline
