// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Muslim IA';

  @override
  String get appTagline => 'Tu asistente islámico inteligente';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get later => 'Más tarde';

  @override
  String get send => 'Enviar';

  @override
  String get resend => 'Reenviar';

  @override
  String get edit => 'Editar';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get today => 'Hoy';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get logoutConfirmTitle => 'Cerrar sesión';

  @override
  String get logoutConfirmBody => '¿Estás seguro de que quieres cerrar sesión?';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Selecciona el idioma de la aplicación';

  @override
  String get detectedCountry => 'País detectado';

  @override
  String get automaticLanguage => 'Idioma automático';

  @override
  String get autoLanguageDescription => 'Detección automática según tu país';

  @override
  String get chatNew => 'Nueva conversación';

  @override
  String get chatTracker => 'Seguimiento Islámico';

  @override
  String get chatTrackerSubtitle => 'Oraciones, Corán, objetivos';

  @override
  String get chatCurrent => 'Activa';

  @override
  String get chatHistory => 'Historial';

  @override
  String get chatMessages => 'mensajes';

  @override
  String get chatNoConversations => 'No hay conversaciones';

  @override
  String get chatDeleteTitle => '¿Eliminar esta conversación?';

  @override
  String chatDeleteBody(Object title) {
    return '\"$title\" se eliminará permanentemente.';
  }

  @override
  String get chatEmptyHint => '¿Qué dice el Corán sobre la paciencia?';

  @override
  String get chatWelcomeTitle => '¡Assalamu alaykum! ¿Cómo puedo ayudarte hoy?';

  @override
  String get chatSuggestionQuran => '¿Qué dice el Corán sobre la paciencia?';

  @override
  String get chatSuggestionSurah => 'Explícame la sura Al-Fatiha';

  @override
  String get chatSuggestionWord => 'Analiza la palabra árabe \"Rahman\"';

  @override
  String get chatSuggestionAdvice => 'Dame un consejo islámico del día';

  @override
  String get chatSuggestionVocab =>
      'Enséñame 5 palabras de vocabulario coránico';

  @override
  String get chatSuggestionProphet => 'Háblame del profeta Muhammad ﷺ';

  @override
  String get chatInputHint => 'Mensaje a Muslim IA...';

  @override
  String get chatLimitTitle => 'Límite alcanzado';

  @override
  String chatLimitBody(Object count) {
    return 'Has enviado $count mensajes hoy.\n\nRegresa mañana para seguir chateando gratis o suscríbete para acceso ilimitado.';
  }

  @override
  String get chatRecording => 'Grabando...';

  @override
  String get chatMicPermission =>
      'Permite el acceso al micrófono para grabar un mensaje de voz.';

  @override
  String get chatMicPermissionTitle => 'Micrófono bloqueado';

  @override
  String get chatMicPermissionDenied =>
      'El acceso al micrófono está desactivado. Abre la configuración para permitirlo y vuelve a intentarlo.';

  @override
  String get chatMicSettings => 'Abrir configuración';

  @override
  String chatRecordError(Object error) {
    return 'Error de grabación: $error';
  }

  @override
  String get chatContinue => 'Continuar';

  @override
  String get chatCopy => 'Copiar';

  @override
  String get chatEdit => 'Editar';

  @override
  String get chatEditing => 'Editando mensaje…';

  @override
  String get chatShare => 'Compartir';

  @override
  String get chatAttachTitle => 'Adjuntar';

  @override
  String get chatCopied => 'Mensaje copiado';

  @override
  String get chatPhotoSelected => 'Foto seleccionada';

  @override
  String get chatChooseImage => 'Elige una imagen';

  @override
  String get chatTakePhoto => 'Tomar una foto';

  @override
  String get chatAudioTranscription => 'Transcripción de audio';

  @override
  String get chatAudioTranscriptionActive =>
      'Transcripción de audio — graba tu mensaje';

  @override
  String get close => 'Cerrar';

  @override
  String get chatPreviewTitle => 'Vista previa de la grabación';

  @override
  String get chatPreviewSubtitle => 'Escucha antes de enviar';

  @override
  String get chatNoTextDetected => 'No se detectó texto';

  @override
  String chatTranscriptionError(Object error) {
    return 'Error de transcripción: $error';
  }

  @override
  String get authLogin => 'Iniciar sesión';

  @override
  String get authLoginSubtitle => 'Inicia sesión para continuar';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authRegisterSubtitle => 'Crea tu cuenta en Muslim IA';

  @override
  String get authFullName => 'Nombre completo';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authEmailHint => 'tu@email.com';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordHint => 'Tu contraseña';

  @override
  String get authConfirmPassword => 'Confirmar';

  @override
  String get authLoginButton => 'Iniciar sesión';

  @override
  String get authRegisterButton => 'Registrarse';

  @override
  String get authNoAccount => '¿No tienes cuenta? ';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get authSkip => 'Continuar sin registrarme';

  @override
  String get authSignUpLink => 'Registrarse';

  @override
  String get authLoginLink => 'Iniciar sesión';

  @override
  String get authNameRequired => 'Ingresa tu nombre completo';

  @override
  String get authNameTooShort => 'El nombre debe tener al menos 2 caracteres';

  @override
  String get authEmailInvalid => 'Correo electrónico inválido';

  @override
  String get authPasswordTooShort => 'Mínimo 6 caracteres';

  @override
  String get authPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get authFieldsRequired => 'Todos los campos son obligatorios';

  @override
  String get authCorrectFields => 'Por favor, corrige los campos';

  @override
  String get authErrorNetwork => 'Error de red. Revisa tu conexión.';

  @override
  String get offlineBanner => 'Sin conexión a internet';

  @override
  String get offlineMessage =>
      'Parece que estás sin conexión. Revisa tu conexión a internet e inténtalo de nuevo.';

  @override
  String get authVerifyTitle => 'Verifica tu correo electrónico';

  @override
  String get authVerifySent => 'Te enviamos un correo de verificación a';

  @override
  String get authVerifyInstructions =>
      'Haz clic en el enlace en el correo y luego presiona \"Continuar\"';

  @override
  String get authVerifyContinue => 'Continuar';

  @override
  String get authVerifyResend => 'Reenviar correo';

  @override
  String get authVerifyUseOther => 'Usar otra cuenta';

  @override
  String get authVerifyEmailSent =>
      '¡Correo reenviado! Revisa tu bandeja de entrada.';

  @override
  String get authEmailNotVerified =>
      'Correo no verificado. Revisa tu bandeja de entrada.';

  @override
  String get authVerifyError => 'Error de verificación';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileFullName => 'Nombre completo';

  @override
  String get profileEmail => 'Correo electrónico';

  @override
  String get profileNotProvided => 'No proporcionado';

  @override
  String get profileNotModifiable => 'No modificable';

  @override
  String get profilePassword => 'Contraseña';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profilePasswordTitle => 'Cambiar contraseña';

  @override
  String get profilePasswordCurrent => 'Contraseña actual';

  @override
  String get profilePasswordNew => 'Nueva contraseña';

  @override
  String get profilePasswordChanged => 'Contraseña cambiada con éxito';

  @override
  String get profileTheme => 'Tema';

  @override
  String get profileDarkMode => 'Modo oscuro';

  @override
  String get profileLightMode => 'Modo claro';

  @override
  String profileDeleteConversations(Object count) {
    return 'Eliminar conversaciones ($count)';
  }

  @override
  String get profileDeleteConversationsTitle => '¿Eliminar conversaciones?';

  @override
  String profileDeleteConversationsBody(Object count) {
    return '$count conversación(es) se eliminarán permanentemente.';
  }

  @override
  String get profileDeleteAll => 'Eliminar todo';

  @override
  String get profileSubActive => 'Suscripción activa';

  @override
  String get profileTrialActive => 'Prueba gratuita';

  @override
  String profileDaysLeft(Object days) {
    return '$days días restantes';
  }

  @override
  String get profileEndsToday => 'Termina hoy';

  @override
  String get profileFreeMessages => 'Mensajes gratuitos';

  @override
  String profileToday(Object left, Object total) {
    return '$left / $total hoy';
  }

  @override
  String get profileSubscription => 'Suscripción';

  @override
  String get profileFreePlan => 'Plan gratuito';

  @override
  String get profileUpgrade => 'Pasar a Premium';

  @override
  String get appBarPremium => 'Pasar a Premium';

  @override
  String get profileProgressPlan => 'Barra de progreso de la cuenta';

  @override
  String get trackerTitle => 'Seguimiento Islámico';

  @override
  String get trackerToday => 'Hoy';

  @override
  String get trackerObjectives => 'Objetivos';

  @override
  String get trackerTools => 'Herramientas';

  @override
  String get trackerHistory => 'Historial';

  @override
  String trackerDays(Object days) {
    return '$days días';
  }

  @override
  String get trackerStreakSubtitle => 'de streak de oración';

  @override
  String get trackerPrayersToday => 'Oraciones de hoy';

  @override
  String get trackerDone => 'Hecho';

  @override
  String get trackerQuranReading => 'Lectura del Corán';

  @override
  String trackerPages(Object goal, Object pages) {
    return '$pages/$goal páginas';
  }

  @override
  String get trackerHabitsToday => 'Hábitos de hoy';

  @override
  String get trackerAddHabits => 'Agrega tus hábitos diarios';

  @override
  String get trackerNewHabit => 'Nuevo hábito';

  @override
  String get trackerHabitHint => 'Ej: Leer Sura Al-Kahf';

  @override
  String get trackerAdd => 'Agregar';

  @override
  String get trackerNewObjective => 'Nuevo objetivo';

  @override
  String get trackerInProgress => 'En progreso';

  @override
  String get trackerCompleted => 'Completados';

  @override
  String get trackerNoObjectives => 'Sin objetivos';

  @override
  String get trackerNoObjectivesSubtitle =>
      'Define tus metas espirituales y diarias';

  @override
  String get trackerCatSpiritual => 'Espiritual';

  @override
  String get trackerCatSport => 'Deporte';

  @override
  String get trackerCatWork => 'Trabajo';

  @override
  String get trackerCatStudy => 'Estudios';

  @override
  String get trackerCatFinance => 'Finanzas';

  @override
  String get trackerCatHealth => 'Salud';

  @override
  String get trackerCatOther => 'Otro';

  @override
  String get trackerReopen => 'Reabrir';

  @override
  String get trackerMarkDone => '✓ Hecho';

  @override
  String get trackerTitleField => 'Título';

  @override
  String get trackerTargetField => 'Objetivo';

  @override
  String get trackerUnitField => 'Unidad';

  @override
  String get trackerCategory => 'Categoría';

  @override
  String get trackerCreate => 'Crear';

  @override
  String get trackerTimes => 'veces';

  @override
  String get trackerHelp =>
      'Muslim IA te ayuda a seguir tus actividades diarias';

  @override
  String trackerGoal(Object target, Object unit) {
    return 'Objetivo: $target $unit';
  }

  @override
  String get trackerReset => 'Reiniciar';

  @override
  String get trackerNoteHint => 'Escribe tu comida del día...';

  @override
  String get trackerAddItemHint => 'Agregar elemento...';

  @override
  String get trackerNoHistory => 'Sin historial';

  @override
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  ) {
    return 'Oraciones: $done/$total • Corán: ${pages}p • Streak: ${days}d';
  }

  @override
  String get trackerVersets => 'versículos';

  @override
  String surahVersets(Object count) {
    return '$count versículos';
  }

  @override
  String surahExplain(Object name) {
    return 'Explicar $name';
  }

  @override
  String get surahFilter => 'Filtrar por nombre o número...';

  @override
  String get surahMeccan => 'Mecana';

  @override
  String get surahMedinan => 'Medinense';

  @override
  String get memorizeTouchTranslation => 'Tocar para traducción';

  @override
  String get memorizeTouchReveal => 'Tocar para revelar';

  @override
  String get memorizeAgain => 'Otra vez';

  @override
  String get memorizeEasy => 'Fácil';

  @override
  String get memorizeHard => 'Difícil';

  @override
  String get writingStrokeThin => 'Fino';

  @override
  String get writingStrokeMedium => 'Medio';

  @override
  String get writingStrokeThick => 'Grueso';

  @override
  String get writingClear => 'Borrar';

  @override
  String get writingClearAll => 'Todo';

  @override
  String get writingNextLetter => 'Siguiente letra';

  @override
  String get paywallTitle => 'Muslim IA Premium';

  @override
  String get paywallSubtitle => 'Suscripción Premium';

  @override
  String get paywallCard => 'Pago con tarjeta bancaria • Sin compromiso';

  @override
  String get paywallPay => 'Pagar con tarjeta';

  @override
  String get paywallProcessing => 'Procesando...';

  @override
  String get paywallVerifying => 'Verificando...';

  @override
  String get paywallAlreadyPaid => 'Ya pagué';

  @override
  String get paywallPopular => 'POPULAR';

  @override
  String get paywallFreeChat => 'Chat IA ilimitado';

  @override
  String get paywallVision => 'Visión IA';

  @override
  String get paywallAlarm => 'Alarma + bloqueo de teléfono';

  @override
  String get paywallPrayerAlerts => 'Alertas de oración';

  @override
  String get paywallQuranExplorer => 'Explorador del Corán';

  @override
  String get paywallMemorization => 'Memorización y seguimiento';

  @override
  String get paywallSearchMCP => 'Búsqueda avanzada MCP';

  @override
  String get paywallTheme => 'Tema personalizado';

  @override
  String paywallTrialDays(Object days) {
    return 'Prueba gratuita — $days restantes';
  }

  @override
  String get paywallTrialEnded => 'Tu prueba ha terminado';

  @override
  String get paywallPaymentError => 'Error de pago. Inténtalo de nuevo.';

  @override
  String get paywallPaymentNotDetected => 'Pago no detectado.';

  @override
  String get paywallSuccess =>
      '¡Pago exitoso! Tu suscripción Premium ya está activa.';

  @override
  String get paymentSuccessTitle => '¡Suscripción activada!';

  @override
  String get paymentSuccessSubtitle =>
      'Tu suscripción Premium ya está activa. Disfruta de todas las funciones ahora mismo.';

  @override
  String get paymentStart => 'Comenzar';

  @override
  String get paymentFailureTitle => 'Pago fallido';

  @override
  String get paymentFailureSubtitle =>
      'Tu pago no se completó. Revisa tu tarjeta e inténtalo de nuevo, o vuelve más tarde.';

  @override
  String get paywallAssistant => 'Asistente islámico inteligente';

  @override
  String get retry => 'Reintentar';

  @override
  String get prayerUnlock => 'Desbloquear ahora';

  @override
  String get prayerTime => 'hora de la oración';

  @override
  String get prayerAutoUnlock =>
      'El teléfono se desbloqueará\nautomáticamente después de la oración';

  @override
  String get prayerRemaining => 'restantes';

  @override
  String get prayerTitle => 'Oración';

  @override
  String get prayerAlarmStopped => 'Alarma detenida';

  @override
  String get prayerLockModeOn => 'Modo bloqueo activado';

  @override
  String get prayerLockModeOff => 'Modo bloqueo desactivado';

  @override
  String get prayerStopAlarm => 'Detener alarma';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordTitle => 'Restablecer contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Introduce tu correo electrónico. Te enviaremos un enlace para restablecer tu contraseña.';

  @override
  String get forgotPasswordEmailLabel => 'Correo electrónico';

  @override
  String get forgotPasswordEmailHint => 'tucorreo@email.com';

  @override
  String get forgotPasswordInvalidEmail => 'Correo electrónico no válido';

  @override
  String get forgotPasswordSend => 'Enviar enlace';

  @override
  String get forgotPasswordSent =>
      '¡Correo de restablecimiento enviado! Revisa tu bandeja de entrada.';

  @override
  String get authResetTitle => 'Restablecer contraseña';

  @override
  String get authResetSent =>
      '¡Correo de restablecimiento enviado! Revisa tu bandeja de entrada.';

  @override
  String get authMfaTitle => 'Verificación en dos pasos';

  @override
  String get authMfaBody =>
      'Introduce el código de 6 dígitos de tu aplicación de autenticación.';

  @override
  String get profileEmailChange => 'Cambiar email';

  @override
  String get profileEmailNew => 'Nuevo email';

  @override
  String get profileEmailChanged =>
      '¡Email cambiado! Revisa tu nuevo email para confirmar.';

  @override
  String get profileSecurity => 'Seguridad';

  @override
  String get profileMfa => 'Autenticación de dos factores';

  @override
  String get profileMfaEnabled => 'Activada';

  @override
  String get profileMfaDisabled => 'Desactivada';

  @override
  String get profileMfaSetupTitle => 'Activar autenticación de dos factores';

  @override
  String get profileMfaStepQr =>
      'Escanea el código QR con tu app de autenticación (Google Authenticator, Authy...) e introduce el código generado.';

  @override
  String get profileMfaSecretKey => 'Clave secreta';

  @override
  String get profileMfaCode => 'Código de 6 dígitos';

  @override
  String get profileMfaCodeHint => '123456';

  @override
  String get profileMfaActivate => 'Activar';

  @override
  String get profileMfaEnabledMsg =>
      'Autenticación de dos factores activada. Se ha enviado un email de confirmación.';

  @override
  String get profileMfaDisabledMsg =>
      'Autenticación de dos factores desactivada.';

  @override
  String get profileMfaInvalidCode =>
      'Código inválido o caducado. Inténtalo de nuevo.';

  @override
  String get profileMfaDisableTitle =>
      'Desactivar autenticación de dos factores';

  @override
  String get profileMfaDisableBody => 'Introduce tu contraseña para confirmar.';

  @override
  String get profileMfaDisable => 'Desactivar';
}
