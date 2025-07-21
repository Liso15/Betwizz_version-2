#!/bin/bash

# Mobile Setup Script for Betwizz Flutter App
# This script configures the development environment for mobile development

set -e

echo "🚀 Setting up Betwizz for Mobile Development"
echo "============================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if Flutter is installed
check_flutter() {
    print_status "Checking Flutter installation..."
    
    if ! command -v flutter &> /dev/null; then
        print_error "Flutter is not installed. Please install Flutter first."
        echo "Visit: https://docs.flutter.dev/get-started/install"
        exit 1
    fi
    
    flutter --version
    print_success "Flutter is installed"
}

# Check Flutter doctor
check_flutter_doctor() {
    print_status "Running Flutter doctor..."
    
    flutter doctor -v
    
    # Check for critical issues
    if flutter doctor | grep -q "✗"; then
        print_warning "Flutter doctor found some issues. Please resolve them for optimal development."
    else
        print_success "Flutter doctor checks passed"
    fi
}

# Setup Android development
setup_android() {
    print_status "Setting up Android development..."
    
    # Check if Android SDK is available
    if flutter doctor | grep -q "Android toolchain"; then
        print_success "Android toolchain is available"
        
        # Accept Android licenses
        print_status "Accepting Android licenses..."
        flutter doctor --android-licenses || true
        
        # Create Android keystore for release builds
        if [ ! -f "android/app/betwizz-key.jks" ]; then
            print_status "Creating Android keystore..."
            keytool -genkey -v -keystore android/app/betwizz-key.jks \
                -keyalg RSA -keysize 2048 -validity 10000 \
                -alias betwizz \
                -dname "CN=Betwizz, OU=Mobile, O=Betwizz, L=Cape Town, S=Western Cape, C=ZA" \
                -storepass betwizz123 -keypass betwizz123
            
            print_success "Android keystore created"
        fi
        
    else
        print_warning "Android toolchain not found. Install Android Studio and SDK."
    fi
}

# Setup iOS development (macOS only)
setup_ios() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Setting up iOS development..."
        
        # Check if Xcode is installed
        if command -v xcodebuild &> /dev/null; then
            print_success "Xcode is installed"
            
            # Check Xcode version
            xcode_version=$(xcodebuild -version | head -n 1 | awk '{print $2}')
            print_status "Xcode version: $xcode_version"
            
            # Install CocoaPods if not installed
            if ! command -v pod &> /dev/null; then
                print_status "Installing CocoaPods..."
                sudo gem install cocoapods
                print_success "CocoaPods installed"
            else
                print_success "CocoaPods is already installed"
            fi
            
            # Setup iOS pods
            print_status "Setting up iOS pods..."
            cd ios
            pod install --repo-update
            cd ..
            print_success "iOS pods installed"
            
        else
            print_warning "Xcode not found. Install Xcode from the App Store for iOS development."
        fi
    else
        print_warning "iOS development is only available on macOS"
    fi
}

# Install Flutter dependencies
install_dependencies() {
    print_status "Installing Flutter dependencies..."
    
    flutter pub get
    
    print_success "Flutter dependencies installed"
}

# Generate code (Hive adapters, etc.)
generate_code() {
    print_status "Generating code..."
    
    flutter packages pub run build_runner build --delete-conflicting-outputs
    
    print_success "Code generation completed"
}

# Setup Firebase
setup_firebase() {
    print_status "Setting up Firebase..."
    
    # Check if Firebase CLI is installed
    if command -v firebase &> /dev/null; then
        print_success "Firebase CLI is available"
        
        # Configure Firebase for Flutter
        if command -v flutterfire &> /dev/null; then
            print_status "Configuring Firebase for Flutter..."
            flutterfire configure --project=betwizz-app
            print_success "Firebase configured"
        else
            print_warning "FlutterFire CLI not found. Install with: dart pub global activate flutterfire_cli"
        fi
    else
        print_warning "Firebase CLI not found. Install from: https://firebase.google.com/docs/cli"
    fi
}

# Run mobile-specific tests
run_mobile_tests() {
    print_status "Running mobile compatibility tests..."
    
    # Test Android build
    if flutter doctor | grep -q "Android toolchain"; then
        print_status "Testing Android build..."
        flutter build apk --debug --target-platform android-arm64
        print_success "Android build test passed"
    fi
    
    # Test iOS build (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]] && command -v xcodebuild &> /dev/null; then
        print_status "Testing iOS build..."
        flutter build ios --debug --no-codesign
        print_success "iOS build test passed"
    fi
}

# Create mobile-specific configuration files
create_mobile_configs() {
    print_status "Creating mobile configuration files..."
    
    # Create Android signing configuration
    cat > android/key.properties << EOF
storePassword=betwizz123
keyPassword=betwizz123
keyAlias=betwizz
storeFile=betwizz-key.jks
EOF
    
    # Create mobile-specific environment file
    cat > .env.mobile << EOF
# Mobile-specific environment variables
MOBILE_MODE=true
ENABLE_CAMERA=true
ENABLE_MICROPHONE=true
ENABLE_NOTIFICATIONS=true
PERFORMANCE_MODE=auto
CACHE_SIZE=50MB
EOF
    
    print_success "Mobile configuration files created"
}

# Main execution
main() {
    echo ""
    print_status "Starting mobile setup process..."
    echo ""
    
    check_flutter
    echo ""
    
    check_flutter_doctor
    echo ""
    
    install_dependencies
    echo ""
    
    generate_code
    echo ""
    
    setup_android
    echo ""
    
    setup_ios
    echo ""
    
    setup_firebase
    echo ""
    
    create_mobile_configs
    echo ""
    
    run_mobile_tests
    echo ""
    
    print_success "Mobile setup completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Connect an Android device or start an emulator"
    echo "2. Run: flutter run"
    echo "3. For iOS: Open ios/Runner.xcworkspace in Xcode"
    echo ""
    print_status "Useful commands:"
    echo "• flutter run -d android    # Run on Android"
    echo "• flutter run -d ios        # Run on iOS"
    echo "• flutter build apk         # Build Android APK"
    echo "• flutter build ios         # Build iOS app"
    echo ""
}

# Run main function
main "$@"
