class SessionExpiredException implements Exception {
  final String message = 'Session expired, need re-authentication.';
  @override
  String toString() => 'SessionExpiredException: $message';
}
