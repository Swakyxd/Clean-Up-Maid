#!/bin/zsh
# Builds CleanUpMaid.app and packages it into CleanUpMaid.dmg
# with a drag-to-Applications layout.
set -e
cd "$(dirname "$0")"

./build-app.sh

DMG="CleanUpMaid.dmg"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

cp -R CleanUpMaid.app "$STAGING/"
ln -s /Applications "$STAGING/Applications"

rm -f "$DMG"
hdiutil create -volname "CleanUpMaid" -srcfolder "$STAGING" -format UDZO "$DMG"

echo "Built $DMG"
