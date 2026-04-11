// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get loginTitle => 'Conecte-se com sua comunidade esportiva';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginEmailHint => 'Informe o e-mail';

  @override
  String get loginEmailInvalid => 'E-mail inválido';

  @override
  String get loginPasswordLabel => 'Senha';

  @override
  String get loginPasswordHint => 'Informe a senha';

  @override
  String get loginPasswordMin => 'Mínimo 6 caracteres';

  @override
  String get loginButton => 'Entrar';

  @override
  String get loginForgotPassword => 'Esqueci minha senha';

  @override
  String get loginNoAccount => 'Não tem conta?';

  @override
  String get loginCreateAccount => 'Criar conta';

  @override
  String get loginOr => 'ou continue com';

  @override
  String get loginGoogleError => 'Não foi possível obter token do Google';

  @override
  String get loginAppleUnavailable =>
      'Apple Sign In indisponível neste dispositivo';

  @override
  String get loginAppleError => 'Não foi possível obter token da Apple';

  @override
  String get registerTitle => 'Criar conta';

  @override
  String get registerNameLabel => 'Nome completo';

  @override
  String get registerNameHint => 'Informe seu nome';

  @override
  String get registerNameTooShort => 'Nome muito curto';

  @override
  String get registerEmailLabel => 'E-mail';

  @override
  String get registerEmailHint => 'Informe o e-mail';

  @override
  String get registerEmailInvalid => 'E-mail inválido';

  @override
  String get registerEmailTaken => 'E-mail já cadastrado';

  @override
  String get registerEmailAvailable => 'E-mail disponível';

  @override
  String get registerPasswordLabel => 'Senha';

  @override
  String get registerPasswordHint => 'Informe a senha';

  @override
  String get registerPasswordMin => 'Mínimo 8 caracteres';

  @override
  String get registerPasswordUppercase => 'Inclua ao menos 1 letra maiúscula';

  @override
  String get registerConfirmPassword => 'Confirmar senha';

  @override
  String get registerPasswordMismatch => 'As senhas não conferem';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerUsernameHint => 'Informe um username';

  @override
  String get registerUsernameInvalid => 'Username inválido';

  @override
  String get registerUsernameAvailable => 'Username disponível';

  @override
  String get registerUsernameTaken => 'Username indisponível';

  @override
  String registerStep(int step, int total) {
    return 'Etapa $step de $total';
  }

  @override
  String get registerPasswordLowercase => 'Inclua ao menos 1 letra minúscula';

  @override
  String get registerPasswordNumber => 'Inclua ao menos 1 número';

  @override
  String get registerPasswordSpecial => 'Inclua ao menos 1 caractere especial';

  @override
  String get registerConfirmPasswordHint => 'Confirme sua senha';

  @override
  String get registerEmailChecking => 'Validando e-mail...';

  @override
  String get registerUsernameChecking => 'Validando username...';

  @override
  String get registerUsernameHelper =>
      'Use 3 a 20 caracteres: letras, números ou _';

  @override
  String get registerAddPhoto => 'Adicionar foto (opcional)';

  @override
  String get registerAlreadyHaveAccount => 'Já tem conta?';

  @override
  String get registerSignIn => 'Entrar';

  @override
  String get registerAwaitEmailValidation => 'Aguarde a validação do e-mail.';

  @override
  String get registerAwaitUsernameValidation =>
      'Aguarde a validação do username.';

  @override
  String get registerBack => 'Voltar';

  @override
  String get registerNext => 'Continuar';

  @override
  String get registerSubmit => 'Criar conta';

  @override
  String get onboardingSportsTitle => 'Quais esportes te interessam?';

  @override
  String get onboardingSportsSubtitle =>
      'Selecione quantos quiser para personalizar seu feed';

  @override
  String get onboardingLevelTitle => 'Qual seu nível atual?';

  @override
  String get onboardingLevelSubtitle =>
      'Isso ajuda a sugerir desafios no ritmo certo';

  @override
  String get onboardingGoalTitle => 'Qual seu objetivo principal?';

  @override
  String get onboardingGoalSubtitle =>
      'Seu objetivo define metas e recomendações iniciais';

  @override
  String get onboardingLocationTitle => 'Ativar localização para o Nearby?';

  @override
  String get onboardingLocationSubtitle =>
      'Com isso, você encontra pessoas e locais de treino perto de você';

  @override
  String get onboardingLocationEnable => 'Quero usar o Nearby';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingFinishLater => 'Finalizar depois';

  @override
  String get onboardingContinue => 'Continuar';

  @override
  String get onboardingComplete => 'Concluir';

  @override
  String get sportMusculacao => 'Musculação';

  @override
  String get sportCorrida => 'Corrida';

  @override
  String get sportCiclismo => 'Ciclismo';

  @override
  String get sportCrossfit => 'Crossfit';

  @override
  String get sportNatacao => 'Natação';

  @override
  String get sportFutebol => 'Futebol';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportCalistenia => 'Calistenia';

  @override
  String get levelBeginner => 'Iniciante';

  @override
  String get levelIntermediate => 'Intermediário';

  @override
  String get levelAdvanced => 'Avançado';

  @override
  String get goalHypertrophy => 'Hipertrofia';

  @override
  String get goalWeightLoss => 'Emagrecimento';

  @override
  String get goalPerformance => 'Performance';

  @override
  String get goalHealth => 'Saúde';

  @override
  String get feedEmptyTitle => 'Seu feed está vazio';

  @override
  String get feedEmptySubtitle =>
      'Siga pessoas e comunidades para ver posts aqui.';

  @override
  String get feedEmptyAction => 'Explorar';

  @override
  String get feedErrorMessage => 'Não foi possível carregar o feed';

  @override
  String get feedRetry => 'Tentar novamente';

  @override
  String get postTimeNow => 'agora';

  @override
  String postTimeMinutes(int n) {
    return 'há ${n}min';
  }

  @override
  String postTimeHours(int n) {
    return 'há ${n}h';
  }

  @override
  String postTimeDays(int n) {
    return 'há ${n}d';
  }

  @override
  String get postSeeMore => 'ver mais';

  @override
  String get postSeeLess => 'ver menos';

  @override
  String get postDefaultUser => 'Usuário';

  @override
  String get prCardNewBadge => 'Novo PR!';

  @override
  String get createPostTitle => 'Criar post';

  @override
  String get createPostPublish => 'Publicar';

  @override
  String get createPostHint => 'O que está acontecendo no seu treino?';

  @override
  String get createPostGallery => 'Galeria';

  @override
  String get createPostCamera => 'Câmera';

  @override
  String get createPostPR => 'PR';

  @override
  String get createPostHashtag => 'Hashtag';

  @override
  String get createPostMention => 'Mencionar';

  @override
  String get createPostPrivacyEveryone => 'Todos';

  @override
  String get createPostPrivacyFollowers => 'Seguidores';

  @override
  String get createPostPrivacyCommunity => 'Comunidade';

  @override
  String get createPostSelectPR => 'Selecionar PR para compartilhar';

  @override
  String get createPostNoPRs => 'Você ainda não tem PRs registrados.';

  @override
  String get createPostSuccess => 'Post publicado!';

  @override
  String get createPostError => 'Erro ao publicar. Tente novamente.';

  @override
  String get commentsTitle => 'Comentários';

  @override
  String get commentsError => 'Erro ao carregar comentários';

  @override
  String get commentsEmpty => 'Seja o primeiro a comentar!';

  @override
  String get commentsReply => 'Responder';

  @override
  String get commentsInputHint => 'Adicionar comentário...';

  @override
  String commentsReplyingTo(String name) {
    return 'Respondendo a @$name';
  }

  @override
  String get prsTitle => 'Personal Records';

  @override
  String get prsSearchHint => 'Buscar exercício...';

  @override
  String get prsFilterAll => 'Todos';

  @override
  String get prsAllExercises => 'Todos os exercícios';

  @override
  String prsExerciseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n exercícios',
      one: '$n exercício',
    );
    return '$_temp0';
  }

  @override
  String get prsHighlights => 'Meus Destaques';

  @override
  String get prsNewBadge => 'Novo PR! 🔥';

  @override
  String get prsEmptyTitle => 'Nenhum PR encontrado';

  @override
  String get prsEmptyFirstTime => 'Registre seu primeiro Personal Record!';

  @override
  String get prsEmptyFilter => 'Tente outros filtros ou termos de busca.';

  @override
  String get prsErrorMessage => 'Erro ao carregar PRs';

  @override
  String get prsRetry => 'Tentar novamente';

  @override
  String get prsTimeToday => 'Hoje';

  @override
  String get prsTimeYesterday => 'Ontem';

  @override
  String prsTimeDaysAgo(int n) {
    return 'Há $n dias';
  }

  @override
  String get muscleChest => 'peito';

  @override
  String get muscleBack => 'costas';

  @override
  String get muscleLegs => 'pernas';

  @override
  String get muscleShoulders => 'ombros';

  @override
  String get muscleBiceps => 'bíceps';

  @override
  String get muscleTriceps => 'tríceps';

  @override
  String get muscleCore => 'core';

  @override
  String get muscleCardio => 'cardio';

  @override
  String get muscleOlympic => 'olímpico';

  @override
  String get muscleOther => 'outros';

  @override
  String get addPrTitle => 'Registrar PR';

  @override
  String get editPrTitle => 'Editar PR';

  @override
  String get addPrExerciseSection => 'Exercício';

  @override
  String get addPrResultSection => 'Resultado';

  @override
  String get addPrRepsSection => 'Repetições (opcional)';

  @override
  String get addPrRepsHint => 'Ex: 5';

  @override
  String get addPrRepsInvalid => 'Número inteiro';

  @override
  String get addPrDateSection => 'Data';

  @override
  String get addPrNotesSection => 'Observações (opcional)';

  @override
  String get addPrNotesHint => 'Como foi o treino, equipamento utilizado...';

  @override
  String get addPrShareToggle => 'Compartilhar no feed';

  @override
  String get addPrShareSubtitle => 'Seus seguidores verão este PR no feed';

  @override
  String get addPrSubmit => 'Registrar PR';

  @override
  String get editPrSubmit => 'Salvar alterações';

  @override
  String get addPrSelectExercise => 'Selecionar exercício';

  @override
  String get addPrNoExercise => 'Selecione um exercício';

  @override
  String addPrPreviousBest(String value) {
    return 'Melhor PR atual: $value';
  }

  @override
  String get addPrValueRequired => 'Obrigatório';

  @override
  String get addPrValueInvalid => 'Valor inválido';

  @override
  String get addPrSuccess => 'PR registrado!';

  @override
  String get addPrError => 'Erro ao salvar PR. Tente novamente.';

  @override
  String get addPrCelebrationTitle => 'Novo Personal Record!';

  @override
  String get addPrCelebrationButton => 'Incrível! 🎉';

  @override
  String addPrCelebrationImprovement(String value, String unit) {
    return '+$value $unit acima do anterior';
  }

  @override
  String get exerciseSearchHint => 'Buscar exercício...';

  @override
  String get exerciseCreateNew => 'Criar novo';

  @override
  String get exerciseCreateTitle => 'Criar exercício';

  @override
  String get exerciseNameLabel => 'Nome do exercício';

  @override
  String get exerciseNameHint => 'Ex: Supino Engessado';

  @override
  String get exerciseMuscleLabel => 'Grupo muscular';

  @override
  String get exerciseUnitLabel => 'Unidade';

  @override
  String get exerciseCreateButton => 'Criar';

  @override
  String get deletePrTitle => 'Deletar PR?';

  @override
  String get deletePrConfirm => 'Esta ação não pode ser desfeita.';

  @override
  String get deletePrButton => 'Deletar';

  @override
  String get cancelButton => 'Cancelar';
}
