--!strict
local Guard = require(script.Parent:WaitForChild("GuardClause"))
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local ConfigManager = {}
ConfigManager.__index = ConfigManager

export type ConfigTable = { [string]: any }

local globalConfig: ConfigTable = {}             -- configs globais
local playerConfig: { [number]: ConfigTable } = {} -- configs por player (Player.UserId como key)

function ConfigManager.new()
	local self = setmetatable({}, ConfigManager)
	return self
end

-- Set global config
function ConfigManager:SetGlobal(key: string, value: any)
	if not Guard:IsValid(key, "string") then
		ConsoleReporter:SendMessage("ConfigManager", "[SetGlobal] Key inválida", "Warn")
		return
	end
	globalConfig[key] = value
end

-- Get global config
function ConfigManager:GetGlobal(key: string): any
	return globalConfig[key]
end

-- Set config para player
function ConfigManager:SetPlayer(player: Player, key: string, value: any)
	if not Guard:IsValid(player, "Instance") or not player:IsA("Player") then
		ConsoleReporter:SendMessage("ConfigManager", "[SetPlayer] Player inválido", "Warn")
		return
	end
	if not Guard:IsValid(key, "string") then
		ConsoleReporter:SendMessage("ConfigManager", "[SetPlayer] Key inválida", "Warn")
		return
	end
	if not playerConfig[player.UserId] then
		playerConfig[player.UserId] = {}
	end
	playerConfig[player.UserId][key] = value
end

-- Get config de player
function ConfigManager:GetPlayer(player: Player, key: string): any
	if not playerConfig[player.UserId] then return nil end
	return playerConfig[player.UserId][key]
end

-- Limpa todas configs de um player
function ConfigManager:ClearPlayer(player: Player)
	playerConfig[player.UserId] = nil
end

-- Get total de configs globais
function ConfigManager:GetGlobalCount(): number
	local count = 0
	for _ in globalConfig do
		count += 1
	end
	return count
end

return ConfigManager
