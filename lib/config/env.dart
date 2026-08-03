/// Configuration de l'application lue depuis l'environnement de build.
///
/// Aucun secret en dur dans le code : les valeurs sont injectées au moment du
/// build via --dart-define=...
///
/// Exemple de build de production :
///   flutter build appbundle --release \
///     --dart-define=API_BASE_URL=https://muslim-ia-api.onrender.com \
///     --dart-define=GENIUSPAY_API_KEY=pk_live_xxx \
///     --dart-define=GENIUSPAY_API_SECRET=sk_live_xxx
///
/// Remarque : côté client, toute valeur embarquée reste techniquement
/// inspectable. On évite donc d'y mettre des secrets sensibles.
class Env {
  /// URL du backend (voir ApiService).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.36.100.91:4000',
  );

  /// Clé publique GeniusPay (merchant).
  static const geniusPayApiKey = String.fromEnvironment(
    'GENIUSPAY_API_KEY',
    defaultValue: '',
  );

  /// Secret GeniusPay.
  static const geniusPayApiSecret = String.fromEnvironment(
    'GENIUSPAY_API_SECRET',
    defaultValue: '',
  );

  /// URL de la passerelle de paiement GeniusPay.
  static const geniusPayBaseUrl = String.fromEnvironment(
    'GENIUSPAY_BASE_URL',
    defaultValue: 'https://pay.genius.ci/api/v1/merchant',
  );

  /// Mode sandbox (true en test, false en production).
  static const geniusPaySandbox = bool.fromEnvironment(
    'GENIUSPAY_SANDBOX',
    defaultValue: false,
  );
}
