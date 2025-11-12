import 'package:flutter/foundation.dart';

class MediaVideo {
  final int id;
  final String title;
  final String youtubeUrl;
  final String videoId;
  final String description;
  final DateTime dateAdded;
  final String thumbnailUrl;

  MediaVideo({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.videoId,
    required this.description,
    required this.dateAdded,
    required this.thumbnailUrl,
  });

  factory MediaVideo.fromJson(Map<String, dynamic> json) {
    String url = json['youtube_url'] ?? '';
    String videoId = _extractVideoId(url);

    return MediaVideo(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      youtubeUrl: url,
      videoId: videoId,
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
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error extracting video ID: $e');
      }
    }
    return '';
  }
}