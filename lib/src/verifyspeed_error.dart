class VerifySpeedError {
  const VerifySpeedError(
    this.message,
    this.type,
  );

  final String? message;
  final VerifySpeedErrorType type;
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
      case 'ActiveSessionNotFound':
        return activeSessionNotFound;
      default:
        return unknown;
    }
  }
}
