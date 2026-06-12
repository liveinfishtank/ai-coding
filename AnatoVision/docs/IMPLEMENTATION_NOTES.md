# AnatoVision Implementation Notes

## Scope

This repository contains the iOS client for AnatoVision. The app supports:

- Selecting an image from the photo library.
- Capturing an image with the camera.
- Running an anatomy review through a replaceable review client.
- Showing original/redline image comparison and text feedback.
- Saving completed reviews in local app storage.
- Reopening and deleting saved review history.
- Showing recurring weakness patterns based on saved feedback.

The backend service is intentionally not included. The iOS app defaults to `MockAnatomyReviewClient` until `ANATOVISION_API_BASE_URL` is set in `Info.plist`.

## Backend Contract

The app sends JSON:

```http
POST /v1/anatomy-reviews
Content-Type: application/json
Authorization: Bearer <optional token>
```

```json
{
  "imageBase64": "<jpeg base64>"
}
```

The backend should return either inline redline image data or a URL:

```json
{
  "redlinedImageBase64": "<jpeg/png base64 or null>",
  "redlinedImageURL": "https://example.com/redline.png",
  "feedbackText": "Actionable anatomy feedback"
}
```

Non-2xx responses may return:

```json
{
  "message": "Human-readable error"
}
```

## Local Storage

`ReviewSessionStore` writes metadata to `Documents/AnatoVisionData/sessions.json` and image files to `Documents/AnatoVisionData/Images`. The app stores only completed reviews; failed reviews remain transient and can be retried from the current screen.

## Weakness Trends

`WeaknessTrendAnalyzer` runs locally over completed review feedback. It uses lightweight keyword rules to group repeated notes into categories such as shoulders/arms, torso balance, perspective, lower body, and gesture flow. The home screen shows the top categories above the review history when enough feedback exists.

## Mac Verification

This workspace was created on Windows, where `xcodebuild` is not available. On macOS:

```sh
sh scripts/verify_mac.sh
```

To choose a different simulator:

```sh
SIMULATOR_NAME='iPhone 16' sh scripts/verify_mac.sh
```

The GitHub Actions workflow uses the same script so local and CI validation stay aligned.

Use `docs/ACCEPTANCE_CHECKLIST.md` for the final manual acceptance pass on macOS or device.

Then manually verify:

- Photo picker starts a mock review and shows a redline result.
- Camera capture starts a mock review on a device or camera-capable simulator setup.
- Review history persists after relaunch.
- Deleting a history row removes it from the list.
- Repeated feedback appears in the `Common Patterns` section.
- Setting `ANATOVISION_API_BASE_URL` switches the app from mock to remote review.
