import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/community_model.dart';

class CommunityService {
  static const String _baseUrl = 'https://yourdomain.com/api/communities';

  /// Get all available communities
  static Future<List<Community>> getAvailableCommunities() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_communities.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<Community> communities = [];
          for (var communityData in data['data']) {
            communities.add(Community.fromJson(communityData));
          }
          return communities;
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching communities: $e');
      }
      return [];
    }
  }

  /// Join community with invitation code
  static Future<Map<String, dynamic>> joinCommunityWithCode(
      String invitationCode,
      int userId,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/join_community.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invitation_code': invitationCode,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to join community',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error joining community: $e');
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user's joined communities
  static Future<List<Community>> getUserCommunities(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_user_communities.php?user_id=$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<Community> communities = [];
          for (var communityData in data['data']) {
            communities.add(Community.fromJson(communityData));
          }
          return communities;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching user communities: $e');
      return [];
    }
  }

  /// Get community details by ID
  static Future<Community?> getCommunityDetails(int communityId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_community_details.php?id=$communityId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return Community.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching community details: $e');
      }
      return null;
    }
  }
}