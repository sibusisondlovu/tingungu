import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PurchaseAirtimeService {
  static const String _baseUrl = 'https://api-flashswitch-sandbox.flash-group.com';
  static const String _accountNumber = '3538-3478-8620-0385';

  Future<String> _getAccessToken() async {
    return 'e9f82b7e-8d92-3b96-9a9e-4337c945a17f';
  }

  Future<Map<String, dynamic>> purchaseAirtime({
    required int productCode,
    required int amount,
    required String mobileNumber,
  }) async {
    try {
      final reference = FirebaseFirestore.instance.collection('transactions').doc().id;
      final token = await _getAccessToken();

      final url = Uri.parse('$_baseUrl/aggregation/4.0/cellular/pinless/purchase');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      final body = jsonEncode({
        "reference": reference,
        "accountNumber": _accountNumber,
        "amount": amount,
        "productCode": productCode,
        "mobileNumber": mobileNumber
      });

      final response = await http.post(url, headers: headers, body: body);

      if (kDebugMode) {
        print('Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse = jsonDecode(response.body);
        final rechargeDetails = decodedResponse['rechargeDetails'];
        final rechargeType = rechargeDetails?['rechargeType'];
        final amount = decodedResponse['amount'];
        final responseCode = decodedResponse['responseCode'];
        final mobileNumber = decodedResponse['mobileNumber'];
        final responseMessage = decodedResponse['responseMessage'];
        final transactionId = decodedResponse['transactionId'];

        if (responseCode == 2335) {
          return {
            'success': true,
            'amount': amount,
            'responseCode': responseCode,
            'responseMessage': responseMessage,
            'transactionId': transactionId,
            'mobileNumber': mobileNumber
          };
        } else {
          return {
            'success': true,
            'rechargeType': rechargeType,
            'amount': amount,
            'responseCode': responseCode,
            'responseMessage': responseMessage,
            'transactionId': transactionId,
            'mobileNumber': mobileNumber
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'statusCode': 401,
          'message': 'Access failure for API',
          'description': 'Invalid Credentials. Make sure you have given the correct access token'
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': 'Purchase failed',
          'description': response.body
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error purchasing airtime: $e');
      }
      return {
        'success': false,
        'message': 'An error occurred',
        'description': e.toString()
      };
    }
  }
}