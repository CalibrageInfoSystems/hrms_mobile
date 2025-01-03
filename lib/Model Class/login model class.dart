class loginmodel {
  final String accessToken;
  final String refreshToken;

  loginmodel({
    required this.accessToken,
    required this.refreshToken
  });

  factory loginmodel.fromJson(Map<String, dynamic> json) {
    return loginmodel(
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken']
    );
  }
}