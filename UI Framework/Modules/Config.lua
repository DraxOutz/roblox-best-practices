--!strict
local Config = {}

-- UI geral
Config.UI = {
	DefaultFadeTime = 0.5,                   -- tempo padrão para fade in/out
	DefaultTweenTime = 0.5,                  -- tempo padrão para qualquer tween
	DefaultTweenStyle = Enum.EasingStyle.Quad,
	DefaultTweenDirection = Enum.EasingDirection.Out,
	OverlayFadeTime = 0.3,                   -- tempo para overlays
	TooltipDelay = 0.7,                      -- tempo até mostrar tooltips
	ModalBackgroundTransparency = 0.5,       -- transparência padrão de fundo de modal
	MaxOpenFrames = 1,                        -- apenas uma tela principal aberta por vez
}

-- Texto
Config.Text = {
	DefaultTypingSpeed = 0.05,               -- segundos por letra para efeito de digitação
	FadeTime = 0.3,                           -- tempo de fade de texto
}

-- Input / Controle do jogador
Config.Input = {
	EnableKeyboardShortcuts = true,
	DefaultClickDelay = 0.2,                 -- delay padrão entre cliques em botões
}

-- Debug / Dev (visível apenas no cliente)
Config.Debug = {
	ShowUIBorders = false,                   -- contorno das UIs para desenvolvimento
	EnableLogs = true,
	VerboseTweens = false,
}

return Config
