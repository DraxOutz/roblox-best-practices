--!strict
-- Config.lua
-- @module Config
-- @desc Configurações gerais do cliente: UI, Texto, Input e Debug

-- Tipos de configuração

-- @type UIConfig
-- @field DefaultFadeTime tempo padrão para fade in/out de telas
-- @field DefaultTweenTime tempo padrão para qualquer tween
-- @field DefaultTweenStyle estilo padrão de tween
-- @field DefaultTweenDirection direção padrão de tween
-- @field OverlayFadeTime tempo de fade para overlays (tooltips, modals)
-- @field TooltipDelay atraso antes de mostrar tooltips
-- @field ModalBackgroundTransparency transparência padrão de modals
-- @field MaxOpenFrames número máximo de telas primárias abertas
type UIConfig = {
	DefaultFadeTime: number,
	DefaultTweenTime: number,
	DefaultTweenStyle: Enum.EasingStyle,
	DefaultTweenDirection: Enum.EasingDirection,
	OverlayFadeTime: number,
	TooltipDelay: number,
	ModalBackgroundTransparency: number,
	MaxOpenFrames: number,
}

-- @type TextConfig
-- @field DefaultTypingSpeed segundos por letra para efeito de digitação
-- @field FadeTime tempo de fade de texto
type TextConfig = {
	DefaultTypingSpeed: number,
	FadeTime: number,
}

-- @type InputConfig
-- @field EnableKeyboardShortcuts ativa atalhos de teclado padrão
-- @field DefaultClickDelay tempo mínimo entre cliques em botões
type InputConfig = {
	EnableKeyboardShortcuts: boolean,
	DefaultClickDelay: number,
}

-- @type DebugConfig
-- @field ShowUIBorders mostra bordas das UIs para desenvolvimento
-- @field EnableLogs ativa logs no console
-- @field VerboseTweens logs detalhados de tweens
type DebugConfig = {
	ShowUIBorders: boolean,
	EnableLogs: boolean,
	VerboseTweens: boolean,
}

-- @type ConfigType
-- @field UI configurações de UI
-- @field Text configurações de texto
-- @field Input configurações de input
-- @field Debug configurações de debug
export type ConfigType = {
	UI: UIConfig,
	Text: TextConfig,
	Input: InputConfig,
	Debug: DebugConfig,
}

-- Criação do módulo
local Config: ConfigType = {}

-- UI
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

-- Input
Config.Input = {
	EnableKeyboardShortcuts = true,
	DefaultClickDelay = 0.2,
}

-- Debug
Config.Debug = {
	ShowUIBorders = false,
	EnableLogs = true,
	VerboseTweens = false,
}

return Config
