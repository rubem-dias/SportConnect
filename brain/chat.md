---
tags: [feature, chat, core]
---

# Chat

Tela inicial do app. Interface Telegram-like com DMs, grupos e canais. WebSocket para real-time com fila offline via Hive.

## Lista de conversas
- DMs + grupos misturados, ordenados por última atividade
- Badge de mensagens não lidas
- Indicador de online (ponto verde no avatar)
- Swipe para arquivar / mutar
- Skeleton de carregamento na primeira carga

## Tela de chat
- `ListView.builder` invertido (mais recentes embaixo)
- Bubbles com status: enviando ⏳ / enviado ✓ / lido ✓✓
- Agrupamento por dia com separador de data
- Reply via swipe na mensagem
- Reactions via long press (emoji picker compacto)
- Indicador "fulano está digitando..."
- Paginação ao rolar para cima

## Tipos de mensagem
- Texto, foto, vídeo curto, áudio
- Card especial de compartilhamento de [[prs]]

## Grupos e Canais
- Criação: nome, foto, esporte, privado/público
- Admins podem: remover membros, fixar mensagens, editar info
- Convite por link compartilhável
- Canais: broadcast (só admins escrevem)

## Protocolo WebSocket
```
{ type, conversationId, payload, timestamp }

Tipos: message | typing | read | reaction | presence
```

## Infraestrutura
- Reconexão automática
- Fila de mensagens pendentes (envia ao reconectar)
- Persistência local: Hive
- Status de conexão: connected / reconnecting / offline

## Código
- `lib/features/chat/`

## Relacionado
- [[SportConnect]] (aba principal)
- [[notifications]]
- [[profile]]
- [[prs]] (card de PR no chat)
- [[backend-api]]
- [[state-management]]
