import 'package:flutter/material.dart';

class StatsBanner extends StatelessWidget {
  final int totalNotes;
  final int totalWords;

  const StatsBanner({
    super.key,
    required this.totalNotes,
    required this.totalWords,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.sticky_note_2_outlined,
            label: 'Notas',
            value: '$totalNotes',
          ),
          Container(
            width: 1,
            height: 36,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.2),
          ),
          _StatItem(
            icon: Icons.text_fields,
            label: 'Palabras',
            value: '$totalWords',
          ),
          const Spacer(),
          Icon(Icons.cloud_off,
              size: 18,
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.5)),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
