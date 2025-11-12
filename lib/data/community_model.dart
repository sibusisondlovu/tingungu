class Community {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final int memberCount;
  final String status;
  final bool isPublic;
  final DateTime createdAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.memberCount,
    required this.status,
    required this.isPublic,
    required this.createdAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      memberCount: json['member_count'] ?? 0,
      status: json['status'] ?? 'active',
      isPublic: json['is_public'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}