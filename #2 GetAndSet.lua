local ValidItems = {
	["Apple"] = 5,
}

-- Get function: centralizes how we read prices.
-- If in the future we add discounts, taxes or dynamic pricing,
-- we only change this function instead of editing every script.
local function GetPrice(Item)
	return ValidItems[Item]
end

-- Get function: all money reads come from here.
-- Useful for logging, stats or future changes like multiple wallets.
local function GetMoney(Player)
	return Player.Money.Value
end

-- Set function: we update the player's money only through here.
-- This allows future changes like discounts, transactions logs,
-- anti-cheat validation, or versioning without rewriting everything.
local function SetMoney(Player, NewValue)
	Player.Money.Value = NewValue
end

local function PurchaseItem(Player, Item)

	-- Guard Clause: invalid player
	if not Player or not Player:IsA("Player") then
		return false, "Invalid player"
	end

	-- Guard Clause: invalid item
	if typeof(Item) ~= "string" or ValidItems[Item] == nil then
		return false, "Invalid item"
	end

	local price = GetPrice(Item)
	local money = GetMoney(Player)

	-- Guard Clause: not enough money
	if money < price then
		return false, "Not enough money"
	end

	-- Instead of modifying money directly,
	-- we use SetMoney so the system stays modular and easy to update.
	SetMoney(Player, money - price)

	return true, "Purchase completed"
end
