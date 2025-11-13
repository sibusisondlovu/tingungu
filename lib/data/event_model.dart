import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Event {
  final int id;
  final String month;
  final String dateStart;
  final String? dateEnd;
  final String description;
  final String? venue;

  Event({
    required this.id,
    required this.month,
    required this.dateStart,
    this.dateEnd,
    required this.description,
    this.venue,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: int.tryParse(json['id'].toString()) ?? 0,
      month: json['month'] ?? '',
      dateStart: json['date_start'] ?? '',
      dateEnd: json['date_end'],
      description: json['description'] ?? '',
      venue: json['venue'],
    );
  }
}