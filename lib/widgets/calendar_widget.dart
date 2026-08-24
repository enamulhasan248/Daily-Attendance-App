/// Calendar widget — renders a grid of days for the 26th-to-25th pay month.
import 'package:flutter/material.dart';
import '../models/attendance_entry.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/pay_month.dart';

class CalendarWidget extends StatelessWidget {
  final PayMonth payMonth;
  final Map<String, AttendanceEntry> entries;
  final void Function(DateTime date) onDayTap;

  const CalendarWidget({
    super.key,
    required this.payMonth,
    required this.entries,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final dates = payMonth.allDates;
    final today = DateTime.now();
    final todayStr = '${today.year.toString().padLeft(4, '0')}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final dayHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Calculate leading empty cells (days before the start date's weekday).
    final startWeekday = dates.first.weekday; // 1=Mon, 7=Sun
    final leadingEmpty = startWeekday - 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Day headers
            Row(
              children: dayHeaders
                  .map((d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),

            // Calendar grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: leadingEmpty + dates.length,
              itemBuilder: (context, index) {
                if (index < leadingEmpty) {
                  return const SizedBox.shrink();
                }
                final date = dates[index - leadingEmpty];
                final dateStr = '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final entry = entries[dateStr];
                final isToday = dateStr == todayStr;

                return _DayCell(
                  date: date,
                  status: entry?.status,
                  isToday: isToday,
                  onTap: () => onDayTap(date),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final AttendanceStatus? status;
  final bool isToday;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    this.status,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = status?.color ?? AppTheme.unset;
    final hasStatus = status != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: hasStatus ? bgColor.withValues(alpha: 0.2) : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isToday
                ? AppTheme.accent
                : hasStatus
                    ? bgColor.withValues(alpha: 0.5)
                    : AppTheme.divider,
            width: isToday ? 2 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                color: isToday
                    ? AppTheme.accent
                    : hasStatus
                        ? bgColor
                        : AppTheme.textSecondary,
              ),
            ),
            // Status label
            if (hasStatus) ...[
              const SizedBox(height: 2),
              Icon(status!.icon, size: 12, color: bgColor),
              Text(
                status!.shortLabel,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: bgColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
