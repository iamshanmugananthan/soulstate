#!/bin/bash
set -e

VERSION="1.0.0"
BUNDLE="build/linux/x64/release/bundle"
OUT="build/deb"
PKG_DIR="${OUT}/soulstate_${VERSION}_amd64"

if [ ! -d "$BUNDLE" ]; then
    echo "Bundle not found at $BUNDLE. Run 'flutter build linux --release' first."
    exit 1
fi

rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/opt/soulstate"
mkdir -p "$PKG_DIR/usr/bin"
mkdir -p "$PKG_DIR/usr/share/applications"
mkdir -p "$PKG_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$PKG_DIR/usr/share/pixmaps"

# Copy Linux bundle
cp -r "$BUNDLE"/* "$PKG_DIR/opt/soulstate/"
chmod 755 "$PKG_DIR/opt/soulstate/SoulState"

# Create symlink in /usr/bin
ln -sf /opt/soulstate/SoulState "$PKG_DIR/usr/bin/soulstate"

# Desktop entry
cat << 'EOF' > "$PKG_DIR/usr/share/applications/com.shanmugananthan.soulstate.desktop"
[Desktop Entry]
Type=Application
Name=Soul State
Comment=Mindful habit tracker, money tracker, and meal tracker
Exec=/opt/soulstate/SoulState
Icon=com.shanmugananthan.soulstate
Terminal=false
Categories=Utility;
StartupWMClass=SoulState
EOF

# Icons
cp "$BUNDLE/com.shanmugananthan.soulstate.png" "$PKG_DIR/usr/share/icons/hicolor/256x256/apps/com.shanmugananthan.soulstate.png"
cp "$BUNDLE/com.shanmugananthan.soulstate.png" "$PKG_DIR/usr/share/pixmaps/com.shanmugananthan.soulstate.png"

# Calculate installed size in KB
INSTALLED_SIZE=$(du -sk "$PKG_DIR" | cut -f1)

# Control file
cat << EOF > "$PKG_DIR/DEBIAN/control"
Package: soulstate
Version: ${VERSION}
Section: utils
Priority: optional
Architecture: amd64
Maintainer: shanmugananthan <ak@shanmugananthan.com>
Installed-Size: ${INSTALLED_SIZE}
Depends: libgtk-3-0, libglib2.0-0
Homepage: https://github.com/iamshanmugananthan/soulstate
Description: Soul State
 Mindful habit tracker, money tracker, and meal tracker.
EOF

# Build DEB
dpkg-deb --build --root-owner-group "$PKG_DIR" "${OUT}/soulstate_${VERSION}_amd64.deb"
echo "DEB package created at: ${OUT}/soulstate_${VERSION}_amd64.deb"
