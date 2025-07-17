#!/bin/bash

# Betwizz Flutter Web Build Analysis Script
# Analyzes build output and provides detailed metrics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

BUILD_DIR="build/web"
ANALYSIS_DIR="build/analysis"

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

log_metric() {
    echo -e "${PURPLE}[METRIC]${NC} $1"
}

# Create analysis directory
mkdir -p "$ANALYSIS_DIR"

analyze_build_size() {
    log_info "Analyzing build size..."
    
    if [[ ! -d "$BUILD_DIR" ]]; then
        log_error "Build directory not found. Run 'npm run build' first."
        exit 1
    fi
    
    # Total build size
    TOTAL_SIZE=$(du -sh "$BUILD_DIR" | cut -f1)
    log_metric "Total build size: $TOTAL_SIZE"
    
    # JavaScript bundle sizes
    log_info "JavaScript bundle analysis:"
    find "$BUILD_DIR" -name "*.js" -type f -exec du -h {} + | sort -hr | head -10 | while read size file; do
        filename=$(basename "$file")
        log_metric "  $filename: $size"
    done
    
    # CSS bundle sizes
    log_info "CSS bundle analysis:"
    find "$BUILD_DIR" -name "*.css" -type f -exec du -h {} + | sort -hr | head -5 | while read size file; do
        filename=$(basename "$file")
        log_metric "  $filename: $size"
    done
    
    # Asset sizes
    log_info "Asset analysis:"
    if [[ -d "$BUILD_DIR/assets" ]]; then
        ASSETS_SIZE=$(du -sh "$BUILD_DIR/assets" | cut -f1)
        log_metric "  Total assets: $ASSETS_SIZE"
        
        # Image assets
        find "$BUILD_DIR/assets" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" | wc -l | xargs -I {} log_metric "  Image files: {}"
        
        # Font assets
        find "$BUILD_DIR/assets" -name "*.ttf" -o -name "*.woff" -o -name "*.woff2" | wc -l | xargs -I {} log_metric "  Font files: {}"
    fi
}

analyze_performance() {
    log_info "Analyzing performance metrics..."
    
    # Check for source maps
    if find "$BUILD_DIR" -name "*.map" | grep -q .; then
        log_warning "Source maps found in production build"
        find "$BUILD_DIR" -name "*.map" -exec du -h {} + | head -5
    else
        log_success "No source maps in production build"
    fi
    
    # Check for uncompressed files
    LARGE_FILES=$(find "$BUILD_DIR" -type f -size +1M)
    if [[ -n "$LARGE_FILES" ]]; then
        log_warning "Large files detected (>1MB):"
        echo "$LARGE_FILES" | while read file; do
            size=$(du -h "$file" | cut -f1)
            log_metric "  $(basename "$file"): $size"
        done
    else
        log_success "No large files detected"
    fi
    
    # Check for Flutter web optimizations
    if [[ -f "$BUILD_DIR/main.dart.js" ]]; then
        MAIN_JS_SIZE=$(du -h "$BUILD_DIR/main.dart.js" | cut -f1)
        log_metric "Main Dart JS bundle: $MAIN_JS_SIZE"
        
        # Check if minified
        if grep -q "^/\*" "$BUILD_DIR/main.dart.js"; then
            log_warning "JavaScript may not be properly minified"
        else
            log_success "JavaScript appears to be minified"
        fi
    fi
}

analyze_assets() {
    log_info "Analyzing asset optimization..."
    
    # Check image optimization
    if [[ -d "$BUILD_DIR/assets/images" ]]; then
        PNG_COUNT=$(find "$BUILD_DIR/assets/images" -name "*.png" | wc -l)
        JPG_COUNT=$(find "$BUILD_DIR/assets/images" -name "*.jpg" -o -name "*.jpeg" | wc -l)
        
        log_metric "PNG images: $PNG_COUNT"
        log_metric "JPEG images: $JPG_COUNT"
        
        # Check for unoptimized images
        LARGE_IMAGES=$(find "$BUILD_DIR/assets/images" -type f -size +500k)
        if [[ -n "$LARGE_IMAGES" ]]; then
            log_warning "Large images detected (>500KB):"
            echo "$LARGE_IMAGES" | while read file; do
                size=$(du -h "$file" | cut -f1)
                log_metric "  $(basename "$file"): $size"
            done
        else
            log_success "All images are optimally sized"
        fi
    fi
    
    # Check font optimization
    if [[ -d "$BUILD_DIR/assets/fonts" ]]; then
        FONT_COUNT=$(find "$BUILD_DIR/assets/fonts" -name "*.ttf" -o -name "*.woff" -o -name "*.woff2" | wc -l)
        log_metric "Font files: $FONT_COUNT"
        
        # Prefer WOFF2 over TTF
        TTF_COUNT=$(find "$BUILD_DIR/assets/fonts" -name "*.ttf" | wc -l)
        WOFF2_COUNT=$(find "$BUILD_DIR/assets/fonts" -name "*.woff2" | wc -l)
        
        if [[ $TTF_COUNT -gt 0 && $WOFF2_COUNT -eq 0 ]]; then
            log_warning "Consider converting TTF fonts to WOFF2 for better compression"
        fi
    fi
}

analyze_seo() {
    log_info "Analyzing SEO optimization..."
    
    if [[ -f "$BUILD_DIR/index.html" ]]; then
        # Check meta tags
        if grep -q "<meta name=\"description\"" "$BUILD_DIR/index.html"; then
            log_success "Meta description found"
        else
            log_warning "Meta description missing"
        fi
        
        if grep -q "<meta property=\"og:" "$BUILD_DIR/index.html"; then
            log_success "Open Graph tags found"
        else
            log_warning "Open Graph tags missing"
        fi
        
        if grep -q "<meta name=\"twitter:" "$BUILD_DIR/index.html"; then
            log_success "Twitter Card tags found"
        else
            log_warning "Twitter Card tags missing"
        fi
        
        # Check for structured data
        if grep -q "application/ld+json" "$BUILD_DIR/index.html"; then
            log_success "Structured data found"
        else
            log_warning "Structured data missing"
        fi
    fi
    
    # Check for sitemap
    if [[ -f "$BUILD_DIR/sitemap.xml" ]]; then
        log_success "Sitemap found"
        SITEMAP_URLS=$(grep -c "<url>" "$BUILD_DIR/sitemap.xml" || echo "0")
        log_metric "Sitemap URLs: $SITEMAP_URLS"
    else
        log_warning "Sitemap missing"
    fi
    
    # Check for robots.txt
    if [[ -f "$BUILD_DIR/robots.txt" ]]; then
        log_success "Robots.txt found"
    else
        log_warning "Robots.txt missing"
    fi
}

generate_report() {
    log_info "Generating analysis report..."
    
    REPORT_FILE="$ANALYSIS_DIR/build-analysis-$(date +%Y%m%d-%H%M%S).json"
    
    cat > "$REPORT_FILE" << EOF
{
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "buildDirectory": "$BUILD_DIR",
  "totalSize": "$(du -sb "$BUILD_DIR" | cut -f1)",
  "totalSizeFormatted": "$(du -sh "$BUILD_DIR" | cut -f1)",
  "fileCount": $(find "$BUILD_DIR" -type f | wc -l),
  "jsFiles": $(find "$BUILD_DIR" -name "*.js" | wc -l),
  "cssFiles": $(find "$BUILD_DIR" -name "*.css" | wc -l),
  "imageFiles": $(find "$BUILD_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" | wc -l),
  "fontFiles": $(find "$BUILD_DIR" -name "*.ttf" -o -name "*.woff" -o -name "*.woff2" | wc -l),
  "hasSourceMaps": $(find "$BUILD_DIR" -name "*.map" | wc -l | awk '{print ($1 > 0)}'),
  "hasSitemap": $(test -f "$BUILD_DIR/sitemap.xml" && echo "true" || echo "false"),
  "hasRobots": $(test -f "$BUILD_DIR/robots.txt" && echo "true" || echo "false")
}
EOF
    
    log_success "Analysis report saved to: $REPORT_FILE"
}

main() {
    log_info "Starting Betwizz build analysis..."
    
    analyze_build_size
    echo
    analyze_performance
    echo
    analyze_assets
    echo
    analyze_seo
    echo
    generate_report
    
    log_success "Build analysis completed!"
    
    # Summary
    echo
    echo "=== BUILD ANALYSIS SUMMARY ==="
    log_metric "Build directory: $BUILD_DIR"
    log_metric "Total size: $(du -sh "$BUILD_DIR" | cut -f1)"
    log_metric "File count: $(find "$BUILD_DIR" -type f | wc -l)"
    log_metric "Analysis saved: $ANALYSIS_DIR"
}

main "$@"
