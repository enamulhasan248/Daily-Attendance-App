/// Pay-month utility: handles the 26th-to-25th pay cycle logic.

class PayMonth {
  final int year;
  final int month; // The month that contains the 26th start date.

  const PayMonth({required this.year, required this.month});

  /// Start date of this pay month (26th of [month]/[year]).
  DateTime get startDate => DateTime(year, month, 26);

  /// End date of this pay month (25th of the following month).
  DateTime get endDate {
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    return DateTime(nextYear, nextMonth, 25);
  }

  /// Total number of days in this pay month.
  int get totalDays => endDate.difference(startDate).inDays + 1;

  /// Returns all dates in this pay month as a list.
  List<DateTime> get allDates {
    final dates = <DateTime>[];
    var current = startDate;
    while (!current.isAfter(endDate)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  /// Display label, e.g. "26 Jul – 25 Aug 2026"
  String get displayLabel {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final startMonth = monthNames[startDate.month - 1];
    final endMonthName = monthNames[endDate.month - 1];
    return '26 $startMonth – 25 $endMonthName ${endDate.year}';
  }

  /// Get the pay month that contains a given date.
  static PayMonth fromDate(DateTime date) {
    // If date is on or after the 26th, the pay month starts this calendar month.
    // If date is before the 26th, the pay month started on the 26th of the previous month.
    if (date.day >= 26) {
      return PayMonth(year: date.year, month: date.month);
    } else {
      final prevMonth = date.month == 1 ? 12 : date.month - 1;
      final prevYear = date.month == 1 ? date.year - 1 : date.year;
      return PayMonth(year: prevYear, month: prevMonth);
    }
  }

  /// Get the current pay month.
  static PayMonth current() => fromDate(DateTime.now());

  /// Navigate to the previous pay month.
  PayMonth get previous {
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;
    return PayMonth(year: prevYear, month: prevMonth);
  }

  /// Navigate to the next pay month.
  PayMonth get next {
    final nextMonth = month == 12 ? 1 : month + 1;
    final nextYear = month == 12 ? year + 1 : year;
    return PayMonth(year: nextYear, month: nextMonth);
  }

  /// Whether this pay month contains the given date.
  bool containsDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(startDate) && !d.isAfter(endDate);
  }

  /// String key for storage, e.g. "2026-07" (the start month).
  String get key => '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayMonth && year == other.year && month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  @override
  String toString() => 'PayMonth($key)';
}
