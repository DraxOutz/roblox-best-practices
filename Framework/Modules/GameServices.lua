--!strict
-- GameServices.lua
-- Centraliza todos os serviços utilitários do framework

local GameServices = {}
GameServices.__index = GameServices

-- Tipagem
export type ServiceTable = {
	ConsoleReporter: typeof(require(script.Parent:WaitForChild("ConsoleReporter"))),
	MemoryManager: typeof(require(script.Parent:WaitForChild("MemoryManager"))),
	GuardClause: typeof(require(script.Parent:WaitForChild("GuardClause"))),
	ConfigManager: typeof(require(script.Parent:WaitForChild("ConfigManager"))),
}

-- @desc Instância única de services, com carregamento imediato e seguro
GameServices.Services: ServiceTable = {
	ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter")),
	MemoryManager  = require(script.Parent:WaitForChild("MemoryManager")),
	GuardClause    = require(script.Parent:WaitForChild("GuardClause")),
	ConfigManager  = require(script.Parent:WaitForChild("ConfigManager")),
}

-- @desc Permite acessar serviços de forma tipada
function GameServices:GetService<T>(name: string): T?
	return self.Services[name] :: T?
end

-- @desc Permite reatribuir um service (somente se realmente necessário)
function GameServices:SetService(name: string, service: any)
	self.Services[name] = service
end

return GameServices
