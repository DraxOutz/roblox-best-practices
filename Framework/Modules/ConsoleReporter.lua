--!strict
-- ConsoleReporter.lua
-- Logger avançado com histórico por instância, dispatch seguro e timestamps legíveis.

local ConsoleReporter = {}
ConsoleReporter.__index = ConsoleReporter

-- Tipos
export type MessageType = "Error" | "Warn" | "Print"

export type LogEntry = {
	Time: string,
	Type: MessageType,
	Title: string,
	Message: string,
}

export type ConsoleReporterType = typeof(ConsoleReporter.new())

-- Cria uma nova instância do Logger
function ConsoleReporter.new(): ConsoleReporterType
	local self = setmetatable({}, ConsoleReporter)
	self.LogHistory = {} :: { LogEntry }
	self.Functions = {
		Error = function(title: string, message: string)
			error(title .. ": " .. message)
		end,
		Warn = function(title: string, message: string)
			warn(title .. ": " .. message)
		end,
		Print = function(title: string, message: string)
			print(title .. ": " .. message)
		end,
	} :: { [MessageType]: (string, string) -> () }
	return self
end

-- Gera timestamp legível
function ConsoleReporter:GetTimestamp(): string
	local now = DateTime.now():ToLocalTime()
	return string.format("[%02d:%02d:%02d]", now.Hour, now.Minute, now.Second)
end

-- Envia mensagem e salva no histórico
function ConsoleReporter:SendMessage(Title: string, Message: string, Type: MessageType)
	local ts = self:GetTimestamp()
	local logEntry: LogEntry = {
		Time = ts,
		Type = Type,
		Title = Title,
		Message = Message,
	}

	-- Salva histórico
	table.insert(self.LogHistory, logEntry)

	-- Dispara para output
	local func = self.Functions[Type]
	if func then
		func(ts .. " " .. Title, Message)
	else
		error("[ConsoleReporter] Tipo inválido: " .. tostring(Type))
	end
end

-- Retorna histórico completo da instância
function ConsoleReporter:GetHistory(): { LogEntry }
	return self.LogHistory
end

-- Limpa histórico da instância
function ConsoleReporter:ClearHistory()
	self.LogHistory = {}
end

-- Filtra histórico por tipo
function ConsoleReporter:GetHistoryByType(Type: MessageType): { LogEntry }
	local filtered: { LogEntry } = {}
	for _, entry in self.LogHistory do
		if entry.Type == Type then
			table.insert(filtered, entry)
		end
	end
	return filtered
end

return ConsoleReporter
