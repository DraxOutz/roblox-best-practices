local Players = game:GetService("Players")

-- Table to store connections for cleanup
local playerConnections = {}

-- Function to handle player joining
local function OnPlayerAdded(player)
	-- Guard Clause
	if not player then return end

	-- Initialize table for this player's connections
	playerConnections[player.UserId] = {}

	-- Example event: Player chats
	local chatConnection = player.Chatted:Connect(function(msg)
		print(player.Name.." said: "..msg)
	end)
	table.insert(playerConnections[player.UserId], chatConnection)

	-- Example event: Character added
	local charConnection = player.CharacterAdded:Connect(function(character)
		print(player.Name.." spawned a character")
	end)
	table.insert(playerConnections[player.UserId], charConnection)
end

-- Function to cleanup connections when player leaves
local function OnPlayerRemoving(player)
	local connections = playerConnections[player.UserId]
	if connections then
		for _, conn in pairs(connections) do
			if conn.Connected then
				conn:Disconnect()
			end
		end
		playerConnections[player.UserId] = nil
	end
end

-- Connect player added/removed
Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

print("Event memory leak demo running!")
