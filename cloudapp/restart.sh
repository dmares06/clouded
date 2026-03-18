#!/bin/bash
# Restart Cloud app: kills running instance, rebuilds, and relaunches

set -e

APP="Cloud"
DERIVED="$HOME/Library/Developer/Xcode/DerivedData/Cloud-ctszcswnkqsivegkeaukvvwaiarr/Build/Products/Debug/Cloud.app"

echo "⏳ Stopping $APP..."
pkill -x "$APP" 2>/dev/null && sleep 1 || true

echo "🔨 Building..."
cd "$(dirname "$0")"
xcodebuild -scheme Cloud -configuration Debug build 2>&1 | tail -3

echo "🚀 Launching $APP..."
open "$DERIVED"

echo "✅ Done"
