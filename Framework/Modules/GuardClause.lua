--!strict
local GuardClause = {}
GuardClause.__index = GuardClause

function GuardClause:IsValid(Value: any, expectedType: string? ): boolean
	--
	if Value == nil then
		return false
	end
	--
	if expectedType and typeof(Value) ~= expectedType then
		return false
	end
	--
	return true
end

function GuardClause:IsValidNumber(Value: any, min: number, max: number): boolean
	if typeof(Value) ~= "number" then
		return false
	end
	if min and Value < min then
		return false
	end
	if max and Value > max then
		return false
	end
	return true
end

function GuardClause:IsValidWithPredicate(Value: any, Predicate: (any) -> boolean): boolean
	if Value == nil then
		return false
	end
	return Predicate(Value)
end


return GuardClause
