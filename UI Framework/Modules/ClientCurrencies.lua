--!strict
-- Lado cliente.
-- Gerencia currencies do jogador individual
-- Modularizado, seguro e preparado para UI ou lógica do jogo

local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Maid"))

local ClientCurrencies = {}
ClientCurrencies.__index = ClientCurrencies

type CurrencyName = string
type CurrencyAmount = number
type CurrencyMap = { [CurrencyName]: CurrencyAmount }

export type ClientCurrenciesType = typeof(ClientCurrencies.new())

function ClientCurrencies.new(): ClientCurrenciesType
	local self = setmetatable({}, ClientCurrencies)
	self.currencies = {} :: CurrencyMap
	self.maid = Maid.new()
	return self
end

function ClientCurrencies:Set(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or not amount then return end
	self.currencies[name] = math.max(amount, 0)
end

function ClientCurrencies:Add(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or amount <= 0 then return end
	self.currencies[name] = (self.currencies[name] or 0) + amount
end

function ClientCurrencies:Subtract(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or amount <= 0 then return end
	local current = self.currencies[name] or 0
	self.currencies[name] = math.max(current - amount, 0)
end

function ClientCurrencies:Get(name: CurrencyName): CurrencyAmount
	if name == "" then return 0 end
	return self.currencies[name] or 0
end

function ClientCurrencies:GetAll(): CurrencyMap
	local copy: CurrencyMap = {}
	for k, v in pairs(self.currencies) do
		copy[k] = v
	end
	return copy
end

function ClientCurrencies:Reset()
	self.currencies = {}
end

return ClientCurrencies
