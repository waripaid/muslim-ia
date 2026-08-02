import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Muslim IA'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Votre assistant islamique intelligent'**
  String get appTagline;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get later;

  /// No description provided for @send.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer'**
  String get send;

  /// No description provided for @resend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer'**
  String get resend;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @yes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get no;

  /// No description provided for @today.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get today;

  /// No description provided for @logout.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get logoutConfirmBody;

  /// No description provided for @login.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get login;

  /// No description provided for @language.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la langue de l\'application'**
  String get languageDescription;

  /// No description provided for @detectedCountry.
  ///
  /// In fr, this message translates to:
  /// **'Pays détecté'**
  String get detectedCountry;

  /// No description provided for @automaticLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue automatique'**
  String get automaticLanguage;

  /// No description provided for @autoLanguageDescription.
  ///
  /// In fr, this message translates to:
  /// **'Détection automatique selon votre pays'**
  String get autoLanguageDescription;

  /// No description provided for @chatNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau chat'**
  String get chatNew;

  /// No description provided for @chatTracker.
  ///
  /// In fr, this message translates to:
  /// **'Suivi Islamique'**
  String get chatTracker;

  /// No description provided for @chatTrackerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Prières, Coran, objectifs'**
  String get chatTrackerSubtitle;

  /// No description provided for @chatCurrent.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get chatCurrent;

  /// No description provided for @chatHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get chatHistory;

  /// No description provided for @chatMessages.
  ///
  /// In fr, this message translates to:
  /// **'messages'**
  String get chatMessages;

  /// No description provided for @chatNoConversations.
  ///
  /// In fr, this message translates to:
  /// **'Aucune conversation'**
  String get chatNoConversations;

  /// No description provided for @chatDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette conversation ?'**
  String get chatDeleteTitle;

  /// No description provided for @chatDeleteBody.
  ///
  /// In fr, this message translates to:
  /// **'\"{title}\" sera définitivement supprimée.'**
  String chatDeleteBody(Object title);

  /// No description provided for @chatEmptyHint.
  ///
  /// In fr, this message translates to:
  /// **'Que dit le Coran sur la patience ?'**
  String get chatEmptyHint;

  /// No description provided for @chatWelcomeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Assalamou alaykoum ! Comment puis-je vous aider aujourd\'hui ?'**
  String get chatWelcomeTitle;

  /// No description provided for @chatSuggestionQuran.
  ///
  /// In fr, this message translates to:
  /// **'Que dit le Coran sur la patience ?'**
  String get chatSuggestionQuran;

  /// No description provided for @chatSuggestionSurah.
  ///
  /// In fr, this message translates to:
  /// **'Explique-moi la sourate Al-Fatiha'**
  String get chatSuggestionSurah;

  /// No description provided for @chatSuggestionWord.
  ///
  /// In fr, this message translates to:
  /// **'Analyse le mot arabe \"Rahman\"'**
  String get chatSuggestionWord;

  /// No description provided for @chatSuggestionAdvice.
  ///
  /// In fr, this message translates to:
  /// **'Donne-moi un conseil islamique du jour'**
  String get chatSuggestionAdvice;

  /// No description provided for @chatSuggestionVocab.
  ///
  /// In fr, this message translates to:
  /// **'Apprends-moi 5 mots de vocabulaire coranique'**
  String get chatSuggestionVocab;

  /// No description provided for @chatSuggestionProphet.
  ///
  /// In fr, this message translates to:
  /// **'Parle-moi du prophète Muhammad ﷺ'**
  String get chatSuggestionProphet;

  /// No description provided for @chatInputHint.
  ///
  /// In fr, this message translates to:
  /// **'Message Muslim IA...'**
  String get chatInputHint;

  /// No description provided for @chatLimitTitle.
  ///
  /// In fr, this message translates to:
  /// **'Limite atteinte'**
  String get chatLimitTitle;

  /// No description provided for @chatLimitBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez envoyé {count} messages aujourd\'hui.\n\nRevenez demain pour continuer à discuter gratuitement, ou abonnez-vous pour un accès illimité.'**
  String chatLimitBody(Object count);

  /// No description provided for @chatRecording.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrement...'**
  String get chatRecording;

  /// No description provided for @chatMicPermission.
  ///
  /// In fr, this message translates to:
  /// **'Autorisez l\'accès au microphone pour enregistrer un message vocal.'**
  String get chatMicPermission;

  /// No description provided for @chatMicPermissionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Microphone bloqué'**
  String get chatMicPermissionTitle;

  /// No description provided for @chatMicPermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'L\'accès au microphone est désactivé. Ouvrez les paramètres pour l\'autoriser, puis réessayez.'**
  String get chatMicPermissionDenied;

  /// No description provided for @chatMicSettings.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir les paramètres'**
  String get chatMicSettings;

  /// No description provided for @chatRecordError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur d\'enregistrement : {error}'**
  String chatRecordError(Object error);

  /// No description provided for @chatContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get chatContinue;

  /// No description provided for @chatCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get chatCopy;

  /// No description provided for @chatEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get chatEdit;

  /// No description provided for @chatEditing.
  ///
  /// In fr, this message translates to:
  /// **'Modification du message…'**
  String get chatEditing;

  /// No description provided for @chatShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get chatShare;

  /// No description provided for @chatAttachTitle.
  ///
  /// In fr, this message translates to:
  /// **'Joindre'**
  String get chatAttachTitle;

  /// No description provided for @chatCopied.
  ///
  /// In fr, this message translates to:
  /// **'Message copié'**
  String get chatCopied;

  /// No description provided for @chatPhotoSelected.
  ///
  /// In fr, this message translates to:
  /// **'Photo sélectionnée'**
  String get chatPhotoSelected;

  /// No description provided for @chatChooseImage.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une image'**
  String get chatChooseImage;

  /// No description provided for @chatTakePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get chatTakePhoto;

  /// No description provided for @chatAudioTranscription.
  ///
  /// In fr, this message translates to:
  /// **'Transcription audio'**
  String get chatAudioTranscription;

  /// No description provided for @chatAudioTranscriptionActive.
  ///
  /// In fr, this message translates to:
  /// **'Transcription audio — enregistrez votre message'**
  String get chatAudioTranscriptionActive;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @chatPreviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de l\'enregistrement'**
  String get chatPreviewTitle;

  /// No description provided for @chatPreviewSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Écoutez avant d\'envoyer'**
  String get chatPreviewSubtitle;

  /// No description provided for @chatNoTextDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun texte détecté'**
  String get chatNoTextDetected;

  /// No description provided for @chatTranscriptionError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de transcription: {error}'**
  String chatTranscriptionError(Object error);

  /// No description provided for @authLogin.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get authLogin;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour continuer'**
  String get authLoginSubtitle;

  /// No description provided for @authRegister.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get authRegister;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre compte Muslim IA'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get authFullName;

  /// No description provided for @authEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get authEmailHint;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre mot de passe'**
  String get authPasswordHint;

  /// No description provided for @authConfirmPassword.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get authConfirmPassword;

  /// No description provided for @authLoginButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get authRegisterButton;

  /// No description provided for @authNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? '**
  String get authNoAccount;

  /// No description provided for @authHaveAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? '**
  String get authHaveAccount;

  /// No description provided for @authSkip.
  ///
  /// In fr, this message translates to:
  /// **'Continuer sans inscription'**
  String get authSkip;

  /// No description provided for @authSignUpLink.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get authSignUpLink;

  /// No description provided for @authLoginLink.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authLoginLink;

  /// No description provided for @authNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre nom complet'**
  String get authNameRequired;

  /// No description provided for @authNameTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Le nom doit contenir au moins 2 caractères'**
  String get authNameTooShort;

  /// No description provided for @authEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get authEmailInvalid;

  /// No description provided for @authPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 6 caractères'**
  String get authPasswordTooShort;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les mots de passe ne correspondent pas'**
  String get authPasswordMismatch;

  /// No description provided for @authFieldsRequired.
  ///
  /// In fr, this message translates to:
  /// **'Tous les champs sont requis'**
  String get authFieldsRequired;

  /// No description provided for @authCorrectFields.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez corriger les champs'**
  String get authCorrectFields;

  /// No description provided for @authErrorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Erreur réseau. Vérifiez votre connexion.'**
  String get authErrorNetwork;

  /// No description provided for @offlineBanner.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet'**
  String get offlineBanner;

  /// No description provided for @offlineMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes hors ligne. Vérifiez votre connexion internet puis réessayez.'**
  String get offlineMessage;

  /// No description provided for @authVerifyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifiez votre email'**
  String get authVerifyTitle;

  /// No description provided for @authVerifySent.
  ///
  /// In fr, this message translates to:
  /// **'Nous avons envoyé un email de vérification à'**
  String get authVerifySent;

  /// No description provided for @authVerifyInstructions.
  ///
  /// In fr, this message translates to:
  /// **'Cliquez sur le lien dans l\'email, puis appuyez sur \"Continuer\"'**
  String get authVerifyInstructions;

  /// No description provided for @authVerifyContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get authVerifyContinue;

  /// No description provided for @authVerifyResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer l\'email'**
  String get authVerifyResend;

  /// No description provided for @authVerifyUseOther.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser un autre compte'**
  String get authVerifyUseOther;

  /// No description provided for @authVerifyEmailSent.
  ///
  /// In fr, this message translates to:
  /// **'Email renvoyé ! Vérifiez votre boîte de réception.'**
  String get authVerifyEmailSent;

  /// No description provided for @authEmailNotVerified.
  ///
  /// In fr, this message translates to:
  /// **'Email non vérifié. Veuillez vérifier votre boîte de réception.'**
  String get authEmailNotVerified;

  /// No description provided for @authVerifyError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de vérification'**
  String get authVerifyError;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEdit;

  /// No description provided for @profileFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get profileFullName;

  /// No description provided for @profileEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileNotProvided.
  ///
  /// In fr, this message translates to:
  /// **'Non renseigné'**
  String get profileNotProvided;

  /// No description provided for @profileNotModifiable.
  ///
  /// In fr, this message translates to:
  /// **'Non modifiable'**
  String get profileNotModifiable;

  /// No description provided for @profilePassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get profilePassword;

  /// No description provided for @profileChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get profileChangePassword;

  /// No description provided for @profilePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get profilePasswordTitle;

  /// No description provided for @profilePasswordCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get profilePasswordCurrent;

  /// No description provided for @profilePasswordNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get profilePasswordNew;

  /// No description provided for @profilePasswordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe changé avec succès'**
  String get profilePasswordChanged;

  /// No description provided for @profileTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get profileTheme;

  /// No description provided for @profileDarkMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode sombre'**
  String get profileDarkMode;

  /// No description provided for @profileLightMode.
  ///
  /// In fr, this message translates to:
  /// **'Mode clair'**
  String get profileLightMode;

  /// No description provided for @profileDeleteConversations.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les conversations ({count})'**
  String profileDeleteConversations(Object count);

  /// No description provided for @profileDeleteConversationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer les conversations ?'**
  String get profileDeleteConversationsTitle;

  /// No description provided for @profileDeleteConversationsBody.
  ///
  /// In fr, this message translates to:
  /// **'{count} conversation(s) seront définitivement supprimées.'**
  String profileDeleteConversationsBody(Object count);

  /// No description provided for @profileDeleteAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout supprimer'**
  String get profileDeleteAll;

  /// No description provided for @profileSubActive.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement actif'**
  String get profileSubActive;

  /// No description provided for @profileTrialActive.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit'**
  String get profileTrialActive;

  /// No description provided for @profileDaysLeft.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours restants'**
  String profileDaysLeft(Object days);

  /// No description provided for @profileEndsToday.
  ///
  /// In fr, this message translates to:
  /// **'Se termine aujourd\'hui'**
  String get profileEndsToday;

  /// No description provided for @profileFreeMessages.
  ///
  /// In fr, this message translates to:
  /// **'Messages gratuits'**
  String get profileFreeMessages;

  /// No description provided for @profileToday.
  ///
  /// In fr, this message translates to:
  /// **'{left} / {total} aujourd\'hui'**
  String profileToday(Object left, Object total);

  /// No description provided for @profileSubscription.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement'**
  String get profileSubscription;

  /// No description provided for @profileFreePlan.
  ///
  /// In fr, this message translates to:
  /// **'Plan gratuit'**
  String get profileFreePlan;

  /// No description provided for @profileUpgrade.
  ///
  /// In fr, this message translates to:
  /// **'Passer Premium'**
  String get profileUpgrade;

  /// No description provided for @appBarPremium.
  ///
  /// In fr, this message translates to:
  /// **'Passer au Premium'**
  String get appBarPremium;

  /// No description provided for @profileProgressPlan.
  ///
  /// In fr, this message translates to:
  /// **'Barre de progression du compte'**
  String get profileProgressPlan;

  /// No description provided for @trackerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivi Islamique'**
  String get trackerTitle;

  /// No description provided for @trackerToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get trackerToday;

  /// No description provided for @trackerObjectives.
  ///
  /// In fr, this message translates to:
  /// **'Objectifs'**
  String get trackerObjectives;

  /// No description provided for @trackerTools.
  ///
  /// In fr, this message translates to:
  /// **'Mini-outils'**
  String get trackerTools;

  /// No description provided for @trackerHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get trackerHistory;

  /// No description provided for @trackerDays.
  ///
  /// In fr, this message translates to:
  /// **'{days} jours'**
  String trackerDays(Object days);

  /// No description provided for @trackerStreakSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'de streak de prière'**
  String get trackerStreakSubtitle;

  /// No description provided for @trackerPrayersToday.
  ///
  /// In fr, this message translates to:
  /// **'Prières du jour'**
  String get trackerPrayersToday;

  /// No description provided for @trackerDone.
  ///
  /// In fr, this message translates to:
  /// **'Fait'**
  String get trackerDone;

  /// No description provided for @trackerQuranReading.
  ///
  /// In fr, this message translates to:
  /// **'Lecture du Coran'**
  String get trackerQuranReading;

  /// No description provided for @trackerPages.
  ///
  /// In fr, this message translates to:
  /// **'{pages}/{goal} pages'**
  String trackerPages(Object goal, Object pages);

  /// No description provided for @trackerHabitsToday.
  ///
  /// In fr, this message translates to:
  /// **'Habitudes du jour'**
  String get trackerHabitsToday;

  /// No description provided for @trackerAddHabits.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos habitudes quotidiennes'**
  String get trackerAddHabits;

  /// No description provided for @trackerNewHabit.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle habitude'**
  String get trackerNewHabit;

  /// No description provided for @trackerHabitHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Lire Sourate Al-Kahf'**
  String get trackerHabitHint;

  /// No description provided for @trackerAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get trackerAdd;

  /// No description provided for @trackerNewObjective.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel objectif'**
  String get trackerNewObjective;

  /// No description provided for @trackerInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get trackerInProgress;

  /// No description provided for @trackerCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminés'**
  String get trackerCompleted;

  /// No description provided for @trackerNoObjectives.
  ///
  /// In fr, this message translates to:
  /// **'Aucun objectif'**
  String get trackerNoObjectives;

  /// No description provided for @trackerNoObjectivesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Définissez vos objectifs spirituels et quotidiens'**
  String get trackerNoObjectivesSubtitle;

  /// No description provided for @trackerCatSpiritual.
  ///
  /// In fr, this message translates to:
  /// **'Spirituel'**
  String get trackerCatSpiritual;

  /// No description provided for @trackerCatSport.
  ///
  /// In fr, this message translates to:
  /// **'Sport'**
  String get trackerCatSport;

  /// No description provided for @trackerCatWork.
  ///
  /// In fr, this message translates to:
  /// **'Travail'**
  String get trackerCatWork;

  /// No description provided for @trackerCatStudy.
  ///
  /// In fr, this message translates to:
  /// **'Études'**
  String get trackerCatStudy;

  /// No description provided for @trackerCatFinance.
  ///
  /// In fr, this message translates to:
  /// **'Finances'**
  String get trackerCatFinance;

  /// No description provided for @trackerCatHealth.
  ///
  /// In fr, this message translates to:
  /// **'Santé'**
  String get trackerCatHealth;

  /// No description provided for @trackerCatOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get trackerCatOther;

  /// No description provided for @trackerReopen.
  ///
  /// In fr, this message translates to:
  /// **'Réouvrir'**
  String get trackerReopen;

  /// No description provided for @trackerMarkDone.
  ///
  /// In fr, this message translates to:
  /// **'✓ Terminé'**
  String get trackerMarkDone;

  /// No description provided for @trackerTitleField.
  ///
  /// In fr, this message translates to:
  /// **'Titre'**
  String get trackerTitleField;

  /// No description provided for @trackerTargetField.
  ///
  /// In fr, this message translates to:
  /// **'Objectif'**
  String get trackerTargetField;

  /// No description provided for @trackerUnitField.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get trackerUnitField;

  /// No description provided for @trackerCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get trackerCategory;

  /// No description provided for @trackerCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get trackerCreate;

  /// No description provided for @trackerTimes.
  ///
  /// In fr, this message translates to:
  /// **'fois'**
  String get trackerTimes;

  /// No description provided for @trackerHelp.
  ///
  /// In fr, this message translates to:
  /// **'Muslim IA vous aide à suivre vos activités quotidiennes'**
  String get trackerHelp;

  /// No description provided for @trackerGoal.
  ///
  /// In fr, this message translates to:
  /// **'Objectif: {target} {unit}'**
  String trackerGoal(Object target, Object unit);

  /// No description provided for @trackerReset.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get trackerReset;

  /// No description provided for @trackerNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Écrivez votre repas du jour...'**
  String get trackerNoteHint;

  /// No description provided for @trackerAddItemHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un élément...'**
  String get trackerAddItemHint;

  /// No description provided for @trackerNoHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun historique'**
  String get trackerNoHistory;

  /// No description provided for @trackerHistorySummary.
  ///
  /// In fr, this message translates to:
  /// **'Prières: {done}/{total} • Quran: {pages}p • Streak: {days}j'**
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  );

  /// No description provided for @trackerVersets.
  ///
  /// In fr, this message translates to:
  /// **'versets'**
  String get trackerVersets;

  /// No description provided for @surahVersets.
  ///
  /// In fr, this message translates to:
  /// **'{count} versets'**
  String surahVersets(Object count);

  /// No description provided for @surahExplain.
  ///
  /// In fr, this message translates to:
  /// **'Expliquer {name}'**
  String surahExplain(Object name);

  /// No description provided for @surahFilter.
  ///
  /// In fr, this message translates to:
  /// **'Filtrer par nom ou numéro...'**
  String get surahFilter;

  /// No description provided for @surahMeccan.
  ///
  /// In fr, this message translates to:
  /// **'Mecquoise'**
  String get surahMeccan;

  /// No description provided for @surahMedinan.
  ///
  /// In fr, this message translates to:
  /// **'Médinoise'**
  String get surahMedinan;

  /// No description provided for @memorizeTouchTranslation.
  ///
  /// In fr, this message translates to:
  /// **'Toucher pour la traduction'**
  String get memorizeTouchTranslation;

  /// No description provided for @memorizeTouchReveal.
  ///
  /// In fr, this message translates to:
  /// **'Toucher pour révéler'**
  String get memorizeTouchReveal;

  /// No description provided for @memorizeAgain.
  ///
  /// In fr, this message translates to:
  /// **'Encore'**
  String get memorizeAgain;

  /// No description provided for @memorizeEasy.
  ///
  /// In fr, this message translates to:
  /// **'Facile'**
  String get memorizeEasy;

  /// No description provided for @memorizeHard.
  ///
  /// In fr, this message translates to:
  /// **'Difficile'**
  String get memorizeHard;

  /// No description provided for @writingStrokeThin.
  ///
  /// In fr, this message translates to:
  /// **'Fin'**
  String get writingStrokeThin;

  /// No description provided for @writingStrokeMedium.
  ///
  /// In fr, this message translates to:
  /// **'Moyen'**
  String get writingStrokeMedium;

  /// No description provided for @writingStrokeThick.
  ///
  /// In fr, this message translates to:
  /// **'Épais'**
  String get writingStrokeThick;

  /// No description provided for @writingClear.
  ///
  /// In fr, this message translates to:
  /// **'Effacer'**
  String get writingClear;

  /// No description provided for @writingClearAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get writingClearAll;

  /// No description provided for @writingNextLetter.
  ///
  /// In fr, this message translates to:
  /// **'Lettre suivante'**
  String get writingNextLetter;

  /// No description provided for @paywallTitle.
  ///
  /// In fr, this message translates to:
  /// **'Muslim IA Premium'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement Premium'**
  String get paywallSubtitle;

  /// No description provided for @paywallCard.
  ///
  /// In fr, this message translates to:
  /// **'Paiement par carte bancaire • Sans engagement'**
  String get paywallCard;

  /// No description provided for @paywallPay.
  ///
  /// In fr, this message translates to:
  /// **'Payer par carte'**
  String get paywallPay;

  /// No description provided for @paywallProcessing.
  ///
  /// In fr, this message translates to:
  /// **'Patientez...'**
  String get paywallProcessing;

  /// No description provided for @paywallVerifying.
  ///
  /// In fr, this message translates to:
  /// **'Vérification...'**
  String get paywallVerifying;

  /// No description provided for @paywallAlreadyPaid.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai déjà payé'**
  String get paywallAlreadyPaid;

  /// No description provided for @paywallPopular.
  ///
  /// In fr, this message translates to:
  /// **'POPULAIRE'**
  String get paywallPopular;

  /// No description provided for @paywallFreeChat.
  ///
  /// In fr, this message translates to:
  /// **'Chat IA illimité'**
  String get paywallFreeChat;

  /// No description provided for @paywallVision.
  ///
  /// In fr, this message translates to:
  /// **'Vision IA'**
  String get paywallVision;

  /// No description provided for @paywallAlarm.
  ///
  /// In fr, this message translates to:
  /// **'Alarme + blocage téléphone'**
  String get paywallAlarm;

  /// No description provided for @paywallPrayerAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Alertes de prière'**
  String get paywallPrayerAlerts;

  /// No description provided for @paywallQuranExplorer.
  ///
  /// In fr, this message translates to:
  /// **'Explorateur Coran'**
  String get paywallQuranExplorer;

  /// No description provided for @paywallMemorization.
  ///
  /// In fr, this message translates to:
  /// **'Mémorisation & Suivi'**
  String get paywallMemorization;

  /// No description provided for @paywallSearchMCP.
  ///
  /// In fr, this message translates to:
  /// **'Recherche avancée MCP'**
  String get paywallSearchMCP;

  /// No description provided for @paywallTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème personnalisé'**
  String get paywallTheme;

  /// No description provided for @paywallTrialDays.
  ///
  /// In fr, this message translates to:
  /// **'Essai gratuit — {days} restantes'**
  String paywallTrialDays(Object days);

  /// No description provided for @paywallTrialEnded.
  ///
  /// In fr, this message translates to:
  /// **'Votre essai est terminé'**
  String get paywallTrialEnded;

  /// No description provided for @paywallPaymentError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de paiement. Veuillez réessayer.'**
  String get paywallPaymentError;

  /// No description provided for @paywallPaymentNotDetected.
  ///
  /// In fr, this message translates to:
  /// **'Paiement non détecté.'**
  String get paywallPaymentNotDetected;

  /// No description provided for @paywallSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Paiement réussi ! Votre abonnement Premium est actif.'**
  String get paywallSuccess;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement activé !'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre abonnement Premium est actif. Profitez de toutes les fonctionnalités dès maintenant.'**
  String get paymentSuccessSubtitle;

  /// No description provided for @paymentStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get paymentStart;

  /// No description provided for @paymentFailureTitle.
  ///
  /// In fr, this message translates to:
  /// **'Paiement échoué'**
  String get paymentFailureTitle;

  /// No description provided for @paymentFailureSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre paiement n\'a pas abouti. Vérifiez votre carte et réessayez, ou revenez plus tard.'**
  String get paymentFailureSubtitle;

  /// No description provided for @paywallAssistant.
  ///
  /// In fr, this message translates to:
  /// **'Assistant islamique intelligent'**
  String get paywallAssistant;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @prayerUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer maintenant'**
  String get prayerUnlock;

  /// No description provided for @prayerTime.
  ///
  /// In fr, this message translates to:
  /// **'heure de la prière'**
  String get prayerTime;

  /// No description provided for @prayerAutoUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone sera débloqué\nautomatiquement après la prière'**
  String get prayerAutoUnlock;

  /// No description provided for @prayerRemaining.
  ///
  /// In fr, this message translates to:
  /// **'restantes'**
  String get prayerRemaining;

  /// No description provided for @prayerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prière'**
  String get prayerTitle;

  /// No description provided for @prayerAlarmStopped.
  ///
  /// In fr, this message translates to:
  /// **'Alarme arrêtée'**
  String get prayerAlarmStopped;

  /// No description provided for @prayerLockModeOn.
  ///
  /// In fr, this message translates to:
  /// **'Mode verrouillage activé'**
  String get prayerLockModeOn;

  /// No description provided for @prayerLockModeOff.
  ///
  /// In fr, this message translates to:
  /// **'Mode verrouillage désactivé'**
  String get prayerLockModeOff;

  /// No description provided for @prayerStopAlarm.
  ///
  /// In fr, this message translates to:
  /// **'Couper l\'alarme'**
  String get prayerStopAlarm;

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre adresse email. Nous vous enverrons un lien pour réinitialiser votre mot de passe.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @forgotPasswordEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email'**
  String get forgotPasswordEmailLabel;

  /// No description provided for @forgotPasswordEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'votre@email.com'**
  String get forgotPasswordEmailHint;

  /// No description provided for @forgotPasswordInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse email invalide'**
  String get forgotPasswordInvalidEmail;

  /// No description provided for @forgotPasswordSend.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get forgotPasswordSend;

  /// No description provided for @forgotPasswordSent.
  ///
  /// In fr, this message translates to:
  /// **'Email de réinitialisation envoyé ! Vérifiez votre boîte de réception.'**
  String get forgotPasswordSent;

  /// No description provided for @authResetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser le mot de passe'**
  String get authResetTitle;

  /// No description provided for @authResetSent.
  ///
  /// In fr, this message translates to:
  /// **'Email de réinitialisation envoyé ! Vérifiez votre boîte de réception.'**
  String get authResetSent;

  /// No description provided for @authMfaTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérification en deux étapes'**
  String get authMfaTitle;

  /// No description provided for @authMfaBody.
  ///
  /// In fr, this message translates to:
  /// **'Entrez le code à 6 chiffres généré par votre application d\'authentification.'**
  String get authMfaBody;

  /// No description provided for @profileEmailChange.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'email'**
  String get profileEmailChange;

  /// No description provided for @profileEmailNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouvel email'**
  String get profileEmailNew;

  /// No description provided for @profileEmailChanged.
  ///
  /// In fr, this message translates to:
  /// **'Email modifié ! Vérifiez votre nouveau email pour confirmer.'**
  String get profileEmailChanged;

  /// No description provided for @profileSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get profileSecurity;

  /// No description provided for @profileMfa.
  ///
  /// In fr, this message translates to:
  /// **'Authentification à deux facteurs'**
  String get profileMfa;

  /// No description provided for @profileMfaEnabled.
  ///
  /// In fr, this message translates to:
  /// **'Activé'**
  String get profileMfaEnabled;

  /// No description provided for @profileMfaDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Désactivé'**
  String get profileMfaDisabled;

  /// No description provided for @profileMfaSetupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Activer l\'authentification à deux facteurs'**
  String get profileMfaSetupTitle;

  /// No description provided for @profileMfaStepQr.
  ///
  /// In fr, this message translates to:
  /// **'Scannez le QR code avec votre application d\'authentification (Google Authenticator, Authy...) puis entrez le code généré.'**
  String get profileMfaStepQr;

  /// No description provided for @profileMfaSecretKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé secrète'**
  String get profileMfaSecretKey;

  /// No description provided for @profileMfaCode.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get profileMfaCode;

  /// No description provided for @profileMfaCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'123456'**
  String get profileMfaCodeHint;

  /// No description provided for @profileMfaActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get profileMfaActivate;

  /// No description provided for @profileMfaEnabledMsg.
  ///
  /// In fr, this message translates to:
  /// **'Authentification à deux facteurs activée. Un email de confirmation a été envoyé.'**
  String get profileMfaEnabledMsg;

  /// No description provided for @profileMfaDisabledMsg.
  ///
  /// In fr, this message translates to:
  /// **'Authentification à deux facteurs désactivée.'**
  String get profileMfaDisabledMsg;

  /// No description provided for @profileMfaInvalidCode.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ou expiré. Réessayez.'**
  String get profileMfaInvalidCode;

  /// No description provided for @profileMfaDisableTitle.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver l\'authentification à deux facteurs'**
  String get profileMfaDisableTitle;

  /// No description provided for @profileMfaDisableBody.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre mot de passe pour confirmer la désactivation.'**
  String get profileMfaDisableBody;

  /// No description provided for @profileMfaDisable.
  ///
  /// In fr, this message translates to:
  /// **'Désactiver'**
  String get profileMfaDisable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'en',
    'es',
    'fr',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
