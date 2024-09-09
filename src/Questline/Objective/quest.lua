local Objective = require(script.Parent)

local Quest = {}
local super = Objective.__index

local _children = {}
local _complete = {}

local _index = {}
local _parent = {}

Quest.__call = Objective.__call
Quest.IsQuest = true

local function objCanceled(obj, player)
	obj:Disconnect(player)
	
	local index = _index[obj]
	local parent = _parent[obj]
	
	local children = _children[parent]
	local complete = _complete[parent][player]
	
	task.defer(obj.OnCancel, obj, player)
	
	if parent.IsAny then
		complete[index] = true
		
		for i in children do
			if not complete[i] then
				return
			end
		end
	end
	
	parent:Cancel(player)
end

local function objComplete(obj, player)
	obj:Disconnect(player)
	
	local index = _index[obj]
	local parent = _parent[obj]
	
	local children = _children[parent]
	local complete = _complete[parent][player]
	
	task.defer(obj.OnComplete, obj, player)
	
	if parent.IsAny then
		parent:Complete(player)
		
		return
	end
	
	complete[index] = true
	
	obj:Disconnect(player)
	
	if parent.IsAll or parent.IsNone then
		for i, o in children do
			if not(complete[i] or o.IsNone) then
				task.defer(parent.OnProgress, parent, player, index)
				
				return
			end
		end
		
		return parent:Complete(player)
	end
	
	-- Begin Questline
	parent:SetProgress(player, index)
	
	local nextObj = children[index + 1]
	
	if nextObj then
		task.defer(parent.OnProgress, parent, player, index)
		
		nextObj:Connect(player)
	else
		parent:Complete(player)
	end
end

function Quest:new(...)
	_children[self] = {}
	_complete[self] = {}
	
	for _, obj in {...} do
		self:AddObjective(obj)
	end
end

function Quest:AddObjective(obj)
	assert(_parent[obj] == nil, "Objective already added.")
	
	local children = _children[self]
	
	local index = #children + 1
	
	if self.IsNone then
		obj.Cancel = objComplete
		obj.Complete = objCanceled
	else
		obj.Cancel = objCanceled
		obj.Complete = objComplete
	end
	
	children[index] = obj
	
	_index[obj] = index
	_parent[obj] = self
end

function Quest:Connect(player, progress)
	if not progress then
		progress = 0
	end

	super.Connect(self, player, progress)
	
	local children = _children[self]
	local complete = _complete[self]
	
	local startIndex, endIndex
	
	if self.IsAll or self.IsAny or self.IsNone then
		startIndex = 1
		endIndex = #children
	else
		startIndex = progress + 1
		endIndex = startIndex
		
		self:SetProgress(player, progress)
	end
	
	complete[player] = {}
	
	for i = startIndex, endIndex do
		children[i]:Connect(player)
	end
end

function Quest:Destroy()
	local children = _children[self]
	
	for player in _complete[self] do
		self:Disconnect(player)
		
		_complete[self][player] = nil
	end
	
	_children[self] = nil
	_complete[self] = nil
	
	for i = 1, #children do
		children[i]:Destroy()
	end
end

function Quest:Disconnect(player)
	local children = _children[self]
	local complete = _complete[self][player]
	
	if not complete then
		return
	end
	
	for i, obj in children do
		if not(complete[i] or obj.IsNone) then
			obj:Disconnect(player)
		end
		
		complete[i] = nil
	end
	
	_complete[self][player] = nil
end

function Quest:GetObjectiveAt(index)
	return _children[self][index]
end

function Quest:GetObjectiveCount()
	return #_children[self]
end

function Quest:IsConnected(player)
	return _complete[self][player] ~= nil
end

function Quest:OnProgress(player, index) end

return Quest
