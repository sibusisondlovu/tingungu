import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../data/api_config.dart';


class ConfigService {
  static const String configUrl = 'https://projects.jaspahost.co.za/get_config.php';
  static ApiConfig? _cachedConfig;
  static DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  Future<ApiConfig?> getConfig({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _cachedConfig != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _cachedConfig;
    }

    try {
      final response = await http.get(Uri.parse(configUrl));

      if (kDebugMode) {
        print('Config API Status Code: ${response.statusCode}');
        print('Config API Response: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          _cachedConfig = ApiConfig.fromJson(jsonResponse['data']);
          _lastFetchTime = DateTime.now();
          return _cachedConfig;
        } else {
          if (kDebugMode) {
            print('Config API Error: ${jsonResponse['message']}');
          }
          return null;
        }
      } else {
        if (kDebugMode) {
          print('Failed to fetch config: ${response.statusCode}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching config: $e');
      }
      return null;
    }
  }

  void clearCache() {
    _cachedConfig = null;
    _lastFetchTime = null;
  }
}