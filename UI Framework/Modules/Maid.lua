--!strict
-- Maid.lua
-- @module Maid
-- @desc Gerencia cleanup de tasks: eventos, tweens e Instâncias de forma segura e previsível

local Maid = {}
Maid.__index = Maid

-- Tipagem
-- @type Maid
-- @field Tasks lista de tarefas gerenciadas
-- @field Give adiciona uma task ao Maid
-- @field DoCleaning limpa todas as tasks gerenciadas
export type Maid = {
	Tasks: {any},
	Give: (self: Maid, task: any) -> (),
	DoCleaning: (self: Maid) -> (),
}

-- @desc Cria uma nova instância de Maid
-- @return nova instância de Maid
function Maid.new(): Maid
	return setmetatable({ Tasks = {} }, Maid)
end

-- @desc Adiciona uma task para o Maid gerenciar
-- @param task task gerenciável (RBXScriptConnection, Instance, ou outro objeto que precise de cleanup)
function Maid:Give(task: any)
	if task == nil then
		warn("[Maid] Tentativa de adicionar task inválida")
		return
	end
	table.insert(self.Tasks, task)
end

-- @desc Limpa todas as tasks gerenciadas
--       Desconecta eventos, destrói instâncias e reseta a lista
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
