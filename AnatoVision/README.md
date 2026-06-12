# AnatoVision

AnatoVision is a SwiftUI iOS app for drawing anatomy review. It lets users select or capture an illustration, run an AI-style anatomy critique, view redline feedback, revisit saved review history, and see recurring weakness patterns from past feedback.

## Open in Xcode

Open `AnatoVision.xcodeproj` on macOS with Xcode 15 or newer. The app target supports iOS 16.0+ on iPhone and iPad.

By default, the app uses `MockAnatomyReviewClient`, so the UI works without a backend. To connect a backend, set these Info.plist values:

- `ANATOVISION_API_BASE_URL`
- `ANATOVISION_API_BEARER_TOKEN`

## Features

- Photo library and camera input.
- Mock anatomy review that generates a redline overlay locally.
- Remote review client for a backend API.
- Local review history with original and redlined images.
- Common pattern analysis from saved feedback notes.
- Unit tests for storage, view-model state changes, remote API mapping, image processing, and weakness trend analysis.

The remote client posts JSON to:

```http
POST /v1/anatomy-reviews
Content-Type: application/json
Authorization: Bearer <token>
```

Request:

```json
{
  "imageBase64": "<jpeg base64>"
}
```

Response:

```json
{
  "redlinedImageBase64": "<jpeg/png base64 or null>",
  "redlinedImageURL": "https://example.com/redline.jpg",
  "feedbackText": "Anatomy feedback"
}
```

## Test

Run the `AnatoVisionTests` target in Xcode, or run this on macOS:

```sh
sh scripts/verify_mac.sh
```

This workspace does not include a Windows Swift toolchain, so simulator builds and XCTest execution should be done on macOS.

## CI

The GitHub Actions workflow in `.github/workflows/ios.yml` runs the same verification script on a macOS runner.

For manual release readiness checks, use `docs/ACCEPTANCE_CHECKLIST.md`.
