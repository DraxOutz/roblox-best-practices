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
