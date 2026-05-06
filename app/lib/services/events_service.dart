import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/event_model.dart';

class EventService {
  static const String _baseUrl = 'https://backend.tingungu.co.za';

  /// Get all events
  static Future<List<Event>> getAllEvents() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_all_events.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<Event> events = [];
          for (var eventData in data['data']) {
            events.add(Event.fromJson(eventData));
          }
          return events;
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all events: $e');
      }
      return [];
    }
  }

  /// Get events for a specific month
  static Future<List<Event>> getEventsByMonth(String month) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/get_events_by_month.php?month=$month'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<Event> events = [];
          for (var eventData in data['data']) {
            events.add(Event.fromJson(eventData));
          }
          return events;
        }
      }

      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching events by month: $e');
      }
      return [];
    }
  }
}