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
    <key>LSUIElement</key>               <true/>
</dict>
</plist>
EOF

# 有 Developer ID 证书就用它签名,否则 ad-hoc
SIGN_ID=$(security find-identity -v -p codesigning | awk -F'"' '/Developer ID Application/{print $2; exit}')
if [[ -n "$SIGN_ID" ]]; then
  codesign --force --deep --options runtime --timestamp --sign "$SIGN_ID" "$APP"
  echo "🔑 签名: $SIGN_ID"
else
  codesign --force --deep --sign - "$APP"
  echo "⚠️  未找到 Developer ID,使用 ad-hoc 签名"
fi

echo "✅ $APP"