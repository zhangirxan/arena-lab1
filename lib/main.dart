import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/shell_screen.dart';

void main() => runApp(const MyApp());

/// The one seed colour; every other colour is a role derived from it.
const _seed = Colors.deepOrange;

ThemeData _theme(Brightness brightness) => ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: brightness),
);

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Arena',
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _themeMode,
    initialRoute: Routes.shell,
    routes: {
      Routes.shell: (_) =>
          ShellScreen(themeMode: _themeMode, onThemeModeChanged: _setThemeMode),
    },
    onGenerateRoute: onGenerateRoute,
    onUnknownRoute: onUnknownRoute,
  );
}
