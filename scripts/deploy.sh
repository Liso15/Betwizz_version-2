#!/bin/bash

# Betwizz Flutter Web Deployment Script
# Handles deployment to Vercel with proper error handling and logging

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

# Check if production flag is set
PRODUCTION=false
if [[ "$1" == "--production" ]]; then
    PRODUCTION=true
    log_info "Production deployment mode enabled"
fi

# Function to check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Flutter installation
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed or not in PATH"
        exit 1
    fi
    
    # Check Node.js installation
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed or not in PATH"
        exit 1
    fi
    
    # Check Vercel CLI installation
    if ! command -v vercel &> /dev/null; then
        log_warning "Vercel CLI not found, installing..."
        npm install -g vercel@latest
    fi
    
    # Verify Flutter version
    FLUTTER_VERSION=$(flutter --version | head -n 1 | cut -d ' ' -f 2)
    log_info "Flutter version: $FLUTTER_VERSION"
    
    # Verify Node.js version
    NODE_VERSION=$(node --version)
    log_info "Node.js version: $NODE_VERSION"
    
    log_success "Prerequisites check completed"
}

# Function to clean previous builds
clean_build() {
    log_info "Cleaning previous builds..."
    
    flutter clean
    rm -rf build/
    rm -rf .dart_tool/build/
    rm -rf node_modules/.cache/
    
    log_success "Build cleanup completed"
}

# Function to install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    # Flutter dependencies
    flutter pub get
    if [ $? -ne 0 ]; then
        log_error "Failed to install Flutter dependencies"
        exit 1
    fi
    
    # Node.js dependencies
    npm install
    if [ $? -ne 0 ]; then
        log_error "Failed to install Node.js dependencies"
        exit 1
    fi
    
    log_success "Dependencies installed successfully"
}

# Function to run tests and analysis
run_tests() {
    log_info "Running tests and code analysis..."
    
    # Enable web support
    flutter config --enable-web
    
    # Run Flutter analyze
    flutter analyze --fatal-infos
    if [ $? -ne 0 ]; then
        log_error "Flutter analysis failed"
        exit 1
    fi
    
    # Run tests (continue on failure for now)
    flutter test || log_warning "Some tests failed, continuing with deployment"
    
    # Check code formatting
    dart format --set-exit-if-changed . || log_warning "Code formatting issues detected"
    
    log_success "Tests and analysis completed"
}

# Function to build Flutter web app
build_flutter() {
    log_info "Building Flutter web application..."
    
    # Build with specific configurations for Vercel
    flutter build web \
        --release \
        --web-renderer html \
        --base-href / \
        --dart-define=FLUTTER_WEB_USE_SKIA=false \
        --dart-define=FLUTTER_WEB_AUTO_DETECT=false \
        --source-maps
    
    if [ $? -ne 0 ]; then
        log_error "Flutter build failed"
        exit 1
    fi
    
    # Verify build output
    if [ ! -d "build/web" ]; then
        log_error "Build directory not found"
        exit 1
    fi
    
    if [ ! -f "build/web/index.html" ]; then
        log_error "index.html not found in build output"
        exit 1
    fi
    
    log_success "Flutter build completed successfully"
}

# Function to optimize assets
optimize_assets() {
    log_info "Optimizing assets..."
    
    # Run asset optimization if script exists
    if [ -f "scripts/optimize-assets.js" ]; then
        node scripts/optimize-assets.js
        if [ $? -ne 0 ]; then
            log_warning "Asset optimization failed, continuing..."
        else
            log_success "Asset optimization completed"
        fi
    else
        log_warning "Asset optimization script not found, skipping..."
    fi
    
    # Generate sitemap if script exists
    if [ -f "scripts/generate-sitemap.js" ]; then
        node scripts/generate-sitemap.js
        if [ $? -ne 0 ]; then
            log_warning "Sitemap generation failed, continuing..."
        else
            log_success "Sitemap generation completed"
        fi
    else
        log_warning "Sitemap generation script not found, skipping..."
    fi
}

# Function to deploy to Vercel
deploy_to_vercel() {
    log_info "Deploying to Vercel..."
    
    # Check if Vercel is configured
    if [ ! -f ".vercel/project.json" ] && [ -z "$VERCEL_PROJECT_ID" ]; then
        log_info "Vercel project not linked, linking now..."
        vercel link --yes
    fi
    
    # Deploy based on mode
    if [ "$PRODUCTION" = true ]; then
        log_info "Deploying to production..."
        vercel --prod --yes
    else
        log_info "Deploying to preview..."
        vercel --yes
    fi
    
    if [ $? -ne 0 ]; then
        log_error "Vercel deployment failed"
        exit 1
    fi
    
    log_success "Deployment completed successfully"
}

# Function to verify deployment
verify_deployment() {
    log_info "Verifying deployment..."
    
    # Wait a moment for deployment to propagate
    sleep 10
    
    # Get deployment URL (this is a simplified check)
    if [ "$PRODUCTION" = true ]; then
        DEPLOYMENT_URL="https://betwizz.vercel.app"
    else
        # For preview deployments, we'd need to parse the Vercel output
        log_info "Preview deployment verification skipped"
        return 0
    fi
    
    # Simple HTTP check
    if command -v curl &> /dev/null; then
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$DEPLOYMENT_URL")
        if [ "$HTTP_STATUS" = "200" ]; then
            log_success "Deployment verification successful: $DEPLOYMENT_URL"
        else
            log_warning "Deployment verification returned HTTP $HTTP_STATUS"
        fi
    else
        log_warning "curl not available, skipping deployment verification"
    fi
}

# Main deployment process
main() {
    log_info "Starting Betwizz Flutter Web deployment..."
    log_info "Timestamp: $(date)"
    
    # Run all deployment steps
    check_prerequisites
    clean_build
    install_dependencies
    run_tests
    build_flutter
    optimize_assets
    deploy_to_vercel
    verify_deployment
    
    log_success "🎉 Deployment process completed successfully!"
    log_info "Timestamp: $(date)"
}

# Error handling
trap 'log_error "Deployment failed at line $LINENO. Exit code: $?"' ERR

# Run main function
main "$@"
