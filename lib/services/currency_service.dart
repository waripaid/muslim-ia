import 'dart:ui' as ui;

class CurrencyInfo {
  final String code;
  final String symbol;
  final double rateFromXOF; // 1 XOF = rateFromXOF units of this currency
  final String locale;

  const CurrencyInfo(this.code, this.symbol, this.rateFromXOF, this.locale);
}

class CurrencyService {
  static const basePriceXOF = 10500;

  static const _currencies = [
    CurrencyInfo('XOF', 'FCFA', 1.0, 'fr_BJ'),
    CurrencyInfo('EUR', '€', 0.00152, 'fr_FR'),
    CurrencyInfo('USD', '\$', 0.00167, 'en_US'),
    CurrencyInfo('GBP', '£', 0.00130, 'en_GB'),
    CurrencyInfo('CAD', 'CA\$', 0.00225, 'en_CA'),
    CurrencyInfo('XAF', 'FCFA', 1.0, 'fr_CM'),
    CurrencyInfo('MAD', 'DH', 0.0165, 'ar_MA'),
    CurrencyInfo('DZD', 'DA', 0.225, 'ar_DZ'),
    CurrencyInfo('TND', 'DT', 0.0051, 'ar_TN'),
    CurrencyInfo('NGN', '₦', 2.50, 'en_NG'),
    CurrencyInfo('GHS', 'GH₵', 0.025, 'en_GH'),
    CurrencyInfo('KES', 'KSh', 0.25, 'en_KE'),
    CurrencyInfo('ZAR', 'R', 0.030, 'en_ZA'),
    CurrencyInfo('INR', '₹', 0.14, 'en_IN'),
    CurrencyInfo('PKR', 'Rs', 0.46, 'en_PK'),
    CurrencyInfo('BDT', '৳', 0.18, 'bn_BD'),
    CurrencyInfo('IDR', 'Rp', 26.0, 'id_ID'),
    CurrencyInfo('MYR', 'RM', 0.0078, 'ms_MY'),
    CurrencyInfo('SAR', '﷼', 0.0063, 'ar_SA'),
    CurrencyInfo('AED', 'DH', 0.0061, 'ar_AE'),
    CurrencyInfo('TRY', '₺', 0.055, 'tr_TR'),
    CurrencyInfo('BRL', 'R\$', 0.0083, 'pt_BR'),
    CurrencyInfo('AUD', 'A\$', 0.0025, 'en_AU'),
    CurrencyInfo('JPY', '¥', 0.25, 'ja_JP'),
    CurrencyInfo('CNY', '¥', 0.012, 'zh_CN'),
    CurrencyInfo('KRW', '₩', 2.2, 'ko_KR'),
  ];

  static const _countryCurrency = {
    'BJ': 'XOF', 'BF': 'XOF', 'CI': 'XOF', 'SN': 'XOF', 'ML': 'XOF',
    'TG': 'XOF', 'NE': 'XOF', 'GW': 'XOF',
    'CM': 'XAF', 'GA': 'XAF', 'CG': 'XAF', 'TD': 'XAF', 'CF': 'XAF',
    'FR': 'EUR', 'DE': 'EUR', 'ES': 'EUR', 'IT': 'EUR', 'BE': 'EUR',
    'NL': 'EUR', 'PT': 'EUR', 'AT': 'EUR', 'CH': 'EUR', 'LU': 'EUR',
    'US': 'USD', 'GB': 'GBP', 'CA': 'CAD',
    'MA': 'MAD', 'DZ': 'DZD', 'TN': 'TND',
    'NG': 'NGN', 'GH': 'GHS', 'KE': 'KES', 'ZA': 'ZAR',
    'IN': 'INR', 'PK': 'PKR', 'BD': 'BDT',
    'ID': 'IDR', 'MY': 'MYR', 'SA': 'SAR', 'AE': 'AED',
    'TR': 'TRY', 'BR': 'BRL', 'AU': 'AUD',
    'JP': 'JPY', 'CN': 'CNY', 'KR': 'KRW',
  };

  /// Détecte la devise à partir des locales préférées du système.
  ///
  /// Parcourt toutes les locales préférées (pas seulement la première) et
  /// privilégie le code pays pour être plus précis : un utilisateur `fr`
  /// localisé en Côte d'Ivoire (fr_CI) obtient XOF, en France (fr_FR) EUR.
  static CurrencyInfo detectCurrency() {
    try {
      for (final locale in ui.PlatformDispatcher.instance.locales) {
        final info = _match(locale);
        if (info != null) return info;
      }
    } catch (_) {}

    return _currencies[0]; // XOF par défaut
  }

  static CurrencyInfo? _match(ui.Locale locale) {
    // 1) Correspondance exacte locale (ex: fr_BJ → XOF)
    final localeStr = '${locale.languageCode}_${locale.countryCode ?? ''}';
    for (final c in _currencies) {
      if (c.locale == localeStr) return c;
    }

    // 2) Correspondance par code pays (ex: CI → XOF, FR → EUR)
    final country = locale.countryCode?.toUpperCase();
    if (country != null && country.isNotEmpty) {
      final code = _countryCurrency[country];
      if (code != null) {
        for (final c in _currencies) {
          if (c.code == code) return c;
        }
      }
    }

    return null;
  }

  static String formatPrice(CurrencyInfo currency) {
    final amount = (basePriceXOF * currency.rateFromXOF);

    // Formater selon la devise
    if (currency.code == 'XOF' || currency.code == 'XAF') {
      return '10 500 FCFA / mois';
    }
    if (currency.code == 'JPY' || currency.code == 'KRW' || currency.code == 'IDR') {
      return '${amount.round()} ${currency.symbol} / mois';
    }

    final formatted = amount.toStringAsFixed(2);
    return '${currency.symbol}$formatted / mois';
  }

  static int getAmountInCurrency(CurrencyInfo currency) {
    return (basePriceXOF * currency.rateFromXOF).round();
  }

  static String getCurrencyCode() {
    return detectCurrency().code;
  }
}
