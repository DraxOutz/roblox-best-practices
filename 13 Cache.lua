--!strict
local RunService: RunService = game:GetService("RunService")
local Player: Player
local Model: Model

-- Type alias for the cache
type VehicleCacheType = {
	Player: Player?,
	Cache: { [Model]: boolean }?,
	ChildAddedConnection: RBXScriptConnection?,
	ChildRemovedConnection: RBXScriptConnection?,
	AddListeners: (self: VehicleCacheType) -> (),
	Destroy: (self: VehicleCacheType) -> (),
	ForEach: (self: VehicleCacheType, callback: (vehicle: Model) -> ()) -> (),
}

local VehicleCache: VehicleCacheType = {}
VehicleCache.__index = VehicleCache

-- Constructor
function VehicleCache.new(player: Player): VehicleCacheType
	local self: VehicleCacheType = setmetatable({}, VehicleCache)
	self.Player = player
	self.Cache = {} :: { [Model]: boolean }

	-- Connect events to update cache
	self:AddListeners()

	return self
end

-- Add ChildAdded/ChildRemoved listeners
function VehicleCache:AddListeners(): ()
	if not self.Player then return end
	local vehiclesFolder: Folder = self.Player:WaitForChild("Veiculos") :: Folder

	-- When a vehicle is added
	self.ChildAddedConnection = vehiclesFolder.ChildAdded:Connect(function(vehicle: Instance)
		if vehicle:IsA("Model") then
			self.Cache[vehicle] = true
		end
	end)

	-- When a vehicle is removed
	self.ChildRemovedConnection = vehiclesFolder.ChildRemoved:Connect(function(vehicle: Instance)
		if vehicle:IsA("Model") then
			self.Cache[vehicle] = nil
		end
	end)

	-- Initialize cache with existing vehicles
	for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
		if vehicle:IsA("Model") then
			self.Cache[vehicle] = true
		end
	end
end

-- Cleanup connections and cache
function VehicleCache:Destroy(): ()
	if self.ChildAddedConnection then
		self.ChildAddedConnection:Disconnect()
		self.ChildAddedConnection = nil
	end
	if self.ChildRemovedConnection then
		self.ChildRemovedConnection:Disconnect()
		self.ChildRemovedConnection = nil
	end

	-- Clear cache
	if self.Cache then
		for vehicle, _ in pairs(self.Cache) do
			self.Cache[vehicle] = nil
		end
	end
	self.Cache = nil
	self.Player = nil
end

-- Iterate over cache safely
function VehicleCache:ForEach(callback: (vehicle: Model) -> ()): ()
	if not self.Cache then return end
	for vehicle, _ in pairs(self.Cache) do
		callback(vehicle)
	end
end

return VehicleCache
