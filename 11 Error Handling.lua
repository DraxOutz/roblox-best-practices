local ErrorHandling = {}

-- Generic Try function with optional fallback
-- @param action function: the function to execute
-- @param fallback? function: optional fallback on error
-- @return any: result of the function or fallback
function ErrorHandling.Try(action: () -> any, fallback: (() -> any)?): any
    if type(action) ~= "function" then
        error("Action must be a function")  -- Guard Clause
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

-- Specific function to destroy an object safely
-- @param obj Instance: object to destroy
-- @return boolean: success or failure
function ErrorHandling.DestroyObj(obj: Instance): boolean
    return ErrorHandling.Try(function()
        obj:Destroy()
        return true
    end, function()
        warn("Custom handler: cannot destroy the object")
        return false
    end)
end

return ErrorHandling
