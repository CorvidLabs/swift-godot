#!/bin/bash
set -e

# Configuration
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/.build/release"
GODOT_PROJECT="$PROJECT_ROOT/GodotProject"
BIN_DIR="$GODOT_PROJECT/bin"

echo "Building SwiftGodotKitDemo..."
cd "$PROJECT_ROOT"
swift build -c release --product SwiftGodotKitDemo

# Create bin directory if it doesn't exist
mkdir -p "$BIN_DIR"

# Find and copy the dylib
DYLIB_PATH="$BUILD_DIR/libSwiftGodotKitDemo.dylib"

if [ ! -f "$DYLIB_PATH" ]; then
    echo "Error: Could not find libSwiftGodotKitDemo.dylib at $DYLIB_PATH"
    echo "Searching for dylib files..."
    find "$BUILD_DIR" -name "*.dylib" 2>/dev/null || true
    exit 1
fi

# Copy the dylibs to the Godot project
cp "$DYLIB_PATH" "$BIN_DIR/"
cp "$BUILD_DIR/libSwiftGodot.dylib" "$BIN_DIR/"

echo "Successfully copied libraries to $BIN_DIR/"
echo ""
echo "To run the demo:"
echo "  open -a Godot $GODOT_PROJECT/project.godot"
