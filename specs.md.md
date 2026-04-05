# SportConnect — Especificação do Projeto

> **Nome sugerido:** `SportConnect` (substitui GymConnected para cobrir academia + outros esportes)  
> **Repositório atual:** `GymConnected/`  
> **Versão:** 1.0 — Draft inicial

---

## 1. Visão Geral

SportConnect é uma plataforma mobile de comunidade esportiva com foco em experiência de treino compartilhada. A proposta é ser socialmente fluida como o Telegram — rápido, limpo, orientado a conversas e grupos — mas com camadas de gamificação e tracking voltadas para esporte.

O usuário vem para registrar seu PR, compartilhar um treino, encontrar alguém que treina perto dele ou entrar num grupo de corrida. Fica pela comunidade.

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
│   ├── feed/             # Home feed, posts, stories
│   ├── prs/              # Personal Records
│   ├── goals/            # Metas e progresso
│   ├── chat/             # DMs e grupos (estilo Telegram)
│   ├── nearby/           # Usuários e academias próximas
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

### 4.2 Feed / Home
Inspirado no Telegram (lista limpa, sem poluição visual):
- **Posts de treino:** descrição, exercícios, fotos/vídeos curtos
- **PR compartilhado:** card destacado com exercício + peso + badge
- **Stories de treino:** conteúdo efêmero (24h)
- Reactions rápidas (🔥 💪 🏆)
- Comentários
- Algoritmo: posts de seguidos + comunidades + localização (configurável)

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

### 4.8 Busca e Descoberta
- Busca global: usuários, grupos, exercícios, academias
- Explorar: trending por esporte, região
- Hashtags em posts

### 4.9 Notificações
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

## 6. Contratos com Back-end (Go)

O back-end será desenvolvido por parceiro em **Go**. Contratos iniciais:

### Autenticação
```
POST /auth/register
POST /auth/login
POST /auth/refresh
POST /auth/social/{provider}
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
