--!strict
-- Network.lua
-- @module Network
-- @desc Suporte completo a RemoteEvent, RemoteFunction, BindableEvent e BindableFunction
--       Com validação automática de argumentos, proteção real, gerenciamento de listeners e debug opcional.
-- v1.2

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
	self.Contracts = {} :: { [string]: {string} } -- tabela de tipos esperados por remote
	self.Debug = debugMode or false
	return self
end

-- Função interna: valida argumentos automaticamente
local function validateArgs(expected: {string}, actual: {any})
	for i, t in expected do
		if typeof(actual[i]) ~= t then
			return false, ("[Network] Argumento %d esperado %s, mas recebeu %s"):format(i, t, typeof(actual[i]))
		end
	end
	return true
end

-- Função interna: chamada segura
local function safeCall(func: Callback, ...)
	local success, result = pcall(func, ...)
	if not success then
		warn(("[Network] Erro na chamada segura: %s"):format(result))
		return nil
	end
	return result
end

-- Fire/Invoke qualquer Remote ou Bindable com validação automática
function Network:Fire(name: string, ...: any): any
	local remote = self.Remotes[name]
	if not remote then
		warn(("[Network] Remote/Bindable '%s' não encontrado!"):format(name))
		return
	end

	-- validação automática
	if self.Contracts[name] then
		local valid, err = validateArgs(self.Contracts[name], {...})
		if not valid then
			warn(err)
			return
		end
	end

	if remote:IsA("RemoteEvent") or remote:IsA("BindableEvent") then
		safeCall(function()
			if remote.FireServer then
				remote:FireServer(...)
			else
				remote:Fire(...)
			end
		end)
		if self.Debug then
			print(("[Network] Disparado Event '%s'"):format(name))
		end
	elseif remote:IsA("RemoteFunction") or remote:IsA("BindableFunction") then
		local result
		result = safeCall(function()
			if remote.InvokeServer then
				return remote:InvokeServer(...)
			else
				return remote:Invoke(...)
			end
		end)
		if self.Debug then
			print(("[Network] Invocado Function '%s', resultado: %s"):format(name, tostring(result)))
		end
		return result
	else
		warn(("[Network] Remote/Bindable '%s' inválido!"):format(name))
	end
end

-- Listen com validação automática
function Network:Listen(name: string, callback: Callback)
	local remote = self.Remotes[name]
	if not remote then
		warn(("[Network] Remote/Bindable '%s' não encontrado!"):format(name))
		return nil
	end

	local wrapper = function(...)
		-- validação automática
		if self.Contracts[name] then
			local valid, err = validateArgs(self.Contracts[name], {...})
			if not valid then
				warn(err)
				return
			end
		end
		return safeCall(callback, ...)
	end

	if remote:IsA("RemoteEvent") or remote:IsA("BindableEvent") then
		local conn = remote.Event:Connect(wrapper)
		self.Listeners[name] = self.Listeners[name] or {}
		table.insert(self.Listeners[name], conn)
		return conn
	elseif remote:IsA("RemoteFunction") or remote:IsA("BindableFunction") then
		remote.OnClientInvoke = wrapper
	else
		warn(("[Network] Remote/Bindable '%s' inválido!"):format(name))
	end
end

-- Registrar tipos esperados para cada remote (contrato)
function Network:SetContract(name: string, types: {string})
	self.Contracts[name] = types
	if self.Debug then
		print(("[Network] Contrato definido para '%s': %s"):format(name, table.concat(types, ", ")))
	end
end

-- Gerenciamento de listeners
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

function Network:DisconnectAll()
	for name, _ in self.Listeners do
		self:Disconnect(name)
	end
end

-- Registrar / remover remote/bindable
function Network:Register(name: string, remote: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction)
	self.Remotes[name] = remote
	if self.Debug then
		print(("[Network] Registrado '%s'"):format(name))
	end
end

function Network:Unregister(name: string)
	self:Disconnect(name)
	self.Remotes[name] = nil
	if self.Debug then
		print(("[Network] Removido '%s'"):format(name))
	end
end

return Network
