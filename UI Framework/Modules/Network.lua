--!strict
-- Gerencia remotes do lado cliente
local Network = {}
Network.__index = Network

export type NetworkType = typeof(Network.new())

function Network.new(remotes: {[string]: RemoteEvent}): NetworkType
	local self = setmetatable({}, Network)
	self.Remotes = remotes or {}
	return self
end

function Network:Fire(name: string, ...: any)
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	end
end

function Network:Listen(name: string, callback: (...any) -> ())
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		local conn = remote.OnClientEvent:Connect(callback)
		return conn
	end
end

return Network
