/// Attendance entry — one status per user per day.
import '../utils/constants.dart';

class AttendanceEntry {
  final int? id;
  final int userId;
  final DateTime date;
  final AttendanceStatus status;

  const AttendanceEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.status,
  });

  /// ISO date string for DB storage (yyyy-MM-dd).
  String get dateString =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'date': dateString,
        'status': status.dbValue,
      };

  factory AttendanceEntry.fromMap(Map<String, dynamic> map) => AttendanceEntry(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        date: DateTime.parse(map['date'] as String),
        status: AttendanceStatusExtension.fromDbValue(map['status'] as String?) ??
            AttendanceStatus.absent,
      );

  AttendanceEntry copyWith({
    int? id,
    int? userId,
    DateTime? date,
    AttendanceStatus? status,
  }) =>
      AttendanceEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        date: date ?? this.date,
        status: status ?? this.status,
      );

  @override
  String toString() =>
      'AttendanceEntry(id: $id, userId: $userId, date: $dateString, status: ${status.label})';
}
