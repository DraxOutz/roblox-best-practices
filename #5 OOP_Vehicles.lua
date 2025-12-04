--[[
In Lua, table.insert is useful for storing data in a list, but it doesn’t let your objects “know what they can do.” 
Each function has to be separate, and adding new behaviors (like Brake or Turn) requires duplicating code or writing more functions. 
This is not object-oriented.
With setmetatable and __index, you can create objects with their own data and shared methods. 
Each object “knows” its properties and can use the methods from its class without duplicating code:
]]

-- Vehicle "class"
local Vehicle = {}
Vehicle.__index = Vehicle  -- If the object doesn't have a key, look in the Vehicle table

-- Constructor
function Vehicle.new(name)
	local self = setmetatable({}, Vehicle)  -- create the object and set its metatable
	self.Name = name                         -- unique data for this object
	return self
end

-- Method: Accelerate
function Vehicle:Accelerate()
	print(self.Name .. " is accelerating!")  -- self = the object that called the method
end

-- Method: Brake
function Vehicle:Brake()
	print(self.Name .. " is braking!")
end

-- Creating objects (cars)
local car1 = Vehicle.new("Tesla")
local car2 = Vehicle.new("BMW")
local car3 = Vehicle.new("Tiggo")

-- Calling methods
car1:Accelerate() -- Tesla is accelerating!
car1:Brake()      -- Tesla is braking!

car2:Accelerate() -- BMW is accelerating!
car2:Brake()      -- BMW is braking!

car3:Accelerate() -- Tiggo is accelerating!
car3:Brake()      -- Tiggo is braking!

