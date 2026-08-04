// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Muslim IA';

  @override
  String get appTagline => 'Ваш интеллектуальный исламский помощник';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get later => 'Позже';

  @override
  String get send => 'Отправить';

  @override
  String get resend => 'Отправить повторно';

  @override
  String get edit => 'Редактировать';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get today => 'Сегодня';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirmTitle => 'Выйти из аккаунта';

  @override
  String get logoutConfirmBody => 'Вы уверены, что хотите выйти из аккаунта?';

  @override
  String get login => 'Войти';

  @override
  String get language => 'Язык';

  @override
  String get languageDescription => 'Выберите язык приложения';

  @override
  String get detectedCountry => 'Определённая страна';

  @override
  String get automaticLanguage => 'Автоматический язык';

  @override
  String get autoLanguageDescription =>
      'Автоматическое определение по вашей стране';

  @override
  String get chatNew => 'Новый чат';

  @override
  String get chatTracker => 'Исламский трекер';

  @override
  String get chatTrackerSubtitle => 'Молитвы, Коран, цели';

  @override
  String get chatCurrent => 'Текущий';

  @override
  String get chatHistory => 'История';

  @override
  String get chatMessages => 'сообщений';

  @override
  String get chatNoConversations => 'Нет активных чатов';

  @override
  String get chatDeleteTitle => 'Удалить этот чат?';

  @override
  String chatDeleteBody(Object title) {
    return '\"$title\" будет удалён безвозвратно.';
  }

  @override
  String get chatEmptyHint => 'Что Коран говорит о терпении?';

  @override
  String get chatWelcomeTitle =>
      'Ассаляму алейкум! Чем я могу помочь вам сегодня?';

  @override
  String get chatSuggestionQuran => 'Что Коран говорит о терпении?';

  @override
  String get chatSuggestionSurah => 'Объясни мне суру Аль-Фатиха';

  @override
  String get chatSuggestionWord => 'Проанализируй арабское слово \"Рахман\"';

  @override
  String get chatSuggestionAdvice => 'Дай мне сегодняшний исламский совет';

  @override
  String get chatSuggestionVocab => 'Научи меня 5 коранических слов';

  @override
  String get chatSuggestionProphet => 'Расскажи мне о пророке Мухаммаде ﷺ';

  @override
  String get chatInputHint => 'Сообщение Muslim IA...';

  @override
  String get chatLimitTitle => 'Лимит исчерпан';

  @override
  String chatLimitBody(Object count) {
    return 'Вы достигли лимита из $count бесплатных сообщений.\n\nПодпишитесь, чтобы продолжать общение без ограничений.';
  }

  @override
  String get subscribe => 'Подписаться';

  @override
  String get premiumFeatureTitle => 'Премиум-функция';

  @override
  String get premiumFeatureBody =>
      'Эта функция доступна подписчикам Premium. Подпишитесь, чтобы открыть её и пользоваться безлимитными сообщениями.';

  @override
  String get chatRecording => 'Запись...';

  @override
  String get chatMicPermission =>
      'Разрешите доступ к микрофону для записи голосового сообщения.';

  @override
  String get chatMicPermissionTitle => 'Микрофон заблокирован';

  @override
  String get chatMicPermissionDenied =>
      'Доступ к микрофону отключён. Откройте настройки, чтобы разрешить его, затем повторите попытку.';

  @override
  String get chatMicSettings => 'Открыть настройки';

  @override
  String chatRecordError(Object error) {
    return 'Ошибка записи: $error';
  }

  @override
  String get chatContinue => 'Продолжить';

  @override
  String get chatCopy => 'Копировать';

  @override
  String get chatEdit => 'Редактировать';

  @override
  String get chatEditing => 'Редактирование сообщения…';

  @override
  String get chatShare => 'Поделиться';

  @override
  String get chatAttachTitle => 'Прикрепить';

  @override
  String get chatCopied => 'Сообщение скопировано';

  @override
  String get chatPhotoSelected => 'Фото выбрано';

  @override
  String get chatChooseImage => 'Выбрать изображение';

  @override
  String get chatTakePhoto => 'Сделать фото';

  @override
  String get chatAudioTranscription => 'Аудиотранскрипция';

  @override
  String get chatAudioTranscriptionActive =>
      'Аудиотранскрипция — запишите сообщение';

  @override
  String get close => 'Закрыть';

  @override
  String get chatPreviewTitle => 'Предварительный просмотр записи';

  @override
  String get chatPreviewSubtitle => 'Прослушайте перед отправкой';

  @override
  String get chatNoTextDetected => 'Текст не обнаружен';

  @override
  String chatTranscriptionError(Object error) {
    return 'Ошибка транскрипции: $error';
  }

  @override
  String get chatVoiceTranscriptionLabel => 'Аудиотранскрипция';

  @override
  String get chatPreparingVoice => 'Подготовка голоса…';

  @override
  String get authLogin => 'Вход';

  @override
  String get authLoginSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get authRegister => 'Регистрация';

  @override
  String get authRegisterSubtitle => 'Создайте аккаунт Muslim IA';

  @override
  String get authFullName => 'Полное имя';

  @override
  String get authEmail => 'Электронная почта';

  @override
  String get authEmailHint => 'ваш@email.com';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authPasswordHint => 'Ваш пароль';

  @override
  String get authConfirmPassword => 'Подтвердить';

  @override
  String get authLoginButton => 'Войти';

  @override
  String get authRegisterButton => 'Зарегистрироваться';

  @override
  String get authNoAccount => 'Нет аккаунта? ';

  @override
  String get authHaveAccount => 'Уже есть аккаунт? ';

  @override
  String get authSkip => 'Продолжить без регистрации';

  @override
  String get authSignUpLink => 'Зарегистрироваться';

  @override
  String get authLoginLink => 'Войти';

  @override
  String get authNameRequired => 'Введите ваше полное имя';

  @override
  String get authNameTooShort => 'Имя должно содержать не менее 2 символов';

  @override
  String get authEmailInvalid => 'Некорректный адрес электронной почты';

  @override
  String get authPasswordTooShort => 'Минимум 6 символов';

  @override
  String get authPasswordMismatch => 'Пароли не совпадают';

  @override
  String get authFieldsRequired => 'Все поля обязательны для заполнения';

  @override
  String get authCorrectFields => 'Пожалуйста, исправьте ошибки в полях';

  @override
  String get authErrorNetwork =>
      'Ошибка сети. Проверьте подключение к интернету.';

  @override
  String get offlineBanner => 'Нет подключения к интернету';

  @override
  String get offlineMessage =>
      'Похоже, вы офлайн. Проверьте подключение к интернету и попробуйте снова.';

  @override
  String get authVerifyTitle => 'Подтвердите вашу электронную почту';

  @override
  String get authVerifySent => 'Мы отправили письмо с подтверждением на';

  @override
  String get authVerifyInstructions =>
      'Перейдите по ссылке в письме и нажмите \"Продолжить\"';

  @override
  String get authVerifyContinue => 'Продолжить';

  @override
  String get authVerifyResend => 'Отправить повторно';

  @override
  String get authVerifyUseOther => 'Использовать другой аккаунт';

  @override
  String get authVerifyEmailSent =>
      'Письмо отправлено повторно! Проверьте вашу почту.';

  @override
  String get authEmailNotVerified =>
      'Электронная почта не подтверждена. Пожалуйста, проверьте вашу почту.';

  @override
  String get authVerifyError => 'Ошибка подтверждения';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get profileFullName => 'Полное имя';

  @override
  String get profileEmail => 'Электронная почта';

  @override
  String get profileNotProvided => 'Не указано';

  @override
  String get profileNotModifiable => 'Не подлежит изменению';

  @override
  String get profilePassword => 'Пароль';

  @override
  String get profileChangePassword => 'Сменить пароль';

  @override
  String get profilePasswordTitle => 'Сменить пароль';

  @override
  String get profilePasswordCurrent => 'Текущий пароль';

  @override
  String get profilePasswordNew => 'Новый пароль';

  @override
  String get profilePasswordChanged => 'Пароль успешно изменён';

  @override
  String get profileTheme => 'Тема';

  @override
  String get profileDarkMode => 'Тёмная тема';

  @override
  String get profileLightMode => 'Светлая тема';

  @override
  String profileDeleteConversations(Object count) {
    return 'Удалить чаты ($count)';
  }

  @override
  String get profileDeleteConversationsTitle => 'Удалить чаты?';

  @override
  String profileDeleteConversationsBody(Object count) {
    return '$count чат(ов) будет(ут) удалён(ы) безвозвратно.';
  }

  @override
  String get profileDeleteAll => 'Удалить всё';

  @override
  String get profileSubActive => 'Активная подписка';

  @override
  String get profileTrialActive => 'Активна пробная версия';

  @override
  String profileDaysLeft(Object days) {
    return '$days дней осталось';
  }

  @override
  String get profileEndsToday => 'Заканчивается сегодня';

  @override
  String get profileFreeMessages => 'Бесплатные сообщения';

  @override
  String profileToday(Object left, Object total) {
    return '$left / $total сообщений осталось';
  }

  @override
  String get profileSubscription => 'Подписка';

  @override
  String get profileFreePlan => 'Бесплатный тариф';

  @override
  String get profileUpgrade => 'Перейти на Premium';

  @override
  String get appBarPremium => 'Перейти на Premium';

  @override
  String get profileProgressPlan => 'Прогресс по тарифу';

  @override
  String get trackerTitle => 'Исламский трекер';

  @override
  String get trackerToday => 'Сегодня';

  @override
  String get trackerObjectives => 'Цели';

  @override
  String get trackerTools => 'Мини-инструменты';

  @override
  String get trackerHistory => 'История';

  @override
  String trackerDays(Object days) {
    return '$days дней';
  }

  @override
  String get trackerStreakSubtitle => 'подряд молитв';

  @override
  String get trackerPrayersToday => 'Молитвы сегодня';

  @override
  String get trackerDone => 'Выполнено';

  @override
  String get trackerQuranReading => 'Чтение Корана';

  @override
  String trackerPages(Object goal, Object pages) {
    return '$pages/$goal страниц';
  }

  @override
  String get trackerHabitsToday => 'Сегодняшние привычки';

  @override
  String get trackerAddHabits => 'Добавьте свои ежедневные привычки';

  @override
  String get trackerNewHabit => 'Новая привычка';

  @override
  String get trackerHabitHint => 'Например: Чтение суры Аль-Кахф';

  @override
  String get trackerAdd => 'Добавить';

  @override
  String get trackerNewObjective => 'Новая цель';

  @override
  String get trackerInProgress => 'В процессе';

  @override
  String get trackerCompleted => 'Завершённые';

  @override
  String get trackerNoObjectives => 'Нет целей';

  @override
  String get trackerNoObjectivesSubtitle =>
      'Задайте свои духовные и ежедневные цели';

  @override
  String get trackerCatSpiritual => 'Духовное';

  @override
  String get trackerCatSport => 'Спорт';

  @override
  String get trackerCatWork => 'Работа';

  @override
  String get trackerCatStudy => 'Учёба';

  @override
  String get trackerCatFinance => 'Финансы';

  @override
  String get trackerCatHealth => 'Здоровье';

  @override
  String get trackerCatOther => 'Другое';

  @override
  String get trackerReopen => 'Возобновить';

  @override
  String get trackerMarkDone => '✓ Выполнено';

  @override
  String get trackerTitleField => 'Название';

  @override
  String get trackerTargetField => 'Цель';

  @override
  String get trackerUnitField => 'Единица';

  @override
  String get trackerCategory => 'Категория';

  @override
  String get trackerCreate => 'Создать';

  @override
  String get trackerTimes => 'раз';

  @override
  String get trackerHelp =>
      'Muslim IA помогает отслеживать ваши ежедневные активности';

  @override
  String trackerGoal(Object target, Object unit) {
    return 'Цель: $target $unit';
  }

  @override
  String get trackerReset => 'Сбросить';

  @override
  String get trackerNoteHint => 'Запишите ваш сегодняшний приём пищи...';

  @override
  String get trackerAddItemHint => 'Добавить элемент...';

  @override
  String get trackerNoHistory => 'Нет истории';

  @override
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  ) {
    return 'Молитвы: $done/$total • Коран: $pages стр. • Подряд: $days дн.';
  }

  @override
  String get trackerVersets => 'стихов';

  @override
  String surahVersets(Object count) {
    return '$count стихов';
  }

  @override
  String surahExplain(Object name) {
    return 'Объяснить $name';
  }

  @override
  String get surahFilter => 'Фильтровать по названию или номеру...';

  @override
  String get surahMeccan => 'Мекканская';

  @override
  String get surahMedinan => 'Мединанская';

  @override
  String get memorizeTouchTranslation => 'Коснитесь для перевода';

  @override
  String get memorizeTouchReveal => 'Коснитесь, чтобы открыть';

  @override
  String get memorizeAgain => 'Ещё раз';

  @override
  String get memorizeEasy => 'Лёгкий';

  @override
  String get memorizeHard => 'Сложный';

  @override
  String get writingStrokeThin => 'Тонкий';

  @override
  String get writingStrokeMedium => 'Средний';

  @override
  String get writingStrokeThick => 'Толстый';

  @override
  String get writingClear => 'Очистить';

  @override
  String get writingClearAll => 'Всё';

  @override
  String get writingNextLetter => 'Следующая буква';

  @override
  String get paywallTitle => 'Muslim IA Premium';

  @override
  String get paywallSubtitle => 'Премиум-подписка';

  @override
  String get paywallCard => 'Оплата банковской картой • Без обязательств';

  @override
  String get paywallPay => 'Оплатить картой';

  @override
  String get paywallProcessing => 'Идёт обработка...';

  @override
  String get paywallVerifying => 'Проверка...';

  @override
  String get paywallAlreadyPaid => 'Я уже оплатил';

  @override
  String get paywallPopular => 'ПОПУЛЯРНО';

  @override
  String get paywallFreeChat => 'Безлимитный ИИ-чат';

  @override
  String get paywallVision => 'ИИ-зрение';

  @override
  String get paywallAlarm => 'Будильник + блокировка телефона';

  @override
  String get paywallPrayerAlerts => 'Уведомления о молитвах';

  @override
  String get paywallQuranExplorer => 'Исследователь Корана';

  @override
  String get paywallMemorization => 'Запоминание и трекер';

  @override
  String get paywallSearchMCP => 'Расширенный поиск МКП';

  @override
  String get paywallTheme => 'Персональная тема';

  @override
  String paywallTrialDays(Object days) {
    return 'Пробная версия — $days осталось';
  }

  @override
  String get paywallTrialEnded => 'Ваша пробная версия закончилась';

  @override
  String get paywallPaymentError =>
      'Ошибка оплаты. Пожалуйста, повторите попытку.';

  @override
  String get paywallPaymentNotDetected => 'Оплата не обнаружена.';

  @override
  String get paywallSuccess =>
      'Оплата прошла успешно! Ваша Premium-подписка активна.';

  @override
  String get paymentSuccessTitle => 'Подписка активирована!';

  @override
  String get paymentSuccessSubtitle =>
      'Ваша Premium-подписка активна. Пользуйтесь всеми функциями прямо сейчас.';

  @override
  String get paymentStart => 'Начать';

  @override
  String get paymentFailureTitle => 'Оплата не удалась';

  @override
  String get paymentFailureSubtitle =>
      'Платёж не прошёл. Проверьте карту и попробуйте ещё раз или вернитесь позже.';

  @override
  String get paywallAssistant => 'Интеллектуальный исламский помощник';

  @override
  String get retry => 'Повторить';

  @override
  String get prayerUnlock => 'Разблокировать сейчас';

  @override
  String get prayerTime => 'время молитвы';

  @override
  String get prayerAutoUnlock =>
      'Телефон будет автоматически\nразблокирован после молитвы';

  @override
  String get prayerRemaining => 'осталось';

  @override
  String get prayerTitle => 'Молитва';

  @override
  String get prayerAlarmStopped => 'Будильник остановлен';

  @override
  String get prayerLockModeOn => 'Режим блокировки включён';

  @override
  String get prayerLockModeOff => 'Режим блокировки выключен';

  @override
  String get prayerStopAlarm => 'Остановить будильник';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get forgotPasswordTitle => 'Сброс пароля';

  @override
  String get forgotPasswordSubtitle =>
      'Введите адрес электронной почты. Мы отправим вам ссылку для сброса пароля.';

  @override
  String get forgotPasswordEmailLabel => 'Электронная почта';

  @override
  String get forgotPasswordEmailHint => 'ваш@email.com';

  @override
  String get forgotPasswordInvalidEmail =>
      'Некорректный адрес электронной почты';

  @override
  String get forgotPasswordSend => 'Отправить ссылку';

  @override
  String get forgotPasswordSent =>
      'Письмо для сброса пароля отправлено! Проверьте почту.';

  @override
  String get authResetTitle => 'Сброс пароля';

  @override
  String get authResetSent => 'Письмо для сброса отправлено! Проверьте почту.';

  @override
  String get authMfaTitle => 'Двухэтапная проверка';

  @override
  String get authMfaBody =>
      'Введите 6-значный код из вашего приложения-аутентификатора.';

  @override
  String get profileEmailChange => 'Изменить email';

  @override
  String get profileEmailNew => 'Новый email';

  @override
  String get profileEmailChanged =>
      'Email изменён! Подтвердите новый адрес по почте.';

  @override
  String get profileSecurity => 'Безопасность';

  @override
  String get profileMfa => 'Двухфакторная аутентификация';

  @override
  String get profileMfaEnabled => 'Включена';

  @override
  String get profileMfaDisabled => 'Отключена';

  @override
  String get profileMfaSetupTitle => 'Включить двухфакторную аутентификацию';

  @override
  String get profileMfaStepQr =>
      'Отсканируйте QR-код приложением-аутентификатором (Google Authenticator, Authy...) и введите сгенерированный код.';

  @override
  String get profileMfaSecretKey => 'Секретный ключ';

  @override
  String get profileMfaCode => '6-значный код';

  @override
  String get profileMfaCodeHint => '123456';

  @override
  String get profileMfaActivate => 'Включить';

  @override
  String get profileMfaEnabledMsg =>
      'Двухфакторная аутентификация включена. Отправлено письмо с подтверждением.';

  @override
  String get profileMfaDisabledMsg => 'Двухфакторная аутентификация отключена.';

  @override
  String get profileMfaInvalidCode =>
      'Неверный или истёкший код. Попробуйте снова.';

  @override
  String get profileMfaDisableTitle => 'Отключить двухфакторную аутентификацию';

  @override
  String get profileMfaDisableBody => 'Введите пароль для подтверждения.';

  @override
  String get profileMfaDisable => 'Отключить';
}
