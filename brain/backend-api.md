---
tags: [arch, backend]
---

# Backend API

Backend em Go (parceiro). Auth é Firebase-first — sem backend próprio para autenticação.

## Auth
Não usa backend. Ver [[auth]] para o fluxo Firebase.  
Se no futuro precisar de lógica server-side: Firebase ID Token → `POST /auth/social/google` → JWT próprio.

## Endpoints por feature

### Feed ([[feed]])
```
GET  /feed?page=&limit=
POST /posts
POST /posts/{id}/reaction
POST /posts/{id}/comments
```

### PRs ([[prs]])
```
GET  /prs?userId=
POST /prs
GET  /prs/{exerciseId}/history
```

### Chat ([[chat]])
```
WebSocket: /ws/chat
GET  /conversations
GET  /conversations/{id}/messages
POST /conversations/{id}/messages
```

### Nearby ([[nearby]])
```
GET  /nearby/users?lat=&lng=&radius=
GET  /nearby/gyms?lat=&lng=&radius=
```

## Padrões
- Formato: REST JSON + WebSocket para real-time
- Auth: Bearer JWT (access + refresh token)
- Paginação: cursor-based preferencial

## HTTP Client
Dio com interceptors em `lib/core/network/api_client.dart`:
1. `_AuthInterceptor` — injeta Firebase ID token, retry em 401
2. `PrettyDioLogger` — logs em dev

Base URL via `Env.API_BASE_URL` (por flavor, via `--dart-define-from-file`).

## Relacionado
- [[architecture]]
- [[state-management]]
- [[auth]]
- [[chat]]
- [[prs]]
- [[nearby]]
- [[feed]]
