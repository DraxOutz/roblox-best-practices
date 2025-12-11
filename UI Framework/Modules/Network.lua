--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = {}
Network.__index = Network

export type Network = {
	Remotes: {[string]: RemoteEvent},
	Fire: (self: Network, name: string, ...any) -> (),
	Listen: (self: Network, name: string, callback: (...any) -> ()) -> (),
}

Network.Remotes = {}

function Network:Fire(name: string, ...: any)
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	end
end

function Network:Listen(name: string, callback: (...any) -> ())
	local remote = self.Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote.OnClientEvent:Connect(callback)
	end
end

return Network
