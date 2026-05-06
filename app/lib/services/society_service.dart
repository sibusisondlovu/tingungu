import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/society_model.dart';

class SocietyService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all available societies from Firestore
  static Future<List<Society>> getAllSocieties() async {
    try {
      final snapshot = await _db.collection('societies').get();
      return snapshot.docs
          .map((doc) => Society.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching societies: $e');
      }
      return [];
    }
  }

  /// Search societies by name or circuit in Firestore
  static Future<List<Society>> searchSocieties(String query) async {
    try {
      // Note: Firestore doesn't support partial string search natively easily
      // We'll fetch and filter client-side for now as the list is small
      final all = await getAllSocieties();
      return all.where((s) =>
        s.name.toLowerCase().contains(query.toLowerCase()) ||
        (s.circuit?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching societies: $e');
      }
      return [];
    }
  }

  /// Get societies by circuit (from Firestore)
  static Future<List<Society>> getSocietiesByCircuit(String circuit) async {
    try {
      final snapshot = await _db
          .collection('societies')
          .where('circuit', isEqualTo: circuit)
          .get();
          
      return snapshot.docs
          .map((doc) => Society.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching circuit societies: $e');
      }
      return [];
    }
  }

  /// Join a society (Update user profile in Firestore)
  static Future<Map<String, dynamic>> joinSociety(
      String userId,
      String societyName,
      ) async {
    try {
      await _db.collection('users').doc(userId).update({
        'society': societyName,
      });

      return {
        'success': true,
        'message': 'Joined society successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error joining society: $e');
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Get user's society from Firestore
  static Future<Society?> getUserSociety(String userId) async {
    try {
      final userDoc = await _db.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data()?.containsKey('society') == true) {
        final societyName = userDoc.data()!['society'];
        
        // Find the society object by name
        final snapshot = await _db
            .collection('societies')
            .where('name', isEqualTo: societyName)
            .limit(1)
            .get();
            
        if (snapshot.docs.isNotEmpty) {
          return Society.fromMap(snapshot.docs.first.data(), snapshot.docs.first.id);
        }
        
        // Return a virtual society if only name exists but not in the master list
        return Society(id: 'virtual', name: societyName);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user society: $e');
      }
      return null;
    }
  }

  /// Leave society (Update user profile in Firestore)
  static Future<Map<String, dynamic>> leaveSociety(String userId) async {
    try {
      await _db.collection('users').doc(userId).update({
        'society': FieldValue.delete(),
      });

      return {
        'success': true,
        'message': 'Left society successfully',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving society: $e');
      }
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}