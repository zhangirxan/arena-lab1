import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/profile.dart';
import '../models/tournament.dart';
import '../routes.dart';
import '../tabs/favourites_tab.dart';
import '../tabs/profile_tab.dart';
import '../tabs/tournaments_tab.dart';

/// Holds the list and the profile; the three tabs only get them passed down.
class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  static const _profileTab = 2;
  static const _titles = ['Tournaments', 'Favourites', 'Profile'];

  List<Tournament> _items = seedTournaments();
  Profile _profile = const Profile.empty();
  int _tab = 0;

  void _selectTab(int index) => setState(() => _tab = index);

  void _save(Tournament t) => setState(() {
    _items = _items.any((x) => x.id == t.id)
        ? [for (final x in _items) x.id == t.id ? t : x]
        : [..._items, t];
  });

  void _delete(Tournament t) => setState(
    () => _items = [
      for (final x in _items)
        if (x.id != t.id) x,
    ],
  );

  void _toggleFavourite(Tournament t) =>
      _save(t.copyWith(favourite: !t.favourite));

  void _setProfile(Profile p) => setState(() => _profile = p);

  void _open(Tournament t) => Navigator.of(context).pushNamed(
    Routes.detail,
    arguments: DetailArgs(
      item: t,
      profile: _profile,
      onChanged: _save,
      onDelete: _delete,
      onOpenProfile: () => _selectTab(_profileTab),
    ),
  );

  Future<void> _create() async {
    final created = await Navigator.of(context)
        .pushNamed<Tournament>(Routes.form, arguments: const FormArgs());
    if (created == null || !mounted) return;
    setState(() => _items = [..._items, created]);
  }

  void _about() {
    Navigator.of(context).pop(); // close the drawer
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Arena'),
        content: const Text(
          'Tournaments at the KBTU student gaming club.\n'
          'Lab 1, Mobile Development.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _reset() async {
    Navigator.of(context).pop(); // close the drawer
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset data?'),
        content: const Text(
          'All tournaments go back to the seed and your profile is cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() {
      _items = seedTournaments();
      _profile = const Profile.empty();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_tab])),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Arena',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
            ),
            ListTile(
              title: const Text('About'),
              trailing: const Icon(Icons.info_outline),
              onTap: _about,
            ),
            ListTile(
              title: const Text('Reset data'),
              trailing: const Icon(Icons.restore),
              onTap: _reset,
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          TournamentsTab(
            items: _items,
            onOpen: _open,
            onFavourite: _toggleFavourite,
          ),
          FavouritesTab(
            items: _items,
            onOpen: _open,
            onFavourite: _toggleFavourite,
          ),
          ProfileTab(
            profile: _profile,
            items: _items,
            themeMode: widget.themeMode,
            onProfileChanged: _setProfile,
            onThemeModeChanged: widget.onThemeModeChanged,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              onPressed: _create,
              tooltip: 'New tournament',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Tournaments',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
