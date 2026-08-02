import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/user_progress.dart';

class ProgressSummary extends StatelessWidget {
  final UserProgress progress;
  const ProgressSummary({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: const Color(0xFFC5A028).withValues(alpha: 0.04), blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFC5A028), Color(0xFF9B7B1C)]),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text('Niveau ${progress.levelLabel}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
              ),
              const Spacer(),
              Text('${(progress.studyTimeMinutes / 60).toStringAsFixed(0)}h d\'étude',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _s('${progress.wordsLearned}', '/ ${progress.totalWords}', 'Mots appris', Icons.menu_book_rounded),
              _s('${progress.versesUnderstood}', '', 'Versets', Icons.auto_stories_rounded),
              _s('${progress.quizScore}', 'pts', 'Quiz', Icons.emoji_events_rounded),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.wordProgress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.accent.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
          const SizedBox(height: 8),
          Text('Progression : ${(progress.wordProgress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _s(String value, String suffix, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          if (suffix.isNotEmpty)
            Padding(padding: const EdgeInsets.only(bottom: 2),
                child: Text(suffix, style: const TextStyle(fontSize: 12, color: AppColors.textLight))),
        ]),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
