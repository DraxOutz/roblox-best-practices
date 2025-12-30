--!strict
-- GameServices.lua 
-- @class GameServices
-- @desc Centraliza todos os módulos essenciais do cliente para acesso seguro e previsível.

local GameServices = {}
GameServices.__index = GameServices

-- @desc Tabela de serviços disponíveis no jogo
-- @field ClientCurrencies: módulo ClientCurrencies
-- @field Config: módulo de configuração global
-- @field Maid: módulo de gerenciamento de cleanup
-- @field Network: módulo de comunicação segura com o server
-- @field TweenUtil: módulo de tween/efeitos UI
-- @field UIManager: módulo de gerenciamento de telas
-- @field UIState: módulo de gerenciamento de estados UI
GameServices.Services = {
	-- @desc Gerencia moedas/currencies do jogador (cliente)
	ClientCurrencies = require(script.Parent:WaitForChild("ClientCurrencies")),

	-- @desc Configurações globais do cliente (UI, texto, input, debug)
	Config = require(script.Parent:WaitForChild("Config")),

	-- @desc Maid para cleanup de instâncias, eventos e tarefas
	Maid = require(script.Parent:WaitForChild("Maid")),

	-- @desc Comunicação segura entre cliente e servidor
	Network = require(script.Parent:WaitForChild("Network")),

	-- @desc Tweening e efeitos de UI de alta performance
	TweenUtil = require(script.Parent:WaitForChild("TweenUtil")),

	-- @desc Gerenciador de telas principais e overlays
	UIManager = require(script.Parent:WaitForChild("UIManager")),

	-- @desc Gerencia estados de elementos UI de forma modular e segura
	UIState = require(script.Parent:WaitForChild("UIState")),
}

-- @desc Garante que a tabela de serviços não seja modificada externamente

return setmetatable({}, {
	__index = GameServices.Services,
	__newindex = function()
		error("[GameServices] Tentativa de modificar serviços é proibida")
	end,
})
