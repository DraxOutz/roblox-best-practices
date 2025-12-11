--!strict
local MemoryManager = require(script.Parent:WaitForChild("MemoryManager"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local NetworkManager = {}
NetworkManager.__index = NetworkManager

export type Callback = (player: Player, ...any) -> ()

type NetworkManagerType = {
    _events: { [string]: RemoteEvent }
}

function NetworkManager.new()
    local self: NetworkManagerType = setmetatable({}, NetworkManager) :: any
    self._events = {}
    return self
end

-- Registrar RemoteEvent
function NetworkManager:RegisterEvent(name: string, event: RemoteEvent)
    if self._events[name] then
        ConsoleReporter:SendMessage("NetworkManager", "Evento já registrado: " .. name, "Warn")
        return
    end
    self._events[name] = event
end

-- Conectar listener
function NetworkManager:Connect(name: string, callback: Callback)
    local event = self._events[name]
    if not event then
        ConsoleReporter:SendMessage("NetworkManager", "Evento não encontrado: " .. name, "Warn")
        return nil
    end
    local conn = event.OnServerEvent:Connect(callback)
    return conn
end

-- Disparar evento para cliente específico
function NetworkManager:FireClient(name: string, player: Player, ...: any)
    local event = self._events[name]
    if not event then
        ConsoleReporter:SendMessage("NetworkManager", "Evento não encontrado: " .. name, "Warn")
        return
    end
    event:FireClient(player,...)
end

-- Disparar evento para todos os clientes
function NetworkManager:FireAllClients(name: string, ...: any)
    local event = self._events[name]
    if not event then
        ConsoleReporter:SendMessage("NetworkManager", "Evento não encontrado: " .. name, "Warn")
        return
    end
    event:FireAllClients(...)
end

return NetworkManager

