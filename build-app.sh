#!/bin/zsh
# Builds CleanUpMaid.app in the project root.
set -e
cd "$(dirname "$0")"

swift build -c release

APP="CleanUpMaid.app"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp .build/release/CleanUpMaid "$APP/Contents/MacOS/CleanUpMaid"
cp AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>CleanUpMaid</string>
    <key>CFBundleIdentifier</key>
    <string>com.sayan.cleanupmaid</string>
    <key>CFBundleName</key>
    <string>CleanUpMaid</string>
    <key>CFBundleDisplayName</key>
    <string>CleanUpMaid</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSHumanReadableCopyright</key>
    <string>🧹✨</string>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP"

echo "Built $APP — launch it with: open $APP"
