--!strict

local UIManager = {}

-- Only ONE primary UI can be active at a time
local CurrentFrame: GuiObject?
-- Opens a primary screen (exclusive)
-- Automatically closes the previous one
function UIManager.Open(Frame: GuiObject)
	if CurrentFrame == Frame then
		return -- already open, no-op
	end

	if CurrentFrame then
		CurrentFrame.Visible = false
	end

	CurrentFrame = Frame
	Frame.Visible = true
end

-- Closes a specific screen
function UIManager.Close(Frame: GuiObject)
	if CurrentFrame ~= Frame then
		return -- not managed as current
	end

	Frame.Visible = false
	CurrentFrame = nil
end

-- Closes the currently opened screen, if any
function UIManager.CloseCurrent()
	if not CurrentFrame then
		return
	end

	CurrentFrame.Visible = false
	CurrentFrame = nil
end

-- Returns the current active screen
function UIManager.GetCurrent(): GuiObject?
	return CurrentFrame
end

-- Opens an overlay UI (does NOT affect CurrentFrame)
-- Example: tooltips, notifications, modals
function UIManager.OpenOverlay(Frame: GuiObject)
	Frame.Visible = true
end

-- Closes an overlay UI
function UIManager.CloseOverlay(Frame: GuiObject)
	Frame.Visible = false
end

return UIManager
