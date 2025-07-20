sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String token;
  AuthAuthenticated(this.token);
}

class AuthUnauthenticated extends AuthState {
  final String? error;
  AuthUnauthenticated({this.error});
}
