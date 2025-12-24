--!strict
-- TweenUtil.lua
-- Abstração de tweens e efeitos de UI
-- Permite animações consistentes e seguras em GuiObjects, incluindo efeitos de fade, movimento, tamanho e typing effect.

local TweenService = game:GetService("TweenService")

local TweenUtil = {}
TweenUtil.__index = TweenUtil

-- Tipagem exportada
export type TweenUtilType = {
	PlayTween: (frame: GuiObject?, properties: {[string]: any}, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?) -> (),
	FadeIn: (frame: GuiObject, duration: number, onComplete: (() -> ())?) -> (),
	FadeOut: (frame: GuiObject, duration: number, onComplete: (() -> ())?) -> (),
	TweenPosition: (frame: GuiObject, position: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?) -> (),
	TweenSize: (frame: GuiObject, size: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?) -> (),
	FadeText: (label: TextLabel | TextButton, fadeIn: boolean, duration: number, onComplete: (() -> ())?) -> (),
	TypeText: (label: TextLabel | TextButton, fullText: string, delay: number?, onComplete: (() -> ())?) -> (),
}

-- Guarda tweens ativos para evitar sobreposição
local activeTweens: {[GuiObject]: Tween} = {}

-- Função interna segura para criar e gerenciar tweens
local function safePlayTween(
	frame: GuiObject?,
	properties: {[string]: any},
	duration: number,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	onComplete: (() -> ())?
)
	if not frame or not frame:IsA("GuiObject") then
		warn("TweenUtil: Frame inválido fornecido")
		return
	end
	if duration <= 0 then
		warn("TweenUtil: Duração inválida")
		return
	end

	-- Cancela tween anterior se existir
	if activeTweens[frame] then
		activeTweens[frame]:Cancel()
		activeTweens[frame] = nil
	end

	local info = TweenInfo.new(
		duration,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(frame, info, properties)
	activeTweens[frame] = tween
	tween.Completed:Connect(function()
		activeTweens[frame] = nil
		if onComplete then onComplete() end
	end)
	tween:Play()
end

TweenUtil.PlayTween = safePlayTween

-- Funções helpers

-- Fade in de um frame
function TweenUtil.FadeIn(frame: GuiObject, duration: number, onComplete: (() -> ())?)
	safePlayTween(frame, {BackgroundTransparency = 0}, duration, nil, nil, onComplete)
end

-- Fade out de um frame
function TweenUtil.FadeOut(frame: GuiObject, duration: number, onComplete: (() -> ())?)
	safePlayTween(frame, {BackgroundTransparency = 1}, duration, nil, nil, onComplete)
end

-- Move um frame para nova posição
function TweenUtil.TweenPosition(frame: GuiObject, position: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	safePlayTween(frame, {Position = position}, duration, easingStyle, easingDirection, onComplete)
end

-- Redimensiona um frame
function TweenUtil.TweenSize(frame: GuiObject, size: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	safePlayTween(frame, {Size = size}, duration, easingStyle, easingDirection, onComplete)
end

-- Fade in/out do texto de um label
function TweenUtil.FadeText(label: TextLabel | TextButton, fadeIn: boolean, duration: number, onComplete: (() -> ())?)
	safePlayTween(label, {TextTransparency = fadeIn and 0 or 1}, duration, nil, nil, onComplete)
end

-- Efeito de digitação para textos
function TweenUtil.TypeText(label: TextLabel | TextButton, fullText: string, delay: number?, onComplete: (() -> ())?)
	delay = delay or 0.05
	task.spawn(function()
		label.Text = ""
		for i = 1, #fullText do
			label.Text = fullText:sub(1, i)
			task.wait(delay)
		end
		if onComplete then onComplete() end
	end)
end

-- Exemplo de uso:
-- TweenUtil.FadeIn(myFrame, 0.5)
-- TweenUtil.TweenPosition(myFrame, UDim2.new(0.5,0,0.5,0), 0.3)
-- TweenUtil.TypeText(myLabel, "Olá Mundo!", 0.05)

return TweenUtil
