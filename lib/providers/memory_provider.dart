import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

class MemoryEntry {
  String id;
  String content;
  String category; // preference, goal, fact, conversation, habit
  DateTime createdAt;
  DateTime lastAccessed;

  MemoryEntry({
    required this.id, required this.content, this.category = 'fact',
    DateTime? createdAt, DateTime? lastAccessed,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastAccessed = lastAccessed ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id, 'content': content, 'category': category,
    'createdAt': createdAt.toIso8601String(), 'lastAccessed': lastAccessed.toIso8601String(),
  };

  factory MemoryEntry.fromJson(Map<String, dynamic> json) => MemoryEntry(
    id: json['id'] ?? '', content: json['content'] ?? '', category: json['category'] ?? 'fact',
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    lastAccessed: DateTime.tryParse(json['lastAccessed'] ?? '') ?? DateTime.now(),
  );

  String get age {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365} an(s)';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} mois';
    if (diff.inDays > 0) return '${diff.inDays} jour(s)';
    if (diff.inHours > 0) return '${diff.inHours} heure(s)';
    return '${diff.inMinutes} min';
  }
}

class MemoryProvider extends ChangeNotifier {
  final StorageService _storage;
  List<MemoryEntry> _memories = [];
  static const _key = 'memories';

  MemoryProvider({required StorageService storage}) : _storage = storage {
    _load();
  }

  List<MemoryEntry> get memories => _memories;
  List<MemoryEntry> get preferences => _memories.where((m) => m.category == 'preference').toList();
  List<MemoryEntry> get goals => _memories.where((m) => m.category == 'goal').toList();
  List<MemoryEntry> get facts => _memories.where((m) => m.category == 'fact').toList();
  List<MemoryEntry> get conversations => _memories.where((m) => m.category == 'conversation').toList();
  List<MemoryEntry> get habits => _memories.where((m) => m.category == 'habit').toList();

  void _load() {
    final data = _storage.prefs.getString(_key);
    if (data != null) {
      try {
        _memories = (jsonDecode(data) as List).map((j) => MemoryEntry.fromJson(j)).toList();
        _memories.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
      } catch (_) {}
    }
  }

  void _save() {
    if (_memories.length > 500) _memories = _memories.sublist(0, 500);
    _storage.prefs.setString(_key, jsonEncode(_memories.map((m) => m.toJson()).toList()));
    notifyListeners();
  }

  void remember(String content, {String category = 'fact'}) {
    AppLogger.info('Mémoire', 'Remember ($category): ${content.length > 60 ? '${content.substring(0, 60)}...' : content}');
    // Check for duplicates (similar content)
    final exists = _memories.any((m) => m.content.trim().toLowerCase() == content.trim().toLowerCase());
    if (exists) {
      // Update lastAccessed
      final existing = _memories.firstWhere((m) => m.content.trim().toLowerCase() == content.trim().toLowerCase());
      existing.lastAccessed = DateTime.now();
    } else {
      _memories.insert(0, MemoryEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content.trim(),
        category: category,
      ));
    }
    _save();
  }

  void rememberPreference(String content) => remember(content, category: 'preference');
  void rememberGoal(String content) => remember(content, category: 'goal');
  void rememberFact(String content) => remember(content, category: 'fact');
  void rememberConversation(String content) => remember(content, category: 'conversation');
  void rememberHabit(String content) => remember(content, category: 'habit');

  void forget(String id) {
    AppLogger.info('Mémoire', 'Forget: $id');
    _memories.removeWhere((m) => m.id == id);
    _save();
  }

  void clearAll() {
    AppLogger.warn('Mémoire', 'clearAll: ${_memories.length} entrées supprimées');
    _memories.clear();
    _save();
  }

  /// Génère un résumé contextuel pour l'IA
  String getContextForAI() {
    if (_memories.isEmpty) return '';

    final prefs = preferences.take(3).map((m) => m.content).join('. ');
    final goals = this.goals.take(3).map((m) => m.content).join('. ');
    final facts = this.facts.take(5).map((m) => m.content).join('. ');
    final habits = this.habits.take(3).map((m) => m.content).join('. ');

    final parts = <String>[];
    if (prefs.isNotEmpty) parts.add('Préférences utilisateur: $prefs');
    if (goals.isNotEmpty) parts.add('Objectifs: $goals');
    if (facts.isNotEmpty) parts.add('Infos: $facts');
    if (habits.isNotEmpty) parts.add('Habitudes: $habits');

    if (parts.isEmpty) return '';
    return '\n\n[CONTEXTE UTILISATEUR - Mémoire long-terme]\n${parts.join('\n')}\nUtilise ces informations pour personnaliser tes réponses.\n';
  }

  /// Extrait automatiquement des insights des conversations
  void extractFromMessage(String userMessage, String aiResponse) {
    // Détection simple de préférences
    if (userMessage.toLowerCase().contains('je préfère') || userMessage.toLowerCase().contains("j'aime")) {
      rememberPreference(userMessage);
    }
    if (userMessage.toLowerCase().contains('mon objectif') || userMessage.toLowerCase().contains('je veux')) {
      rememberGoal(userMessage);
    }
    if (userMessage.toLowerCase().contains('je suis') || userMessage.toLowerCase().contains('mon nom est')) {
      rememberFact(userMessage);
    }
    // Save conversation summary (keep last 20)
    final summary = '${DateTime.now().toIso8601String().substring(0, 10)} - ${userMessage.substring(0, 80)}...';
    rememberConversation(summary);
    // Auto-clean old conversation summaries
    final convs = conversations;
    if (convs.length > 30) {
      for (final c in convs.sublist(30)) {
        _memories.remove(c);
      }
    }
    _save();
  }

  List<MemoryEntry> search(String query) {
    final lower = query.toLowerCase();
    final results = _memories.where((m) => m.content.toLowerCase().contains(lower)).toList();
    AppLogger.info('Mémoire', 'Recherche "$query": ${results.length} résultats');
    return results;
  }
}
