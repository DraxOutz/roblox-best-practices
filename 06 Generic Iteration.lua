local players = {
	{Name = "Alice", Money = 100},
	{Name = "Bob", Money = 50},
	{Name = "Charlie", Money = 200},
}

-- Generic iteration function
local function foreach(tbl, action)
	for i, v in ipairs(tbl) do
		action(v)
	end
end

-- Now we can use the same function for any logic
foreach(players, function(player)
	if player.Money >= 100 then
		print(player.Name .. " is rich!")
	end
end)

-- Or to sum the money of all players
local total = 0
foreach(players, function(player)
	total = total + player.Money
end)
print("Total money: " .. total)
