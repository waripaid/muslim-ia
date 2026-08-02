class ChatMessage {
  final String id;
  String content;
  final ChatRole role;
  final DateTime timestamp;
  final List<QuranSource>? sources;
  final String? imagePath;
  String? audioPath;
  bool isIncomplete;

  ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.sources,
    this.imagePath,
    this.audioPath,
    this.isIncomplete = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      content: json['content'] ?? '',
      role: json['role'] == 'user' ? ChatRole.user : ChatRole.assistant,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      sources: json['sources'] != null
          ? (json['sources'] as List).map((s) => QuranSource.fromJson(s)).toList()
          : null,
      imagePath: json['imagePath'],
      audioPath: json['audioPath'],
      isIncomplete: json['isIncomplete'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'role': role == ChatRole.user ? 'user' : 'assistant',
        'timestamp': timestamp.toIso8601String(),
        if (sources != null)
          'sources': sources!.map((s) => s.toJson()).toList(),
        if (imagePath != null) 'imagePath': imagePath,
        if (audioPath != null) 'audioPath': audioPath,
        if (isIncomplete) 'isIncomplete': true,
      };
}

enum ChatRole { user, assistant }

class QuranSource {
  final String sourate;
  final String verset;
  final String? texteArabe;
  final String? traduction;

  QuranSource({
    required this.sourate,
    required this.verset,
    this.texteArabe,
    this.traduction,
  });

  factory QuranSource.fromJson(Map<String, dynamic> json) {
    return QuranSource(
      sourate: json['sourate'] ?? json['surah'] ?? '',
      verset: json['verset']?.toString() ?? json['ayah']?.toString() ?? '',
      texteArabe: json['texte_arabe'] ?? json['arabic_text'],
      traduction: json['traduction'] ?? json['translation'],
    );
  }

  Map<String, dynamic> toJson() => {
        'sourate': sourate,
        'verset': verset,
        if (texteArabe != null) 'texte_arabe': texteArabe,
        if (traduction != null) 'traduction': traduction,
      };

  String get reference => '$sourate $verset';
}
