#!/bin/bash

# Betwizz Flutter Web Deployment Script
# This script handles the complete deployment process to Vercel

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
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

# Check if required tools are installed
check_dependencies() {
    log_info "Checking dependencies..."
    
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v vercel &> /dev/null; then
        log_error "Vercel CLI is not installed. Install with: npm i -g vercel"
        exit 1
    fi
    
    log_success "All dependencies are available"
}

# Verify environment variables
check_environment() {
    log_info "Checking environment variables..."
    
    if [[ -z "$VERCEL_TOKEN" ]]; then
        log_error "VERCEL_TOKEN environment variable is not set"
        exit 1
    fi
    
    if [[ -z "$VERCEL_ORG_ID" ]]; then
        log_error "VERCEL_ORG_ID environment variable is not set"
        exit 1
    fi
    
    if [[ -z "$VERCEL_PROJECT_ID" ]]; then
        log_error "VERCEL_PROJECT_ID environment variable is not set"
        exit 1
    fi
    
    log_success "Environment variables are configured"
}

# Clean previous builds
clean_build() {
    log_info "Cleaning previous builds..."
    
    flutter clean
    rm -rf build/
    rm -rf .dart_tool/
    
    log_success "Build directory cleaned"
}

# Install dependencies
install_dependencies() {
    log_info "Installing Flutter dependencies..."
    
    flutter pub get
    
    if [[ $? -ne 0 ]]; then
        log_error "Failed to install Flutter dependencies"
        exit 1
    fi
    
    log_success "Dependencies installed successfully"
}

# Run code analysis
analyze_code() {
    log_info "Running code analysis..."
    
    flutter analyze --fatal-infos
    
    if [[ $? -ne 0 ]]; then
        log_warning "Code analysis found issues, but continuing..."
    else
        log_success "Code analysis passed"
    fi
}

# Run tests
run_tests() {
    log_info "Running tests..."
    
    flutter test
    
    if [[ $? -ne 0 ]]; then
        log_warning "Some tests failed, but continuing with deployment..."
    else
        log_success "All tests passed"
    fi
}

# Build Flutter web app
build_app() {
    log_info "Building Flutter web application..."
    
    # Enable web support
    flutter config --enable-web
    
    # Build the web app
    flutter build web \
        --release \
        --web-renderer html \
        --base-href "/" \
        --dart-define=FLUTTER_WEB_USE_SKIA=false \
        --dart-define=FLUTTER_WEB_AUTO_DETECT=false \
        --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.33.0/bin/ \
        --source-maps
    
    if [[ $? -ne 0 ]]; then
        log_error "Flutter web build failed"
        exit 1
    fi
    
    log_success "Flutter web build completed"
}

# Verify build output
verify_build() {
    log_info "Verifying build output..."
    
    if [[ ! -d "build/web" ]]; then
        log_error "Build directory 'build/web' does not exist"
        exit 1
    fi
    
    if [[ ! -f "build/web/index.html" ]]; then
        log_error "index.html not found in build output"
        exit 1
    fi
    
    if [[ ! -f "build/web/main.dart.js" ]]; then
        log_error "main.dart.js not found in build output"
        exit 1
    fi
    
    # Check build size
    BUILD_SIZE=$(du -sh build/web | cut -f1)
    log_info "Build size: $BUILD_SIZE"
    
    # List critical files
    log_info "Build contents:"
    ls -la build/web/ | head -10
    
    log_success "Build verification completed"
}

# Optimize build for deployment
optimize_build() {
    log_info "Optimizing build for deployment..."
    
    # Create deployment directory
    rm -rf deployment/
    mkdir -p deployment
    
    # Copy build files
    cp -r build/web/* deployment/
    
    # Optimize images (if imagemagick is available)
    if command -v convert &> /dev/null; then
        log_info "Optimizing images..."
        find deployment -name "*.png" -exec convert {} -strip -quality 85 {} \;
        find deployment -name "*.jpg" -exec convert {} -strip -quality 85 {} \;
    fi
    
    # Create .vercelignore if it doesn't exist
    if [[ ! -f "deployment/.vercelignore" ]]; then
        cat > deployment/.vercelignore << EOF
*.map
*.dart
*.md
.git/
.github/
test/
EOF
    fi
    
    log_success "Build optimization completed"
}

# Deploy to Vercel
deploy_to_vercel() {
    local ENVIRONMENT=$1
    
    log_info "Deploying to Vercel ($ENVIRONMENT)..."
    
    cd deployment
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        vercel --token "$VERCEL_TOKEN" \
               --scope "$VERCEL_ORG_ID" \
               --prod \
               --confirm \
               --yes
    else
        vercel --token "$VERCEL_TOKEN" \
               --scope "$VERCEL_ORG_ID" \
               --confirm \
               --yes
    fi
    
    if [[ $? -ne 0 ]]; then
        log_error "Vercel deployment failed"
        exit 1
    fi
    
    cd ..
    log_success "Deployment to Vercel completed"
}

# Post-deployment verification
verify_deployment() {
    log_info "Verifying deployment..."
    
    # Get deployment URL from Vercel
    DEPLOYMENT_URL=$(vercel ls --token "$VERCEL_TOKEN" --scope "$VERCEL_ORG_ID" | grep betwizz | head -1 | awk '{print $2}')
    
    if [[ -n "$DEPLOYMENT_URL" ]]; then
        log_info "Deployment URL: https://$DEPLOYMENT_URL"
        
        # Test if the deployment is accessible
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://$DEPLOYMENT_URL")
        
        if [[ "$HTTP_STATUS" == "200" ]]; then
            log_success "Deployment is accessible and returning HTTP 200"
        else
            log_warning "Deployment returned HTTP $HTTP_STATUS"
        fi
    else
        log_warning "Could not retrieve deployment URL"
    fi
}

# Main deployment function
main() {
    log_info "Starting Betwizz Flutter Web deployment process..."
    
    # Parse command line arguments
    ENVIRONMENT="preview"
    SKIP_TESTS=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --production)
                ENVIRONMENT="production"
                shift
                ;;
            --skip-tests)
                SKIP_TESTS=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--production] [--skip-tests]"
                echo "  --production: Deploy to production environment"
                echo "  --skip-tests: Skip running tests"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Run deployment steps
    check_dependencies
    check_environment
    clean_build
    install_dependencies
    analyze_code
    
    if [[ "$SKIP_TESTS" != true ]]; then
        run_tests
    fi
    
    build_app
    verify_build
    optimize_build
    deploy_to_vercel "$ENVIRONMENT"
    verify_deployment
    
    log_success "Betwizz deployment completed successfully!"
    
    if [[ "$ENVIRONMENT" == "production" ]]; then
        log_info "🚀 Production deployment is live!"
    else
        log_info "🔍 Preview deployment is ready for testing"
    fi
}

# Run main function with all arguments
main "$@"
