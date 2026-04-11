import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @loginTitle.
  ///
  /// In pt, this message translates to:
  /// **'Conecte-se com sua comunidade esportiva'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'Informe o e-mail'**
  String get loginEmailHint;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Informe a senha'**
  String get loginPasswordHint;

  /// No description provided for @loginPasswordMin.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 6 caracteres'**
  String get loginPasswordMin;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta?'**
  String get loginNoAccount;

  /// No description provided for @loginCreateAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get loginCreateAccount;

  /// No description provided for @loginOr.
  ///
  /// In pt, this message translates to:
  /// **'ou continue com'**
  String get loginOr;

  /// No description provided for @loginGoogleError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter token do Google'**
  String get loginGoogleError;

  /// No description provided for @loginAppleUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Apple Sign In indisponível neste dispositivo'**
  String get loginAppleUnavailable;

  /// No description provided for @loginAppleError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível obter token da Apple'**
  String get loginAppleError;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerTitle;

  /// No description provided for @registerNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get registerNameLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome'**
  String get registerNameHint;

  /// No description provided for @registerNameTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Nome muito curto'**
  String get registerNameTooShort;

  /// No description provided for @registerEmailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'Informe o e-mail'**
  String get registerEmailHint;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'E-mail inválido'**
  String get registerEmailInvalid;

  /// No description provided for @registerEmailTaken.
  ///
  /// In pt, this message translates to:
  /// **'E-mail já cadastrado'**
  String get registerEmailTaken;

  /// No description provided for @registerEmailAvailable.
  ///
  /// In pt, this message translates to:
  /// **'E-mail disponível'**
  String get registerEmailAvailable;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Informe a senha'**
  String get registerPasswordHint;

  /// No description provided for @registerPasswordMin.
  ///
  /// In pt, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get registerPasswordMin;

  /// No description provided for @registerPasswordUppercase.
  ///
  /// In pt, this message translates to:
  /// **'Inclua ao menos 1 letra maiúscula'**
  String get registerPasswordUppercase;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get registerConfirmPassword;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não conferem'**
  String get registerPasswordMismatch;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameHint.
  ///
  /// In pt, this message translates to:
  /// **'Informe um username'**
  String get registerUsernameHint;

  /// No description provided for @registerUsernameInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Username inválido'**
  String get registerUsernameInvalid;

  /// No description provided for @registerUsernameAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Username disponível'**
  String get registerUsernameAvailable;

  /// No description provided for @registerUsernameTaken.
  ///
  /// In pt, this message translates to:
  /// **'Username indisponível'**
  String get registerUsernameTaken;

  /// No description provided for @registerStep.
  ///
  /// In pt, this message translates to:
  /// **'Etapa {step} de {total}'**
  String registerStep(int step, int total);

  /// No description provided for @registerPasswordLowercase.
  ///
  /// In pt, this message translates to:
  /// **'Inclua ao menos 1 letra minúscula'**
  String get registerPasswordLowercase;

  /// No description provided for @registerPasswordNumber.
  ///
  /// In pt, this message translates to:
  /// **'Inclua ao menos 1 número'**
  String get registerPasswordNumber;

  /// No description provided for @registerPasswordSpecial.
  ///
  /// In pt, this message translates to:
  /// **'Inclua ao menos 1 caractere especial'**
  String get registerPasswordSpecial;

  /// No description provided for @registerConfirmPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua senha'**
  String get registerConfirmPasswordHint;

  /// No description provided for @registerEmailChecking.
  ///
  /// In pt, this message translates to:
  /// **'Validando e-mail...'**
  String get registerEmailChecking;

  /// No description provided for @registerUsernameChecking.
  ///
  /// In pt, this message translates to:
  /// **'Validando username...'**
  String get registerUsernameChecking;

  /// No description provided for @registerUsernameHelper.
  ///
  /// In pt, this message translates to:
  /// **'Use 3 a 20 caracteres: letras, números ou _'**
  String get registerUsernameHelper;

  /// No description provided for @registerAddPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar foto (opcional)'**
  String get registerAddPhoto;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta?'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get registerSignIn;

  /// No description provided for @registerAwaitEmailValidation.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde a validação do e-mail.'**
  String get registerAwaitEmailValidation;

  /// No description provided for @registerAwaitUsernameValidation.
  ///
  /// In pt, this message translates to:
  /// **'Aguarde a validação do username.'**
  String get registerAwaitUsernameValidation;

  /// No description provided for @registerBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get registerBack;

  /// No description provided for @registerNext.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get registerNext;

  /// No description provided for @registerSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get registerSubmit;

  /// No description provided for @onboardingSportsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quais esportes te interessam?'**
  String get onboardingSportsTitle;

  /// No description provided for @onboardingSportsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Selecione quantos quiser para personalizar seu feed'**
  String get onboardingSportsSubtitle;

  /// No description provided for @onboardingLevelTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual seu nível atual?'**
  String get onboardingLevelTitle;

  /// No description provided for @onboardingLevelSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Isso ajuda a sugerir desafios no ritmo certo'**
  String get onboardingLevelSubtitle;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual seu objetivo principal?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu objetivo define metas e recomendações iniciais'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Ativar localização para o Nearby?'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Com isso, você encontra pessoas e locais de treino perto de você'**
  String get onboardingLocationSubtitle;

  /// No description provided for @onboardingLocationEnable.
  ///
  /// In pt, this message translates to:
  /// **'Quero usar o Nearby'**
  String get onboardingLocationEnable;

  /// No description provided for @onboardingSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get onboardingSkip;

  /// No description provided for @onboardingFinishLater.
  ///
  /// In pt, this message translates to:
  /// **'Finalizar depois'**
  String get onboardingFinishLater;

  /// No description provided for @onboardingContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get onboardingContinue;

  /// No description provided for @onboardingComplete.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get onboardingComplete;

  /// No description provided for @sportMusculacao.
  ///
  /// In pt, this message translates to:
  /// **'Musculação'**
  String get sportMusculacao;

  /// No description provided for @sportCorrida.
  ///
  /// In pt, this message translates to:
  /// **'Corrida'**
  String get sportCorrida;

  /// No description provided for @sportCiclismo.
  ///
  /// In pt, this message translates to:
  /// **'Ciclismo'**
  String get sportCiclismo;

  /// No description provided for @sportCrossfit.
  ///
  /// In pt, this message translates to:
  /// **'Crossfit'**
  String get sportCrossfit;

  /// No description provided for @sportNatacao.
  ///
  /// In pt, this message translates to:
  /// **'Natação'**
  String get sportNatacao;

  /// No description provided for @sportFutebol.
  ///
  /// In pt, this message translates to:
  /// **'Futebol'**
  String get sportFutebol;

  /// No description provided for @sportYoga.
  ///
  /// In pt, this message translates to:
  /// **'Yoga'**
  String get sportYoga;

  /// No description provided for @sportCalistenia.
  ///
  /// In pt, this message translates to:
  /// **'Calistenia'**
  String get sportCalistenia;

  /// No description provided for @levelBeginner.
  ///
  /// In pt, this message translates to:
  /// **'Iniciante'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In pt, this message translates to:
  /// **'Intermediário'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In pt, this message translates to:
  /// **'Avançado'**
  String get levelAdvanced;

  /// No description provided for @goalHypertrophy.
  ///
  /// In pt, this message translates to:
  /// **'Hipertrofia'**
  String get goalHypertrophy;

  /// No description provided for @goalWeightLoss.
  ///
  /// In pt, this message translates to:
  /// **'Emagrecimento'**
  String get goalWeightLoss;

  /// No description provided for @goalPerformance.
  ///
  /// In pt, this message translates to:
  /// **'Performance'**
  String get goalPerformance;

  /// No description provided for @goalHealth.
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
  String get goalHealth;

  /// No description provided for @feedEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Seu feed está vazio'**
  String get feedEmptyTitle;

  /// No description provided for @feedEmptySubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Siga pessoas e comunidades para ver posts aqui.'**
  String get feedEmptySubtitle;

  /// No description provided for @feedEmptyAction.
  ///
  /// In pt, this message translates to:
  /// **'Explorar'**
  String get feedEmptyAction;

  /// No description provided for @feedErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o feed'**
  String get feedErrorMessage;

  /// No description provided for @feedRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get feedRetry;

  /// No description provided for @postTimeNow.
  ///
  /// In pt, this message translates to:
  /// **'agora'**
  String get postTimeNow;

  /// No description provided for @postTimeMinutes.
  ///
  /// In pt, this message translates to:
  /// **'há {n}min'**
  String postTimeMinutes(int n);

  /// No description provided for @postTimeHours.
  ///
  /// In pt, this message translates to:
  /// **'há {n}h'**
  String postTimeHours(int n);

  /// No description provided for @postTimeDays.
  ///
  /// In pt, this message translates to:
  /// **'há {n}d'**
  String postTimeDays(int n);

  /// No description provided for @postSeeMore.
  ///
  /// In pt, this message translates to:
  /// **'ver mais'**
  String get postSeeMore;

  /// No description provided for @postSeeLess.
  ///
  /// In pt, this message translates to:
  /// **'ver menos'**
  String get postSeeLess;

  /// No description provided for @postDefaultUser.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get postDefaultUser;

  /// No description provided for @prCardNewBadge.
  ///
  /// In pt, this message translates to:
  /// **'Novo PR!'**
  String get prCardNewBadge;

  /// No description provided for @createPostTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar post'**
  String get createPostTitle;

  /// No description provided for @createPostPublish.
  ///
  /// In pt, this message translates to:
  /// **'Publicar'**
  String get createPostPublish;

  /// No description provided for @createPostHint.
  ///
  /// In pt, this message translates to:
  /// **'O que está acontecendo no seu treino?'**
  String get createPostHint;

  /// No description provided for @createPostGallery.
  ///
  /// In pt, this message translates to:
  /// **'Galeria'**
  String get createPostGallery;

  /// No description provided for @createPostCamera.
  ///
  /// In pt, this message translates to:
  /// **'Câmera'**
  String get createPostCamera;

  /// No description provided for @createPostPR.
  ///
  /// In pt, this message translates to:
  /// **'PR'**
  String get createPostPR;

  /// No description provided for @createPostHashtag.
  ///
  /// In pt, this message translates to:
  /// **'Hashtag'**
  String get createPostHashtag;

  /// No description provided for @createPostMention.
  ///
  /// In pt, this message translates to:
  /// **'Mencionar'**
  String get createPostMention;

  /// No description provided for @createPostPrivacyEveryone.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get createPostPrivacyEveryone;

  /// No description provided for @createPostPrivacyFollowers.
  ///
  /// In pt, this message translates to:
  /// **'Seguidores'**
  String get createPostPrivacyFollowers;

  /// No description provided for @createPostPrivacyCommunity.
  ///
  /// In pt, this message translates to:
  /// **'Comunidade'**
  String get createPostPrivacyCommunity;

  /// No description provided for @createPostSelectPR.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar PR para compartilhar'**
  String get createPostSelectPR;

  /// No description provided for @createPostNoPRs.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não tem PRs registrados.'**
  String get createPostNoPRs;

  /// No description provided for @createPostSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Post publicado!'**
  String get createPostSuccess;

  /// No description provided for @createPostError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao publicar. Tente novamente.'**
  String get createPostError;

  /// No description provided for @commentsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Comentários'**
  String get commentsTitle;

  /// No description provided for @commentsError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar comentários'**
  String get commentsError;

  /// No description provided for @commentsEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Seja o primeiro a comentar!'**
  String get commentsEmpty;

  /// No description provided for @commentsReply.
  ///
  /// In pt, this message translates to:
  /// **'Responder'**
  String get commentsReply;

  /// No description provided for @commentsInputHint.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar comentário...'**
  String get commentsInputHint;

  /// No description provided for @commentsReplyingTo.
  ///
  /// In pt, this message translates to:
  /// **'Respondendo a @{name}'**
  String commentsReplyingTo(String name);

  /// No description provided for @prsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Personal Records'**
  String get prsTitle;

  /// No description provided for @prsSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar exercício...'**
  String get prsSearchHint;

  /// No description provided for @prsFilterAll.
  ///
  /// In pt, this message translates to:
  /// **'Todos'**
  String get prsFilterAll;

  /// No description provided for @prsAllExercises.
  ///
  /// In pt, this message translates to:
  /// **'Todos os exercícios'**
  String get prsAllExercises;

  /// No description provided for @prsExerciseCount.
  ///
  /// In pt, this message translates to:
  /// **'{n, plural, one{{n} exercício} other{{n} exercícios}}'**
  String prsExerciseCount(int n);

  /// No description provided for @prsHighlights.
  ///
  /// In pt, this message translates to:
  /// **'Meus Destaques'**
  String get prsHighlights;

  /// No description provided for @prsNewBadge.
  ///
  /// In pt, this message translates to:
  /// **'Novo PR! 🔥'**
  String get prsNewBadge;

  /// No description provided for @prsEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum PR encontrado'**
  String get prsEmptyTitle;

  /// No description provided for @prsEmptyFirstTime.
  ///
  /// In pt, this message translates to:
  /// **'Registre seu primeiro Personal Record!'**
  String get prsEmptyFirstTime;

  /// No description provided for @prsEmptyFilter.
  ///
  /// In pt, this message translates to:
  /// **'Tente outros filtros ou termos de busca.'**
  String get prsEmptyFilter;

  /// No description provided for @prsErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao carregar PRs'**
  String get prsErrorMessage;

  /// No description provided for @prsRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get prsRetry;

  /// No description provided for @prsTimeToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get prsTimeToday;

  /// No description provided for @prsTimeYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get prsTimeYesterday;

  /// No description provided for @prsTimeDaysAgo.
  ///
  /// In pt, this message translates to:
  /// **'Há {n} dias'**
  String prsTimeDaysAgo(int n);

  /// No description provided for @muscleChest.
  ///
  /// In pt, this message translates to:
  /// **'peito'**
  String get muscleChest;

  /// No description provided for @muscleBack.
  ///
  /// In pt, this message translates to:
  /// **'costas'**
  String get muscleBack;

  /// No description provided for @muscleLegs.
  ///
  /// In pt, this message translates to:
  /// **'pernas'**
  String get muscleLegs;

  /// No description provided for @muscleShoulders.
  ///
  /// In pt, this message translates to:
  /// **'ombros'**
  String get muscleShoulders;

  /// No description provided for @muscleBiceps.
  ///
  /// In pt, this message translates to:
  /// **'bíceps'**
  String get muscleBiceps;

  /// No description provided for @muscleTriceps.
  ///
  /// In pt, this message translates to:
  /// **'tríceps'**
  String get muscleTriceps;

  /// No description provided for @muscleCore.
  ///
  /// In pt, this message translates to:
  /// **'core'**
  String get muscleCore;

  /// No description provided for @muscleCardio.
  ///
  /// In pt, this message translates to:
  /// **'cardio'**
  String get muscleCardio;

  /// No description provided for @muscleOlympic.
  ///
  /// In pt, this message translates to:
  /// **'olímpico'**
  String get muscleOlympic;

  /// No description provided for @muscleOther.
  ///
  /// In pt, this message translates to:
  /// **'outros'**
  String get muscleOther;

  /// No description provided for @addPrTitle.
  ///
  /// In pt, this message translates to:
  /// **'Registrar PR'**
  String get addPrTitle;

  /// No description provided for @editPrTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar PR'**
  String get editPrTitle;

  /// No description provided for @addPrExerciseSection.
  ///
  /// In pt, this message translates to:
  /// **'Exercício'**
  String get addPrExerciseSection;

  /// No description provided for @addPrResultSection.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get addPrResultSection;

  /// No description provided for @addPrRepsSection.
  ///
  /// In pt, this message translates to:
  /// **'Repetições (opcional)'**
  String get addPrRepsSection;

  /// No description provided for @addPrRepsHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: 5'**
  String get addPrRepsHint;

  /// No description provided for @addPrRepsInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Número inteiro'**
  String get addPrRepsInvalid;

  /// No description provided for @addPrDateSection.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get addPrDateSection;

  /// No description provided for @addPrNotesSection.
  ///
  /// In pt, this message translates to:
  /// **'Observações (opcional)'**
  String get addPrNotesSection;

  /// No description provided for @addPrNotesHint.
  ///
  /// In pt, this message translates to:
  /// **'Como foi o treino, equipamento utilizado...'**
  String get addPrNotesHint;

  /// No description provided for @addPrShareToggle.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhar no feed'**
  String get addPrShareToggle;

  /// No description provided for @addPrShareSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Seus seguidores verão este PR no feed'**
  String get addPrShareSubtitle;

  /// No description provided for @addPrSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Registrar PR'**
  String get addPrSubmit;

  /// No description provided for @editPrSubmit.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get editPrSubmit;

  /// No description provided for @addPrSelectExercise.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar exercício'**
  String get addPrSelectExercise;

  /// No description provided for @addPrNoExercise.
  ///
  /// In pt, this message translates to:
  /// **'Selecione um exercício'**
  String get addPrNoExercise;

  /// No description provided for @addPrPreviousBest.
  ///
  /// In pt, this message translates to:
  /// **'Melhor PR atual: {value}'**
  String addPrPreviousBest(String value);

  /// No description provided for @addPrValueRequired.
  ///
  /// In pt, this message translates to:
  /// **'Obrigatório'**
  String get addPrValueRequired;

  /// No description provided for @addPrValueInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Valor inválido'**
  String get addPrValueInvalid;

  /// No description provided for @addPrSuccess.
  ///
  /// In pt, this message translates to:
  /// **'PR registrado!'**
  String get addPrSuccess;

  /// No description provided for @addPrError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao salvar PR. Tente novamente.'**
  String get addPrError;

  /// No description provided for @addPrCelebrationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo Personal Record!'**
  String get addPrCelebrationTitle;

  /// No description provided for @addPrCelebrationButton.
  ///
  /// In pt, this message translates to:
  /// **'Incrível! 🎉'**
  String get addPrCelebrationButton;

  /// No description provided for @addPrCelebrationImprovement.
  ///
  /// In pt, this message translates to:
  /// **'+{value} {unit} acima do anterior'**
  String addPrCelebrationImprovement(String value, String unit);

  /// No description provided for @exerciseSearchHint.
  ///
  /// In pt, this message translates to:
  /// **'Buscar exercício...'**
  String get exerciseSearchHint;

  /// No description provided for @exerciseCreateNew.
  ///
  /// In pt, this message translates to:
  /// **'Criar novo'**
  String get exerciseCreateNew;

  /// No description provided for @exerciseCreateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Criar exercício'**
  String get exerciseCreateTitle;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do exercício'**
  String get exerciseNameLabel;

  /// No description provided for @exerciseNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex: Supino Engessado'**
  String get exerciseNameHint;

  /// No description provided for @exerciseMuscleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Grupo muscular'**
  String get exerciseMuscleLabel;

  /// No description provided for @exerciseUnitLabel.
  ///
  /// In pt, this message translates to:
  /// **'Unidade'**
  String get exerciseUnitLabel;

  /// No description provided for @exerciseCreateButton.
  ///
  /// In pt, this message translates to:
  /// **'Criar'**
  String get exerciseCreateButton;

  /// No description provided for @deletePrTitle.
  ///
  /// In pt, this message translates to:
  /// **'Deletar PR?'**
  String get deletePrTitle;

  /// No description provided for @deletePrConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Esta ação não pode ser desfeita.'**
  String get deletePrConfirm;

  /// No description provided for @deletePrButton.
  ///
  /// In pt, this message translates to:
  /// **'Deletar'**
  String get deletePrButton;

  /// No description provided for @cancelButton.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
