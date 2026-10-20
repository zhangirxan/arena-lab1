import 'package:flutter/material.dart';

import '../models/discipline.dart';
import '../models/tournament.dart';
import '../widgets/empty_state.dart';
import '../widgets/tournament_collection.dart';

/// Tab 1: search, discipline chips, the past filter and the list.
class TournamentsTab extends StatefulWidget {
  const TournamentsTab({
    super.key,
    required this.items,
    required this.onOpen,
    required this.onFavourite,
  });

  final List<Tournament> items;
  final ValueChanged<Tournament> onOpen;
  final ValueChanged<Tournament> onFavourite;

  @override
  State<TournamentsTab> createState() => _TournamentsTabState();
}

class _TournamentsTabState extends State<TournamentsTab> {
  final _search = TextEditingController();
  Discipline? _discipline;
  bool _showPast = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool _matches(Tournament t, String query) =>
      (_discipline == null || t.discipline == _discipline) &&
      (_showPast || !t.isPast) &&
      (query.isEmpty || t.title.toLowerCase().contains(query));

  void _clearSearch() {
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final visible = [...widget.items.where((t) => _matches(t, query))]
      ..sort(compareByDate);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
          child: TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search tournaments',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _search.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: _discipline == null,
                onSelected: (_) => setState(() => _discipline = null),
              ),
              for (final d in Discipline.values)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    avatar: Icon(d.icon),
                    label: Text(d.label),
                    selected: _discipline == d,
                    onSelected: (_) => setState(() => _discipline = d),
                  ),
                ),
              const SizedBox(width: 16),
              FilterChip(
                label: const Text('Past'),
                selected: _showPast,
                onSelected: (v) => setState(() => _showPast = v),
              ),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'No tournaments match',
                  actionLabel: query.isEmpty ? null : 'Clear search',
                  onAction: _clearSearch,
                )
              : TournamentCollection(
                  items: visible,
                  onOpen: widget.onOpen,
                  onFavourite: widget.onFavourite,
                ),
        ),
      ],
    );
  }
}
