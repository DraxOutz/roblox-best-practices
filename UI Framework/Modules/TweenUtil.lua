--!strict
local TweenService = game:GetService("TweenService")

local TweenUtil = {}
local activeTweens: {[GuiObject]: Tween} = {}

-- Internal function to play a tween safely
function TweenUtil.PlayTween(
	Frame: GuiObject?,
	properties: {[string]: any},
	duration: number,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
	onComplete: (() -> ())?
)
	if not Frame or not Frame:IsA("GuiObject") then
		warn("TweenUtil: Invalid Frame")
		return
	end
	if duration <= 0 then
		warn("TweenUtil: Duration must be positive")
		return
	end

	-- Cancel existing tween if any
	if activeTweens[Frame] then
		activeTweens[Frame]:Cancel()
		activeTweens[Frame] = nil
	end

	local tweenInfo = TweenInfo.new(
		duration,
		easingStyle or Enum.EasingStyle.Quad,
		easingDirection or Enum.EasingDirection.Out
	)

	local tween = TweenService:Create(Frame, tweenInfo, properties)
	activeTweens[Frame] = tween
	tween.Completed:Connect(function()
		activeTweens[Frame] = nil
		if onComplete then onComplete() end
	end)
	tween:Play()
end

-- Fade In / Out
function TweenUtil.FadeIn(Frame: GuiObject, duration: number, onComplete: (() -> ())?)
	TweenUtil.PlayTween(Frame, {BackgroundTransparency = 0}, duration, nil, nil, onComplete)
end

function TweenUtil.FadeOut(Frame: GuiObject, duration: number, onComplete: (() -> ())?)
	TweenUtil.PlayTween(Frame, {BackgroundTransparency = 1}, duration, nil, nil, onComplete)
end

-- Position / Size Tweens
function TweenUtil.TweenPosition(Frame: GuiObject, newPosition: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	TweenUtil.PlayTween(Frame, {Position = newPosition}, duration, easingStyle, easingDirection, onComplete)
end

function TweenUtil.TweenSize(Frame: GuiObject, newSize: UDim2, duration: number, easingStyle: Enum.EasingStyle?, easingDirection: Enum.EasingDirection?, onComplete: (() -> ())?)
	TweenUtil.PlayTween(Frame, {Size = newSize}, duration, easingStyle, easingDirection, onComplete)
end

-- Text fade
function TweenUtil.FadeText(Label: GuiObject, duration: number, fadeIn: boolean, onComplete: (() -> ())?)
	if not Label:IsA("TextLabel") and not Label:IsA("TextButton") then
		warn("TweenUtil: FadeText requires TextLabel or TextButton")
		return
	end
	TweenUtil.PlayTween(Label, {TextTransparency = fadeIn and 0 or 1}, duration, nil, nil, onComplete)
end

-- Typing effect
function TweenUtil.TypeText(Label: TextLabel | TextButton, fullText: string, delay: number?, onComplete: (() -> ())?)
	delay = delay or 0.05
	task.spawn(function()
		Label.Text = ""
		for i = 1, #fullText do
			Label.Text = fullText:sub(1, i)
			task.wait(delay)
		end
		if onComplete then onComplete() end
	end)
end

return TweenUtil
