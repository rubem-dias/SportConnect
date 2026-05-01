---
tags: [feature, auth]
---

# Auth

Único provider ativo: **Google Sign-In**. E-mail/senha e Apple foram removidos.

## Fluxo

```
Google OAuth
  → Firebase Auth (signInWithCredential)
  → Firestore users/{uid} (findOrCreate)
  → authStateProvider (Riverpod)
  → se sports.isEmpty → Onboarding
  → senão → [[chat]]
```

## Onboarding (4 steps)
1. Selecionar esportes de interesse
2. Nível (Iniciante / Intermediário / Avançado)
3. Objetivo (Hipertrofia / Emagrecimento / Performance / Saúde)
4. Localização opt-in (para [[nearby]])

## Firestore: `users/{uid}`

| Campo | Tipo |
|---|---|
| email | String |
| name | String |
| avatar | String? |
| sports | List\<String\> |
| level | String |
| username | String? |
| createdAt | String (ISO) |

## Providers
- `authStateProvider` → `AsyncNotifier<UserModel?>` — fonte de verdade global
- `userFirestoreRepositoryProvider` → `findOrCreate`, `getUser`, `updateProfile`

## Sessão
Firebase Auth persiste sessão entre aberturas. O `_AuthInterceptor` no Dio busca ID token do Firebase a cada request — tokens não ficam em storage manual.

## Código
- `lib/features/auth/`
- `lib/shared/providers/auth_provider.dart`
- `lib/core/network/api_client.dart` (interceptor)

## Relacionado
- [[architecture]]
- [[state-management]]
- [[backend-api]]
- [[profile]]
