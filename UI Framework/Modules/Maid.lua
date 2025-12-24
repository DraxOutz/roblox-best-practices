--!strict
-- Maid.lua
-- Gerencia cleanup de tasks: eventos, tweens e Instâncias
local Maid = {}
Maid.__index = Maid

-- Tipagem
export type Maid = {
	Tasks: {any},                               -- lista de tarefas gerenciadas
	Give: (self: Maid, task: any) -> (),        -- adiciona uma task
	DoCleaning: (self: Maid) -> (),            -- limpa todas as tasks
}

-- Cria uma nova instância de Maid
-- @return uma instância limpa de Maid
function Maid.new(): Maid
	return setmetatable({ Tasks = {} }, Maid)
end

-- Adiciona uma task para o Maid gerenciar
-- Task pode ser:
--  - RBXScriptConnection (eventos)
--  - Instância do Roblox (GUI, objetos do jogo)
--  - Qualquer objeto que precise de cleanup manual
-- @param task qualquer objeto gerenciável
function Maid:Give(task: any)
	if task ~= nil then
		table.insert(self.Tasks, task)
	end
end

-- Limpa todas as tasks gerenciadas pelo Maid
-- Desconecta eventos, destrói instâncias e reseta a lista
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
	-- Reseta a lista de tasks após limpeza
	self.Tasks = {}
end

-- Exemplo de uso:
-- local maid = Maid.new()
-- local conn = someEvent:Connect(function() print("Evento") end)
-- maid:Give(conn)
-- maid:DoCleaning() -- desconecta e limpa tudo

return Maid

