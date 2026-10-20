import 'package:flutter/material.dart';

import '../models/tournament.dart';
import 'tournament_card.dart';

/// A list on phones, a grid from 600 px up — decided by the space we get.
class TournamentCollection extends StatelessWidget {
  const TournamentCollection({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Tournament> items;
  final ValueChanged<Tournament> onOpen;
  final ValueChanged<Tournament> onFavourite;

  static const _wide = 600.0;
  static const _maxCell = 360.0;

  @override
  Widget build(BuildContext context) {
    Widget card(int i) => TournamentCard(
      item: items[i],
      onTap: () => onOpen(items[i]),
      onFavourite: () => onFavourite(items[i]),
    );

    return LayoutBuilder(
      builder: (context, constraints) => constraints.maxWidth >= _wide
          ? GridView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: _maxCell,
                childAspectRatio: 2.0,
              ),
              itemCount: items.length,
              itemBuilder: (context, i) => card(i),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
              itemCount: items.length,
              itemBuilder: (context, i) => card(i),
              separatorBuilder: (context, i) => const SizedBox(height: 4),
            ),
    );
  }
}
