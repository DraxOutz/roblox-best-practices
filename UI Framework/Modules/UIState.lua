--!strict
-- UIState.lua
-- Gerencia propriedades e eventos de elementos UI de forma modular e segura.
-- Usa Maid para cleanup automático de conexões e instâncias.

local Maid = require(script.Parent:WaitForChild("Maid"))

local UIState = {}
UIState.__index = UIState

-- Tipagem exportada
export type UIStateType = {
	maid: Maid,
	SetProperty: (self: UIStateType, element: GuiObject, property: string, value: any) -> (),
	SetText: (self: UIStateType, element: TextLabel | TextBox, text: string) -> (),
	SetColor: (self: UIStateType, element: GuiObject, color: Color3) -> (),
	SetSize: (self: UIStateType, element: GuiObject, size: UDim2) -> (),
	SetPosition: (self: UIStateType, element: GuiObject, position: UDim2) -> (),
	SetVisible: (self: UIStateType, element: GuiObject, visible: boolean) -> (),
	SetTransparency: (self: UIStateType, element: GuiObject, transparency: number) -> (),
	ConnectEvent: (self: UIStateType, element: GuiObject, eventName: string, callback: (...any) -> ()) -> (),
	Cleanup: (self: UIStateType) -> (),
}

-- Cria uma nova instância de UIState
local function new(): UIStateType
	local self: UIStateType = setmetatable({}, UIState)
	self.maid = Maid.new()
	return self
end

-- Define qualquer propriedade de um elemento UI
function UIState:SetProperty(element: GuiObject, property: string, value: any)
	if not element then
		warn("UIState:SetProperty: element inválido")
		return
	end

	if element[property] == nil then
		warn(("UIState:SetProperty: propriedade '%s' inválida para %s"):format(property, element:GetFullName()))
		return
	end

	element[property] = value
end

-- Define o texto de um TextLabel ou TextBox
function UIState:SetText(element: TextLabel | TextBox, text: string)
	self:SetProperty(element, "Text", text)
end

-- Define a cor de fundo de um elemento UI
function UIState:SetColor(element: GuiObject, color: Color3)
	self:SetProperty(element, "BackgroundColor3", color)
end

-- Define o tamanho de um elemento UI
function UIState:SetSize(element: GuiObject, size: UDim2)
	self:SetProperty(element, "Size", size)
end

-- Define a posição de um elemento UI
function UIState:SetPosition(element: GuiObject, position: UDim2)
	self:SetProperty(element, "Position", position)
end

-- Define a visibilidade de um elemento UI
function UIState:SetVisible(element: GuiObject, visible: boolean)
	self:SetProperty(element, "Visible", visible)
end

-- Define a transparência de fundo de um elemento UI
function UIState:SetTransparency(element: GuiObject, transparency: number)
	self:SetProperty(element, "BackgroundTransparency", transparency)
end

-- Conecta eventos do elemento UI e gerencia com Maid
function UIState:ConnectEvent(element: GuiObject, eventName: string, callback: (...any) -> ())
	if not element then
		warn("UIState:ConnectEvent: element inválido")
		return
	end

	local event = element[eventName]
	if not event or typeof(event) ~= "RBXScriptSignal" then
		warn(("UIState:ConnectEvent: evento '%s' inválido para %s"):format(eventName, element:GetFullName()))
		return
	end

	local conn = event:Connect(callback)
	self.maid:Give(conn)
end

-- Limpa todas conexões e instâncias gerenciadas
function UIState:Cleanup()
	self.maid:DoCleaning()
end

-- Exporta a função de criação
UIState.new = new

return UIState
