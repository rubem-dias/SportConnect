# SportConnect — Especificação do Projeto

> **Nome sugerido:** `SportConnect` (substitui GymConnected para cobrir academia + outros esportes)  
> **Repositório atual:** `SportConnect/` · Flutter em `src/`  
> **Versão:** 1.0 — Draft inicial

---

## 1. Visão Geral

SportConnect é uma plataforma mobile de comunidade esportiva com foco em experiência de treino compartilhada. A proposta é ser socialmente fluida como o Telegram — rápido, limpo, orientado a conversas e grupos — mas com camadas de gamificação e tracking voltadas para esporte.

O usuário vem para conversar com sua turma de treino, encontrar alguém que treina perto dele ou descobrir eventos esportivos. Fica pela comunidade.

### Navegação principal (bottom nav)

| # | Aba | Descrição | Status |
|---|---|---|---|
| 1 | **Chat** | Tela inicial — DMs e grupos (estilo Telegram) | ✅ Core |
| 2 | **Nearby** | Usuários próximos por localização | ✅ Core |
| 3 | **Eventos** | Eventos esportivos (estilo Strava/Meetup) | 🔜 Futuro |
| 4 | **Explorar** | Hub de features adicionais (PRs, Metas, etc.) | ✅ Core |
| 5 | **Perfil** | Perfil do usuário | ✅ Core |

> Features adicionais crescem dentro de **Explorar** sem poluir a navegação principal.

---

## 2. Decisão de Framework

| Critério | Flutter | React Native |
|---|---|---|
| Consistência visual iOS/Android | ✅ Total controle | ⚠️ Depende de bridge |
| Animações tipo Telegram | ✅ Nativo (Skia/Impeller) | ⚠️ Reanimated necessário |
| Performance em listas longas (feed) | ✅ | ⚠️ FlatList com ressalvas |
| Tipagem forte (parceiro Go) | ✅ Dart tipado | ⚠️ TS opcional |
| Ecossistema para real-time | ✅ Maduro | ✅ Maduro |

**Decisão: Flutter (Dart)**  
Stack: Flutter 3.x · Riverpod (state) · Go Router (navegação) · Dio (HTTP) · Hive (cache local) · Socket.IO ou gRPC (real-time)

---

## 3. Arquitetura

```
lib/
├── core/
│   ├── network/          # Dio client, interceptors, endpoints
│   ├── storage/          # Hive boxes, secure storage
│   ├── router/           # Go Router + guards de autenticação
│   ├── theme/            # Design tokens, cores, tipografia
│   └── utils/            # Formatadores, helpers
├── features/
│   ├── auth/             # Login, registro, onboarding
│   ├── chat/             # DMs e grupos (estilo Telegram) — tela inicial
│   ├── nearby/           # Usuários próximos
│   ├── eventos/          # Eventos esportivos (futuro — Strava/Meetup-like)
│   ├── explorar/         # Hub de features adicionais
│   ├── prs/              # Personal Records (acessível via Explorar)
│   ├── goals/            # Metas e progresso (acessível via Explorar)
│   ├── feed/             # Feed de posts — pausado, fora do MVP atual
│   ├── profile/          # Perfil, stats, conquistas
│   ├── search/           # Busca global
│   └── notifications/    # Central de notificações
├── shared/
│   ├── widgets/          # Componentes reutilizáveis
│   ├── models/           # Entidades de domínio
│   └── providers/        # Providers globais (Riverpod)
└── main.dart
```

Padrão por feature: **Feature → Repository → Provider → UI**  
Sem BLoC; Riverpod com `AsyncNotifier` e `StateNotifier`.

---

## 4. Funcionalidades

### 4.1 Autenticação
- Registro com e-mail + senha
- Login social (Google, Apple)
- Onboarding: esportes de interesse, objetivo, nível
- Recuperação de senha

### 4.2 Feed / Home ⚠️ Pausado — fora do MVP atual
O feed existe no código mas está desativado da navegação principal. Será retomado numa fase futura.

Escopo planejado (quando retomar):
- **Posts de treino:** descrição, exercícios, fotos/vídeos curtos
- **PR compartilhado:** card destacado com exercício + peso + badge
- Reactions rápidas (🔥 💪 🏆)
- Comentários
- Algoritmo: posts de seguidos + comunidades + localização (configurável)

> **Stories removidos** — decisão de não seguir o modelo Instagram.

### 4.3 Personal Records (PRs)
- Registro por exercício: peso × reps × data
- Histórico com gráfico de evolução
- Badge automático ao bater PR
- Comparativo com média da comunidade (anônimo)
- Exercícios customizáveis + biblioteca padrão

### 4.4 Metas
- Criação de meta: tipo (peso, distância, frequência), prazo
- Progress bar visual
- Check-in semanal
- Notificação de marco (50%, 100%)
- Metas públicas ou privadas

### 4.5 Chat / Comunicação
Interface Telegram-like:
- **DM:** mensagem direta entre usuários
- **Grupos:** grupos de treino, turmas, comunidades por esporte
- **Canais:** conteúdo broadcast (coaches, influenciadores fitness)
- Suporte a: texto, foto, vídeo curto, GIF, áudio, compartilhamento de PR
- Indicador de digitação, lido/entregue
- Reações em mensagens
- Reply e forward de mensagem

### 4.6 Usuários Próximos
- Mapa com usuários/academias no raio configurável
- Filtros: esporte, nível, disponibilidade para treinar junto
- Privacidade: compartilhamento de localização opcional (bairro ou exato)
- Request de "treinar junto" (como friend request)

### 4.7 Perfil
- Avatar, bio, esportes praticados
- Stats: PRs, posts, seguidores, seguindo
- Galeria de treinos
- Mural de conquistas (badges)
- Cronologia de atividade física

### 4.8 Eventos 🔜 Futuro
Inspirado no Strava e Meetup:
- Criação e divulgação de eventos esportivos (corridas, peladas, treinos em grupo)
- Localização, data, vagas e tipo de esporte
- Inscrição e confirmação de presença
- Integração com Nearby (eventos próximos)

> Tela já existente no app como placeholder. Feature completa planejada para pós-MVP.

### 4.9 Explorar — Hub de Features Adicionais
Aba dedicada a features complementares ao core, permitindo crescimento sem poluir o bottom nav:
- **PRs** (Personal Records)
- **Metas**
- Features futuras entram aqui antes de ganhar destaque próprio

### 4.10 Busca e Descoberta
- Busca global: usuários, grupos, exercícios, academias
- Explorar: trending por esporte, região
- Hashtags em posts

### 4.11 Notificações
- Push (FCM)
- In-app notification center
- Configuração granular por tipo

---

## 5. Design System

Referência visual: Telegram + nuances de apps fitness (Strava, Whoop).

| Token | Valor |
|---|---|
| Primary | `#5C6BC0` (índigo vibrante) |
| Secondary | `#FF7043` (laranja energia) |
| Background dark | `#1A1A2E` |
| Background light | `#F5F5F5` |
| Surface | `#FFFFFF` / `#16213E` |
| Success (PR badge) | `#00C853` |
| Font | Inter (display) + Roboto (corpo) |
| Border radius padrão | 12px |
| Chat bubble radius | 18px |

Suporte a **Dark Mode e Light Mode** desde o dia 1.

---

## 5-B. Arquitetura de Autenticação (Firebase-first)

> **Decisão (2025-04):** auth não usa back-end próprio. Toda autenticação e persistência de perfil passa pelo Firebase.

### Fluxo

```
App → Google Sign-In → Firebase Auth (signInWithCredential)
                     ↓
              Firestore users/{uid}
              findOrCreate → UserModel
                     ↓
              authStateProvider (Riverpod)
```

### Pacotes ativos

| Pacote | Função |
|---|---|
| `firebase_core` | inicialização |
| `firebase_auth` | sessão OAuth |
| `cloud_firestore` | perfil do usuário |
| `google_sign_in` | fluxo OAuth Google |

### Coleção Firestore: `users/{uid}`

```
email        String
name         String
avatar       String?
sports       List<String>   ← salvo no onboarding
level        String         ← salvo no onboarding
username     String?        ← salvo no onboarding
createdAt    String (ISO)
```

### Regras de segurança (Firestore)

```js
match /users/{uid} {
  allow read, write: if request.auth.uid == uid;
}
```

### Providers relevantes

- `authStateProvider` — `AsyncNotifier<UserModel?>`, fonte de verdade do usuário logado
- `userFirestoreRepositoryProvider` — `findOrCreate`, `getUser`, `updateProfile`

### Quando adicionar back-end

Se no futuro precisar de lógica server-side (recomendação, chat escalável, etc.), o fluxo será:  
Firebase ID Token → `POST /auth/social/google` no back-end → JWT próprio.  
O `auth_repository_impl.dart` e `AuthRepository` interface já existem preparados para isso.

---

## 6. Contratos com Back-end (Go)

> **Auth não usa back-end** — ver § 5-B. Os endpoints abaixo são para features futuras.

### Autenticação (futuro, se necessário)
```
POST /auth/social/{provider}   ← recebe Firebase ID Token, retorna JWT próprio
```

### Feed
```
GET  /feed?page=&limit=
POST /posts
POST /posts/{id}/reaction
POST /posts/{id}/comments
```

### PRs
```
GET  /prs?userId=
POST /prs
GET  /prs/{exerciseId}/history
```

### Chat
```
WebSocket: /ws/chat
GET  /conversations
GET  /conversations/{id}/messages
POST /conversations/{id}/messages
```

### Nearby
```
GET  /nearby/users?lat=&lng=&radius=
GET  /nearby/gyms?lat=&lng=&radius=
```

> **Formato:** REST JSON + WebSocket para real-time  
> **Auth:** Bearer JWT (access + refresh token)  
> **Paginação:** cursor-based preferencial

---

## 7. Não-Funcional

- **Offline-first:** feed e PRs acessíveis sem internet (Hive cache)
- **Performance:** 60fps consistente, listas com lazy loading
- **Segurança:** dados sensíveis em Flutter Secure Storage, HTTPS obrigatório
- **Privacidade:** localização opt-in, LGPD/GDPR compliance
- **Acessibilidade:** Semantics widgets, contraste mínimo AA

---

## 8. Plataformas Alvo

| Plataforma | Prioridade |
|---|---|
| Android | P0 — MVP |
| iOS | P0 — MVP |
| Web (Flutter Web) | P2 — Pós-MVP |

---

## 9. Fora do Escopo (MVP)

- Pagamentos / assinaturas premium
- Integração com wearables (Apple Watch, Garmin) — P2
- Planos de treino gerados por IA — P3
- Back-end próprio (responsabilidade do parceiro)
