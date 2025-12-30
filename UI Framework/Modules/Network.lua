--!strict
-- Network.lua
-- @module Network
-- @desc Suporte completo a RemoteEvent, RemoteFunction, BindableEvent e BindableFunction
--       Com validação automática de argumentos e retornos, proteção real, gerenciamento central de listeners,
--       versionamento de contratos e debug opcional.
-- v2.0

local Network = {}
Network.__index = Network

-- Tipos
export type RemoteMap = { [string]: RemoteEvent | RemoteFunction | BindableEvent | BindableFunction }
export type Callback = (...any) -> any
export type ListenerMap = { [string]: { RBXScriptConnection } }
export type Contract = { args: {string}, returns: {string}?, version: number? }

export type NetworkType = typeof(Network.new({}))

-- Cria a instância
function Network.new(remotes: RemoteMap?, debugMode: boolean?): NetworkType
	local self = setmetatable({}, Network)
	self.Remotes = remotes or {}
	self.Listeners = {} :: ListenerMap
	self.Contracts = {} :: { [string]: Contract } -- contratos completos por remote
	self.Debug = debugMode or false
	self.OnError = nil :: ((string, string) -> ())? -- callback global de erro opcional
	return self
end

-- Função interna: valida argumentos e retornos
local function validateArgs(expected: {string}, actual: {any})
	for i, t in expected do
		if typeof(actual[i]) ~= t then
			return false, ("[Network] Argumento %d esperado %s, mas recebeu %s"):format(i, t, typeof(actual[i]))
		end
	end
	return true
end

-- Função interna: chamada segura
local function safeCall(func: Callback, name: string, selfRef: NetworkType, ...)
	local success, result = pcall(func, ...)
	if not success then
		if selfRef.OnError then
			selfRef.OnError(name, result)
		else
			warn(("[Network] Erro na chamada segura '%s': %s"):format(name, result))
		end
		return nil
	end
	return result
end

-- Dispara / invoca qualquer Remote ou Bindable com validação e retorno
function Network:Fire(name: string, ...: any): any
	local remote = self.Remotes[name]
	if not remote then
		warn(("[Network] Remote/Bindable '%s' não encontrado!"):format(name))
		return
	end

	-- validação de argumentos
	local contract = self.Contracts[name]
	if contract and contract.args then
		local valid, err = validateArgs(contract.args, {...})
		if not valid then
			if self.Debug then warn(err) end
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
		end, name, self)
		if self.Debug then print(("[Network] Disparado Event '%s'"):format(name)) end
	elseif remote:IsA("RemoteFunction") or remote:IsA("BindableFunction") then
		local result = safeCall(function()
			if remote.InvokeServer then
				return remote:InvokeServer(...)
			else
				return remote:Invoke(...)
			end
		end, name, self)
		-- validação de retorno
		if contract and contract.returns then
			local valid, err = validateArgs(contract.returns, {result})
			if not valid then
				if self.Debug then warn(("[Network] Retorno inválido da Function '%s': %s"):format(name, err)) end
				return nil
			end
		end
		if self.Debug then print(("[Network] Invocado Function '%s', resultado: %s"):format(name, tostring(result))) end
		return result
	else
		warn(("[Network] Remote/Bindable '%s' inválido!"):format(name))
	end
end

-- Listen seguro com validação automática
function Network:Listen(name: string, callback: Callback)
	local remote = self.Remotes[name]
	if not remote then
		warn(("[Network] Remote/Bindable '%s' não encontrado!"):format(name))
		return nil
	end

	local wrapper = function(...)
		local contract = self.Contracts[name]
		-- validação de argumentos
		if contract and contract.args then
			local valid, err = validateArgs(contract.args, {...})
			if not valid then
				if self.Debug then warn(err) end
				return
			end
		end
		return safeCall(callback, name, self, ...)
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

-- Define contratos (argumentos e retornos) e versão opcional
function Network:SetContract(name: string, args: {string}, returns: {string}?, version: number?)
	self.Contracts[name] = {args=args, returns=returns, version=version}
	if self.Debug then
		print(("[Network] Contrato definido para '%s', versão: %s"):format(name, tostring(version or 1)))
	end
end

-- Listener management
function Network:Disconnect(name: string)
	if self.Listeners[name] then
		for _, conn in self.Listeners[name] do
			conn:Disconnect()
		end
		self.Listeners[name] = nil
		if self.Debug then print(("[Network] Desconectados listeners de '%s'"):format(name)) end
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
	if self.Debug then print(("[Network] Registrado '%s'"):format(name)) end
end

function Network:Unregister(name: string)
	self:Disconnect(name)
	self.Remotes[name] = nil
	if self.Debug then print(("[Network] Removido '%s'"):format(name)) end
end

-- Define callback global de erro
function Network:SetErrorCallback(func: (string, string) -> ())
	self.OnError = func
end

return Network
