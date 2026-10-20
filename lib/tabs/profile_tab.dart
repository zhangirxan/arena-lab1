import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/tournament.dart';

final _groupFormat = RegExp(r'^[A-Z]{2,4}-\d{4}$');

/// Tab 3: name, group, how many lists you are on, and the theme.
class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.items,
    required this.themeMode,
    required this.onProfileChanged,
    required this.onThemeModeChanged,
  });

  final Profile profile;
  final List<Tournament> items;
  final ThemeMode themeMode;
  final ValueChanged<Profile> onProfileChanged;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.profile.name);
  late final _group = TextEditingController(text: widget.profile.group);

  @override
  void didUpdateWidget(ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new profile object came from above (for example Reset data).
    if (!identical(oldWidget.profile, widget.profile)) {
      _name.text = widget.profile.name;
      _group.text = widget.profile.group;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  String? _validateGroup(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty || _groupFormat.hasMatch(v)) return null;
    return 'Format: IT-2302';
  }

  void _saveName(String value) =>
      widget.onProfileChanged(widget.profile.copyWith(name: value.trim()));

  void _saveGroup(String value) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onProfileChanged(widget.profile.copyWith(group: value.trim()));
  }

  static String _label(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'System',
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final me = widget.profile.name;
    final lists = me.isEmpty
        ? 0
        : widget.items.where((t) => t.contains(me)).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  helperText: 'Press Enter to save',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: _saveName,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _group,
                decoration: const InputDecoration(
                  labelText: 'Group',
                  hintText: 'IT-2302',
                  helperText: 'Press Enter to save',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.done,
                validator: _validateGroup,
                onFieldSubmitted: _saveGroup,
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You are on $lists ${lists == 1 ? 'list' : 'lists'}',
          style: text.titleMedium,
        ),
        const SizedBox(height: 24),
        Text('Theme', style: text.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final mode in ThemeMode.values)
              ChoiceChip(
                label: Text(_label(mode)),
                selected: widget.themeMode == mode,
                onSelected: (_) => widget.onThemeModeChanged(mode),
              ),
          ],
        ),
      ],
    );
  }
}
