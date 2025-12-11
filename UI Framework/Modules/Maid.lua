--!strict


local Maid = {}
Maid.__index = Maid

export type Maid = {
	Tasks: {any},
	Give: (self: Maid, task: any) -> (),
	DoCleaning: (self: Maid) -> (),
}

-- Cria uma nova instância de Maid
function Maid.new(): Maid
	return setmetatable({
		Tasks = {}
	}, Maid)
end

-- Adiciona uma tarefa para o Maid gerenciar
function Maid:Give(task: any): ()
	table.insert(self.Tasks, task)
end

-- Limpa todas as tarefas gerenciadas pelo Maid
function Maid:DoCleaning(): ()
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
