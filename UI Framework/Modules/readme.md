# Roblox UI & Game Framework

Framework modular para Roblox que gerencia UI, currencies, networking, animações e estados de objetos de forma organizada e segura.

---

## **1. Módulos disponíveis**

- `ClientCurrencies` – Gerencia moedas/valores recebidos do server.  
- `Maid` – Gerencia tarefas e eventos, garantindo limpeza automática.  
- `Network` – Facilita comunicação entre cliente e servidor via RemoteEvents.  
- `TweenUtil` – Tweening e animações de UI.  
- `UIManager` – Controle de telas primárias e overlays.  
- `UIState` – Manipulação de propriedades de elementos de UI e conexão de eventos.  
- `Config` – Configurações padrão para UI, texto, input e debug.

---

## **2. ClientCurrencies**

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
