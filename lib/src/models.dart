/// Environment for the TrueID SDKs.
enum TrueIdEnvironment {
  production,
  staging,
  custom,
}

/// Capture mode for the selfie camera.
enum CaptureMode {
  auto,
  manual,
}

/// Camera facing direction.
enum CameraFacing {
  front,
  back,
}

/// Result format for standalone selfie capture.
enum ResultFormat {
  byteArray,
  filePath,
  base64,
  all,
}

/// Configuration for the selfie camera.
class SelfieCaptureConfig {
  final CaptureMode captureMode;
  final CameraFacing initialCamera;
  final bool allowCameraSwitch;
  final bool showFaceMesh;
  final int outputWidth;
  final int outputHeight;
  final int jpegQuality;
  final int burstFrameCount;
  final int burstFrameDelayMs;
  final ResultFormat resultFormat;

  const SelfieCaptureConfig({
    this.captureMode = CaptureMode.auto,
    this.initialCamera = CameraFacing.front,
    this.allowCameraSwitch = true,
    this.showFaceMesh = true,
    this.outputWidth = 600,
    this.outputHeight = 800,
    this.jpegQuality = 94,
    this.burstFrameCount = 4,
    this.burstFrameDelayMs = 90,
    this.resultFormat = ResultFormat.base64,
  });

  Map<String, dynamic> toMap() => {
        'captureMode': captureMode.name,
        'initialCamera': initialCamera.name,
        'allowCameraSwitch': allowCameraSwitch,
        'showFaceMesh': showFaceMesh,
        'outputWidth': outputWidth,
        'outputHeight': outputHeight,
        'jpegQuality': jpegQuality,
        'burstFrameCount': burstFrameCount,
        'burstFrameDelayMs': burstFrameDelayMs,
        'resultFormat': resultFormat.name,
      };
}

/// Result of a standalone selfie capture.
class SelfieCaptureResult {
  /// Raw image bytes (when resultFormat includes BYTE_ARRAY or ALL).
  final List<int>? imageBytes;

  /// Base64-encoded principal selfie (when resultFormat includes BASE64 or ALL).
  final String? base64;

  /// Base64-encoded burst frames captured around the principal selfie.
  final List<String>? burstFrames;

  /// File path to saved image (when resultFormat includes FILE_PATH or ALL).
  final String? filePath;

  const SelfieCaptureResult({
    this.imageBytes,
    this.base64,
    this.burstFrames,
    this.filePath,
  });

  factory SelfieCaptureResult.fromMap(Map<dynamic, dynamic> map) {
    return SelfieCaptureResult(
      imageBytes: (map['imageBytes'] as List<dynamic>?)?.cast<int>(),
      base64: map['base64'] as String?,
      burstFrames: (map['burstFrames'] as List<dynamic>?)?.cast<String>(),
      filePath: map['filePath'] as String?,
    );
  }
}

/// Error from a TrueID SDK.
class TrueIdException implements Exception {
  final String code;
  final String message;

  const TrueIdException({required this.code, required this.message});

  @override
  String toString() => 'TrueIdException($code): $message';
}
