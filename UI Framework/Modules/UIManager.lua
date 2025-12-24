--!strict
-- Gerencia telas primárias e overlays
local UIManager = {}
UIManager.__index = UIManager

local CurrentFrame: GuiObject?

function UIManager.Open(frame: GuiObject)
	if CurrentFrame == frame then return end
	if CurrentFrame then CurrentFrame.Visible = false end
	CurrentFrame = frame
	frame.Visible = true
end

function UIManager.Close(frame: GuiObject)
	if CurrentFrame ~= frame then return end
	CurrentFrame.Visible = false
	CurrentFrame = nil
end

function UIManager.CloseCurrent()
	if CurrentFrame then
		CurrentFrame.Visible = false
		CurrentFrame = nil
	end
end

function UIManager.GetCurrent(): GuiObject?
	return CurrentFrame
end

function UIManager.OpenOverlay(frame: GuiObject)
	frame.Visible = true
end

function UIManager.CloseOverlay(frame: GuiObject)
	frame.Visible = false
end

return UIManager
