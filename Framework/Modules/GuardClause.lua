--!strict
-- GuardClause.lua
-- Valida valores e tipos de forma segura e performática

local GuardClause = {}
GuardClause.__index = GuardClause

-- @desc Verifica se um valor existe e opcionalmente confere o tipo
-- @param Value: any - valor a ser verificado
-- @param expectedType: string? - tipo esperado (opcional)
-- @return boolean - true se válido, false caso contrário
function GuardClause:IsValid(Value: any, expectedType: string?): boolean
	if Value == nil then return false end
	if expectedType and typeof(Value) ~= expectedType then
		return false
	end
	return true
end

-- @desc Verifica se um valor é número e opcionalmente se está dentro de um range
-- @param Value: any - valor a ser verificado
-- @param min: number? - valor mínimo permitido (opcional)
-- @param max: number? - valor máximo permitido (opcional)
-- @return boolean - true se válido, false caso contrário
function GuardClause:IsValidNumber(Value: any, min: number?, max: number?): boolean
	if typeof(Value) ~= "number" then return false end
	if min and Value < min then return false end
	if max and Value > max then return false end
	return true
end

-- @desc Verifica um valor com função predicado customizada
-- @param Value: any - valor a ser verificado
-- @param Predicate: (any) -> boolean - função que retorna true se válido
-- @return boolean - true se válido, false caso contrário
function GuardClause:IsValidWithPredicate(Value: any, Predicate: (any) -> boolean): boolean
	if Value == nil then return false end
	return Predicate(Value)
end

return GuardClause
