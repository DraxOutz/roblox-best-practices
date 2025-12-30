--!strict
-- Network.lua
-- @module Network
-- @desc Gerencia RemoteEvents do lado cliente de forma modular e segura
--       Permite enviar e receber eventos com verificação de tipos e proteção contra erros

local Network = {}
Network.__index = Network

-- Tipos
-- @type RemoteMap
-- @desc Mapeamento de nomes de RemoteEvents
export type RemoteMap = { [string]: RemoteEvent }

-- @type NetworkType
-- @desc Instância da Network
export type NetworkType = typeof(Network.new({}))

-- @desc Cria uma nova instância de Network
-- @param remotes tabela de RemoteEvents existentes no cliente
-- @return instância da Network
function Network.new(remotes: RemoteMap?): NetworkType
	local self = setmetatable({}, Network)
	self.Remotes = remotes or {}
	return self
end

-- @desc Dispara um RemoteEvent para o servidor
-- @param name nome do RemoteEvent
-- @param ... argumentos a serem enviados
function Network:Fire(name: string, ...: any)
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	else
		warn(("[Network] Remote '%s' não encontrado ou inválido"):format(name))
	end
end

-- @desc Conecta a um RemoteEvent do servidor
-- @param name nome do RemoteEvent
-- @param callback função a ser chamada ao receber o evento
-- @return RBXScriptConnection? conexão para permitir desconexão futura
function Network:Listen(name: string, callback: (...any) -> ()): RBXScriptConnection?
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		return remote.OnClientEvent:Connect(callback)
	else
		warn(("[Network] Remote '%s' não encontrado ou inválido"):format(name))
		return nil
	end
end

-- Exemplo de uso:
-- local net = Network.new({Ping = ReplicatedStorage.Remotes.Ping})
-- net:Listen("Ping", function(msg) print(msg) end)
-- net:Fire("Ping", "Olá server!")

return Network
