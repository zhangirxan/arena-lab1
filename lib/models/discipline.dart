import 'package:flutter/material.dart';

/// The game a tournament is played in.
enum Discipline {
  cs2('Counter-Strike 2', Icons.gps_fixed),
  dota2('Dota 2', Icons.shield),
  valorant('Valorant', Icons.bolt),
  fc('EA FC', Icons.sports_soccer),
  chess('Chess', Icons.grid_on),
  tekken('Tekken', Icons.sports_mma);

  const Discipline(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Background and foreground roles for this discipline's avatar.
  ({Color background, Color foreground}) colorsIn(ColorScheme scheme) =>
      switch (this) {
        Discipline.cs2 => (
          background: scheme.primary,
          foreground: scheme.onPrimary,
        ),
        Discipline.dota2 => (
          background: scheme.error,
          foreground: scheme.onError,
        ),
        Discipline.valorant => (
          background: scheme.tertiary,
          foreground: scheme.onTertiary,
        ),
        Discipline.fc => (
          background: scheme.secondary,
          foreground: scheme.onSecondary,
        ),
        Discipline.chess => (
          background: scheme.primaryContainer,
          foreground: scheme.onPrimaryContainer,
        ),
        Discipline.tekken => (
          background: scheme.tertiaryContainer,
          foreground: scheme.onTertiaryContainer,
        ),
      };
}
