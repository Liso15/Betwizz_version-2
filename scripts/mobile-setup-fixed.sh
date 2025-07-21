#!/bin/bash

# Enhanced Mobile Setup Script for Betwizz Flutter App
# This script includes comprehensive error handling and troubleshooting

set -e

echo "🚀 Setting up Betwizz for Mobile Development"
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ANDROID_KEY_PATH="$PROJECT_ROOT/android/app/betwizz-key.jks"
ANDROID_KEY_PROPERTIES="$PROJECT_ROOT/android/key.properties"
IOS_DIR="$PROJECT_ROOT/ios"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# Function to check if file exists
file_exists() {
    [ -f "$1" ]
}

# Function to create directory if it doesn't exist
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_status "Created directory: $1"
    fi
}

# Function to backup existing file
backup_file() {
    if file_exists "$1"; then
        cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Backed up existing file: $1"
    fi
}

# Enhanced Flutter check with detailed diagnostics
check_flutter() {
    print_status "Checking Flutter installation..."
    
    if ! command_exists flutter; then
        print_error "Flutter is not installed or not in PATH."
        print_status "Please install Flutter from: https://docs.flutter.dev/get-started/install"
        print_status "After installation, add Flutter to your PATH:"
        echo "  export PATH=\"\$PATH:/path/to/flutter/bin\""
        exit 1
    fi
    
    # Check Flutter version
    local flutter_version
    flutter_version=$(flutter --version | head -n 1 | awk '{print $2}')
    print_success "Flutter is installed (version: $flutter_version)"
    
    # Check if Flutter is properly configured
    if ! flutter config --machine >/dev/null 2>&1; then
        print_warning "Flutter configuration may be incomplete"
    fi
}

# Enhanced Flutter doctor with specific issue detection
check_flutter_doctor() {
    print_status "Running Flutter doctor..."
    
    local doctor_output
    doctor_output=$(flutter doctor 2>&1)
    
    echo "$doctor_output"
    
    # Check for specific issues
    if echo "$doctor_output" | grep -q "✗.*Android toolchain"; then
        print_error "Android toolchain issues detected"
        print_status "Try running: flutter doctor --android-licenses"
        print_status "Ensure ANDROID_HOME is set: export ANDROID_HOME=\$HOME/Android/Sdk"
    fi
    
    if echo "$doctor_output" | grep -q "✗.*Xcode"; then
        print_error "Xcode issues detected"
        print_status "Install Xcode from the App Store"
        print_status "Run: xcode-select --install"
    fi
    
    if echo "$doctor_output" | grep -q "✗.*CocoaPods"; then
        print_error "CocoaPods issues detected"
        print_status "Install CocoaPods: sudo gem install cocoapods"
    fi
    
    # Check if there are any critical issues
    if echo "$doctor_output" | grep -q "✗"; then
        print_warning "Flutter doctor found issues. Continuing with setup..."
        return 1
    else
        print_success "Flutter doctor checks passed"
        return 0
    fi
}

# Enhanced Android setup with better error handling
setup_android() {
    print_status "Setting up Android development..."
    
    # Check if Android directory exists
    if ! dir_exists "$PROJECT_ROOT/android"; then
        print_error "Android directory not found. This may not be a Flutter project."
        return 1
    fi
    
    # Check for Android SDK
    if [ -z "$ANDROID_HOME" ]; then
        # Try to detect Android SDK location
        local possible_locations=(
            "$HOME/Android/Sdk"
            "$HOME/Library/Android/sdk"
            "/usr/local/android-sdk"
            "/opt/android-sdk"
        )
        
        for location in "${possible_locations[@]}"; do
            if dir_exists "$location"; then
                export ANDROID_HOME="$location"
                export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
                print_status "Found Android SDK at: $location"
                break
            fi
        done
        
        if [ -z "$ANDROID_HOME" ]; then
            print_warning "Android SDK not found. Please install Android Studio and set ANDROID_HOME"
            return 1
        fi
    fi
    
    # Accept Android licenses with timeout
    print_status "Accepting Android licenses..."
    timeout 60 flutter doctor --android-licenses || {
        print_warning "License acceptance timed out or failed"
    }
    
    # Create Android keystore with better error handling
    if [ ! -f "$ANDROID_KEY_PATH" ]; then
        print_status "Creating Android keystore..."
        
        # Ensure directory exists
        ensure_dir "$(dirname "$ANDROID_KEY_PATH")"
        
        # Check if keytool is available
        if ! command_exists keytool; then
            print_error "keytool not found. Please install Java JDK"
            print_status "Ubuntu/Debian: sudo apt-get install openjdk-11-jdk"
            print_status "macOS: brew install openjdk@11"
            return 1
        fi
        
        # Generate keystore with error handling
        if keytool -genkey -v -keystore "$ANDROID_KEY_PATH" \
            -keyalg RSA -keysize 2048 -validity 10000 \
            -alias betwizz \
            -dname "CN=Betwizz, OU=Mobile, O=Betwizz, L=Cape Town, S=Western Cape, C=ZA" \
            -storepass betwizz123 -keypass betwizz123 2>/dev/null; then
            print_success "Android keystore created at: $ANDROID_KEY_PATH"
        else
            print_error "Failed to create Android keystore"
            return 1
        fi
    else
        print_success "Android keystore already exists"
    fi
    
    # Create key.properties file
    create_android_key_properties
    
    print_success "Android setup completed"
}

# Function to create Android key properties
create_android_key_properties() {
    print_status "Creating Android key properties..."
    
    backup_file "$ANDROID_KEY_PROPERTIES"
    
    cat > "$ANDROID_KEY_PROPERTIES" << EOF
storePassword=betwizz123
keyPassword=betwizz123
keyAlias=betwizz
storeFile=betwizz-key.jks
EOF
    
    print_success "Android key properties created"
}

# Enhanced iOS setup with better error detection
setup_ios() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_warning "iOS development is only available on macOS"
        return 0
    fi
    
    print_status "Setting up iOS development..."
    
    # Check if iOS directory exists
    if ! dir_exists "$IOS_DIR"; then
        print_error "iOS directory not found"
        return 1
    fi
    
    # Check if Xcode is installed
    if ! command_exists xcodebuild; then
        print_error "Xcode not found. Please install Xcode from the App Store"
        print_status "After installation, run: xcode-select --install"
        return 1
    fi
    
    # Check Xcode version
    local xcode_version
    xcode_version=$(xcodebuild -version 2>/dev/null | head -n 1 | awk '{print $2}' || echo "unknown")
    print_status "Xcode version: $xcode_version"
    
    # Check if command line tools are installed
    if ! xcode-select -p >/dev/null 2>&1; then
        print_status "Installing Xcode command line tools..."
        xcode-select --install
    fi
    
    # Install CocoaPods if not installed
    if ! command_exists pod; then
        print_status "Installing CocoaPods..."
        
        # Check if we have permission to install gems
        if sudo -n gem install cocoapods 2>/dev/null; then
            print_success "CocoaPods installed with sudo"
        elif gem install --user-install cocoapods 2>/dev/null; then
            print_success "CocoaPods installed in user directory"
            # Add user gem bin to PATH
            export PATH="$PATH:$(ruby -e 'puts Gem.user_dir')/bin"
        else
            print_error "Failed to install CocoaPods"
            print_status "Try manually: sudo gem install cocoapods"
            return 1
        fi
    else
        print_success "CocoaPods is already installed"
    fi
    
    # Setup iOS pods with error handling
    print_status "Setting up iOS pods..."
    cd "$IOS_DIR" || {
        print_error "Failed to change to iOS directory"
        return 1
    }
    
    # Clean existing pods if they exist
    if dir_exists "Pods"; then
        print_status "Cleaning existing pods..."
        rm -rf Pods Podfile.lock
    fi
    
    # Install pods with timeout and retry
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_status "Installing iOS pods (attempt $attempt/$max_attempts)..."
        
        if timeout 300 pod install --repo-update 2>/dev/null; then
            print_success "iOS pods installed successfully"
            cd "$PROJECT_ROOT" || exit 1
            return 0
        else
            print_warning "Pod install attempt $attempt failed"
            ((attempt++))
            
            if [ $attempt -le $max_attempts ]; then
                print_status "Retrying in 5 seconds..."
                sleep 5
            fi
        fi
    done
    
    print_error "Failed to install iOS pods after $max_attempts attempts"
    cd "$PROJECT_ROOT" || exit 1
    return 1
}

# Enhanced dependency installation with error handling
install_dependencies() {
    print_status "Installing Flutter dependencies..."
    
    # Change to project root
    cd "$PROJECT_ROOT" || {
        print_error "Failed to change to project root directory"
        exit 1
    }
    
    # Clean previous builds
    print_status "Cleaning previous builds..."
    flutter clean
    
    # Get dependencies with retry logic
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        print_status "Getting Flutter dependencies (attempt $attempt/$max_attempts)..."
        
        if flutter pub get; then
            print_success "Flutter dependencies installed"
            return 0
        else
            print_warning "Dependency installation attempt $attempt failed"
            ((attempt++))
            
            if [ $attempt -le $max_attempts ]; then
                print_status "Retrying in 5 seconds..."
                sleep 5
            fi
        fi
    done
    
    print_error "Failed to install dependencies after $max_attempts attempts"
    return 1
}

# Enhanced code generation with better error handling
generate_code() {
    print_status "Generating code..."
    
    # Check if build_runner is available
    if ! flutter packages pub run build_runner --help >/dev/null 2>&1; then
        print_error "build_runner not found in dependencies"
        print_status "Add build_runner to dev_dependencies in pubspec.yaml"
        return 1
    fi
    
    # Clean previous generated files
    print_status "Cleaning previous generated files..."
    flutter packages pub run build_runner clean || true
    
    # Generate code with timeout
    print_status "Running code generation..."
    if timeout 300 flutter packages pub run build_runner build --delete-conflicting-outputs; then
        print_success "Code generation completed"
    else
        print_error "Code generation failed or timed out"
        return 1
    fi
}

# Enhanced Firebase setup
setup_firebase() {
    print_status "Setting up Firebase..."
    
    # Check if Firebase CLI is installed
    if ! command_exists firebase; then
        print_warning "Firebase CLI not found"
        print_status "Install with: npm install -g firebase-tools"
        print_status "Or visit: https://firebase.google.com/docs/cli"
        return 1
    fi
    
    print_success "Firebase CLI is available"
    
    # Check if FlutterFire CLI is installed
    if ! command_exists flutterfire; then
        print_status "Installing FlutterFire CLI..."
        
        if dart pub global activate flutterfire_cli; then
            print_success "FlutterFire CLI installed"
            
            # Add to PATH if not already there
            local pub_cache_bin="$HOME/.pub-cache/bin"
            if [[ ":$PATH:" != *":$pub_cache_bin:"* ]]; then
                export PATH="$PATH:$pub_cache_bin"
                print_status "Added $pub_cache_bin to PATH"
            fi
        else
            print_error "Failed to install FlutterFire CLI"
            return 1
        fi
    else
        print_success "FlutterFire CLI is available"
    fi
    
    # Configure Firebase (optional, requires user interaction)
    print_status "Firebase configuration available"
    print_status "Run manually: flutterfire configure --project=betwizz-app"
}

# Enhanced mobile testing with better error reporting
run_mobile_tests() {
    print_status "Running mobile compatibility tests..."
    
    local test_passed=true
    
    # Test Android build if Android toolchain is available
    if flutter doctor | grep -q "Android toolchain.*✓"; then
        print_status "Testing Android build..."
        
        if flutter build apk --debug --target-platform android-arm64 >/dev/null 2>&1; then
            print_success "Android build test passed"
        else
            print_error "Android build test failed"
            test_passed=false
        fi
    else
        print_warning "Skipping Android build test (toolchain not available)"
    fi
    
    # Test iOS build if on macOS and Xcode is available
    if [[ "$OSTYPE" == "darwin"* ]] && command_exists xcodebuild; then
        print_status "Testing iOS build..."
        
        if flutter build ios --debug --no-codesign >/dev/null 2>&1; then
            print_success "iOS build test passed"
        else
            print_error "iOS build test failed"
            test_passed=false
        fi
    else
        print_warning "Skipping iOS build test (not available on this platform)"
    fi
    
    if [ "$test_passed" = true ]; then
        print_success "All available mobile tests passed"
    else
        print_warning "Some mobile tests failed"
        return 1
    fi
}

# Create mobile-specific configuration files
create_mobile_configs() {
    print_status "Creating mobile configuration files..."
    
    # Create mobile-specific environment file
    local env_mobile="$PROJECT_ROOT/.env.mobile"
    backup_file "$env_mobile"
    
    cat > "$env_mobile" << EOF
# Mobile-specific environment variables
MOBILE_MODE=true
ENABLE_CAMERA=true
ENABLE_MICROPHONE=true
ENABLE_NOTIFICATIONS=true
PERFORMANCE_MODE=auto
CACHE_SIZE=50MB
BUILD_MODE=debug
EOF
    
    # Create mobile launch configuration for VS Code
    local vscode_dir="$PROJECT_ROOT/.vscode"
    ensure_dir "$vscode_dir"
    
    cat > "$vscode_dir/launch.json" << EOF
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Flutter (Mobile Debug)",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "args": ["--flavor", "development"]
        },
        {
            "name": "Flutter (Android)",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "deviceId": "android"
        },
        {
            "name": "Flutter (iOS)",
            "request": "launch",
            "type": "dart",
            "program": "lib/main.dart",
            "deviceId": "ios"
        }
    ]
}
EOF
    
    print_success "Mobile configuration files created"
}

# Function to display helpful information
show_next_steps() {
    echo ""
    print_success "Mobile setup completed!"
    echo ""
    print_status "Next steps:"
    echo "1. Connect an Android device or start an emulator"
    echo "2. For iOS: Open ios/Runner.xcworkspace in Xcode"
    echo "3. Run the application:"
    echo ""
    print_status "Useful commands:"
    echo "• flutter devices                    # List available devices"
    echo "• flutter run                       # Run on default device"
    echo "• flutter run -d android            # Run on Android"
    echo "• flutter run -d ios                # Run on iOS"
    echo "• flutter build apk --debug         # Build Android APK"
    echo "• flutter build ios --debug         # Build iOS app"
    echo ""
    print_status "Troubleshooting:"
    echo "• flutter doctor -v                 # Detailed system check"
    echo "• flutter clean && flutter pub get  # Clean and reinstall"
    echo "• ./scripts/mobile-setup-fixed.sh   # Re-run this script"
    echo ""
}

# Function to handle script interruption
cleanup() {
    print_warning "Script interrupted. Cleaning up..."
    cd "$PROJECT_ROOT" || exit 1
    exit 1
}

# Set up signal handlers
trap cleanup SIGINT SIGTERM

# Main execution function
main() {
    local overall_success=true
    
    echo ""
    print_status "Starting mobile setup process..."
    print_status "Project root: $PROJECT_ROOT"
    echo ""
    
    # Run setup steps with error handling
    check_flutter || overall_success=false
    echo ""
    
    check_flutter_doctor || true  # Don't fail on doctor issues
    echo ""
    
    install_dependencies || overall_success=false
    echo ""
    
    generate_code || overall_success=false
    echo ""
    
    setup_android || true  # Don't fail if Android setup has issues
    echo ""
    
    setup_ios || true  # Don't fail if iOS setup has issues
    echo ""
    
    setup_firebase || true  # Don't fail if Firebase setup has issues
    echo ""
    
    create_mobile_configs || overall_success=false
    echo ""
    
    run_mobile_tests || true  # Don't fail on test issues
    echo ""
    
    if [ "$overall_success" = true ]; then
        show_next_steps
        exit 0
    else
        print_error "Setup completed with some issues. Check the output above."
        show_next_steps
        exit 1
    fi
}

# Validate environment before starting
validate_environment() {
    print_status "Validating environment..."
    
    # Check if we're in a Flutter project
    if [ ! -f "$PROJECT_ROOT/pubspec.yaml" ]; then
        print_error "Not in a Flutter project directory (pubspec.yaml not found)"
        exit 1
    fi
    
    # Check if we have write permissions
    if [ ! -w "$PROJECT_ROOT" ]; then
        print_error "No write permission in project directory"
        exit 1
    fi
    
    print_success "Environment validation passed"
}

# Run validation and main function
validate_environment
main "$@"
