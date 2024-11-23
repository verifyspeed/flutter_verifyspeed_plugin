import 'package:flutter/services.dart';
import 'package:flutter_verifyspeed_plugin/flutter_verifyspeed_plugin.dart';

final class VerifySpeedPlugin {
  VerifySpeedPlugin._();

  static final instance = VerifySpeedPlugin._();
  final channel = const MethodChannel('verifyspeed_channel');

  late void Function(String token) onSuccess;
  late void Function(VerifySpeedError error) onFailure;
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

    return result;
  }

  Future<void> verifyPhoneNumberWithDeepLink({
    required String deepLink,
    required String verificationKey,
    bool redirectToStore = true,
    required void Function(String token) onSuccess,
    required void Function(VerifySpeedError error) onFailure,
  }) async {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;

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

    _checkResult(result: result);
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
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;

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
    required void Function(VerifySpeedError error) onFailure,
  }) async {
    this.onSuccess = onSuccess;
    this.onFailure = onFailure;

    final result = await channel.invokeMethod('checkInterruptedSession');

    _checkResult(
      result: result,
      onFailure: onFailure,
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

        if (token is String? && token != null && token.isNotEmpty) {
          this.onSuccess(token);

          return;
        } else if (error != null) {
          this.onFailure(
            VerifySpeedError(
              error.toString(),
              errorType,
            ),
          );

          return;
        }

        onFailure?.call(
          VerifySpeedError(
            'Token is null',
            errorType,
          ),
        );
      }
    } catch (error) {
      onFailure?.call(
        VerifySpeedError(
          error.toString(),
          VerifySpeedErrorType.unknown,
        ),
      );
    }
  }
}
