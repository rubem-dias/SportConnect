// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'Connect with your sports community';

  @override
  String get loginEmailLabel => 'E-mail';

  @override
  String get loginEmailHint => 'Enter your e-mail';

  @override
  String get loginEmailInvalid => 'Invalid e-mail';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordHint => 'Enter your password';

  @override
  String get loginPasswordMin => 'Minimum 6 characters';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgotPassword => 'Forgot my password';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginCreateAccount => 'Create account';

  @override
  String get loginOr => 'or continue with';

  @override
  String get loginGoogleError => 'Could not get Google token';

  @override
  String get loginAppleUnavailable =>
      'Apple Sign In is not available on this device';

  @override
  String get loginAppleError => 'Could not get Apple token';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerNameLabel => 'Full name';

  @override
  String get registerNameHint => 'Enter your name';

  @override
  String get registerNameTooShort => 'Name too short';

  @override
  String get registerEmailLabel => 'E-mail';

  @override
  String get registerEmailHint => 'Enter your e-mail';

  @override
  String get registerEmailInvalid => 'Invalid e-mail';

  @override
  String get registerEmailTaken => 'E-mail already registered';

  @override
  String get registerEmailAvailable => 'E-mail available';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordHint => 'Enter your password';

  @override
  String get registerPasswordMin => 'Minimum 8 characters';

  @override
  String get registerPasswordUppercase => 'Include at least 1 uppercase letter';

  @override
  String get registerConfirmPassword => 'Confirm password';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerUsernameHint => 'Enter a username';

  @override
  String get registerUsernameInvalid => 'Invalid username';

  @override
  String get registerUsernameAvailable => 'Username available';

  @override
  String get registerUsernameTaken => 'Username unavailable';

  @override
  String registerStep(int step, int total) {
    return 'Step $step of $total';
  }

  @override
  String get registerPasswordLowercase => 'Include at least 1 lowercase letter';

  @override
  String get registerPasswordNumber => 'Include at least 1 number';

  @override
  String get registerPasswordSpecial => 'Include at least 1 special character';

  @override
  String get registerConfirmPasswordHint => 'Confirm your password';

  @override
  String get registerEmailChecking => 'Validating e-mail...';

  @override
  String get registerUsernameChecking => 'Validating username...';

  @override
  String get registerUsernameHelper =>
      'Use 3 to 20 characters: letters, numbers or _';

  @override
  String get registerAddPhoto => 'Add photo (optional)';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get registerAwaitEmailValidation =>
      'Please wait for e-mail validation.';

  @override
  String get registerAwaitUsernameValidation =>
      'Please wait for username validation.';

  @override
  String get registerBack => 'Back';

  @override
  String get registerNext => 'Continue';

  @override
  String get registerSubmit => 'Create account';

  @override
  String get onboardingTitle => 'Onboarding';

  @override
  String get onboardingLocationNote =>
      'This permission can be changed later in settings.';

  @override
  String get onboardingSportsTitle => 'Which sports interest you?';

  @override
  String get onboardingSportsSubtitle =>
      'Select as many as you want to personalize your feed';

  @override
  String get onboardingLevelTitle => 'What is your current level?';

  @override
  String get onboardingLevelSubtitle =>
      'This helps suggest challenges at the right pace';

  @override
  String get onboardingGoalTitle => 'What is your main goal?';

  @override
  String get onboardingGoalSubtitle =>
      'Your goal defines initial targets and recommendations';

  @override
  String get onboardingLocationTitle => 'Enable location for Nearby?';

  @override
  String get onboardingLocationSubtitle =>
      'This lets you find people and workout spots near you';

  @override
  String get onboardingLocationEnable => 'I want to use Nearby';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingFinishLater => 'Finish later';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingComplete => 'Done';

  @override
  String get sportMusculacao => 'Weightlifting';

  @override
  String get sportCorrida => 'Running';

  @override
  String get sportCiclismo => 'Cycling';

  @override
  String get sportCrossfit => 'Crossfit';

  @override
  String get sportNatacao => 'Swimming';

  @override
  String get sportFutebol => 'Football';

  @override
  String get sportYoga => 'Yoga';

  @override
  String get sportCalistenia => 'Calisthenics';

  @override
  String get levelBeginner => 'Beginner';

  @override
  String get levelIntermediate => 'Intermediate';

  @override
  String get levelAdvanced => 'Advanced';

  @override
  String get goalHypertrophy => 'Hypertrophy';

  @override
  String get goalWeightLoss => 'Weight loss';

  @override
  String get goalPerformance => 'Performance';

  @override
  String get goalHealth => 'Health';

  @override
  String get feedEmptyTitle => 'Your feed is empty';

  @override
  String get feedEmptySubtitle =>
      'Follow people and communities to see posts here.';

  @override
  String get feedEmptyAction => 'Explore';

  @override
  String get feedErrorMessage => 'Could not load feed';

  @override
  String get feedRetry => 'Try again';

  @override
  String get postTimeNow => 'now';

  @override
  String postTimeMinutes(int n) {
    return '${n}min ago';
  }

  @override
  String postTimeHours(int n) {
    return '${n}h ago';
  }

  @override
  String postTimeDays(int n) {
    return '${n}d ago';
  }

  @override
  String get postSeeMore => 'see more';

  @override
  String get postSeeLess => 'see less';

  @override
  String get postDefaultUser => 'User';

  @override
  String get prCardNewBadge => 'New PR!';

  @override
  String get createPostTitle => 'Create post';

  @override
  String get createPostPublish => 'Publish';

  @override
  String get createPostHint => 'What\'s happening in your workout?';

  @override
  String get createPostGallery => 'Gallery';

  @override
  String get createPostCamera => 'Camera';

  @override
  String get createPostPR => 'PR';

  @override
  String get createPostHashtag => 'Hashtag';

  @override
  String get createPostMention => 'Mention';

  @override
  String get createPostPrivacyEveryone => 'Everyone';

  @override
  String get createPostPrivacyFollowers => 'Followers';

  @override
  String get createPostPrivacyCommunity => 'Community';

  @override
  String get createPostSelectPR => 'Select PR to share';

  @override
  String get createPostNoPRs => 'You don\'t have any PRs yet.';

  @override
  String get createPostSuccess => 'Post published!';

  @override
  String get createPostError => 'Error publishing. Please try again.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsError => 'Error loading comments';

  @override
  String get commentsEmpty => 'Be the first to comment!';

  @override
  String get commentsReply => 'Reply';

  @override
  String get commentsInputHint => 'Add a comment...';

  @override
  String commentsReplyingTo(String name) {
    return 'Replying to @$name';
  }

  @override
  String get prsTitle => 'Personal Records';

  @override
  String get prsSearchHint => 'Search exercise...';

  @override
  String get prsFilterAll => 'All';

  @override
  String get prsAllExercises => 'All exercises';

  @override
  String prsExerciseCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n exercises',
      one: '$n exercise',
    );
    return '$_temp0';
  }

  @override
  String get prsHighlights => 'My Highlights';

  @override
  String get prsNewBadge => 'New PR! 🔥';

  @override
  String get prsEmptyTitle => 'No PRs found';

  @override
  String get prsEmptyFirstTime => 'Log your first Personal Record!';

  @override
  String get prsEmptyFilter => 'Try other filters or search terms.';

  @override
  String get prsErrorMessage => 'Error loading PRs';

  @override
  String get prsRetry => 'Try again';

  @override
  String get prsTimeToday => 'Today';

  @override
  String get prsTimeYesterday => 'Yesterday';

  @override
  String prsTimeDaysAgo(int n) {
    return '$n days ago';
  }

  @override
  String get muscleChest => 'chest';

  @override
  String get muscleBack => 'back';

  @override
  String get muscleLegs => 'legs';

  @override
  String get muscleShoulders => 'shoulders';

  @override
  String get muscleBiceps => 'biceps';

  @override
  String get muscleTriceps => 'triceps';

  @override
  String get muscleCore => 'core';

  @override
  String get muscleCardio => 'cardio';

  @override
  String get muscleOlympic => 'olympic';

  @override
  String get muscleOther => 'other';

  @override
  String get addPrTitle => 'Log PR';

  @override
  String get editPrTitle => 'Edit PR';

  @override
  String get addPrExerciseSection => 'Exercise';

  @override
  String get addPrResultSection => 'Result';

  @override
  String get addPrRepsSection => 'Reps (optional)';

  @override
  String get addPrRepsHint => 'e.g. 5';

  @override
  String get addPrRepsInvalid => 'Whole number';

  @override
  String get addPrDateSection => 'Date';

  @override
  String get addPrNotesSection => 'Notes (optional)';

  @override
  String get addPrNotesHint => 'How was the workout, equipment used...';

  @override
  String get addPrShareToggle => 'Share to feed';

  @override
  String get addPrShareSubtitle =>
      'Your followers will see this PR in their feed';

  @override
  String get addPrSubmit => 'Log PR';

  @override
  String get editPrSubmit => 'Save changes';

  @override
  String get addPrSelectExercise => 'Select exercise';

  @override
  String get addPrNoExercise => 'Select an exercise';

  @override
  String addPrPreviousBest(String value) {
    return 'Current best: $value';
  }

  @override
  String get addPrValueRequired => 'Required';

  @override
  String get addPrValueInvalid => 'Invalid value';

  @override
  String get addPrSuccess => 'PR logged!';

  @override
  String get addPrError => 'Error saving PR. Please try again.';

  @override
  String get addPrCelebrationTitle => 'New Personal Record!';

  @override
  String get addPrCelebrationButton => 'Amazing! 🎉';

  @override
  String addPrCelebrationImprovement(String value, String unit) {
    return '+$value $unit above previous';
  }

  @override
  String get exerciseSearchHint => 'Search exercise...';

  @override
  String get exerciseCreateNew => 'Create new';

  @override
  String get exerciseCreateTitle => 'Create exercise';

  @override
  String get exerciseNameLabel => 'Exercise name';

  @override
  String get exerciseNameHint => 'e.g. Close-grip Bench Press';

  @override
  String get exerciseMuscleLabel => 'Muscle group';

  @override
  String get exerciseUnitLabel => 'Unit';

  @override
  String get exerciseCreateButton => 'Create';

  @override
  String get deletePrTitle => 'Delete PR?';

  @override
  String get deletePrConfirm => 'This action cannot be undone.';

  @override
  String get deletePrButton => 'Delete';

  @override
  String get cancelButton => 'Cancel';
}
