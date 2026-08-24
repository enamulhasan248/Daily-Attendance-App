/// Attendance status enum with associated colors, labels, and icons.
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AttendanceStatus {
  dayShift,
  nightShift,
  onLeave,
  weekend,
  holiday,
  absent,
}

extension AttendanceStatusExtension on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.dayShift:
        return 'Day Shift';
      case AttendanceStatus.nightShift:
        return 'Night Shift';
      case AttendanceStatus.onLeave:
        return 'On Leave';
      case AttendanceStatus.weekend:
        return 'Weekend';
      case AttendanceStatus.holiday:
        return 'Holiday';
      case AttendanceStatus.absent:
        return 'Absent';
    }
  }

  String get shortLabel {
    switch (this) {
      case AttendanceStatus.dayShift:
        return 'D';
      case AttendanceStatus.nightShift:
        return 'N';
      case AttendanceStatus.onLeave:
        return 'L';
      case AttendanceStatus.weekend:
        return 'W';
      case AttendanceStatus.holiday:
        return 'H';
      case AttendanceStatus.absent:
        return 'A';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.dayShift:
        return AppTheme.dayShift;
      case AttendanceStatus.nightShift:
        return AppTheme.nightShift;
      case AttendanceStatus.onLeave:
        return AppTheme.onLeave;
      case AttendanceStatus.weekend:
        return AppTheme.weekend;
      case AttendanceStatus.holiday:
        return AppTheme.holiday;
      case AttendanceStatus.absent:
        return AppTheme.absent;
    }
  }

  IconData get icon {
    switch (this) {
      case AttendanceStatus.dayShift:
        return Icons.wb_sunny_rounded;
      case AttendanceStatus.nightShift:
        return Icons.nights_stay_rounded;
      case AttendanceStatus.onLeave:
        return Icons.beach_access_rounded;
      case AttendanceStatus.weekend:
        return Icons.weekend_rounded;
      case AttendanceStatus.holiday:
        return Icons.celebration_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
    }
  }

  String get dbValue => name;

  static AttendanceStatus? fromDbValue(String? value) {
    if (value == null) return null;
    try {
      return AttendanceStatus.values.firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}
