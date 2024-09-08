local Objective = require(script.Parent)

local Quest = {}

local _children = {}
local _complete = {}

local _index = {}
local _parent = {}

Quest.__call = Objective.__call
Quest.IsQuest = true

local function objCanceled(obj, player)
	obj:Disconnect(player)
	
	local self = _parent[obj]
	
	local children = _children[self]
	local complete = _complete[self][player]
	
	local index = _index[obj]
	
	if not complete then
		return
	end
	
	obj:OnCancel(obj, player)
	
	if self.IsAny then
		complete[index] = true
		
		for i, obj in children do
			if not complete[i] then
				self:OnProgress(player, index)
				
				return
			end
		end
	end
	
	self:Cancel(player)
end

local function objComplete(obj, player)
	obj:Disconnect(player)
	
	local index = _index[obj]
	local parent = _parent[obj]
	
	local children = _children[parent]
	local complete = _complete[parent][player]
	
	obj:OnComplete(player)
	
	if parent.IsAny then
		parent:Complete(player)
		
		return
	end
	
	complete[index] = true
	
	obj:Disconnect(player)
	
	if parent.IsAll or parent.IsNone then
		for i, o in children do
			if not(complete[i] or o.IsNone) then
				parent:OnProgress(player, index)
				
				return
			end
		end
		
		return parent:Complete(player)
	end
	
	-- Questline only
	parent:SetProgress(player, index)
	
	local nextObj = children[index + 1]
	
	if nextObj then
		parent:OnProgress(player, index)
		
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
	
	self:Disconnect(player)
	
	local children = _children[self]
	local complete = _complete[self]
	
	local startIndex, endIndex
	
	if self.IsAll or self.IsAny or self.IsNone then
		startIndex = 1
		endIndex = #children
	else
		self:SetProgress(player, progress)
		
		startIndex = progress + 1
		endIndex = startIndex
	end
	
	complete[player] = {}
	
	self:OnAssign(player, progress)
	
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
