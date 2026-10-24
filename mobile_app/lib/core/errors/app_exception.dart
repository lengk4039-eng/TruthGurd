/// Thrown by repositories on a handled failure (bad credentials, no match,
/// etc.) so screens can show `error.message` directly instead of a generic
/// "something went wrong".
class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}
