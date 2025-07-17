#!/bin/bash

# Build Analysis Script for Betwizz Flutter Web
# Analyzes build output and provides insights

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[ANALYSIS]${NC} $1"
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

# Check if build directory exists
if [ ! -d "build/web" ]; then
    log_error "Build directory not found. Run 'flutter build web' first."
    exit 1
fi

log_info "Starting build analysis..."

# Analyze build size
BUILD_SIZE=$(du -sh build/web | cut -f1)
log_info "Total build size: $BUILD_SIZE"

# Count files
FILE_COUNT=$(find build/web -type f | wc -l)
log_info "Total files: $FILE_COUNT"

# Analyze main.dart.js size (the main Flutter bundle)
if [ -f "build/web/main.dart.js" ]; then
    MAIN_JS_SIZE=$(du -sh build/web/main.dart.js | cut -f1)
    log_info "Main Flutter bundle size: $MAIN_JS_SIZE"
else
    log_warning "main.dart.js not found"
fi

# Check for source maps
if [ -f "build/web/main.dart.js.map" ]; then
    log_success "Source maps generated"
else
    log_warning "Source maps not found"
fi

# Analyze assets
if [ -d "build/web/assets" ]; then
    ASSETS_SIZE=$(du -sh build/web/assets | cut -f1)
    ASSETS_COUNT=$(find build/web/assets -type f | wc -l)
    log_info "Assets size: $ASSETS_SIZE ($ASSETS_COUNT files)"
else
    log_warning "Assets directory not found"
fi

# Check for Flutter service worker
if [ -f "build/web/flutter_service_worker.js" ]; then
    log_success "Flutter service worker found"
else
    log_warning "Flutter service worker not found"
fi

# Check for manifest.json
if [ -f "build/web/manifest.json" ]; then
    log_success "Web app manifest found"
else
    log_warning "Web app manifest not found"
fi

# Check for favicon
if [ -f "build/web/favicon.png" ]; then
    log_success "Favicon found"
else
    log_warning "Favicon not found"
fi

# Analyze largest files
log_info "Top 10 largest files:"
find build/web -type f -exec du -h {} + | sort -rh | head -10

# Check for potential issues
log_info "Checking for potential issues..."

# Check if build is too large
BUILD_SIZE_MB=$(du -sm build/web | cut -f1)
if [ "$BUILD_SIZE_MB" -gt 50 ]; then
    log_warning "Build size is quite large (${BUILD_SIZE_MB}MB). Consider optimization."
elif [ "$BUILD_SIZE_MB" -gt 100 ]; then
    log_error "Build size is very large (${BUILD_SIZE_MB}MB). Optimization required."
else
    log_success "Build size is reasonable (${BUILD_SIZE_MB}MB)"
fi

# Check for debug artifacts
if grep -r "debugPrint\|print(" build/web/ > /dev/null 2>&1; then
    log_warning "Debug print statements found in build"
fi

# Check for development dependencies
if grep -r "flutter_test\|test:" build/web/ > /dev/null 2>&1; then
    log_warning "Test dependencies may be included in build"
fi

log_success "Build analysis completed"

# Generate analysis report
cat > build/web/build-analysis.json << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "buildSize": "$BUILD_SIZE",
  "buildSizeMB": $BUILD_SIZE_MB,
  "fileCount": $FILE_COUNT,
  "mainBundleSize": "${MAIN_JS_SIZE:-unknown}",
  "assetsSize": "${ASSETS_SIZE:-unknown}",
  "assetsCount": ${ASSETS_COUNT:-0},
  "hasSourceMaps": $([ -f "build/web/main.dart.js.map" ] && echo "true" || echo "false"),
  "hasServiceWorker": $([ -f "build/web/flutter_service_worker.js" ] && echo "true" || echo "false"),
  "hasManifest": $([ -f "build/web/manifest.json" ] && echo "true" || echo "false"),
  "hasFavicon": $([ -f "build/web/favicon.png" ] && echo "true" || echo "false")
}
EOF

log_success "Analysis report saved to build/web/build-analysis.json"
