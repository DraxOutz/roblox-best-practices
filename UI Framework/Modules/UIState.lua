--!strict

local Maid = require(script.Parent:WaitForChild("Maid")) 

export type UIState = {
	maid: any,
	SetProperty: (self: UIState, element: GuiObject, property: string, value: any) -> (),
	SetText: (self: UIState, element: TextLabel | TextBox, text: string) -> (),
	SetColor: (self: UIState, element: GuiObject, color: Color3) -> (),
	SetSize: (self: UIState, element: GuiObject, size: UDim2) -> (),
	SetPosition: (self: UIState, element: GuiObject, position: UDim2) -> (),
	SetVisible: (self: UIState, element: GuiObject, visible: boolean) -> (),
	SetTransparency: (self: UIState, element: GuiObject, transparency: number) -> (),
	ConnectEvent: (self: UIState, element: GuiObject, eventName: string, callback: (...any) -> ()) -> (),
	Cleanup: (self: UIState) -> (),
}

local UIState: UIState = {}
UIState.maid = Maid.new()

function UIState:SetProperty(element: GuiObject, property: string, value: any): ()
	if element and element[property] ~= nil then
		element[property] = value
	end
end

function UIState:SetText(element: TextLabel | TextBox, text: string): ()
	self:SetProperty(element, "Text", text)
end

function UIState:SetColor(element: GuiObject, color: Color3): ()
	self:SetProperty(element, "BackgroundColor3", color)
end

function UIState:SetSize(element: GuiObject, size: UDim2): ()
	self:SetProperty(element, "Size", size)
end

function UIState:SetPosition(element: GuiObject, position: UDim2): ()
	self:SetProperty(element, "Position", position)
end

function UIState:SetVisible(element: GuiObject, visible: boolean): ()
	self:SetProperty(element, "Visible", visible)
end

function UIState:SetTransparency(element: GuiObject, transparency: number): ()
	self:SetProperty(element, "BackgroundTransparency", transparency)
end

function UIState:ConnectEvent(element: GuiObject, eventName: string, callback: (...any) -> ()): ()
	if element and element[eventName] then
		local connection = element[eventName]:Connect(callback)
		self.maid:Give(connection)
	end
end

function UIState:Cleanup(): ()
	self.maid:DoCleaning()
end

return UIState
