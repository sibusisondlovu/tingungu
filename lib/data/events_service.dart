// File: lib/services/events_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/church_event_model.dart';

class EventsService {
  // CHANGE THIS TO YOUR API ENDPOINT
  static const String _baseUrl = 'https://yourdomain.com/api/events/get_upcoming_events.php';

  /// Fetch upcoming events from API
  static Future<List<ChurchEvent>> getUpcomingEvents() async {
    try {
      final response = await http
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] is List) {
          List<ChurchEvent> events = [];

          for (var eventData in data['data']) {
            events.add(
              ChurchEvent(
                title: eventData['title'] ?? 'Event',
                date: _formatDate(eventData['date']),
                time: _formatTime(eventData['time']),
                location: eventData['location'] ?? 'TBD',
              ),
            );
          }

          return events;
        }
      }

      return _getDefaultEvents();
    } catch (e) {
      print('Error fetching events: $e');
      return _getDefaultEvents();
    }
  }

  /// Format date from YYYY-MM-DD to readable format
  static String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  /// Format time from HH:MM:SS to readable format
  static String _formatTime(String time) {
    try {
      final timeParts = time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = timeParts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return time;
    }
  }

  /// Fallback default events
  static List<ChurchEvent> _getDefaultEvents() {
    return [
      ChurchEvent(
        title: 'Sunday Service',
        date: 'Nov 10, 2024',
        time: '9:00 AM',
        location: 'Main Hall',
      ),
      ChurchEvent(
        title: 'Youth Group Meeting',
        date: 'Nov 12, 2024',
        time: '6:00 PM',
        location: 'Fellowship Room',
      ),
      ChurchEvent(
        title: 'Bible Study',
        date: 'Nov 15, 2024',
        time: '7:30 PM',
        location: 'Online',
      ),
    ];
  }
}