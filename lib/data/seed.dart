import '../models/discipline.dart';
import '../models/tournament.dart';

const _people = [
  'Aida Akhmetova', 'Dias Nurlanov', 'Madina Serik', 'Alikhan Bekov', //
  'Zhanel Tolegen', 'Arman Kairat', 'Kamila Dosym', 'Yerlan Sadyk',
  'Aruzhan Mukhtar', 'Timur Zhaksylyk', 'Dana Orazbek', 'Sanzhar Kenzhe',
  'Amina Talgat', 'Bekzat Ospan', 'Inkar Rakhim', 'Daniyar Amir',
];

List<String> _roster(int n) => [
  for (var i = 0; i < n; i++)
    i < _people.length ? _people[i] : 'Guest ${i - _people.length + 1}',
];

const _club = 'Arena Club, Abay 52, 2nd floor';

/// Twelve tournaments with dates relative to today.
List<Tournament> seedTournaments() {
  final now = DateTime.now();
  DateTime day(int days, int hour) =>
      DateTime(now.year, now.month, now.day + days, hour);

  return [
    // The 60-character title.
    Tournament(
      id: 't01',
      title: 'KBTU Spring Major: Counter-Strike 2 Wingman Cup Grand Finals',
      discipline: Discipline.cs2,
      startsAt: day(3, 18),
      slots: 32,
      venue: 'KBTU, Tole Bi 59, hall 202',
      players: _roster(14),
      description:
          'Best of three, double elimination. '
          'Bring your own mouse and headset.',
      favourite: true,
    ),
    // At its limit.
    Tournament(
      id: 't02',
      title: 'Dota 2 Freshman Cup',
      discipline: Discipline.dota2,
      startsAt: day(5, 16),
      slots: 10,
      venue: _club,
      players: _roster(10),
      description: 'Five-a-side, captains draft. First-year students only.',
    ),
    // In the past.
    Tournament(
      id: 't03',
      title: 'Friday Night Valorant',
      discipline: Discipline.valorant,
      startsAt: day(-4, 20),
      slots: 20,
      venue: _club,
      players: _roster(18),
      description: 'Results are on the club board.',
    ),
    // Mode on: the venue is a link. Also without the optional text.
    Tournament(
      id: 't04',
      title: 'Online Chess Blitz 3+2',
      discipline: Discipline.chess,
      startsAt: day(2, 19),
      slots: 64,
      venue: 'https://lichess.org/tournament/kbtu-blitz',
      online: true,
      players: _roster(9),
    ),
    // Without the optional text; four places left.
    Tournament(
      id: 't05',
      title: 'EA FC Pub League, Week 3',
      discipline: Discipline.fc,
      startsAt: day(1, 15),
      slots: 16,
      venue: 'Student Union lounge',
      players: _roster(12),
    ),
    Tournament(
      id: 't06',
      title: 'Tekken 8 King of the Iron Fist Night',
      discipline: Discipline.tekken,
      startsAt: day(6, 18),
      slots: 24,
      venue: _club,
      players: _roster(5),
      description: 'Arcade sticks provided. Pad players welcome.',
      favourite: true,
    ),
    Tournament(
      id: 't07',
      title: 'CS2 Aim Duels',
      discipline: Discipline.cs2,
      startsAt: now.subtract(const Duration(minutes: 40)),
      slots: 16,
      venue: _club,
      players: _roster(11),
      description: 'One-versus-one on aim maps, first to sixteen.',
    ),
    Tournament(
      id: 't08',
      title: 'Valorant Unrated Mixer',
      discipline: Discipline.valorant,
      startsAt: day(9, 17),
      slots: 30,
      venue: 'https://discord.gg/kbtu-arena',
      online: true,
      players: _roster(2),
      description: 'Random teams every round. Voice chat on Discord.',
    ),
    // Two places left.
    Tournament(
      id: 't09',
      title: 'Dota 2 Turbo Marathon',
      discipline: Discipline.dota2,
      startsAt: day(12, 12),
      slots: 40,
      venue: _club,
      players: _roster(38),
      description: 'Six hours of Turbo games, snacks included.',
    ),
    Tournament(
      id: 't10',
      title: 'Chess960 Rapid Open',
      discipline: Discipline.chess,
      startsAt: day(-10, 14),
      slots: 30,
      venue: 'KBTU library, reading room',
      players: _roster(21),
      description: 'Fischer random, 15+10.',
    ),
    // Five places left.
    Tournament(
      id: 't11',
      title: 'Tekken Beginners Workshop',
      discipline: Discipline.tekken,
      startsAt: day(4, 17),
      slots: 12,
      venue: _club,
      players: _roster(7),
      description: 'Learn movement and punishes, then play a mini bracket.',
    ),
    // Nobody on the list yet.
    Tournament(
      id: 't12',
      title: 'EA FC Pro Clubs Showdown',
      discipline: Discipline.fc,
      startsAt: day(15, 19),
      slots: 22,
      venue: 'https://twitch.tv/kbtuarena',
      online: true,
      description: 'Eleven-a-side clubs, streamed live.',
    ),
  ];
}
