--!strict
-- Gerencia remotes do lado cliente (Network Layer)
local Network = {}
Network.__index = Network

-- Tipos
export type RemoteMap = { [string]: RemoteEvent }
export type NetworkType = typeof(Network.new({}))

-- Cria uma nova instância da Network
function Network.new(remotes: RemoteMap?): NetworkType
	local self = setmetatable({}, Network)
	self.Remotes = remotes or {}
	return self
end

-- Dispara um RemoteEvent para o server
function Network:Fire(name: string, ...: any)
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	else
		warn(("Network: Remote '%s' não encontrado ou inválido"):format(name))
	end
end

-- Conecta a um RemoteEvent do server
function Network:Listen(name: string, callback: (...any) -> ()): RBXScriptConnection?
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		return remote.OnClientEvent:Connect(callback)
	else
		warn(("Network: Remote '%s' não encontrado ou inválido"):format(name))
		return nil
	end
end

return Network
