// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Muslim IA';

  @override
  String get appTagline => 'Seu assitente islâmico inteligente';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get later => 'Mais tarde';

  @override
  String get send => 'Enviar';

  @override
  String get resend => 'Reenviar';

  @override
  String get edit => 'Editar';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String get today => 'Hoje';

  @override
  String get logout => 'Sair';

  @override
  String get logoutConfirmTitle => 'Sair';

  @override
  String get logoutConfirmBody => 'Tem certeza de que deseja sair?';

  @override
  String get login => 'Entrar';

  @override
  String get language => 'Idioma';

  @override
  String get languageDescription => 'Escolha o idioma do aplicativo';

  @override
  String get detectedCountry => 'País detectado';

  @override
  String get automaticLanguage => 'Idioma automático';

  @override
  String get autoLanguageDescription =>
      'Detecção automática com base no seu país';

  @override
  String get chatNew => 'Nova conversa';

  @override
  String get chatTracker => 'Acompanhamento Islâmico';

  @override
  String get chatTrackerSubtitle => 'Orações, Alcorão, objetivos';

  @override
  String get chatCurrent => 'Atual';

  @override
  String get chatHistory => 'Histórico';

  @override
  String get chatMessages => 'mensagens';

  @override
  String get chatNoConversations => 'Nenhuma conversa';

  @override
  String get chatDeleteTitle => 'Excluir esta conversa?';

  @override
  String chatDeleteBody(Object title) {
    return '\"$title\" será excluída permanentemente.';
  }

  @override
  String get chatEmptyHint => 'O que o Alcorão diz sobre a paciência?';

  @override
  String get chatWelcomeTitle => 'Assalamu alaykum! Como posso ajudá-lo hoje?';

  @override
  String get chatSuggestionQuran => 'O que o Alcorão diz sobre a paciência?';

  @override
  String get chatSuggestionSurah => 'Explique-me a surata Al-Fatiha';

  @override
  String get chatSuggestionWord => 'Analise a palavra árabe \"Rahman\"';

  @override
  String get chatSuggestionAdvice => 'Dê-me um conselho islâmico do dia';

  @override
  String get chatSuggestionVocab =>
      'Ensine-me 5 palavras de vocabulário corânico';

  @override
  String get chatSuggestionProphet => 'Fale-me sobre o profeta Muhammad ﷺ';

  @override
  String get chatInputHint => 'Mensagem para Muslim IA...';

  @override
  String get chatLimitTitle => 'Limite atingido';

  @override
  String chatLimitBody(Object count) {
    return 'Você atingiu o limite de $count mensagens gratuitas.\n\nAssine para continuar conversando sem limites.';
  }

  @override
  String get subscribe => 'Assinar';

  @override
  String get premiumFeatureTitle => 'Recurso Premium';

  @override
  String get premiumFeatureBody =>
      'Este recurso é reservado aos assinantes Premium. Assine para acessá-lo e aproveitar mensagens ilimitadas.';

  @override
  String get chatRecording => 'Gravando...';

  @override
  String get chatMicPermission =>
      'Permita o acesso ao microfone para gravar uma mensagem de voz.';

  @override
  String get chatMicPermissionTitle => 'Microfone bloqueado';

  @override
  String get chatMicPermissionDenied =>
      'O acesso ao microfone está desativado. Abra as configurações para permitir e tente novamente.';

  @override
  String get chatMicSettings => 'Abrir configurações';

  @override
  String chatRecordError(Object error) {
    return 'Erro na gravação: $error';
  }

  @override
  String get chatContinue => 'Continuar';

  @override
  String get chatCopy => 'Copiar';

  @override
  String get chatEdit => 'Editar';

  @override
  String get chatEditing => 'Editando mensagem…';

  @override
  String get chatShare => 'Compartilhar';

  @override
  String get chatAttachTitle => 'Anexar';

  @override
  String get chatCopied => 'Mensagem copiada';

  @override
  String get chatPhotoSelected => 'Foto selecionada';

  @override
  String get chatChooseImage => 'Escolher uma imagem';

  @override
  String get chatTakePhoto => 'Tirar uma foto';

  @override
  String get chatAudioTranscription => 'Transcrição de áudio';

  @override
  String get chatAudioTranscriptionActive =>
      'Transcrição de áudio — grave sua mensagem';

  @override
  String get close => 'Fechar';

  @override
  String get chatPreviewTitle => 'Pré-visualização da gravação';

  @override
  String get chatPreviewSubtitle => 'Ouça antes de enviar';

  @override
  String get chatNoTextDetected => 'Nenhum texto detectado';

  @override
  String chatTranscriptionError(Object error) {
    return 'Erro de transcrição: $error';
  }

  @override
  String get chatVoiceTranscriptionLabel => 'Transcrição de áudio';

  @override
  String get chatPreparingVoice => 'Preparando a voz…';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authLoginSubtitle => 'Entre para continuar';

  @override
  String get authRegister => 'Cadastrar-se';

  @override
  String get authRegisterSubtitle => 'Crie sua conta Muslim IA';

  @override
  String get authFullName => 'Nome completo';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authEmailHint => 'seu@email.com';

  @override
  String get authPassword => 'Senha';

  @override
  String get authPasswordHint => 'Sua senha';

  @override
  String get authConfirmPassword => 'Confirmar';

  @override
  String get authLoginButton => 'Entrar';

  @override
  String get authRegisterButton => 'Cadastrar-se';

  @override
  String get authNoAccount => 'Não tem conta? ';

  @override
  String get authHaveAccount => 'Já tem conta? ';

  @override
  String get authSkip => 'Continuar sem cadastro';

  @override
  String get authSignUpLink => 'Cadastrar-se';

  @override
  String get authLoginLink => 'Entrar';

  @override
  String get authNameRequired => 'Digite seu nome completo';

  @override
  String get authNameTooShort => 'O nome deve ter pelo menos 2 caracteres';

  @override
  String get authEmailInvalid => 'E-mail inválido';

  @override
  String get authPasswordTooShort => 'Mínimo de 6 caracteres';

  @override
  String get authPasswordMismatch => 'As senhas não coincidem';

  @override
  String get authFieldsRequired => 'Todos os campos são obrigatórios';

  @override
  String get authCorrectFields => 'Corrija os campos';

  @override
  String get authErrorNetwork => 'Erro de rede. Verifique sua conexão.';

  @override
  String get offlineBanner => 'Sem conexão com a internet';

  @override
  String get offlineMessage =>
      'Você parece estar offline. Verifique sua conexão e tente novamente.';

  @override
  String get authVerifyTitle => 'Verifique seu e-mail';

  @override
  String get authVerifySent => 'Enviamos um e-mail de verificação para';

  @override
  String get authVerifyInstructions =>
      'Clique no link no e-mail e pressione \"Continuar\"';

  @override
  String get authVerifyContinue => 'Continuar';

  @override
  String get authVerifyResend => 'Reenviar e-mail';

  @override
  String get authVerifyUseOther => 'Usar outra conta';

  @override
  String get authVerifyEmailSent =>
      'E-mail reenviado! Verifique sua caixa de entrada.';

  @override
  String get authEmailNotVerified =>
      'E-mail não verificado. Verifique sua caixa de entrada.';

  @override
  String get authVerifyError => 'Erro de verificação';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileFullName => 'Nome completo';

  @override
  String get profileEmail => 'E-mail';

  @override
  String get profileNotProvided => 'Não informado';

  @override
  String get profileNotModifiable => 'Não modificável';

  @override
  String get profilePassword => 'Senha';

  @override
  String get profileChangePassword => 'Alterar senha';

  @override
  String get profilePasswordTitle => 'Alterar senha';

  @override
  String get profilePasswordCurrent => 'Senha atual';

  @override
  String get profilePasswordNew => 'Nova senha';

  @override
  String get profilePasswordChanged => 'Senha alterada com sucesso';

  @override
  String get profileTheme => 'Tema';

  @override
  String get profileDarkMode => 'Modo escuro';

  @override
  String get profileLightMode => 'Modo claro';

  @override
  String profileDeleteConversations(Object count) {
    return 'Excluir conversas ($count)';
  }

  @override
  String get profileDeleteConversationsTitle => 'Excluir conversas?';

  @override
  String profileDeleteConversationsBody(Object count) {
    return '$count conversa(s) serão excluídas permanentemente.';
  }

  @override
  String get profileDeleteAll => 'Excluir tudo';

  @override
  String get profileSubActive => 'Assinatura ativa';

  @override
  String get profileTrialActive => 'Teste gratuito';

  @override
  String profileDaysLeft(Object days) {
    return '$days dias restantes';
  }

  @override
  String get profileEndsToday => 'Termina hoje';

  @override
  String get profileFreeMessages => 'Mensagens gratuitas';

  @override
  String profileToday(Object left, Object total) {
    return '$left / $total mensagens restantes';
  }

  @override
  String get profileSubscription => 'Assinatura';

  @override
  String get profileFreePlan => 'Plano gratuito';

  @override
  String get profileUpgrade => 'Assinar Premium';

  @override
  String get appBarPremium => 'Passar para Premium';

  @override
  String get profileProgressPlan => 'Barra de progresso da conta';

  @override
  String get trackerTitle => 'Acompanhamento Islâmico';

  @override
  String get trackerToday => 'Hoje';

  @override
  String get trackerObjectives => 'Objetivos';

  @override
  String get trackerTools => 'Mini-ferramentas';

  @override
  String get trackerHistory => 'Histórico';

  @override
  String trackerDays(Object days) {
    return '$days dias';
  }

  @override
  String get trackerStreakSubtitle => 'de streak de oração';

  @override
  String get trackerPrayersToday => 'Orações de hoje';

  @override
  String get trackerDone => 'Concluído';

  @override
  String get trackerQuranReading => 'Leitura do Alcorão';

  @override
  String trackerPages(Object goal, Object pages) {
    return '$pages/$goal páginas';
  }

  @override
  String get trackerHabitsToday => 'Hábitos de hoje';

  @override
  String get trackerAddHabits => 'Adicione seus hábitos diários';

  @override
  String get trackerNewHabit => 'Novo hábito';

  @override
  String get trackerHabitHint => 'Ex: Ler Surata Al-Kahf';

  @override
  String get trackerAdd => 'Adicionar';

  @override
  String get trackerNewObjective => 'Novo objetivo';

  @override
  String get trackerInProgress => 'Em andamento';

  @override
  String get trackerCompleted => 'Concluídos';

  @override
  String get trackerNoObjectives => 'Nenhum objetivo';

  @override
  String get trackerNoObjectivesSubtitle =>
      'Defina seus objetivos espirituais e diários';

  @override
  String get trackerCatSpiritual => 'Espiritual';

  @override
  String get trackerCatSport => 'Esporte';

  @override
  String get trackerCatWork => 'Trabalho';

  @override
  String get trackerCatStudy => 'Estudos';

  @override
  String get trackerCatFinance => 'Finanças';

  @override
  String get trackerCatHealth => 'Saúde';

  @override
  String get trackerCatOther => 'Outro';

  @override
  String get trackerReopen => 'Reabrir';

  @override
  String get trackerMarkDone => '✓ Concluído';

  @override
  String get trackerTitleField => 'Título';

  @override
  String get trackerTargetField => 'Objetivo';

  @override
  String get trackerUnitField => 'Unidade';

  @override
  String get trackerCategory => 'Categoria';

  @override
  String get trackerCreate => 'Criar';

  @override
  String get trackerTimes => 'vezes';

  @override
  String get trackerHelp =>
      'Muslim IA ajuda você a acompanhar suas atividades diárias';

  @override
  String trackerGoal(Object target, Object unit) {
    return 'Objetivo: $target $unit';
  }

  @override
  String get trackerReset => 'Redefinir';

  @override
  String get trackerNoteHint => 'Escreva sua refeição do dia...';

  @override
  String get trackerAddItemHint => 'Adicionar item...';

  @override
  String get trackerNoHistory => 'Nenhum histórico';

  @override
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  ) {
    return 'Orações: $done/$total • Alcorão: ${pages}p • Streak: ${days}d';
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
  String get surahFilter => 'Filtrar por nome ou número...';

  @override
  String get surahMeccan => 'Mecana';

  @override
  String get surahMedinan => 'Medinense';

  @override
  String get memorizeTouchTranslation => 'Toque para tradução';

  @override
  String get memorizeTouchReveal => 'Toque para revelar';

  @override
  String get memorizeAgain => 'Novamente';

  @override
  String get memorizeEasy => 'Fácil';

  @override
  String get memorizeHard => 'Difícil';

  @override
  String get writingStrokeThin => 'Fino';

  @override
  String get writingStrokeMedium => 'Médio';

  @override
  String get writingStrokeThick => 'Grosso';

  @override
  String get writingClear => 'Limpar';

  @override
  String get writingClearAll => 'Tudo';

  @override
  String get writingNextLetter => 'Próxima letra';

  @override
  String get paywallTitle => 'Muslim IA Premium';

  @override
  String get paywallSubtitle => 'Assinatura Premium';

  @override
  String get paywallCard => 'Pagamento por cartão • Sem compromisso';

  @override
  String get paywallPay => 'Pagar com cartão';

  @override
  String get paywallProcessing => 'Processando...';

  @override
  String get paywallVerifying => 'Verificando...';

  @override
  String get paywallAlreadyPaid => 'Já paguei';

  @override
  String get paywallPopular => 'POPULAR';

  @override
  String get paywallFreeChat => 'Chat IA ilimitado';

  @override
  String get paywallVision => 'Visão IA';

  @override
  String get paywallAlarm => 'Alarme + bloqueio do telefone';

  @override
  String get paywallPrayerAlerts => 'Alertas de oração';

  @override
  String get paywallQuranExplorer => 'Explorador do Alcorão';

  @override
  String get paywallMemorization => 'Memorização & Acompanhamento';

  @override
  String get paywallSearchMCP => 'Pesquisa avançada MCP';

  @override
  String get paywallTheme => 'Tema personalizado';

  @override
  String paywallTrialDays(Object days) {
    return 'Teste gratuito — $days restantes';
  }

  @override
  String get paywallTrialEnded => 'Seu teste terminou';

  @override
  String get paywallPaymentError => 'Erro no pagamento. Tente novamente.';

  @override
  String get paywallPaymentNotDetected => 'Pagamento não detectado.';

  @override
  String get paywallSuccess =>
      'Pagamento realizado! Sua assinatura Premium já está ativa.';

  @override
  String get paymentSuccessTitle => 'Assinatura ativada!';

  @override
  String get paymentSuccessSubtitle =>
      'Sua assinatura Premium está ativa. Aproveite todos os recursos agora.';

  @override
  String get paymentStart => 'Começar';

  @override
  String get paymentFailureTitle => 'Pagamento falhou';

  @override
  String get paymentFailureSubtitle =>
      'Seu pagamento não foi concluído. Verifique seu cartão e tente novamente, ou volte mais tarde.';

  @override
  String get paywallAssistant => 'Assistente islâmico inteligente';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get prayerUnlock => 'Desbloquear agora';

  @override
  String get prayerTime => 'hora da oração';

  @override
  String get prayerAutoUnlock =>
      'O telefone será desbloqueado\nautomáticamente após a oração';

  @override
  String get prayerRemaining => 'restantes';

  @override
  String get prayerTitle => 'Orações';

  @override
  String get prayerAlarmStopped => 'Alarme parado';

  @override
  String get prayerLockModeOn => 'Modo de bloqueio ativado';

  @override
  String get prayerLockModeOff => 'Modo de bloqueio desativado';

  @override
  String get prayerStopAlarm => 'Parar alarme';

  @override
  String get authForgotPassword => 'Esqueceu a senha?';

  @override
  String get forgotPasswordTitle => 'Redefinir senha';

  @override
  String get forgotPasswordSubtitle =>
      'Digite seu e-mail. Enviaremos um link para redefinir sua senha.';

  @override
  String get forgotPasswordEmailLabel => 'Endereço de e-mail';

  @override
  String get forgotPasswordEmailHint => 'seu@email.com';

  @override
  String get forgotPasswordInvalidEmail => 'Endereço de e-mail inválido';

  @override
  String get forgotPasswordSend => 'Enviar link';

  @override
  String get forgotPasswordSent =>
      'E-mail de redefinição enviado! Verifique sua caixa de entrada.';

  @override
  String get authResetTitle => 'Redefinir senha';

  @override
  String get authResetSent =>
      'Email de redefinição enviado! Verifique sua caixa de entrada.';

  @override
  String get authMfaTitle => 'Verificação em duas etapas';

  @override
  String get authMfaBody =>
      'Digite o código de 6 dígitos do seu aplicativo autenticador.';

  @override
  String get profileEmailChange => 'Alterar email';

  @override
  String get profileEmailNew => 'Novo email';

  @override
  String get profileEmailChanged =>
      'Email alterado! Verifique seu novo email para confirmar.';

  @override
  String get profileSecurity => 'Segurança';

  @override
  String get profileMfa => 'Autenticação de dois fatores';

  @override
  String get profileMfaEnabled => 'Ativada';

  @override
  String get profileMfaDisabled => 'Desativada';

  @override
  String get profileMfaSetupTitle => 'Ativar autenticação de dois fatores';

  @override
  String get profileMfaStepQr =>
      'Escaneie o código QR com seu app autenticador (Google Authenticator, Authy...) e digite o código gerado.';

  @override
  String get profileMfaSecretKey => 'Chave secreta';

  @override
  String get profileMfaCode => 'Código de 6 dígitos';

  @override
  String get profileMfaCodeHint => '123456';

  @override
  String get profileMfaActivate => 'Ativar';

  @override
  String get profileMfaEnabledMsg =>
      'Autenticação de dois fatores ativada. Um email de confirmação foi enviado.';

  @override
  String get profileMfaDisabledMsg =>
      'Autenticação de dois fatores desativada.';

  @override
  String get profileMfaInvalidCode =>
      'Código inválido ou expirado. Tente novamente.';

  @override
  String get profileMfaDisableTitle => 'Desativar autenticação de dois fatores';

  @override
  String get profileMfaDisableBody => 'Digite sua senha para confirmar.';

  @override
  String get profileMfaDisable => 'Desativar';
}
