---
tags: [feature, goals, core]
---

# Goals — Metas

Acompanhamento de metas de treino com progress visual. Acessível via [[explore]].

## Cards de metas
- Progress bar animada
- Categorias: Em andamento / Concluídas / Expiradas
- Card: título + ícone + porcentagem + dias restantes + último check-in
- Confetti ao atingir 100% 🎊 (`confetti` package)

## Tipos de meta
- Peso corporal
- PR específico (vincula a [[prs]])
- Frequência semanal
- Distância mensal

## Criação (multi-step)
1. Tipo de meta
2. Valor alvo
3. Prazo
4. Visibilidade (pública / privada)

## Check-in
- Manual via botão
- Automático ao registrar [[prs]] vinculado à meta
- Notificação de marco em 50% e 100% via [[notifications]]

## Código
- `lib/features/goals/`

## Modelo
```dart
GoalModel(
  id, type, title,
  target, unit,
  current, startDate, endDate,
  isPublic
)
```

## Relacionado
- [[explore]]
- [[prs]]
- [[notifications]]
- [[profile]]
- [[backend-api]]
