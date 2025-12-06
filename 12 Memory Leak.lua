--!strict
local Players: Players = game:GetService("Players")

-- Table to store connections for cleanup
type PlayerConnections = { [number]: RBXScriptConnection }
local playerConnections: { [number]: PlayerConnections } = {}

-- Function to handle player joining
local function OnPlayerAdded(player: Player): ()
	-- Guard Clause
	if not player then return end

	-- Initialize table for this player's connections
	playerConnections[player.UserId] = {} :: PlayerConnections

	-- Example event: Player chats
	local chatConnection: RBXScriptConnection = player.Chatted:Connect(function(msg: string)
		print(player.Name.." said: "..msg)
	end)
	table.insert(playerConnections[player.UserId], chatConnection)

	-- Example event: Character added
	local charConnection: RBXScriptConnection = player.CharacterAdded:Connect(function(character: Model)
		print(player.Name.." spawned a character")
	end)
	table.insert(playerConnections[player.UserId], charConnection)
end

-- Function to cleanup connections when player leaves
local function OnPlayerRemoving(player: Player): ()
	local connections: PlayerConnections? = playerConnections[player.UserId]
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
