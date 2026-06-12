#!/bin/sh
set -eu

SCHEME="${SCHEME:-AnatoVision}"
PROJECT="${PROJECT:-AnatoVision.xcodeproj}"
SIMULATOR_NAME="${SIMULATOR_NAME:-iPhone 15}"
DESTINATION="${DESTINATION:-platform=iOS Simulator,name=${SIMULATOR_NAME}}"

if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "error: xcodebuild was not found. Run this script on macOS with Xcode installed." >&2
  exit 127
fi

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  clean test
