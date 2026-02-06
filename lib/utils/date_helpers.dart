bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

DateTime endOfDay(DateTime dt) =>
    DateTime(dt.year, dt.month, dt.day, 23, 59, 59, 999);

DateTime startOfWeek(DateTime dt) {
  final d = startOfDay(dt);
  final daysToSubtract = d.weekday - DateTime.monday;
  return d.subtract(Duration(days: daysToSubtract));
}

DateTime endOfWeek(DateTime dt) => startOfWeek(dt).add(const Duration(days: 6));

String formatShortDate(DateTime dt) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
}

String formatDayLabel(DateTime dt) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return '${days[dt.weekday - 1]} • ${formatShortDate(dt)}';
}

int isoWeekNumber(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final thursday = d.add(Duration(days: 4 - d.weekday));
  final yearStart = DateTime(thursday.year, 1, 1);
  final week1Thursday = yearStart.add(Duration(days: 4 - yearStart.weekday));
  final diffDays = thursday.difference(week1Thursday).inDays;
  return 1 + (diffDays ~/ 7);
}
