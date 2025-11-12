import 'circuit_leader_model.dart';

class Circuit {
  final int id;
  final String name;
  final String category;
  final CircuitLeader leader;

  Circuit({
    required this.id,
    required this.name,
    required this.category,
    required this.leader,
  });

  factory Circuit.fromJson(Map<String, dynamic> json) {
    return Circuit(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      category: json['category'] ?? '',
      leader: CircuitLeader.fromJson(json['leader'] ?? {}),
    );
  }
}