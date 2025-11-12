import 'circuit_model.dart';

class Society {
  final int id;
  final String name;
  final Circuit circuit;


  Society({
    required this.id,
    required this.name,
    required this.circuit,

  });

  factory Society.fromJson(Map<String, dynamic> json) {
    return Society(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      circuit: Circuit.fromJson(json['circuit'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'circuit': {
      'id': circuit.id,
      'name': circuit.name,
      'category': circuit.category,
      'leader': {
        'id': circuit.leader.id,
        'firstName': circuit.leader.firstName,
        'lastName': circuit.leader.lastName,
        'cellNumber': circuit.leader.cellNumber,
        'email': circuit.leader.email,
      },
    },
  };
}