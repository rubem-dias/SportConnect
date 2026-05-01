---
tags: [feature, feed, paused]
---

# Feed

⚠️ **Pausado — fora do MVP atual.** O código existe mas a aba foi removida da navegação. Retomado em fase futura.

## Escopo planejado (quando retomar)
- Posts de treino: descrição, exercícios, fotos
- Card de [[prs]] destacado com badge 🏆
- Reactions rápidas (🔥 💪 🏆) com optimistic update
- Comentários com @menção e reply
- Pull-to-refresh + infinite scroll (cursor-based)
- Offline via Hive cache

## Stories
- Removidos da spec — decisão de não seguir o modelo Instagram

## Algoritmo de feed (futuro)
- Posts de seguidos + comunidades + localização (configurável)

## Backend
```
GET  /feed?page=&limit=
POST /posts
POST /posts/{id}/reaction
POST /posts/{id}/comments
```

## Código
- `lib/features/feed/`

## Relacionado
- [[explore]] (trending quando feed retornar)
- [[prs]] (compartilhar PR no feed)
- [[search]] (busca de posts)
- [[notifications]] (reactions, comentários)
- [[backend-api]]
