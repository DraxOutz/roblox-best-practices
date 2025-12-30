--!strict
-- @module UIManager
-- @desc Gerencia telas principais (exclusive) e overlays (não exclusive) com tipagem estrita e guard clauses.
--       Suporte a integração com Maid para gerenciamento futuro de cleanup, se necessário.

local UIManager = {}
UIManager.__index = UIManager

-- @type UIManagerType
-- @desc Interface do UIManager com todas as funções públicas disponíveis
export type UIManagerType = {
	-- @param frame GuiObject: tela a abrir
	-- @return void
	Open: (frame: GuiObject) -> (),

	-- @param frame GuiObject: tela a fechar
	-- @return void
	Close: (frame: GuiObject) -> (),

	-- Fecha a tela principal atualmente aberta
	-- @return void
	CloseCurrent: () -> (),

	-- Retorna a tela principal atualmente aberta ou nil
	-- @return GuiObject?
	GetCurrent: () -> GuiObject?,

	-- Abre um overlay sem interferir na tela principal
	-- @param frame GuiObject: overlay a abrir
	-- @return void
	OpenOverlay: (frame: GuiObject) -> (),

	-- Fecha um overlay específico
	-- @param frame GuiObject: overlay a fechar
	-- @return void
	CloseOverlay: (frame: GuiObject) -> (),
}

-- @private
-- Tela principal atualmente aberta
local CurrentFrame: GuiObject?

-- @desc Abre uma tela principal (exclusive)
--       Fecha automaticamente a tela anterior, se houver.
-- @param frame GuiObject: tela a abrir
function UIManager.Open(frame: GuiObject)
	assert(frame and frame:IsA("GuiObject"), "[UIManager] Open: Frame inválido")
	if CurrentFrame == frame then return end

	if CurrentFrame then
		CurrentFrame.Visible = false
	end

	CurrentFrame = frame
	CurrentFrame.Visible = true
end

-- @desc Fecha uma tela principal específica
-- @param frame GuiObject: tela a fechar
function UIManager.Close(frame: GuiObject)
	assert(frame and frame:IsA("GuiObject"), "[UIManager] Close: Frame inválido")
	if CurrentFrame ~= frame then return end

	CurrentFrame.Visible = false
	CurrentFrame = nil
end

-- @desc Fecha a tela principal atualmente aberta, se houver
function UIManager.CloseCurrent()
	if CurrentFrame then
		CurrentFrame.Visible = false
		CurrentFrame = nil
	end
end

-- @desc Retorna a tela principal atualmente aberta
-- @return GuiObject? - tela atual ou nil
function UIManager.GetCurrent(): GuiObject?
	return CurrentFrame
end

-- @desc Abre um overlay sem afetar a tela principal
-- @param frame GuiObject: overlay a abrir
function UIManager.OpenOverlay(frame: GuiObject)
	assert(frame and frame:IsA("GuiObject"), "[UIManager] OpenOverlay: Frame inválido")
	frame.Visible = true
end

-- @desc Fecha um overlay
-- @param frame GuiObject: overlay a fechar
function UIManager.CloseOverlay(frame: GuiObject)
	assert(frame and frame:IsA("GuiObject"), "[UIManager] CloseOverlay: Frame inválido")
	frame.Visible = false
end

return UIManager
