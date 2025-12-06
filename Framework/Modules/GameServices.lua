--!strict

local GameServices = {}

GameServices.Services = {
	ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter")),
	MemoryManager  = require(script.Parent:WaitForChild("MemoryManager")),
	GuardClause    = require(script.Parent:WaitForChild("GuardClause")),
	ConfigManager  = require(script.Parent:WaitForChild("ConfigManager")),
}

return GameServices
