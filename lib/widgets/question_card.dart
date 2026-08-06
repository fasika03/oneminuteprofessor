import 'package:flutter/material.dart';

/// Reusable card that displays a question/topic — the quote-styled
/// card used on the Topic Selection screen, factored out so it can
/// be reused anywhere else a topic needs to be shown the same way
/// (e.g. a history detail screen, a "today's challenge" widget).
///
/// Example:
/// ```dart
/// QuestionCard(
///   question: 'What is Blockchain?',
///   difficulty: 'Medium',
/// )
///
/// // Without a difficulty badge:
/// QuestionCard(question: 'What is CRISPR Gene Editing?')
/// ```
class QuestionCard extends StatelessWidget {
  final String question;
  final String? difficulty;
  final VoidCallback? onTap;

  const QuestionCard({
    super.key,
    required this.question,
    this.difficulty,
    this.onTap,
  });

  Color get _difficultyColor {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Hard':
        return Colors.redAccent;
      case 'Custom':
        return Colors.blueAccent;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote, color: Colors.black26, size: 28),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (difficulty != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Difficulty: ',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                Text(
                  difficulty!,
                  style: TextStyle(
                    color: _difficultyColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.bar_chart, size: 18, color: Colors.black38),
              ],
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: card,
    );
  }
}
