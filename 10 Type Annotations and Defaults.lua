local Players = game:GetService("Players")

local InventoryModule = {}

-- SRP: Initialize player inventory
function InventoryModule.Init(player: Player)
	if not player:FindFirstChild("Inventory") then
		local inv = Instance.new("Folder")
		inv.Name = "Inventory"
		inv.Parent = player :: Player -- forcing type for clarity
	end
end

-- Add item to inventory
function InventoryModule.AddItem(player: Player, itemName: string, amount: number?)
	amount = amount or 1 -- default to 1 if nil

	local inv = player:FindFirstChild("Inventory") :: Folder
	if not inv then return end

	local item = inv:FindFirstChild(itemName)
	if item then
		item.Value += amount
	else
		local newItem = Instance.new("IntValue")
		newItem.Name = itemName
		newItem.Value = amount
		newItem.Parent = inv
	end
end

-- Remove item from inventory
function InventoryModule.RemoveItem(player: Player, itemName: string, amount: number?)
	amount = amount or 1

	local inv = player:FindFirstChild("Inventory") :: Folder
	if not inv then return false end

	local item = inv:FindFirstChild(itemName) :: IntValue?
	if item and item.Value >= amount then
		item.Value -= amount
		if item.Value <= 0 then
			item:Destroy()
		end
		return true
	end
	return false
end

-- Get inventory info
function InventoryModule.GetInventory(player: Player): {[string]: number}
	local inv = player:FindFirstChild("Inventory") :: Folder?
	local data: {[string]: number} = {}

	if not inv then return data end

	for _, item in pairs(inv:GetChildren() :: {IntValue}) do
		data[item.Name] = item.Value
	end

	return data
end

return InventoryModule
