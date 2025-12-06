--!strict
local ConsoleReporter = require(script.Parent:WaitForChild("ConsoleReporter"))

local MemoryManager = {}
MemoryManager.__index = MemoryManager

export type CleanupFn = () -> ()
export type Entry = {
	Id: number,
	Object: any,
	Cleanup: CleanupFn?,
}

local weakRegistry = setmetatable({}, { __mode = "v" }) :: { Entry }
local idCounter = 0

function MemoryManager.new()
	local self = setmetatable({}, MemoryManager)
	return self
end

function MemoryManager:Track(Object: any, Cleanup: CleanupFn?): Entry?
	if Object == nil then return nil end

	idCounter += 1
	local entry: Entry = {
		Id = idCounter,
		Object = Object,
		Cleanup = Cleanup,
	}

	table.insert(weakRegistry, entry)
	
	ConsoleReporter:SendMessage("MemoryManager", "Object tracked: " .. tostring(Object),"Warn")
	
	return entry
end

function MemoryManager:Destroy(entry: Entry)
	if entry == nil then return end

	if entry.Cleanup then
		entry.Cleanup()
	end

	for i = #weakRegistry, 1, -1 do
		if weakRegistry[i].Id == entry.Id then
			table.remove(weakRegistry, i)
			ConsoleReporter:SendMessage("MemoryManager", "Object destroyed: " .. tostring(entry.Object),"Warn")
			break
		end
	end
end

function MemoryManager:GetCount(): number
	local count = 0
	for _, entry in weakRegistry do
		if entry.Object then
			count += 1
		end
	end
	return count
end


function MemoryManager:CleanAll()
	for i = #weakRegistry, 1, -1 do
		local entry = weakRegistry[i]
		if entry.Cleanup then
			entry.Cleanup()
		end
		table.remove(weakRegistry, i)
	end
	ConsoleReporter:SendMessage("MemoryManager", "All objects cleaned","Warn")
end

return MemoryManager
