--!strict
-- AnimationService.lua
-- Sistema avançado de animações com cache e reutilização de AnimationTracks

local AnimationService = {}
AnimationService.__index = AnimationService

-- Cache:
-- [Humanoid] = { [AnimationId] = AnimationTrack }
local AnimationCache: {
	[Humanoid]: { [string]: AnimationTrack }
} = {}

-- Obtém ou cria Animator
local function getAnimator(humanoid: Humanoid): Animator
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	return animator
end

-- Limpa cache quando Humanoid morre
local function bindCleanup(humanoid: Humanoid)
	if AnimationCache[humanoid] then return end

	AnimationCache[humanoid] = {}

	humanoid.Destroying:Connect(function()
		AnimationCache[humanoid] = nil
	end)
end

-- Retorna AnimationTrack (cacheado ou novo)
function AnimationService:GetTrack(
	humanoid: Humanoid,
	animation: Animation
): AnimationTrack?

	-- Guard clauses
	if not humanoid then
		warn("AnimationService:GetTrack -> Humanoid inválido")
		return nil
	end

	if not animation or not animation:IsA("Animation") then
		warn("AnimationService:GetTrack -> Animation inválida")
		return nil
	end

	bindCleanup(humanoid)

	local animationId = animation.AnimationId
	local humanoidCache = AnimationCache[humanoid]

	-- Reutiliza track se existir
	if humanoidCache[animationId] then
		return humanoidCache[animationId]
	end

	-- Cria novo track
	local animator = getAnimator(humanoid)

	local success, track = pcall(function()
		return animator:LoadAnimation(animation)
	end)

	if not success or not track then
		warn("AnimationService:GetTrack -> Falha ao carregar animação")
		return nil
	end

	humanoidCache[animationId] = track
	return track
end

-- Toca animação (usa cache)
function AnimationService:PlayAnimation(
	humanoid: Humanoid,
	animation: Animation,
	speed: number?,
	priority: Enum.AnimationPriority?
): AnimationTrack?

	local track = self:GetTrack(humanoid, animation)
	if not track then return nil end

	if priority then
		track.Priority = priority
	end

	if speed then
		track:AdjustSpeed(speed)
	end

	if not track.IsPlaying then
		track:Play()
	end
	
	

	return track
end

-- Para animação específica
function AnimationService:StopAnimation(
	humanoid: Humanoid,
	animation: Animation
)
	local cache = AnimationCache[humanoid]
	if not cache then return end

	local track = cache[animation.AnimationId]
	if track and track.IsPlaying then
		track:Stop()
	end
end

-- =====================================================
-- Para todas animações do humanoid
-- =====================================================
function AnimationService:StopAll(humanoid: Humanoid)
	local cache = AnimationCache[humanoid]
	if not cache then return end

	for _, track in pairs(cache) do
		if track.IsPlaying then
			track:Stop()
		end
	end
end

return AnimationService
