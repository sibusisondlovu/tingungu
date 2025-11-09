import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'config_service.dart';


class PurchaseAirtimeService {
  final ConfigService _configService = ConfigService();

  Future<Map<String, dynamic>> purchaseAirtime({
    required int productCode,
    required int amount,
    required String mobileNumber,
  }) async {
    try {
      final config = await _configService.getConfig();

      if (config == null || !config.isValid()) {
        return {
          'success': false,
          'message': 'Configuration not available',
          'description': 'Unable to retrieve API configuration'
        };
      }

      final reference = FirebaseFirestore.instance.collection('transactions').doc().id;

      final url = Uri.parse('${config.baseUrl}/aggregation/4.0/cellular/pinless/purchase');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${config.token}',
      };
      final body = jsonEncode({
        "reference": reference,
        "accountNumber": config.accountNumber,
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
        _configService.clearCache();
        return {
          'success': false,
          'statusCode': 401,
          'message': 'Access failure for API',
          'description': 'Invalid Credentials. Token may have expired'
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