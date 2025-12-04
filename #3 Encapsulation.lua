--[[
Private Function (ensurePlayer)
-Only used inside the module.
-Not accessible by other scripts.
-Used to protect the system from invalid input.
-Private functions are safer because:
-They cannot be misused by other developers.
-You avoid someone accidentally calling them incorrectly.
-They act like “internal rules” of your system.

Public Function (Damage)
-This is what other developers can call.
-It’s clean, simple, and safe because all validations are hidden inside the private function.
-Public functions are the official API of your module.
]]

local HealthSystem = {}

-- PRIVATE FUNCTION
local function ensurePlayer(Player)
	-- Validate Player and Humanoid
	if not Player or not Player:IsA("Player") then
		return false
	end

	local char = Player.Character
	if not char then return false end

	local hum = char:FindFirstChild("Humanoid")
	if not hum then return false end

	if hum.Health <= 0 then return false end

	return true
end

-- PUBLIC FUNCTION
function HealthSystem:Damage(Player, Amount)
	-- Validation before applying damage
	if not ensurePlayer(Player) then
		return
	end

	Player.Character.Humanoid:TakeDamage(Amount)
end

return HealthSystem
