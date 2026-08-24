/// Status picker — grid of the 6 attendance statuses.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class StatusPicker extends StatelessWidget {
  final AttendanceStatus? currentStatus;
  final void Function(AttendanceStatus status) onStatusSelected;

  const StatusPicker({
    super.key,
    this.currentStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AttendanceStatus.values.map((status) {
        final isSelected = currentStatus == status;
        return GestureDetector(
          onTap: () => onStatusSelected(status),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? status.color.withValues(alpha: 0.25)
                  : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? status.color
                    : AppTheme.divider,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(status.icon, size: 18, color: status.color),
                const SizedBox(width: 6),
                Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? status.color : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
