import 'package:flutter/foundation.dart';

class MediaVideo {
  final int id;
  final String title;
  final String youtubeUrl;
  final String description;
  final DateTime dateAdded;

  MediaVideo({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.description,
    required this.dateAdded,

  });

  factory MediaVideo.fromJson(Map<String, dynamic> json) {
    String url = json['youtube_url'] ?? '';

    return MediaVideo(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      youtubeUrl: url,
      description: json['description'] ?? '',
      dateAdded: DateTime.tryParse(json['date_added'] ?? '') ?? DateTime.now(),
    );
  }
}