local ErrorHandling = {}

-- Generic Try function with optional fallback
-- @param action function: the function to execute
-- @param fallback? function: optional function if action fails
-- @return any: result of the action or fallback
function ErrorHandling.Try(action: () -> any, fallback: (() -> any)?): any
	-- Guard Clause
	if type(action) ~= "function" then
		error("Action must be a function")
	end

	local success, result = pcall(action)

	if success then
		return result
	else
		warn("Error captured: "..tostring(result))
		if fallback then
			return fallback()
		else
			return nil
		end
	end
end

-- Optional function to safely execute code with custom handler (like xpcall)
-- @param action function: the function to execute
-- @param handler function: error handler
-- @return any: result of the action or handler
function ErrorHandling.SafeExecute(action: () -> any, handler: (string) -> any): any
	-- Guard Clause
	if type(action) ~= "function" or type(handler) ~= "function" then
		error("Both action and handler must be functions")
	end

	local success, result = xpcall(action, handler)
	if success then
		return result
	else
		return result -- result now contains the handled message
	end
end

return ErrorHandling
