local Debounce = {}

-- Internal storage for active debounces
local activeDebounces = {}

-- Execute a function with debounce
-- @param key string | unique key to identify the function
-- @param func () -> any | function to execute
-- @param delay number | debounce delay in seconds
-- @return boolean | true if executed, false if ignored
function Debounce.Execute(key: string, func: () -> any, delay: number): boolean
	-- Guard Clauses
	if type(key) ~= "string" then error("Debounce key must be a string") end
	if type(func) ~= "function" then error("Debounce func must be a function") end
	if type(delay) ~= "number" or delay < 0 then error("Debounce delay must be a non-negative number") end

	-- Check if already debounced
	if activeDebounces[key] then
		return false
	end

	-- Mark as active
	activeDebounces[key] = true

	-- Execute the function safely
	local success, result = pcall(func)
	if not success then
		warn("Debounce function error: "..tostring(result))
	end

	-- Schedule removal from active debounces
	task.delay(delay, function()
		activeDebounces[key] = nil
	end)

	return true
end

-- Check if a key is currently debounced
-- @param key string
-- @return boolean
function Debounce.IsActive(key: string): boolean
	return activeDebounces[key] == true
end

return Debounce
