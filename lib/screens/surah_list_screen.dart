import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class SurahListScreen extends StatefulWidget {
  const SurahListScreen({super.key});
  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  Map<String, dynamic>? _selectedSurah;
  bool _loadingSurah = false;
  final _filterCtrl = TextEditingController();
  String _filter = '';

  List<Map> get _filteredSurahs {
    if (_filter.isEmpty) return _surahs;
    final lower = _filter.toLowerCase();
    return _surahs.where((s) {
      return '${s['n']}'.contains(lower) ||
          '${s['fr']}'.toLowerCase().contains(lower) ||
          '${s['ar']}'.contains(_filter);
    }).toList();
  }

  static const _surahs = [
    {'n': 1, 'ar': 'الفاتحة', 'fr': 'Al-Fatiha', 'type': 'Mecquoise', 'verses': 7},
    {'n': 2, 'ar': 'البقرة', 'fr': 'Al-Baqara', 'type': 'Médinoise', 'verses': 286},
    {'n': 3, 'ar': 'آل عمران', 'fr': 'Al-Imran', 'type': 'Médinoise', 'verses': 200},
    {'n': 4, 'ar': 'النساء', 'fr': 'An-Nisa', 'type': 'Médinoise', 'verses': 176},
    {'n': 5, 'ar': 'المائدة', 'fr': 'Al-Ma\'ida', 'type': 'Médinoise', 'verses': 120},
    {'n': 6, 'ar': 'الأنعام', 'fr': 'Al-An\'am', 'type': 'Mecquoise', 'verses': 165},
    {'n': 7, 'ar': 'الأعراف', 'fr': 'Al-A\'raf', 'type': 'Mecquoise', 'verses': 206},
    {'n': 8, 'ar': 'الأنفال', 'fr': 'Al-Anfal', 'type': 'Médinoise', 'verses': 75},
    {'n': 9, 'ar': 'التوبة', 'fr': 'At-Tawba', 'type': 'Médinoise', 'verses': 129},
    {'n': 10, 'ar': 'يونس', 'fr': 'Yunus', 'type': 'Mecquoise', 'verses': 109},
    {'n': 11, 'ar': 'هود', 'fr': 'Hud', 'type': 'Mecquoise', 'verses': 123},
    {'n': 12, 'ar': 'يوسف', 'fr': 'Yusuf', 'type': 'Mecquoise', 'verses': 111},
    {'n': 13, 'ar': 'الرعد', 'fr': 'Ar-Ra\'d', 'type': 'Médinoise', 'verses': 43},
    {'n': 14, 'ar': 'إبراهيم', 'fr': 'Ibrahim', 'type': 'Mecquoise', 'verses': 52},
    {'n': 15, 'ar': 'الحجر', 'fr': 'Al-Hijr', 'type': 'Mecquoise', 'verses': 99},
    {'n': 16, 'ar': 'النحل', 'fr': 'An-Nahl', 'type': 'Mecquoise', 'verses': 128},
    {'n': 17, 'ar': 'الإسراء', 'fr': 'Al-Isra', 'type': 'Mecquoise', 'verses': 111},
    {'n': 18, 'ar': 'الكهف', 'fr': 'Al-Kahf', 'type': 'Mecquoise', 'verses': 110},
    {'n': 19, 'ar': 'مريم', 'fr': 'Maryam', 'type': 'Mecquoise', 'verses': 98},
    {'n': 20, 'ar': 'طه', 'fr': 'Ta-Ha', 'type': 'Mecquoise', 'verses': 135},
    {'n': 21, 'ar': 'الأنبياء', 'fr': 'Al-Anbiya', 'type': 'Mecquoise', 'verses': 112},
    {'n': 22, 'ar': 'الحج', 'fr': 'Al-Hajj', 'type': 'Médinoise', 'verses': 78},
    {'n': 23, 'ar': 'المؤمنون', 'fr': 'Al-Mu\'minun', 'type': 'Mecquoise', 'verses': 118},
    {'n': 24, 'ar': 'النور', 'fr': 'An-Nur', 'type': 'Médinoise', 'verses': 64},
    {'n': 25, 'ar': 'الفرقان', 'fr': 'Al-Furqan', 'type': 'Mecquoise', 'verses': 77},
    {'n': 26, 'ar': 'الشعراء', 'fr': 'Ash-Shu\'ara', 'type': 'Mecquoise', 'verses': 227},
    {'n': 27, 'ar': 'النمل', 'fr': 'An-Naml', 'type': 'Mecquoise', 'verses': 93},
    {'n': 28, 'ar': 'القصص', 'fr': 'Al-Qasas', 'type': 'Mecquoise', 'verses': 88},
    {'n': 29, 'ar': 'العنكبوت', 'fr': 'Al-Ankabut', 'type': 'Mecquoise', 'verses': 69},
    {'n': 30, 'ar': 'الروم', 'fr': 'Ar-Rum', 'type': 'Mecquoise', 'verses': 60},
    {'n': 31, 'ar': 'لقمان', 'fr': 'Luqman', 'type': 'Mecquoise', 'verses': 34},
    {'n': 32, 'ar': 'السجدة', 'fr': 'As-Sajda', 'type': 'Mecquoise', 'verses': 30},
    {'n': 33, 'ar': 'الأحزاب', 'fr': 'Al-Ahzab', 'type': 'Médinoise', 'verses': 73},
    {'n': 34, 'ar': 'سبأ', 'fr': 'Saba', 'type': 'Mecquoise', 'verses': 54},
    {'n': 35, 'ar': 'فاطر', 'fr': 'Fatir', 'type': 'Mecquoise', 'verses': 45},
    {'n': 36, 'ar': 'يس', 'fr': 'Ya-Sin', 'type': 'Mecquoise', 'verses': 83},
    {'n': 37, 'ar': 'الصافات', 'fr': 'As-Saffat', 'type': 'Mecquoise', 'verses': 182},
    {'n': 38, 'ar': 'ص', 'fr': 'Sad', 'type': 'Mecquoise', 'verses': 88},
    {'n': 39, 'ar': 'الزمر', 'fr': 'Az-Zumar', 'type': 'Mecquoise', 'verses': 75},
    {'n': 40, 'ar': 'غافر', 'fr': 'Ghafir', 'type': 'Mecquoise', 'verses': 85},
    {'n': 41, 'ar': 'فصلت', 'fr': 'Fussilat', 'type': 'Mecquoise', 'verses': 54},
    {'n': 42, 'ar': 'الشورى', 'fr': 'Ash-Shura', 'type': 'Mecquoise', 'verses': 53},
    {'n': 43, 'ar': 'الزخرف', 'fr': 'Az-Zukhruf', 'type': 'Mecquoise', 'verses': 89},
    {'n': 44, 'ar': 'الدخان', 'fr': 'Ad-Dukhan', 'type': 'Mecquoise', 'verses': 59},
    {'n': 45, 'ar': 'الجاثية', 'fr': 'Al-Jathiya', 'type': 'Mecquoise', 'verses': 37},
    {'n': 46, 'ar': 'الأحقاف', 'fr': 'Al-Ahqaf', 'type': 'Mecquoise', 'verses': 35},
    {'n': 47, 'ar': 'محمد', 'fr': 'Muhammad', 'type': 'Médinoise', 'verses': 38},
    {'n': 48, 'ar': 'الفتح', 'fr': 'Al-Fath', 'type': 'Médinoise', 'verses': 29},
    {'n': 49, 'ar': 'الحجرات', 'fr': 'Al-Hujurat', 'type': 'Médinoise', 'verses': 18},
    {'n': 50, 'ar': 'ق', 'fr': 'Qaf', 'type': 'Mecquoise', 'verses': 45},
    {'n': 51, 'ar': 'الذاريات', 'fr': 'Adh-Dhariyat', 'type': 'Mecquoise', 'verses': 60},
    {'n': 52, 'ar': 'الطور', 'fr': 'At-Tur', 'type': 'Mecquoise', 'verses': 49},
    {'n': 53, 'ar': 'النجم', 'fr': 'An-Najm', 'type': 'Mecquoise', 'verses': 62},
    {'n': 54, 'ar': 'القمر', 'fr': 'Al-Qamar', 'type': 'Mecquoise', 'verses': 55},
    {'n': 55, 'ar': 'الرحمن', 'fr': 'Ar-Rahman', 'type': 'Médinoise', 'verses': 78},
    {'n': 56, 'ar': 'الواقعة', 'fr': 'Al-Waqi\'a', 'type': 'Mecquoise', 'verses': 96},
    {'n': 57, 'ar': 'الحديد', 'fr': 'Al-Hadid', 'type': 'Médinoise', 'verses': 29},
    {'n': 58, 'ar': 'المجادلة', 'fr': 'Al-Mujadila', 'type': 'Médinoise', 'verses': 22},
    {'n': 59, 'ar': 'الحشر', 'fr': 'Al-Hashr', 'type': 'Médinoise', 'verses': 24},
    {'n': 60, 'ar': 'الممتحنة', 'fr': 'Al-Mumtahana', 'type': 'Médinoise', 'verses': 13},
    {'n': 61, 'ar': 'الصف', 'fr': 'As-Saff', 'type': 'Médinoise', 'verses': 14},
    {'n': 62, 'ar': 'الجمعة', 'fr': 'Al-Jumu\'a', 'type': 'Médinoise', 'verses': 11},
    {'n': 63, 'ar': 'المنافقون', 'fr': 'Al-Munafiqun', 'type': 'Médinoise', 'verses': 11},
    {'n': 64, 'ar': 'التغابن', 'fr': 'At-Taghabun', 'type': 'Médinoise', 'verses': 18},
    {'n': 65, 'ar': 'الطلاق', 'fr': 'At-Talaq', 'type': 'Médinoise', 'verses': 12},
    {'n': 66, 'ar': 'التحريم', 'fr': 'At-Tahrim', 'type': 'Médinoise', 'verses': 12},
    {'n': 67, 'ar': 'الملك', 'fr': 'Al-Mulk', 'type': 'Mecquoise', 'verses': 30},
    {'n': 68, 'ar': 'القلم', 'fr': 'Al-Qalam', 'type': 'Mecquoise', 'verses': 52},
    {'n': 69, 'ar': 'الحاقة', 'fr': 'Al-Haqqa', 'type': 'Mecquoise', 'verses': 52},
    {'n': 70, 'ar': 'المعارج', 'fr': 'Al-Ma\'arij', 'type': 'Mecquoise', 'verses': 44},
    {'n': 71, 'ar': 'نوح', 'fr': 'Nuh', 'type': 'Mecquoise', 'verses': 28},
    {'n': 72, 'ar': 'الجن', 'fr': 'Al-Jinn', 'type': 'Mecquoise', 'verses': 28},
    {'n': 73, 'ar': 'المزمل', 'fr': 'Al-Muzzammil', 'type': 'Mecquoise', 'verses': 20},
    {'n': 74, 'ar': 'المدثر', 'fr': 'Al-Muddaththir', 'type': 'Mecquoise', 'verses': 56},
    {'n': 75, 'ar': 'القيامة', 'fr': 'Al-Qiyama', 'type': 'Mecquoise', 'verses': 40},
    {'n': 76, 'ar': 'الإنسان', 'fr': 'Al-Insan', 'type': 'Médinoise', 'verses': 31},
    {'n': 77, 'ar': 'المرسلات', 'fr': 'Al-Mursalat', 'type': 'Mecquoise', 'verses': 50},
    {'n': 78, 'ar': 'النبأ', 'fr': 'An-Naba', 'type': 'Mecquoise', 'verses': 40},
    {'n': 79, 'ar': 'النازعات', 'fr': 'An-Nazi\'at', 'type': 'Mecquoise', 'verses': 46},
    {'n': 80, 'ar': 'عبس', 'fr': 'Abasa', 'type': 'Mecquoise', 'verses': 42},
    {'n': 81, 'ar': 'التكوير', 'fr': 'At-Takwir', 'type': 'Mecquoise', 'verses': 29},
    {'n': 82, 'ar': 'الإنفطار', 'fr': 'Al-Infitar', 'type': 'Mecquoise', 'verses': 19},
    {'n': 83, 'ar': 'المطففين', 'fr': 'Al-Mutaffifin', 'type': 'Mecquoise', 'verses': 36},
    {'n': 84, 'ar': 'الإنشقاق', 'fr': 'Al-Inshiqaq', 'type': 'Mecquoise', 'verses': 25},
    {'n': 85, 'ar': 'البروج', 'fr': 'Al-Buruj', 'type': 'Mecquoise', 'verses': 22},
    {'n': 86, 'ar': 'الطارق', 'fr': 'At-Tariq', 'type': 'Mecquoise', 'verses': 17},
    {'n': 87, 'ar': 'الأعلى', 'fr': 'Al-A\'la', 'type': 'Mecquoise', 'verses': 19},
    {'n': 88, 'ar': 'الغاشية', 'fr': 'Al-Ghashiya', 'type': 'Mecquoise', 'verses': 26},
    {'n': 89, 'ar': 'الفجر', 'fr': 'Al-Fajr', 'type': 'Mecquoise', 'verses': 30},
    {'n': 90, 'ar': 'البلد', 'fr': 'Al-Balad', 'type': 'Mecquoise', 'verses': 20},
    {'n': 91, 'ar': 'الشمس', 'fr': 'Ash-Shams', 'type': 'Mecquoise', 'verses': 15},
    {'n': 92, 'ar': 'الليل', 'fr': 'Al-Layl', 'type': 'Mecquoise', 'verses': 21},
    {'n': 93, 'ar': 'الضحى', 'fr': 'Ad-Duha', 'type': 'Mecquoise', 'verses': 11},
    {'n': 94, 'ar': 'الشرح', 'fr': 'Ash-Sharh', 'type': 'Mecquoise', 'verses': 8},
    {'n': 95, 'ar': 'التين', 'fr': 'At-Tin', 'type': 'Mecquoise', 'verses': 8},
    {'n': 96, 'ar': 'العلق', 'fr': 'Al-Alaq', 'type': 'Mecquoise', 'verses': 19},
    {'n': 97, 'ar': 'القدر', 'fr': 'Al-Qadr', 'type': 'Mecquoise', 'verses': 5},
    {'n': 98, 'ar': 'البينة', 'fr': 'Al-Bayyina', 'type': 'Médinoise', 'verses': 8},
    {'n': 99, 'ar': 'الزلزلة', 'fr': 'Az-Zalzala', 'type': 'Médinoise', 'verses': 8},
    {'n': 100, 'ar': 'العاديات', 'fr': 'Al-Adiyat', 'type': 'Mecquoise', 'verses': 11},
    {'n': 101, 'ar': 'القارعة', 'fr': 'Al-Qari\'a', 'type': 'Mecquoise', 'verses': 11},
    {'n': 102, 'ar': 'التكاثر', 'fr': 'At-Takathur', 'type': 'Mecquoise', 'verses': 8},
    {'n': 103, 'ar': 'العصر', 'fr': 'Al-Asr', 'type': 'Mecquoise', 'verses': 3},
    {'n': 104, 'ar': 'الهمزة', 'fr': 'Al-Humaza', 'type': 'Mecquoise', 'verses': 9},
    {'n': 105, 'ar': 'الفيل', 'fr': 'Al-Fil', 'type': 'Mecquoise', 'verses': 5},
    {'n': 106, 'ar': 'قريش', 'fr': 'Quraysh', 'type': 'Mecquoise', 'verses': 4},
    {'n': 107, 'ar': 'الماعون', 'fr': 'Al-Ma\'un', 'type': 'Mecquoise', 'verses': 7},
    {'n': 108, 'ar': 'الكوثر', 'fr': 'Al-Kawthar', 'type': 'Mecquoise', 'verses': 3},
    {'n': 109, 'ar': 'الكافرون', 'fr': 'Al-Kafirun', 'type': 'Mecquoise', 'verses': 6},
    {'n': 110, 'ar': 'النصر', 'fr': 'An-Nasr', 'type': 'Médinoise', 'verses': 3},
    {'n': 111, 'ar': 'المسد', 'fr': 'Al-Masad', 'type': 'Mecquoise', 'verses': 5},
    {'n': 112, 'ar': 'الإخلاص', 'fr': 'Al-Ikhlas', 'type': 'Mecquoise', 'verses': 4},
    {'n': 113, 'ar': 'الفلق', 'fr': 'Al-Falaq', 'type': 'Mecquoise', 'verses': 5},
    {'n': 114, 'ar': 'الناس', 'fr': 'An-Nas', 'type': 'Mecquoise', 'verses': 6},
  ];

  Future<void> _loadSurah(int index) async {
    setState(() { _loadingSurah = true; _selectedSurah = null; });
    final s = _surahs[index];
    try {
      final api = context.read<ApiService>();
      final result = await api.getVerse('${s['n']}:1', lang: Localizations.localeOf(context).languageCode);      setState(() {
        _selectedSurah = {
          ...s,
          'firstVerse': result['data']?['arabe'] ?? '',
          'translation': result['data']?['traduction'] ?? '',
        };
      });
    } catch (_) {
      setState(() { _selectedSurah = {...s, 'firstVerse': 'Chargement impossible', 'translation': ''}; });
    }
    setState(() => _loadingSurah = false);
  }

  void _openDetail(Map s) {
    final l10n = AppLocalizations.of(context);
    final surahType = s['type'].toString().contains('Méc') ? l10n.surahMeccan : l10n.surahMedinan;
    showModalBottomSheet(context: context, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) {
      return Container(padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFFE8C547)]), borderRadius: BorderRadius.circular(14)),
              child: Center(child: Text('${s['n']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s['fr'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Text(s['ar'], style: const TextStyle(fontSize: 16, color: AppColors.textSecondary)),
            ])),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _chip(l10n.surahVersets(s['verses']), Icons.format_list_numbered_rounded),
            const SizedBox(width: 8),
            _chip(surahType, Icons.location_on_rounded),
          ]),
          const SizedBox(height: 16),
          if (_loadingSurah)
            const Center(child: CircularProgressIndicator(color: AppColors.accent))
          else if (_selectedSurah != null) ...[
            if (_selectedSurah!['firstVerse'] != null) ...[
              Text(_selectedSurah!['firstVerse']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16, height: 1.7, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(_selectedSurah!['translation'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
            ],
          ],
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // Switch to chat tab and send request
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 18),
            label: Text(l10n.surahExplain(s['fr']), style: const TextStyle(fontWeight: FontWeight.w700)),
          )),
        ]),
      );
    });
  }

  Widget _chip(String label, IconData icon) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: AppColors.accent), const SizedBox(width: 4), Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent))]));
  }

  @override
  Widget build(BuildContext context) {
    final surahs = _filteredSurahs;
    return Column(children: [
      _buildSearchBar(),
      Expanded(child: _buildSurahList(surahs)),
    ]);
  }

  Widget _buildSearchBar() {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      color: AppColors.surface,
      child: TextField(
        controller: _filterCtrl,
        onChanged: (v) => setState(() => _filter = v),
        decoration: InputDecoration(
          hintText: l10n.surahFilter,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.textLight),
          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textLight),
          suffixIcon: _filter.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear_rounded, size: 18), onPressed: () { _filterCtrl.clear(); setState(() => _filter = ''); })
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          filled: true, fillColor: AppColors.background,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSurahList(List<Map> surahs) {
    final l10n = AppLocalizations.of(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
      itemCount: surahs.length,
      itemBuilder: (ctx, i) {
        final s = surahs[i];
        final surahType = s['type'].toString().contains('Méc') ? l10n.surahMeccan : l10n.surahMedinan;
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('${s['n']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${s['fr']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              Text('${s['ar']} • ${l10n.surahVersets(s['verses'])} • $surahType', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ])),
            GestureDetector(
              onTap: () { _loadSurah(i); _openDetail(s); },
              child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent)),
            ),
          ]),
        );
      },
    );
  }
}
