class AuthConfig {
  static const String issuer = 'http://10.0.2.2:8080/realms/master';
  static const String clientId = 'gatewise-app';
  static const String redirectUri = 'com.gatewise.app://auth';
  static const List<String> scopes = ['openid', 'profile', 'email'];
}
