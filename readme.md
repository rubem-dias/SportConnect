# SportConnect 🏋️

> Plataforma de comunidade esportiva — compartilhe treinos, bata PRs, conecte-se com atletas próximos.

## Stack

- **Mobile:** Flutter 3.x (Dart)
- **Back-end:** Go (parceiro)
- **State:** Riverpod
- **Navegação:** Go Router
- **Real-time:** WebSocket
- **Cache:** Hive

## Docs

- [`SPEC.md`](./SPEC.md) — Especificação completa do produto
- [`TASKS.md`](./TASKS.md) — Breakdown de tasks por épico

## Setup Rápido

```bash
# Pré-requisitos: Flutter 3.x, Dart SDK
flutter pub get
flutter run --flavor dev
```

## Estrutura

```
lib/
├── core/          # Network, router, theme, utils
├── features/      # Auth, Feed, PRs, Goals, Chat, Nearby, Profile...
└── shared/        # Widgets, models, providers reutilizáveis
```
