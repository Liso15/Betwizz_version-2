#!/bin/bash

# Betwizz Flutter Web Deployment Script
# Comprehensive deployment automation for Vercel

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
PROJECT_NAME="betwizz-flutter-app"
BUILD_DIR="build/web"
VERCEL_CONFIG="vercel.json"

# Parse command line arguments
PRODUCTION=false
PREVIEW=false
SKIP_BUILD=false
SKIP_TESTS=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --production|-p)
      PRODUCTION=true
      shift
      ;;
    --preview)
      PREVIEW=true
      shift
      ;;
    --skip-build)
      SKIP_BUILD=true
      shift
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --production, -p    Deploy to production"
      echo "  --preview          Deploy as preview"
      echo "  --skip-build       Skip build process"
      echo "  --skip-tests       Skip test execution"
      echo "  --help, -h         Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

check_dependencies() {
    log_step "Checking dependencies..."
    
    # Check Flutter
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed or not in PATH"
        exit 1
    fi
    
    # Check Vercel CLI
    if ! command -v vercel &> /dev/null; then
        log_warning "Vercel CLI not found. Installing..."
        npm install -g vercel@latest
    fi
    
    # Check Flutter web support
    if ! flutter config | grep -q "enable-web: true"; then
        log_info "Enabling Flutter web support..."
        flutter config --enable-web
    fi
    
    log_success "All dependencies are available"
}

run_tests() {
    if [[ "$SKIP_TESTS" == "true" ]]; then
        log_warning "Skipping tests as requested"
        return 0
    fi
    
    log_step "Running tests..."
    
    # Run Flutter tests
    if ! flutter test; then
        log_error "Flutter tests failed"
        exit 1
    fi
    
    # Run Flutter analyze
    if ! flutter analyze --fatal-infos; then
        log_error "Flutter analyze found issues"
        exit 1
    fi
    
    log_success "All tests passed"
}

build_application() {
    if [[ "$SKIP_BUILD" == "true" ]]; then
        log_warning "Skipping build as requested"
        return 0
    fi
    
    log_step "Building Flutter web application..."
    
    # Clean previous build
    flutter clean
    
    # Get dependencies
    flutter pub get
    
    # Build for web
    flutter build web \
        --release \
        --web-renderer html \
        --base-href / \
        --dart-define=FLUTTER_WEB_USE_SKIA=false \
        --dart-define=FLUTTER_WEB_AUTO_DETECT=false
    
    if [[ ! -d "$BUILD_DIR" ]]; then
        log_error "Build failed - output directory not found"
        exit 1
    fi
    
    log_success "Build completed successfully"
}

optimize_build() {
    log_step "Optimizing build output..."
    
    # Run asset optimization
    if [[ -f "scripts/optimize-assets.js" ]]; then
        node scripts/optimize-assets.js
    else
        log_warning "Asset optimization script not found"
    fi
    
    # Generate sitemap
    if [[ -f "scripts/generate-sitemap.js" ]]; then
        node scripts/generate-sitemap.js
    else
        log_warning "Sitemap generation script not found"
    fi
    
    # Create robots.txt
    cat > "$BUILD_DIR/robots.txt" << EOF
User-agent: *
Allow: /
Sitemap: https://betwizz.vercel.app/sitemap.xml

# Disallow admin and private areas
Disallow: /admin/
Disallow: /api/
Disallow: /_next/
EOF
    
    log_success "Build optimization completed"
}

validate_build() {
    log_step "Validating build output..."
    
    # Check required files
    required_files=("index.html" "main.dart.js" "flutter_service_worker.js" "manifest.json")
    
    for file in "${required_files[@]}"; do
        if [[ ! -f "$BUILD_DIR/$file" ]]; then
            log_error "Required file missing: $file"
            exit 1
        fi
    done
    
    # Check build size
    build_size=$(du -sh "$BUILD_DIR" | cut -f1)
    log_info "Total build size: $build_size"
    
    # Check for large files
    large_files=$(find "$BUILD_DIR" -type f -size +10M)
    if [[ -n "$large_files" ]]; then
        log_warning "Large files detected (>10MB):"
        echo "$large_files" | while read file; do
            size=$(du -h "$file" | cut -f1)
            log_warning "  $(basename "$file"): $size"
        done
    fi
    
    log_success "Build validation passed"
}

deploy_to_vercel() {
    log_step "Deploying to Vercel..."
    
    # Check Vercel configuration
    if [[ ! -f "$VERCEL_CONFIG" ]]; then
        log_error "Vercel configuration file not found: $VERCEL_CONFIG"
        exit 1
    fi
    
    # Set deployment command based on environment
    if [[ "$PRODUCTION" == "true" ]]; then
        log_info "Deploying to production..."
        vercel --prod --yes
    else
        log_info "Deploying as preview..."
        vercel --yes
    fi
    
    # Get deployment URL
    deployment_url=$(vercel ls | grep "$PROJECT_NAME" | head -1 | awk '{print $2}')
    
    if [[ -n "$deployment_url" ]]; then
        log_success "Deployment successful!"
        log_info "URL: https://$deployment_url"
    else
        log_error "Failed to get deployment URL"
        exit 1
    fi
}

verify_deployment() {
    log_step "Verifying deployment..."
    
    # Get the latest deployment URL
    deployment_url=$(vercel ls | grep "$PROJECT_NAME" | head -1 | awk '{print $2}')
    
    if [[ -z "$deployment_url" ]]; then
        log_error "Could not determine deployment URL"
        return 1
    fi
    
    full_url="https://$deployment_url"
    
    # Test basic connectivity
    if curl -f -s "$full_url" > /dev/null; then
        log_success "Deployment is accessible"
    else
        log_error "Deployment is not accessible"
        return 1
    fi
    
    # Test specific endpoints
    endpoints=("/" "/manifest.json" "/flutter_service_worker.js")
    
    for endpoint in "${endpoints[@]}"; do
        if curl -f -s "$full_url$endpoint" > /dev/null; then
            log_success "✓ $endpoint is accessible"
        else
            log_warning "✗ $endpoint is not accessible"
        fi
    done
    
    log_success "Deployment verification completed"
    log_info "🚀 Your Betwizz app is live at: $full_url"
}

cleanup() {
    log_step "Cleaning up temporary files..."
    
    # Remove any temporary files created during deployment
    if [[ -f ".vercel/project.json.tmp" ]]; then
        rm -f ".vercel/project.json.tmp"
    fi
    
    log_success "Cleanup completed"
}

main() {
    log_info "🚀 Starting Betwizz deployment process..."
    
    # Trap to ensure cleanup on exit
    trap cleanup EXIT
    
    check_dependencies
    run_tests
    build_application
    optimize_build
    validate_build
    deploy_to_vercel
    verify_deployment
    
    log_success "🎉 Deployment completed successfully!"
    
    if [[ "$PRODUCTION" == "true" ]]; then
        log_info "📱 Production deployment is now live!"
    else
        log_info "🔍 Preview deployment is ready for testing!"
    fi
}

# Run main function
main "$@"
