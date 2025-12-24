--!strict
-- Gerencia cleanup de tasks: eventos, tweens, Instâncias
local Maid = {}
Maid.__index = Maid

-- Tipagem
export type Maid = {
	Tasks: {any},                               -- lista de tarefas gerenciadas
	Give: (self: Maid, task: any) -> (),       -- adiciona uma task
	DoCleaning: (self: Maid) -> (),           -- limpa todas as tasks
}

-- Cria uma nova instância de Maid
function Maid.new(): Maid
	return setmetatable({ Tasks = {} }, Maid)
end

-- Adiciona uma task para o Maid gerenciar
function Maid:Give(task: any)
	if task ~= nil then
		table.insert(self.Tasks, task)
	end
end

-- Limpa todas as tasks gerenciadas pelo Maid
function Maid:DoCleaning()
	for _, task in ipairs(self.Tasks) do
		local taskType = typeof(task)
		if taskType == "RBXScriptConnection" then
			task:Disconnect()
		elseif taskType == "Instance" then
			if task.Parent then
				task:Destroy()
			end
		end
	end
	-- reseta lista
	self.Tasks = {}
end

return Maid
