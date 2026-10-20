import 'package:flutter/material.dart';

import '../models/tournament.dart';
import '../widgets/empty_state.dart';
import '../widgets/tournament_collection.dart';

/// Tab 2: only the favourites, in date order.
class FavouritesTab extends StatelessWidget {
  const FavouritesTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Tournament> items;
  final ValueChanged<Tournament> onOpen;
  final ValueChanged<Tournament> onFavourite;

  @override
  Widget build(BuildContext context) {
    final favourites = [...items.where((t) => t.favourite)]
      ..sort(compareByDate);

    if (favourites.isEmpty) {
      return const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favourites yet.\nTap the heart on a tournament.',
      );
    }
    return TournamentCollection(
      items: favourites,
      onOpen: onOpen,
      onFavourite: onFavourite,
    );
  }
}
