--!strict
-- TweenUtil.lua
-- @class TweenUtil
-- @desc Módulo para animações seguras e modulares em GuiObjects.
--        Suporta fades, movimentos, redimensionamento e efeito de digitação.
--        Arquitetura projetada para Tier S: tipagem estrita, controle total, integração com Maid, cancelamento seguro.

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage:WaitForChild("Maid"))
local Config = require(ReplicatedStorage:WaitForChild("Config"))

local TweenUtil = {}
TweenUtil.__index = TweenUtil

-- @type TweenProperties
-- @desc Tipagem estrita para propriedades de tween. Evita erros silenciosos e aumenta previsibilidade.
export type TweenProperties = {
	BackgroundTransparency: number?,
	TextTransparency: number?,
	Position: UDim2?,
	Size: UDim2?,
	BackgroundColor3: Color3?,
	Text: string?,
}

-- @type TweenUtilType
-- @desc Define a interface do TweenUtil, incluindo retorno de controladores para cancelamento e pause/resume.
export type TweenUtilType = {
	-- @param frame: GuiObject? - elemento a ser animado.
	-- @param properties: TweenProperties - propriedades a alterar.
	-- @param duration: number? - duração do tween (usa default se nil).
	-- @param easingStyle: Enum.EasingStyle? - estilo do tween.
	-- @param easingDirection: Enum.EasingDirection? - direção do tween.
	-- @param onComplete: (() -> ())? - callback ao final do tween.
	-- @return {Cancel: () -> ()} - controlador para cancelar tween.
	PlayTween: (frame: GuiObject?, properties: TweenProperties, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?) -> {Cancel: () -> ()},

	-- Funções helpers similares com retorno de cancelamento.
	FadeIn: (frame: GuiObject, duration: number?, onComplete: (() -> ())?) -> {Cancel: () -> ()},
	FadeOut: (frame: GuiObject, duration: number?, onComplete: (() -> ())?) -> {Cancel: () -> ()},
	TweenPosition: (frame: GuiObject, position: UDim2, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?) -> {Cancel: () -> ()},
	TweenSize: (frame: GuiObject, size: UDim2, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?) -> {Cancel: () -> ()},
	FadeText: (label: TextLabel | TextButton, fadeIn: boolean, duration: number?, onComplete: (() -> ())?) -> {Cancel: () -> ()},

	-- @param maid: Maid - gerencia o cleanup seguro de coroutines.
	-- @param label: TextLabel | TextButton - elemento a digitar.
	-- @param fullText: string - texto completo.
	-- @param delay: number? - tempo por letra (default do Config se nil).
	-- @param onComplete: (() -> ())? - callback ao terminar.
	-- @return {Pause: () -> (), Resume: () -> (), Cancel: () -> ()} - controlador de coroutine.
	TypeText: (maid: Maid, label: TextLabel | TextButton, fullText: string, delay: number?, onComplete: (() -> ())?) -> {Pause: () -> (), Resume: () -> (), Cancel: () -> ()},
}

-- @desc Armazena tweens ativos para evitar sobreposição e permitir cancelamento automático.
local activeTweens: {[GuiObject]: Tween} = {}

-- @desc Função interna que centraliza a criação de tweens.
--       Escolha arquitetural: centralizar tween evita duplicação de lógica, garante cancelamento seguro e integração com Config defaults.
local function safePlayTween(
	frame: GuiObject?,
	properties: TweenProperties,
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	onComplete: (() -> ())?
)
	-- @guard: frame inválido
	if not frame or not frame:IsA("GuiObject") then
		error("TweenUtil: Frame inválido fornecido")
	end

	duration = duration or Config.UI.DefaultTweenTime
	if duration <= 0 then
		error("TweenUtil: Duração inválida")
	end

	-- @design: cancela tween anterior no mesmo frame para evitar sobreposição.
	if activeTweens[frame] then
		activeTweens[frame]:Cancel()
		activeTweens[frame] = nil
	end

	local info = TweenInfo.new(
		duration,
		easingStyle or Config.UI.DefaultTweenStyle,
		easingDirection or Config.UI.DefaultTweenDirection
	)

	local tween = TweenService:Create(frame, info, properties)
	activeTweens[frame] = tween
	tween.Completed:Connect(function()
		activeTweens[frame] = nil
		if onComplete then onComplete() end
	end)
	tween:Play()

	-- @return controlador para cancelamento externo.
	return {
		Cancel = function()
			if activeTweens[frame] then
				activeTweens[frame]:Cancel()
				activeTweens[frame] = nil
			end
		end
	}
end

TweenUtil.PlayTween = safePlayTween

-- Helpers
function TweenUtil.FadeIn(frame: GuiObject, duration: number?, onComplete: (() -> ())?)
	return safePlayTween(frame, {BackgroundTransparency = 0}, duration, nil, nil, onComplete)
end

function TweenUtil.FadeOut(frame: GuiObject, duration: number?, onComplete: (() -> ())?)
	return safePlayTween(frame, {BackgroundTransparency = 1}, duration, nil, nil, onComplete)
end

function TweenUtil.TweenPosition(frame: GuiObject, position: UDim2, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	return safePlayTween(frame, {Position = position}, duration, easingStyle, easingDirection, onComplete)
end

function TweenUtil.TweenSize(frame: GuiObject, size: UDim2, duration: number?, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	return safePlayTween(frame, {Size = size}, duration, easingStyle, easingDirection, onComplete)
end

function TweenUtil.FadeText(label: TextLabel | TextButton, fadeIn: boolean, duration: number?, onComplete: (() -> ())?)
	return safePlayTween(label, {TextTransparency = fadeIn and 0 or 1}, duration, nil, nil, onComplete)
end

-- @desc TypeText com coroutine pura, totalmente controlável
--       Escolha arquitetural: coroutine permite pause/resume/cancel, integração Maid previne vazamentos.
function TweenUtil.TypeText(maid: Maid, label: TextLabel | TextButton, fullText: string, delay: number?, onComplete: (() -> ())?)
	delay = delay or Config.Text.DefaultTypingSpeed
	label.Text = ""

	local running = true
	local paused = false
	local co = coroutine.create(function()
		for i = 1, #fullText do
			if not running then break end
			while paused do
				task.wait()
			end
			label.Text = fullText:sub(1, i)
			task.wait(delay)
		end
		if running and onComplete then onComplete() end
	end)

	coroutine.resume(co)

	local controller = {
		Pause = function() paused = true end,
		Resume = function() paused = false end,
		Cancel = function() running = false end
	}

	-- @design: integração Maid garante cleanup seguro
	maid:Give({
		Destroy = function() running = false end
	})

	return controller
end

return TweenUtil
