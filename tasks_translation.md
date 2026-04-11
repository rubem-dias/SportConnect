# SportConnect — Tasks de Tradução (i18n)

> **Objetivo:** Migrar todas as strings hardcoded em português para o sistema `gen-l10n` do Flutter (`AppLocalizations`).  
> **Pré-requisito:** TASK-I18N-000 deve ser concluída antes de qualquer outra task desta lista.  
> **Idiomas alvo:** `pt` (base) e `en`.  
> **Metodologia:** Uma task por tela/widget. Não misturar arquivos. Marcar como concluída só quando o arquivo não tiver mais nenhuma string hardcoded visível ao usuário.

---

## TASK-I18N-000 · Setup do gen-l10n
**Prioridade:** BLOCKER — todas as outras dependem desta  
**Esforço:** P (pequeno)

- [x] Criar `src/l10n.yaml` com `arb-dir`, `template-arb-file` e `output-class`
- [x] Criar `src/l10n/app_pt.arb` (arquivo base)
- [x] Criar `src/l10n/app_en.arb` (arquivo de tradução)
- [x] Adicionar `generate: true` e `flutter_localizations` no `pubspec.yaml`
- [x] Configurar `localizationsDelegates` e `supportedLocales` no `app.dart`
- [x] Criar extensão `BuildContext.l10n` em `core/extensions/` para acesso conveniente
- [x] Rodar `flutter gen-l10n` e confirmar que a classe `AppLocalizations` é gerada sem erro

---

## E02 — Autenticação

### ✅ TASK-I18N-001 · login_screen.dart
**Esforço:** P  
**Strings a extrair (~15):**

| Chave sugerida | String atual |
|---|---|
| `loginTitle` | `"Conecte-se com sua comunidade esportiva"` |
| `loginEmailLabel` | `"E-mail"` |
| `loginEmailHint` | `"Informe o e-mail"` |
| `loginEmailInvalid` | `"E-mail inválido"` |
| `loginPasswordLabel` | `"Senha"` |
| `loginPasswordHint` | `"Informe a senha"` |
| `loginPasswordMin` | `"Mínimo 6 caracteres"` |
| `loginButton` | `"Entrar"` |
| `loginForgotPassword` | `"Esqueci minha senha"` |
| `loginNoAccount` | `"Não tem conta?"` |
| `loginCreateAccount` | `"Criar conta"` |
| `loginOr` | `"ou continue com"` |
| `loginGoogleError` | `"Não foi possível obter token do Google"` |
| `loginAppleUnavailable` | `"Apple Sign In indisponível neste dispositivo"` |
| `loginAppleError` | `"Não foi possível obter token da Apple"` |

---

### ✅ TASK-I18N-002 · register_screen.dart
**Esforço:** M  
**Strings a extrair (~25):**

| Chave sugerida | String atual |
|---|---|
| `registerTitle` | `"Criar conta"` |
| `registerNameLabel` | `"Nome completo"` |
| `registerNameHint` | `"Informe seu nome"` |
| `registerNameTooShort` | `"Nome muito curto"` |
| `registerEmailLabel` | `"E-mail"` |
| `registerEmailHint` | `"Informe o e-mail"` |
| `registerEmailInvalid` | `"E-mail inválido"` |
| `registerEmailTaken` | `"E-mail já cadastrado"` |
| `registerEmailAvailable` | `"E-mail disponível"` |
| `registerPasswordLabel` | `"Senha"` |
| `registerPasswordHint` | `"Informe a senha"` |
| `registerPasswordMin` | `"Mínimo 8 caracteres"` |
| `registerPasswordUppercase` | `"Inclua ao menos 1 letra maiúscula"` |
| `registerConfirmPassword` | `"Confirmar senha"` |
| `registerPasswordMismatch` | `"As senhas não conferem"` |
| `registerUsernameLabel` | `"Username"` |
| `registerUsernameHint` | `"Informe um username"` |
| `registerUsernameInvalid` | `"Username inválido"` |
| `registerUsernameAvailable` | `"Username disponível"` |
| `registerUsernameTaken` | `"Username indisponível"` |
| `registerBack` | `"Voltar"` |
| `registerNext` | `"Continuar"` |
| `registerSubmit` | `"Criar conta"` |

---

### ✅ TASK-I18N-003 · onboarding_screen.dart
**Esforço:** M  
**Strings a extrair (~28):**

| Chave sugerida | String atual |
|---|---|
| `onboardingSportsTitle` | `"Quais esportes te interessam?"` |
| `onboardingSportsSubtitle` | `"Selecione quantos quiser para personalizar seu feed"` |
| `onboardingLevelTitle` | `"Qual seu nível atual?"` |
| `onboardingLevelSubtitle` | `"Isso ajuda a sugerir desafios no ritmo certo"` |
| `onboardingGoalTitle` | `"Qual seu objetivo principal?"` |
| `onboardingGoalSubtitle` | `"Seu objetivo define metas e recomendações iniciais"` |
| `onboardingLocationTitle` | `"Ativar localização para o Nearby?"` |
| `onboardingLocationSubtitle` | `"Com isso, você encontra pessoas e locais de treino perto de você"` |
| `onboardingLocationEnable` | `"Quero usar o Nearby"` |
| `onboardingSkip` | `"Pular"` |
| `onboardingFinishLater` | `"Finalizar depois"` |
| `onboardingContinue` | `"Continuar"` |
| `onboardingComplete` | `"Concluir"` |
| `sportMusculacao` | `"Musculação"` |
| `sportCorrida` | `"Corrida"` |
| `sportCiclismo` | `"Ciclismo"` |
| `sportCrossfit` | `"Crossfit"` |
| `sportNatacao` | `"Natação"` |
| `sportFutebol` | `"Futebol"` |
| `sportYoga` | `"Yoga"` |
| `sportCalistenia` | `"Calistenia"` |
| `levelBeginner` | `"Iniciante"` |
| `levelIntermediate` | `"Intermediário"` |
| `levelAdvanced` | `"Avançado"` |
| `goalHypertrophy` | `"Hipertrofia"` |
| `goalWeightLoss` | `"Emagrecimento"` |
| `goalPerformance` | `"Performance"` |
| `goalHealth` | `"Saúde"` |

---

## E03 — Feed

### ✅ TASK-I18N-004 · feed_screen.dart
**Esforço:** P  
**Strings a extrair (~5):**

| Chave sugerida | String atual |
|---|---|
| `feedEmptyTitle` | `"Seu feed está vazio"` |
| `feedEmptySubtitle` | `"Siga pessoas e comunidades para ver posts aqui."` |
| `feedEmptyAction` | `"Explorar"` |
| `feedErrorMessage` | `"Não foi possível carregar o feed"` |
| `feedRetry` | `"Tentar novamente"` |

---

### ✅ TASK-I18N-005 · post_card.dart
**Esforço:** P  
**Strings a extrair (~4):**

| Chave sugerida | String atual |
|---|---|
| `postTimeNow` | `"agora"` |
| `postTimeMinutes` | `"há {n}min"` |
| `postTimeHours` | `"há {n}h"` |
| `postTimeDays` | `"há {n}d"` |
| `postSeeMore` | `"ver mais"` |
| `postSeeLess` | `"ver menos"` |
| `postDefaultUser` | `"Usuário"` |

---

### ✅ TASK-I18N-006 · pr_card.dart
**Esforço:** P  
**Strings a extrair (~3):**

| Chave sugerida | String atual |
|---|---|
| `prCardNewBadge` | `"Novo PR!"` |
| `prCardDefaultUser` | `"Usuário"` |

> **Nota:** Reutilizar `postTimeNow`, `postTimeMinutes`, etc. do TASK-I18N-005.

---

### ✅ TASK-I18N-007 · create_post_sheet.dart
**Esforço:** M  
**Strings a extrair (~16):**

| Chave sugerida | String atual |
|---|---|
| `createPostTitle` | `"Criar post"` |
| `createPostPublish` | `"Publicar"` |
| `createPostHint` | `"O que está acontecendo no seu treino?"` |
| `createPostGallery` | `"Galeria"` |
| `createPostCamera` | `"Câmera"` |
| `createPostPR` | `"PR"` |
| `createPostHashtag` | `"Hashtag"` |
| `createPostMention` | `"Mencionar"` |
| `createPostPrivacyEveryone` | `"Todos"` |
| `createPostPrivacyFollowers` | `"Seguidores"` |
| `createPostPrivacyCommunity` | `"Comunidade"` |
| `createPostSelectPR` | `"Selecionar PR para compartilhar"` |
| `createPostNoPRs` | `"Você ainda não tem PRs registrados."` |
| `createPostSuccess` | `"Post publicado!"` |
| `createPostError` | `"Erro ao publicar. Tente novamente."` |

---

### ✅ TASK-I18N-008 · comments_screen.dart
**Esforço:** P  
**Strings a extrair (~7):**

| Chave sugerida | String atual |
|---|---|
| `commentsTitle` | `"Comentários"` |
| `commentsError` | `"Erro ao carregar comentários"` |
| `commentsEmpty` | `"Seja o primeiro a comentar!"` |
| `commentsReply` | `"Responder"` |
| `commentsInputHint` | `"Adicionar comentário..."` |
| `commentsReplyingTo` | `"Respondendo a @{name}"` |

---

## E04 — PRs

### ✅ TASK-I18N-009 · prs_screen.dart
**Esforço:** M  
**Strings a extrair (~26):**

| Chave sugerida | String atual |
|---|---|
| `prsTitle` | `"Personal Records"` |
| `prsSearchHint` | `"Buscar exercício..."` |
| `prsFilterAll` | `"Todos"` |
| `prsAllExercises` | `"Todos os exercícios"` |
| `prsExerciseCount` | `"{n} exercício(s)"` |
| `prsHighlights` | `"Meus Destaques"` |
| `prsNewBadge` | `"Novo PR! 🔥"` |
| `prsEmptyTitle` | `"Nenhum PR encontrado"` |
| `prsEmptyFirstTime` | `"Registre seu primeiro Personal Record!"` |
| `prsEmptyFilter` | `"Tente outros filtros ou termos de busca."` |
| `prsErrorMessage` | `"Erro ao carregar PRs"` |
| `prsRetry` | `"Tentar novamente"` |
| `prsTimeToday` | `"Hoje"` |
| `prsTimeYesterday` | `"Ontem"` |
| `prsTimeDaysAgo` | `"Há {n} dias"` |
| `muscleChest` | `"peito"` |
| `muscleBack` | `"costas"` |
| `muscleLegs` | `"pernas"` |
| `muscleShoulders` | `"ombros"` |
| `muscleBiceps` | `"bíceps"` |
| `muscleTriceps` | `"tríceps"` |
| `muscleCore` | `"core"` |
| `muscleCardio` | `"cardio"` |
| `muscleOlympic` | `"olímpico"` |
| `muscleOther` | `"outros"` |

---

### ✅ TASK-I18N-010 · add_pr_screen.dart
**Esforço:** G (grande)  
**Strings a extrair (~30):**

| Chave sugerida | String atual |
|---|---|
| `addPrTitle` | `"Registrar PR"` |
| `editPrTitle` | `"Editar PR"` |
| `addPrExerciseSection` | `"Exercício"` |
| `addPrResultSection` | `"Resultado"` |
| `addPrRepsSection` | `"Repetições (opcional)"` |
| `addPrRepsHint` | `"Ex: 5"` |
| `addPrRepsInvalid` | `"Número inteiro"` |
| `addPrDateSection` | `"Data"` |
| `addPrNotesSection` | `"Observações (opcional)"` |
| `addPrNotesHint` | `"Como foi o treino, equipamento utilizado..."` |
| `addPrShareToggle` | `"Compartilhar no feed"` |
| `addPrShareSubtitle` | `"Seus seguidores verão este PR no feed"` |
| `addPrSubmit` | `"Registrar PR"` |
| `editPrSubmit` | `"Salvar alterações"` |
| `addPrSelectExercise` | `"Selecionar exercício"` |
| `addPrNoExercise` | `"Selecione um exercício"` |
| `addPrPreviousBest` | `"Melhor PR atual: {value}"` |
| `addPrValueRequired` | `"Obrigatório"` |
| `addPrValueInvalid` | `"Valor inválido"` |
| `addPrSuccess` | `"PR registrado!"` |
| `addPrError` | `"Erro ao salvar PR. Tente novamente."` |
| `addPrCelebrationTitle` | `"Novo Personal Record!"` |
| `addPrCelebrationButton` | `"Incrível! 🎉"` |
| `addPrCelebrationImprovement` | `"+{value} {unit} acima do anterior"` |
| `exerciseSearchHint` | `"Buscar exercício..."` |
| `exerciseCreateNew` | `"Criar novo"` |
| `exerciseCreateTitle` | `"Criar exercício"` |
| `exerciseNameLabel` | `"Nome do exercício"` |
| `exerciseNameHint` | `"Ex: Supino Engessado"` |
| `exerciseMuscleLabel` | `"Grupo muscular"` |
| `exerciseUnitLabel` | `"Unidade"` |
| `exerciseCreateButton` | `"Criar"` |
| `deletePrTitle` | `"Deletar PR?"` |
| `deletePrConfirm` | `"Esta ação não pode ser desfeita."` |
| `deletePrButton` | `"Deletar"` |
| `cancelButton` | `"Cancelar"` |

---

## Resumo

| Task | Arquivo | Esforço | Strings |
|---|---|---|---|
| I18N-000 | Setup gen-l10n | P | — |
| I18N-001 | login_screen.dart | P | ~15 |
| I18N-002 | register_screen.dart | M | ~25 |
| I18N-003 | onboarding_screen.dart | M | ~28 |
| I18N-004 | feed_screen.dart | P | ~5 |
| I18N-005 | post_card.dart | P | ~7 |
| I18N-006 | pr_card.dart | P | ~2 |
| I18N-007 | create_post_sheet.dart | M | ~16 |
| I18N-008 | comments_screen.dart | P | ~6 |
| I18N-009 | prs_screen.dart | M | ~26 |
| I18N-010 | add_pr_screen.dart | G | ~35 |
| **Total** | **10 arquivos** | | **~165 strings** |

> **Legenda de esforço:** P = menos de 1h · M = 1–2h · G = 2–3h  
> Tasks futuras (telas ainda não implementadas) serão adicionadas aqui conforme o backlog avança.
