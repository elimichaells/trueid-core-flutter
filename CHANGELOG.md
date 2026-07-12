## 1.0.0

* Initial release: shared foundation extracted from the former monolithic
  `trueid_sdk` package.
* `TrueIdSdk.initialize()` — one secret/publishable key setup shared by every
  TrueID product package (`trueid_nia_sdk`, `trueid_hosted_sdk`,
  `trueid_document_sdk`, `trueid_nfc_sdk`).
* `TrueIdSdk.captureSelfie()` — standalone guided selfie capture with live
  face-mesh overlay, usable with no API key and no verification attached.
