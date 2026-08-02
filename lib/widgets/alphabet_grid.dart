import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/arabic_letter.dart';

class AlphabetGrid extends StatelessWidget {
  final Function(ArabicLetter) onLetterTap;
  const AlphabetGrid({super.key, required this.onLetterTap});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, childAspectRatio: 0.75, crossAxisSpacing: 10, mainAxisSpacing: 10,
      ),
      itemCount: ArabicLetter.alphabet.length,
      itemBuilder: (context, index) {
        final l = ArabicLetter.alphabet[index];
        return GestureDetector(
          onTap: () => onLetterTap(l),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l.letter, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(l.name, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textLight)),
              ],
            ),
          ),
        );
      },
    );
  }
}
