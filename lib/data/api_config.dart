class ApiConfig {
  final String token;
  final String? expiresAt;
  final String baseUrl;
  final String accountNumber;

  ApiConfig({
    required this.token,
    this.expiresAt,
    required this.baseUrl,
    required this.accountNumber,
  });

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      token: json['token'] ?? '',
      expiresAt: json['expires_at'],
      baseUrl: json['baseUrl'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'expires_at': expiresAt,
      'baseUrl': baseUrl,
      'accountNumber': accountNumber,
    };
  }

  bool isValid() {
    return token.isNotEmpty &&
        baseUrl.isNotEmpty &&
        accountNumber.isNotEmpty;
  }
}