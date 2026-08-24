/// TA/DA monthly summary screen with export options.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tada_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/tada_provider.dart';
import '../theme/app_theme.dart';
import '../utils/pay_month.dart';
import '../utils/tada_export.dart';
import 'tada_screen.dart';

class TadaSummaryScreen extends ConsumerWidget {
  const TadaSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(tadaProvider);
    final payMonth = ref.watch(selectedPayMonthProvider);
    final user = ref.watch(authProvider);
    final total = entries.fold(0.0, (sum, e) => sum + e.amount);

    // Group by date
    final grouped = <String, List<TadaEntry>>{};
    for (final e in entries) {
      grouped.putIfAbsent(e.dateString, () => []).add(e);
    }
    final sortedDates = grouped.keys.toList()..sort();

    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    return Column(
      children: [
        // Total Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accent.withValues(alpha: 0.18),
                AppTheme.surfaceCard,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(payMonth.displayLabel, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                '৳ ${total.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppTheme.accent),
              ),
              const SizedBox(height: 4),
              Text(
                '${entries.length} entries across ${grouped.length} days',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: entries.isEmpty || user == null
                          ? null
                          : () => _exportCsv(context, user, payMonth, entries),
                      icon: const Icon(Icons.table_chart_outlined, size: 18),
                      label: const Text('CSV'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: entries.isEmpty || user == null
                          ? null
                          : () => _exportPdf(context, user, payMonth, entries),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                      label: const Text('PDF'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Entry List
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      Text('No TA/DA entries this month', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Add entries from the Attendance calendar.', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final dateStr = sortedDates[index];
                    final dayEntries = grouped[dateStr]!;
                    final date = DateTime.parse(dateStr);
                    final dayTotal = dayEntries.fold(0.0, (sum, e) => sum + e.amount);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => TadaScreen(date: date)),
                              );
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceCardHover,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${date.day} ${monthNames[date.month - 1]}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimary),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '৳ ${dayTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.accent, fontSize: 14),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        ),
                        ...dayEntries.map((e) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.divider, width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(e.purpose, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                                        if (e.remarks.isNotEmpty)
                                          Text(e.remarks, style: Theme.of(context).textTheme.bodySmall),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '৳ ${e.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _exportCsv(BuildContext context, dynamic user, PayMonth payMonth, List<TadaEntry> entries) async {
    try {
      await TadaExport.exportCsv(
        userName: user.name,
        employeeId: user.employeeId,
        payMonth: payMonth,
        entries: entries,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV exported!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }

  Future<void> _exportPdf(BuildContext context, dynamic user, PayMonth payMonth, List<TadaEntry> entries) async {
    try {
      await TadaExport.exportPdf(
        userName: user.name,
        employeeId: user.employeeId,
        payMonth: payMonth,
        entries: entries,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF exported!')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
      }
    }
  }
}
