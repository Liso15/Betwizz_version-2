#!/bin/bash

# Build Analysis Script for Betwizz Flutter Web
# Analyzes build output and provides optimization recommendations

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

BUILD_DIR="build/web"

echo -e "${BLUE}📊 Analyzing Betwizz build output...${NC}"

if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${RED}❌ Build directory not found. Run 'flutter build web' first.${NC}"
    exit 1
fi

# File size analysis
echo -e "\n${BLUE}📁 File Size Analysis:${NC}"
echo "----------------------------------------"

# Find largest files
echo -e "${YELLOW}🔝 Largest files:${NC}"
find "$BUILD_DIR" -type f -exec ls -lh {} + | sort -k5 -hr | head -10 | while read -r line; do
    size=$(echo "$line" | awk '{print $5}')
    file=$(echo "$line" | awk '{print $9}' | sed "s|$BUILD_DIR/||")
    echo "   $size - $file"
done

# Total build size
total_size=$(du -sh "$BUILD_DIR" | cut -f1)
echo -e "\n${GREEN}📦 Total build size: $total_size${NC}"

# File count
file_count=$(find "$BUILD_DIR" -type f | wc -l)
echo -e "${GREEN}📄 Total files: $file_count${NC}"

# Asset analysis
echo -e "\n${BLUE}🎨 Asset Analysis:${NC}"
echo "----------------------------------------"

# Images
image_count=$(find "$BUILD_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" | wc -l)
image_size=$(find "$BUILD_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.gif" -o -name "*.svg" -exec ls -l {} + | awk '{sum += $5} END {print sum/1024/1024}' 2>/dev/null || echo "0")
echo -e "   Images: $image_count files (~${image_size%.*}MB)"

# JavaScript
js_count=$(find "$BUILD_DIR" -name "*.js" | wc -l)
js_size=$(find "$BUILD_DIR" -name "*.js" -exec ls -l {} + | awk '{sum += $5} END {print sum/1024/1024}' 2>/dev/null || echo "0")
echo -e "   JavaScript: $js_count files (~${js_size%.*}MB)"

# CSS
css_count=$(find "$BUILD_DIR" -name "*.css" | wc -l)
css_size=$(find "$BUILD_DIR" -name "*.css" -exec ls -l {} + | awk '{sum += $5} END {print sum/1024/1024}' 2>/dev/null || echo "0")
echo -e "   CSS: $css_count files (~${css_size%.*}MB)"

# Fonts
font_count=$(find "$BUILD_DIR" -name "*.woff*" -o -name "*.ttf" -o -name "*.otf" | wc -l)
font_size=$(find "$BUILD_DIR" -name "*.woff*" -o -name "*.ttf" -o -name "*.otf" -exec ls -l {} + | awk '{sum += $5} END {print sum/1024/1024}' 2>/dev/null || echo "0")
echo -e "   Fonts: $font_count files (~${font_size%.*}MB)"

# Performance recommendations
echo -e "\n${BLUE}⚡ Performance Recommendations:${NC}"
echo "----------------------------------------"

# Check main.dart.js size
if [ -f "$BUILD_DIR/main.dart.js" ]; then
    main_js_size=$(ls -lh "$BUILD_DIR/main.dart.js" | awk '{print $5}')
    main_js_bytes=$(ls -l "$BUILD_DIR/main.dart.js" | awk '{print $5}')
    
    echo -e "   Main bundle size: $main_js_size"
    
    if [ "$main_js_bytes" -gt 5242880 ]; then  # 5MB
        echo -e "${YELLOW}   ⚠️  Large main bundle detected. Consider code splitting.${NC}"
    else
        echo -e "${GREEN}   ✅ Main bundle size is acceptable${NC}"
    fi
fi

# Check for source maps
if find "$BUILD_DIR" -name "*.map" | grep -q .; then
    echo -e "${YELLOW}   ⚠️  Source maps found in production build${NC}"
    echo -e "      Consider removing them for smaller bundle size"
else
    echo -e "${GREEN}   ✅ No source maps in production build${NC}"
fi

# Check for uncompressed assets
large_images=$(find "$BUILD_DIR" -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -exec ls -l {} + | awk '$5 > 500000 {print $9}' | wc -l)
if [ "$large_images" -gt 0 ]; then
    echo -e "${YELLOW}   ⚠️  $large_images large images found (>500KB)${NC}"
    echo -e "      Consider optimizing images"
else
    echo -e "${GREEN}   ✅ Image sizes are optimized${NC}"
fi

# Check critical files
echo -e "\n${BLUE}🔍 Critical Files Check:${NC}"
echo "----------------------------------------"

critical_files=("index.html" "main.dart.js" "flutter_service_worker.js" "manifest.json")
for file in "${critical_files[@]}"; do
    if [ -f "$BUILD_DIR/$file" ]; then
        size=$(ls -lh "$BUILD_DIR/$file" | awk '{print $5}')
        echo -e "${GREEN}   ✅ $file ($size)${NC}"
    else
        echo -e "${RED}   ❌ $file (missing)${NC}"
    fi
done

# Caching recommendations
echo -e "\n${BLUE}💾 Caching Strategy:${NC}"
echo "----------------------------------------"
echo -e "   Static assets (images, fonts): ${GREEN}1 year cache${NC}"
echo -e "   JavaScript/CSS: ${YELLOW}1 day cache${NC}"
echo -e "   Service worker: ${RED}No cache${NC}"
echo -e "   HTML: ${RED}No cache${NC}"

# SEO check
echo -e "\n${BLUE}🔍 SEO Check:${NC}"
echo "----------------------------------------"

if [ -f "$BUILD_DIR/sitemap.xml" ]; then
    echo -e "${GREEN}   ✅ Sitemap found${NC}"
else
    echo -e "${YELLOW}   ⚠️  Sitemap missing${NC}"
fi

if [ -f "$BUILD_DIR/robots.txt" ]; then
    echo -e "${GREEN}   ✅ Robots.txt found${NC}"
else
    echo -e "${YELLOW}   ⚠️  Robots.txt missing${NC}"
fi

# Check index.html for meta tags
if grep -q "og:title" "$BUILD_DIR/index.html"; then
    echo -e "${GREEN}   ✅ Open Graph tags found${NC}"
else
    echo -e "${YELLOW}   ⚠️  Open Graph tags missing${NC}"
fi

echo -e "\n${GREEN}📊 Build analysis complete!${NC}"
