#!/bin/bash

# Create dist directory if it doesn't exist
mkdir -p dist

# Clean previous builds
rm -rf build/Kiwi.xcarchive
rm -rf dist/Kiwi.app

# Archive the project
echo "Archiving Kiwi..."
xcodebuild archive \
  -project Kiwi.xcodeproj \
  -scheme Kiwi \
  -configuration Release \
  -archivePath ./build/Kiwi.xcarchive

# Export the archive
echo "Exporting app..."
xcodebuild -exportArchive \
  -archivePath ./build/Kiwi.xcarchive \
  -exportPath ./dist \
  -exportOptionsPlist exportOptions.plist

echo "✅ Package created at: dist/Kiwi.app"

