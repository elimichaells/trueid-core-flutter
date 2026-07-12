import 'package:flutter/services.dart';
import 'models.dart';

/// Shared entry point for the TrueID Flutter SDKs.
///
/// Call [initialize] once (e.g. before `runApp`) and every TrueID product
/// package — `trueid_nia_sdk`, `trueid_hosted_sdk`, `trueid_document_sdk`,
/// `trueid_nfc_sdk` — uses the same configuration.
///
/// ```dart
/// await TrueIdSdk.initialize(
///   secretKey: 'sk_your_secret_key',
///   publishableKey: 'pk_your_publishable_key',
/// );
/// ```
class TrueIdSdk {
  static const MethodChannel _channel =
      MethodChannel('com.trueid.sdk.core/flutter');

  TrueIdSdk._();

  /// Initialize with your API key(s) from app.trueid.info → Settings → API.
  ///
  /// The two keys are not interchangeable server-side: native verification
  /// flows use the [secretKey], the hosted browser flow and verification
  /// saves use the [publishableKey]. Pass whichever the products you use
  /// require — at least one must be provided.
  ///
  /// [environment] — Target environment (defaults to production).
  /// [customBaseUrl] — Required when environment is [TrueIdEnvironment.custom].
  static Future<void> initialize({
    String? secretKey,
    String? publishableKey,
    TrueIdEnvironment environment = TrueIdEnvironment.production,
    String? customBaseUrl,
  }) async {
    await _channel.invokeMethod('initialize', {
      'secretKey': secretKey,
      'publishableKey': publishableKey,
      'environment': environment.name,
      'customBaseUrl': customBaseUrl,
    });
  }

  /// Launch standalone selfie capture (no verification, no API key needed).
  ///
  /// Returns a [SelfieCaptureResult] on success, or `null` if cancelled.
  static Future<SelfieCaptureResult?> captureSelfie({
    SelfieCaptureConfig config = const SelfieCaptureConfig(),
  }) async {
    try {
      final result =
          await _channel.invokeMethod('captureSelfie', config.toMap());
      if (result == null) return null;
      return SelfieCaptureResult.fromMap(Map<dynamic, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw TrueIdException(
        code: e.code,
        message: e.message ?? 'Capture failed',
      );
    }
  }
}
