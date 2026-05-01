---
tags: [feature, prs, core]
---

# PRs — Personal Records

Registro e acompanhamento de marcas pessoais por exercício. Acessível via [[explore]].

## Lista de exercícios
- Melhor marca de cada exercício
- Ícone de grupo muscular (peito, costas, pernas…)
- Filtros: grupo muscular, data, favoritos
- Badge "Novo PR!" em registros recentes
- Busca por exercício

## Registrar PR
- Selecionar exercício (busca + recentes + biblioteca)
- Criar exercício customizado
- Campos: valor + unidade, reps (opcional), data, observações
- Se valor > PR anterior → animação de celebração 🎉 + badge automático
- Toggle "Compartilhar no [[feed]]" com preview do card

## Detalhe do exercício
- Histórico cronológico
- Gráfico de linha (`fl_chart`) com filtros: 1M / 3M / 6M / 1A / Tudo
- Linha de tendência suavizada
- Anotações nos pontos de PR

## Offline-first
- Hive para persistência local
- Sincroniza ao voltar online

## Compartilhamento
- Card de PR aparece no [[chat]] como mensagem especial
- Pode ser postado no [[feed]]
- Atualiza [[goals]] automaticamente se meta vinculada

## Backend
```
GET  /prs?userId=
POST /prs
GET  /prs/{exerciseId}/history
```

## Código
- `lib/features/prs/`

## Modelos
- `ExerciseModel` (id, name, muscleGroup, isCustom, unit: kg/km/min)
- `PRModel` (id, exerciseId, value, unit, reps, date, notes, isShared)

## Relacionado
- [[explore]]
- [[goals]]
- [[chat]]
- [[feed]]
- [[profile]]
- [[backend-api]]
