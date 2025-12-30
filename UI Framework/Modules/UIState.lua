--!strict
-- @module UIState
-- @desc Gerencia propriedades e eventos de elementos UI de forma modular, segura e totalmente controlada.
--       Usa Maid para cleanup automático de conexões e instâncias.
--       Arquitetura pensada para máxima previsibilidade e integração com outros módulos.

local Maid = require(script.Parent:WaitForChild("Maid"))

local UIState = {}
UIState.__index = UIState

-- @type UIStateType
-- @desc Interface do UIState
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

-- @desc Cria uma nova instância de UIState
-- @return UIStateType
local function new(): UIStateType
	local self: UIStateType = setmetatable({}, UIState)
	self.maid = Maid.new()
	return self
end

-- @desc Define qualquer propriedade de um elemento UI
-- @param element GuiObject: elemento alvo
-- @param property string: nome da propriedade
-- @param value any: valor a ser atribuído
function UIState:SetProperty(element: GuiObject, property: string, value: any)
	assert(element and element:IsA("GuiObject"), "[UIState] SetProperty: element inválido")
	if element[property] == nil then
		error(("[UIState] SetProperty: propriedade '%s' inválida para %s"):format(property, element:GetFullName()))
	end
	element[property] = value
end

-- @desc Define o texto de um TextLabel ou TextBox
-- @param element TextLabel | TextBox: elemento alvo
-- @param text string: texto a ser aplicado
function UIState:SetText(element: TextLabel | TextBox, text: string)
	self:SetProperty(element, "Text", text)
end

-- @desc Define a cor de fundo de um elemento UI
-- @param element GuiObject
-- @param color Color3
function UIState:SetColor(element: GuiObject, color: Color3)
	self:SetProperty(element, "BackgroundColor3", color)
end

-- @desc Define o tamanho de um elemento UI
-- @param element GuiObject
-- @param size UDim2
function UIState:SetSize(element: GuiObject, size: UDim2)
	self:SetProperty(element, "Size", size)
end

-- @desc Define a posição de um elemento UI
-- @param element GuiObject
-- @param position UDim2
function UIState:SetPosition(element: GuiObject, position: UDim2)
	self:SetProperty(element, "Position", position)
end

-- @desc Define a visibilidade de um elemento UI
-- @param element GuiObject
-- @param visible boolean
function UIState:SetVisible(element: GuiObject, visible: boolean)
	self:SetProperty(element, "Visible", visible)
end

-- @desc Define a transparência de fundo de um elemento UI
-- @param element GuiObject
-- @param transparency number
function UIState:SetTransparency(element: GuiObject, transparency: number)
	self:SetProperty(element, "BackgroundTransparency", transparency)
end

-- @desc Conecta eventos do elemento UI e gerencia com Maid
-- @param element GuiObject
-- @param eventName string: nome do evento (ex: "MouseButton1Click")
-- @param callback (...any) -> (): função a ser chamada
function UIState:ConnectEvent(element: GuiObject, eventName: string, callback: (...any) -> ())
	assert(element and element:IsA("GuiObject"), "[UIState] ConnectEvent: element inválido")
	local event = element[eventName]
	if not event or typeof(event) ~= "RBXScriptSignal" then
		error(("[UIState] ConnectEvent: evento '%s' inválido para %s"):format(eventName, element:GetFullName()))
	end
	local conn = event:Connect(callback)
	self.maid:Give(conn)
end

-- @desc Limpa todas conexões e instâncias gerenciadas
function UIState:Cleanup()
	self.maid:DoCleaning()
end

-- @desc Exporta a função de criação
UIState.new = new

return UIState
