# TrueID Core for Flutter

Shared foundation for every TrueID Flutter SDK: one API-key setup and a
standalone selfie-capture camera. Install this alongside whichever TrueID
product package(s) you need — you never call anything in this package
directly except `initialize()` (and, optionally, `captureSelfie()`).

| Product | Package |
|---------|---------|
| Native Ghana Card (NIA) PIN + selfie verification | [`trueid_nia_sdk`](https://pub.dev/packages/trueid_nia_sdk) |
| Hosted document + selfie verification (Chrome Custom Tab) | [`trueid_hosted_sdk`](https://pub.dev/packages/trueid_hosted_sdk) |
| Native standard document verification | [`trueid_document_sdk`](https://pub.dev/packages/trueid_document_sdk) |
| NFC chip reading (ICAO 9303) | `trueid_nfc_sdk` (not yet published) |

## Features

- **One-time initialization** — `TrueIdSdk.initialize()` configures the
  secret and/or publishable key used by every product package you install
- **Standalone selfie capture** — guided camera with live face-mesh overlay,
  usable on its own with no API key and no verification attached
- **Shared camera/liveness engine** — the same CameraX + ML Kit engine backs
  the selfie step in every product package

## Platform Support

| Platform | Supported |
|----------|-----------|
| Android  | Yes       |
| iOS      | No (planned) |

## Installation

```yaml
dependencies:
  trueid_core: ^1.0.0
```

### Android Setup

Add the TrueID Maven repository to your `android/settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://app.trueid.info/sdk/android") }
    }
}
```

On-prem institutions: replace `app.trueid.info` with your TrueID server origin.

Set `minSdkVersion` to at least **24**, and make your `MainActivity` extend
`FlutterFragmentActivity` (the camera screen needs an androidx
`ComponentActivity` host):

```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

## Quick Start

```dart
import 'package:trueid_core/trueid_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TrueIdSdk.initialize(
    secretKey: 'sk_your_secret_key',
    publishableKey: 'pk_your_publishable_key',
  );
  runApp(MyApp());
}
```

Both API keys live at app.trueid.info → Settings → API. They are not
interchangeable server-side: native verification flows (`trueid_nia_sdk`,
`trueid_document_sdk`) use the **secret key**; the hosted browser flow
(`trueid_hosted_sdk`) and verification saves use the **publishable key**.
Pass whichever the products you use require — at least one must be provided.

### Standalone selfie capture

```dart
final result = await TrueIdSdk.captureSelfie(
  config: const SelfieCaptureConfig(resultFormat: ResultFormat.base64),
);

if (result != null) {
  print('Captured: ${result.base64?.length} chars');
}
```

## API Reference

### TrueIdSdk

| Method | Description |
|--------|-------------|
| `initialize({secretKey, publishableKey, environment, customBaseUrl})` | Configure API keys once for every installed TrueID product package |
| `captureSelfie({config})` | Launch standalone selfie capture. Returns `SelfieCaptureResult?` (`null` if cancelled). No API key required |

### SelfieCaptureConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `captureMode` | `CaptureMode` | `auto` | `auto` or `manual` capture |
| `initialCamera` | `CameraFacing` | `front` | `front` or `back` |
| `allowCameraSwitch` | `bool` | `true` | Show the camera-flip button |
| `showFaceMesh` | `bool` | `true` | Overlay the live face mesh |
| `outputWidth`, `outputHeight` | `int` | `600`, `800` | Output image dimensions |
| `jpegQuality` | `int` | `94` | JPEG compression quality |
| `burstFrameCount`, `burstFrameDelayMs` | `int` | `4`, `90` | Extra frames captured around the principal selfie |
| `resultFormat` | `ResultFormat` | `base64` | `byteArray`, `filePath`, `base64`, or `all` |

## License

Proprietary. Use of this SDK requires an active TrueID organization account —
see https://app.trueid.info.
