import 'package:flutter/material.dart';

import '../models/tournament.dart';
import '../utils/format.dart';

/// The one card used by every list and grid of tournaments.
class TournamentCard extends StatelessWidget {
  const TournamentCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onFavourite,
  });

  final Tournament item;
  final VoidCallback onTap;
  final VoidCallback onFavourite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              TournamentAvatar(item: item),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(formatDateTime(item.startsAt), style: text.bodySmall),
                    Text(
                      item.venue,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavourite,
                tooltip: item.favourite ? 'Remove favourite' : 'Favourite',
                color: item.favourite ? scheme.error : null,
                icon: Icon(
                  item.favourite ? Icons.favorite : Icons.favorite_border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Discipline icon with a "FULL" or "N left" badge on a Stack.
class TournamentAvatar extends StatelessWidget {
  const TournamentAvatar({super.key, required this.item});

  final Tournament item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = item.discipline.colorsIn(scheme);
    final (:taken, :free) = item.places;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          child: Icon(item.discipline.icon),
        ),
        if (taken >= item.slots)
          _Badge(
            label: 'FULL',
            background: scheme.error,
            foreground: scheme.onError,
          )
        else if (free <= 5)
          _Badge(
            label: '$free left',
            background: scheme.tertiary,
            foreground: scheme.onTertiary,
          ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Positioned(
      left: -8,
      right: -8,
      bottom: -6,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.surface, width: 1.5),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: foreground),
          ),
        ),
      ),
    );
  }
}
