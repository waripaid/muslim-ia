import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../utils/logger.dart';

class ApiService {
  // URL du backend, injectée via --dart-define=API_BASE_URL=...
  static const defaultUrl = Env.apiBaseUrl;

  final String baseUrl;
  bool _isOnline = true;

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? defaultUrl;

  bool get isOnline => _isOnline;

  Future<bool> checkConnectivity() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 3));
      _isOnline = res.statusCode == 200;
    } catch (_) {
      _isOnline = false;
    }
    return _isOnline;
  }

  Future<http.Response> _withRetry(Future<http.Response> Function() request, {int retries = 2}) async {
    for (int i = 0; i <= retries; i++) {
      try {
        final start = DateTime.now();
        final response = await request();
        final duration = DateTime.now().difference(start).inMilliseconds;
        AppLogger.info('API', '${response.request?.method} ${response.request?.url.path} → ${response.statusCode} (${duration}ms)');
        if (response.statusCode < 500) return response;
        if (i == retries) return response;
      } catch (e) {
        AppLogger.warn('API', 'Tentative ${i + 1}/$retries échouée: $e');
        if (i == retries) rethrow;
      }
      await Future.delayed(Duration(milliseconds: 500 * (i + 1)));
    }
    throw Exception('Échec après $retries tentatives');
  }

  /// Recherche directe dans le Coran via MCP Quran
  Future<Map<String, dynamic>> searchQuran(String query) async {
    final res = await _withRetry(() => http.post(
      Uri.parse('$baseUrl/api/ask/search'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    ));
    return jsonDecode(res.body);
  }

  /// Récupère un verset complet (arabe + trad + tafsir) dans la langue voulue
  Future<Map<String, dynamic>> getVerse(String reference, {String lang = 'fr'}) async {
    final res = await _withRetry(() => http.get(
      Uri.parse('$baseUrl/api/ask/verse/$reference?lang=$lang'),
    ));
    return jsonDecode(res.body);
  }

  /// Transcrit un audio (base64) en texte
  Future<Map<String, dynamic>> transcribeAudio(String audioBase64, {String? language}) async {
    final res = await _withRetry(() => http.post(
      Uri.parse('$baseUrl/api/audio/transcribe'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'audio': audioBase64, 'language': language}),
    ).timeout(const Duration(seconds: 120)));
    return jsonDecode(res.body);
  }

  /// Vérifie la prononciation
  Future<Map<String, dynamic>> checkPronunciation(String audioBase64, String expected, {String language = 'ar'}) async {
    final res = await _withRetry(() => http.post(
      Uri.parse('$baseUrl/api/audio/pronounce'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'audio': audioBase64, 'expected': expected, 'language': language}),
    ));
    return jsonDecode(res.body);
  }

  /// Synthèse vocale via Mistral Voxtral TTS (retourne l'audio en base64)
  Future<Map<String, dynamic>> textToSpeech(String text, {String? voiceId, String? language}) async {
    final res = await _withRetry(() => http.post(
      Uri.parse('$baseUrl/api/audio/tts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'text': text,
        if (language != null) 'language': language,
        if (voiceId != null) 'voice_id': voiceId,
      }),
    ));
    return jsonDecode(res.body);
  }

  /// Vision : analyse une image via Groq
  Future<Map<String, dynamic>> analyzeImage(String imageBase64, {String? context}) async {
    final res = await _withRetry(() => http.post(
      Uri.parse('$baseUrl/api/vision/analyze'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'image': imageBase64, 'context': context}),
    ));
    return jsonDecode(res.body);
  }

  /// Chat en streaming (SSE)
  Stream<String> askQuestionStream(String question, {String mode = 'general', List<Map<String, String>>? history}) async* {
    AppLogger.stream('API', 'Début requête stream: mode=$mode');
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('$baseUrl/api/ask/stream'));
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'question': question,
        'mode': mode,
        // Jamais plus que les 10 derniers échanges : le prompt reste léger et
        // on reste sous la limite serveur même après 100 messages.
        'history': (history ?? []).length > 10 ? history!.sublist(history.length - 10) : (history ?? []),
      });

      // Timeout de connexion : 60 s pour couvrir le cold start de Render
      // (~25-30 s) sans pénaliser les requêtes chaudes.
      final response = await client.send(request).timeout(const Duration(seconds: 60));
      final stream = response.stream.transform(utf8.decoder);

      AppLogger.stream('API', 'Connexion stream établie (${response.statusCode})');

      // Détection de stall : si aucun octet n'arrive pendant 60 s (réseau
      // coupé, serveur planté en cours de génération), on abandonne. Le
      // timeout est réarmé à chaque chunk, donc une génération longue mais
      // active n'est jamais coupée.
      await for (final chunk in stream.timeout(const Duration(seconds: 60))) {
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ') && !line.contains('[DONE]')) {
            final data = line.substring(6).trim();
            try {
              final json = jsonDecode(data);
              if (json['truncated'] == true) {
                yield 'TRUNCATED';
              }
              if (json['text'] != null) {
                yield json['text'];
              }
              if (json['error'] != null) {
                AppLogger.error('API', 'Erreur stream: ${json['error']}');
                yield 'ERROR: ${json['error']}';
              }
            } catch (_) {}
          }
        }
      }
    } catch (e) {
      AppLogger.error('API', 'Erreur connexion stream', e);
      yield 'ERROR: $e';
    } finally {
      // Libère toujours les sockets, même en cas d'erreur ou d'abandon.
      client.close();
    }
  }

  Future<Map<String, dynamic>> askQuestion({
    required String question,
    String mode = 'general',
    List<Map<String, String>>? history,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ask'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'question': question,
        'mode': mode,
        'history': (history ?? []).length > 10 ? history!.sublist(history.length - 10) : (history ?? []),
        'userId': userId,
      }),
    ).timeout(const Duration(seconds: 90));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        'Erreur ${response.statusCode}',
        jsonDecode(response.body)['error'] ?? 'Erreur inconnue',
      );
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String userId, {int limit = 50}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ask/history/$userId?limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }
    return [];
  }

  Future<Map<String, dynamic>> addFavorite({
    required String userId,
    required String sourate,
    required String verset,
    String? texteArabe,
    String? traduction,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ask/favorites'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'sourate': sourate,
        'verset': verset,
        'texte_arabe': texteArabe,
        'traduction': traduction,
        'notes': notes,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ask/favorites/$userId'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    }
    return [];
  }

  Future<void> removeFavorite(String id) async {
    await http.delete(Uri.parse('$baseUrl/api/ask/favorites/$id'));
  }

  Future<void> syncUser(String uid, {String? email, String? displayName}) async {
    await http.post(
      Uri.parse('$baseUrl/api/user/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'email': email,
        'displayName': displayName,
      }),
    );
  }

  Future<Map<String, dynamic>> updateProgress(
    String userId,
    Map<String, dynamic> progress,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/progress/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, ...progress}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getProgress(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/progress/$userId'),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getDailyLesson({String? userId, int? day}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/progress/daily-lesson'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'day': day}),
    );
    return jsonDecode(response.body);
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Envoie l'email de vérification personnalisé (logo de l'app) via le backend.
  /// Retourne true si le backend l'a envoyé, false sinon (fallback Firebase).
  Future<bool> sendVerificationEmail(String idToken) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/send-verification-email'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken}),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      AppLogger.warn('API', 'sendVerificationEmail → ${response.statusCode}: ${response.body}');
      return false;
    } catch (e) {
      AppLogger.warn('API', 'sendVerificationEmail indisponible: $e');
      return false;
    }
  }

  /// Crée un paiement GeniusPay via le backend.
  /// Le secret GeniusPay ne circule jamais dans l'app : seul le serveur l'utilise.
  Future<Map<String, dynamic>> createCheckout({
    required int amount,
    required String email,
    String? customerName,
    required String idToken,
  }) async {
    final response = await _withRetry(() => http.post(
      Uri.parse('$baseUrl/api/payments/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'idToken': idToken,
        'amount': amount,
        'email': email,
        if (customerName != null && customerName.isNotEmpty) 'customerName': customerName,
      }),
    ));
    return jsonDecode(response.body);
  }

  /// Interroge le statut d'un paiement auprès du backend.
  Future<Map<String, dynamic>> getPaymentStatus({
    required String reference,
    required String idToken,
  }) async {
    final response = await _withRetry(() => http.post(
      Uri.parse('$baseUrl/api/payments/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken, 'reference': reference}),
    ));
    return jsonDecode(response.body);
  }
}

class ApiException implements Exception {
  final String status;
  final String message;

  ApiException(this.status, this.message);

  @override
  String toString() => 'ApiException: $status - $message';
}
