local GuardClause = {}

-- Validate that value is not nil
-- @param value any
-- @param message string
function GuardClause.NotNil(value: any, message: string)
	if value == nil then
		error(message or "Value cannot be nil")
	end
end

-- Validate that value is a positive number
-- @param value number
-- @param message string
function GuardClause.PositiveNumber(value: number, message: string)
	if type(value) ~= "number" or value <= 0 then
		error(message or "Value must be a positive number")
	end
end

-- Validate that value is a number (can be zero or negative)
-- @param value any
-- @param message string
function GuardClause.Number(value: any, message: string)
	if type(value) ~= "number" then
		error(message or "Value must be a number")
	end
end

-- Validate that value is a string
-- @param value any
-- @param message string
function GuardClause.String(value: any, message: string)
	if type(value) ~= "string" then
		error(message or "Value must be a string")
	end
end

-- Validate that value is a table
-- @param value any
-- @param message string
function GuardClause.Table(value: any, message: string)
	if type(value) ~= "table" then
		error(message or "Value must be a table")
	end
end

-- Validate that value is boolean
-- @param value any
-- @param message string
function GuardClause.Boolean(value: any, message: string)
	if type(value) ~= "boolean" then
		error(message or "Value must be a boolean")
	end
end

return GuardClause
