# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is SportConnect

SportConnect é uma plataforma mobile de comunidade esportiva. A proposta é ser socialmente fluida como o Telegram — rápido, limpo, orientado a conversas e grupos — mas com gamificação e tracking voltados para esporte. O usuário vem para conversar com sua turma de treino, encontrar quem treina perto dele e acompanhar sua evolução.

**Plataformas:** Android e iOS (P0); Flutter Web (P2, pós-MVP).  
**Backend:** Go (parceiro). Auth é Firebase-first, sem backend próprio. Features de social (chat, feed, nearby) usam REST + WebSocket.

### Bottom navigation — 5 abas

| Aba | Rota | Status | Descrição |
|---|---|---|---|
| **Chat** | `/chat` | ✅ Core | Tela inicial — DMs e grupos estilo Telegram |
| **Nearby** | `/nearby` | ✅ Core | Usuários e academias próximos no mapa (Mapbox) |
| **Eventos** | `/eventos` | 🔜 Placeholder | Eventos esportivos (Strava/Meetup-like) — tela existe mas feature não implementada |
| **Explorar** | `/explorar` | ✅ Core | Hub de features complementares (PRs, Metas, Trending) |
| **Perfil** | `/profile` | ✅ Core | Perfil público, stats, badges, conquistas |

### Autenticação (`features/auth/`)

Único provider ativo: **Google Sign-In**. E-mail/senha e Apple foram removidos.

Fluxo: `Google OAuth → Firebase Auth → Firestore users/{uid} (findOrCreate) → authStateProvider`.

Após login, se `sports.isEmpty` o app redireciona para onboarding (4 steps: esportes, nível, objetivo, localização). Caso contrário vai direto para `/chat`.

A sessão é gerenciada pelo Firebase Auth (persiste entre aberturas). Tokens não são armazenados manualmente — o `_AuthInterceptor` no Dio busca o ID token do Firebase a cada request.

### Chat (`features/chat/`)

Interface Telegram-like. Arquitetura WebSocket com fila de mensagens offline (Hive).

- Lista de conversas: DMs + grupos misturados, ordenados por última atividade, badge de não lidas
- Tela de chat: `ListView.builder` invertido, bubbles com status (⏳/✓/✓✓), agrupamento por dia, reply via swipe, reactions via long press, indicador de digitação
- Grupos: criação, membros, admins, convite por link, canais (broadcast)
- Tipos de mensagem suportados: texto, foto, vídeo curto, áudio, compartilhamento de PR
- Protocolo WS: `{type, conversationId, payload, timestamp}` — tipos: `message`, `typing`, `read`, `reaction`, `presence`

### Nearby (`features/nearby/`)

Descoberta de pessoas e academias próximas com privacidade opt-in.

- Mapa Mapbox com pins de usuários e academias
- Lista alternativa abaixo do mapa (acessibilidade)
- Filtros: raio (500m / 1km / 5km), esporte, nível
- Tap no pin abre bottom sheet com mini-perfil + botão "Treinar junto" (friend request)
- Privacidade: Exato / Bairro / Desativado — bairro não expõe coordenada exata

### Eventos (`features/events/`)

Tela placeholder. Feature completa planejada pós-MVP. Inspiração: Strava + Meetup (criação de corridas, peladas, treinos em grupo com localização e inscrição).

### Explorar (`features/explore/`)

Hub que agrupa features complementares sem poluir o bottom nav. Hoje expõe PRs e Metas; features futuras entram aqui antes de ganhar destaque próprio.

### PRs — Personal Records (`features/prs/`)

- Lista de exercícios com melhor marca de cada um (filtros por grupo muscular)
- Registrar PR: exercício + valor + reps + data; se bate o anterior → animação de celebração + badge automático
- Detalhe do exercício: histórico cronológico + gráfico de linha (`fl_chart`) com filtros de período
- Offline-first via Hive; sincroniza ao voltar online

### Metas (`features/goals/`)

- Cards com progress bar animada (Em andamento / Concluídas / Expiradas)
- Tipos: peso corporal, PR específico, frequência semanal, distância mensal
- Check-in automático ao registrar PR vinculado à meta
- Confetti ao atingir 100% (`confetti` package)

### Feed (`features/feed/`)

**⚠️ Pausado — fora do MVP atual.** O código existe mas a aba foi removida da navegação. Será retomado em fase futura.

## Commands

```bash
# Development
make dev             # Run with dev flavor (desktop/mocks)
make dev-android     # Run on Android emulator
make dev-usb         # Run on physical device
make dev-web         # Run on browser (Edge)

# Dependencies & codegen
make get             # flutter pub get
make gen             # One-shot build_runner (freezed, riverpod, json_serializable)
make gen-watch       # build_runner in watch mode

# Quality
make lint            # flutter analyze (warnings allowed)
make lint-strict     # flutter analyze (fail on warnings)
make test            # flutter test
make clean           # flutter clean + pub get
```

After adding/modifying any `@freezed`, `@riverpod`, or `@JsonSerializable` class, always run `make gen`.

Run a single test file: `flutter test test/path/to/test_file.dart`

## Architecture

Clean Architecture per feature (`data/` → `domain/` → `presentation/`), Riverpod for state + DI, Go Router for navigation.

### Entry points & flavors

Three flavors with separate `main_*.dart` files:
- `main_dev.dart` — injects mock repositories, skips Firebase requirements
- `main_staging.dart` / `main.dart` — real Firebase + real API

Initialization order in `main.dart`: Firebase → Mapbox token → timeago locale → `ProviderScope`.

### Dependency injection

Pure Riverpod — no GetIt. All providers are code-generated with `@riverpod` and live in `.g.dart` siblings. The global auth state is `authStateProvider` in `shared/providers/auth_provider.dart` (`AsyncNotifier<UserModel?>`); it is the single source of truth for the current user across the app.

The API client (`apiClientProvider`) auto-injects Firebase ID tokens via `_AuthInterceptor` and refreshes on 401. Base URL comes from flavor-scoped `.env.*` files read at build time via `--dart-define-from-file`.

### Router & navigation

`appRouterProvider` (Go Router) in `core/router/app_router.dart`. Auth redirect logic lives there — unauthenticated users are sent to `/login`. The shell route wraps five bottom-nav tabs (chat / nearby / events / explore / profile). Feature screens outside the shell (PRs, goals, notifications, search) are pushed as full-screen or modal pages using helpers in `app_page_transitions.dart`.

### Error surfacing pattern

Errors bubble through `ref.pushError(...)` inside providers/notifiers. `GlobalErrorListener` (mounted at `app.dart`) listens to the error stream and renders snackbars. Do not show errors directly from widgets — always push through the provider layer.

### Feature structure

```
lib/features/<feature>/
  data/
    models/          # Freezed data classes (@freezed + @JsonSerializable)
    repositories/    # Concrete implementations (Firestore, HTTP, Hive)
  domain/
    repositories/    # Abstract interfaces
  presentation/
    screens/
    widgets/
    providers/       # @riverpod notifiers / providers for this feature
```

### Shared widgets

`lib/shared/widgets/` exports reusable primitives: `AppButton`, `AppTextField`, `AppAvatar`, `AppBadge`, `AppBottomSheet`, `AppSnackbar`, `AppLoadingSkeleton`, `AppEmptyState`. Use these before creating new UI primitives.

### Theme & design tokens

All design values come from `lib/core/theme/`:
- Colors → `AppColors`
- Typography → `AppTypography`
- Spacing → `AppSpacing` (4/8/12/16/24/32/48 scale)
- Border radius → `AppRadius`
- Full theme (light + dark, Material 3) → `AppTheme`

### Localization

ARB files in `lib/l10n/` (pt and en). Generated classes accessed via the `l10n` extension (`context.l10n`). Add keys to both `.arb` files, then run `flutter gen-l10n` (handled automatically on `flutter run/build`).

## Key dependencies

| Concern | Package |
|---|---|
| State / DI | `flutter_riverpod` + `riverpod_generator` |
| Navigation | `go_router` |
| HTTP | `dio` + `pretty_dio_logger` |
| Auth | `firebase_auth` + `google_sign_in` |
| Database | `cloud_firestore` |
| Local cache | `hive_flutter` |
| Secure storage | `flutter_secure_storage` |
| Code gen | `freezed` + `json_serializable` + `build_runner` |
| Maps | `mapbox_maps_flutter` |
| Charts | `fl_chart` |

## Environment variables

Per-flavor `.env.*` files (not committed). Accessed via `Env.*` (code-generated by `envied`). Required variables: `API_BASE_URL`. Pass to Flutter with `--dart-define-from-file=.env.<flavor>.json`.
