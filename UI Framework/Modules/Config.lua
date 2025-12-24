--!strict
-- Config.lua
-- Configurações gerais para UI, Texto, Input e Debug no cliente
-- Preparado para uso em sistemas complexos, fácil de manter e entender por outro dev

-- Tipos para cada grupo de configuração
type UIConfig = {
	DefaultFadeTime: number,               -- tempo padrão para fade in/out de telas
	DefaultTweenTime: number,              -- tempo padrão para qualquer tween
	DefaultTweenStyle: Enum.EasingStyle,  -- estilo padrão de tween
	DefaultTweenDirection: Enum.EasingDirection, -- direção padrão de tween
	OverlayFadeTime: number,               -- tempo para overlays (tooltips, modals)
	TooltipDelay: number,                  -- atraso antes de mostrar tooltips
	ModalBackgroundTransparency: number,   -- transparência padrão de modals
	MaxOpenFrames: number,                 -- número máximo de telas primárias abertas
}

type TextConfig = {
	DefaultTypingSpeed: number,  -- segundos por letra para efeito de digitação
	FadeTime: number,            -- tempo de fade de texto
}

type InputConfig = {
	EnableKeyboardShortcuts: boolean, -- ativa atalhos de teclado padrão
	DefaultClickDelay: number,        -- tempo mínimo entre cliques em botões
}

type DebugConfig = {
	ShowUIBorders: boolean,  -- mostra bordas das UIs para desenvolvimento
	EnableLogs: boolean,     -- ativa logs no console
	VerboseTweens: boolean,  -- logs detalhados de tweens
}

export type ConfigType = {
	UI: UIConfig,
	Text: TextConfig,
	Input: InputConfig,
	Debug: DebugConfig,
}

-- Definição do módulo
local Config: ConfigType = {}

-- UI geral
Config.UI = {
	DefaultFadeTime = 0.5,
	DefaultTweenTime = 0.5,
	DefaultTweenStyle = Enum.EasingStyle.Quad,
	DefaultTweenDirection = Enum.EasingDirection.Out,
	OverlayFadeTime = 0.3,
	TooltipDelay = 0.7,
	ModalBackgroundTransparency = 0.5,
	MaxOpenFrames = 1,
}

-- Texto
Config.Text = {
	DefaultTypingSpeed = 0.05,
	FadeTime = 0.3,
}

-- Input / Controle do jogador
Config.Input = {
	EnableKeyboardShortcuts = true,
	DefaultClickDelay = 0.2,
}

-- Debug / Desenvolvimento
Config.Debug = {
	ShowUIBorders = false,
	EnableLogs = true,
	VerboseTweens = false,
}

-- Exemplo de uso:
-- local Config = require(path.to.Config)
-- print(Config.UI.DefaultFadeTime)
-- if Config.Debug.EnableLogs then print("Logs ativos") end

return Config
