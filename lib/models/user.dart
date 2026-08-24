/// User model — represents a logged-in employee.
class User {
  final int? id;
  final String name;
  final String employeeId;

  const User({
    this.id,
    required this.name,
    required this.employeeId,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'employee_id': employeeId,
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id: map['id'] as int?,
        name: map['name'] as String,
        employeeId: map['employee_id'] as String,
      );

  User copyWith({int? id, String? name, String? employeeId}) => User(
        id: id ?? this.id,
        name: name ?? this.name,
        employeeId: employeeId ?? this.employeeId,
      );

  @override
  String toString() => 'User(id: $id, name: $name, employeeId: $employeeId)';
}
