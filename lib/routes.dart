import 'package:flutter/material.dart';

import 'models/profile.dart';
import 'models/tournament.dart';
import 'screens/detail_screen.dart';
import 'screens/form_screen.dart';
import 'screens/not_found_screen.dart';

abstract final class Routes {
  static const shell = '/';
  static const detail = '/tournament';
  static const form = '/tournament/form';
}

/// What the detail screen needs: the item and how to report changes.
class DetailArgs {
  const DetailArgs({
    required this.item,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onOpenProfile,
  });

  final Tournament item;
  final Profile profile;
  final ValueChanged<Tournament> onChanged;
  final ValueChanged<Tournament> onDelete;
  final VoidCallback onOpenProfile;
}

/// The form edits [item], or creates a new one when it is null.
class FormArgs {
  const FormArgs({this.item});

  final Tournament? item;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) => switch (settings) {
  RouteSettings(name: Routes.detail, arguments: final DetailArgs args) =>
    MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => DetailScreen(args: args),
    ),
  RouteSettings(name: Routes.form, arguments: final FormArgs args) =>
    MaterialPageRoute<Tournament>(
      settings: settings,
      builder: (_) => FormScreen(args: args),
    ),
  _ => null,
};

Route<dynamic> onUnknownRoute(RouteSettings settings) =>
    MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const NotFoundScreen(),
    );
