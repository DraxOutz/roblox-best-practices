--!strict
-- ConfigManager.lua
-- Gerencia configs globais e por player de forma segura, modular e eficiente
-- Inclui eventos onChange, tipagem forte e integração Maid

local Maid = require(script.Parent:WaitForChild("Maid"))

local ConfigManager = {}
ConfigManager.__index = ConfigManager

-- Tipagem
export type ConfigTable = { [string]: any }
export type ConfigChangeCallback = (key: string, value: any) -> ()

-- Eventos onChange
local GlobalChangeEvent = Instance.new("BindableEvent") -- dispara quando uma config global muda
local PlayerChangeEvents: {[number]: BindableEvent} = {} -- dispara quando config de um player muda

-- Locks simples para concorrência
local GlobalLock = false
local PlayerLocks: {[number]: boolean} = {}

-- Configs armazenadas
local globalConfig: ConfigTable = {}
local playerConfig: {[number]: ConfigTable} = {}

-- Cria uma nova instância
function ConfigManager.new(): ConfigManager
	local self = setmetatable({}, ConfigManager)
	self.maid = Maid.new()
	return self
end

-- Função interna para garantir lock
local function withGlobalLock(fn: () -> ())
	while GlobalLock do task.wait() end
	GlobalLock = true
	fn()
	GlobalLock = false
end

local function withPlayerLock(userId: number, fn: () -> ())
	PlayerLocks[userId] = PlayerLocks[userId] or false
	while PlayerLocks[userId] do task.wait() end
	PlayerLocks[userId] = true
	fn()
	PlayerLocks[userId] = false
end

--[[ Global Configs ]]--

function ConfigManager:SetGlobal(key: string, value: any)
	assert(type(key) == "string" and key ~= "", "[ConfigManager] SetGlobal: Key inválida")
	withGlobalLock(function()
		globalConfig[key] = value
		GlobalChangeEvent:Fire(key, value)
	end)
end

function ConfigManager:GetGlobal(key: string): any
	return globalConfig[key]
end

function ConfigManager:ConnectGlobalChange(callback: ConfigChangeCallback)
	assert(type(callback) == "function", "[ConfigManager] ConnectGlobalChange: callback inválido")
	return GlobalChangeEvent.Event:Connect(callback)
end

function ConfigManager:GetGlobalCount(): number
	local count = 0
	for _ in globalConfig do
		count += 1
	end
	return count
end

--[[ Player Configs ]]--

function ConfigManager:SetPlayer(player: Player, key: string, value: any)
	assert(player and player:IsA("Player"), "[ConfigManager] SetPlayer: Player inválido")
	assert(type(key) == "string" and key ~= "", "[ConfigManager] SetPlayer: Key inválida")

	withPlayerLock(player.UserId, function()
		playerConfig[player.UserId] = playerConfig[player.UserId] or {}
		playerConfig[player.UserId][key] = value

		if not PlayerChangeEvents[player.UserId] then
			PlayerChangeEvents[player.UserId] = Instance.new("BindableEvent")
		end
		PlayerChangeEvents[player.UserId]:Fire(key, value)
	end)
end

function ConfigManager:GetPlayer(player: Player, key: string): any
	if not playerConfig[player.UserId] then return nil end
	return playerConfig[player.UserId][key]
end

function ConfigManager:ConnectPlayerChange(player: Player, callback: ConfigChangeCallback)
	assert(player and player:IsA("Player"), "[ConfigManager] ConnectPlayerChange: Player inválido")
	assert(type(callback) == "function", "[ConfigManager] ConnectPlayerChange: callback inválido")

	if not PlayerChangeEvents[player.UserId] then
		PlayerChangeEvents[player.UserId] = Instance.new("BindableEvent")
	end

	return PlayerChangeEvents[player.UserId].Event:Connect(callback)
end

function ConfigManager:ClearPlayer(player: Player)
	playerConfig[player.UserId] = nil
	if PlayerChangeEvents[player.UserId] then
		PlayerChangeEvents[player.UserId]:Destroy()
		PlayerChangeEvents[player.UserId] = nil
	end
end

return ConfigManager
