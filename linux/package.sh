#!/bin/bash
set -e

bundle=build/linux/x64/release/bundle
out=build/linux/package
tool=https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage
runtime=https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64

rm -rf "$out"
mkdir -p "$out/SoulState" "$out/AppDir/usr/bin"

cp -r "$bundle"/. "$out/SoulState/"
tar -C "$out" -czf soulstate-1.0.0-linux-x64.tar.gz SoulState

cp -r "$bundle"/. "$out/AppDir/usr/bin/"
cp "$bundle/com.shanmugananthan.soulstate.desktop" "$bundle/com.shanmugananthan.soulstate.png" "$out/AppDir/"
ln -s com.shanmugananthan.soulstate.png "$out/AppDir/.DirIcon"
ln -s usr/bin/SoulState "$out/AppDir/AppRun"

curl -6 -fsSL -o "$out/appimagetool" "$tool"
curl -6 -fsSL -o "$out/runtime" "$runtime"
chmod +x "$out/appimagetool"
ARCH=x86_64 "$out/appimagetool" --appimage-extract-and-run --runtime-file "$out/runtime" "$out/AppDir" SoulState-x86_64.AppImage
