class User {
  String name;
  String phone;
  String preference;
  String unitId;
  DateTime lastDate;
  DateTime? fromDate; // New field
  DateTime? toDate; // New field
  String email;
  String password;
  bool isApproved = false;

  User({
    required this.name,
    required this.phone,
    required this.preference,
    required this.unitId,
    required this.lastDate,
    this.fromDate,
    this.toDate,
    required this.email,
    required this.password,
    this.isApproved = false,
  });

  // Convert a User object to a Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'preference': preference,
      'unit_id': unitId,
      'last_date': lastDate.toIso8601String(),
      'from_date': fromDate?.toIso8601String(), // Convert to ISO string
      'to_date': toDate?.toIso8601String(), // Convert to ISO string
      'email': email,
      'password': password,
      'is_approved': isApproved,
    };
  }

  // Create a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      phone: map['phone'],
      preference: map['preference'],
      unitId: map['unit_id'],
      email: map['email'],
      password: map['password'],
      lastDate: DateTime.parse(map['last_date']),
      fromDate:
          map['from_date'] != null ? DateTime.parse(map['from_date']) : null,
      toDate: map['to_date'] != null ? DateTime.parse(map['to_date']) : null,
      isApproved: map['is_approved'] ?? false,
    );
  }
}
