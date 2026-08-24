/// TA/DA provider — manages expense entries.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/tada_entry.dart';
import '../utils/pay_month.dart';

/// Provides TA/DA entries for the selected pay month.
final tadaProvider =
    StateNotifierProvider<TadaNotifier, List<TadaEntry>>((ref) {
  return TadaNotifier();
});

/// Provides TA/DA entries for a specific day.
final tadaDayProvider =
    StateNotifierProvider<TadaDayNotifier, List<TadaEntry>>((ref) {
  return TadaDayNotifier();
});

class TadaNotifier extends StateNotifier<List<TadaEntry>> {
  TadaNotifier() : super([]);

  /// Load all TA/DA entries for a user within a pay month.
  Future<void> loadForPayMonth(int userId, PayMonth payMonth) async {
    final entries = await DatabaseHelper.instance.getTadaEntriesForRange(
      userId,
      payMonth.startDate,
      payMonth.endDate,
    );
    state = entries;
  }

  /// Total amount for the loaded entries.
  double get totalAmount =>
      state.fold(0.0, (sum, entry) => sum + entry.amount);

  /// Group entries by date.
  Map<String, List<TadaEntry>> get groupedByDate {
    final grouped = <String, List<TadaEntry>>{};
    for (final entry in state) {
      grouped.putIfAbsent(entry.dateString, () => []).add(entry);
    }
    return grouped;
  }
}

class TadaDayNotifier extends StateNotifier<List<TadaEntry>> {
  TadaDayNotifier() : super([]);

  /// Load TA/DA entries for a specific day.
  Future<void> loadForDate(int userId, DateTime date) async {
    final entries =
        await DatabaseHelper.instance.getTadaEntriesForDate(userId, date);
    state = entries;
  }

  /// Add a new entry.
  Future<void> addEntry(TadaEntry entry) async {
    await DatabaseHelper.instance.insertTadaEntry(entry);
    await loadForDate(entry.userId, entry.date);
  }

  /// Update an existing entry.
  Future<void> updateEntry(TadaEntry entry) async {
    await DatabaseHelper.instance.updateTadaEntry(entry);
    await loadForDate(entry.userId, entry.date);
  }

  /// Delete an entry.
  Future<void> deleteEntry(int id, int userId, DateTime date) async {
    await DatabaseHelper.instance.deleteTadaEntry(id);
    await loadForDate(userId, date);
  }
}
