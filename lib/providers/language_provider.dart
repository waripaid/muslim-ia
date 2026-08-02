import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class LanguageProvider extends ChangeNotifier {
  static const supportedLocales = [Locale('fr'), Locale('ar'), Locale('en'), Locale('es'), Locale('pt'), Locale('ru'), Locale('zh')];

  static const _prefKey = 'app_language';
  static const _countryKey = 'detected_country';

  final SharedPreferences _prefs;
  Locale _locale;
  String? _detectedCountry;
  bool _detecting = false;

  LanguageProvider({required SharedPreferences prefs, Locale? deviceLocale})
      : _prefs = prefs,
        _locale = Locale(_sanitize(
          prefs.getString(_prefKey) ?? _localeCodeOf(deviceLocale ?? _platformLocale),
        )) {
    _detectedCountry = prefs.getString(_countryKey);
    if (!prefs.containsKey(_prefKey)) {
      _detectCountry();
    }
  }

  static Locale get _platformLocale {
    try {
      return WidgetsBinding.instance.platformDispatcher.locale;
    } catch (_) {
      return const Locale('fr');
    }
  }

  Locale get locale => _locale;
  String? get detectedCountry => _detectedCountry;
  bool get isDetecting => _detecting;
  bool get isAuto => !_prefs.containsKey(_prefKey);

  static String _sanitize(String code) =>
      ['fr', 'ar', 'en', 'es', 'pt', 'ru', 'zh'].contains(code) ? code : 'fr';

  static String _localeCodeOf(Locale locale) => _sanitize(locale.languageCode);

  Future<void> setLanguage(String languageCode) async {
    final code = _sanitize(languageCode);
    await _prefs.setString(_prefKey, code);
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setAutoLanguage() async {
    await _prefs.remove(_prefKey);
    await _detectCountry();
  }

  String get languageName {
    switch (_locale.languageCode) {
      case 'ar': return 'العربية';
      case 'en': return 'English';
      case 'es': return 'Español';
      case 'pt': return 'Português';
      case 'ru': return 'Русский';
      case 'zh': return '中文';
      default: return 'Français';
    }
  }

  /// Détecte le pays via IP géolocalisation et règle la langue automatiquement
  /// si l'utilisateur n'a pas choisi manuellement.
  Future<void> _detectCountry() async {
    if (_detecting) return;
    _detecting = true;
    notifyListeners();
    try {
      final res = await http
          .get(Uri.parse('http://ip-api.com/json/?fields=status,countryCode'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'success' && data['countryCode'] != null) {
          final code = data['countryCode'].toString().toUpperCase();
          await _prefs.setString(_countryKey, code);
          _detectedCountry = code;
          if (!_prefs.containsKey(_prefKey)) {
            final lang = languageForCountry(code);
            await _prefs.setString(_prefKey, lang);
            _locale = Locale(lang);
          }
          AppLogger.success('Lang', 'Pays détecté: $code -> ${_locale.languageCode}');
        }
      }
    } catch (e) {
      AppLogger.warn('Lang', 'Détection pays échouée: $e');
    } finally {
      _detecting = false;
      notifyListeners();
    }
  }

  /// Retourne la langue principale d'un pays (code ISO 3166-1 alpha-2).
  static String languageForCountry(String countryCode) {
    final c = countryCode.toUpperCase();
    if (_arabicCountries.contains(c)) return 'ar';
    if (_frenchCountries.contains(c)) return 'fr';
    if (_russianCountries.contains(c)) return 'ru';
    if (_chineseCountries.contains(c)) return 'zh';
    if (_portugueseCountries.contains(c)) return 'pt';
    if (_spanishCountries.contains(c)) return 'es';
    if (_englishCountries.contains(c)) return 'en';
    return _sanitize(_platformLocale.languageCode);
  }

  static String countryName(String countryCode) {
    const names = {
      'FR': 'France', 'BE': 'Belgique', 'CH': 'Suisse', 'MC': 'Monaco',
      'LU': 'Luxembourg', 'CA': 'Canada', 'SN': 'Sénégal', 'CI': 'Côte d\'Ivoire',
      'ML': 'Mali', 'BF': 'Burkina Faso', 'NE': 'Niger', 'TG': 'Togo',
      'BJ': 'Bénin', 'GN': 'Guinée', 'GA': 'Gabon', 'CG': 'Congo',
      'CD': 'RD Congo', 'CM': 'Cameroun', 'CF': 'Centrafrique', 'TD': 'Tchad',
      'MG': 'Madagascar', 'RW': 'Rwanda', 'BI': 'Burundi', 'DJ': 'Djibouti',
      'HT': 'Haïti', 'KM': 'Comores',
      'SA': 'Arabie Saoudite', 'AE': 'Émirats', 'QA': 'Qatar', 'KW': 'Koweït',
      'BH': 'Bahreïn', 'OM': 'Oman', 'YE': 'Yémen', 'IQ': 'Irak', 'SY': 'Syrie',
      'JO': 'Jordanie', 'LB': 'Liban', 'PS': 'Palestine', 'EG': 'Égypte',
      'SD': 'Soudan', 'LY': 'Libye', 'TN': 'Tunisie', 'DZ': 'Algérie',
      'MA': 'Maroc', 'MR': 'Mauritanie', 'SO': 'Somalie',
      'US': 'États-Unis', 'GB': 'Royaume-Uni', 'AU': 'Australie', 'NZ': 'Nouvelle-Zélande',
      'IE': 'Irlande', 'ZA': 'Afrique du Sud', 'NG': 'Nigeria', 'GH': 'Ghana',
      'KE': 'Kenya', 'UG': 'Ouganda', 'TZ': 'Tanzanie', 'ZM': 'Zambie',
      'ZW': 'Zimbabwe', 'NA': 'Namibie', 'BW': 'Botswana', 'IN': 'Inde',
      'PK': 'Pakistan', 'PH': 'Philippines', 'SG': 'Singapour', 'MY': 'Malaisie',
      'JM': 'Jamaïque', 'TT': 'Trinité', 'BB': 'Barbade', 'GY': 'Guyana',
      'LR': 'Liberia', 'SL': 'Sierra Leone', 'GM': 'Gambie', 'MW': 'Malawi',
      'SZ': 'Eswatini', 'LS': 'Lesotho', 'FJ': 'Fidji', 'PG': 'Papouasie',
      'RU': 'Russie', 'KZ': 'Kazakhstan', 'BY': 'Biélorussie',
      'ES': 'Espagne', 'MX': 'Mexique', 'AR': 'Argentine', 'CO': 'Colombie',
      'PE': 'Pérou', 'VE': 'Venezuela', 'CL': 'Chili', 'EC': 'Équateur',
      'GT': 'Guatemala', 'CU': 'Cuba', 'BO': 'Bolivie', 'DO': 'Rép. Dominicaine',
      'HN': 'Honduras', 'PY': 'Paraguay', 'SV': 'Salvador', 'NI': 'Nicaragua',
      'CR': 'Costa Rica', 'PA': 'Panama', 'UY': 'Uruguay', 'PR': 'Porto Rico',
      'GQ': 'Guinée équatoriale',
      'BR': 'Brésil', 'PT': 'Portugal', 'MZ': 'Mozambique', 'AO': 'Angola',
      'GW': 'Guinée-Bissau', 'CV': 'Cap-Vert', 'ST': 'São Tomé', 'TL': 'Timor',
      'CN': 'Chine', 'TW': 'Taïwan', 'HK': 'Hong Kong', 'MO': 'Macao',
    };
    return names[countryCode] ?? countryCode;
  }

  static const _arabicCountries = {
    'SA', 'AE', 'QA', 'KW', 'BH', 'OM', 'YE', 'IQ', 'SY', 'JO', 'LB', 'PS',
    'EG', 'SD', 'LY', 'TN', 'DZ', 'MA', 'MR', 'IL', 'SO', 'DJ', 'KM',
  };

  static const _frenchCountries = {
    'FR', 'BE', 'CH', 'MC', 'LU', 'CA', 'SN', 'CI', 'ML', 'BF', 'NE', 'TG',
    'BJ', 'GN', 'GA', 'CG', 'CD', 'CM', 'CF', 'TD', 'MG', 'RW', 'BI', 'DJ',
    'HT', 'GF', 'PF', 'NC', 'RE', 'GP', 'MQ', 'YT',
  };

  static const _englishCountries = {
    'US', 'GB', 'AU', 'NZ', 'IE', 'ZA', 'NG', 'GH', 'KE', 'UG', 'TZ', 'ZM',
    'ZW', 'NA', 'BW', 'IN', 'PK', 'PH', 'SG', 'MY', 'JM', 'TT', 'BB', 'GY',
    'LR', 'SL', 'GM', 'MW', 'SZ', 'LS', 'FJ', 'PG',
  };

  static const _russianCountries = {
    'RU', 'KZ', 'BY',
  };

  static const _chineseCountries = {
    'CN', 'TW', 'HK', 'MO',
  };

  static const _portugueseCountries = {
    'BR', 'PT', 'MZ', 'AO', 'GW', 'CV', 'ST', 'TL',
  };

  static const _spanishCountries = {
    'ES', 'MX', 'AR', 'CO', 'PE', 'VE', 'CL', 'EC', 'GT', 'CU', 'BO', 'DO',
    'HN', 'PY', 'SV', 'NI', 'CR', 'PA', 'UY', 'PR', 'GQ',
  };
}
