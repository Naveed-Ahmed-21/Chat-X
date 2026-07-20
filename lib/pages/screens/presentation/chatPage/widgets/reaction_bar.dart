import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  final Map<String, dynamic> reactions;

  const ReactionBar({
    super.key,
    required this.reactions,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox();
    }

    final Map<String, int> grouped = {};

    for (final emoji in reactions.values) {
      grouped[emoji] = (grouped[emoji] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: grouped.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              "${entry.key} ${entry.value}",
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
      ),
    );
  }
}