export type Class = {
	all: (...Objective) -> Objective,
	any: (...Objective) -> Objective,
	none: (...Objective) -> Objective,
	
	click: (target:BasePart|Model) -> Objective,
	event: (event:RBXScriptSignal) -> Objective,
	--quest: (questId:string) -> Objective,
	score: (leaderstat:string, targetValue:number) -> Objective,
	timer: (timeDelay:number) -> Objective,
	touch: (touchPart:BasePart) -> Objective,
	value: (playerstat:string, targetValue:number) -> Objective
}

export type Object = {
	Cancel: (self:Objective, player:Player) -> (),
	Complete: (self:Objective, player:Player) -> (),
	
	Connect: (self:Objective, player:Player) -> (),
	Disconnect: (self:Objective, player:Player) -> (),
	
	--Destroy: (self:Objective) -> (),
	
	IsConnected: (self:Objective, player:Player) -> boolean,
	
	OnAssign: (self:Objective, player:Player) -> (),
	OnCancel: (self:Objective, player:Player) -> (),
	OnComplete: (self:Objective, player:Player) -> (),
	OnProgress: (self:Objective, player:Player, index:number) -> ()
}

export type Objective = typeof(setmetatable({}::Object, {}::Class))

local Objective = { __index = {} }::Objective
local prototype = Objective.__index

local QuestType = {
	all = "IsAll",
	any = "IsAny",
	none = "IsNone"
}

function Objective.__call(class, ...)
	local self = {}
	
	setmetatable(self, class)
	
	self:new(...)
	
	return self
end

function prototype:Cancel(player)
	self:Disconnect(player)
	
	self:OnCancel(player)
end

function prototype:Complete(player)
	self:Disconnect(player)
	
	self:OnComplete(player)
end

function prototype:Connect(player, progress)
	self:Disconnect(player)
	
	task.defer(self.OnAssign, self, player, progress)
end

function prototype:Destroy() end

function prototype:Disconnect(player) end


function prototype:OnAssign(player) end

function prototype:OnCancel(player) end

function prototype:OnComplete(player) end


setmetatable(Objective, {
	__index = function (Objective, index)
		local mod
		
		if QuestType[index] then
			mod = { [QuestType[index]] = true }
			
			mod.__index = setmetatable(mod, Objective.quest)
		else
			local src = script[index]
			
			if not src then
				error(`Objective {index} not found.`)
			end
			
			mod = require(src)
			
			mod.__index = setmetatable(mod, Objective)
		end
		
		Objective[index] = mod
		
		return mod
	end,
	
	__tostring = function ()
		return "Objective"
	end
})

return Objective
