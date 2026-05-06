import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/event_model.dart';

class EventService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all events from Firestore
  static Future<List<Event>> getAllEvents() async {
    try {
      final snapshot = await _db
          .collection('events')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching all events: $e');
      }
      return [];
    }
  }

  /// Get events for a specific month from Firestore
  static Future<List<Event>> getEventsByMonth(String month) async {
    try {
      final snapshot = await _db
          .collection('events')
          .where('month', isEqualTo: month)
          .get();

      final events = snapshot.docs
          .map((doc) => Event.fromMap(doc.data(), doc.id))
          .toList();
          
      // Sort manually by date_start since it's a string in the current schema
      events.sort((a, b) {
        int dayA = int.tryParse(a.dateStart) ?? 0;
        int dayB = int.tryParse(b.dateStart) ?? 0;
        return dayA.compareTo(dayB);
      });
      
      return events;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching events by month: $e');
      }
      return [];
    }
  }
}