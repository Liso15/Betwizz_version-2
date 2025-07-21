# Mobile Setup Script Troubleshooting Guide

## Common Failure Analysis and Solutions

### 1. **Script Permission Issues**
**Problem**: Script fails to execute due to permission restrictions
\`\`\`bash
bash: ./scripts/mobile-setup.sh: Permission denied
\`\`\`

**Solution**:
\`\`\`bash
# Make script executable
chmod +x scripts/mobile-setup.sh

# Alternative: Run with bash directly
bash scripts/mobile-setup.sh
\`\`\`

### 2. **Flutter Command Not Found**
**Problem**: Flutter is not in PATH or not installed
\`\`\`bash
flutter: command not found
\`\`\`

**Solutions**:
\`\`\`bash
# Add Flutter to PATH (Linux/macOS)
export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
which flutter
flutter --version
\`\`\`

### 3. **Android SDK Issues**
**Problem**: Android toolchain not properly configured
\`\`\`bash
Android toolchain - develop for Android devices ✗
\`\`\`

**Solutions**:
\`\`\`bash
# Set ANDROID_HOME environment variable
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools

# Accept licenses
flutter doctor --android-licenses
\`\`\`

### 4. **iOS Setup Failures (macOS)**
**Problem**: Xcode or CocoaPods issues
\`\`\`bash
CocoaPods not installed
Xcode not found
\`\`\`

**Solutions**:
\`\`\`bash
# Install Xcode Command Line Tools
xcode-select --install

# Install CocoaPods
sudo gem install cocoapods
pod setup
\`\`\`

### 5. **Keystore Generation Failures**
**Problem**: Java keytool not found or keystore creation fails
\`\`\`bash
keytool: command not found
\`\`\`

**Solutions**:
\`\`\`bash
# Install Java JDK
sudo apt-get install openjdk-11-jdk  # Ubuntu/Debian
brew install openjdk@11             # macOS

# Verify Java installation
java -version
keytool -help
\`\`\`

### 6. **Firebase Configuration Issues**
**Problem**: Firebase CLI or FlutterFire CLI not installed
\`\`\`bash
firebase: command not found
flutterfire: command not found
\`\`\`

**Solutions**:
\`\`\`bash
# Install Firebase CLI
npm install -g firebase-tools

# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Add to PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"
\`\`\`

### 7. **Build Runner Failures**
**Problem**: Code generation fails
\`\`\`bash
[SEVERE] Failed to generate code
\`\`\`

**Solutions**:
\`\`\`bash
# Clean and regenerate
flutter clean
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
