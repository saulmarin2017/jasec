class TokenInfo {
  String accessToken;
  String tokenType;
  DateTime expiration;

  TokenInfo({
    required this.accessToken,
    required this.tokenType,
    required this.expiration,
  });

  bool get isExpired => DateTime.now().isAfter(expiration);

  factory TokenInfo.fromJson(Map<String, dynamic> json) {
    return TokenInfo(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
      expiration: DateTime.now().add(Duration(seconds: json['expires_in'])),
    );
  }
}
