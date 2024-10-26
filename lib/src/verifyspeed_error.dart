class VerifySpeedError {
  const VerifySpeedError(
    this.message,
    this.type,
  );

  final String? message;
  final VerifySpeedErrorType type;

  @override
  String toString() => 'VerifySpeedError(message: $message, type: $type)';

  @override
  bool operator ==(covariant VerifySpeedError other) {
    if (identical(this, other)) return true;

    return other.message == message && other.type == type;
  }

  @override
  int get hashCode => message.hashCode ^ type.hashCode;
}

enum VerifySpeedErrorType {
  unknown,
  server,
  client,
  appNotInstalled,
  verificationFailed,
  clientKeyNotSet,
  notFoundVerificationMethod,
  invalidDeepLink,
  invalidPhoneNumber,
  activeSessionNotFound;

  const VerifySpeedErrorType();

  static VerifySpeedErrorType fromString(String? value) {
    switch (value) {
      case 'Server':
        return server;
      case 'Client':
        return client;
      case 'AppNotInstalled':
        return appNotInstalled;
      case 'VerificationFailed':
        return verificationFailed;
      case 'ClientKeyNotSet':
        return clientKeyNotSet;
      case 'NotFoundVerificationMethod':
        return notFoundVerificationMethod;
      case 'InvalidDeepLink':
        return invalidDeepLink;
      case 'InvalidPhoneNumber':
        return invalidPhoneNumber;
      case 'ActiveSessionNotFound':
        return activeSessionNotFound;
      default:
        return unknown;
    }
  }
}
