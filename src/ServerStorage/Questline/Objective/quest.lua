local Objective = require(script.Parent)

local Quest = { __index = setmetatable({}, Objective) }
local prototype = Quest.__index
local super = Objective.__index

local _children = {}
local _complete = {}
local _progress = {}

prototype.IsQuest = true

function prototype:new(...)
	local progress = Instance.new("BindableEvent")
	
	_children[self] = {...}
	_progress[self] = progress
	
	_complete[self] = {}
	
	self.OnProgress = progress.Event
end

function prototype:Abort(player)
	super.Abort(self, player)
	
	local complete = _complete[self][player]
	
	if complete then
		complete[self][player] = nil
		
		table.clear(complete)
	end
end

function prototype:AddObjective(obj)
	table.insert(_children[self], obj)
end

function prototype:Assign(player, parent)
	local target = parent or self
	
	super.Assign(self, player)
	
	local children = _children[self]
	local complete = {}
	
	_complete[self] = complete
	
	local startIndex, endIndex
	
	local function objCancel(obj, index)
		if self.IsAny then
			complete[index] = true
			
			target:Disconnect(player, obj.OnCancel)
			target:Disconnect(player, obj.OnComplete)
			
			for i, obj in children do
				if not complete[i] then return end
			end
		end
		
		self:Cancel(player)
	end
	
	local function objComplete(obj, index)
		_progress[self]:Fire(player, index)
		
		if self.IsAny then return self:Complete(player) end
		
		complete[index] = true
		
		target:Disconnect(player, obj.OnCancel)
		target:Disconnect(player, obj.OnComplete)
		
		if self.IsAll or self.IsNone then
			for i, obj in children do
				if not(complete[i] or obj.IsNone) then return end
			end
			
			return self:Complete(player)
		end
		
		local nextObj = children[index + 1]
		
		if not nextObj then
			return self:Complete(player)
		end
		
		--_progress[self][player] = index
		
		target:Connect(player, nextObj.OnCancel, function (plr) if plr == player then objCancel(nextObj, index + 1) end end)
		target:Connect(player, nextObj.OnComplete, function (plr) if plr == player then objComplete(nextObj, index + 1) end end)
		
		nextObj:Assign(player, target)
	end
	
	if self.IsAll or self.IsAny or self.IsNone then
		startIndex = 1
		endIndex = #children
		
		if self.IsNone then
			objCancel, objComplete = objComplete, objCancel
		end
	else
		startIndex = self:GetProgress(player) + 1
		endIndex = startIndex
	end
	
	for i = startIndex, endIndex do
		local obj = children[i]
		
		target:Connect(player, obj.OnCancel, function (plr) if plr == player then objCancel(obj, i) end end)
		target:Connect(player, obj.OnComplete, function (plr) if plr == player then objComplete(obj, i) end end)
		
		obj:Assign(player, target)
	end
end

function prototype:Destroy()
	
end

function prototype:GetObjectiveAt(index)
	return _children[self][index]
end

function prototype:GetObjectiveCount()
	return #_children[self]
end

return Quest
