--!strict
local MemoryManager = require(script.Parent:WaitForChild("MemoryManager"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local EventManager = {}
EventManager.__index = EventManager

export type Callback = (...any) -> ()

-- Tabela de eventos
local events: { [string]: {Callback} } = {}

-- Cria nova instância
function EventManager.new()
	local self = setmetatable({}, EventManager)
	return self
end

-- Conectar callback a um evento
function EventManager:Connect(eventName: string, callback: Callback)
	if not events[eventName] then
		events[eventName] = {}
	end
	table.insert(events[eventName], callback)

	-- Retorna função de desconexão (pode registrar no MemoryManager)
	local function disconnect()
		for i, cb in events[eventName] do
			if cb == callback then
				table.remove(events[eventName], i)
				ConsoleReporter:SendMessage("EventManager", "Callback desconectado do evento: " .. eventName, "Warn")
				break
			end
		end
	end

	return disconnect
end

-- Disparar evento
function EventManager:Fire(eventName: string, ...: any)
	if not events[eventName] then return end
	for _, callback in events[eventName] do
		task.spawn(callback, ...) -- Spawn pra não travar o loop
	end
end

-- Limpar todos eventos
function EventManager:ClearAll()
	for eventName, _ in events do
		events[eventName] = {}
	end
	ConsoleReporter:SendMessage("EventManager", "Todos eventos limpos", "Warn")
end

return EventManager
