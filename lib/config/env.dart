/// Configuration de l'application lue depuis l'environnement de build.
///
/// Aucun secret en dur dans le code : les valeurs sont injectées au moment du
/// build via --dart-define=...
///
/// Les clés GeniusPay (GENIUSPAY_API_KEY / GENIUSPAY_API_SECRET) ne vivent
/// plus ici : depuis que le paiement est proxifié côté serveur
/// (server/src/services/geniuspay.js), le secret ne circule plus jamais dans
/// l'app. Elles se configurent dans l'environnement du backend (Render, .env).
///
/// Exemple de build de production :
///   flutter build appbundle --release \
///     --dart-define=API_BASE_URL=https://muslim-ia-api.onrender.com
class Env {
  /// URL du backend (voir ApiService).
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.36.100.91:4000',
  );
}
