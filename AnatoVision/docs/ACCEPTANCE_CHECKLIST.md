# AnatoVision Acceptance Checklist

Use this checklist on macOS after running:

```sh
sh scripts/verify_mac.sh
```

## Build And Tests

- The `AnatoVision` scheme builds for an iOS Simulator.
- All `AnatoVisionTests` tests pass.
- The app launches without a crash on iPhone and iPad simulator sizes.

## Image Input

- The Photos button opens the photo picker.
- Selecting a valid image starts analysis.
- A non-loadable image path shows a review error instead of silently returning.
- The Camera button appears on devices or environments where camera capture is available.

## Review Flow

- Mock review completes without a backend URL.
- The analyzing screen shows while the review is running.
- Cancel returns the app to the idle state.
- Failure shows an error state with a retry button.
- Successful review shows original/redline image switching.
- The result screen shows text feedback and a visible `Saved` status.

## History

- Completed reviews appear in Review History.
- Relaunching the app keeps completed review history.
- Opening a history row shows the saved original image, redline image, and feedback.
- Deleting a row removes it from the list and clears detail selection when needed.

## Weakness Trends

- After multiple completed reviews, `Common Patterns` appears above history.
- Repeated feedback terms affect the displayed trend order.
- Failed reviews do not affect weakness trend counts.

## Remote Backend

- With an empty `ANATOVISION_API_BASE_URL`, the app uses the mock reviewer.
- Setting `ANATOVISION_API_BASE_URL` uses `POST /v1/anatomy-reviews`.
- The request includes JPEG base64 data and a 5-second timeout.
- Responses without a redline image show an error instead of saving an incomplete review.

## Privacy And Packaging

- Camera permission text appears before camera capture.
- Photo library access is limited to user-selected images through PhotosPicker.
- AppIcon renders in the simulator.
- `PrivacyInfo.xcprivacy` is included in app resources.
