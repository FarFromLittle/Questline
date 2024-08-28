local Objective = require(script.Objective)

local Quest = Objective.quest

local Questline = setmetatable({
	__index = setmetatable({}, Quest)
}, {
	__tostring = function ()
		return "Questline"
	end,
})

local prototype = Questline.__index
local super = Quest.__index

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

local function getPlayerData(player, progress, minProgress, maxProgress)
	local ds, ok, pages
	
	local data = progress or {}
	
	ok, ds = pcall(game.DataStoreService.GetOrderedDataStore, game.DataStoreService, player.UserId, "Questline")
	
	if ok then
		ok, pages = attempt(3, ds.GetSortedAsync, ds, false, 100, minProgress or 0, maxProgress or 0xffffffff)
	end
	
	if not ok then
		warn("Unable to load player data.")
		
		return data
	end
	
	repeat
		for _, entry in pages:GetCurrentPage() do
			data[entry.key] = entry.value
		end
	until pages.IsFinished or not attempt(3, pages.AdvanceToNextPageAsync, pages)
	
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

function Questline.register(player, progress)
	if _progress[player] then error(`{player.Name} has already registered.`) end
	
	local data = getPlayerData(player, progress or {})
	
	_progress[player] = data
	
	local pstats = Instance.new("Folder")
	local quests = _questTable
	
	pstats.Name = "playerstats"
	
	for questId, progress in data do
		if quests[questId] then
			quests[questId]:Assign(player)
		else
			local intVal = Instance.new("IntValue")
			
			intVal.Name = questId
			intVal.Value = progress
			intVal.Parent = pstats
		end
	end
	
	pstats.Parent = player
end

function Questline.unregister(player:Player)
	local questData = _progress[player]
	
	if not questData then return end
	
	_progress[player] = nil
	
	local quests = _questTable
	
	for questId, progress in questData do
		if quests[questId] then
			quests[questId]:Disconnect(player)
		end
	end
end

function Questline.getStat(player:Player, statName:string)
	local value = _progress[player][statName]
	
	if value then return value end
	
	local ds, ok, res
	
	ok, ds = pcall(game.DataStoreService.GetOrderedDataStore, game.DataStoreService, player.UserId, "Questline")
	
	if not ds then return 0 end
	
	ok, res = attempt(3, ds.GetAsync, ds, statName)
	
	if not ok then return 0 end
	
	_progress[player][statName] = res
	
	return res
end

function Questline.setStat(player:Player, name:string, value:number)
	if value == _progress[player][name] then return end
	
	_progress[player][name] = value
	
	local ok, ds = pcall(game.DataStoreService.GetOrderedDataStore, game.DataStoreService, player.UserId, "Questline")
	
	if not ds then return end
	
	task.spawn(attempt, 3, ds.SetAsync, ds, name, value)
end

function Questline.new(questId)
	local self = Objective.new(Questline)
	
	_questIndex[self] = questId
	_questTable[questId] = self
	
	return self
end

function Questline:__tostring()
	return _questIndex[self]
end

function prototype:GetProgress(player)
	return _progress[player] and _progress[player][self] or 0
end

function prototype:GetQuestId()
	return _questIndex[self]
end

return Questline
