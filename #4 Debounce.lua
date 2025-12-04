--[[
    This example teaches:
    1. Debounce (prevents spamming an action)
    2. Get/Set methods (control values safely)
    3. Private vs Public functions
]]

local DamageSystem = {}
DamageSystem.__index = DamageSystem

-- PRIVATE: store last damage time per player
local lastDamageTime = {}

-- PRIVATE: helper to check cooldown
local function canDamage(Player, Cooldown)
	if not Player then return false end

	local now = tick()
	local lastTick = lastDamageTime[Player.UserId] or 0

	if now - lastTick < Cooldown then
		return false
	end

	lastDamageTime[Player.UserId] = now
	return true
end

-- PRIVATE: apply damage safely
local function applyDamage(Player, Amount)
	local Humanoid = Player.Character and Player.Character:FindFirstChildWhichIsA("Humanoid")
	if Humanoid then
		Humanoid:TakeDamage(Amount)
	end
end

-- PUBLIC: Get the last damage time (example of GET method)
function DamageSystem:GetLastDamage(Player)
	return lastDamageTime[Player.UserId] or 0
end

-- PUBLIC: Deal damage (example of SET method)
function DamageSystem:Damage(Player, Amount, Cooldown)
	Cooldown = Cooldown or 1 -- default 1 second
	if not canDamage(Player, Cooldown) then
		return false -- still in cooldown
	end

	applyDamage(Player, Amount)
	return true
end

return DamageSystem
