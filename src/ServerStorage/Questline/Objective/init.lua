local Objective = {
	__index = {}
}

local prototype = Objective.__index

local _abort = {}
local _assign = {}
local _cancel = {}
local _complete = {}

local _connected = {}

function Objective.new(class, ...)
	local abort = Instance.new("BindableEvent")
	local assign = Instance.new("BindableEvent")
	local cancel = Instance.new("BindableEvent")
	local complete = Instance.new("BindableEvent")
	
	local self = setmetatable({
		OnAbort = abort.Event,
		OnAssign = assign.Event,
		OnCancel = cancel.Event,
		OnComplete = complete.Event
	}, class)
	
	_abort[self] = abort
	_assign[self] = assign
	_cancel[self] = cancel
	_complete[self] = complete
	
	_connected[self] = {}
	
	self:new(...)
	
	return self
end

function prototype:Abort(player)
	local connected = _connected[self]
	
	if not connected[player] then
		return
	end
	
	_abort[self]:Fire(player)
	
	for event, conn in connected[player] do
		if conn.Connected then
			conn:Disconnect()
		end
		
		connected[player][event] = nil
	end
	
	connected[player] = nil
end

function prototype:Assign(player)
	_connected[self][player] = {}
	
	_assign[self]:Fire(player)
end

function prototype:Cancel(player)
	_cancel[self]:Fire(player)
	
	self:Abort(player)
end

function prototype:Complete(player)
	_complete[self]:Fire(player)
	
	self:Abort(player)
end

function prototype:Connect(player, event, callback)
	local connected = _connected[self]
	
	self:Disconnect(player, event)
	
	connected[player][event] = event:Connect(callback)
end

function prototype:Disconnect(player, event)
	local connected = _connected[self]
	
	if not connected[player] then
		return warn(`{player} not connected.`)
	end
	
	local conn
	
	for i, e in connected[player] do
		if i == event then
			conn = e
			connected[player][i] = nil
			break
		end
	end
	
	if not conn then
		return --warn(`{event} not connected.`)
	end
	
	if conn.Connected then
		conn:Disconnect()
	end
end

function prototype:Destroy()
	local connected = _connected[self]
	
	if not connected then
		error("Objective is already destroyed.")
	end
	
	for player in connected do
		self:Abort(player)
	end
	
	_abort[self], _assign[self], _cancel[self], _complete[self], _connected[self] = nil
end

function prototype:IsConnected(player)
	return _connected[self][player] ~= nil
end

local QuestType = {
	all = "IsAll",
	any = "IsAny",
	none = "IsNone"
}

setmetatable(Objective, {
	__index = function (self, index)
		local mod
			
		if QuestType[index] then
			mod = {
				__index = setmetatable({ [QuestType[index]] = true }, self.quest),
				__tostring = function (self)
					local tbl = {}
					
					for _, child in self.Children do
						table.insert(tbl, tostring(child))
					end
					
					return `{index}({table.concat(tbl, ", ")})`
				end
			}
		else
			local src = script[index]
			
			if not src then
				error(`Objective {index} not found.`)
			end
			
			mod = require(src)
		end
		
		rawset(self, index, mod)
		
		setmetatable(mod, {
			__call = self.new,
			__tostring = function ()
				return index
			end
		})
		
		return mod
	end,
	
	__tostring = function ()
		return "Objective"
	end
})

return Objective
