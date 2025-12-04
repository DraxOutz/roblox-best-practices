-- Modular game system integrating Guard Clauses, Get/Set, Encapsulation, Debounce, OOP Vehicles, Generic Iteration

local GameSystem = {}
GameSystem.__index = GameSystem

-- Debounce Utility (#4)
local DebounceTimes = {}
local function debounce(player, action, time)
	local key = player.UserId .. ":" .. action
	local now = tick()
	if DebounceTimes[key] and DebounceTimes[key] > now then
		return false
	end
	DebounceTimes[key] = now + time
	return true
end

-- Player Stats / Buffs (#2, #3)
local PlayerStats = {}
PlayerStats.__index = PlayerStats

function PlayerStats.new(player)
	local self = setmetatable({}, PlayerStats)
	self.Player = player
	self.Stats = {HP = 100, Mana = 50, Strength = 10, Defense = 5}
	self.Buffs = {}
	return self
end

function PlayerStats:GetStat(statName)
	return self.Stats[statName]
end

function PlayerStats:SetStat(statName, value)
	if type(value) ~= "number" then return end
	self.Stats[statName] = value
end

function PlayerStats:ApplyBuff(statName, value, duration)
	if not self.Stats[statName] then return end
	self.Stats[statName] += value
	table.insert(self.Buffs, {Stat = statName, Value = value, Expire = os.time() + duration})
end

function PlayerStats:UpdateBuffs()
	local now = os.time()
	for i = #self.Buffs, 1, -1 do
		local buff = self.Buffs[i]
		if now >= buff.Expire then
			self.Stats[buff.Stat] -= buff.Value
			table.remove(self.Buffs, i)
		end
	end
end

-- Economy System (#1, #2, #3)
local Economy = {}
Economy.__index = Economy

function Economy.new(player)
	local self = setmetatable({}, Economy)
	self.Player = player
	self.Money = player:FindFirstChild("Money") or Instance.new("IntValue", player)
	self.Money.Name = "Money"
	self.Money.Value = self.Money.Value or 1000
	return self
end

function Economy:GetMoney() return self.Money.Value end
function Economy:AddMoney(amount)
	if type(amount) ~= "number" or amount <= 0 then return end
	self.Money.Value += amount
end

function Economy:RemoveMoney(amount)
	if type(amount) ~= "number" or amount <= 0 then return false end
	if self.Money.Value < amount then return false end
	self.Money.Value -= amount
	return true
end

-- Vehicles System (#5)
local Vehicle = {}
Vehicle.__index = Vehicle

Vehicle.AvailableVehicles = {
	{Name="HB20", Price=25000},
	{Name="Tesla Model 3", Price=250000},
}

function Vehicle:BuyVehicle(playerEconomy, vehicleName)
	local vehicle
	for _, v in ipairs(self.AvailableVehicles) do
		if v.Name == vehicleName then
			vehicle = v
			break
		end
	end
	if not vehicle then return false, "Vehicle not found" end
	if not playerEconomy:RemoveMoney(vehicle.Price) then
		return false, "Not enough money"
	end
	return true, vehicle
end

-- Generic Iteration (#6)
local function foreach(tbl, action)
	for i, v in ipairs(tbl) do
		action(v)
	end
end

-- GameSystem Constructor
function GameSystem.new(player)
	local self = setmetatable({}, GameSystem)
	self.Player = player
	self.Stats = PlayerStats.new(player)
	self.Economy = Economy.new(player)
	self.Vehicles = setmetatable({}, Vehicle)
	return self
end

-- Example Usage Methods
function GameSystem:BuyCar(vehicleName)
	if not debounce(self.Player, "buyVehicle", 1) then
		return false, "Please wait before buying again"
	end
	return self.Vehicles:BuyVehicle(self.Economy, vehicleName)
end

function GameSystem:ShowRichFriends(friends)
	foreach(friends, function(friend)
		if friend.Money.Value >= 1000 then
			print(friend.Name .. " is rich!")
		end
	end)
end

function GameSystem:ApplyBuff(stat, value, duration)
	self.Stats:ApplyBuff(stat, value, duration)
end

function GameSystem:Update()
	self.Stats:UpdateBuffs()
end

return GameSystem
