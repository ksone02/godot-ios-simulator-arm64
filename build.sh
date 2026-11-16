#!/bin/sh
# Builds the arm64 iOS Simulator debug libraries from the Godot source tree.
# Usage: ./build.sh [godot-tag]   (default 4.7.2-stable). Needs Xcode, git, python3.
set -e
TAG="${1:-4.7.2-stable}"
python3 -m venv venv && ./venv/bin/pip install -q scons
[ -d godot-src ] || git clone --depth 1 --branch "$TAG" https://github.com/godotengine/godot.git godot-src
cd godot-src
../venv/bin/scons platform=ios target=template_debug arch=arm64 simulator=yes -j"$(sysctl -n hw.ncpu)"
mkdir -p ../dist && cp bin/*.ios.template_debug.arm64.simulator.a ../dist/
