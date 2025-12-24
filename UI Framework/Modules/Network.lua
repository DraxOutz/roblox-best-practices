--!strict
-- Network.lua
-- Gerencia remotes do lado cliente (Network Layer)
-- Responsável por enviar e receber RemoteEvents de forma modular e segura

local Network = {}
Network.__index = Network

-- Tipos
export type RemoteMap = { [string]: RemoteEvent }
export type NetworkType = typeof(Network.new({}))

-- Cria uma nova instância da Network
-- @param remotes: tabela de RemoteEvents existentes no cliente
-- @return instância da Network
function Network.new(remotes: RemoteMap?): NetworkType
	local self = setmetatable({}, Network)
	self.Remotes = remotes or {}
	return self
end

-- Dispara um RemoteEvent para o server
-- @param name: nome do remote
-- @param ...: argumentos para enviar
function Network:Fire(name: string, ...: any)
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	else
		warn(("Network: Remote '%s' não encontrado ou inválido"):format(name))
	end
end

-- Conecta a um RemoteEvent do server
-- @param name: nome do remote
-- @param callback: função que será chamada ao receber o evento
-- @return RBXScriptConnection? conexão para permitir desconexão futura
function Network:Listen(name: string, callback: (...any) -> ()): RBXScriptConnection?
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		return remote.OnClientEvent:Connect(callback)
	else
		warn(("Network: Remote '%s' não encontrado ou inválido"):format(name))
		return nil
	end
end

-- Exemplo de uso:
-- local net = Network.new({Ping = ReplicatedStorage.Remotes.Ping})
-- net:Listen("Ping", function(msg) print(msg) end)
-- net:Fire("Ping", "Olá server!")

return Network
