enum FailureType {
  network,
  unauthorized,
  validation,
  storage,
  integrity,
  system,
  configuration,
  unknown,
}

final class Failure {
  const Failure(this.type, this.message, {this.code});
  final FailureType type;
  final String message;
  final String? code;
}
