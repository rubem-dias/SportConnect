# SportConnect — Tasks de Desenvolvimento

> Metodologia: cada task tem ID único, estimativa em pontos (Fibonacci), dependências e critérios de aceite claros.  
> Sprints sugeridos de **2 semanas**. MVP estimado em **~12 sprints**.

---

## Épicos

| ID | Épico | Descrição |
|---|---|---|
| E01 | Setup & Infra | Projeto base, CI/CD, design system |
| E02 | Autenticação | Login, registro, onboarding |
| E03 | Feed | Home, posts, stories, reactions |
| E04 | PRs | Personal records, histórico, badges |
| E05 | Metas | Goals, progress tracking |
| E06 | Chat | DM, grupos, canais |
| E07 | Nearby | Mapa, descoberta local |
| E08 | Perfil | Perfil público, stats, conquistas |
| E09 | Busca | Search global, explorar |
| E10 | Notificações | Push, in-app |
| E11 | Polimento | Animações, acessibilidade, dark mode |

---

## E01 — Setup & Infra

### TASK-001 · Criar projeto Flutter base
**Pontos:** 3  
**Dependências:** nenhuma

- [x] `flutter create sport_connect --org com.sportconnect`
- [x] Configurar estrutura de pastas conforme SPEC (features/, core/, shared/)
- [x] Adicionar `.gitignore` específico para Flutter
- [x] Configurar `analysis_options.yaml` com regras lint rigorosas
- [x] Configurar flavors: `dev`, `staging`, `prod`

**Aceite:** `flutter run` funciona nos dois flavors sem erro

---

### TASK-002 · Configurar dependências base
**Pontos:** 2  
**Dependências:** TASK-001

Adicionar ao `pubspec.yaml`:
- [x] `flutter_riverpod` + `riverpod_annotation` — state management
- [x] `go_router` — navegação declarativa
- [x] `dio` + `pretty_dio_logger` — HTTP client
- [x] `hive_flutter` — cache local
- [x] `flutter_secure_storage` — tokens
- [x] `freezed` + `json_serializable` — models imutáveis
- [x] `envied` — variáveis de ambiente
- [x] `flutter_svg` — ícones SVG
- [x] `cached_network_image` — imagens com cache
- [x] `intl` — internacionalização (pt-BR, en)

**Aceite:** ✅ `flutter pub get` sem conflitos, build iOS e Android passa

---

### TASK-003 · Design System — Tokens e Tema
**Pontos:** 5  
**Dependências:** TASK-002

- [x] Criar `core/theme/app_colors.dart` com paleta completa (ver SPEC §5)
- [x] Criar `core/theme/app_typography.dart` com Inter + Roboto
- [x] Criar `core/theme/app_theme.dart` com `ThemeData` light e dark
- [x] Criar `core/theme/app_spacing.dart` (4, 8, 12, 16, 24, 32, 48)
- [x] Criar `core/theme/app_radius.dart`
- [x] Configurar `MaterialApp` para usar ambos os temas com detecção de sistema

**Aceite:** Tela de teste mostra paleta correta em light e dark mode

---

### TASK-004 · Componentes base (shared/widgets)
**Pontos:** 8  
**Dependências:** TASK-003

- [x] `AppButton` — primary, secondary, ghost, loading state
- [x] `AppTextField` — com label flutuante, ícone, validação, senha toggle
- [x] `AppAvatar` — circular, com status online indicator
- [x] `AppBadge` — tags coloridas (esporte, nível)
- [x] `AppBottomSheet` — modal arrastável (estilo Telegram)
- [x] `AppSnackbar` — success, error, info
- [x] `AppLoadingSkeleton` — shimmer para listas
- [x] `AppEmptyState` — ilustração + texto para telas vazias
- [x] `AppDivider` — com texto opcional no meio

**Aceite:** Storybook-like screen com todos os widgets renderizando corretamente

---

### TASK-005 · Configurar navegação (Go Router)
**Pontos:** 3  
**Dependências:** TASK-002

- [x] Definir todas as rotas em `core/router/app_router.dart`
- [x] Implementar guard de autenticação (redirect para login se não autenticado)
- [x] Configurar shell route para Bottom Navigation Bar
- [x] Deep links: `sportconnect://post/:id`, `sportconnect://profile/:id`
- [x] Tratamento de rota não encontrada (404 screen)

**Aceite:** Navegação entre todas as telas stub funciona; guard redireciona corretamente

---

### TASK-006 · HTTP Client e interceptors
**Pontos:** 3  
**Dependências:** TASK-002

- [x] Criar `core/network/api_client.dart` com Dio configurado
- [x] Interceptor de autenticação (injetar Bearer token automaticamente)
- [x] Interceptor de refresh token (retry automático em 401)
- [x] Interceptor de erros → mapeamento para `AppException` typed
- [x] Classe `ApiEndpoints` com todas as URLs centralizadas

**Aceite:** Request mock retorna e erros 401 disparam refresh sem intervenção manual

---

### TASK-007 · CI/CD básico (GitHub Actions) (PODE IGNORAR ESSA TASK POR ENQUANTO)
**Pontos:** 5  
**Dependências:** TASK-001

- [ ] Workflow `analyze.yml`: lint + testes a cada PR
- [ ] Workflow `build_android.yml`: APK de staging no push para `main`
- [ ] Workflow `build_ios.yml`: IPA de staging (com Fastlane)
- [ ] Badge de build no README
- [ ] Configurar secrets: `KEYSTORE`, `APPLE_CERT`, `FIREBASE_CONFIG`

**Aceite:** PR com erro de lint falha na CI; merge em main gera artefatos

---

## E02 — Autenticação

### TASK-008 · Models de autenticação
**Pontos:** 2  
**Dependências:** TASK-006

- [x] `UserModel` (id, email, name, avatar, sports, level, createdAt)
- [x] `AuthTokenModel` (accessToken, refreshToken, expiresAt)
- [x] `AuthRepository` interface + implementação HTTP
- [x] Provider `authStateProvider` com `AsyncNotifier<UserModel?>`

**Aceite:** Models gerados pelo `freezed` sem warnings

---

### TASK-009 · Tela de Login
**Pontos:** 5  
**Dependências:** TASK-008, TASK-004

- [x] Layout: logo centralizado, campos e-mail + senha, botão entrar
- [x] Botões de social login (Google, Apple) — visual apenas nesta task
- [x] Link "Esqueci minha senha"
- [x] Link "Criar conta"
- [x] Validação local dos campos antes do request
- [x] Loading state no botão durante request
- [x] Tratamento de erros (credenciais inválidas, sem conexão)
- [x] Navegação pós-login para Home

**Aceite:** Login com credenciais válidas navega para Home; erro exibe snackbar correto

---

### TASK-010 · Tela de Registro
**Pontos:** 5  
**Dependências:** TASK-008, TASK-004

- [x] Step 1: Nome, e-mail, senha, confirmação de senha
- [x] Step 2: Foto de perfil (opcional), username
- [x] Validações: e-mail único (check assíncrono), senha forte, username disponível
- [x] Progress indicator de steps
- [x] Navegar para Onboarding após registro

**Aceite:** Registro completo cria usuário no back-end e persiste token

---

### TASK-011 · Onboarding
**Pontos:** 5  
**Dependências:** TASK-010

- [x] Step 1: Selecionar esportes de interesse (multi-select com ícones)
- [x] Step 2: Nível de condicionamento (Iniciante / Intermediário / Avançado)
- [x] Step 3: Objetivo principal (Hipertrofia, Emagrecimento, Performance, Saúde)
- [x] Step 4: Localização (para Nearby) — opt-in com explicação clara
- [x] Skip possível em cada step
- [x] Salvar preferências no perfil

**Aceite:** Onboarding completo persiste preferências e navega para Home

---

### TASK-012 · Social Login (Google e Apple)
**Pontos:** 5  
**Dependências:** TASK-009

- [x] Integrar `google_sign_in` package
- [x] Integrar `sign_in_with_apple` package
- [x] Enviar token social para `POST /auth/social/{provider}`
- [x] Tratar conta já existente vs novo usuário (onboarding condicional)
- [ ] Configurar OAuth apps no Google Cloud Console e Apple Developer

**Aceite:** Login Google e Apple funciona em device físico iOS e Android

---

### TASK-013 · Persistência de sessão e logout
**Pontos:** 3  
**Dependências:** TASK-008

- [x] Salvar tokens em `flutter_secure_storage` (não SharedPreferences)
- [x] Auto-login ao abrir o app se token válido
- [x] Tela de splash com verificação de sessão
- [x] Logout: limpar storage + invalidar token no back-end + redirecionar

**Aceite:** App abre logado após fechar; logout limpa tudo

---

## E03 — Feed

### TASK-014 · Model e Repository de Posts
**Pontos:** 3  
**Dependências:** TASK-006

- [x] `PostModel` (id, userId, content, mediaUrls, exerciseData, prData, reactions, commentsCount, createdAt)
- [x] `FeedRepository` com paginação cursor-based
- [x] `feedProvider` com `AsyncNotifier` + `refresh()` e `loadMore()`
- [x] Cache local de feed (Hive) para offline

**Aceite:** Provider carrega posts paginados e atualiza ao fazer pull-to-refresh

---

### TASK-015 · Tela de Feed (Home)
**Pontos:** 8  
**Dependências:** TASK-014, TASK-004

- [ ] `CustomScrollView` com `SliverList` (performance em listas longas)
- [ ] Pull-to-refresh com indicador estilizado
- [ ] Infinite scroll com skeleton no final da lista
- [ ] `PostCard` widget:
  - Avatar + nome + tempo relativo (ex: "há 3h")
  - Texto do post com "ver mais" em posts longos
  - Grid de fotos (1, 2, 3, 4+ imagens)
  - Barra de reactions (🔥 💪 🏆) com contagem
  - Botão comentar e compartilhar
- [ ] `PRCard` widget destacado (quando post é um PR) — fundo verde com badge 🏆
- [ ] Estado vazio (primeiro uso) com sugestão de seguir pessoas

**Aceite:** Feed rola fluido (60fps), PRs se destacam visualmente, offline mostra cache

---

### TASK-016 · Stories
**Pontos:** 5  
**Dependências:** TASK-015

- [ ] Carrossel horizontal de avatares no topo do feed
- [ ] Tela de visualização de story (fullscreen, barra de progresso)
- [ ] Criação de story: foto/vídeo + texto sobreposto
- [ ] Expiração em 24h (controle via back-end)
- [ ] Indicador de story não visto (anel colorido)

**Aceite:** Story abre fullscreen com progresso animado, expira no prazo

---

### TASK-017 · Criação de Post
**Pontos:** 8  
**Dependências:** TASK-014

- [ ] Bottom sheet de criação (estilo Telegram — sobe suavemente)
- [ ] Campo de texto com hashtag highlight (#academia, #crossfit)
- [ ] Seleção de mídia (galeria + câmera)
- [ ] Opção "Compartilhar PR" — abre seletor de PR cadastrado
- [ ] Seleção de privacidade: Todos / Seguidores / Comunidade específica
- [ ] Preview antes de publicar
- [ ] Upload com progress indicator
- [ ] Rascunho salvo localmente se fechar sem publicar

**Aceite:** Post com foto publicado aparece no topo do feed em < 3s

---

### TASK-018 · Reactions e Comentários
**Pontos:** 5  
**Dependências:** TASK-015

- [ ] Tap na reaction: toggle com animação scale + haptic feedback
- [ ] Long press: exibir todos os tipos de reaction (emoji picker compacto)
- [ ] Tela de comentários:
  - Lista de comentários com avatar + nome + texto + tempo
  - Campo de texto fixo no rodapé (estilo Telegram)
  - Mencionar usuário com @
  - Reply em comentário específico
- [ ] Contagem de comentários atualiza em tempo real (WebSocket)

**Aceite:** Reaction anima imediatamente (optimistic update); comentário aparece sem reload

---

## E04 — PRs (Personal Records)

### TASK-019 · Models e Repository de PRs
**Pontos:** 3  
**Dependências:** TASK-006

- [ ] `ExerciseModel` (id, name, muscleGroup, isCustom, unit: kg/km/min)
- [ ] `PRModel` (id, exerciseId, value, unit, reps, date, notes, isShared)
- [ ] `PRRepository`: listar por exercício, criar, histórico, melhor de cada
- [ ] Banco local Hive para PRs offline-first

**Aceite:** PRs salvos offline sincronizam ao voltar online

---

### TASK-020 · Tela de PRs
**Pontos:** 8  
**Dependências:** TASK-019, TASK-004

- [ ] Lista de exercícios com melhor PR de cada um
- [ ] Ícone de músculo por grupo (peito, costas, pernas, etc.)
- [ ] Filtros: por grupo muscular, por data, favoritos
- [ ] Card de exercício: nome + melhor mark + data + badge "Novo PR!" se recente
- [ ] Busca por exercício
- [ ] Floating Action Button para registrar novo PR
- [ ] Seção "Meus Destaques" (top 3 PRs mais impressionantes)

**Aceite:** Lista filtra corretamente; badge aparece em PR novo sem reload

---

### TASK-021 · Registrar e Editar PR
**Pontos:** 5  
**Dependências:** TASK-020

- [ ] Selecionar exercício (busca + recentes + biblioteca completa)
- [ ] Criar exercício customizado se não existir
- [ ] Campos: valor + unidade, reps (opcional), data, observações
- [ ] Validação: valor maior que zero, data não futura
- [ ] Se valor > PR anterior: animação de celebração 🎉 + badge automático
- [ ] Toggle "Compartilhar no feed" com preview do card
- [ ] Editar / deletar PR existente

**Aceite:** Novo PR maior que anterior dispara animação e pergunta se quer postar

---

### TASK-022 · Histórico e Gráfico de Evolução
**Pontos:** 5  
**Dependências:** TASK-021

- [ ] Tela de detalhe de exercício com histórico cronológico
- [ ] Gráfico de linha (`fl_chart`) mostrando evolução no tempo
- [ ] Filtros de período: 1M, 3M, 6M, 1A, Tudo
- [ ] Linha de tendência suavizada
- [ ] Anotações no gráfico nos pontos de PR
- [ ] Comparativo anônimo com média da comunidade (linha pontilhada)

**Aceite:** Gráfico renderiza corretamente com 100+ pontos sem travar

---

## E05 — Metas

### TASK-023 · Models e Repository de Metas
**Pontos:** 3  
**Dependências:** TASK-006

- [ ] `GoalModel` (id, type, title, target, unit, current, startDate, endDate, isPublic)
- [ ] Tipos: peso corporal, PR específico, frequência semanal, distância mensal
- [ ] `GoalRepository`: CRUD + check-in
- [ ] Check-in automático ao registrar PR vinculado à meta

**Aceite:** Meta de PR atualiza progresso automaticamente ao registrar PR

---

### TASK-024 · Tela de Metas
**Pontos:** 8  
**Dependências:** TASK-023, TASK-004

- [ ] Cards de metas ativas com progress bar animada
- [ ] Categorias: Em andamento / Concluídas / Expiradas
- [ ] Card de meta:
  - Título + ícone de tipo
  - Progress bar com porcentagem
  - Dias restantes
  - Último check-in
- [ ] Tela de criação de meta (multi-step: tipo → valor → prazo → visibilidade)
- [ ] Animação de confetti ao completar meta 🎊
- [ ] Arquivar meta concluída

**Aceite:** Progress bar anima ao entrar na tela; confetti ao bater 100%

---

## E06 — Chat

### TASK-025 · Infraestrutura de Chat (WebSocket)
**Pontos:** 8  
**Dependências:** TASK-006

- [ ] Conexão WebSocket com reconexão automática
- [ ] Protocolo de mensagens: `{type, conversationId, payload, timestamp}`
- [ ] Tipos: `message`, `typing`, `read`, `reaction`, `presence`
- [ ] `ChatRepository` com Hive para persistir mensagens localmente
- [ ] Provider de conexão com status (connected/reconnecting/offline)
- [ ] Fila de mensagens pendentes (enviar ao reconectar)

**Aceite:** Mensagem enviada offline entra na fila e é enviada ao reconectar

---

### TASK-026 · Lista de Conversas
**Pontos:** 5  
**Dependências:** TASK-025, TASK-004

- [ ] Layout idêntico ao Telegram: avatar + nome + última mensagem + tempo + badge de não lidas
- [ ] DMs e grupos misturados, ordenados por última atividade
- [ ] Indicador de online (ponto verde no avatar)
- [ ] Swipe para arquivar / mutar conversa
- [ ] Long press: opções (arquivar, mutar, deletar)
- [ ] Busca por nome na lista
- [ ] Skeleton de carregamento na primeira carga

**Aceite:** Lista atualiza em tempo real ao chegar mensagem nova sem reload

---

### TASK-027 · Tela de Chat (DM e Grupo)
**Pontos:** 13  
**Dependências:** TASK-026

- [ ] `ListView.builder` invertido para mensagens (mais recentes embaixo)
- [ ] Bubble de mensagem:
  - Alinhamento esquerda (outro) / direita (eu)
  - Canto arredondado estilo Telegram
  - Status: enviando ⏳ / enviado ✓ / lido ✓✓
  - Timestamp ao lado ou abaixo
- [ ] Agrupamento por dia com separador de data
- [ ] Input bar:
  - Campo de texto expansível (até 4 linhas)
  - Botão de mídia (câmera, galeria, arquivo)
  - Botão de áudio (pressionar e segurar)
  - Botão enviar animado
- [ ] Reply: swipe na mensagem para responder
- [ ] Reaction: long press na mensagem abre emoji picker compacto
- [ ] Indicador "fulano está digitando..."
- [ ] Scroll rápido ao clicar no nome no header → vai para primeira mensagem
- [ ] Load mais mensagens ao rolar para cima (paginação)
- [ ] Card especial para compartilhamento de PR

**Aceite:** Chat de 1000 mensagens rola fluido; reply e reactions funcionam offline

---

### TASK-028 · Grupos e Canais
**Pontos:** 8  
**Dependências:** TASK-027

- [ ] Criação de grupo: nome, foto, descrição, esporte, privado/público
- [ ] Adicionar / remover membros
- [ ] Info do grupo: membros, mídia compartilhada, admin
- [ ] Papel de admin: remover membros, fixar mensagens, editar info
- [ ] Convite por link compartilhável
- [ ] Canais (broadcast): somente admins escrevem, todos leem
- [ ] Mencionar @todos ou @usuário

**Aceite:** Grupo criado; admin consegue fixar mensagem; link de convite funciona

---

## E07 — Nearby (Usuários Próximos)

### TASK-029 · Infraestrutura de Localização
**Pontos:** 5  
**Dependências:** TASK-002

- [ ] Integrar `geolocator` package
- [ ] Solicitar permissão com explicação clara (LGPD/GDPR)
- [ ] Modo de privacidade: Exato / Bairro / Desativado
- [ ] Atualizar localização no back-end em background (modo bairro = aproximado)
- [ ] Parar atualização quando app em background se usuário não autorizou

**Aceite:** Permissão solicitada com explicação; modo bairro não expõe endereço exato

---

### TASK-030 · Tela de Nearby
**Pontos:** 8  
**Dependências:** TASK-029, TASK-004

- [ ] Mapa (`flutter_map` com OpenStreetMap ou Google Maps)
- [ ] Pins de usuários e academias no mapa
- [ ] Lista abaixo do mapa (alternativa ao mapa para acessibilidade)
- [ ] Filtros: raio (500m, 1km, 5km), esporte, nível
- [ ] Bottom sheet ao clicar em pin: mini-perfil do usuário
- [ ] Botão "Treinar junto" no mini-perfil → envia request
- [ ] Academias: nome, horário, foto, link para maps

**Aceite:** Pins aparecem em < 2s; filter muda pins em tempo real

---

## E08 — Perfil

### TASK-031 · Tela de Perfil Próprio
**Pontos:** 8  
**Dependências:** TASK-008, TASK-020

- [ ] Header: foto, nome, username, bio, esportes (badges)
- [ ] Stats bar: posts / seguidores / seguindo
- [ ] Tabs: Posts | PRs | Conquistas
- [ ] Editar perfil (inline ou tela separada)
- [ ] Trocar foto de perfil (galeria + câmera + crop circular)
- [ ] Conquistas: grid de badges com nome e como desbloquear

**Aceite:** Edição de nome reflete imediatamente no header sem reload

---

### TASK-032 · Perfil de Outro Usuário
**Pontos:** 5  
**Dependências:** TASK-031

- [ ] Mesmo layout, mas com botão Seguir / Seguindo / Solicitar (perfil privado)
- [ ] Botão "Mensagem" abre DM
- [ ] Botão "Treinar junto" (se próximo)
- [ ] Posts públicos visíveis; PRs públicos visíveis
- [ ] Bloquear usuário (via long press no header ou menu)

**Aceite:** Seguir atualiza contador em tempo real; bloquear remove das listas

---

## E09 — Busca

### TASK-033 · Busca Global
**Pontos:** 5  
**Dependências:** TASK-006

- [ ] Barra de busca no topo (estilo Telegram: fica em cima ao digitar)
- [ ] Tabs de resultado: Tudo / Usuários / Grupos / Posts / Exercícios
- [ ] Histórico de buscas recentes (local)
- [ ] Busca de hashtag → feed filtrado
- [ ] Sugestões em tempo real (debounce 300ms)
- [ ] Estado vazio com sugestão de trending

**Aceite:** Resultado aparece em < 500ms após parar de digitar

---

### TASK-034 · Explorar / Trending
**Pontos:** 3  
**Dependências:** TASK-033

- [ ] Seção de trending: hashtags mais usadas hoje
- [ ] Posts em alta (mais reactions nas últimas 24h)
- [ ] Sugestão de grupos para entrar baseado nos esportes do perfil
- [ ] Sugestão de usuários para seguir

**Aceite:** Trending atualiza ao puxar para baixo

---

## E10 — Notificações

### TASK-035 · Push Notifications (FCM)
**Pontos:** 5  
**Dependências:** TASK-007

- [ ] Integrar Firebase Messaging (`firebase_messaging`)
- [ ] Solicitar permissão no iOS
- [ ] Handler para foreground, background e terminated
- [ ] Deep link a partir da notificação (ex: abrir post, abrir chat)
- [ ] Enviar `FCM token` para o back-end ao logar

**Aceite:** Notificação em background abre o app na tela correta

---

### TASK-036 · Central de Notificações In-app
**Pontos:** 5  
**Dependências:** TASK-035

- [ ] Tela de notificações com lista cronológica
- [ ] Tipos: nova reaction, novo comentário, novo seguidor, PR batido por amigo, menção
- [ ] Ícone diferente por tipo
- [ ] Marcar como lida (tap) / marcar todas como lidas
- [ ] Badge na aba com contagem de não lidas
- [ ] Configurações: toggle por tipo de notificação

**Aceite:** Badge some ao abrir a aba; configurações persistem entre sessões

---

## E11 — Polimento

### TASK-037 · Animações e Micro-interações
**Pontos:** 8  
**Dependências:** todas as telas principais

- [ ] Transições de página: slide para telas filhas, fade para tabs
- [ ] Hero animation em imagens de post para fullscreen
- [ ] Animação de reaction (bounce + scale)
- [ ] Confetti ao bater PR (pacote `confetti`)
- [ ] Skeleton shimmer consistente em todas as listas
- [ ] Pull-to-refresh com ícone animado customizado
- [ ] Bottom navigation com indicador fluido (estilo Telegram)

**Aceite:** Sem jank visível a 60fps em device mid-range (Snapdragon 660)

---

### TASK-038 · Acessibilidade
**Pontos:** 5  
**Dependências:** todas as telas

- [ ] `Semantics` widget em ícones sem texto
- [ ] Contraste AA em todos os textos
- [ ] Tamanho mínimo de tap target: 44x44px
- [ ] Suporte a fonte grande do sistema (textScaleFactor)
- [ ] Navegação por TalkBack / VoiceOver funcional nas telas core

**Aceite:** Auditoria com TalkBack passa sem bloqueadores graves

---

### TASK-039 · Testes
**Pontos:** 8  
**Dependências:** todas

- [ ] Testes unitários de todos os Repositories (mock HTTP)
- [ ] Testes de widget para `PostCard`, `PRCard`, `AppButton`, `ChatBubble`
- [ ] Testes de integração: fluxo de login completo, criar e postar PR
- [ ] Cobertura mínima: 70% nos arquivos de `features/`
- [ ] `golden_toolkit` para snapshot tests dos principais widgets

**Aceite:** `flutter test` com cobertura ≥ 70%, zero falhas

---

## Estimativas Resumidas por Épico

| Épico | Tasks | Pontos | Sprints estimados |
|---|---|---|---|
| E01 Setup | 7 | 29 | 2 |
| E02 Auth | 6 | 25 | 2 |
| E03 Feed | 5 | 29 | 2 |
| E04 PRs | 4 | 19 | 1.5 |
| E05 Metas | 2 | 11 | 1 |
| E06 Chat | 4 | 34 | 2.5 |
| E07 Nearby | 2 | 13 | 1 |
| E08 Perfil | 2 | 13 | 1 |
| E09 Busca | 2 | 8 | 0.5 |
| E10 Notif | 2 | 10 | 1 |
| E11 Polish | 3 | 21 | 1.5 |
| **Total** | **39** | **212** | **~16** |

> Considerando 1 dev principal + revisões parciais do parceiro Go: **~8 meses** para MVP completo.  
> MVP mínimo (E01–E04 + E06 básico): **~5 meses**.

---

## Prioridade de MVP

### Sprint 1–2: Foundation
TASK-001 → 002 → 003 → 004 → 005 → 006 → 007

### Sprint 3–4: Auth + Feed básico
TASK-008 → 009 → 010 → 011 → 013 → 014 → 015

### Sprint 5–6: PRs + Criação de Post
TASK-019 → 020 → 021 → 017 → 018

### Sprint 7–8: Chat MVP
TASK-025 → 026 → 027

### Sprint 9–10: Perfil + Metas
TASK-023 → 024 → 031 → 032

### Sprint 11–12: Nearby + Notificações + Social Login
TASK-029 → 030 → 035 → 036 → 012

### Sprint 13+: Polimento, stories, busca, testes
TASK-016 → 033 → 034 → 037 → 038 → 039
