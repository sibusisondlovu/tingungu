class Society {
  final String id;
  final String name;
  final String? circuit;
  final String? location;
  final String? leader;

  Society({
    required this.id,
    required this.name,
    this.circuit,
    this.location,
    this.leader,
  });

  factory Society.fromJson(Map<String, dynamic> json) {
    return Society(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Unknown',
      circuit: json['circuit'],
      location: json['location'],
      leader: json['leader'],
    );
  }

  factory Society.fromMap(Map<String, dynamic> map, String id) {
    return Society(
      id: id,
      name: map['name'] ?? 'Unknown',
      circuit: map['circuit'],
      location: map['location'],
      leader: map['leader'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'circuit': circuit,
    'location': location,
    'leader': leader,
  };
}