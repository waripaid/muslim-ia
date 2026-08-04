// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Muslim IA';

  @override
  String get appTagline => 'Votre assistant islamique intelligent';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get confirm => 'Confirmer';

  @override
  String get later => 'Plus tard';

  @override
  String get send => 'Envoyer';

  @override
  String get resend => 'Renvoyer';

  @override
  String get edit => 'Modifier';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get logout => 'Déconnexion';

  @override
  String get logoutConfirmTitle => 'Déconnexion';

  @override
  String get logoutConfirmBody => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get login => 'Se connecter';

  @override
  String get language => 'Langue';

  @override
  String get languageDescription => 'Choisissez la langue de l\'application';

  @override
  String get detectedCountry => 'Pays détecté';

  @override
  String get automaticLanguage => 'Langue automatique';

  @override
  String get autoLanguageDescription =>
      'Détection automatique selon votre pays';

  @override
  String get chatNew => 'Nouveau chat';

  @override
  String get chatTracker => 'Suivi Islamique';

  @override
  String get chatTrackerSubtitle => 'Prières, Coran, objectifs';

  @override
  String get chatCurrent => 'En cours';

  @override
  String get chatHistory => 'Historique';

  @override
  String get chatMessages => 'messages';

  @override
  String get chatNoConversations => 'Aucune conversation';

  @override
  String get chatDeleteTitle => 'Supprimer cette conversation ?';

  @override
  String chatDeleteBody(Object title) {
    return '\"$title\" sera définitivement supprimée.';
  }

  @override
  String get chatEmptyHint => 'Que dit le Coran sur la patience ?';

  @override
  String get chatWelcomeTitle =>
      'Assalamou alaykoum ! Comment puis-je vous aider aujourd\'hui ?';

  @override
  String get chatSuggestionQuran => 'Que dit le Coran sur la patience ?';

  @override
  String get chatSuggestionSurah => 'Explique-moi la sourate Al-Fatiha';

  @override
  String get chatSuggestionWord => 'Analyse le mot arabe \"Rahman\"';

  @override
  String get chatSuggestionAdvice => 'Donne-moi un conseil islamique du jour';

  @override
  String get chatSuggestionVocab =>
      'Apprends-moi 5 mots de vocabulaire coranique';

  @override
  String get chatSuggestionProphet => 'Parle-moi du prophète Muhammad ﷺ';

  @override
  String get chatInputHint => 'Message Muslim IA...';

  @override
  String get chatLimitTitle => 'Limite atteinte';

  @override
  String chatLimitBody(Object count) {
    return 'Vous avez atteint votre limite de $count messages gratuits.\n\nAbonnez-vous pour continuer à discuter sans limite.';
  }

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get premiumFeatureTitle => 'Fonctionnalité Premium';

  @override
  String get premiumFeatureBody =>
      'Cette fonctionnalité est réservée aux abonnés Premium. Abonnez-vous pour y accéder et profiter de messages illimités.';

  @override
  String get chatRecording => 'Enregistrement...';

  @override
  String get chatMicPermission =>
      'Autorisez l\'accès au microphone pour enregistrer un message vocal.';

  @override
  String get chatMicPermissionTitle => 'Microphone bloqué';

  @override
  String get chatMicPermissionDenied =>
      'L\'accès au microphone est désactivé. Ouvrez les paramètres pour l\'autoriser, puis réessayez.';

  @override
  String get chatMicSettings => 'Ouvrir les paramètres';

  @override
  String chatRecordError(Object error) {
    return 'Erreur d\'enregistrement : $error';
  }

  @override
  String get chatContinue => 'Continuer';

  @override
  String get chatCopy => 'Copier';

  @override
  String get chatEdit => 'Modifier';

  @override
  String get chatEditing => 'Modification du message…';

  @override
  String get chatShare => 'Partager';

  @override
  String get chatAttachTitle => 'Joindre';

  @override
  String get chatCopied => 'Message copié';

  @override
  String get chatPhotoSelected => 'Photo sélectionnée';

  @override
  String get chatChooseImage => 'Choisir une image';

  @override
  String get chatTakePhoto => 'Prendre une photo';

  @override
  String get chatAudioTranscription => 'Transcription audio';

  @override
  String get chatAudioTranscriptionActive =>
      'Transcription audio — enregistrez votre message';

  @override
  String get close => 'Fermer';

  @override
  String get chatPreviewTitle => 'Aperçu de l\'enregistrement';

  @override
  String get chatPreviewSubtitle => 'Écoutez avant d\'envoyer';

  @override
  String get chatNoTextDetected => 'Aucun texte détecté';

  @override
  String chatTranscriptionError(Object error) {
    return 'Erreur de transcription: $error';
  }

  @override
  String get chatVoiceTranscriptionLabel => 'Transcription audio';

  @override
  String get authLogin => 'Connexion';

  @override
  String get authLoginSubtitle => 'Connectez-vous pour continuer';

  @override
  String get authRegister => 'Inscription';

  @override
  String get authRegisterSubtitle => 'Créez votre compte Muslim IA';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authEmail => 'Email';

  @override
  String get authEmailHint => 'votre@email.com';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authPasswordHint => 'Votre mot de passe';

  @override
  String get authConfirmPassword => 'Confirmer';

  @override
  String get authLoginButton => 'Se connecter';

  @override
  String get authRegisterButton => 'S\'inscrire';

  @override
  String get authNoAccount => 'Pas de compte ? ';

  @override
  String get authHaveAccount => 'Déjà un compte ? ';

  @override
  String get authSkip => 'Continuer sans inscription';

  @override
  String get authSignUpLink => 'S\'inscrire';

  @override
  String get authLoginLink => 'Se connecter';

  @override
  String get authNameRequired => 'Entrez votre nom complet';

  @override
  String get authNameTooShort => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get authEmailInvalid => 'Email invalide';

  @override
  String get authPasswordTooShort => 'Minimum 6 caractères';

  @override
  String get authPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get authFieldsRequired => 'Tous les champs sont requis';

  @override
  String get authCorrectFields => 'Veuillez corriger les champs';

  @override
  String get authErrorNetwork => 'Erreur réseau. Vérifiez votre connexion.';

  @override
  String get offlineBanner => 'Pas de connexion internet';

  @override
  String get offlineMessage =>
      'Vous êtes hors ligne. Vérifiez votre connexion internet puis réessayez.';

  @override
  String get authVerifyTitle => 'Vérifiez votre email';

  @override
  String get authVerifySent => 'Nous avons envoyé un email de vérification à';

  @override
  String get authVerifyInstructions =>
      'Cliquez sur le lien dans l\'email, puis appuyez sur \"Continuer\"';

  @override
  String get authVerifyContinue => 'Continuer';

  @override
  String get authVerifyResend => 'Renvoyer l\'email';

  @override
  String get authVerifyUseOther => 'Utiliser un autre compte';

  @override
  String get authVerifyEmailSent =>
      'Email renvoyé ! Vérifiez votre boîte de réception.';

  @override
  String get authEmailNotVerified =>
      'Email non vérifié. Veuillez vérifier votre boîte de réception.';

  @override
  String get authVerifyError => 'Erreur de vérification';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileFullName => 'Nom complet';

  @override
  String get profileEmail => 'Email';

  @override
  String get profileNotProvided => 'Non renseigné';

  @override
  String get profileNotModifiable => 'Non modifiable';

  @override
  String get profilePassword => 'Mot de passe';

  @override
  String get profileChangePassword => 'Changer le mot de passe';

  @override
  String get profilePasswordTitle => 'Changer le mot de passe';

  @override
  String get profilePasswordCurrent => 'Mot de passe actuel';

  @override
  String get profilePasswordNew => 'Nouveau mot de passe';

  @override
  String get profilePasswordChanged => 'Mot de passe changé avec succès';

  @override
  String get profileTheme => 'Thème';

  @override
  String get profileDarkMode => 'Mode sombre';

  @override
  String get profileLightMode => 'Mode clair';

  @override
  String profileDeleteConversations(Object count) {
    return 'Supprimer les conversations ($count)';
  }

  @override
  String get profileDeleteConversationsTitle => 'Supprimer les conversations ?';

  @override
  String profileDeleteConversationsBody(Object count) {
    return '$count conversation(s) seront définitivement supprimées.';
  }

  @override
  String get profileDeleteAll => 'Tout supprimer';

  @override
  String get profileSubActive => 'Abonnement actif';

  @override
  String get profileTrialActive => 'Essai gratuit';

  @override
  String profileDaysLeft(Object days) {
    return '$days jours restants';
  }

  @override
  String get profileEndsToday => 'Se termine aujourd\'hui';

  @override
  String get profileFreeMessages => 'Messages gratuits';

  @override
  String profileToday(Object left, Object total) {
    return '$left / $total messages restants';
  }

  @override
  String get profileSubscription => 'Abonnement';

  @override
  String get profileFreePlan => 'Plan gratuit';

  @override
  String get profileUpgrade => 'Passer Premium';

  @override
  String get appBarPremium => 'Passer au Premium';

  @override
  String get profileProgressPlan => 'Barre de progression du compte';

  @override
  String get trackerTitle => 'Suivi Islamique';

  @override
  String get trackerToday => 'Aujourd\'hui';

  @override
  String get trackerObjectives => 'Objectifs';

  @override
  String get trackerTools => 'Mini-outils';

  @override
  String get trackerHistory => 'Historique';

  @override
  String trackerDays(Object days) {
    return '$days jours';
  }

  @override
  String get trackerStreakSubtitle => 'de streak de prière';

  @override
  String get trackerPrayersToday => 'Prières du jour';

  @override
  String get trackerDone => 'Fait';

  @override
  String get trackerQuranReading => 'Lecture du Coran';

  @override
  String trackerPages(Object goal, Object pages) {
    return '$pages/$goal pages';
  }

  @override
  String get trackerHabitsToday => 'Habitudes du jour';

  @override
  String get trackerAddHabits => 'Ajoutez vos habitudes quotidiennes';

  @override
  String get trackerNewHabit => 'Nouvelle habitude';

  @override
  String get trackerHabitHint => 'Ex: Lire Sourate Al-Kahf';

  @override
  String get trackerAdd => 'Ajouter';

  @override
  String get trackerNewObjective => 'Nouvel objectif';

  @override
  String get trackerInProgress => 'En cours';

  @override
  String get trackerCompleted => 'Terminés';

  @override
  String get trackerNoObjectives => 'Aucun objectif';

  @override
  String get trackerNoObjectivesSubtitle =>
      'Définissez vos objectifs spirituels et quotidiens';

  @override
  String get trackerCatSpiritual => 'Spirituel';

  @override
  String get trackerCatSport => 'Sport';

  @override
  String get trackerCatWork => 'Travail';

  @override
  String get trackerCatStudy => 'Études';

  @override
  String get trackerCatFinance => 'Finances';

  @override
  String get trackerCatHealth => 'Santé';

  @override
  String get trackerCatOther => 'Autre';

  @override
  String get trackerReopen => 'Réouvrir';

  @override
  String get trackerMarkDone => '✓ Terminé';

  @override
  String get trackerTitleField => 'Titre';

  @override
  String get trackerTargetField => 'Objectif';

  @override
  String get trackerUnitField => 'Unité';

  @override
  String get trackerCategory => 'Catégorie';

  @override
  String get trackerCreate => 'Créer';

  @override
  String get trackerTimes => 'fois';

  @override
  String get trackerHelp =>
      'Muslim IA vous aide à suivre vos activités quotidiennes';

  @override
  String trackerGoal(Object target, Object unit) {
    return 'Objectif: $target $unit';
  }

  @override
  String get trackerReset => 'Réinitialiser';

  @override
  String get trackerNoteHint => 'Écrivez votre repas du jour...';

  @override
  String get trackerAddItemHint => 'Ajouter un élément...';

  @override
  String get trackerNoHistory => 'Aucun historique';

  @override
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  ) {
    return 'Prières: $done/$total • Quran: ${pages}p • Streak: ${days}j';
  }

  @override
  String get trackerVersets => 'versets';

  @override
  String surahVersets(Object count) {
    return '$count versets';
  }

  @override
  String surahExplain(Object name) {
    return 'Expliquer $name';
  }

  @override
  String get surahFilter => 'Filtrer par nom ou numéro...';

  @override
  String get surahMeccan => 'Mecquoise';

  @override
  String get surahMedinan => 'Médinoise';

  @override
  String get memorizeTouchTranslation => 'Toucher pour la traduction';

  @override
  String get memorizeTouchReveal => 'Toucher pour révéler';

  @override
  String get memorizeAgain => 'Encore';

  @override
  String get memorizeEasy => 'Facile';

  @override
  String get memorizeHard => 'Difficile';

  @override
  String get writingStrokeThin => 'Fin';

  @override
  String get writingStrokeMedium => 'Moyen';

  @override
  String get writingStrokeThick => 'Épais';

  @override
  String get writingClear => 'Effacer';

  @override
  String get writingClearAll => 'Tout';

  @override
  String get writingNextLetter => 'Lettre suivante';

  @override
  String get paywallTitle => 'Muslim IA Premium';

  @override
  String get paywallSubtitle => 'Abonnement Premium';

  @override
  String get paywallCard => 'Paiement par carte bancaire • Sans engagement';

  @override
  String get paywallPay => 'Payer par carte';

  @override
  String get paywallProcessing => 'Patientez...';

  @override
  String get paywallVerifying => 'Vérification...';

  @override
  String get paywallAlreadyPaid => 'J\'ai déjà payé';

  @override
  String get paywallPopular => 'POPULAIRE';

  @override
  String get paywallFreeChat => 'Chat IA illimité';

  @override
  String get paywallVision => 'Vision IA';

  @override
  String get paywallAlarm => 'Alarme + blocage téléphone';

  @override
  String get paywallPrayerAlerts => 'Alertes de prière';

  @override
  String get paywallQuranExplorer => 'Explorateur Coran';

  @override
  String get paywallMemorization => 'Mémorisation & Suivi';

  @override
  String get paywallSearchMCP => 'Recherche avancée MCP';

  @override
  String get paywallTheme => 'Thème personnalisé';

  @override
  String paywallTrialDays(Object days) {
    return 'Essai gratuit — $days restantes';
  }

  @override
  String get paywallTrialEnded => 'Votre essai est terminé';

  @override
  String get paywallPaymentError => 'Erreur de paiement. Veuillez réessayer.';

  @override
  String get paywallPaymentNotDetected => 'Paiement non détecté.';

  @override
  String get paywallSuccess =>
      'Paiement réussi ! Votre abonnement Premium est actif.';

  @override
  String get paymentSuccessTitle => 'Abonnement activé !';

  @override
  String get paymentSuccessSubtitle =>
      'Votre abonnement Premium est actif. Profitez de toutes les fonctionnalités dès maintenant.';

  @override
  String get paymentStart => 'Commencer';

  @override
  String get paymentFailureTitle => 'Paiement échoué';

  @override
  String get paymentFailureSubtitle =>
      'Votre paiement n\'a pas abouti. Vérifiez votre carte et réessayez, ou revenez plus tard.';

  @override
  String get paywallAssistant => 'Assistant islamique intelligent';

  @override
  String get retry => 'Réessayer';

  @override
  String get prayerUnlock => 'Débloquer maintenant';

  @override
  String get prayerTime => 'heure de la prière';

  @override
  String get prayerAutoUnlock =>
      'Le téléphone sera débloqué\nautomatiquement après la prière';

  @override
  String get prayerRemaining => 'restantes';

  @override
  String get prayerTitle => 'Prière';

  @override
  String get prayerAlarmStopped => 'Alarme arrêtée';

  @override
  String get prayerLockModeOn => 'Mode verrouillage activé';

  @override
  String get prayerLockModeOff => 'Mode verrouillage désactivé';

  @override
  String get prayerStopAlarm => 'Couper l\'alarme';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordSubtitle =>
      'Saisissez votre adresse email. Nous vous enverrons un lien pour réinitialiser votre mot de passe.';

  @override
  String get forgotPasswordEmailLabel => 'Adresse email';

  @override
  String get forgotPasswordEmailHint => 'votre@email.com';

  @override
  String get forgotPasswordInvalidEmail => 'Adresse email invalide';

  @override
  String get forgotPasswordSend => 'Envoyer le lien';

  @override
  String get forgotPasswordSent =>
      'Email de réinitialisation envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get authResetTitle => 'Réinitialiser le mot de passe';

  @override
  String get authResetSent =>
      'Email de réinitialisation envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get authMfaTitle => 'Vérification en deux étapes';

  @override
  String get authMfaBody =>
      'Entrez le code à 6 chiffres généré par votre application d\'authentification.';

  @override
  String get profileEmailChange => 'Modifier l\'email';

  @override
  String get profileEmailNew => 'Nouvel email';

  @override
  String get profileEmailChanged =>
      'Email modifié ! Vérifiez votre nouveau email pour confirmer.';

  @override
  String get profileSecurity => 'Sécurité';

  @override
  String get profileMfa => 'Authentification à deux facteurs';

  @override
  String get profileMfaEnabled => 'Activé';

  @override
  String get profileMfaDisabled => 'Désactivé';

  @override
  String get profileMfaSetupTitle =>
      'Activer l\'authentification à deux facteurs';

  @override
  String get profileMfaStepQr =>
      'Scannez le QR code avec votre application d\'authentification (Google Authenticator, Authy...) puis entrez le code généré.';

  @override
  String get profileMfaSecretKey => 'Clé secrète';

  @override
  String get profileMfaCode => 'Code à 6 chiffres';

  @override
  String get profileMfaCodeHint => '123456';

  @override
  String get profileMfaActivate => 'Activer';

  @override
  String get profileMfaEnabledMsg =>
      'Authentification à deux facteurs activée. Un email de confirmation a été envoyé.';

  @override
  String get profileMfaDisabledMsg =>
      'Authentification à deux facteurs désactivée.';

  @override
  String get profileMfaInvalidCode => 'Code invalide ou expiré. Réessayez.';

  @override
  String get profileMfaDisableTitle =>
      'Désactiver l\'authentification à deux facteurs';

  @override
  String get profileMfaDisableBody =>
      'Entrez votre mot de passe pour confirmer la désactivation.';

  @override
  String get profileMfaDisable => 'Désactiver';
}
