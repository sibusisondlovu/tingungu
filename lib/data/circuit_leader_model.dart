class CircuitLeader {
  final int id;
  final String firstName;
  final String lastName;
  final String cellNumber;
  final String email;

  CircuitLeader({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.cellNumber,
    required this.email,
  });

  factory CircuitLeader.fromJson(Map<String, dynamic> json) {
    return CircuitLeader(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      cellNumber: json['cell_number'] ?? '',
      email: json['email'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}