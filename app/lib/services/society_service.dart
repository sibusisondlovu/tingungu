import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/society_model.dart';

class SocietyService {
  static const String _baseUrl = 'https://yourdomain.com/api/societies';

  /// Get all available societies
  static Future<List<Society>> getAllSocieties() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_all_societies.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<Society> societies = [];
          for (var societyData in data['data']) {
            societies.add(Society.fromJson(societyData));
          }
          return societies;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching societies: $e');
      return [];
    }
  }

  /// Search societies by name or circuit
  static Future<List<Society>> searchSocieties(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http
          .get(Uri.parse('$_baseUrl/search_societies.php?q=$encodedQuery'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<Society> societies = [];
          for (var societyData in data['data']) {
            societies.add(Society.fromJson(societyData));
          }
          return societies;
        }
      }

      return [];
    } catch (e) {
      print('Error searching societies: $e');
      return [];
    }
  }

  /// Get societies by circuit
  static Future<List<Society>> getSocietiesByCircuit(int circuitId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_circuit_societies.php?circuit_id=$circuitId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<Society> societies = [];
          for (var societyData in data['data']) {
            societies.add(Society.fromJson(societyData));
          }
          return societies;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching circuit societies: $e');
      return [];
    }
  }

  /// Join a society
  static Future<Map<String, dynamic>> joinSociety(
      int userId,
      int societyId,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/join_society.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
          'society_id': societyId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to join society',
        };
      }
    } catch (e) {
      print('Error joining society: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user's society
  static Future<Society?> getUserSociety(int userId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_user_society.php?user_id=$userId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          return Society.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user society: $e');
      }
      return null;
    }
  }

  /// Leave society
  static Future<Map<String, dynamic>> leaveSociety(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/leave_society.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to leave society',
        };
      }
    } catch (e) {
      print('Error leaving society: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}