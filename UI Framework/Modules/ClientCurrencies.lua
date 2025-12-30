--!strict
-- ClientCurrencies.lua
-- @class ClientCurrencies
-- @desc Gerencia moedas/currencies do jogador no lado cliente.
--       Totalmente modular, seguro, eficiente e pronto para UI ou lógica do jogo.

local Maid = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Maid"))

local ClientCurrencies = {}
ClientCurrencies.__index = ClientCurrencies

-- @type CurrencyName
-- @desc Nome da moeda/currency
type CurrencyName = string

-- @type CurrencyAmount
-- @desc Valor numérico da currency
type CurrencyAmount = number

-- @type CurrencyMap
-- @desc Mapa interno de moedas { [nome]: valor }
type CurrencyMap = { [CurrencyName]: CurrencyAmount }

-- @type ClientCurrenciesType
-- @desc Interface do ClientCurrencies para tipagem externa
export type ClientCurrenciesType = typeof(ClientCurrencies.new())

--[[
	@desc Cria uma nova instância de ClientCurrencies
	@returns ClientCurrenciesType - instância pronta para uso
	@example
		local playerCurrencies = ClientCurrencies.new()
		playerCurrencies:Set("Gold", 100)
		playerCurrencies.OnChange.Event:Connect(function(name, value)
			print(name, value)
		end)
]]
function ClientCurrencies.new(): ClientCurrenciesType
	local self = setmetatable({}, ClientCurrencies)

	-- @desc Tabela interna de moedas
	self.currencies = {} :: CurrencyMap

	-- @desc Maid para gerenciamento de limpeza
	self.maid = Maid.new()

	-- @desc Evento disparado sempre que uma moeda é alterada
	self.OnChange = Instance.new("BindableEvent")
	self.maid:Give(self.OnChange)

	return self
end

--[[
	@desc Define ou atualiza o valor de uma currency
	@param name: CurrencyName - nome da moeda
	@param amount: CurrencyAmount - novo valor (>= 0)
	@return nil
]]
function ClientCurrencies:Set(name: CurrencyName, amount: CurrencyAmount)
	if not name or name == "" then
		error("[ClientCurrencies] Set: nome inválido")
	end
	if not amount or type(amount) ~= "number" then
		error("[ClientCurrencies] Set: valor inválido")
	end

	local prev = self.currencies[name] or 0
	self.currencies[name] = math.max(amount, 0)

	if prev ~= self.currencies[name] then
		self.OnChange:Fire(name, self.currencies[name])
	end
end

--[[
	@desc Adiciona valor a uma currency existente
	@param name: CurrencyName - moeda a adicionar
	@param amount: CurrencyAmount - valor positivo a adicionar
	@return nil
]]
function ClientCurrencies:Add(name: CurrencyName, amount: CurrencyAmount)
	if not name or name == "" then
		error("[ClientCurrencies] Add: nome inválido")
	end
	if not amount or amount <= 0 then
		error("[ClientCurrencies] Add: valor deve ser positivo")
	end
	self:Set(name, (self.currencies[name] or 0) + amount)
end

--[[
	@desc Subtrai valor de uma currency existente
	@param name: CurrencyName - moeda a subtrair
	@param amount: CurrencyAmount - valor positivo a subtrair
	@return nil
]]
function ClientCurrencies:Subtract(name: CurrencyName, amount: CurrencyAmount)
	if not name or name == "" then
		error("[ClientCurrencies] Subtract: nome inválido")
	end
	if not amount or amount <= 0 then
		error("[ClientCurrencies] Subtract: valor deve ser positivo")
	end
	self:Set(name, math.max((self.currencies[name] or 0) - amount, 0))
end

--[[
	@desc Retorna o valor atual de uma currency
	@param name: CurrencyName - nome da moeda
	@return CurrencyAmount - valor atual (0 se não existir)
]]
function ClientCurrencies:Get(name: CurrencyName): CurrencyAmount
	if not name or name == "" then return 0 end
	return self.currencies[name] or 0
end

--[[
	@desc Retorna todas as currencies (cópia para evitar sobrescrita externa)
	@return CurrencyMap - tabela cópia de todas as moedas
]]
function ClientCurrencies:GetAll(): CurrencyMap
	local copy: CurrencyMap = {}
	for k, v in pairs(self.currencies) do
		copy[k] = v
	end
	return copy
end

--[[
	@desc Reseta todas as currencies para 0
	@return nil
]]
function ClientCurrencies:Reset()
	for name, _ in pairs(self.currencies) do
		self:Set(name, 0)
	end
end

--[[
	@desc Cleanup completo da instância
	@return nil
]]
function ClientCurrencies:Destroy()
	self.maid:DoCleaning()
	setmetatable(self, nil)
end

return ClientCurrencies
