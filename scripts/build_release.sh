#!/bin/bash
# Build script with secrets for release
# This script loads environment variables from .env and passes them to flutter build

set -e

# Check if .env exists
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found!"
    echo "Please copy .env.example to .env and fill in your values:"
    echo "  cp .env.example .env"
    exit 1
fi

# Load environment variables from .env
export $(grep -v '^#' .env | xargs)

# Build type (apk or appbundle)
BUILD_TYPE=${1:-apk}

echo "🔨 Building $BUILD_TYPE with secrets..."

flutter build $BUILD_TYPE \
    --dart-define=MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}

echo "✅ Build complete!"
