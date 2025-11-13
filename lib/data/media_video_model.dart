import 'package:flutter/foundation.dart';

class MediaVideo {
  final int id;
  final String title;
  final String youtubeUrl;
  final String? description;
  final DateTime dateAdded;
  final String thumbnailUrl;

  MediaVideo({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.description,
    required this.dateAdded,
    required this.thumbnailUrl,
  });

  factory MediaVideo.fromJson(Map<String, dynamic> json) {
    String url = json['youtube_url'] ?? '';
    String videoId = _extractVideoId(url);

    return MediaVideo(
      id: int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? 'Untitled',
      youtubeUrl: url,
      description: json['description'] ?? '',
      dateAdded: DateTime.tryParse(json['date_added'] ?? '') ?? DateTime.now(),
      thumbnailUrl: 'https://img.youtube.com/vi/$videoId/mqdefault.jpg',
    );
  }

  /// Extract video ID from YouTube URL
  static String _extractVideoId(String url) {
    try {
      if (url.contains('youtu.be/')) {
        return url.split('youtu.be/').last.split('?').first;
      } else if (url.contains('youtube.com/watch')) {
        return url.split('v=').last.split('&').first;
      } else if (url.contains('youtube.com/embed/')) {
        return url.split('embed/').last.split('?').first;
      } else if (url.contains('youtube.com/live/')) {
        return url.split('live/').last.split('?').first;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting video ID: $e');
      }
    }
    return '';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'youtube_url': youtubeUrl,
    'description': description,
    'date_added': dateAdded.toIso8601String(),
  };
}