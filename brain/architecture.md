---
tags: [arch]
---

# Architecture

Flutter 3.x · Riverpod · Go Router · Dio · Hive · Firebase

## Estrutura por feature (Clean Architecture)

```
lib/features/<feature>/
  data/
    models/       → Freezed + JsonSerializable
    repositories/ → Implementações (Firestore, HTTP, Hive)
  domain/
    repositories/ → Interfaces abstratas
  presentation/
    screens/
    widgets/
    providers/    → @riverpod notifiers
```

## Flavors / Entry points

| Arquivo | Flavor | Comportamento |
|---|---|---|
| `main.dart` | prod | Firebase + API real |
| `main_staging.dart` | staging | Firebase + API staging |
| `main_dev.dart` | dev | Mocks, sem Firebase |

Ordem de init: Firebase → Mapbox token → timeago locale → ProviderScope

## Codegen
Após qualquer alteração em `@freezed`, `@riverpod`, `@JsonSerializable`: rodar `make gen`.

Arquivos `.g.dart` e `.freezed.dart` são gerados — não editar manualmente.

## Error surfacing
Erros sobem via `ref.pushError(...)` nos providers. `GlobalErrorListener` (em `app.dart`) escuta e renderiza snackbars. Nunca exibir erros direto dos widgets.

## Shared widgets
`lib/shared/widgets/`: `AppButton`, `AppTextField`, `AppAvatar`, `AppBadge`, `AppBottomSheet`, `AppSnackbar`, `AppLoadingSkeleton`, `AppEmptyState`. Usar antes de criar novos primitivos.

## Relacionado
- [[state-management]]
- [[design-system]]
- [[backend-api]]
- [[auth]]
- [[SportConnect]]
