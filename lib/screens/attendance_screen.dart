/// Attendance screen — calendar view with pay-month navigation, status picker, and summary.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/tada_provider.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/pay_month.dart';
import '../utils/pdf_generator.dart';
import '../widgets/calendar_widget.dart';
import '../widgets/color_legend.dart';
import '../widgets/status_picker.dart';
import 'tada_screen.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payMonth = ref.watch(selectedPayMonthProvider);
    final attendance = ref.watch(attendanceProvider);
    final user = ref.watch(authProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // ─── Pay Month Navigator ───
          _PayMonthNavigator(payMonth: payMonth),

          // ─── Calendar Grid ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CalendarWidget(
              payMonth: payMonth,
              entries: attendance,
              onDayTap: (date) => _showDayActions(context, ref, date),
            ),
          ),

          const SizedBox(height: 16),

          // ─── Summary Bar ───
          _SummaryBar(entries: attendance),

          const SizedBox(height: 12),

          // ─── Color Legend ───
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ColorLegend(),
          ),

          const SizedBox(height: 16),

          // ─── Export PDF Button ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: user == null
                    ? null
                    : () => _exportPdf(context, ref, user, payMonth, attendance),
                icon: const Icon(Icons.picture_as_pdf_rounded),
                label: const Text('Export Attendance PDF'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDayActions(BuildContext context, WidgetRef ref, DateTime date) {
    final user = ref.read(authProvider);
    if (user == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => _DayActionsSheet(date: date, userId: user.id!),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    PayMonth payMonth,
    Map<String, dynamic> attendance,
  ) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generating PDF...')),
      );
      await PdfGenerator.generateAttendancePdf(
        userName: user.name,
        employeeId: user.employeeId,
        payMonth: payMonth,
        entries: Map<String, dynamic>.from(attendance),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF: $e')),
        );
      }
    }
  }
}

/// Day actions bottom sheet — pick status or manage TA/DA entries for the day.
class _DayActionsSheet extends ConsumerWidget {
  final DateTime date;
  final int userId;

  const _DayActionsSheet({required this.date, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    final currentStatus =
        ref.read(attendanceProvider.notifier).getStatusForDate(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Header
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${date.day}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accent,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayNames[date.weekday - 1],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    '${monthNames[date.month - 1]} ${date.year}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const Spacer(),
              if (currentStatus != null)
                Chip(
                  backgroundColor: currentStatus.color.withValues(alpha: 0.2),
                  label: Text(
                    currentStatus.label,
                    style: TextStyle(color: currentStatus.color, fontSize: 12),
                  ),
                  avatar: Icon(
                    currentStatus.icon,
                    size: 16,
                    color: currentStatus.color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Status Picker
          Text(
            'SET STATUS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 8),
          StatusPicker(
            currentStatus: currentStatus,
            onStatusSelected: (status) async {
              await ref
                  .read(attendanceProvider.notifier)
                  .setStatus(userId, date, status);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          const SizedBox(height: 16),

          // TA/DA Link
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TadaScreen(date: date),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('Manage TA/DA Entries'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pay-month navigation bar.
class _PayMonthNavigator extends ConsumerWidget {
  final PayMonth payMonth;
  const _PayMonthNavigator({required this.payMonth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _navigateMonth(ref, -1),
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Reset to current pay month.
                ref.read(selectedPayMonthProvider.notifier).state =
                    PayMonth.current();
                _reloadData(ref);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.divider, width: 0.5),
                ),
                child: Center(
                  child: Text(
                    payMonth.displayLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _navigateMonth(ref, 1),
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }

  void _navigateMonth(WidgetRef ref, int direction) {
    final current = ref.read(selectedPayMonthProvider);
    ref.read(selectedPayMonthProvider.notifier).state =
        direction > 0 ? current.next : current.previous;
    _reloadData(ref);
  }

  void _reloadData(WidgetRef ref) {
    final user = ref.read(authProvider);
    if (user == null) return;
    final payMonth = ref.read(selectedPayMonthProvider);
    ref.read(attendanceProvider.notifier).loadForPayMonth(user.id!, payMonth);
    ref.read(tadaProvider.notifier).loadForPayMonth(user.id!, payMonth);
  }
}

/// Summary bar showing status counts.
class _SummaryBar extends StatelessWidget {
  final Map<String, dynamic> entries;
  const _SummaryBar({required this.entries});

  @override
  Widget build(BuildContext context) {
    final counts = <AttendanceStatus, int>{};
    for (final entry in entries.values) {
      final status = (entry as dynamic).status as AttendanceStatus;
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: AttendanceStatus.values.map((status) {
          final count = counts[status] ?? 0;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(
                color: status.color.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: 14, color: status.color),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: TextStyle(
                    color: status.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  status.shortLabel,
                  style: TextStyle(
                    color: status.color.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
