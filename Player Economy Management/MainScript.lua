local ErrorHandling = require(script.Parent.ErrorHandling) -- modular error handling
local GuardClause = require(script.Parent.GuardClause)     -- parameter validation
local Debounce = require(script.Parent.Debounce)           -- execution control

local PlayerEconomy = {}
PlayerEconomy.__index = PlayerEconomy

-- Constructor (Single Responsibility, SOLID)
-- @param player Instance
-- @return PlayerEconomy
function PlayerEconomy.new(player: Instance): PlayerEconomy
	GuardClause.NotNil(player, "Player cannot be nil")

	local self = setmetatable({}, PlayerEconomy)		
	self.Player = player
	self.EconomyValues = player:FindFirstChild("EconomyValues")
	return self
end

-- Pure function to calculate new balance (Functional Programming)
-- @param current number
-- @param change number
-- @return number
local function CalculateBalance(current: number, change: number): number
	return current + change
end

-- Deposit money into player's account
-- @param amount number
-- @return boolean
function PlayerEconomy:Deposit(amount: number): boolean
	return ErrorHandling.Try(function()
		GuardClause.PositiveNumber(amount, "Deposit amount must be positive")

		local bank = self.EconomyValues:FindFirstChild("Bank")
		if bank then
			bank.Value = CalculateBalance(bank.Value, amount) -- functional approach
			return true
		else
			warn("Bank value not found for player: "..self.Player.Name)
			return false
		end
	end, function()
		warn("Deposit failed for player: "..self.Player.Name)
		return false
	end)
end

-- Withdraw money from player's account
-- @param amount number
-- @return boolean
function PlayerEconomy:Withdraw(amount: number): boolean
	return ErrorHandling.Try(function()
		GuardClause.PositiveNumber(amount, "Withdraw amount must be positive")

		local bank = self.EconomyValues:FindFirstChild("Bank")
		if bank and bank.Value >= amount then
			bank.Value = CalculateBalance(bank.Value, -amount)
			return true
		else
			warn("Insufficient balance for player: "..self.Player.Name)
			return false
		end
	end, function()
		warn("Withdraw failed for player: "..self.Player.Name)
		return false
	end)
end

-- Optional: safe transfer between players (SOLID, SRP, Error Handling)
-- @param target PlayerEconomy
-- @param amount number
-- @return boolean
function PlayerEconomy:TransferTo(target: PlayerEconomy, amount: number): boolean
	return ErrorHandling.Try(function()
		GuardClause.NotNil(target, "Target player cannot be nil")
		GuardClause.PositiveNumber(amount, "Transfer amount must be positive")

		if self:Withdraw(amount) then
			return target:Deposit(amount)
		else
			return false
		end
	end, function()
		warn("Transfer failed from "..self.Player.Name.." to "..target.Player.Name)
		return false
	end)
end

return PlayerEconomy
