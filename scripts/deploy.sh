#!/bin/bash

echo "🚀 Starting Betwizz deployment process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed or not in PATH"
    exit 1
fi

# Step 1: Clean previous builds
print_status "Cleaning previous builds..."
flutter clean
if [ $? -ne 0 ]; then
    print_error "Flutter clean failed"
    exit 1
fi

# Step 2: Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get
if [ $? -ne 0 ]; then
    print_error "Flutter pub get failed"
    exit 1
fi

# Step 3: Install Node.js dependencies
print_status "Installing Node.js dependencies..."
npm install
if [ $? -ne 0 ]; then
    print_error "npm install failed"
    exit 1
fi

# Step 4: Run Flutter analyzer
print_status "Running Flutter analyzer..."
flutter analyze
if [ $? -ne 0 ]; then
    print_warning "Flutter analyzer found issues, but continuing..."
fi

# Step 5: Run tests
print_status "Running Flutter tests..."
flutter test
if [ $? -ne 0 ]; then
    print_warning "Some tests failed, but continuing..."
fi

# Step 6: Build for web
print_status "Building Flutter web app..."
flutter build web --release --web-renderer html --base-href /
if [ $? -ne 0 ]; then
    print_error "Flutter web build failed"
    exit 1
fi

# Step 7: Optimize assets
print_status "Optimizing assets..."
npm run optimize:assets
if [ $? -ne 0 ]; then
    print_warning "Asset optimization failed, but continuing..."
fi

# Step 8: Generate sitemap
print_status "Generating sitemap..."
npm run generate:sitemap
if [ $? -ne 0 ]; then
    print_warning "Sitemap generation failed, but continuing..."
fi

# Step 9: Verify build
print_status "Verifying build..."
npm run verify:build
if [ $? -ne 0 ]; then
    print_error "Build verification failed"
    exit 1
fi

# Step 10: Deploy to Vercel (if vercel CLI is available)
if command -v vercel &> /dev/null; then
    print_status "Deploying to Vercel..."
    vercel --prod
    if [ $? -eq 0 ]; then
        print_status "Deployment to Vercel successful!"
    else
        print_error "Deployment to Vercel failed"
        exit 1
    fi
else
    print_warning "Vercel CLI not found. Skipping deployment."
    print_status "Build completed successfully. Ready for manual deployment."
fi

print_status "🎉 Deployment process completed successfully!"
print_status "Build artifacts are available in: build/web/"
