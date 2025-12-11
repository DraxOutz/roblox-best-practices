--!strict

local GameServices = {}

GameServices.Services = {
	ClientCurrencies = require(script.Parent:WaitForChild("ClientCurrencies")),
	Config  = require(script.Parent:WaitForChild("Config")),
	Maid    = require(script.Parent:WaitForChild("Maid")),
	Network  = require(script.Parent:WaitForChild("Network")),
	TweenUtil  = require(script.Parent:WaitForChild("TweenUtil")),
	UIManager  = require(script.Parent:WaitForChild("UIManager")),
	UIState  = require(script.Parent:WaitForChild("UIState")),
}

return GameServices
