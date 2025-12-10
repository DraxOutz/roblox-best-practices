--!strict
-- Use the Framework on my github for better functioning
-- maintain the standard for better efficiency
-- Services (I recommend putting these services in a single module, but it is just for example)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Modules folder (
local MODULES_FOLDER = ReplicatedStorage:FindFirstChild("Modules")
if not MODULES_FOLDER then
	MODULES_FOLDER = Instance.new("Folder")
	MODULES_FOLDER.Name = "Modules"
	MODULES_FOLDER.Parent = ReplicatedStorage
end

--Types
export type Player = Player 
export type Timestamp = number

export type PlayerStats = {
	HP: number,
	MaxHP: number,
	Energy: number,
	MaxEnergy: number,
	Strength: number,
	Speed: number,
}

export type AbilityMeta = {
	Cost: number?,
	Mult: number?,
	FlatDamage: number?,
	Cooldown: number?,
}

export type PlayerData = {
	UserId: number,
	Level: number,
	XP: number,
	Stats: PlayerStats,
	Inventory: { [number]: any }?,
	Abilities: { [string]: AbilityMeta }?,
	CreatedAt: Timestamp,
}

export type Registry = { [number]: PlayerData }

-- Adjust the module return types here if your modules expose specific typed APIs.

local Guard = require(MODULES_FOLDER:WaitForChild("GuardClause")) :: any
local GetAndSet = require(MODULES_FOLDER:WaitForChild("GetAndSet")) :: {
	new: (initialTable: { [string]: any }?) -> {
		Get: (key: string) -> any,
		Set: (key: string, value: any) -> (),
	},
}
local Encapsulation = require(MODULES_FOLDER:WaitForChild("Encapsulation")) :: {
	protect: (t: table) -> (),
}
local Debounce = require(MODULES_FOLDER:WaitForChild("Debounce")) :: {
	new: () -> {
		isDebounced: (key: string) -> boolean,
		setDebounce: (key: string, seconds: number) -> (),
	},
}
local OOPVehicles = require(MODULES_FOLDER:WaitForChild("OOP_Vehicles")) :: any
local GenericIter = require(MODULES_FOLDER:WaitForChild("GenericIteration")) :: {
	foreach: (tbl: table, fn: (any, any) -> ()) -> (),
}
local GameSystem = require(MODULES_FOLDER:WaitForChild("GameSystemModule")) :: {
	on: (eventName: string, callback: (...any) -> ()) -> (),
	boot: () -> (),
}

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

-- Configuration (GetAndSet expected API: new(initialTable) -> object with :Get(key) and :Set(key,value))  (basic encapsulation, same logic as Java)
local Config = GetAndSet.new({
	XP_PER_KILL = 50,
	BASE_HP = 120,
	ENERGY_REGEN_PER_SEC = 5,
	DEFAULT_ABILITY_COOLDOWN = 1.2,
})

-- Encapsulated player registry. Encapsulation.protect(table) expected.
local _registry: Registry = {}
Encapsulation.protect(_registry)

-- PlayerManager API (exposed via _G.AnimeGame.PlayerManager)
-- Methods: new(player), get(player), remove(player), addXP(player,amount)
local PlayerManager: {
	new: (self: any, player: Player) -> PlayerData,
	get: (self: any, player: number | Player) -> PlayerData?,
	remove: (self: any, player: number | Player) -> (),
	addXP: (self: any, player: number | Player, amount: number?) -> (),
} = {}
PlayerManager.__index = PlayerManager

function PlayerManager:new(player: Player): PlayerData
	Guard.isA(player, "Instance", "player must be a Player instance")
	local data: PlayerData = {
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

function PlayerManager:get(player: number | Player): PlayerData?
	if typeof(player) == "number" then
		return _registry[player] :: PlayerData?
	elseif typeof(player) == "Instance" then
		local p = player :: Player
		return _registry[p.UserId]
	end
	return nil
end

function PlayerManager:remove(player: number | Player)
	local userId: number
	if typeof(player) == "Instance" then
		userId = (player :: Player).UserId
	else
		userId = player :: number
	end
	_registry[userId] = nil
end

function PlayerManager:addXP(player: number | Player, amount: number?)
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
local AbilityManager: {
	register: (self: any, player: number | Player, abilityName: string, meta: AbilityMeta?) -> (),
	canUse: (self: any, player: number | Player, abilityName: string) -> boolean,
	use: (self: any, player: Player, abilityName: string, targetUserId: number?) -> boolean,
} = {}
AbilityManager.__index = AbilityManager
local debounce = Debounce.new()

function AbilityManager:register(player: number | Player, abilityName: string, meta: AbilityMeta?)
	Guard.isString(abilityName, "abilityName must be a string")
	local p = PlayerManager:get(player)
	if not p then return end
	p.Abilities = p.Abilities or {}
	p.Abilities[abilityName] = meta or {}
end

function AbilityManager:canUse(player: number | Player, abilityName: string): boolean
	local p = PlayerManager:get(player)
	if not p then return false end
	local ability = p.Abilities and p.Abilities[abilityName]
	if not ability then return false end
	if ability.Cost and p.Stats.Energy < ability.Cost then return false end
	if ability.Cooldown and debounce:isDebounced((p.UserId :: number) .. ":" .. abilityName) then return false end
	return true
end

function AbilityManager:use(player: Player, abilityName: string, targetUserId: number?): boolean
	if not self:canUse(player, abilityName) then return false end
	local p = PlayerManager:get(player)
	if not p then return false end
	local ability = p.Abilities and p.Abilities[abilityName]
	if ability == nil then return false end
	if ability.Cost then
		p.Stats.Energy = math.max(0, p.Stats.Energy - ability.Cost)
	end
	if ability.Cooldown then
		debounce:setDebounce((p.UserId :: number) .. ":" .. abilityName, ability.Cooldown)
	end

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
local VehicleController: {
	spawnFor: (self: any, player: Player, vehicleId: any) -> any,
} = {}
function VehicleController:spawnFor(player: Player, vehicleId: any)
	-- OOPVehicles:spawnForPlayer(player, vehicleId) expected
	-- cast as any because OOPVehicles exact signature unknown
	return (OOPVehicles :: any):spawnForPlayer(player, vehicleId)
end

-- World systems using GameSystemModule
-- GameSystem API expected: :on(eventName, callback), :boot()
local World: {
	init: (self: any) -> (),
	handleJoin: (self: any, player: Player) -> (),
	handleLeave: (self: any, player: Player) -> (),
} = {}
World.__index = World

function World:init()
	-- Tick listener: energy regeneration
	GameSystem:on("Tick", function(dt: number)
		GenericIter.foreach(_registry, function(_, pdata: PlayerData)
			pdata.Stats.Energy = math.min(pdata.Stats.MaxEnergy, pdata.Stats.Energy + (Config:Get("ENERGY_REGEN_PER_SEC") * dt))
		end)
	end)

	GameSystem:on("PlayerJoined", function(player: Player)
		self:handleJoin(player)
	end)

	GameSystem:on("PlayerLeft", function(player: Player)
		self:handleLeave(player)
	end)
end

function World:handleJoin(player: Player)
	PlayerManager:new(player)
	task.wait(0.1)
	AbilityManager:register(player, "Strike", { Cost = 8, Mult = 1.2, Cooldown = 1.3 })
	local pdata = PlayerManager:get(player)
	if pdata then
		RemoteClient:FireClient(player, "Init", { Level = pdata.Level, XP = pdata.XP, Stats = pdata.Stats })
	end
end

function World:handleLeave(player: Player)
	PlayerManager:remove(player.UserId)
end

-- Network handlers: validate inputs with Guard
RemoteRequest.OnServerEvent:Connect(function(player: Player, action: string, payload: any)
	if action == "UseAbility" then
		Guard.isTable(payload, "payload must be a table")
		local name = payload.Name
		Guard.isString(name, "ability name required")
		-- client should pass target userId (number) to avoid trusting client strings
		local targetUserId = payload.TargetUserId :: number?
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
Players.PlayerAdded:Connect(function(player: Player)
	World:handleJoin(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
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
		GenericIter.foreach(_registry, function(_, _v)
			count = count + 1
		end)
		print(string.format("[AnimeGame] players=%d | uptime=%.0f", count, time()))
		task.wait(90)
	end
end)



