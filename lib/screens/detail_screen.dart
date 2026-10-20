import 'dart:async';

import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../models/tournament.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widgets/empty_state.dart';

enum _MenuAction { edit, delete }

/// One tournament: header, About and Players tabs, and Join / Leave.
class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.args});

  final DetailArgs args;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Tournament _item = widget.args.item;
  late final Timer _ticker;

  String get _me => widget.args.profile.name.trim();
  bool get _joined => _me.isNotEmpty && _item.contains(_me);

  @override
  void initState() {
    super.initState();
    // Time passing is the change: rebuild so the countdown moves on.
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  void _apply(Tournament updated) {
    setState(() => _item = updated);
    widget.args.onChanged(updated);
  }

  void _goToProfile() {
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.args.onOpenProfile();
  }

  Future<void> _primary() async {
    if (_me.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add your name in the profile first'),
          action: SnackBarAction(label: 'Profile', onPressed: _goToProfile),
        ),
      );
      return;
    }
    if (_joined) {
      _apply(
        _item.copyWith(
          players: [
            for (final p in _item.players)
              if (p != _me) p,
          ],
        ),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join this tournament?'),
        content: Text('${_item.title}\n${formatDateTime(_item.startsAt)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Join'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _apply(_item.copyWith(players: [..._item.players, _me]));
  }

  Future<void> _edit() async {
    final edited = await Navigator.of(context)
        .pushNamed<Tournament>(Routes.form, arguments: FormArgs(item: _item));
    if (edited == null || !mounted) return;
    _apply(edited);
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this tournament?'),
        content: Text(_item.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    widget.args.onDelete(_item);
    Navigator.of(context).pop();
  }

  void _onMenu(_MenuAction action) => switch (action) {
    _MenuAction.edit => _edit(),
    _MenuAction.delete => _delete(),
  };

  @override
  Widget build(BuildContext context) {
    final canAct = _joined || (!_item.isFull && !_item.isPast);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            PopupMenuButton<_MenuAction>(
              onSelected: _onMenu,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _MenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _MenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: [
              // A share of the height we get, so landscape keeps room
              // for the tabs and the button.
              SizedBox(
                width: double.infinity,
                height: (constraints.maxHeight * 0.3).clamp(80, 220),
                child: _Header(item: _item),
              ),
              TabBar(
                tabs: [
                  const Tab(text: 'About'),
                  Tab(text: 'Players (${_item.count})'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _AboutTab(item: _item),
                    _PlayersTab(item: _item, me: _me),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: canAct ? _primary : null,
                      icon: Icon(_joined ? Icons.logout : Icons.how_to_reg),
                      label: Text(_joined ? 'Leave' : 'Join'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.item});

  final Tournament item;

  static String _describe(Countdown countdown) => switch (countdown) {
    Upcoming(:final left) => 'Starts in ${formatDuration(left)}',
    Started() => 'Live now',
    Ended() => 'Ended',
  };

  @override
  Widget build(BuildContext context) {
    final colors = item.discipline.colorsIn(Theme.of(context).colorScheme);
    final countdown = Countdown.of(item.startsAt, DateTime.now());

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/arena.png', fit: BoxFit.cover),
          Center(
            child: CircleAvatar(
              radius: 32,
              backgroundColor: colors.background,
              foregroundColor: colors.foreground,
              child: Icon(item.discipline.icon, size: 32),
            ),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: Chip(
              avatar: Icon(item.discipline.icon),
              label: Text(item.discipline.label),
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: Chip(label: Text(_describe(countdown))),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.item});

  final Tournament item;

  @override
  Widget build(BuildContext context) {
    final (:taken, :free) = item.places;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoRow(icon: Icons.event, text: formatDateTime(item.startsAt)),
        _InfoRow(
          icon: item.online ? Icons.link : Icons.place,
          text: item.venue,
        ),
        _InfoRow(
          icon: Icons.group,
          text: '$taken of ${item.slots} taken, $free free',
        ),
        if (item.description case final description?)
          _InfoRow(icon: Icons.notes, text: description),
      ],
    );
  }
}

class _PlayersTab extends StatelessWidget {
  const _PlayersTab({required this.item, required this.me});

  final Tournament item;
  final String me;

  @override
  Widget build(BuildContext context) {
    final players = item.players;
    if (players.isEmpty) {
      return const EmptyState(
        icon: Icons.group_off,
        message: 'Nobody has joined yet.',
      );
    }
    return ListView.builder(
      itemCount: players.length,
      itemBuilder: (context, i) {
        final isMe = players[i] == me;
        return ListTile(
          selected: isMe,
          title: Text(players[i]),
          trailing: isMe ? const Text('You') : null,
        );
      },
    );
  }
}
