--!strict
-- EventManager.lua
-- Sistema de eventos modular, seguro e totalmente gerenciável.
-- Suporta callbacks múltiplos, desconexão segura e integração com MemoryManager e ConsoleReporter.

local MemoryManager = require(script.Parent:WaitForChild("MemoryManager"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local EventManager = {}
EventManager.__index = EventManager

export type Callback = (...any) -> ()
export type EventManagerType = typeof(EventManager.new())

-- @desc Tabela de eventos por instância
local events: { [string]: {Callback} } = {}

-- Cria nova instância de EventManager
function EventManager.new(): EventManagerType
	local self = setmetatable({}, EventManager)
	self.Console = ConsoleReporter.new()
	return self
end

-- Conecta callback a um evento
-- @param eventName: string - nome do evento
-- @param callback: Callback - função a ser chamada ao disparar evento
-- @return function - função de desconexão segura
function EventManager:Connect(eventName: string, callback: Callback): () -> ()
	if not events[eventName] then
		events[eventName] = {}
	end
	table.insert(events[eventName], callback)

	local function disconnect()
		if not events[eventName] then return end
		for i, cb in ipairs(events[eventName]) do
			if cb == callback then
				table.remove(events[eventName], i)
				self.Console:SendMessage("EventManager", "Callback desconectado do evento: " .. eventName, "Print")
				break
			end
		end
	end

	-- Integra com MemoryManager para cleanup automático
	if MemoryManager then
		MemoryManager:Register(disconnect)
	end

	return disconnect
end

-- Dispara evento
-- @param eventName: string - nome do evento
-- @param ...: any - argumentos para callbacks
function EventManager:Fire(eventName: string, ...: any)
	if not events[eventName] then return end
	for _, callback in ipairs(events[eventName]) do
		task.spawn(callback, ...)
	end
end

-- Limpa todos os eventos
function EventManager:ClearAll()
	for eventName, _ in events do
		events[eventName] = {}
	end
	self.Console:SendMessage("EventManager", "Todos eventos limpos", "Print")
end

return EventManager
