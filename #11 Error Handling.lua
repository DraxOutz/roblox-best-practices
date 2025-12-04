-- Function to attempt to destroy an object
local function CanBeDestroyed(obj)
	local success = pcall(function()
		obj:Destroy()  -- no space between : and Destroy
	end)
	return success
end

-- Basic example
if not CanBeDestroyed(workspace) then
	error("The workspace cannot be destroyed")
else
	warn("Workspace destroyed successfully")
end

-- Example with pcall
local sc, er = pcall(function()
	workspace:Destroy()
end)

if not sc then
	warn("pcall error: "..tostring(er))
end

-- Example with xpcall and custom message
local sc2, er2 = xpcall(function()
	workspace:Destroy()
end, function(err)
	return "Custom handler: "..err
end)

if not sc2 then
	warn(er2)  -- now er2 will have the handled message
end
