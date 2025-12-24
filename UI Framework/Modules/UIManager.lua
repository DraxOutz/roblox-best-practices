--!strict
-- UIManager.lua
-- Gerencia telas primárias (exclusive) e overlays (não exclusive)

local UIManager = {}
UIManager.__index = UIManager

-- Tipagem exportada
export type UIManagerType = {
	Open: (frame: GuiObject) -> (),
	Close: (frame: GuiObject) -> (),
	CloseCurrent: () -> (),
	GetCurrent: () -> GuiObject?,
	OpenOverlay: (frame: GuiObject) -> (),
	CloseOverlay: (frame: GuiObject) -> (),
}

-- Tela principal atualmente aberta (apenas 1 por vez)
local CurrentFrame: GuiObject?

-- Abre uma tela principal (exclusive)
-- Fecha automaticamente a tela anterior, se houver
function UIManager.Open(frame: GuiObject)
	if not frame then
		warn("UIManager.Open: Frame inválido")
		return
	end

	if CurrentFrame == frame then
		return -- já está aberta
	end

	if CurrentFrame then
		CurrentFrame.Visible = false
	end

	CurrentFrame = frame
	CurrentFrame.Visible = true
end

-- Fecha uma tela principal específica
function UIManager.Close(frame: GuiObject)
	if not frame then
		warn("UIManager.Close: Frame inválido")
		return
	end

	if CurrentFrame ~= frame then
		return -- frame não está aberto
	end

	CurrentFrame.Visible = false
	CurrentFrame = nil
end

-- Fecha a tela principal atualmente aberta, se houver
function UIManager.CloseCurrent()
	if CurrentFrame then
		CurrentFrame.Visible = false
		CurrentFrame = nil
	end
end

-- Retorna a tela principal atualmente aberta
function UIManager.GetCurrent(): GuiObject?
	return CurrentFrame
end

-- Abre um overlay (não afeta a tela principal)
-- Útil para tooltips, notificações ou modais
function UIManager.OpenOverlay(frame: GuiObject)
	if not frame then
		warn("UIManager.OpenOverlay: Frame inválido")
		return
	end

	frame.Visible = true
end

-- Fecha um overlay
function UIManager.CloseOverlay(frame: GuiObject)
	if not frame then
		warn("UIManager.CloseOverlay: Frame inválido")
		return
	end

	frame.Visible = false
end

-- Exemplo de uso:
-- UIManager.Open(myMainFrame)
-- UIManager.OpenOverlay(myTooltip)
-- UIManager.CloseCurrent()

return UIManager

