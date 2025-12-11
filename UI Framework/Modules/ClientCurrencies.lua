-- Guarda e gerencia valores recebidos do server (currencies)

local ClientCurrencies = {}
ClientCurrencies.__index = ClientCurrencies

-- Tabela interna com todas as currencies
local currencies = {}

-- Define ou atualiza o valor de uma currency
function ClientCurrencies:Set(name, amount)
	currencies[name] = amount
end

-- Adiciona à currency existente
function ClientCurrencies:Add(name, amount)
	currencies[name] = (currencies[name] or 0) + amount
end

-- Subtrai de uma currency existente
function ClientCurrencies:Subtract(name, amount)
	currencies[name] = (currencies[name] or 0) - amount
	if currencies[name] < 0 then
		currencies[name] = 0
	end
end

-- Pega o valor atual da currency
function ClientCurrencies:Get(name)
	return currencies[name] or 0
end

-- Pega todas as currencies (útil pra UI)
function ClientCurrencies:GetAll()
	local copy = {}
	for k,v in pairs(currencies) do
		copy[k] = v
	end
	return copy
end

-- Limpa todas as currencies (se precisar)
function ClientCurrencies:Reset()
	currencies = {}
end

return ClientCurrencies
