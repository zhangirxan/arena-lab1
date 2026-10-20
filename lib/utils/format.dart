const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 18 Oct
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// 10:00
String formatTime(int hour, int minute) => '${_two(hour)}:${_two(minute)}';

/// 18 Oct, 10:00
String formatDateTime(DateTime d) =>
    '${formatDate(d)}, ${formatTime(d.hour, d.minute)}';

/// 2d 4h, 3h 10m or 25m
String formatDuration(Duration d) {
  final days = d.inDays;
  final hours = d.inHours % 24;
  final minutes = d.inMinutes % 60;
  if (days > 0) return '${days}d ${hours}h';
  if (hours > 0) return '${hours}h ${_two(minutes)}m';
  return '${minutes}m';
}
