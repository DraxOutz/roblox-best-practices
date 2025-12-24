--!strict
-- Abstração de tweens e efeitos de UI
local TweenService = game:GetService("TweenService")

local TweenUtil = {}
TweenUtil.__index = TweenUtil

local activeTweens: {[GuiObject]: Tween} = {}

local function safePlayTween(
	frame: GuiObject?,
	properties: {[string]: any},
	duration: number,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	onComplete: (() -> ())?
)
	if not frame or not frame:IsA("GuiObject") then return end
	if duration <= 0 then return end

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

-- Helpers
function TweenUtil.FadeIn(frame: GuiObject, duration: number, onComplete: (() -> ())?)
	safePlayTween(frame, {BackgroundTransparency = 0}, duration, nil, nil, onComplete)
end

function TweenUtil.FadeOut(frame: GuiObject, duration: number, onComplete: (() -> ())?)
	safePlayTween(frame, {BackgroundTransparency = 1}, duration, nil, nil, onComplete)
end

function TweenUtil.TweenPosition(frame: GuiObject, position: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	safePlayTween(frame, {Position = position}, duration, easingStyle, easingDirection, onComplete)
end

function TweenUtil.TweenSize(frame: GuiObject, size: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	safePlayTween(frame, {Size = size}, duration, easingStyle, easingDirection, onComplete)
end

function TweenUtil.FadeText(label: TextLabel | TextButton, fadeIn: boolean, duration: number, onComplete: (() -> ())?)
	safePlayTween(label, {TextTransparency = fadeIn and 0 or 1}, duration, nil, nil, onComplete)
end

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

return TweenUtil
