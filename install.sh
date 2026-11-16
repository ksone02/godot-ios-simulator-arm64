#!/bin/sh
# Merges the arm64 simulator libraries into your installed Godot iOS export template.
# Usage: ./install.sh [path/to/ios.zip] [dir with the .a files]
# Default zip: the newest ios.zip under ~/Library/Application Support/Godot/export_templates.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
ZIP="${1:-$(ls -t "$HOME"/Library/Application\ Support/Godot/export_templates/*/ios.zip | head -1)}"
LIBS="${2:-$HERE/dist}"
[ -f "$ZIP" ] || { echo "ios.zip not found: $ZIP" >&2; exit 1; }
[ -f "$ZIP.orig" ] || cp "$ZIP" "$ZIP.orig"   # backup, kept from the first run
W="$(mktemp -d)"; trap 'rm -rf "$W"' EXIT
unzip -q "$ZIP.orig" -d "$W"
for n in libgodot libgodot_camera; do
  S="$W/$n.ios.debug.xcframework/ios-arm64_x86_64-simulator/$n.a"
  [ -f "$S" ] || { echo "slice not found: $S" >&2; exit 1; }
  lipo -archs "$S" | grep -qw arm64 && { echo "$n already has arm64, nothing to do"; continue; }
  lipo -create "$S" "$LIBS/$n.ios.template_debug.arm64.simulator.a" -output "$S.fat"
  mv "$S.fat" "$S"
done
rm -f "$ZIP.new"; (cd "$W" && zip -qr "$ZIP.new" .)
mv "$ZIP.new" "$ZIP"
echo "patched: $ZIP (original saved as $ZIP.orig)"
