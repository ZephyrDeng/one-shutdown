#!/bin/zsh
set -e
cd "$(dirname "$0")"

APP=build/OneShutdown.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"

swiftc -O Sources/main.swift -o "$APP/Contents/MacOS/OneShutdown"

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>              <string>OneShutdown</string>
    <key>CFBundleDisplayName</key>       <string>OneShutdown</string>
    <key>CFBundleIdentifier</key>        <string>com.zephyr.one-shutdown</string>
    <key>CFBundleExecutable</key>        <string>OneShutdown</string>
    <key>CFBundleShortVersionString</key><string>1.0.0</string>
    <key>CFBundleVersion</key>           <string>1</string>
    <key>CFBundlePackageType</key>       <string>APPL</string>
    <key>LSMinimumSystemVersion</key>    <string>13.0</string>
    <key>LSUIElement</key>               <true/>  <!-- 只在菜单栏,不占 Dock -->
</dict>
</plist>
EOF

codesign --force --deep --sign - "$APP" 2>/dev/null || true
echo "✅ $APP"