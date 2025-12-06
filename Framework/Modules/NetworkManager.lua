--!strict
local MemoryManager = require(script.Parent:WaitForChild("MemoryManager"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local NetworkManager = {}
NetworkManager.__index = NetworkManager

export type Callback = (...any) -> ()

local events: { [string]: RemoteEvent } = {}

function NetworkManager.new()
	local self = setmetatable({}, NetworkManager)
	return self
end

-- Registrar RemoteEvent
function NetworkManager:RegisterEvent(name: string, event: RemoteEvent)
	if events[name] then
		ConsoleReporter:SendMessage("NetworkManager", "Evento já registrado: " .. name, "Warn")
		return
	end
	events[name] = event
end

-- Conectar listener
function NetworkManager:Connect(name: string, callback: Callback)
	local event = events[name]
	if not event then
		ConsoleReporter:SendMessage("NetworkManager", "Evento não encontrado: " .. name, "Warn")
		return nil
	end
	local conn = event.OnServerEvent:Connect(callback)
	return conn
end

-- Disparar evento
function NetworkManager:Fire(name: string, player: Player?, ...: any)
	local event = events[name]
	if not event then
		ConsoleReporter:SendMessage("NetworkManager", "Evento não encontrado: " .. name, "Warn")
		return
	end
	event:FireServer(player, ...)
end

return NetworkManager
