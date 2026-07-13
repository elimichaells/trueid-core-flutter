## 1.0.1

* Updates the native Android dependency to `trueid-core:1.1.1`: face-region
  lighting/sharpness gating, an eyes-open blink guard, multi-face and
  head-roll checks, face-region AE/AF metering, and shutter sound + flash
  feedback for guided selfie capture. Also fixes a packaging issue where the
  native SDK silently required host apps to raise `compileSdk` to 36.
* No Dart-facing API changes.

## 1.0.0

* Initial release: shared foundation extracted from the former monolithic
  `trueid_sdk` package.
* `TrueIdSdk.initialize()` — one secret/publishable key setup shared by every
  TrueID product package (`trueid_nia_sdk`, `trueid_hosted_sdk`,
  `trueid_document_sdk`, `trueid_nfc_sdk`).
* `TrueIdSdk.captureSelfie()` — standalone guided selfie capture with live
  face-mesh overlay, usable with no API key and no verification attached.
