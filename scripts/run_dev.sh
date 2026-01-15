#!/bin/bash
# Development run script with secrets
# This script loads environment variables from .env and passes them to flutter

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

# Run flutter with dart-define flags
flutter run \
    --dart-define=MAPBOX_ACCESS_TOKEN=${MAPBOX_ACCESS_TOKEN}
