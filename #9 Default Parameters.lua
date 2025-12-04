-- Demonstrates typing, default values, and guard clauses

local PlayerModule = {}

-- Add XP to a player safely
-- player: Player - the Roblox player
-- amount: number? - optional XP amount, defaults to 10
function PlayerModule.AddXP(player: Player, amount: number?)
	-- Default value if amount is nil
	amount = amount or 10

	-- Guard clause: check if player and leaderstats exist
	if not player or not player:FindFirstChild("leaderstats") then
		warn("Invalid player or missing leaderstats")
		return
	end

	local xp = player.leaderstats:FindFirstChild("XP")
	if not xp then
		warn("Player has no XP stat")
		return
	end

	-- Add XP safely
	xp.Value += amount
end

return PlayerModule
