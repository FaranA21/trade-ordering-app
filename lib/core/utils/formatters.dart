import 'package:intl/intl.dart';

class Fmt {
  Fmt._();

  static final NumberFormat _gbp = NumberFormat.currency(locale: 'en_GB', symbol: '£', decimalDigits: 2);
  static final NumberFormat _gbpWhole = NumberFormat.currency(locale: 'en_GB', symbol: '£', decimalDigits: 0);
  static final DateFormat _day = DateFormat('d MMM yyyy');
  static final DateFormat _dayShort = DateFormat('d MMM');
  static final DateFormat _dayTime = DateFormat('d MMM, HH:mm');
  static final DateFormat _longDay = DateFormat('EEEE d MMMM');
  static final DateFormat _time = DateFormat('HH:mm');

  static String gbp(double value) => _gbp.format(value);
  static String gbpWhole(double value) => _gbpWhole.format(value);
  static String day(DateTime d) => _day.format(d);
  static String dayShort(DateTime d) => _dayShort.format(d);
  static String dayTime(DateTime d) => _dayTime.format(d);
  static String longDay(DateTime d) => _longDay.format(d);
  static String time(DateTime d) => _time.format(d);

  /// "Today 09:12" for today, otherwise "2 Nov 16:22".
  static String when(DateTime d) {
    final now = DateTime.now();
    final today = d.year == now.year && d.month == now.month && d.day == now.day;
    return today ? 'Today ${_time.format(d)}' : '${_dayShort.format(d)} ${_time.format(d)}';
  }

  /// Two-letter initials from a company name, e.g. "Hillside Joinery" -> "HJ".
  static String initials(String name) {
    final words = name.split(RegExp(r'[\s&]+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
