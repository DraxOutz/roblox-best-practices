--!strict
-- InputController.lua

local UserInputService = game:GetService("UserInputService")

local InputController = {}
InputController.__index = InputController

-- Estado das ações
local InputState: {[string]: boolean} = {}

-- Eventos por ação
-- [action] = BindableEvent
local ActionEvents: {[string]: BindableEvent} = {}

local KeyBinds = {
	MoveForward = {Enum.KeyCode.W},
	MoveBackward = {Enum.KeyCode.S},
	MoveLeft = {Enum.KeyCode.A},
	MoveRight = {Enum.KeyCode.D},

	Jump = {Enum.KeyCode.Space},
	Sprint = {Enum.KeyCode.LeftShift},
}

-- Init
function InputController:Init(): ()
	for action in pairs(KeyBinds) do
		ActionEvents[action] = Instance.new("BindableEvent")
	end

	UserInputService.InputBegan:Connect(function(input, gp)
		if gp then return end
		self:_handleInput(input, true)
	end)

	UserInputService.InputEnded:Connect(function(input, gp)
		if gp then return end
		self:_handleInput(input, false)
	end)
end

-- Handler interno
function InputController:_handleInput(input: InputObject, isDown: boolean)
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

	for action, keys in pairs(KeyBinds) do
		if table.find(keys, input.KeyCode) then
			InputState[action] = isDown

			-- ?? AQUI: informa ação, estado e tecla física
			ActionEvents[action]:Fire(isDown, input.KeyCode)

			break
		end
	end
end

-- Conectar evento
function InputController:OnAction(
	action: string,
	callback: (isDown: boolean, keyCode: Enum.KeyCode) -> ()
): RBXScriptConnection?

	local event = ActionEvents[action]
	if not event then
		warn(("InputController: ação '%s' não registrada"):format(action))
		return nil
	end

	return event.Event:Connect(callback)
end

-- Consulta estado
function InputController:IsDown(action: string): boolean
	return InputState[action] == true
end

return InputController
