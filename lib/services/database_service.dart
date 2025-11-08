import 'package:mysql1/mysql1.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static const String _host = 'localhost';
  static const int _port = 3306;
  static const String _user = 'your_db_user';
  static const String _password = 'your_db_password';
  static const String _database = 'your_db_name';

  static MySqlConnection? _connection;

  Future<MySqlConnection> _getConnection() async {
    if (_connection != null && _connection!.connected) {
      return _connection!;
    }

    final settings = ConnectionSettings(
      host: _host,
      port: _port,
      user: _user,
      password: _password,
      db: _database,
    );

    _connection = await MySqlConnection.connect(settings);
    return _connection!;
  }

  Future<String?> getAccessToken() async {
    try {
      final conn = await _getConnection();
      final results = await conn.query(
        'SELECT token FROM dev_auth_tokens ORDER BY id DESC LIMIT 1',
      );

      if (results.isNotEmpty) {
        return results.first['token'] as String?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching access token: $e');
      }
      return null;
    }
  }

  Future<Map<String, String?>> getAccountDetails() async {
    try {
      final conn = await _getConnection();
      final results = await conn.query(
        'SELECT baseUrl, account_number FROM account_details ORDER BY id DESC LIMIT 1',
      );

      if (results.isNotEmpty) {
        final row = results.first;
        return {
          'baseUrl': row['baseUrl'] as String?,
          'accountNumber': row['account_number'] as String?,
        };
      }
      return {'baseUrl': null, 'accountNumber': null};
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching account details: $e');
      }
      return {'baseUrl': null, 'accountNumber': null};
    }
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}