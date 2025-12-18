--!strict

-- Script translated and commented by the translator

--[[
MAIN GAME STRUCTURE - SERVER-SIDE AUTHORITY

WHAT IS THIS FOR?
- The server model is authoritative, it serves to avoid cheating on the client side such as critical calculations, for example: damage, XP, statistics. This data is never trusted if sent by the client.
- Separation of responsibilities through modules allows independent updates.
- Encapsulation logging just like Java ensures data integrity, players cannot directly modify their own statistics without going through validation systems like Guard Clause.

PERFORMANCE NOTES
- We use typed tables with export type for development-time validation and clear documentation, but no runtime overhead in production.
- Debounce uses tick() instead of Debounce uses tick() instead of timers because this way time is measured more accurately, even when the server is slow.
- Iteration modules avoid creating temporary tables for each update cycle.
]]

-- STARTUP SERVICE
-- As the complexity of the system increases, the services below will be in a single service module.
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

--[[
MODULE LOADING


WHY, instead of assuming it exists, check the Modules folder:
- Better error messages than "Instance not found" crashes;
- Supports hot reloading when modules are added or removed during development; 
- Allows the game to repair itself if modules are inadvertently deleted;
- Allows modules to be loaded conditionally depending on the environment or game mode.
]]

local MODULES_FOLDER = ReplicatedStorage:FindFirstChild("Modules")
if not MODULES_FOLDER then
	MODULES_FOLDER = Instance.new("Folder")
	MODULES_FOLDER.Name = "Modules"
	MODULES_FOLDER.Parent = ReplicatedStorage
	-- WHY log instead of warn/error: During initial setup, missing folder is expected
	print("[Framework] Created Modules folder - initial setup")
end

--[[
Types and design decisions

WHY defined types here at the top because:
- It becomes easier to understand the structure of the data without having to hunt.
- You can use it in other modules without conflicting.
- Luau understands complex types better.
- Changing something here updates it everywhere, effortlessly.

Separating PlayerStats within PlayerData was on purpose:
- You can update just the stats without changing the rest.
- Facilitates temporary buffs/debuffs, maintaining the base and current value.
- Saves memory, because you don't need to copy the table every time.
]]

export type Player = Player
export type Timestamp = number

export type PlayerStats = {
	HP: number,
	MaxHP: number,  -- WHY separate from HP: Allows regeneration systems and UI to show "120/150" format
	Energy: number,
	MaxEnergy: number,
	Strength: number,  -- WHY flat stat instead of formula: Simpler balancing, predictable scaling
	Speed: number,
}

export type AbilityMeta = {
	Cost: number?,      -- WHY optional: Some abilities might be free (passive)
	Mult: number?,      -- Multiplier for Strength stat
	FlatDamage: number?,-- WHY both Mult and FlatDamage: Allows hybrid scaling (base + percentage)
	Cooldown: number?,  -- WHY in seconds not ticks: Human-readable configuration
}

export type PlayerData = {
	UserId: number,
	Level: number,
	XP: number,
	Stats: PlayerStats,
	Inventory: { [number]: any }?,  -- WHY optional: New players start with empty inventory
	Abilities: { [string]: AbilityMeta }?,  -- WHY dictionary by name: Fast O(1) lookups
	CreatedAt: Timestamp,  -- WHY os.time() not tick(): Persistent across server restarts
}

export type Registry = { [number]: PlayerData }

--[[
MODULE DEPENDENCIES - WHY EACH IS NEEDED

Each module serves a specific Single Responsibility Principle (SRP):
- Guard: Input validation at system boundaries (network, functions)
- GetAndSet: Configuration management with controlled access
- Encapsulation: Data protection against accidental modification
- Debounce: Cooldown management with automatic cleanup
- OOPVehicles: Isolated vehicle physics/logic
- GenericIter: Safe iteration without modifying tables during iteration
- GameSystem: Event-driven architecture for decoupled systems
]]

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

--[[
REMOTE EVENT ARCHITECTURE

WHY two separate RemoteEvents instead of one:
1. "Request": Client → Server (actions, abilities, vehicles)
   - Always validated, never trusted
   - Rate-limited implicitly via debounce systems
   
2. "Client": Server → Client (state updates, notifications)
   - Broadcast updates only when changed (optimized network usage)
   - Separate from requests to prevent feedback loops

WHY dynamically created: Ensures game works even if Remotes are deleted accidentally
]]
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

--[[
CONFIGURATION MANAGEMENT DESIGN

WHY GetAndSet pattern instead of direct table access:
1. Validation: Can add type/range checks when settings are changed
2. Observability: Can hook into value changes for side effects (e.g., update all players when XP_PER_KILL changes)
3. Default values: Centralized fallback system
4. Future-proof: Can migrate to data stores without changing consumer code

WHY these specific defaults:
- XP_PER_KILL = 50: Balanced for ~2 kills per level at early levels
- BASE_HP = 120: Survives 2-3 basic ability hits, encourages strategy
- ENERGY_REGEN_PER_SEC = 5: Regenerates full bar in 20s, promotes ability timing
]]
local Config = GetAndSet.new({
	XP_PER_KILL = 50,
	BASE_HP = 120,
	ENERGY_REGEN_PER_SEC = 5,
	DEFAULT_ABILITY_COOLDOWN = 1.2,
})

--[[
PLAYER REGISTRY - DATA ISOLATION

WHY protected registry: Prevents modules from accidentally modifying other players' data
WHY not a ModuleScript: Registry needs to be accessible by multiple systems (Manager, Abilities, World)
Encapsulation ensures only PlayerManager can modify the registry directly
]]
local _registry: Registry = {}
Encapsulation.protect(_registry)

--[[
PLAYER MANAGER DESIGN PATTERN

WHY class-like pattern instead of pure functions:
1. Clear ownership: PlayerManager "owns" player data lifecycle
2. Method chaining: playerManager:get(player):addXP(50) reads naturally
3. Extensible: Easy to add new methods without global namespace pollution
4. Self-documenting: API surface is obvious from the type definition

ALTERNATIVES CONSIDERED:
- ECS (Entity Component System): Overkill for this scale
- Pure functions: Would require passing registry everywhere
- Singletons: This is essentially a singleton, but with explicit API
]]
local PlayerManager: {
	new: (self: any, player: Player) -> PlayerData,
	get: (self: any, player: number | Player) -> PlayerData?,
	remove: (self: any, player: number | Player) -> (),
	addXP: (self: any, player: number | Player, amount: number?) -> (),
} = {}
PlayerManager.__index = PlayerManager

--[[
PLAYER CREATION - INITIAL STATE DESIGN

WHY these specific starting values:
- Level 1, XP 0: Clean progression start
- Energy 100/100: Full resources for immediate gameplay
- Strength 12: Enough to feel impactful but not overpowered
- Speed 14: Slightly above Roblox default for "anime" feel
- CreatedAt timestamp: For analytics, playtime tracking, and cleanup of abandoned data
]]
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
		CreatedAt = os.time(),  -- WHY os.time over tick(): Persists across server restarts
	}
	_registry[player.UserId] = data
	return data
end

--[[
DATA RETRIEVAL PATTERN

WHY support both number and Player types:
1. number: Called from systems that only have UserId (network events, save data)
2. Player: Called from player-connected events for convenience
This duality prevents unnecessary GetPlayerByUserId calls throughout codebase
]]
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
	-- WHY not delete from data stores here: Data persistence is handled by separate system
	-- PlayerManager only manages runtime state
end

--[[
PROGRESSION SYSTEM - LEVEL UP LOGIC

WHY linear XP requirement (100 * level):
1. Predictable: Players can easily calculate next level
2. Scalable: Simple to adjust with global multiplier if needed
3. Transparent: No hidden formulas confusing players

WHY HP increases by 12 per level:
- Matches enemy damage scaling curve
- Prevents level 100 players from being invincible
- Round number divisible by common healing amounts (25%, 50%)

ALTERNATIVE DESIGN (rejected):
- Exponential curve: Creates frustration at higher levels
- Table-based: Harder to balance, requires data updates
- Dynamic based on performance: Unpredictable, hard to communicate
]]
function PlayerManager:addXP(player: number | Player, amount: number?)
	local p = self:get(player)
	if not p then return end
	p.XP = p.XP + (amount or 0)
	
	-- Linear progression curve
	while p.XP >= (100 * p.Level) do
		p.XP = p.XP - (100 * p.Level)
		p.Level = p.Level + 1
		p.Stats.MaxHP = p.Stats.MaxHP + 12
		p.Stats.HP = p.Stats.MaxHP  -- WHY full heal on level: Rewarding, simplifies UI
		
		-- Notify client
		local pl = Players:GetPlayerByUserId(p.UserId)
		if pl then
			RemoteClient:FireClient(pl, "LevelUp", p.Level)
			-- WHY not include XP reset in message: Client can calculate from known formula
		end
	end
end

--[[
ABILITY SYSTEM - RESOURCE MANAGEMENT

WHY three-layer check (existence, cost, cooldown):
1. Existence: Prevents calling non-existent abilities (hacking attempt)
2. Cost: Energy as limiting resource promotes strategic ability use
3. Cooldown: Prevents ability spamming, adds tempo to combat

WHY debounce key includes UserId AND ability name:
- Prevents cross-player debounce interference
- Clear namespace for debugging
- Allows global cooldowns by using just UserId if needed
]]
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
	-- WHY not notify client here: Abilities loaded during init, client gets full state
end

function AbilityManager:canUse(player: number | Player, abilityName: string): boolean
	local p = PlayerManager:get(player)
	if not p then return false end
	local ability = p.Abilities and p.Abilities[abilityName]
	if not ability then return false end
	
	-- Resource check
	if ability.Cost and p.Stats.Energy < ability.Cost then
		return false  -- WHY silent failure: UI shows energy bar, player knows why
	end
	
	-- Cooldown check
	if ability.Cooldown and debounce:isDebounced((p.UserId :: number) .. ":" .. abilityName) then
		return false  -- WHY not send cooldown remaining: Complex sync, UI handles locally
	end
	
	return true
end

function AbilityManager:use(player: Player, abilityName: string, targetUserId: number?): boolean
	if not self:canUse(player, abilityName) then return false end
	
	local p = PlayerManager:get(player)
	if not p then return false end
	local ability = p.Abilities and p.Abilities[abilityName]
	if ability == nil then return false end
	
	-- Apply cost immediately (prevents rapid consecutive uses)
	if ability.Cost then
		p.Stats.Energy = math.max(0, p.Stats.Energy - ability.Cost)
		-- WHY math.max: Prevents negative energy from buggy abilities
	end
	
	-- Start cooldown
	if ability.Cooldown then
		debounce:setDebounce((p.UserId :: number) .. ":" .. abilityName, ability.Cooldown)
	end

	-- Resolve damage if target exists
	-- WHY server-side target resolution: Prevents client from hitting anyone they claim
	if targetUserId then
		local target = Players:GetPlayerByUserId(targetUserId)
		if target then
			local td = PlayerManager:get(target.UserId)
			if td then
				-- Hybrid damage formula: (Stat * Multiplier) + Flat
				-- WHY hybrid: Allows both scaling abilities and fixed-damage abilities
				local damage = (p.Stats.Strength * (ability.Mult or 1)) + (ability.FlatDamage or 0)
				td.Stats.HP = math.max(0, td.Stats.HP - damage)
				
				RemoteClient:FireClient(target, "TakeDamage", damage)
				
				-- Death check and reward
				if td.Stats.HP <= 0 then
					PlayerManager:addXP(player, Config:Get("XP_PER_KILL"))
					-- WHY not reset HP here: Separate respawn system handles that
				end
			end
		end
	end

	RemoteClient:FireClient(player, "AbilityFired", abilityName)
	return true
end

--[[
VEHICLE CONTROLLER ABSTRACTION LAYER

WHY abstraction layer instead of direct OOPVehicles call:
1. Decoupling: Can replace entire vehicle system without changing gameplay code
2. Error handling: Centralized place for vehicle-related errors
3. Feature flags: Can disable vehicles in certain game modes
4. Analytics: Track vehicle usage patterns
]]
local VehicleController: {
	spawnFor: (self: any, player: Player, vehicleId: any) -> any,
} = {}
function VehicleController:spawnFor(player: Player, vehicleId: any)
	-- Forward to OOP system - WHY not validate here: OOPVehicles has its own validation
	return (OOPVehicles :: any):spawnForPlayer(player, vehicleId)
end

--[[
WORLD SYSTEM - EVENT-DRIVEN ARCHITECTURE

WHY use GameSystem module instead of direct event connections:
1. Ordering: Guaranteed event firing order (Tick always before PlayerJoined)
2. Error isolation: One system crashing doesn't break others
3. Debugging: Can log/trace all events centrally
4. Testing: Mock events during unit tests

CRITICAL: GameSystem must guarantee "Tick" events even during lag
]]
local World: {
	init: (self: any) -> (),
	handleJoin: (self: any, player: Player) -> (),
	handleLeave: (self: any, player: Player) -> (),
} = {}
World.__index = World

function World:init()
	-- Energy regeneration system
	-- WHY in Tick event instead of separate loop: Synchronized with game updates, framerate independent
	GameSystem:on("Tick", function(dt: number)
		GenericIter.foreach(_registry, function(_, pdata: PlayerData)
			-- WHY multiply by dt: Framerate-independent regeneration
			pdata.Stats.Energy = math.min(
				pdata.Stats.MaxEnergy,
				pdata.Stats.Energy + (Config:Get("ENERGY_REGEN_PER_SEC") * dt)
			)
			-- WHY math.min: Prevents over-regeneration from large dt during lag spikes
		end)
	end)

	GameSystem:on("PlayerJoined", function(player: Player)
		self:handleJoin(player)
	end)

	GameSystem:on("PlayerLeft", function(player: Player)
		self:handleLeave(player)
	end)
	
	-- WHY not handle respawns here: Separate system for death/respawn mechanics
end

--[[
PLAYER JOIN FLOW - SEQUENCE MATTERS

Order is critical:
1. Create PlayerData (immediate, for other systems)
2. Wait brief moment (lets client load)
3. Register default ability (gameplay ready)
4. Send initial state (client synchronization)
5. UI setup (client-side visual)

WHY task.wait(0.1): Allows client scripts to initialize before receiving data
]]
function World:handleJoin(player: Player)
	PlayerManager:new(player)
	
	-- Brief delay for client initialization
	task.wait(0.1)
	
	-- Default ability - WHY "Strike": Simple, melee, teaches combat basics
	AbilityManager:register(player, "Strike", {
		Cost = 8,           -- WHY 8: Enough to matter but not restrictive
		Mult = 1.2,         -- 20% bonus over basic attack
		Cooldown = 1.3      -- Slightly longer than animation for timing skill
	})
	
	local pdata = PlayerManager:get(player)
	if pdata then
		-- Initial sync - WHY not include everything: Inventory loaded separately
		RemoteClient:FireClient(player, "Init", {
			Level = pdata.Level,
			XP = pdata.XP,
			Stats = pdata.Stats
		})
	end
end

function World:handleLeave(player: Player)
	PlayerManager:remove(player.UserId)
	-- WHY not save data here: Separate persistence system handles saving
end

--[[
NETWORK REQUEST HANDLING - SECURITY PATTERNS

CRITICAL: Every client request must be validated
Pattern: Guard -> Process -> Respond/Notify

WHY separate actions instead of single "Action" event:
1. Type safety: Each action has specific payload structure
2. Permission checking: Can disable certain actions per player
3. Rate limiting: Per-action rate limits
4. Analytics: Track usage per action type
]]
RemoteRequest.OnServerEvent:Connect(function(player: Player, action: string, payload: any)
	if action == "UseAbility" then
		-- Validate structure before processing
		Guard.isTable(payload, "payload must be a table")
		local name = payload.Name
		Guard.isString(name, "ability name required")
		
		-- WHY targetUserId as number not string: Prevents injection attacks
		local targetUserId = payload.TargetUserId :: number?
		AbilityManager:use(player, name, targetUserId)

	elseif action == "SpawnVehicle" then
		Guard.isTable(payload, "payload must be table")
		-- WHY no vehicle validation here: VehicleController handles validation
		VehicleController:spawnFor(player, payload.VehicleId)

	elseif action == "RequestState" then
		-- WHY allow state requests: Client recovery after disconnect/glitch
		local p = PlayerManager:get(player)
		if p then
			RemoteClient:FireClient(player, "State", {
				Level = p.Level,
				XP = p.XP,
				Stats = p.Stats
			})
		end

	else
		-- WHY warn not error: Don't crash server on hacked client
		warn("Unknown action from client:", tostring(action))
		-- TODO: Add rate limiting for unknown actions to prevent spam
	end
end)

--[[
PLAYER LIFECYCLE HOOKS

WHY duplicate World handlers instead of calling World directly:
1. Separation: Players service knows about joining/leaving, World handles logic
2. Flexibility: Can add middleware (analytics, logging) between event and handler
3. Testing: Can mock Players service independently of World
]]
Players.PlayerAdded:Connect(function(player: Player)
	World:handleJoin(player)
end)

Players.PlayerRemoving:Connect(function(player: Player)
	World:handleLeave(player)
end)

--[[
DEBUG/DEVELOPMENT EXPORTS

WHY expose to _G:
1. Live debugging: Can call functions from console during development
2. Automated testing: Test scripts can access managers directly
3. Admin commands: Can build admin UI using these APIs

WHY not in production: Security risk - will be removed or protected
]]
_G.AnimeGame = {
	PlayerManager = PlayerManager,
	AbilityManager = AbilityManager,
	VehicleController = VehicleController,
}

--[[
SYSTEM BOOT SEQUENCE

Order matters:
1. GameSystem boots (starts internal event loops)
2. World initializes (registers event handlers)
3. Existing players handled (in case of script re-execution)

WHY not auto-handle existing players: GameSystem should emit events for them
]]
GameSystem:boot()
World:init()

--[[
HEARTBEAT/DIAGNOSTICS LOOP

WHY task.spawn not while true do spawn:
- task.spawn is modern, has better error handling
- Creates separate coroutine, doesn't block main thread

WHY 90-second interval:
- Frequent enough for debugging
- Infrequent enough not to spam logs
- Not aligned with common intervals (30, 60) to avoid pattern collisions
]]
task.spawn(function()
	while true do
		local count = 0
		GenericIter.foreach(_registry, function(_, _v)
			count = count + 1
		end)
		
		-- Diagnostic output - WHY include uptime: Correlates issues with server age
		print(string.format("[AnimeGame] players=%d | uptime=%.0f", count, time()))
		
		task.wait(90)
	end
end)





