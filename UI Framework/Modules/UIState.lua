--!strict
local Maid = require(script.Parent:WaitForChild("Maid"))

export type UIStateType = {
	maid: any,
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

local UIState: UIStateType = {}
UIState.__index = UIState
UIState.maid = Maid.new()

function UIState:SetProperty(element: GuiObject, property: string, value: any)
	if element and element[property] ~= nil then
		element[property] = value
	end
end

function UIState:SetText(element: TextLabel | TextBox, text: string)
	self:SetProperty(element, "Text", text)
end

function UIState:SetColor(element: GuiObject, color: Color3)
	self:SetProperty(element, "BackgroundColor3", color)
end

function UIState:SetSize(element: GuiObject, size: UDim2)
	self:SetProperty(element, "Size", size)
end

function UIState:SetPosition(element: GuiObject, position: UDim2)
	self:SetProperty(element, "Position", position)
end

function UIState:SetVisible(element: GuiObject, visible: boolean)
	self:SetProperty(element, "Visible", visible)
end

function UIState:SetTransparency(element: GuiObject, transparency: number)
	self:SetProperty(element, "BackgroundTransparency", transparency)
end

function UIState:ConnectEvent(element: GuiObject, eventName: string, callback: (...any) -> ())
	if element and element[eventName] then
		local conn = element[eventName]:Connect(callback)
		self.maid:Give(conn)
	end
end

function UIState:Cleanup()
	self.maid:DoCleaning()
end

return UIState
