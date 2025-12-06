--!strict
local Guard = require(script.Parent:WaitForChild("GuardClause"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local ResourceManager = {}
ResourceManager.__index = ResourceManager

export type ResourceTable = { [string]: Instance }

local resources: ResourceTable = {}

function ResourceManager.new()
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
	resources[key] = obj
end

-- Pegar um asset registrado
function ResourceManager:Get(key: string): Instance?
	if not resources[key] then
		ConsoleReporter:SendMessage("ResourceManager", "[Get] Asset não encontrado: " .. key, "Warn")
		return nil
	end
	return resources[key]
end

-- Remover um asset registrado
function ResourceManager:Remove(key: string)
	if resources[key] then
		resources[key] = nil
	end
end

-- Limpar todos assets
function ResourceManager:ClearAll()
	resources = {}
	ConsoleReporter:SendMessage("ResourceManager", "Todos assets limpos", "Warn")
end

return ResourceManager
