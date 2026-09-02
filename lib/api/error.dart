class AzkarException implements Exception {
  final String message;
  const AzkarException(this.message);

  @override
  String toString() => message;
}
