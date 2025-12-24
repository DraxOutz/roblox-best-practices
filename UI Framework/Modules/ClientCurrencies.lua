--!strict
--[[
	ClientCurrencies.lua
	Lado cliente
	Modularizado e seguro
	Gerencia moedas/currencies do jogador individual
	Totalmente preparado para UI ou lógica do jogo
]]

local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Maid"))

local ClientCurrencies = {}
ClientCurrencies.__index = ClientCurrencies

-- Tipagem
type CurrencyName = string
type CurrencyAmount = number
type CurrencyMap = { [CurrencyName]: CurrencyAmount }

export type ClientCurrenciesType = typeof(ClientCurrencies.new())

--[[
	Criando uma nova instância de ClientCurrencies
	Exemplo:
		local playerCurrencies = ClientCurrencies.new()
		playerCurrencies:Set("Gold", 100)
		playerCurrencies.OnChange.Event:Connect(function(name, value)
			print(name, value)
		end)
]]
function ClientCurrencies.new(): ClientCurrenciesType
	local self = setmetatable({}, ClientCurrencies)

	-- Tabela interna de moedas
	self.currencies = {} :: CurrencyMap

	-- Maid para cleanup
	self.maid = Maid.new()

	-- Evento disparado sempre que um valor muda
	self.OnChange = Instance.new("BindableEvent")
	self.maid:Give(self.OnChange)

	return self
end

-- Define ou atualiza uma currency
function ClientCurrencies:Set(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or not amount then
		warn("[ClientCurrencies] Set inválido:", name, amount)
		return
	end

	local prev = self.currencies[name] or 0
	self.currencies[name] = math.max(amount, 0)

	if prev ~= self.currencies[name] then
		self.OnChange:Fire(name, self.currencies[name])
	end
end

-- Adiciona valor a uma currency
function ClientCurrencies:Add(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or amount <= 0 then
		warn("[ClientCurrencies] Add inválido:", name, amount)
		return
	end
	self:Set(name, (self.currencies[name] or 0) + amount)
end

-- Subtrai valor de uma currency
function ClientCurrencies:Subtract(name: CurrencyName, amount: CurrencyAmount)
	if name == "" or amount <= 0 then
		warn("[ClientCurrencies] Subtract inválido:", name, amount)
		return
	end
	self:Set(name, math.max((self.currencies[name] or 0) - amount, 0))
end

-- Pega o valor atual de uma currency
function ClientCurrencies:Get(name: CurrencyName): CurrencyAmount
	if name == "" then return 0 end
	return self.currencies[name] or 0
end

-- Retorna todas as currencies (cópia para evitar sobrescrita externa)
function ClientCurrencies:GetAll(): CurrencyMap
	local copy: CurrencyMap = {}
	for k, v in pairs(self.currencies) do
		copy[k] = v
	end
	return copy
end

-- Reseta todas as currencies para 0
function ClientCurrencies:Reset()
	for name, _ in pairs(self.currencies) do
		self:Set(name, 0)
	end
end

-- Cleanup completo
function ClientCurrencies:Destroy()
	self.maid:DoCleaning()
	setmetatable(self, nil)
end

return ClientCurrencies
