local PlayerModule = {}

-- SRP: Initializes player stats
function PlayerModule.Init(player)
	if not player:FindFirstChild("leaderstats") then
		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local xp = Instance.new("NumberValue") --You can use  Instance.new("NumberValue",leaderstats)
		xp.Name = "XP"
		xp.Value = 0
		xp.Parent = leaderstats

		local money = Instance.new("NumberValue")
		money.Name = "Money"
		money.Value = 100
		money.Parent = leaderstats

		local level = Instance.new("NumberValue") 
		level.Name = "Level"
		level.Value = 1
		level.Parent = leaderstats
		
	end
end

-- SRP: Add XP
function PlayerModule.AddXP(player, amount)
	local xp = player.leaderstats and player.leaderstats:FindFirstChild("XP")
	if xp then
		xp.Value += amount
		PlayerModule.CheckLevelUp(player)
	end
end

-- OCP: Add money
function PlayerModule.AddMoney(player, amount)
	local money = player.leaderstats and player.leaderstats:FindFirstChild("Money")
	if money then
		money.Value += amount
	end
end

-- OCP: Remove money
function PlayerModule.RemoveMoney(player, amount)
	local money = player.leaderstats and player.leaderstats:FindFirstChild("Money")
	if money and money.Value >= amount then
		money.Value -= amount
		return true
	end
	return false
end

-- LSP: Level up logic
function PlayerModule.CheckLevelUp(player)
	local stats = player.leaderstats
	if stats then
		local xp = stats:FindFirstChild("XP")
		local level = stats:FindFirstChild("Level")
		while xp and level and xp.Value >= level.Value * 100 do
			xp.Value -= level.Value * 100
			level.Value += 1
		end
	end
end

-- ISP: Example function using only needed stats
function PlayerModule.GetPlayerInfo(player)
	local stats = player.leaderstats
	if stats then
		return {
			XP = stats:FindFirstChild("XP") and stats.XP.Value or 0,
			Money = stats:FindFirstChild("Money") and stats.Money.Value or 0,
			Level = stats:FindFirstChild("Level") and stats.Level.Value or 1
		}
	end
end

-- DIP: Depend on abstractions (simple example)
PlayerModule.StatsProvider = {
	GetXP = function(player)
		return player.leaderstats and player.leaderstats:FindFirstChild("XP") and player.leaderstats.XP.Value or 0
	end
}

return PlayerModule
