--[[
	This function demonstrates the use of guard clauses.
	A guard clause is a programming pattern where the function immediately returns 
	when an invalid condition is detected. This prevents deep nesting, keeps the logic 
	flat and readable, and makes error handling more explicit.

	Why use guard clauses?
	- Improves readability by eliminating unnecessary indentation
	- Makes validation clearer and easier to maintain
	- Ensures the function exits early when parameters are invalid
	- Reduces the chances of unexpected errors deeper in the logic
	- Keeps the "happy path" straight and clean at the bottom of the function
]]

local function SellItem(Player, Item, Price)

	-- Valid Player?
	if typeof(Player) ~= "Instance" or Player.ClassName ~= "Player" then
		return false, "Invalid player"
	end

	-- Valid Item?
	if typeof(Item) ~= "string" or Item == "" then
		return false, "Invalid item"
	end

	-- Valid Price?
	if typeof(Price) ~= "number" or Price <= 0 then
		return false, "Invalid price"
	end

	-- Player has Money attribute?
	local moneyObj = Player:FindFirstChild("Money")
	if not moneyObj or typeof(moneyObj.Value) ~= "number" then
		return false, "Invalid Money attribute"
	end

	-- Has enough money?
	if moneyObj.Value < Price then
		return false, "You don't have enough money"
	end

	-- Charge the player
	moneyObj.Value -= Price

	return true
end
