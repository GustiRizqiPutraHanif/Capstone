const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

/// "Hari ini", "Kemarin", "2 hari lalu", atau tanggal untuk yang lebih lama.
String relativeDay(DateTime date, DateTime now) {
  final day = DateTime(date.year, date.month, date.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff <= 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  if (diff < 7) return '$diff hari lalu';
  return '${day.day} ${_bulan[day.month - 1]} ${day.year}';
}
