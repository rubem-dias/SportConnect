---
tags: [feature, notifications]
---

# Notifications

Central de notificações in-app + push via FCM.

## In-app (implementado ✅)
- Lista cronológica de notificações
- Tipos: nova reaction, novo comentário, novo seguidor, PR batido por amigo, menção, marco de [[goals]]
- Ícone diferente por tipo
- Marcar como lida (tap) / marcar todas como lidas
- Badge na aba com contagem de não lidas

## Push — FCM (pendente 🔜)
- `firebase_messaging`
- Handler para foreground, background e terminated
- Deep link a partir da notificação → abre tela correta
- FCM token enviado ao backend ao logar

## Código
- `lib/features/notifications/`

## Relacionado
- [[chat]] (nova mensagem)
- [[prs]] (PR batido por amigo)
- [[goals]] (marco de progresso)
- [[profile]] (novo seguidor)
- [[feed]] (reaction, comentário)
- [[backend-api]]
