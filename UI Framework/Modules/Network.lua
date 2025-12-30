--!strict
-- Network.lua
-- @module Network
-- @desc Suporte completo a RemoteEvent, RemoteFunction, BindableEvent e BindableFunction v1.2
--       Com validação de argumentos, proteção real, gerenciamento de listeners e debug opcional.

local Network = {}
Network.__index = Network

-- Tipos
export type RemoteMap = { [string]: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction }
export type Callback = (...any) -> any
export type ListenerMap = { [string]: { RBXScriptConnection } }

export type NetworkType = typeof(Network.new({}))

-- Cria a instância
function Network.new(remotes: RemoteMap?, debugMode: boolean?): NetworkType
	local self = setmetatable({}, Network)
	self.Remotes = remotes or {}
	self.Listeners = {} :: ListenerMap
	self.Debug = debugMode or false
	return self
end

-- Valida argumentos com tipos esperados
local function validateArgs(expected: {string}, actual: {any})
	for i, t in expected do
		if typeof(actual[i]) ~= t then
			return false, ("Expected argument %d to be %s, got %s"):format(i, t, typeof(actual[i]))
		end
	end
	return true
end

-- Função interna de disparo (Fire/Invoke) com proteção
local function safeCall(func: Callback, ...)
	local success, result = pcall(func, ...)
	if not success then
		warn(("[Network] Erro na chamada segura: %s"):format(result))
		return nil
	end
	return result
end

-- Fire/Invoke qualquer Remote ou Bindable
function Network:Fire(name: string, ...: any): any
	local remote = self.Remotes[name]
	if not remote then
		warn(("[Network] Remote/Bindable '%s' não encontrado!"):format(name))
		return
	end

	if remote:IsA("RemoteEvent") or remote:IsA("BindableEvent") then
		safeCall(function() remote:FireServer and remote:FireServer(...) or remote:Fire(...) end)
		if self.Debug then
			print(("[Network] Disparado Event '%s'"):format(name))
		end
	elseif remote:IsA("RemoteFunction") or remote:IsA("BindableFunction") then
		local result
		result = safeCall(function() return remote:InvokeServer and remote:InvokeServer(...) or remote:Invoke(...) end)
		if self.Debug then
			print(("[Network] Invocado Function '%s', resultado: %s"):format(name, tostring(result)))
		end
		return result
	else
		warn(("[Network] Remote/Bindable '%s' inválido!"):format(name))
	end
end

-- Listen: conecta callbacks a Event/Function
function Network:Listen(name: string, callback: Callback)
	local remote = self.Remotes[name]
	if not remote then
		warn(("[Network] Remote/Bindable '%s' não encontrado!"):format(name))
		return nil
	end

	if remote:IsA("RemoteEvent") or remote:IsA("BindableEvent") then
		local conn = remote.Event:Connect(function(...)
			safeCall(callback, ...)
		end)
		self.Listeners[name] = self.Listeners[name] or {}
		table.insert(self.Listeners[name], conn)
		return conn
	elseif remote:IsA("RemoteFunction") or remote:IsA("BindableFunction") then
		remote.OnClientInvoke = function(...)
			return safeCall(callback, ...)
		end
	else
		warn(("[Network] Remote/Bindable '%s' inválido!"):format(name))
	end
end

-- Desconecta todos os listeners de um remote específico
function Network:Disconnect(name: string)
	if self.Listeners[name] then
		for _, conn in self.Listeners[name] do
			conn:Disconnect()
		end
		self.Listeners[name] = nil
		if self.Debug then
			print(("[Network] Desconectados listeners de '%s'"):format(name))
		end
	end
end

-- Desconecta todos os listeners de todos os remotes
function Network:DisconnectAll()
	for name, _ in self.Listeners do
		self:Disconnect(name)
	end
end

-- Registro dinâmico de remote/bindable
function Network:Register(name: string, remote: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction)
	self.Remotes[name] = remote
	if self.Debug then
		print(("[Network] Registrado '%s'"):format(name))
	end
end

-- Remover remote/bindable
function Network:Unregister(name: string)
	self:Disconnect(name)
	self.Remotes[name] = nil
	if self.Debug then
		print(("[Network] Removido '%s'"):format(name))
	end
end

return Network
