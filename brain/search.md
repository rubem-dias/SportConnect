---
tags: [feature, search]
---

# Search — Busca

Busca global com sugestões em tempo real e histórico local.

## Comportamento
- Barra de busca no topo (sobe ao digitar, estilo Telegram)
- Debounce de 300ms antes de disparar request
- Histórico de buscas recentes (local)
- Estado vazio mostra trending (integra com [[explore]])

## Tabs de resultado
- Tudo
- Usuários
- Grupos
- Posts (quando [[feed]] for retomado)
- Exercícios (integra com [[prs]])

## Busca de hashtag
- Abre feed filtrado por hashtag

## Código
- `lib/features/search/`

## Relacionado
- [[explore]]
- [[chat]]
- [[prs]]
- [[profile]]
- [[feed]]
- [[backend-api]]
