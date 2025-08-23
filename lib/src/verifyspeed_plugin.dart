import 'package:flutter/services.dart';
import 'package:flutter_verifyspeed_plugin/flutter_verifyspeed_plugin.dart';

final class VerifySpeedPlugin {
  VerifySpeedPlugin._();

  static final instance = VerifySpeedPlugin._();
  final channel = const MethodChannel('verifyspeed_channel');

  String? clientKey;

  void setClientKey(String clientKey) => this.clientKey = clientKey;

  Future<String?> initialize() async {
    if (clientKey == null || clientKey!.isEmpty) {
      throw const VerifySpeedError(
        'Client key is empty',
        VerifySpeedErrorType.clientKeyNotSet,
      );
    }

    final result = await channel.invokeMethod(
      'initialize',
      {'clientKey': clientKey},
    );

    if (result is Map) {
      final error = result['error'];
      final errorType = VerifySpeedErrorType.fromString(
        result['errorType'] as String?,
      );

      throw VerifySpeedError(error.toString(), errorType);
    }

    return result;
  }

  Future<void> verifyPhoneNumberWithDeepLink({
    required String deepLink,
    required String verificationKey,
    bool redirectToStore = true,
    required void Function(String token) onSuccess,
    required void Function(VerifySpeedError error) onFailure,
  }) async {
    final result = await channel.invokeMethod(
      'verifyPhoneNumberWithDeepLink',
      {
        'deepLink': deepLink,
        'verificationKey': verificationKey,
        'redirectToStore': redirectToStore,
      },
    );

    _checkResult(
      result: result,
      onFailure: onFailure,
      onSuccess: onSuccess,
    );
  }

  Future<void> verifyPhoneNumberWithOtp({
    required String phoneNumber,
    required String verificationKey,
  }) async {
    final result = await channel.invokeMethod(
      'verifyPhoneNumberWithOtp',
      {
        'phoneNumber': phoneNumber,
        'verificationKey': verificationKey,
      },
    );

    if (result is Map) {
      final data = Map<String, dynamic>.from(result);

      final error = data['error'];
      final errorType = VerifySpeedErrorType.fromString(
        data['errorType'] as String?,
      );

      if (error != null) {
        throw VerifySpeedError(error.toString(), errorType);
      }

      return;
    }
  }

  Future<void> notifyOnResumed() async {
    final result = await channel.invokeMethod('notifyOnResumed');

    if (result['error'] != null) {
      throw VerifySpeedError(
        'Error Message: ${result['error']}',
        VerifySpeedErrorType.fromString(result['errorType'] as String?),
      );
    }
  }

  Future<void> validateOtp({
    required String verificationKey,
    required String otpCode,
    required void Function(String token) onSuccess,
    required void Function(VerifySpeedError error) onFailure,
  }) async {
    final result = await channel.invokeMethod(
      'validateOtp',
      {
        'verificationKey': verificationKey,
        'otpCode': otpCode,
      },
    );

    _checkResult(
      result: result,
      onFailure: onFailure,
      onSuccess: onSuccess,
    );
  }

  Future<void> checkInterruptedSession({
    required void Function(String token) onSuccess,
  }) async {
    final result = await channel.invokeMethod('checkInterruptedSession');

    _checkResult(
      result: result,
      onSuccess: onSuccess,
    );
  }

  void _checkResult({
    required dynamic result,
    void Function(String)? onSuccess,
    void Function(VerifySpeedError)? onFailure,
  }) {
    try {
      if (result is Map) {
        final token = result['token'];
        final error = result['error'];
        final errorType =
            VerifySpeedErrorType.fromString(result['errorType'] as String?);
        final verifySpeedError = VerifySpeedError(error.toString(), errorType);

        if (token is String? && token != null && token.isNotEmpty) {
          onSuccess?.call(token);

          return;
        } else if (error != null && onFailure != null) {
          onFailure.call(verifySpeedError);

          return;
        } else if (error != null && onFailure == null) {
          throw verifySpeedError;
        }
      }
    } catch (error) {
      if (onFailure != null) {
        onFailure.call(
          VerifySpeedError(
            error.toString(),
            VerifySpeedErrorType.unknown,
          ),
        );

        return;
      }

      rethrow;
    }
  }
}
