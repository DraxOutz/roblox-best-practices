--!strict

local CharacterService = {} :: {
	GetRootPart: (self: any, player: Player) -> BasePart?,
	GetHumanoid: (self: any, player: Player) -> Humanoid?,
	SetSpeed: (self: any, player: Player, speed: number) -> (),
	GetRootSpeed: (self: any, player: Player) -> number?,
	GetInformation: (self: any, player: Player, infoType: "WalkSpeed" | "JumpPower") -> number?
}

-- RootPart
function CharacterService:GetRootPart(player: Player): BasePart?
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart") :: BasePart?
end

-- Humanoid
function CharacterService:GetHumanoid(player: Player): Humanoid?
	local character = player.Character
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

-- Velocidade de movimento
function CharacterService:SetSpeed(player: Player, speed: number): ()
	local humanoid = self:GetHumanoid(player)
	if not humanoid then return end

	humanoid.WalkSpeed = speed
end

-- Velocidade física (magnitude)
function CharacterService:GetRootSpeed(player: Player): number?
	local rootPart = self:GetRootPart(player)
	if not rootPart then return nil end

	return rootPart.AssemblyLinearVelocity.Magnitude
end

-- Informações genéricas do Humanoid
function CharacterService:GetInformation(
	player: Player,
	infoType: "WalkSpeed" | "JumpPower"
): number?
	local humanoid = self:GetHumanoid(player)
	if not humanoid then return nil end

	if infoType == "WalkSpeed" then
		return humanoid.WalkSpeed
	end

	if infoType == "JumpPower" then
		return humanoid.JumpPower
	end

	return nil
end

return CharacterService
