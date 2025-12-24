--!strict
-- Gerencia currencies individuais do jogador (lado cliente)
-- Modularizado, seguro, preparado para UI ou lógica do jogo
local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Maid"))

local ClientCurrencies = {}
ClientCurrencies.__index = ClientCurrencies

-- Tipagem
type CurrencyName = string
type CurrencyAmount = number
type CurrencyMap = { [CurrencyName]: CurrencyAmount }

export type ClientCurrenciesType = typeof(ClientCurrencies.new())

-- Cria nova instância
function ClientCurrencies.new(): ClientCurrenciesType
	local self = setmetatable({}, ClientCurrencies)
	self.currencies = {} :: CurrencyMap
	self.maid = Maid.new()

	-- Evento de mudança de currency
	self.OnChange = Instance.new("BindableEvent")
	self.maid:Give(self.OnChange)

	return self
end

-- Define ou atualiza o valor de uma currency
function ClientCurrencies:Set(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or not amount then return end
	local prev = self.currencies[name] or 0
	self.currencies[name] = math.max(amount, 0)

	if prev ~= self.currencies[name] then
		self.OnChange:Fire(name, self.currencies[name])
	end
end

-- Adiciona valor a uma currency existente
function ClientCurrencies:Add(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or amount <= 0 then return end
	local newAmount = (self.currencies[name] or 0) + amount
	self:Set(name, newAmount)
end

-- Subtrai valor de uma currency existente
function ClientCurrencies:Subtract(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or amount <= 0 then return end
	local newAmount = math.max((self.currencies[name] or 0) - amount, 0)
	self:Set(name, newAmount)
end

-- Pega o valor atual de uma currency
function ClientCurrencies:Get(name: CurrencyName): CurrencyAmount
	if name == "" then return 0 end
	return self.currencies[name] or 0
end

-- Retorna todas as currencies (útil para UI)
function ClientCurrencies:GetAll(): CurrencyMap
	local copy: CurrencyMap = {}
	for k, v in pairs(self.currencies) do
		copy[k] = v
	end
	return copy
end

-- Reseta todas as currencies
function ClientCurrencies:Reset()
	for name, _ in pairs(self.currencies) do
		self:Set(name, 0)
	end
end

-- Cleanup de recursos
function ClientCurrencies:Destroy()
	self.maid:DoCleaning()
	setmetatable(self, nil)
end

return ClientCurrencies
