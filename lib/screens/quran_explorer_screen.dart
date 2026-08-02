import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/favorite.dart';
import '../providers/chat_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/api_service.dart';
import '../widgets/verse_card.dart';
import 'surah_list_screen.dart';

class QuranExplorerScreen extends StatefulWidget {
  const QuranExplorerScreen({super.key});
  @override
  State<QuranExplorerScreen> createState() => _QuranExplorerScreenState();
}

class _QuranExplorerScreenState extends State<QuranExplorerScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;
  String? _error;
  int _tabIndex = 0;

  void _parseAndSetResults(String text) {
    final results = <Map<String, dynamic>>[];
    try {
      final data = jsonDecode(text) as Map<String, dynamic>;
      final items = data['results'] as List? ?? [];
      for (final item in items) {
        results.add({
          'sourate': 'Sourate ${item['surah'] ?? ''}',
          'verset': '${item['ayah'] ?? ''}',
          'texte_arabe': item['text'] ?? '',
          'traduction': item['translation']?.toString() ?? '',
        });
      }
    } catch (_) {
      results.add({'raw': text});
    }
    setState(() => _results = results);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return;
    setState(() { _loading = true; _error = null; });

    try {
      final api = context.read<ApiService>();
      final result = await api.searchQuran(q);
      if (result['data']?['results'] != null) {
        final text = result['data']['results'].toString();
        if (text.contains('ayah_key')) {
          _parseAndSetResults(text);
        } else {
          setState(() { _results = [{'raw': text}]; });
        }
      } else {
        setState(() { _results = [{'raw': result['data']?.toString() ?? 'Aucun résultat'}]; });
      }
    } catch (e) {
      setState(() { _error = 'Erreur de recherche. Vérifiez votre connexion.'; });
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildToggle(),
        Expanded(child: _buildBodyForTab()),
      ],
    );
  }

  Widget _buildBodyForTab() {
    switch (_tabIndex) {
      case 0:
        return _buildBody(); // Search
      case 1:
        return const SurahListScreen(); // Surahs
      case 2:
        return const _HadithTab(); // Hadiths
      default:
        return _buildBody();
    }
  }

  Widget _buildToggle() {
    final tabs = [
      ('Recherche', Icons.search_rounded),
      ('Sourates', Icons.menu_book_rounded),
      ('Hadiths', Icons.format_quote_rounded),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: AppColors.surface,
      child: Row(children: List.generate(3, (i) {
        final sel = _tabIndex == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i > 0 ? 4.0 : 0, right: i < 2 ? 4.0 : 0),
            child: GestureDetector(
              onTap: () => setState(() { _tabIndex = i; }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(tabs[i].$2, size: 15, color: sel ? Colors.white : AppColors.textLight),
                  const SizedBox(width: 4),
                  Text(tabs[i].$1, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: sel ? Colors.white : AppColors.textSecondary)),
                ]),
              ),
            ),
          ),
        );
      })),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF2D2410)]),
        border: const Border(bottom: BorderSide(color: Color(0xFF3D3020), width: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.explore_rounded, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Explorer le Coran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un mot, un thème... (ex: patience, miséricorde)',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.accent.withValues(alpha: 0.5), size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _loading ? null : _search,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    gradient: _loading ? null : const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]),
                    color: _loading ? AppColors.cardBorder : null,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : const Icon(Icons.search_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _results.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(width: 36, height: 36, child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.accent)),
        SizedBox(height: 16),
        Text('Recherche dans le Coran...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ]));
    }

    if (_error != null && _results.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.textLight),
        const SizedBox(height: 12),
        Text(_error!, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _search, child: const Text('Réessayer')),
      ])));
    }

    if (_results.isEmpty) {
      return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.08)),
          child: const Icon(Icons.menu_book_rounded, size: 34, color: AppColors.accent),
        ),
        const SizedBox(height: 16),
        const Text('Explorer le Coran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        const Text('Recherchez un mot-clé ou un thème\npour découvrir les versets correspondants',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        _buildSuggestions(),
      ])));
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: _results.length + (_loading ? 1 : 0),
      itemBuilder: (context, i) {
        if (_loading && i == _results.length) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent))));
        }
        final r = _results[i];
        final fav = context.watch<FavoritesProvider>();
        final sourate = r['sourate']?.toString() ?? '';
        final verset = r['verset']?.toString() ?? '';
        final arabe = r['texte_arabe']?.toString() ?? '';
        final trad = r['traduction']?.toString() ?? r['raw']?.toString() ?? '';

        return VerseCard(
          sourate: sourate.isNotEmpty ? sourate : 'Résultat ${i + 1}',
          verset: verset.isNotEmpty ? verset : '—',
          texteArabe: arabe.isNotEmpty ? arabe : null,
          traduction: trad.isNotEmpty ? trad : null,
          isFavorite: fav.isFavorite(sourate, verset),
          onDeepDive: (sourate.isNotEmpty && verset.isNotEmpty) ? () {
            final ref = '$sourate $verset';
            context.read<ChatProvider>()
              ..setMode(ChatMode.quran)
              ..sendMessage('Fais un Deep Dive du verset $ref. Analyse chaque mot arabe (racine, type, sens), le tafsir, le contexte de révélation, les versets liés, et les leçons à en tirer. Appuie-toi sur les références vérifiées mises à ta disposition.');
          } : null,
          onFavorite: () {
            if (fav.isFavorite(sourate, verset)) {
              final f = fav.favorites.firstWhere((x) => x.sourate == sourate && x.verset == verset, orElse: () => Favorite(id: '', sourate: '', verset: ''));
              if (f.id.isNotEmpty) fav.removeFavorite(f.id);
            } else {
              fav.addFavorite(sourate: sourate, verset: verset, texteArabe: arabe, traduction: trad);
            }
          },
        );
      },
    );
  }

  Widget _buildSuggestions() {
    final tags = ['Patience', 'Miséricorde', 'Paradis', 'Savoir', 'Lumière', 'Pardon', 'Guidance', 'Vérité'];
    return Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: tags.map((t) {
      return GestureDetector(
        onTap: () { _searchCtrl.text = t; _search(); },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.accent.withValues(alpha: 0.15))),
          child: Text(t, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ),
      );
    }).toList());
  }
}

// ─── HADITH TAB ─────────────────────────────────────────────────

class _HadithTab extends StatelessWidget {
  const _HadithTab();

  static const _hadiths = [
    {
      'text': 'Les actions ne valent que par leurs intentions, et chacun n\'aura que selon son intention.',
      'en': 'Actions are only by intentions, and every person shall have only what they intended.',
      'source': 'Sahih al-Bukhari 1, Sahih Muslim 1907',
      'narrator': 'Umar ibn al-Khattab',
      'theme': 'Intention',
    },
    {
      'text': 'Le musulman est celui dont les musulmans sont à l\'abri de sa langue et de sa main.',
      'en': 'A Muslim is one from whose tongue and hand the Muslims are safe.',
      'source': 'Sahih al-Bukhari 10',
      'narrator': 'Abdullah ibn Amr',
      'theme': 'Comportement',
    },
    {
      'text': 'Celui qui croit en Allah et au Jour Dernier, qu\'il dise du bien ou qu\'il se taise.',
      'en': 'Whoever believes in Allah and the Last Day, let him speak good or remain silent.',
      'source': 'Sahih al-Bukhari 6018, Sahih Muslim 47',
      'narrator': 'Abu Hurayra',
      'theme': 'Parole',
    },
    {
      'text': 'La foi compte plus de soixante-dix branches, la meilleure est la parole "La ilaha illa Allah", et la moindre est d\'ôter un obstacle du chemin.',
      'en': 'Faith has over seventy branches, the best of which is the declaration "La ilaha illa Allah", and the lowest is removing a harmful thing from the road.',
      'source': 'Sahih Muslim 35',
      'narrator': 'Abu Hurayra',
      'theme': 'Foi',
    },
    {
      'text': 'Facilitez aux gens et ne leur rendez pas les choses difficiles. Annoncez-leur la bonne nouvelle et ne les faites pas fuir.',
      'en': 'Make things easy for people and do not make them difficult. Give them glad tidings and do not repel them.',
      'source': 'Sahih al-Bukhari 69',
      'narrator': 'Anas ibn Malik',
      'theme': 'Sagesse',
    },
    {
      'text': 'La religion, c\'est la sincérité. Nous dîmes : Envers qui ? Il dit : Envers Allah, Son Livre, Son Messager, les dirigeants des musulmans et leur peuple.',
      'en': 'Religion is sincerity. We said: Towards whom? He said: Towards Allah, His Book, His Messenger, the Muslim leaders, and their people.',
      'source': 'Sahih Muslim 55',
      'narrator': 'Tamim ad-Dari',
      'theme': 'Sincérité',
    },
    {
      'text': 'Le fort n\'est pas celui qui terrasse les autres, mais le fort est celui qui se maîtrise dans la colère.',
      'en': 'The strong man is not the one who wrestles others, but the strong man is the one who controls himself when angry.',
      'source': 'Sahih al-Bukhari 6114, Sahih Muslim 2609',
      'narrator': 'Abu Hurayra',
      'theme': 'Maîtrise de soi',
    },
    {
      'text': 'Allah ne regarde ni vos corps ni vos apparences, mais Il regarde vos cœurs et vos actions.',
      'en': 'Allah does not look at your bodies or your appearances, but He looks at your hearts and your deeds.',
      'source': 'Sahih Muslim 2564',
      'narrator': 'Abu Hurayra',
      'theme': 'Sincérité du cœur',
    },
    {
      'text': 'Aucun d\'entre vous ne sera véritablement croyant jusqu\'à ce qu\'il désire pour son frère ce qu\'il désire pour lui-même.',
      'en': 'None of you will truly believe until he loves for his brother what he loves for himself.',
      'source': 'Sahih al-Bukhari 13, Sahih Muslim 45',
      'narrator': 'Anas ibn Malik',
      'theme': 'Fraternité',
    },
    {
      'text': 'La meilleure aumône est celle donnée pendant le Ramadan.',
      'en': 'The best charity is that given in Ramadan.',
      'source': 'Sunan at-Tirmidhi 663',
      'narrator': 'Anas ibn Malik',
      'theme': 'Charité',
    },
    {
      'text': 'Celui qui ne remercie pas les gens ne remercie pas Allah.',
      'en': 'Whoever does not thank people does not thank Allah.',
      'source': 'Sunan Abi Dawud 4811, Sunan at-Tirmidhi 1954',
      'narrator': 'Abu Hurayra',
      'theme': 'Gratitude',
    },
    {
      'text': 'La recherche de la science est une obligation pour tout musulman.',
      'en': 'Seeking knowledge is an obligation upon every Muslim.',
      'source': 'Sunan Ibn Majah 224',
      'narrator': 'Anas ibn Malik',
      'theme': 'Savoir',
    },
    {
      'text': 'Le croyant qui fréquente les gens et endure leurs torts est meilleur que celui qui ne les fréquente pas.',
      'en': 'The believer who mixes with people and bears their harm is better than the one who does not mix with them.',
      'source': 'Sunan Ibn Majah 4032, Sunan at-Tirmidhi 2507',
      'narrator': 'Ibn Umar',
      'theme': 'Patience sociale',
    },
    {
      'text': 'Celui qui facilite à un endetté, Allah lui facilitera dans ce monde et dans l\'au-delà.',
      'en': 'Whoever makes things easy for someone in difficulty, Allah will make things easy for him in this world and the Hereafter.',
      'source': 'Sahih Muslim 2699',
      'narrator': 'Abu Hurayra',
      'theme': 'Entraide',
    },
    {
      'text': 'La modestie n\'apporte que du bien.',
      'en': 'Modesty brings nothing but good.',
      'source': 'Sahih Muslim 37',
      'narrator': 'Imran ibn Husayn',
      'theme': 'Modestie',
    },
    {
      'text': 'Craignez Allah où que vous soyez, et fais suivre une mauvaise action par une bonne, elle l\'effacera.',
      'en': 'Fear Allah wherever you are, and follow a bad deed with a good one, it will erase it.',
      'source': 'Sunan at-Tirmidhi 1987',
      'narrator': 'Abu Dharr',
      'theme': 'Piété',
    },
    {
      'text': 'Allah a prescrit l\'excellence (ihsan) en toute chose.',
      'en': 'Allah has prescribed excellence (ihsan) in everything.',
      'source': 'Sahih Muslim 1955',
      'narrator': 'Shaddad ibn Aws',
      'theme': 'Excellence',
    },
    {
      'text': 'Le sourire adressé à ton frère est une aumône.',
      'en': 'Your smile to your brother is a charity.',
      'source': 'Sunan at-Tirmidhi 1956',
      'narrator': 'Abu Dharr',
      'theme': 'Charité du sourire',
    },
    {
      'text': 'Les croyants dans leur affection mutuelle sont comme un seul corps : si un membre souffre, tout le corps partage la douleur.',
      'en': 'The believers in their mutual affection are like one body: if one limb suffers, the whole body shares the pain.',
      'source': 'Sahih al-Bukhari 6011, Sahih Muslim 2586',
      'narrator': 'An-Nu\'man ibn Bashir',
      'theme': 'Solidarité',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
      itemCount: _hadiths.length,
      itemBuilder: (context, i) {
        final h = _hadiths[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(h['theme']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent))),
              const Spacer(),
              Text(h['narrator']!, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ]),
            const SizedBox(height: 12),
            Text((lang == 'en' ? h['en'] : h['text'])!, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5, fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.textLight),
              const SizedBox(width: 6),
              Expanded(child: Text(h['source']!, style: const TextStyle(fontSize: 11, color: AppColors.textLight))),
            ]),
          ]),
        );
      },
    );
  }
}
