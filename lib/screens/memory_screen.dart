import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/memory_provider.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});
  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final mp = context.watch<MemoryProvider>();
    final colors = ThemeColors.of(context);
    final memories = _filter.isEmpty ? mp.memories : mp.search(_filter);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Mémoire IA', style: TextStyle(color: AppColors.accent, fontSize: 17)),
        centerTitle: true,
        actions: [
          if (mp.memories.isNotEmpty)
            IconButton(icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 20), onPressed: () => _confirmClear(mp)),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          color: colors.surface,
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _filter = v),
            decoration: InputDecoration(
              hintText: 'Rechercher dans la mémoire...',
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textLight),
              suffixIcon: _filter.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () { _searchCtrl.clear(); setState(() => _filter = ''); }) : null,
              filled: true, fillColor: colors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),

        // Category chips
        if (_filter.isEmpty)
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(children: [
              _chip('Tout', mp.memories.length, null),
              _chip('Préf.', mp.preferences.length, 'preference'),
              _chip('Objectifs', mp.goals.length, 'goal'),
              _chip('Infos', mp.facts.length, 'fact'),
              _chip('Conversations', mp.conversations.length, 'conversation'),
              _chip('Habitudes', mp.habits.length, 'habit'),
            ]),
          ),

        // Memory list
        Expanded(
          child: memories.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.psychology_rounded, size: 48, color: colors.textLight),
                  const SizedBox(height: 12),
                  Text('Aucune mémoire', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Vos conversations seront mémorisées ici', style: TextStyle(fontSize: 12, color: colors.textLight)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 32),
                  itemCount: memories.length,
                  itemBuilder: (context, i) {
                    final m = memories[i];
                    return Dismissible(
                      key: Key(m.id),
                      direction: DismissDirection.endToStart,
                      background: Container(alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), color: AppColors.error.withValues(alpha: 0.1), child: const Icon(Icons.delete_rounded, color: AppColors.error)),
                      onDismissed: (_) => mp.forget(m.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: colors.cardBorder)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: _catColor(m.category).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text(_catLabel(m.category), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _catColor(m.category)))),
                            const Spacer(),
                            Text(m.age, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                          ]),
                          const SizedBox(height: 8),
                          Text(m.content, style: TextStyle(fontSize: 13, color: colors.textPrimary, height: 1.4)),
                        ]),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }

  Widget _chip(String label, int count, String? category) {
    return GestureDetector(
      onTap: () {
        if (category != null) {
          final mp = context.read<MemoryProvider>();
          final filtered = category == 'preference' ? mp.preferences : category == 'goal' ? mp.goals : category == 'fact' ? mp.facts : category == 'conversation' ? mp.conversations : category == 'habit' ? mp.habits : mp.memories;
          _searchCtrl.text = filtered.isNotEmpty ? filtered.first.content.substring(0, 20) : '';
          setState(() => _filter = _searchCtrl.text);
        } else {
          _searchCtrl.clear();
          setState(() => _filter = '');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Text('$label $count', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
      ),
    );
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'preference': return const Color(0xFF8E44AD);
      case 'goal': return const Color(0xFF27AE60);
      case 'fact': return const Color(0xFF2980B9);
      case 'conversation': return const Color(0xFFC5A028);
      case 'habit': return const Color(0xFFE67E22);
      default: return AppColors.textLight;
    }
  }

  String _catLabel(String cat) {
    switch (cat) {
      case 'preference': return 'Préférence';
      case 'goal': return 'Objectif';
      case 'fact': return 'Info';
      case 'conversation': return 'Conversation';
      case 'habit': return 'Habitude';
      default: return 'Autre';
    }
  }

  void _confirmClear(MemoryProvider mp) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Text('Effacer la mémoire ?'),
      content: const Text('Toutes les mémoires seront supprimées. Cette action est irréversible.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
        ElevatedButton(onPressed: () { mp.clearAll(); Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Tout effacer')),
      ],
    ));
  }
}
