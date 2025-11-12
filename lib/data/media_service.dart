import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'media_video_model.dart';

class MediaService {
  static const String _baseUrl = 'https://yourdomain.com/api/media';

  /// Get latest media videos (for home page)
  static Future<List<MediaVideo>> getLatestVideos({int limit = 5}) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_latest_videos.php?limit=$limit'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<MediaVideo> videos = [];
          for (var videoData in data['data']) {
            videos.add(MediaVideo.fromJson(videoData));
          }
          return videos;
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching latest videos: $e');
      }
      return [];
    }
  }

  /// Get all media videos (for media page)
  static Future<List<MediaVideo>> getAllVideos() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_all_videos.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<MediaVideo> videos = [];
          for (var videoData in data['data']) {
            videos.add(MediaVideo.fromJson(videoData));
          }
          return videos;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching all videos: $e');
      return [];
    }
  }

  /// Format date to relative time
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}m ago';
    }
  }
}