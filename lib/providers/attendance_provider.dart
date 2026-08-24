/// Attendance provider — manages attendance entries for a pay month.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/attendance_entry.dart';
import '../utils/constants.dart';
import '../utils/pay_month.dart';

/// Tracks the currently selected pay month.
final selectedPayMonthProvider = StateProvider<PayMonth>((ref) {
  return PayMonth.current();
});

/// Provides attendance entries for the selected pay month, keyed by date string.
final attendanceProvider = StateNotifierProvider<AttendanceNotifier,
    Map<String, AttendanceEntry>>((ref) {
  return AttendanceNotifier();
});

class AttendanceNotifier extends StateNotifier<Map<String, AttendanceEntry>> {
  AttendanceNotifier() : super({});

  /// Load all attendance entries for a user within a pay month.
  Future<void> loadForPayMonth(int userId, PayMonth payMonth) async {
    final entries = await DatabaseHelper.instance.getAttendanceForRange(
      userId,
      payMonth.startDate,
      payMonth.endDate,
    );
    final map = <String, AttendanceEntry>{};
    for (final entry in entries) {
      map[entry.dateString] = entry;
    }
    state = map;
  }

  /// Set or update the status for a specific date.
  Future<void> setStatus(
    int userId,
    DateTime date,
    AttendanceStatus status,
  ) async {
    final entry = AttendanceEntry(
      userId: userId,
      date: date,
      status: status,
    );
    await DatabaseHelper.instance.upsertAttendance(entry);

    // Update local state.
    state = {...state, entry.dateString: entry};
  }

  /// Get the status for a specific date, or null if not set.
  AttendanceStatus? getStatusForDate(DateTime date) {
    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return state[dateStr]?.status;
  }

  /// Get summary counts for the current loaded entries.
  Map<AttendanceStatus, int> get summaryCounts {
    final counts = <AttendanceStatus, int>{};
    for (final entry in state.values) {
      counts[entry.status] = (counts[entry.status] ?? 0) + 1;
    }
    return counts;
  }
}
