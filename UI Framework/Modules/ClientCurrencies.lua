--!strict
-- Guarda e gerencia valores recebidos do server (currencies)

local ClientCurrencies = {}
ClientCurrencies.__index = ClientCurrencies

type CurrencyName = string
type CurrencyAmount = number
type CurrencyMap = { [CurrencyName]: CurrencyAmount }

-- Tabela interna com todas as currencies
local currencies: CurrencyMap = {}

-- Define ou atualiza o valor de uma currency
function ClientCurrencies:Set(name: CurrencyName, amount: CurrencyAmount)
	if name == "" then return end
	if amount < 0 then amount = 0 end

	currencies[name] = amount
end

-- Adiciona à currency existente
function ClientCurrencies:Add(name: CurrencyName, amount: CurrencyAmount)
	if name == "" then return end
	if amount <= 0 then return end

	currencies[name] = (currencies[name] or 0) + amount
end

-- Subtrai de uma currency existente
function ClientCurrencies:Subtract(name: CurrencyName, amount: CurrencyAmount)
	if name == "" then return end
	if amount <= 0 then return end

	local current = currencies[name] or 0
	current -= amount

	if current < 0 then
		current = 0
	end

	currencies[name] = current
end

-- Pega o valor atual da currency
function ClientCurrencies:Get(name: CurrencyName): CurrencyAmount
	if name == "" then
		return 0
	end

	return currencies[name] or 0
end

-- Pega todas as currencies (útil pra UI)
function ClientCurrencies:GetAll(): CurrencyMap
	local copy: CurrencyMap = {}

	for k, v in pairs(currencies) do
		copy[k] = v
	end

	return copy
end

-- Limpa todas as currencies (se precisar)
function ClientCurrencies:Reset()
	table.clear(currencies)
end

return ClientCurrencies
