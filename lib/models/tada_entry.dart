/// TA/DA entry — expense claim tied to a specific day.
class TadaEntry {
  final int? id;
  final int userId;
  final DateTime date;
  final String purpose;
  final double amount;
  final String remarks;

  const TadaEntry({
    this.id,
    required this.userId,
    required this.date,
    required this.purpose,
    required this.amount,
    this.remarks = '',
  });

  /// ISO date string for DB storage (yyyy-MM-dd).
  String get dateString =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'user_id': userId,
        'date': dateString,
        'purpose': purpose,
        'amount': amount,
        'remarks': remarks,
      };

  factory TadaEntry.fromMap(Map<String, dynamic> map) => TadaEntry(
        id: map['id'] as int?,
        userId: map['user_id'] as int,
        date: DateTime.parse(map['date'] as String),
        purpose: map['purpose'] as String,
        amount: (map['amount'] as num).toDouble(),
        remarks: map['remarks'] as String? ?? '',
      );

  TadaEntry copyWith({
    int? id,
    int? userId,
    DateTime? date,
    String? purpose,
    double? amount,
    String? remarks,
  }) =>
      TadaEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        date: date ?? this.date,
        purpose: purpose ?? this.purpose,
        amount: amount ?? this.amount,
        remarks: remarks ?? this.remarks,
      );

  @override
  String toString() =>
      'TadaEntry(id: $id, userId: $userId, date: $dateString, purpose: $purpose, amount: $amount)';
}
