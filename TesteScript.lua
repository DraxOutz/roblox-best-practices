--!strict

--Use the Framework on my github for better functioning
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Modules folder
local MODULES_FOLDER = ReplicatedStorage:FindFirstChild("Modules")
if not MODULES_FOLDER then
	MODULES_FOLDER = Instance.new("Folder")
	MODULES_FOLDER.Name = "Modules"
	MODULES_FOLDER.Parent = ReplicatedStorage
end

-- Require modules
local Guard = require(MODULES_FOLDER:WaitForChild("GuardClause"))
local GetAndSet = require(MODULES_FOLDER:WaitForChild("GetAndSet"))
local Encapsulation = require(MODULES_FOLDER:WaitForChild("Encapsulation"))
local Debounce = require(MODULES_FOLDER:WaitForChild("Debounce"))
local OOPVehicles = require(MODULES_FOLDER:WaitForChild("OOP_Vehicles"))
local GenericIter = require(MODULES_FOLDER:WaitForChild("GenericIteration"))
local GameSystem = require(MODULES_FOLDER:WaitForChild("GameSystemModule"))

-- Remote structure: two RemoteEvents under ReplicatedStorage.AnimeRemotes
local REMOTES = ReplicatedStorage:FindFirstChild("AnimeRemotes")
if not REMOTES then
	REMOTES = Instance.new("Folder")
	REMOTES.Name = "AnimeRemotes"
	REMOTES.Parent = ReplicatedStorage
end

local RemoteRequest = REMOTES:FindFirstChild("Request") or Instance.new("RemoteEvent")
RemoteRequest.Name = "Request"
RemoteRequest.Parent = REMOTES

local RemoteClient = REMOTES:FindFirstChild("Client") or Instance.new("RemoteEvent")
RemoteClient.Name = "Client"
RemoteClient.Parent = REMOTES

-- Configuration (GetAndSet expected API: new(initialTable) -> object with :Get(key) and :Set(key,value))
local Config = GetAndSet.new({
	XP_PER_KILL = 50,
	BASE_HP = 120,
	ENERGY_REGEN_PER_SEC = 5,
	DEFAULT_ABILITY_COOLDOWN = 1.2,
})

-- Encapsulated player registry. Encapsulation.protect(table) expected.
local _registry = {}
Encapsulation.protect(_registry)

-- PlayerManager API (exposed via _G.AnimeGame.PlayerManager)
-- Methods: new(player), get(player), remove(player), addXP(player,amount)
local PlayerManager = {}
PlayerManager.__index = PlayerManager

function PlayerManager:new(player)
	Guard.isA(player, "Instance", "player must be a Player instance")
	local data = {
		UserId = player.UserId,
		Level = 1,
		XP = 0,
		Stats = {
			HP = Config:Get("BASE_HP"),
			MaxHP = Config:Get("BASE_HP"),
			Energy = 100,
			MaxEnergy = 100,
			Strength = 12,
			Speed = 14,
		},
		Inventory = {},
		Abilities = {},
		CreatedAt = os.time(), -- prefer os.time for persistent timestamps
	}
	_registry[player.UserId] = data
	return data
end

function PlayerManager:get(player)
	if typeof(player) == "number" then
		return _registry[player] -- allow passing userId
	elseif typeof(player) == "Instance" then
		return _registry[player.UserId]
	end
	return nil
end

function PlayerManager:remove(player)
	local userId = (typeof(player) == "Instance") and player.UserId or player
	_registry[userId] = nil
end

function PlayerManager:addXP(player, amount)
	local p = self:get(player)
	if not p then return end
	p.XP = p.XP + (amount or 0)
	-- Simple level curve: required XP = 100 * level
	while p.XP >= (100 * p.Level) do
		p.XP = p.XP - (100 * p.Level)
		p.Level = p.Level + 1
		p.Stats.MaxHP = p.Stats.MaxHP + 12
		p.Stats.HP = p.Stats.MaxHP
		-- safe client notify
		local pl = Players:GetPlayerByUserId(p.UserId)
		if pl then
			RemoteClient:FireClient(pl, "LevelUp", p.Level)
		end
	end
end

-- Ability manager using Debounce module
-- Debounce API expected: new() -> object with :isDebounced(key), :setDebounce(key, seconds)
local AbilityManager = {}
AbilityManager.__index = AbilityManager
local debounce = Debounce.new()

function AbilityManager:register(player, abilityName, meta)
	Guard.isString(abilityName, "abilityName must be a string")
	local p = PlayerManager:get(player)
	if not p then return end
	p.Abilities[abilityName] = meta or {}
end

function AbilityManager:canUse(player, abilityName)
	local p = PlayerManager:get(player)
	if not p then return false end
	local ability = p.Abilities[abilityName]
	if not ability then return false end
	if ability.Cost and p.Stats.Energy < ability.Cost then return false end
	if ability.Cooldown and debounce:isDebounced(player.UserId .. ":" .. abilityName) then return false end
	return true
end

function AbilityManager:use(player, abilityName, targetUserId)
	if not self:canUse(player, abilityName) then return false end
	local p = PlayerManager:get(player)
	local ability = p.Abilities[abilityName]
	if ability.Cost then p.Stats.Energy = math.max(0, p.Stats.Energy - ability.Cost) end
	if ability.Cooldown then debounce:setDebounce(player.UserId .. ":" .. abilityName, ability.Cooldown) end

	-- Resolve target (use GetPlayerByUserId to avoid string-based lookups)
	if targetUserId then
		local target = Players:GetPlayerByUserId(targetUserId)
		if target then
			local td = PlayerManager:get(target.UserId)
			if td then
				local damage = (p.Stats.Strength * (ability.Mult or 1)) + (ability.FlatDamage or 0)
				td.Stats.HP = math.max(0, td.Stats.HP - damage)
				RemoteClient:FireClient(target, "TakeDamage", damage)
				if td.Stats.HP <= 0 then
					PlayerManager:addXP(player, Config:Get("XP_PER_KILL"))
				end
			end
		end
	end

	RemoteClient:FireClient(player, "AbilityFired", abilityName)
	return true
end

-- Vehicle controller delegates to OOPVehicles module
local VehicleController = {}
function VehicleController:spawnFor(player, vehicleId)
	-- OOPVehicles:spawnForPlayer(player, vehicleId) expected
	return OOPVehicles:spawnForPlayer(player, vehicleId)
end

-- World systems using GameSystemModule
-- GameSystem API expected: :on(eventName, callback), :boot()
local World = {}
World.__index = World

function World:init()
	-- Tick listener: energy regeneration
	GameSystem:on("Tick", function(dt)
		GenericIter.foreach(_registry, function(_, pdata)
			pdata.Stats.Energy = math.min(pdata.Stats.MaxEnergy, pdata.Stats.Energy + (Config:Get("ENERGY_REGEN_PER_SEC") * dt))
		end)
	end)

	GameSystem:on("PlayerJoined", function(player)
		self:handleJoin(player)
	end)

	GameSystem:on("PlayerLeft", function(player)
		self:handleLeave(player)
	end)
end

function World:handleJoin(player)
	PlayerManager:new(player)
	task.wait(0.1)
	AbilityManager:register(player, "Strike", { Cost = 8, Mult = 1.2, Cooldown = 1.3 })
	RemoteClient:FireClient(player, "Init", { Level = 1, XP = 0, Stats = PlayerManager:get(player).Stats })
end

function World:handleLeave(player)
	PlayerManager:remove(player.UserId)
end

-- Network handlers: validate inputs with Guard
RemoteRequest.OnServerEvent:Connect(function(player, action, payload)
	if action == "UseAbility" then
		Guard.isTable(payload, "payload must be a table")
		local name = payload.Name
		Guard.isString(name, "ability name required")
		-- client should pass target userId (number) to avoid trusting client strings
		local targetUserId = payload.TargetUserId
		AbilityManager:use(player, name, targetUserId)

	elseif action == "SpawnVehicle" then
		Guard.isTable(payload, "payload must be table")
		VehicleController:spawnFor(player, payload.VehicleId)

	elseif action == "RequestState" then
		local p = PlayerManager:get(player)
		if p then
			RemoteClient:FireClient(player, "State", { Level = p.Level, XP = p.XP, Stats = p.Stats })
		end

	else
		warn("Unknown action from client:", tostring(action))
	end
end)

-- Player connection handling
Players.PlayerAdded:Connect(function(player)
	World:handleJoin(player)
end)

Players.PlayerRemoving:Connect(function(player)
	World:handleLeave(player)
end)

-- Expose for dev/debugging (do not rely on this in production)
_G.AnimeGame = {
	PlayerManager = PlayerManager,
	AbilityManager = AbilityManager,
	VehicleController = VehicleController,
}

-- Boot and initialize
GameSystem:boot()
World:init()

-- Dev loop: use task.spawn + task.wait
task.spawn(function()
	while true do
		local count = 0
		GenericIter.foreach(_registry, function(_, _v) count = count + 1 end)
		print(string.format("[AnimeGame] players=%d | uptime=%.0f", count, time()))
		task.wait(90)
	end
end)

