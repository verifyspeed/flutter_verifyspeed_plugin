import 'package:flutter/services.dart';
import 'package:flutter_verifyspeed_plugin/flutter_verifyspeed_plugin.dart';

final class VerifySpeedPlugin {
  VerifySpeedPlugin._();

  static final instance = VerifySpeedPlugin._();
  final channel = const MethodChannel('verifyspeed_channel');

  late String? _clientKey;
  late void Function(String token) onSuccess;
  late void Function(VerifySpeedError error) onFailure;

  void setClientKey(String clientKey) async {
    _clientKey = clientKey;
  }

  Future<String?> getUiFromApi() async {
    try {
      _checkClientKey();

      final result = await channel.invokeMethod(
        'getUiFromApi',
        {
          'clientKey': _clientKey,
        },
      );

      return result;
    } catch (error) {
      onFailure(
        VerifySpeedError(
          error.toString(),
          VerifySpeedErrorType.unknown,
        ),
      );
    }

    return null;
  }

  Future<void> startVerification({
    required void Function(String token) onSuccess,
    required void Function(VerifySpeedError error) onFailure,
    required VerifySpeedMethodType type,
    bool redirectToStore = true,
  }) async {
    try {
      this.onSuccess = onSuccess;
      this.onFailure = onFailure;

      _checkClientKey();

      final result = await channel.invokeMethod(
        'startVerification',
        {
          'clientKey': _clientKey,
          'type': type.value,
          'redirectToStore': redirectToStore,
        },
      );

      _checkResult(
        result: result,
        onFailure: onFailure,
        onSuccess: onSuccess,
      );
    } catch (error) {
      onFailure(
        VerifySpeedError(
          error.toString(),
          VerifySpeedErrorType.unknown,
        ),
      );
    }
  }

  Future<void> startVerificationWithDeepLink({
    required void Function(String token) onSuccess,
    required void Function(VerifySpeedError error) onFailure,
    required String deepLink,
    required String verificationKey,
    required String verificationName,
    bool redirectToStore = true,
  }) async {
    try {
      this.onSuccess = onSuccess;
      this.onFailure = onFailure;

      final result = await channel.invokeMethod(
        'startVerificationWithDeepLink',
        {
          'deepLink': deepLink,
          'verificationKey': verificationKey,
          'verificationName': verificationName,
          'redirectToStore': redirectToStore,
        },
      );

      _checkResult(
        result: result,
        onFailure: onFailure,
        onSuccess: onSuccess,
      );
    } catch (error) {
      onFailure(
        VerifySpeedError(
          error.toString(),
          VerifySpeedErrorType.unknown,
        ),
      );
    }
  }

  Future<void> notifyOnResumed() async {
    try {
      final result = await channel.invokeMethod('notifyOnResumed');

      if (result['error'] != null) {
        throw VerifySpeedError(
          'Error Message: ${result['error']}',
          VerifySpeedErrorType.fromString(result['errorType'] as String?),
        );
      }
    } catch (error) {
      onFailure(
        VerifySpeedError(
          error.toString(),
          VerifySpeedErrorType.unknown,
        ),
      );
    }
  }

  Future<void> checkInterruptedSession({
    required void Function(String token) onSuccess,
    required void Function(VerifySpeedError error) onFailure,
  }) async {
    try {
      this.onSuccess = onSuccess;
      this.onFailure = onFailure;

      final result = await channel.invokeMethod('checkInterruptedSession');

      _checkResult(
        result: result,
        onFailure: onFailure,
        onSuccess: onSuccess,
      );
    } catch (error) {
      onFailure(
        VerifySpeedError(
          error.toString(),
          VerifySpeedErrorType.unknown,
        ),
      );
    }
  }

  void _checkResult({
    required Map<Object?, Object?> result,
    required void Function(String) onSuccess,
    required void Function(VerifySpeedError) onFailure,
  }) {
    try {
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

      this.onFailure(
        VerifySpeedError(
          'Token is null',
          errorType,
        ),
      );
    } catch (error) {
      this.onFailure(
        VerifySpeedError(
          error.toString(),
          VerifySpeedErrorType.unknown,
        ),
      );
    }
  }

  void _checkClientKey() {
    if (_clientKey == null || _clientKey!.isEmpty) {
      throw const VerifySpeedError(
        'Please set your VerifySpeed client key first',
        VerifySpeedErrorType.clientKeyNotSet,
      );
    }
  }
}
