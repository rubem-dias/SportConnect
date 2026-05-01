---
tags: [arch, riverpod]
---

# State Management

Riverpod puro — sem GetIt, sem BLoC.

## Padrão
- Providers definidos com `@riverpod` (code generation)
- `AsyncNotifier` para estado assíncrono com ciclo de vida
- Arquivos `.g.dart` gerados via `build_runner`

## Providers globais chave

| Provider | Tipo | Responsabilidade |
|---|---|---|
| `authStateProvider` | `AsyncNotifier<UserModel?>` | Usuário logado — fonte de verdade global |
| `apiClientProvider` | Provider | HTTP client com interceptors |
| `appRouterProvider` | Provider | Go Router com auth guard |

## Auth guard
`appRouterProvider` em `core/router/app_router.dart` redireciona para `/login` se `authStateProvider` retornar null.

## DI de repositórios
Cada feature tem seus providers de repositório injetados via Riverpod. No flavor dev, `main_dev.dart` sobrescreve os providers com mocks.

## Relacionado
- [[architecture]]
- [[auth]]
- [[backend-api]]
