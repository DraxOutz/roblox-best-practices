--!strict
-- Config.lua

-- Tipos para cada grupo de configuração
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

type TextConfig = {
	DefaultTypingSpeed: number,
	FadeTime: number,
}

type InputConfig = {
	EnableKeyboardShortcuts: boolean,
	DefaultClickDelay: number,
}

type DebugConfig = {
	ShowUIBorders: boolean,
	EnableLogs: boolean,
	VerboseTweens: boolean,
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

-- Debug / Dev
Config.Debug = {
	ShowUIBorders = false,
	EnableLogs = true,
	VerboseTweens = false,
}

return Config
