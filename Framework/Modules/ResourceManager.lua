--!strict
-- ResourceManager.lua
-- Gerencia assets/Instâncias de forma segura e rastreável.

local Guard = require(script.Parent:WaitForChild("GuardClause"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local ResourceManager = {}
ResourceManager.__index = ResourceManager

export type ResourceTable = { [string]: Instance }

-- Armazena assets globalmente
local resources: ResourceTable = {}

-- Cria nova instância
function ResourceManager.new(): ResourceManager
	local self = setmetatable({}, ResourceManager)
	return self
end

-- Registrar um asset
function ResourceManager:Load(key: string, obj: Instance)
	if not Guard:IsValid(key, "string") then
		ConsoleReporter:SendMessage("ResourceManager", "[Load] Key inválida", "Warn")
		return
	end
	if not Guard:IsValid(obj, "Instance") then
		ConsoleReporter:SendMessage("ResourceManager", "[Load] Objeto inválido", "Warn")
		return
	end
	if resources[key] then
		ConsoleReporter:SendMessage("ResourceManager", "[Load] Asset sobrescrito: " .. key, "Warn")
	end
	resources[key] = obj
	ConsoleReporter:SendMessage("ResourceManager", "[Load] Asset registrado: " .. key, "Print")
end

-- Pegar um asset registrado
function ResourceManager:Get(key: string): Instance?
	if not Guard:IsValid(key, "string") then
		ConsoleReporter:SendMessage("ResourceManager", "[Get] Key inválida", "Warn")
		return nil
	end
	local obj = resources[key]
	if not obj then
		ConsoleReporter:SendMessage("ResourceManager", "[Get] Asset não encontrado: " .. key, "Warn")
	end
	return obj
end

-- Remover um asset registrado
function ResourceManager:Remove(key: string)
	if resources[key] then
		resources[key] = nil
		ConsoleReporter:SendMessage("ResourceManager", "[Remove] Asset removido: " .. key, "Print")
	end
end

-- Limpar todos assets
function ResourceManager:ClearAll()
	for k in pairs(resources) do
		resources[k] = nil
	end
	ConsoleReporter:SendMessage("ResourceManager", "Todos assets limpos", "Warn")
end

-- Checar existência de asset
function ResourceManager:Exists(key: string): boolean
	return resources[key] ~= nil
end

return ResourceManager
