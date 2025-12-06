# Framework de Utilitários Roblox

## Objetivo Geral

O framework serve para padronizar funcionalidades essenciais em qualquer projeto Roblox, garantindo:

- Validação segura de dados e parâmetros.
- Gerenciamento de memória e limpeza de objetos/funções.
- Registro e execução de eventos internos.
- Gerenciamento de assets e recursos do jogo.
- Configurações globais e individuais por jogador.
- Comunicação cliente-servidor padronizada via RemoteEvents/RemoteFunctions.
- Logs e debug padronizados.

Ele deve ser utilizado como **base para todos os sistemas do jogo**, garantindo código limpo, manutenção mais fácil e segurança.

---

## ConsoleReporter

**Propósito:**  
Fornecer uma forma padronizada de registrar mensagens no Output, seja como erro, aviso ou print.

**Métodos Principais:**

- `SendMessage(title: string, message: string, type: "Print" | "Warn" | "Error")`  
  Envia a mensagem para o Output, padronizando o formato e tipo de log.

**Exemplo:**
```lua
ConsoleReporter:SendMessage("DEBUG", "Sistema iniciado", "Print")
ConsoleReporter:SendMessage("WARN", "Algo inesperado aconteceu", "Warn")
ConsoleReporter:SendMessage("ERROR", "Falha crítica detectada", "Error")
```

---

## GuardClause

**Propósito:**
Validar entradas de funções para evitar erros por valores inválidos.

**Métodos Principais:**

* `IsValid(value: any, expectedType?: string) -> boolean`
  Verifica se o valor existe e, opcionalmente, se é do tipo esperado.

* `IsValidNumber(value: any, min?: number, max?: number) -> boolean`
  Verifica se o valor é um número e se está dentro de um intervalo.

**Exemplo:**

```lua
Guard:IsValid(nil) -- false
Guard:IsValid("teste", "string") -- true
Guard:IsValidNumber(5, 1, 10) -- true
Guard:IsValidNumber(15, 1, 10) -- false
```

---

## MemoryManager

**Propósito:**
Gerenciar objetos/funções temporários e seus cleanups para evitar vazamentos de memória.

**Métodos Principais:**

* `Track(object: any, cleanup?: function) -> Entry`
  Registra um objeto ou função com cleanup opcional.

* `Destroy(entry: Entry)`
  Remove objeto/função registrado e executa cleanup.

* `CleanAll()`
  Limpa todos objetos/funções registrados e executa cleanups.

* `GetCount() -> number`
  Retorna quantos objetos estão registrados.

**Exemplo:**

```lua
local entry = MemoryManager:Track(part, function() part:Destroy() end)
MemoryManager:CleanAll()
print(MemoryManager:GetCount())
```

---

## ResourceManager

**Propósito:**
Gerenciar assets do jogo (Parts, Models, etc.), permitindo registrar, acessar e limpar recursos facilmente.

**Métodos Principais:**

* `Load(key: string, obj: Instance)`
  Registra um asset.

* `Get(key: string) -> Instance?`
  Retorna o asset registrado ou `nil`.

* `Remove(key: string)`
  Remove um asset específico.

* `ClearAll()`
  Limpa todos assets registrados.

**Exemplo:**

```lua
ResourceManager:Load("DebugPart", part)
local part = ResourceManager:Get("DebugPart")
ResourceManager:ClearAll()
```

---

## EventManager

**Propósito:**
Gerenciar eventos internos do jogo de forma organizada, sem depender de eventos externos do Roblox.

**Métodos Principais:**

* `Connect(eventName: string, callback: function)`
  Conecta função a evento interno.

* `Fire(eventName: string, ...)`
  Dispara o evento e executa funções conectadas.

**Exemplo:**

```lua
EventManager:Connect("PlayerJoined", function(player)
    print(player.Name.." entrou no jogo")
end)
EventManager:Fire("PlayerJoined", player)
```

---

## NetworkManager

**Propósito:**
Gerenciar RemoteEvents e RemoteFunctions para comunicação cliente-servidor.

**Métodos Principais:**

* `RegisterEvent(name: string, RemoteEvent)`
  Registra RemoteEvent para uso.

* `Connect(name: string, callback: function)`
  Conecta função ao RemoteEvent.

* `Fire(name: string, player?: Player, data: any)`
  Dispara RemoteEvent para servidor ou cliente.

**Exemplo:**

```lua
local remote = Instance.new("RemoteEvent")
remote.Name = "TesteRemote"
remote.Parent = game.ReplicatedStorage

NetworkManager:RegisterEvent("TesteRemote", remote)
NetworkManager:Connect("TesteRemote", function(player, data)
    print(player.Name, "disparou evento com dado:", data)
end)
NetworkManager:Fire("TesteRemote", nil, "Teste dado")
```

---

## ConfigManager

**Propósito:**
Gerenciar configurações globais e individuais por jogador, permitindo ajustes dinâmicos e armazenamento seguro.

**Métodos Principais:**

* `SetGlobal(key: string, value: any)` / `GetGlobal(key: string)`
  Define ou lê valores globais do jogo.

* `SetPlayer(player: Player, key: string, value: any)` / `GetPlayer(player: Player, key: string)`
  Define ou lê configurações específicas de cada jogador.

* `ClearPlayer(player: Player)`
  Limpa todas configurações de um jogador.

* `GetGlobalCount() -> number`
  Retorna a quantidade de configurações globais.

**Exemplo:**

```lua
ConfigManager:SetGlobal("DebugMode", true)
print(ConfigManager:GetGlobal("DebugMode"))

ConfigManager:SetPlayer(player, "XP", 100)
print(ConfigManager:GetPlayer(player, "XP"))

ConfigManager:ClearPlayer(player)
```

---
## Como usar?

- Utilize o **GuardClause** para validações antes da aplicação da lógica.
- Utilize o **ConsoleReporter** para mensagens de debug.
- Utilize o **ConfigManager** para configuração de valores e estados.
- Utilize o **EventManager** para criar e gerenciar eventos internos.
- Utilize o **NetworkManager** para validações dos dados do cliente antes de disparar o **EventManager**.
- Utilize o **MemoryManager** para controlar ciclo de vida de objetos e callbacks.
- Utilize o **ResourceManager** para agrupar vários recursos e limpar tudo de uma vez.

## Exemplo

Flow:
Client → NetworkManager → GuardClause → ConfigManager

```lua
NetworkManager:BindEvent("Roll", function(player)
    Guard.IsPlayer(player)
    ConfigManager:SetPlayer(player, "CanRoll", false)
end)
```


## Conclusão

O framework garante:

* Validação segura de dados.
* Controle centralizado de memória.
* Gerenciamento de recursos e assets.
* Eventos internos organizados.
* Comunicação servidor-cliente padronizada.
* Configurações globais e individuais.
* Logs e debug padronizados.

Ele deve ser utilizado como **base para todos os sistemas do jogo**, garantindo código limpo, manutenção mais fácil e segurança em operações críticas.


## Créditos

Feito por [DraxOutz](https://github.com/DraxOutz)  
Revisado por [Puelor](https://github.com/puelor)
