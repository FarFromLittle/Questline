local Objective = setmetatable({ __index = {} }, {
	__index = function (self, name)
		local src = script:FindFirstChild(name)
		
		if not src then error("Objective not found.") end
		
		local mod = require(src)
		
		self[name] = setmetatable(mod, {
			__call = mod.new
		})
		
		return mod
	end
})

local prototype = Objective.__index

function Objective.new(class, o)
	local self = setmetatable(o or {}, class)
	
	self.Connected = {}
	
	return self
end

function prototype:Assign(player)
	self:Disconnect(player)
	self.Connected[player] = {}
	self:OnAssign(player)
end

function prototype:Cancel(player)
	self:Disconnect(player)
	self:OnCancel(player)
end

function prototype:Complete(player)
	self:Disconnect(player)
	self:OnComplete(player)
end

function prototype:Disconnect(player)
	local connected = self.Connected[player]
	
	if not connected then return end
	
	for _, conn in connected do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	
	self.Connected[player] = nil
end

function prototype:IsConnected(player)
	return self.Connected[player] ~= nil
end

function prototype:OnAssign(player) end

function prototype:OnCancel(player) end

function prototype:OnComplete(player) end

return Objective
