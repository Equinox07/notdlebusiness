class LoginResponse {
  final String token;
  final String? tokenType;
  final int? expiryTime;
  final DateTime? expiryDateTime;
  final String? refreshToken;

  LoginResponse({
    required this.token,
    this.tokenType,
    this.expiryTime,
    this.expiryDateTime,
    this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      tokenType: json['tokenType'] as String?,
      expiryTime: json['expiryTime'] as int?,
      expiryDateTime:
          json['expiryDateTime'] != null
              ? DateTime.parse(json['expiryDateTime'] as String)
              : null,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (tokenType != null) 'tokenType': tokenType,
      if (expiryTime != null) 'expiryTime': expiryTime,
      if (expiryDateTime != null)
        'expiryDateTime': expiryDateTime?.toIso8601String(),
      if (refreshToken != null) 'refreshToken': refreshToken,
    };
  }
}

class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}
