import 'tournament.dart';

/// Where a tournament stands relative to now.
sealed class Countdown {
  const Countdown();

  factory Countdown.of(DateTime startsAt, DateTime now) {
    if (now.isBefore(startsAt)) return Upcoming(startsAt.difference(now));
    final since = now.difference(startsAt);
    if (since < tournamentLength) return Started(since);
    return const Ended();
  }
}

final class Upcoming extends Countdown {
  const Upcoming(this.left);
  final Duration left;
}

final class Started extends Countdown {
  const Started(this.since);
  final Duration since;
}

final class Ended extends Countdown {
  const Ended();
}
