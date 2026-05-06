import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  static const String _baseUrl = 'https://backend.tingungu.co.za';

  static Future<Map<String, dynamic>> getUserProfile({
    required String userId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/get_user_profile.php?user_id=$userId');

      final response = await http.get(url);

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to get user profile',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String displayName,
    String? societyName,
  }) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return {
          'success': false,
          'error': 'Failed to create Firebase user',
        };
      }

      await userCredential.user!.updateDisplayName(displayName);

      final userId = userCredential.user!.uid;

      final url = Uri.parse('$_baseUrl/create_user.php');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'display_name': displayName,
          'email': email,
          'wallet_balance': 0.00,
          'society_name': societyName,
        }),
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': data['user'],
          'firebase_user': userCredential.user,
        };
      } else {
        await userCredential.user!.delete();

        return {
          'success': false,
          'error': data['error'] ?? 'Failed to create user in database',
        };
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for this email';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Email/password accounts are not enabled';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user: $e');
      }

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await currentUser.delete();
        }
      } catch (deleteError) {
        if (kDebugMode) {
          print('Error deleting Firebase user: $deleteError');
        }
      }

      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    String? displayName,
    String? phone,
    String? societyName,
    String? avatar,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/update_user_profile.php');

      final Map<String, dynamic> body = {'user_id': userId};
      if (displayName != null) body['display_name'] = displayName;
      if (phone != null) body['phone'] = phone;
      if (societyName != null) body['society_name'] = societyName;
      if (avatar != null) body['avatar'] = avatar;

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to update user profile',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      }
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      final UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        return {
          'success': false,
          'error': 'Failed to sign in',
        };
      }

      final userId = userCredential.user!.uid;

      final profileResult = await getUserProfile(userId: userId);

      if (profileResult['success'] == true) {
        return {
          'success': true,
          'user': profileResult['user'],
          'firebase_user': userCredential.user,
        };
      } else {
        return {
          'success': false,
          'error': 'User profile not found in database',
        };
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      }

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is invalid';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }

      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in user: $e');
      }
      return {
        'success': false,
        'error': 'Network error: ${e.toString()}',
      };
    }
  }

  static Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }
}