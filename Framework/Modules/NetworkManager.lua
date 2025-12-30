--!strict
-- NetworkManager.lua
-- Gerencia RemoteEvents de forma segura, modular e rastreável.

local MemoryManager = require(script.Parent:WaitForChild("MemoryManager"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local NetworkManager = {}
NetworkManager.__index = NetworkManager

export type Callback = (player: Player, ...any) -> ()

type NetworkManagerType = {
    _events: { [string]: RemoteEvent },
    _connections: { [string]: { RBXScriptConnection } }
}

-- Cria nova instância
function NetworkManager.new(): NetworkManagerType
    local self: NetworkManagerType = setmetatable({
        _events = {},
        _connections = {}
    }, NetworkManager) :: any
    return self
end

-- Registrar RemoteEvent (só 1 por nome)
function NetworkManager:RegisterEvent(name: string, event: RemoteEvent)
    if not name or not event then
        ConsoleReporter:SendMessage("NetworkManager", "Registro inválido", "Warn")
        return
    end
    if self._events[name] then
        ConsoleReporter:SendMessage("NetworkManager", "Evento já registrado: " .. name, "Warn")
        return
    end
    self._events[name] = event
    self._connections[name] = {}
end

-- Conectar listener (server-side)
-- Retorna RBXScriptConnection gerenciável
function NetworkManager:Connect(name: string, callback: Callback): RBXScriptConnection?
    local event = self._events[name]
    if not event then
        ConsoleReporter:SendMessage("NetworkManager", "Evento não encontrado: " .. name, "Warn")
        return nil
    end
    local conn = event.OnServerEvent:Connect(callback)
    table.insert(self._connections[name], conn)
    return conn
end

-- Desconectar todos listeners de um evento específico
function NetworkManager:DisconnectAll(name: string)
    local conns = self._connections[name]
    if not conns then return end
    for _, conn in ipairs(conns) do
        conn:Disconnect()
    end
    self._connections[name] = {}
end

-- Disparar evento para cliente específico
function NetworkManager:FireClient(name: string, player: Player, ...: any)
    local event = self._events[name]
    if not event then
        ConsoleReporter:SendMessage("NetworkManager", "Evento não encontrado: " .. name, "Warn")
        return
    end
    event:FireClient(player, ...)
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

-- Cleanup completo de todos eventos e conexões
function NetworkManager:Cleanup()
    for name, conns in self._connections do
        for _, conn in ipairs(conns) do
            conn:Disconnect()
        end
        self._connections[name] = {}
    end
    self._events = {}
end

return NetworkManager
