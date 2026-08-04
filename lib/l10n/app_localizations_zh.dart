// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Muslim IA';

  @override
  String get appTagline => '您的智能伊斯兰助手';

  @override
  String get ok => 'OK';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get confirm => '确认';

  @override
  String get later => '稍后';

  @override
  String get send => '发送';

  @override
  String get resend => '重新发送';

  @override
  String get edit => '编辑';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get today => '今天';

  @override
  String get logout => '退出登录';

  @override
  String get logoutConfirmTitle => '退出登录';

  @override
  String get logoutConfirmBody => '您确定要退出登录吗？';

  @override
  String get login => '登录';

  @override
  String get language => '语言';

  @override
  String get languageDescription => '选择应用语言';

  @override
  String get detectedCountry => '检测到的国家';

  @override
  String get automaticLanguage => '自动语言';

  @override
  String get autoLanguageDescription => '根据您的国家自动检测';

  @override
  String get chatNew => '新对话';

  @override
  String get chatTracker => '伊斯兰追踪';

  @override
  String get chatTrackerSubtitle => '祈祷、古兰经、目标';

  @override
  String get chatCurrent => '进行中';

  @override
  String get chatHistory => '历史记录';

  @override
  String get chatMessages => '条消息';

  @override
  String get chatNoConversations => '暂无对话';

  @override
  String get chatDeleteTitle => '删除此对话？';

  @override
  String chatDeleteBody(Object title) {
    return '“$title”将被永久删除。';
  }

  @override
  String get chatEmptyHint => '古兰经中关于耐心的经文怎么说？';

  @override
  String get chatWelcomeTitle => '愿主赐你平安！今天我能帮您做什么？';

  @override
  String get chatSuggestionQuran => '古兰经中关于耐心的经文怎么说？';

  @override
  String get chatSuggestionSurah => '给我解释一下《法蒂哈》苏拉';

  @override
  String get chatSuggestionWord => '分析阿拉伯词汇“Rahman”';

  @override
  String get chatSuggestionAdvice => '给我一个今日伊斯兰建议';

  @override
  String get chatSuggestionVocab => '教我5个古兰经词汇';

  @override
  String get chatSuggestionProphet => '给我讲讲先知穆罕默德 ﷺ';

  @override
  String get chatInputHint => '向Muslim IA发送消息...';

  @override
  String get chatLimitTitle => '已达上限';

  @override
  String chatLimitBody(Object count) {
    return '您已达到$count条免费消息的上限。\n\n订阅后即可无限畅聊。';
  }

  @override
  String get subscribe => '订阅';

  @override
  String get premiumFeatureTitle => '高级功能';

  @override
  String get premiumFeatureBody => '此功能仅供高级订阅者使用。订阅即可解锁并享受无限消息。';

  @override
  String get chatRecording => '录音中...';

  @override
  String get chatMicPermission => '请允许麦克风权限以录制语音消息。';

  @override
  String get chatMicPermissionTitle => '麦克风被拒绝';

  @override
  String get chatMicPermissionDenied => '麦克风权限已禁用。请前往设置允许权限，然后重试。';

  @override
  String get chatMicSettings => '打开设置';

  @override
  String chatRecordError(Object error) {
    return '录音错误：$error';
  }

  @override
  String get chatContinue => '继续';

  @override
  String get chatCopy => '复制';

  @override
  String get chatEdit => '编辑';

  @override
  String get chatEditing => '正在编辑消息...';

  @override
  String get chatShare => '分享';

  @override
  String get chatAttachTitle => '附件';

  @override
  String get chatCopied => '消息已复制';

  @override
  String get chatPhotoSelected => '已选择照片';

  @override
  String get chatChooseImage => '选择图片';

  @override
  String get chatTakePhoto => '拍照';

  @override
  String get chatAudioTranscription => '语音转文字';

  @override
  String get chatAudioTranscriptionActive => '语音转文字 — 录制您的消息';

  @override
  String get close => '关闭';

  @override
  String get chatPreviewTitle => '录音预览';

  @override
  String get chatPreviewSubtitle => '发送前试听';

  @override
  String get chatNoTextDetected => '未检测到文本';

  @override
  String chatTranscriptionError(Object error) {
    return '转录错误：$error';
  }

  @override
  String get chatVoiceTranscriptionLabel => '音频转录';

  @override
  String get authLogin => '登录';

  @override
  String get authLoginSubtitle => '登录以继续';

  @override
  String get authRegister => '注册';

  @override
  String get authRegisterSubtitle => '创建您的Muslim IA账户';

  @override
  String get authFullName => '全名';

  @override
  String get authEmail => '邮箱';

  @override
  String get authEmailHint => 'your@email.com';

  @override
  String get authPassword => '密码';

  @override
  String get authPasswordHint => '您的密码';

  @override
  String get authConfirmPassword => '确认密码';

  @override
  String get authLoginButton => '登录';

  @override
  String get authRegisterButton => '注册';

  @override
  String get authNoAccount => '没有账户？';

  @override
  String get authHaveAccount => '已有账户？';

  @override
  String get authSkip => '继续不登录';

  @override
  String get authSignUpLink => '注册';

  @override
  String get authLoginLink => '登录';

  @override
  String get authNameRequired => '请输入您的全名';

  @override
  String get authNameTooShort => '姓名至少需要2个字符';

  @override
  String get authEmailInvalid => '邮箱无效';

  @override
  String get authPasswordTooShort => '密码至少6个字符';

  @override
  String get authPasswordMismatch => '密码不匹配';

  @override
  String get authFieldsRequired => '所有字段均为必填';

  @override
  String get authCorrectFields => '请修正字段';

  @override
  String get authErrorNetwork => '网络错误。请检查您的连接。';

  @override
  String get offlineBanner => '无网络连接';

  @override
  String get offlineMessage => '您似乎处于离线状态。请检查网络连接后重试。';

  @override
  String get authVerifyTitle => '验证您的邮箱';

  @override
  String get authVerifySent => '我们已向您发送了一封验证邮件至';

  @override
  String get authVerifyInstructions => '点击邮件中的链接，然后按“继续”';

  @override
  String get authVerifyContinue => '继续';

  @override
  String get authVerifyResend => '重新发送邮件';

  @override
  String get authVerifyUseOther => '使用其他账户';

  @override
  String get authVerifyEmailSent => '邮件已重新发送！请检查收件箱。';

  @override
  String get authEmailNotVerified => '邮箱未验证。请检查收件箱。';

  @override
  String get authVerifyError => '验证错误';

  @override
  String get profileTitle => '个人资料';

  @override
  String get profileEdit => '编辑资料';

  @override
  String get profileFullName => '全名';

  @override
  String get profileEmail => '邮箱';

  @override
  String get profileNotProvided => '未提供';

  @override
  String get profileNotModifiable => '不可修改';

  @override
  String get profilePassword => '密码';

  @override
  String get profileChangePassword => '修改密码';

  @override
  String get profilePasswordTitle => '修改密码';

  @override
  String get profilePasswordCurrent => '当前密码';

  @override
  String get profilePasswordNew => '新密码';

  @override
  String get profilePasswordChanged => '密码修改成功';

  @override
  String get profileTheme => '主题';

  @override
  String get profileDarkMode => '深色模式';

  @override
  String get profileLightMode => '浅色模式';

  @override
  String profileDeleteConversations(Object count) {
    return '删除对话 ($count)';
  }

  @override
  String get profileDeleteConversationsTitle => '删除对话？';

  @override
  String profileDeleteConversationsBody(Object count) {
    return '$count条对话将被永久删除。';
  }

  @override
  String get profileDeleteAll => '全部删除';

  @override
  String get profileSubActive => '订阅已激活';

  @override
  String get profileTrialActive => '试用中';

  @override
  String profileDaysLeft(Object days) {
    return '剩余$days天';
  }

  @override
  String get profileEndsToday => '今日到期';

  @override
  String get profileFreeMessages => '免费消息';

  @override
  String profileToday(Object left, Object total) {
    return '剩余 $left / $total 条消息';
  }

  @override
  String get profileSubscription => '订阅';

  @override
  String get profileFreePlan => '免费版';

  @override
  String get profileUpgrade => '升级至高级版';

  @override
  String get appBarPremium => '升级至高级版';

  @override
  String get profileProgressPlan => '账户进度栏';

  @override
  String get trackerTitle => '伊斯兰追踪';

  @override
  String get trackerToday => '今日';

  @override
  String get trackerObjectives => '目标';

  @override
  String get trackerTools => '小工具';

  @override
  String get trackerHistory => '历史';

  @override
  String trackerDays(Object days) {
    return '$days天';
  }

  @override
  String get trackerStreakSubtitle => '祈祷连胜';

  @override
  String get trackerPrayersToday => '今日祈祷';

  @override
  String get trackerDone => '完成';

  @override
  String get trackerQuranReading => '古兰经阅读';

  @override
  String trackerPages(Object goal, Object pages) {
    return '$pages/$goal 页';
  }

  @override
  String get trackerHabitsToday => '今日习惯';

  @override
  String get trackerAddHabits => '添加您的日常习惯';

  @override
  String get trackerNewHabit => '新习惯';

  @override
  String get trackerHabitHint => '例如：阅读《阿勒卡哈夫》苏拉';

  @override
  String get trackerAdd => '添加';

  @override
  String get trackerNewObjective => '新目标';

  @override
  String get trackerInProgress => '进行中';

  @override
  String get trackerCompleted => '已完成';

  @override
  String get trackerNoObjectives => '暂无目标';

  @override
  String get trackerNoObjectivesSubtitle => '设定您的精神与日常目标';

  @override
  String get trackerCatSpiritual => '精神';

  @override
  String get trackerCatSport => '运动';

  @override
  String get trackerCatWork => '工作';

  @override
  String get trackerCatStudy => '学习';

  @override
  String get trackerCatFinance => '财务';

  @override
  String get trackerCatHealth => '健康';

  @override
  String get trackerCatOther => '其他';

  @override
  String get trackerReopen => '重新打开';

  @override
  String get trackerMarkDone => '✓ 已完成';

  @override
  String get trackerTitleField => '标题';

  @override
  String get trackerTargetField => '目标';

  @override
  String get trackerUnitField => '单位';

  @override
  String get trackerCategory => '分类';

  @override
  String get trackerCreate => '创建';

  @override
  String get trackerTimes => '次';

  @override
  String get trackerHelp => 'Muslim IA助您追踪日常活动';

  @override
  String trackerGoal(Object target, Object unit) {
    return '目标：$target $unit';
  }

  @override
  String get trackerReset => '重置';

  @override
  String get trackerNoteHint => '写下您今日的餐食...';

  @override
  String get trackerAddItemHint => '添加项目...';

  @override
  String get trackerNoHistory => '暂无历史记录';

  @override
  String trackerHistorySummary(
    Object days,
    Object done,
    Object pages,
    Object total,
  ) {
    return '祈祷：$done/$total • 古兰经：$pages页 • 连胜：$days天';
  }

  @override
  String get trackerVersets => '节';

  @override
  String surahVersets(Object count) {
    return '$count节';
  }

  @override
  String surahExplain(Object name) {
    return '解释 $name';
  }

  @override
  String get surahFilter => '按名称或编号筛选...';

  @override
  String get surahMeccan => '麦加篇章';

  @override
  String get surahMedinan => '麦地那篇章';

  @override
  String get memorizeTouchTranslation => '点击查看翻译';

  @override
  String get memorizeTouchReveal => '点击显示';

  @override
  String get memorizeAgain => '再来一次';

  @override
  String get memorizeEasy => '简单';

  @override
  String get memorizeHard => '困难';

  @override
  String get writingStrokeThin => '细';

  @override
  String get writingStrokeMedium => '中';

  @override
  String get writingStrokeThick => '粗';

  @override
  String get writingClear => '清除';

  @override
  String get writingClearAll => '全部';

  @override
  String get writingNextLetter => '下一个字母';

  @override
  String get paywallTitle => 'Muslim IA 高级版';

  @override
  String get paywallSubtitle => '高级订阅';

  @override
  String get paywallCard => '银行卡支付 • 无隐藏费用';

  @override
  String get paywallPay => '立即支付';

  @override
  String get paywallProcessing => '处理中...';

  @override
  String get paywallVerifying => '验证中...';

  @override
  String get paywallAlreadyPaid => '我已付款';

  @override
  String get paywallPopular => '热门推荐';

  @override
  String get paywallFreeChat => '无限AI对话';

  @override
  String get paywallVision => 'AI视觉';

  @override
  String get paywallAlarm => '祈祷闹钟 + 手机锁定';

  @override
  String get paywallPrayerAlerts => '祈祷提醒';

  @override
  String get paywallQuranExplorer => '古兰经探索器';

  @override
  String get paywallMemorization => '记忆与追踪';

  @override
  String get paywallSearchMCP => '高级MCP搜索';

  @override
  String get paywallTheme => '自定义主题';

  @override
  String paywallTrialDays(Object days) {
    return '免费试用 — 剩余$days天';
  }

  @override
  String get paywallTrialEnded => '您的试用已结束';

  @override
  String get paywallPaymentError => '支付错误。请重试。';

  @override
  String get paywallPaymentNotDetected => '未检测到付款。';

  @override
  String get paywallSuccess => '支付成功！您的Premium订阅已激活。';

  @override
  String get paymentSuccessTitle => '订阅已激活！';

  @override
  String get paymentSuccessSubtitle => '您的Premium订阅已生效。立即享受所有功能。';

  @override
  String get paymentStart => '开始';

  @override
  String get paymentFailureTitle => '支付失败';

  @override
  String get paymentFailureSubtitle => '您的付款未完成。请检查银行卡后重试，或稍后再试。';

  @override
  String get paywallAssistant => '智能伊斯兰助手';

  @override
  String get retry => '重试';

  @override
  String get prayerUnlock => '立即解锁';

  @override
  String get prayerTime => '祈祷时间';

  @override
  String get prayerAutoUnlock => '祈祷后手机将自动解锁';

  @override
  String get prayerRemaining => '剩余';

  @override
  String get prayerTitle => '祈祷';

  @override
  String get prayerAlarmStopped => '闹钟已停止';

  @override
  String get prayerLockModeOn => '锁定模式已开启';

  @override
  String get prayerLockModeOff => '锁定模式已关闭';

  @override
  String get prayerStopAlarm => '停止闹钟';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get forgotPasswordTitle => '重置密码';

  @override
  String get forgotPasswordSubtitle => '输入您的电子邮箱。我们将向您发送重置密码的链接。';

  @override
  String get forgotPasswordEmailLabel => '电子邮箱';

  @override
  String get forgotPasswordEmailHint => 'your@email.com';

  @override
  String get forgotPasswordInvalidEmail => '无效的电子邮件地址';

  @override
  String get forgotPasswordSend => '发送链接';

  @override
  String get forgotPasswordSent => '重置密码邮件已发送！请检查您的收件箱。';

  @override
  String get authResetTitle => '重置密码';

  @override
  String get authResetSent => '重置邮件已发送！请查看收件箱。';

  @override
  String get authMfaTitle => '两步验证';

  @override
  String get authMfaBody => '请输入身份验证器应用生成的6位代码。';

  @override
  String get profileEmailChange => '修改邮箱';

  @override
  String get profileEmailNew => '新邮箱';

  @override
  String get profileEmailChanged => '邮箱已修改！请查看新邮箱以确认。';

  @override
  String get profileSecurity => '安全';

  @override
  String get profileMfa => '双重身份验证';

  @override
  String get profileMfaEnabled => '已启用';

  @override
  String get profileMfaDisabled => '已禁用';

  @override
  String get profileMfaSetupTitle => '启用双重身份验证';

  @override
  String get profileMfaStepQr =>
      '使用身份验证器应用（Google Authenticator、Authy 等）扫描二维码，然后输入生成的代码。';

  @override
  String get profileMfaSecretKey => '密钥';

  @override
  String get profileMfaCode => '6位代码';

  @override
  String get profileMfaCodeHint => '123456';

  @override
  String get profileMfaActivate => '启用';

  @override
  String get profileMfaEnabledMsg => '双重身份验证已启用。已发送确认邮件。';

  @override
  String get profileMfaDisabledMsg => '双重身份验证已禁用。';

  @override
  String get profileMfaInvalidCode => '代码无效或已过期，请重试。';

  @override
  String get profileMfaDisableTitle => '禁用双重身份验证';

  @override
  String get profileMfaDisableBody => '请输入密码以确认。';

  @override
  String get profileMfaDisable => '禁用';
}
