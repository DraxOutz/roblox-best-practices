# Roblox UI & Game Framework

Framework modular para Roblox que gerencia UI, currencies, networking, animações e estados de objetos de forma organizada e segura.

---

## 1. Módulos disponíveis

- `ClientCurrencies` – Gerencia moedas/valores recebidos do server.
- `Maid` – Gerencia tarefas e eventos, garantindo limpeza automática.
- `Network` – Facilita comunicação entre cliente e servidor via RemoteEvents.
- `TweenUtil` – Tweening e animações de UI.
- `UIManager` – Controle de telas primárias e overlays.
- `UIState` – Manipulação de propriedades de elementos de UI e conexão de eventos.
- `Config` – Configurações padrão para UI, texto, input e debug.

---

## 2. ClientCurrencies

Gerencia moedas ou valores recebidos do server.

```lua
local Currencies = require(game.ReplicatedStorage.ClientCurrencies)

-- Definir ou atualizar valor
Currencies:Set("Gold", 100)

-- Adicionar valor
Currencies:Add("Gold", 50)

-- Subtrair valor
Currencies:Subtract("Gold", 30)

-- Obter valor atual
local gold = Currencies:Get("Gold")

-- Obter todas as moedas
local allCurrencies = Currencies:GetAll()

-- Resetar todas
Currencies:Reset()
```

---

## 3. Maid

Gerencia tarefas e eventos de forma automática.

```lua
local Maid = require(game.ReplicatedStorage.Maid)

local maid = Maid.new()

-- Adiciona tarefas
maid:Give(someConnectionOrInstance)

-- Limpa todas as tarefas
maid:DoCleaning()
```

---

## 4. Network

Comunicação cliente-servidor via RemoteEvents.

```lua
local Network = require(game.ReplicatedStorage.Network)

-- Envia dados para o servidor
Network:Fire("SomeRemote", arg1, arg2)

-- Recebe dados do servidor
Network:Listen("SomeRemote", function(arg1, arg2)
    print(arg1, arg2)
end)
```

---

## 5. TweenUtil

Animações de UI: fades, posição, tamanho, texto e efeito de digitação.

```lua
local TweenUtil = require(game.ReplicatedStorage.TweenUtil)

-- Fade
TweenUtil.FadeIn(myFrame, 0.5)
TweenUtil.FadeOut(myFrame, 0.5)

-- Tween de posição e tamanho
TweenUtil.TweenPosition(myFrame, UDim2.new(0.5, 0, 0.5, 0), 0.5)
TweenUtil.TweenSize(myFrame, UDim2.new(0, 300, 0, 150), 0.5)

-- Texto
TweenUtil.FadeText(myLabel, 0.5, true)
TweenUtil.TypeText(myLabel, "Olá mundo!", 0.05)
```

---

## 6. UIManager

Gerencia telas primárias e overlays.

```lua
local UIManager = require(game.ReplicatedStorage.UIManager)

-- Abrir tela principal (fecha a anterior automaticamente)
UIManager.Open(myScreen)

-- Fechar tela
UIManager.Close(myScreen)

-- Fechar tela atual
UIManager.CloseCurrent()

-- Abrir/fechar overlays
UIManager.OpenOverlay(myTooltip)
UIManager.CloseOverlay(myTooltip)
```

---

## 7. UIState

Manipula propriedades de elementos de UI e conecta eventos com limpeza automática.

```lua
local UIState = require(game.ReplicatedStorage.UIState)

-- Alterar propriedades
UIState:SetVisible(myFrame, true)
UIState:SetColor(myFrame, Color3.fromRGB(255, 0, 0))
UIState:SetSize(myFrame, UDim2.new(0, 200, 0, 100))
UIState:SetPosition(myFrame, UDim2.new(0.5, -100, 0.5, -50))
UIState:SetText(myLabel, "Olá, jogador!")
UIState:SetTransparency(myFrame, 0.5)

-- Conectar eventos de forma segura
UIState:ConnectEvent(myButton, "MouseButton1Click", function()
    print("Botão clicado!")
end)

-- Limpar eventos e objetos gerenciados
UIState:Cleanup()
```

---

## 8. Config

Configurações padrão do framework.

```lua
local Config = require(game.ReplicatedStorage.Config)

-- UI
print(Config.UI.DefaultFadeTime)
print(Config.UI.DefaultTweenTime)

-- Texto
print(Config.Text.DefaultTypingSpeed)

-- Input
print(Config.Input.DefaultClickDelay)

-- Debug
print(Config.Debug.EnableLogs)
```

---

## 9. Exemplo completo de uso

```lua
local UIManager = require(game.ReplicatedStorage.UIManager)
local UIState = require(game.ReplicatedStorage.UIState)
local TweenUtil = require(game.ReplicatedStorage.TweenUtil)
local Currencies = require(game.ReplicatedStorage.ClientCurrencies)

-- Abrir tela
UIManager.Open(myScreen)

-- Atualizar texto de ouro
local gold = Currencies:Get("Gold")
UIState:SetText(myLabel, "Ouro: " .. gold)

-- Fade in da tela
TweenUtil.FadeIn(myScreen, 0.5)

-- Conectar botão
UIState:ConnectEvent(myButton, "MouseButton1Click", function()
    print("Botão clicado!")
end)
```
