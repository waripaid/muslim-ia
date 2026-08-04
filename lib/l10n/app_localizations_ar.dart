// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مسلم آي';

  @override
  String get appTagline => 'مساعدك الإسلامي الذكي';

  @override
  String get ok => 'حسناً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get confirm => 'تأكيد';

  @override
  String get later => 'لاحقاً';

  @override
  String get send => 'إرسال';

  @override
  String get resend => 'إعادة إرسال';

  @override
  String get edit => 'تعديل';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get today => 'اليوم';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmBody => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get language => 'اللغة';

  @override
  String get languageDescription => 'اختر لغة التطبيق';

  @override
  String get detectedCountry => 'البلد المكتشف';

  @override
  String get automaticLanguage => 'اللغة التلقائية';

  @override
  String get autoLanguageDescription => 'الكشف التلقائي حسب بلدك';

  @override
  String get chatNew => 'محادثة جديدة';

  @override
  String get chatTracker => 'المتابعة الإسلامية';

  @override
  String get chatTrackerSubtitle => 'الصلاة، القرآن، الأهداف';

  @override
  String get chatCurrent => 'جارية';

  @override
  String get chatHistory => 'السجل';

  @override
  String get chatMessages => 'رسائل';

  @override
  String get chatNoConversations => 'لا توجد محادثات';

  @override
  String get chatDeleteTitle => 'حذف هذه المحادثة؟';

  @override
  String chatDeleteBody(Object title) {
    return '\"$title\" سيتم حذفها نهائياً.';
  }

  @override
  String get chatEmptyHint => 'ماذا يقول القرآن عن الصبر؟';

  @override
  String get chatWelcomeTitle => 'السلام عليكم! كيف يمكنني مساعدتك اليوم؟';

  @override
  String get chatSuggestionQuran => 'ماذا يقول القرآن عن الصبر؟';

  @override
  String get chatSuggestionSurah => 'اشرح لي سورة الفاتحة';

  @override
  String get chatSuggestionWord => 'حلل الكلمة العربية \"الرحمن\"';

  @override
  String get chatSuggestionAdvice => 'أعطني نصيحة إسلامية لهذا اليوم';

  @override
  String get chatSuggestionVocab => 'علّمني 5 كلمات من مفردات القرآن';

  @override
  String get chatSuggestionProphet => 'حدّثني عن النبي محمد ﷺ';

  @override
  String get chatInputHint => 'رسالة إلى مسلم آي...';

  @override
  String get chatLimitTitle => 'تم بلوغ الحد الأقصى';

  @override
  String chatLimitBody(Object count) {
    return 'لقد وصلت إلى الحد الأقصى وهو $count رسائل مجانية.\n\nاشترك لمتابعة الدردشة بدون حدود.';
  }

  @override
  String get subscribe => 'اشترك';

  @override
  String get premiumFeatureTitle => 'ميزة بريميوم';

  @override
  String get premiumFeatureBody =>
      'هذه الميزة متاحة للمشتركين في بريميوم. اشترك لفتحها والاستمتاع برسائل غير محدودة.';

  @override
  String get chatRecording => 'جاري التسجيل...';

  @override
  String get chatMicPermission =>
      'اسمح بالوصول إلى الميكروفون لتسجيل رسالة صوتية.';

  @override
  String get chatMicPermissionTitle => 'الميكروفون محظور';

  @override
  String get chatMicPermissionDenied =>
      'تم تعطيل الوصول إلى الميكروفون. افتح الإعدادات للسماح به ثم حاول مرة أخرى.';

  @override
  String get chatMicSettings => 'فتح الإعدادات';

  @override
  String chatRecordError(Object error) {
    return 'خطأ في التسجيل: $error';
  }

  @override
  String get chatContinue => 'متابعة';

  @override
  String get chatCopy => 'نسخ';

  @override
  String get chatEdit => 'تعديل';

  @override
  String get chatEditing => 'جارٍ تعديل الرسالة…';

  @override
  String get chatShare => 'مشاركة';

  @override
  String get chatAttachTitle => 'إرفاق';

  @override
  String get chatCopied => 'تم نسخ الرسالة';

  @override
  String get chatPhotoSelected => 'صورة محددة';

  @override
  String get chatChooseImage => 'اختيار صورة';

  @override
  String get chatTakePhoto => 'التقاط صورة';

  @override
  String get chatAudioTranscription => 'النسخ الصوتي';

  @override
  String get chatAudioTranscriptionActive => 'النسخ الصوتي — سجل رسالتك';

  @override
  String get close => 'إغلاق';

  @override
  String get chatPreviewTitle => 'معاينة التسجيل';

  @override
  String get chatPreviewSubtitle => 'استمع قبل الإرسال';

  @override
  String get chatNoTextDetected => 'لم يتم اكتشاف نص';

  @override
  String chatTranscriptionError(Object error) {
    return 'خطأ في النسخ: $error';
  }

  @override
  String get chatVoiceTranscriptionLabel => 'نسخ صوتي';

  @override
  String get authLogin => 'تسجيل الدخول';

  @override
  String get authLoginSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get authRegister => 'إنشاء حساب';

  @override
  String get authRegisterSubtitle => 'أنشئ حسابك في مسلم آي';

  @override
  String get authFullName => 'الاسم الكامل';

  @override
  String get authEmail => 'البريد الإلكتروني';

  @override
  String get authEmailHint => 'your@email.com';

  @override
  String get authPassword => 'كلمة المرور';

  @override
  String get authPasswordHint => 'كلمة مرورك';

  @override
  String get authConfirmPassword => 'تأكيد';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authRegisterButton => 'إنشاء حساب';

  @override
  String get authNoAccount => 'ليس لديك حساب؟ ';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟ ';

  @override
  String get authSkip => 'المتابعة بدون تسجيل';

  @override
  String get authSignUpLink => 'سجّل';

  @override
  String get authLoginLink => 'تسجيل الدخول';

  @override
  String get authNameRequired => 'أدخل اسمك الكامل';

  @override
  String get authNameTooShort => 'يجب أن يكون الاسم حرفين على الأقل';

  @override
  String get authEmailInvalid => 'بريد إلكتروني غير صالح';

  @override
  String get authPasswordTooShort => '6 أحرف على الأقل';

  @override
  String get authPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authFieldsRequired => 'جميع الحقول مطلوبة';

  @override
  String get authCorrectFields => 'يرجى تصحيح الحقول';

  @override
  String get authErrorNetwork => 'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get offlineBanner => 'لا يوجد اتصال بالإنترنت';

  @override
  String get offlineMessage =>
      'يبدو أنك غير متصل بالإنترنت. تحقق من اتصالك ثم أعد المحاولة.';

  @override
  String get authVerifyTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get authVerifySent => 'أرسلنا بريد التحقق إلى';

  @override
  String get authVerifyInstructions =>
      'اضغط على الرابط في البريد، ثم اضغط \"متابعة\"';

  @override
  String get authVerifyContinue => 'متابعة';

  @override
  String get authVerifyResend => 'إعادة إرسال البريد';

  @override
  String get authVerifyUseOther => 'استخدام حساب آخر';

  @override
  String get authVerifyEmailSent => 'تمت إعادة الإرسال! تحقق من صندوق الوارد.';

  @override
  String get authEmailNotVerified =>
      'البريد غير موثق. يرجى التحقق من صندوق الوارد.';

  @override
  String get authVerifyError => 'خطأ في التحقق';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String get profileEdit => 'تعديل الملف';

  @override
  String get profileFullName => 'الاسم الكامل';

  @override
  String get profileEmail => 'البريد الإلكتروني';

  @override
  String get profileNotProvided => 'غير محدد';

  @override
  String get profileNotModifiable => 'غير قابل للتعديل';

  @override
  String get profilePassword => 'كلمة المرور';

  @override
  String get profileChangePassword => 'تغيير كلمة المرور';

  @override
  String get profilePasswordTitle => 'تغيير كلمة المرور';

  @override
  String get profilePasswordCurrent => 'كلمة المرور الحالية';

  @override
  String get profilePasswordNew => 'كلمة المرور الجديدة';

  @override
  String get profilePasswordChanged => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get profileTheme => 'المظهر';

  @override
  String get profileDarkMode => 'الوضع الداكن';

  @override
  String get profileLightMode => 'الوضع الفاتح';

  @override
  String profileDeleteConversations(Object count) {
    return 'حذف المحادثات ($count)';
  }

  @override
  String get profileDeleteConversationsTitle => 'حذف المحادثات؟';

  @override
  String profileDeleteConversationsBody(Object count) {
    return '$count محادثة سيتم حذفها نهائياً.';
  }

  @override
  String get profileDeleteAll => 'حذف الكل';

  @override
  String get profileSubActive => 'اشتراك نشط';

  @override
  String get profileTrialActive => 'تجربة مجانية';

  @override
  String profileDaysLeft(Object days) {
    return '$days أيام متبقية';
  }

  @override
  String get profileEndsToday => 'ينتهي اليوم';

  @override
  String get profileFreeMessages => 'رسائل مجانية';

  @override
  String profileToday(Object left, Object total) {
    return 'الرسائل المتبقية $left / $total';
  }

  @override
  String get profileSubscription => 'الاشتراك';

  @override
  String get profileFreePlan => 'الخطة المجانية';

  @override
  String get profileUpgrade => 'الترقية إلى بريميوم';

  @override
  String get appBarPremium => 'الترقية إلى Premium';

  @override
  String get profileProgressPlan => 'شريط تقدم الحساب';

  @override
  String get trackerTitle => 'المتابعة الإسلامية';

  @override
  String get trackerToday => 'اليوم';

  @override
  String get trackerObjectives => 'الأهداف';

  @override
  String get trackerTools => 'أدوات';

  @override
  String get trackerHistory => 'السجل';

  @override
  String trackerDays(Object days) {
    return '$days أيام';
  }

  @override
  String get trackerStreakSubtitle => 'من سلسلة الصلاة';

  @override
  String get trackerPrayersToday => 'صلوات اليوم';

  @override
  String get trackerDone => 'تم';

  @override
  String get trackerQuranReading => 'قراءة القرآن';

  @override
  String trackerPages(Object goal, Object pages) {
    return '$pages/$goal صفحة';
  }

  @override
  String get trackerHabitsToday => 'عادات اليوم';

  @override
  String get trackerAddHabits => 'أضف عاداتك اليومية';

  @override
  String get trackerNewHabit => 'عادة جديدة';

  @override
  String get trackerHabitHint => 'مثال: قراءة سورة الكهف';

  @override
  String get trackerAdd => 'إضافة';

  @override
  String get trackerNewObjective => 'هدف جديد';

  @override
  String get trackerInProgress => 'قيد التنفيذ';

  @override
  String get trackerCompleted => 'مكتمل';

  @override
  String get trackerNoObjectives => 'لا يوجد أهداف';

  @override
  String get trackerNoObjectivesSubtitle => 'حدد أهدافك الروحية واليومية';

  @override
  String get trackerCatSpiritual => 'روحي';

  @override
  String get trackerCatSport => 'رياضة';

  @override
  String get trackerCatWork => 'عمل';

  @override
  String get trackerCatStudy => 'دراسة';

  @override
  String get trackerCatFinance => 'مالية';

  @override
  String get trackerCatHealth => 'صحة';

  @override
  String get trackerCatOther => 'أخرى';

  @override
  String get trackerReopen => 'إعادة فتح';

  @override
  String get trackerMarkDone => 'مكتمل ✓';

  @override
  String get trackerTitleField => 'العنوان';

  @override
  String get trackerTargetField => 'الهدف';

  @override
  String get trackerUnitField => 'الوحدة';

  @override
  String get trackerCategory => 'الفئة';

  @override
  String get trackerCreate => 'إنشاء';

  @override
  String get trackerTimes => 'مرة';

  @override
  String get trackerHelp => 'يساعدك مسلم آي في متابعة أنشطتك اليومية';

  @override
  String trackerGoal(Object target, Object unit) {
    return 'الهدف: $target $unit';
  }

  @override
  String get trackerReset => 'إعادة ضبط';

  @override
  String get trackerNoteHint => 'اكتب وجبتك اليوم...';

  @override
  String get trackerAddItemHint => 'أضف عنصراً...';

  @override
  String get trackerNoHistory => 'لا يوجد سجل';

  @override
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  ) {
    return 'الصلوات: $done/$total • القرآن: $pagesص • السلسلة: $daysي';
  }

  @override
  String get trackerVersets => 'آيات';

  @override
  String surahVersets(Object count) {
    return '$count آيات';
  }

  @override
  String surahExplain(Object name) {
    return 'اشرح $name';
  }

  @override
  String get surahFilter => 'تصفية بالاسم أو الرقم...';

  @override
  String get surahMeccan => 'مكية';

  @override
  String get surahMedinan => 'مدنية';

  @override
  String get memorizeTouchTranslation => 'اضغط للترجمة';

  @override
  String get memorizeTouchReveal => 'اضغط للكشف';

  @override
  String get memorizeAgain => 'مرة أخرى';

  @override
  String get memorizeEasy => 'سهل';

  @override
  String get memorizeHard => 'صعب';

  @override
  String get writingStrokeThin => 'رفيع';

  @override
  String get writingStrokeMedium => 'متوسط';

  @override
  String get writingStrokeThick => 'سميك';

  @override
  String get writingClear => 'مسح';

  @override
  String get writingClearAll => 'الكل';

  @override
  String get writingNextLetter => 'الحرف التالي';

  @override
  String get paywallTitle => 'مسلم آي بريميوم';

  @override
  String get paywallSubtitle => 'اشتراك بريميوم';

  @override
  String get paywallCard => 'الدفع بالبطاقة البنكية • بدون التزام';

  @override
  String get paywallPay => 'ادفع بالبطاقة';

  @override
  String get paywallProcessing => 'يرجى الانتظار...';

  @override
  String get paywallVerifying => 'جاري التحقق...';

  @override
  String get paywallAlreadyPaid => 'لقد دفعت بالفعل';

  @override
  String get paywallPopular => 'الأكثر شيوعاً';

  @override
  String get paywallFreeChat => 'دردشة ذكاء اصطناعي غير محدودة';

  @override
  String get paywallVision => 'رؤية ذكية';

  @override
  String get paywallAlarm => 'منبه + قفل الهاتف';

  @override
  String get paywallPrayerAlerts => 'تنبيهات الصلاة';

  @override
  String get paywallQuranExplorer => 'مستكشف القرآن';

  @override
  String get paywallMemorization => 'الحفظ والمتابعة';

  @override
  String get paywallSearchMCP => 'بحث متقدم MCP';

  @override
  String get paywallTheme => 'مظهر مخصص';

  @override
  String paywallTrialDays(Object days) {
    return 'تجربة مجانية — $days متبقية';
  }

  @override
  String get paywallTrialEnded => 'انتهت تجربتك';

  @override
  String get paywallPaymentError => 'خطأ في الدفع. يرجى المحاولة مرة أخرى.';

  @override
  String get paywallPaymentNotDetected => 'لم يتم اكتشاف الدفع.';

  @override
  String get paywallSuccess => 'تم الدفع بنجاح! اشتراكك المميز نشط الآن.';

  @override
  String get paymentSuccessTitle => 'تم تفعيل الاشتراك!';

  @override
  String get paymentSuccessSubtitle =>
      'اشتراكك المميز مفعّل الآن. استمتع بجميع الميزات.';

  @override
  String get paymentStart => 'ابدأ';

  @override
  String get paymentFailureTitle => 'فشل الدفع';

  @override
  String get paymentFailureSubtitle =>
      'لم يكتمل الدفع. تحقق من بطاقتك وحاول مرة أخرى أو عد لاحقًا.';

  @override
  String get paywallAssistant => 'مساعد إسلامي ذكي';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get prayerUnlock => 'فتح الآن';

  @override
  String get prayerTime => 'وقت الصلاة';

  @override
  String get prayerAutoUnlock => 'سيتم فتح الهاتف\ntلقائياً بعد الصلاة';

  @override
  String get prayerRemaining => 'متبقي';

  @override
  String get prayerTitle => 'الصلاة';

  @override
  String get prayerAlarmStopped => 'تم إيقاف المنبه';

  @override
  String get prayerLockModeOn => 'تم تفعيل وضع القفل';

  @override
  String get prayerLockModeOff => 'تم إيقاف وضع القفل';

  @override
  String get prayerStopAlarm => 'إيقاف المنبه';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني. سنرسل لك رابطًا لإعادة تعيين كلمة المرور.';

  @override
  String get forgotPasswordEmailLabel => 'البريد الإلكتروني';

  @override
  String get forgotPasswordEmailHint => 'your@email.com';

  @override
  String get forgotPasswordInvalidEmail => 'بريد إلكتروني غير صالح';

  @override
  String get forgotPasswordSend => 'إرسال الرابط';

  @override
  String get forgotPasswordSent =>
      'تم إرسال بريد إعادة تعيين كلمة المرور! تحقق من بريدك الوارد.';

  @override
  String get authResetTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get authResetSent =>
      'تم إرسال رابط إعادة التعيين! تحقق من بريدك الإلكتروني.';

  @override
  String get authMfaTitle => 'التحقق بخطوتين';

  @override
  String get authMfaBody => 'أدخل الرمز المكون من 6 أرقام من تطبيق المصادقة.';

  @override
  String get profileEmailChange => 'تغيير البريد الإلكتروني';

  @override
  String get profileEmailNew => 'البريد الإلكتروني الجديد';

  @override
  String get profileEmailChanged =>
      'تم تغيير البريد! تحقق من بريدك الجديد للتأكيد.';

  @override
  String get profileSecurity => 'الأمان';

  @override
  String get profileMfa => 'المصادقة الثنائية';

  @override
  String get profileMfaEnabled => 'مفعّلة';

  @override
  String get profileMfaDisabled => 'معطّلة';

  @override
  String get profileMfaSetupTitle => 'تفعيل المصادقة الثنائية';

  @override
  String get profileMfaStepQr =>
      'امسح رمز QR بتطبيق المصادقة (Google Authenticator, Authy...) ثم أدخل الرمز المولّد.';

  @override
  String get profileMfaSecretKey => 'المفتاح السري';

  @override
  String get profileMfaCode => 'رمز من 6 أرقام';

  @override
  String get profileMfaCodeHint => '123456';

  @override
  String get profileMfaActivate => 'تفعيل';

  @override
  String get profileMfaEnabledMsg =>
      'تم تفعيل المصادقة الثنائية. تم إرسال بريد تأكيد.';

  @override
  String get profileMfaDisabledMsg => 'تم تعطيل المصادقة الثنائية.';

  @override
  String get profileMfaInvalidCode => 'رمز غير صالح أو منتهي. حاول مجدداً.';

  @override
  String get profileMfaDisableTitle => 'تعطيل المصادقة الثنائية';

  @override
  String get profileMfaDisableBody => 'أدخل كلمة المرور للتأكيد.';

  @override
  String get profileMfaDisable => 'تعطيل';
}
