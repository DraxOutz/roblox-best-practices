# Framework de Utilitários Roblox

## Objetivo Geral

O framework serve para padronizar funcionalidades essenciais em qualquer projeto Roblox, garantindo **segurança, organização e fácil manutenção**. Ele centraliza módulos comuns em um só lugar, permitindo:

- Evitar bugs por valores inválidos.
- Gerenciar memória e limpeza de objetos/funções.
- Registrar eventos e recursos do jogo.
- Configurar parâmetros globais e por jogador.
- Facilitar debug e logs padronizados.
- Integrar comunicação via RemoteEvents/RemoteFunctions.

Ele deve ser utilizado como base para todos os sistemas do jogo.

---

## GuardClause

**Propósito:**  
Validar entradas de funções e evitar erros por valores inválidos.

**Principais métodos:**

- `IsValid(Value, expectedType?) -> boolean`  
  Verifica se um valor não é `nil` e, opcionalmente, se é do tipo esperado.  
  **Exemplo:**  
  ```lua
  Guard:IsValid("teste", "string") -- retorna true
  Guard:IsValid(nil) -- retorna false
