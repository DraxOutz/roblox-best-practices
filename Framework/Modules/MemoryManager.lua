--!strict
-- MemoryManager.lua
-- Gerencia objetos e cleanup de forma segura, com rastreio e integração com ConsoleReporter

local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local MemoryManager = {}
MemoryManager.__index = MemoryManager

-- Tipos
export type CleanupFn = () -> ()
export type Entry = {
	Id: number,
	Object: any,
	Cleanup: CleanupFn?,
}

-- Registry fraco para não impedir garbage collection
local weakRegistry = setmetatable({}, { __mode = "v" }) :: { Entry }
local idCounter = 0

-- Cria nova instância
function MemoryManager.new(): MemoryManager
	local self = setmetatable({}, MemoryManager)
	return self
end

-- @desc Rastreia um objeto com cleanup opcional
-- @param Object: any - objeto a rastrear
-- @param Cleanup: CleanupFn? - função a ser chamada ao destruir
-- @return Entry? - referência da entrada
function MemoryManager:Track(Object: any, Cleanup: CleanupFn?): Entry?
	if Object == nil then return nil end

	idCounter += 1
	local entry: Entry = {
		Id = idCounter,
		Object = Object,
		Cleanup = Cleanup,
	}

	table.insert(weakRegistry, entry)
	ConsoleReporter:SendMessage("MemoryManager", "Object tracked: " .. tostring(Object), "Warn")

	return entry
end

-- @desc Destrói entrada rastreada, chama cleanup
-- @param entry: Entry - entrada a destruir
function MemoryManager:Destroy(entry: Entry)
	if not entry then return end

	if entry.Cleanup then
		entry.Cleanup()
	end

	for i = #weakRegistry, 1, -1 do
		if weakRegistry[i].Id == entry.Id then
			table.remove(weakRegistry, i)
			ConsoleReporter:SendMessage("MemoryManager", "Object destroyed: " .. tostring(entry.Object), "Warn")
			break
		end
	end
end

-- @desc Retorna quantidade de objetos ainda rastreados (ativos)
function MemoryManager:GetCount(): number
	local count = 0
	for _, entry in weakRegistry do
		if entry.Object then
			count += 1
		end
	end
	return count
end

-- @desc Limpa todos os objetos rastreados
function MemoryManager:CleanAll()
	for i = #weakRegistry, 1, -1 do
		local entry = weakRegistry[i]
		if entry.Cleanup then
			entry.Cleanup()
		end
		table.remove(weakRegistry, i)
	end
	ConsoleReporter:SendMessage("MemoryManager", "All objects cleaned", "Warn")
end

return MemoryManager
