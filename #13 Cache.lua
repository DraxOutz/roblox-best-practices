local RunService = game:GetService("RunService")

local VehicleCache = {}
VehicleCache.__index = VehicleCache

-- Constructor
function VehicleCache.new(player)
	local self = setmetatable({}, VehicleCache)
	self.Player = player
	self.Cache = {} -- Stores vehicle references

	-- Connect events to update cache
	self:AddListeners()

	return self
end

-- Add ChildAdded/ChildRemoved listeners
function VehicleCache:AddListeners()
	local vehiclesFolder = self.Player:WaitForChild("Veiculos")

	-- When a vehicle is added
	self.ChildAddedConnection = vehiclesFolder.ChildAdded:Connect(function(vehicle)
		self.Cache[vehicle] = true
	end)

	-- When a vehicle is removed
	self.ChildRemovedConnection = vehiclesFolder.ChildRemoved:Connect(function(vehicle)
		self.Cache[vehicle] = nil
	end)

	-- Initialize cache with existing vehicles
	for _, vehicle in pairs(vehiclesFolder:GetChildren()) do
		self.Cache[vehicle] = true
	end
end

-- Cleanup connections and cache
function VehicleCache:Destroy()
	if self.ChildAddedConnection then
		self.ChildAddedConnection:Disconnect()
		self.ChildAddedConnection = nil
	end
	if self.ChildRemovedConnection then
		self.ChildRemovedConnection:Disconnect()
		self.ChildRemovedConnection = nil
	end

	-- Clear cache
	for vehicle, _ in pairs(self.Cache) do
		self.Cache[vehicle] = nil
	end
	self.Cache = nil
	self.Player = nil
end

-- Iterate over cache safely
function VehicleCache:ForEach(callback)
	for vehicle, _ in pairs(self.Cache) do
		callback(vehicle)
	end
end

-- Example usage in RenderStepped
--[[
local playerCache = VehicleCache.new(Player)
RunService.RenderStepped:Connect(function()
    playerCache:ForEach(function(vehicle)
        -- do something with vehicle
    end)
end)
]]

return VehicleCache
