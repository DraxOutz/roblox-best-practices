--!strict
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

-- Histórico de logs
local LogHistory: { LogEntry } = {}

-- Funções internas de envio
local function SendError(Title: string, Message: string)
	error(Title .. ": " .. Message)
	return 
end

local function SendWarn(Title: string, Message: string)
	warn(Title .. ": " .. Message)
end

local function SendPrint(Title: string, Message: string)
	print(Title .. ": " .. Message)
end

-- Dispatch table tipada
local Functions: { [MessageType]: (string, string) -> () } = {
	Error = SendError,
	Warn = SendWarn,
	Print = SendPrint,
}

-- Pega timestamp legível
local function GetTimestamp(): string
	local now = DateTime.now():ToLocalTime()
	return string.format("[%02d:%02d:%02d]", now.Hour, now.Minute, now.Second)
end

-- Cria nova instância do Logger (pode ter múltiplas instâncias se quiser)
function ConsoleReporter.new(): typeof(ConsoleReporter)
	local self = setmetatable({}, ConsoleReporter)
	return self
end

-- Envia mensagem pro output e salva no histórico
function ConsoleReporter:SendMessage(Title: string, Message: string, Type: MessageType)
	local ts = GetTimestamp()
	local logEntry: LogEntry = {
		Time = ts,
		Type = Type,
		Title = Title,
		Message = Message,
	}

	-- Salva histórico
	table.insert(LogHistory, logEntry)

	-- Dispara para Output
	local func = Functions[Type]
	if func then
		func(ts .. " " .. Title, Message)
	else
		SendError("[ConsoleReporter]", "Tipo inválido: " .. tostring(Type))
	end
end

-- Retorna histórico completo
function ConsoleReporter:GetHistory(): { LogEntry }
	return LogHistory
end

-- Limpa histórico de logs
function ConsoleReporter:ClearHistory()
	LogHistory = {}
end

-- Filtra histórico por tipo
function ConsoleReporter:GetHistoryByType(Type: MessageType): { LogEntry }
	local filtered: { LogEntry } = {}
	for _, entry in LogHistory do
		if entry.Type == Type then
			table.insert(filtered, entry)
		end
	end
	return filtered
end

return ConsoleReporter
