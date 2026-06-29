/// Lightweight date helpers so the app avoids an `intl` dependency.
abstract final class AppDates {
  const AppDates._();

  static const List<String> monthsShort = [
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

  static const List<String> monthsLong = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Single-letter weekday headers, Sunday first.
  static const List<String> weekdayInitials = [
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  /// Strips the time component, keeping the local calendar day.
  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// e.g. "Jun 30".
  static String shortDate(DateTime d) => '${monthsShort[d.month - 1]} ${d.day}';

  /// e.g. "June 2026".
  static String monthYear(DateTime d) => '${monthsLong[d.month - 1]} ${d.year}';
}
