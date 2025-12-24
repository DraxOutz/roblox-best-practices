--!strict
-- Gerencia cleanup de tasks (events, tweens, instances)
local Maid = {}
Maid.__index = Maid

export type Maid = {
	Tasks: {any},
	Give: (self: Maid, task: any) -> (),
	DoCleaning: (self: Maid) -> (),
}

function Maid.new(): Maid
	return setmetatable({ Tasks = {} }, Maid)
end

function Maid:Give(task: any)
	if task then
		table.insert(self.Tasks, task)
	end
end

function Maid:DoCleaning()
	for _, task in ipairs(self.Tasks) do
		if typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "Instance" then
			task:Destroy()
		end
	end
	self.Tasks = {}
end

return Maid
