/// Color legend — displays all status colors with labels.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';

class ColorLegend extends StatelessWidget {
  const ColorLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: AppTheme.divider, width: 0.5),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: AttendanceStatus.values.map((status) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: status.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                status.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
