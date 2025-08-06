#!/bin/bash

# Flutter SDK Installation Script
# This script installs Flutter SDK and configures the environment

set -e

echo "🚀 Starting Flutter SDK installation..."

# Configuration
FLUTTER_VERSION="3.16.0"
FLUTTER_CHANNEL="stable"
FLUTTER_ROOT="/opt/flutter"
PUB_CACHE="/opt/flutter/.pub-cache"

# System dependencies
echo "📦 Installing system dependencies..."
apt-get update -qq
apt-get install -y curl git unzip xz-utils

# Download and install Flutter
echo "⬇️ Downloading Flutter SDK v${FLUTTER_VERSION}..."
if [ ! -d "$FLUTTER_ROOT" ]; then
    git clone https://github.com/flutter/flutter.git -b $FLUTTER_CHANNEL $FLUTTER_ROOT
    cd $FLUTTER_ROOT
    git checkout $FLUTTER_VERSION
else
    echo "Flutter SDK already exists, updating..."
    cd $FLUTTER_ROOT
    git fetch
    git checkout $FLUTTER_VERSION
fi

# Set up environment
echo "🔧 Configuring environment..."
export PATH="$FLUTTER_ROOT/bin:$PATH"
export FLUTTER_ROOT="$FLUTTER_ROOT"
export PUB_CACHE="$PUB_CACHE"

# Configure Flutter
echo "⚙️ Configuring Flutter..."
flutter config --no-analytics
flutter config --enable-web
flutter config --no-cli-animations

# Pre-download dependencies
echo "📥 Pre-downloading Flutter dependencies..."
flutter precache --web

# Verify installation
echo "✅ Verifying Flutter installation..."
flutter --version
flutter doctor -v

# Create environment file
echo "📝 Creating environment configuration..."
cat > /tmp/flutter-env.sh << EOF
export FLUTTER_ROOT="$FLUTTER_ROOT"
export PUB_CACHE="$PUB_CACHE"
export PATH="$FLUTTER_ROOT/bin:\$PATH"
EOF

echo "🎉 Flutter SDK installation completed successfully!"
echo "Flutter version: $(flutter --version | head -n 1)"
echo "Installation path: $FLUTTER_ROOT"
