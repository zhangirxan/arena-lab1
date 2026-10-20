import 'discipline.dart';

/// How long a tournament runs after it starts.
const tournamentLength = Duration(hours: 3);

/// A tournament at the campus gaming club.
class Tournament {
  const Tournament({
    required this.id,
    required this.title,
    required this.discipline,
    required this.startsAt,
    required this.slots,
    required this.venue,
    List<String> players = const [],
    this.online = false,
    this.description,
    this.favourite = false,
  }) : _names = players;

  /// Defaults for a brand-new tournament in the form.
  Tournament.empty()
    : this(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: '',
        discipline: Discipline.cs2,
        startsAt: DateTime.now().add(const Duration(days: 7)),
        slots: 16,
        venue: '',
      );

  final String id;
  final String title;
  final Discipline discipline;
  final DateTime startsAt;

  /// The limit the players list counts against.
  final int slots;

  /// A physical place, or a stream link when [online] is on.
  final String venue;
  final bool online;
  final String? description;
  final bool favourite;
  final List<String> _names;

  /// Read-only view: the list can only change through [copyWith].
  List<String> get players => List.unmodifiable(_names);

  int get count => _names.length;
  int get free => (slots - count).clamp(0, slots);
  bool get isFull => count >= slots;
  bool get isPast => DateTime.now().isAfter(startsAt.add(tournamentLength));
  bool contains(String name) => _names.any((p) => p == name);

  ({int taken, int free}) get places => (taken: count, free: free);

  Tournament copyWith({
    String? title,
    Discipline? discipline,
    DateTime? startsAt,
    int? slots,
    String? venue,
    List<String>? players,
    bool? online,
    String? Function()? description,
    bool? favourite,
  }) => Tournament(
    id: id,
    title: title ?? this.title,
    discipline: discipline ?? this.discipline,
    startsAt: startsAt ?? this.startsAt,
    slots: slots ?? this.slots,
    venue: venue ?? this.venue,
    players: players ?? _names,
    online: online ?? this.online,
    description: description != null ? description() : this.description,
    favourite: favourite ?? this.favourite,
  );
}

/// Upcoming first by date, past ones last.
int compareByDate(Tournament a, Tournament b) {
  if (a.isPast != b.isPast) return a.isPast ? 1 : -1;
  return a.startsAt.compareTo(b.startsAt);
}
