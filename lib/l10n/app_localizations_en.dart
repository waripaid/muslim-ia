// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Muslim IA';

  @override
  String get appTagline => 'Your intelligent Islamic assistant';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get later => 'Later';

  @override
  String get send => 'Send';

  @override
  String get resend => 'Resend';

  @override
  String get edit => 'Edit';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get today => 'Today';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out';

  @override
  String get logoutConfirmBody => 'Are you sure you want to log out?';

  @override
  String get login => 'Sign in';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Choose the app language';

  @override
  String get detectedCountry => 'Detected country';

  @override
  String get automaticLanguage => 'Automatic language';

  @override
  String get autoLanguageDescription =>
      'Automatic detection based on your country';

  @override
  String get chatNew => 'New chat';

  @override
  String get chatTracker => 'Islamic Tracker';

  @override
  String get chatTrackerSubtitle => 'Prayers, Quran, goals';

  @override
  String get chatCurrent => 'Current';

  @override
  String get chatHistory => 'History';

  @override
  String get chatMessages => 'messages';

  @override
  String get chatNoConversations => 'No conversations';

  @override
  String get chatDeleteTitle => 'Delete this conversation?';

  @override
  String chatDeleteBody(Object title) {
    return '\"$title\" will be permanently deleted.';
  }

  @override
  String get chatEmptyHint => 'What does the Quran say about patience?';

  @override
  String get chatWelcomeTitle => 'Assalamu alaykum! How can I help you today?';

  @override
  String get chatSuggestionQuran => 'What does the Quran say about patience?';

  @override
  String get chatSuggestionSurah => 'Explain Surah Al-Fatiha to me';

  @override
  String get chatSuggestionWord => 'Analyze the Arabic word \"Rahman\"';

  @override
  String get chatSuggestionAdvice => 'Give me a daily Islamic advice';

  @override
  String get chatSuggestionVocab => 'Teach me 5 Quranic vocabulary words';

  @override
  String get chatSuggestionProphet => 'Tell me about Prophet Muhammad ﷺ';

  @override
  String get chatInputHint => 'Message Muslim IA...';

  @override
  String get chatLimitTitle => 'Limit reached';

  @override
  String chatLimitBody(Object count) {
    return 'You have sent $count messages today.\n\nCome back tomorrow to keep chatting for free, or subscribe for unlimited access.';
  }

  @override
  String get chatRecording => 'Recording...';

  @override
  String get chatMicPermission =>
      'Allow microphone access to record a voice message.';

  @override
  String get chatMicPermissionTitle => 'Microphone blocked';

  @override
  String get chatMicPermissionDenied =>
      'Microphone access is disabled. Open settings to allow it, then try again.';

  @override
  String get chatMicSettings => 'Open settings';

  @override
  String chatRecordError(Object error) {
    return 'Recording error: $error';
  }

  @override
  String get chatContinue => 'Continue';

  @override
  String get chatCopy => 'Copy';

  @override
  String get chatEdit => 'Edit';

  @override
  String get chatEditing => 'Editing message…';

  @override
  String get chatShare => 'Share';

  @override
  String get chatAttachTitle => 'Attach';

  @override
  String get chatCopied => 'Message copied';

  @override
  String get chatPhotoSelected => 'Photo selected';

  @override
  String get chatChooseImage => 'Choose an image';

  @override
  String get chatTakePhoto => 'Take a photo';

  @override
  String get chatAudioTranscription => 'Audio transcription';

  @override
  String get chatAudioTranscriptionActive =>
      'Audio transcription — record your message';

  @override
  String get close => 'Close';

  @override
  String get chatPreviewTitle => 'Recording preview';

  @override
  String get chatPreviewSubtitle => 'Listen before sending';

  @override
  String get chatNoTextDetected => 'No text detected';

  @override
  String chatTranscriptionError(Object error) {
    return 'Transcription error: $error';
  }

  @override
  String get authLogin => 'Sign in';

  @override
  String get authLoginSubtitle => 'Sign in to continue';

  @override
  String get authRegister => 'Sign up';

  @override
  String get authRegisterSubtitle => 'Create your Muslim IA account';

  @override
  String get authFullName => 'Full name';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'your@email.com';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordHint => 'Your password';

  @override
  String get authConfirmPassword => 'Confirm';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authRegisterButton => 'Sign up';

  @override
  String get authNoAccount => 'No account? ';

  @override
  String get authHaveAccount => 'Already have an account? ';

  @override
  String get authSkip => 'Continue without signing up';

  @override
  String get authSignUpLink => 'Sign up';

  @override
  String get authLoginLink => 'Sign in';

  @override
  String get authNameRequired => 'Enter your full name';

  @override
  String get authNameTooShort => 'Name must be at least 2 characters';

  @override
  String get authEmailInvalid => 'Invalid email';

  @override
  String get authPasswordTooShort => 'Minimum 6 characters';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authFieldsRequired => 'All fields are required';

  @override
  String get authCorrectFields => 'Please correct the fields';

  @override
  String get authErrorNetwork => 'Network error. Check your connection.';

  @override
  String get offlineBanner => 'No internet connection';

  @override
  String get offlineMessage =>
      'You appear to be offline. Check your internet connection and try again.';

  @override
  String get authVerifyTitle => 'Verify your email';

  @override
  String get authVerifySent => 'We sent a verification email to';

  @override
  String get authVerifyInstructions =>
      'Click the link in the email, then press \"Continue\"';

  @override
  String get authVerifyContinue => 'Continue';

  @override
  String get authVerifyResend => 'Resend email';

  @override
  String get authVerifyUseOther => 'Use another account';

  @override
  String get authVerifyEmailSent => 'Email resent! Check your inbox.';

  @override
  String get authEmailNotVerified =>
      'Email not verified. Please check your inbox.';

  @override
  String get authVerifyError => 'Verification error';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileNotProvided => 'Not provided';

  @override
  String get profileNotModifiable => 'Not modifiable';

  @override
  String get profilePassword => 'Password';

  @override
  String get profileChangePassword => 'Change password';

  @override
  String get profilePasswordTitle => 'Change password';

  @override
  String get profilePasswordCurrent => 'Current password';

  @override
  String get profilePasswordNew => 'New password';

  @override
  String get profilePasswordChanged => 'Password changed successfully';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileDarkMode => 'Dark mode';

  @override
  String get profileLightMode => 'Light mode';

  @override
  String profileDeleteConversations(Object count) {
    return 'Delete conversations ($count)';
  }

  @override
  String get profileDeleteConversationsTitle => 'Delete conversations?';

  @override
  String profileDeleteConversationsBody(Object count) {
    return '$count conversation(s) will be permanently deleted.';
  }

  @override
  String get profileDeleteAll => 'Delete all';

  @override
  String get profileSubActive => 'Active subscription';

  @override
  String get profileTrialActive => 'Free trial';

  @override
  String profileDaysLeft(Object days) {
    return '$days days left';
  }

  @override
  String get profileEndsToday => 'Ends today';

  @override
  String get profileFreeMessages => 'Free messages';

  @override
  String profileToday(Object left, Object total) {
    return '$left / $total today';
  }

  @override
  String get profileSubscription => 'Subscription';

  @override
  String get profileFreePlan => 'Free plan';

  @override
  String get profileUpgrade => 'Go Premium';

  @override
  String get appBarPremium => 'Go Premium';

  @override
  String get profileProgressPlan => 'Account progress bar';

  @override
  String get trackerTitle => 'Islamic Tracker';

  @override
  String get trackerToday => 'Today';

  @override
  String get trackerObjectives => 'Goals';

  @override
  String get trackerTools => 'Mini tools';

  @override
  String get trackerHistory => 'History';

  @override
  String trackerDays(Object days) {
    return '$days days';
  }

  @override
  String get trackerStreakSubtitle => 'prayer streak';

  @override
  String get trackerPrayersToday => 'Today\'s prayers';

  @override
  String get trackerDone => 'Done';

  @override
  String get trackerQuranReading => 'Quran reading';

  @override
  String trackerPages(Object goal, Object pages) {
    return '$pages/$goal pages';
  }

  @override
  String get trackerHabitsToday => 'Today\'s habits';

  @override
  String get trackerAddHabits => 'Add your daily habits';

  @override
  String get trackerNewHabit => 'New habit';

  @override
  String get trackerHabitHint => 'E.g.: Read Surah Al-Kahf';

  @override
  String get trackerAdd => 'Add';

  @override
  String get trackerNewObjective => 'New goal';

  @override
  String get trackerInProgress => 'In progress';

  @override
  String get trackerCompleted => 'Completed';

  @override
  String get trackerNoObjectives => 'No goals yet';

  @override
  String get trackerNoObjectivesSubtitle =>
      'Set your spiritual and daily goals';

  @override
  String get trackerCatSpiritual => 'Spiritual';

  @override
  String get trackerCatSport => 'Sport';

  @override
  String get trackerCatWork => 'Work';

  @override
  String get trackerCatStudy => 'Studies';

  @override
  String get trackerCatFinance => 'Finance';

  @override
  String get trackerCatHealth => 'Health';

  @override
  String get trackerCatOther => 'Other';

  @override
  String get trackerReopen => 'Reopen';

  @override
  String get trackerMarkDone => '✓ Done';

  @override
  String get trackerTitleField => 'Title';

  @override
  String get trackerTargetField => 'Target';

  @override
  String get trackerUnitField => 'Unit';

  @override
  String get trackerCategory => 'Category';

  @override
  String get trackerCreate => 'Create';

  @override
  String get trackerTimes => 'times';

  @override
  String get trackerHelp => 'Muslim IA helps you track your daily activities';

  @override
  String trackerGoal(Object target, Object unit) {
    return 'Goal: $target $unit';
  }

  @override
  String get trackerReset => 'Reset';

  @override
  String get trackerNoteHint => 'Write today\'s meal...';

  @override
  String get trackerAddItemHint => 'Add an item...';

  @override
  String get trackerNoHistory => 'No history';

  @override
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  ) {
    return 'Prayers: $done/$total • Quran: ${pages}p • Streak: ${days}d';
  }

  @override
  String get trackerVersets => 'verses';

  @override
  String surahVersets(Object count) {
    return '$count verses';
  }

  @override
  String surahExplain(Object name) {
    return 'Explain $name';
  }

  @override
  String get surahFilter => 'Filter by name or number...';

  @override
  String get surahMeccan => 'Meccan';

  @override
  String get surahMedinan => 'Medinan';

  @override
  String get memorizeTouchTranslation => 'Tap for translation';

  @override
  String get memorizeTouchReveal => 'Tap to reveal';

  @override
  String get memorizeAgain => 'Again';

  @override
  String get memorizeEasy => 'Easy';

  @override
  String get memorizeHard => 'Hard';

  @override
  String get writingStrokeThin => 'Thin';

  @override
  String get writingStrokeMedium => 'Medium';

  @override
  String get writingStrokeThick => 'Thick';

  @override
  String get writingClear => 'Clear';

  @override
  String get writingClearAll => 'All';

  @override
  String get writingNextLetter => 'Next letter';

  @override
  String get paywallTitle => 'Muslim IA Premium';

  @override
  String get paywallSubtitle => 'Premium subscription';

  @override
  String get paywallCard => 'Card payment • No commitment';

  @override
  String get paywallPay => 'Pay by card';

  @override
  String get paywallProcessing => 'Please wait...';

  @override
  String get paywallVerifying => 'Verifying...';

  @override
  String get paywallAlreadyPaid => 'I have already paid';

  @override
  String get paywallPopular => 'POPULAR';

  @override
  String get paywallFreeChat => 'Unlimited AI chat';

  @override
  String get paywallVision => 'AI Vision';

  @override
  String get paywallAlarm => 'Alarm + phone lock';

  @override
  String get paywallPrayerAlerts => 'Prayer alerts';

  @override
  String get paywallQuranExplorer => 'Quran explorer';

  @override
  String get paywallMemorization => 'Memorization & Tracking';

  @override
  String get paywallSearchMCP => 'Advanced MCP search';

  @override
  String get paywallTheme => 'Custom theme';

  @override
  String paywallTrialDays(Object days) {
    return 'Free trial — $days left';
  }

  @override
  String get paywallTrialEnded => 'Your trial has ended';

  @override
  String get paywallPaymentError => 'Payment error. Please try again.';

  @override
  String get paywallPaymentNotDetected => 'Payment not detected.';

  @override
  String get paywallSuccess =>
      'Payment successful! Your Premium subscription is now active.';

  @override
  String get paymentSuccessTitle => 'Subscription activated!';

  @override
  String get paymentSuccessSubtitle =>
      'Your Premium subscription is now active. Enjoy all the features right away.';

  @override
  String get paymentStart => 'Get Started';

  @override
  String get paymentFailureTitle => 'Payment failed';

  @override
  String get paymentFailureSubtitle =>
      'Your payment did not go through. Check your card and try again, or come back later.';

  @override
  String get paywallAssistant => 'Intelligent Islamic assistant';

  @override
  String get retry => 'Try again';

  @override
  String get prayerUnlock => 'Unlock now';

  @override
  String get prayerTime => 'prayer time';

  @override
  String get prayerAutoUnlock =>
      'The phone will unlock\nautomatically after the prayer';

  @override
  String get prayerRemaining => 'remaining';

  @override
  String get prayerTitle => 'Prayer';

  @override
  String get prayerAlarmStopped => 'Alarm stopped';

  @override
  String get prayerLockModeOn => 'Lock mode enabled';

  @override
  String get prayerLockModeOff => 'Lock mode disabled';

  @override
  String get prayerStopAlarm => 'Stop alarm';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset your password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address. We\'ll send you a link to reset your password.';

  @override
  String get forgotPasswordEmailLabel => 'Email address';

  @override
  String get forgotPasswordEmailHint => 'your@email.com';

  @override
  String get forgotPasswordInvalidEmail => 'Invalid email address';

  @override
  String get forgotPasswordSend => 'Send link';

  @override
  String get forgotPasswordSent =>
      'Password reset email sent! Check your inbox.';

  @override
  String get authResetTitle => 'Reset password';

  @override
  String get authResetSent => 'Reset email sent! Check your inbox.';

  @override
  String get authMfaTitle => 'Two-step verification';

  @override
  String get authMfaBody =>
      'Enter the 6-digit code generated by your authenticator app.';

  @override
  String get profileEmailChange => 'Change email';

  @override
  String get profileEmailNew => 'New email';

  @override
  String get profileEmailChanged =>
      'Email changed! Check your new email to confirm.';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileMfa => 'Two-factor authentication';

  @override
  String get profileMfaEnabled => 'Enabled';

  @override
  String get profileMfaDisabled => 'Disabled';

  @override
  String get profileMfaSetupTitle => 'Enable two-factor authentication';

  @override
  String get profileMfaStepQr =>
      'Scan the QR code with your authenticator app (Google Authenticator, Authy...) then enter the generated code.';

  @override
  String get profileMfaSecretKey => 'Secret key';

  @override
  String get profileMfaCode => '6-digit code';

  @override
  String get profileMfaCodeHint => '123456';

  @override
  String get profileMfaActivate => 'Enable';

  @override
  String get profileMfaEnabledMsg =>
      'Two-factor authentication enabled. A confirmation email has been sent.';

  @override
  String get profileMfaDisabledMsg => 'Two-factor authentication disabled.';

  @override
  String get profileMfaInvalidCode => 'Invalid or expired code. Try again.';

  @override
  String get profileMfaDisableTitle => 'Disable two-factor authentication';

  @override
  String get profileMfaDisableBody =>
      'Enter your password to confirm disabling.';

  @override
  String get profileMfaDisable => 'Disable';
}
