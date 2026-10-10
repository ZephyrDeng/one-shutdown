#!/bin/zsh
set -e
cd "$(dirname "$0")"

APP=build/OneShutdown.app
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"
cp assets/AppIcon.icns "$APP/Contents/Resources/"

# 必须显式 -target:否则 swiftc 按工具链默认 minos(如 28.0)编译,低版本 macOS 报「不能与此版本 macOS 配合使用」
# 版本需与 Info.plist 的 LSMinimumSystemVersion 保持一致;同时出 arm64 + x86_64 通用二进制
for ARCH in arm64 x86_64; do
  swiftc -O -target $ARCH-apple-macos13 Sources/main.swift -o build/OneShutdown-$ARCH
done
lipo -create build/OneShutdown-arm64 build/OneShutdown-x86_64 -output "$APP/Contents/MacOS/OneShutdown"
rm build/OneShutdown-arm64 build/OneShutdown-x86_64

cat > "$APP/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>              <string>OneShutdown</string>
    <key>CFBundleDisplayName</key>       <string>OneShutdown</string>
    <key>CFBundleIdentifier</key>        <string>com.zephyr.one-shutdown</string>
    <key>CFBundleExecutable</key>        <string>OneShutdown</string>
    <key>CFBundleIconFile</key>          <string>AppIcon</string>
    <key>CFBundleShortVersionString</key><string>1.1.0</string>
    <key>CFBundleVersion</key>           <string>2</string>
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

# 可选公证:RELEASE_ENV=<含 APPLE_ID / APPLE_APP_SPECIFIC_PASSWORD / APPLE_TEAM_ID 的文件> ./build.sh
if [[ -n "$RELEASE_ENV" ]]; then
  ( set +x; set -a; . "$RELEASE_ENV"; set +a
    ditto -c -k --keepParent "$APP" build/notarize.zip
    xcrun notarytool submit build/notarize.zip --wait \
      --apple-id "$APPLE_ID" --password "$APPLE_APP_SPECIFIC_PASSWORD" --team-id "$APPLE_TEAM_ID" )
  rm build/notarize.zip
  xcrun stapler staple "$APP"
  spctl -a -vv "$APP"
  ditto -c -k --keepParent "$APP" build/OneShutdown.zip
  echo "📦 build/OneShutdown.zip(已公证)"
fi

echo "✅ $APP"