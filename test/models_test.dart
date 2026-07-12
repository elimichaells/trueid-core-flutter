import 'package:flutter_test/flutter_test.dart';
import 'package:trueid_core/trueid_core.dart';

void main() {
  group('SelfieCaptureConfig', () {
    test('toMap uses enum wire names and defaults', () {
      const config = SelfieCaptureConfig();
      final map = config.toMap();

      expect(map['captureMode'], 'auto');
      expect(map['initialCamera'], 'front');
      expect(map['allowCameraSwitch'], true);
      expect(map['showFaceMesh'], true);
      expect(map['outputWidth'], 600);
      expect(map['outputHeight'], 800);
      expect(map['jpegQuality'], 94);
      expect(map['burstFrameCount'], 4);
      expect(map['burstFrameDelayMs'], 90);
      expect(map['resultFormat'], 'base64');
    });

    test('toMap reflects overridden values', () {
      const config = SelfieCaptureConfig(
        captureMode: CaptureMode.manual,
        initialCamera: CameraFacing.back,
        resultFormat: ResultFormat.all,
      );
      final map = config.toMap();

      expect(map['captureMode'], 'manual');
      expect(map['initialCamera'], 'back');
      expect(map['resultFormat'], 'all');
    });
  });

  group('SelfieCaptureResult', () {
    test('fromMap parses all fields', () {
      final result = SelfieCaptureResult.fromMap({
        'imageBytes': [1, 2, 3],
        'base64': 'abc123',
        'burstFrames': ['a', 'b'],
        'filePath': '/tmp/selfie.jpg',
      });

      expect(result.imageBytes, [1, 2, 3]);
      expect(result.base64, 'abc123');
      expect(result.burstFrames, ['a', 'b']);
      expect(result.filePath, '/tmp/selfie.jpg');
    });

    test('fromMap tolerates missing optional fields', () {
      final result = SelfieCaptureResult.fromMap({});

      expect(result.imageBytes, isNull);
      expect(result.base64, isNull);
      expect(result.burstFrames, isNull);
      expect(result.filePath, isNull);
    });
  });

  test('TrueIdException toString includes code and message', () {
    const exception = TrueIdException(code: 'NO_KEY', message: 'missing key');
    expect(exception.toString(), 'TrueIdException(NO_KEY): missing key');
  });
}
