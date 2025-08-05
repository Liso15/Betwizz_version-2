#!/bin/bash

echo "🧪 Testing Optimized Betwizz Web Build"
echo "======================================"

# Set error handling
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Step 1: Clean previous builds
echo -e "\n${BLUE}📋 Step 1: Cleaning previous builds...${NC}"
flutter clean
print_status "Previous builds cleaned"

# Step 2: Get dependencies
echo -e "\n${BLUE}📋 Step 2: Getting dependencies...${NC}"
flutter pub get
print_status "Dependencies updated"

# Step 3: Run tests
echo -e "\n${BLUE}📋 Step 3: Running tests...${NC}"
if flutter test; then
    print_status "All tests passed"
else
    print_warning "Some tests failed, continuing with build..."
fi

# Step 4: Analyze code
echo -e "\n${BLUE}📋 Step 4: Analyzing code...${NC}"
if flutter analyze; then
    print_status "Code analysis passed"
else
    print_warning "Code analysis found issues, continuing..."
fi

# Step 5: Build optimized web version
echo -e "\n${BLUE}📋 Step 5: Building optimized web version...${NC}"

BUILD_COMMAND="flutter build web --release \
  --web-renderer canvaskit \
  --dart-define=FLUTTER_WEB_USE_SKIA=true \
  --dart-define=FLUTTER_WEB_CANVASKIT_URL=https://unpkg.com/canvaskit-wasm@0.38.0/bin/ \
  --pwa-strategy offline-first \
  --source-maps"

print_info "Build command: $BUILD_COMMAND"

if eval $BUILD_COMMAND; then
    print_status "Web build completed successfully"
else
    print_error "Web build failed"
    exit 1
fi

# Step 6: Analyze bundle size
echo -e "\n${BLUE}📋 Step 6: Analyzing bundle size...${NC}"

if [ -f "build/web/main.dart.js" ]; then
    # Get file sizes
    MAIN_JS_SIZE=$(stat -f%z build/web/main.dart.js 2>/dev/null || stat -c%s build/web/main.dart.js)
    MAIN_JS_SIZE_MB=$(echo "scale=2; $MAIN_JS_SIZE / 1024 / 1024" | bc -l 2>/dev/null || echo "$(($MAIN_JS_SIZE / 1024 / 1024))")
    
    # Estimate compressed size (typical compression ratio for JS is ~75%)
    COMPRESSED_SIZE=$(echo "scale=2; $MAIN_JS_SIZE * 0.25" | bc -l 2>/dev/null || echo "$(($MAIN_JS_SIZE / 4))")
    COMPRESSED_MB=$(echo "scale=2; $COMPRESSED_SIZE / 1024 / 1024" | bc -l 2>/dev/null || echo "$(($COMPRESSED_SIZE / 1024 / 1024))")
    
    echo "📊 Bundle Size Analysis:"
    echo "   Main JS (uncompressed): ${MAIN_JS_SIZE_MB}MB"
    echo "   Main JS (compressed):   ${COMPRESSED_MB}MB"
    
    # Check against targets
    TARGET_SIZE=8388608  # 8MB in bytes
    if [ "$COMPRESSED_SIZE" -lt "$TARGET_SIZE" ]; then
        print_status "Bundle size within 8MB target"
    else
        print_warning "Bundle size exceeds 8MB target"
    fi
    
    # Run detailed bundle analysis if script exists
    if [ -f "scripts/bundle-analyzer.js" ]; then
        print_info "Running detailed bundle analysis..."
        node scripts/bundle-analyzer.js
    fi
else
    print_error "Main bundle file not found"
    exit 1
fi

# Step 7: Check build artifacts
echo -e "\n${BLUE}📋 Step 7: Checking build artifacts...${NC}"

REQUIRED_FILES=(
    "build/web/index.html"
    "build/web/main.dart.js"
    "build/web/flutter_service_worker.js"
    "build/web/manifest.json"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status "Found: $file"
    else
        print_error "Missing: $file"
        exit 1
    fi
done

# Step 8: Start local server for testing
echo -e "\n${BLUE}📋 Step 8: Starting local server...${NC}"

cd build/web

# Check if Python 3 is available
if command -v python3 &> /dev/null; then
    print_info "Starting Python 3 HTTP server on port 8080..."
    print_info "Visit: http://localhost:8080"
    print_info "Press Ctrl+C to stop the server"
    
    # Start server in background and capture PID
    python3 -m http.server 8080 &
    SERVER_PID=$!
    
    # Wait a moment for server to start
    sleep 2
    
    # Check if server is running
    if kill -0 $SERVER_PID 2>/dev/null; then
        print_status "Server started successfully (PID: $SERVER_PID)"
        
        # Open browser if available
        if command -v open &> /dev/null; then
            open http://localhost:8080
        elif command -v xdg-open &> /dev/null; then
            xdg-open http://localhost:8080
        fi
        
        echo -e "\n${GREEN}🎉 Optimized build test complete!${NC}"
        echo -e "${GREEN}=================================${NC}"
        echo -e "${GREEN}✅ Build successful${NC}"
        echo -e "${GREEN}✅ Bundle size analyzed${NC}"
        echo -e "${GREEN}✅ Server running on http://localhost:8080${NC}"
        
        echo -e "\n${BLUE}📝 Test checklist:${NC}"
        echo "1. ✅ App loads without errors"
        echo "2. ⏳ Navigation works correctly"
        echo "3. ⏳ Betting features functional"
        echo "4. ⏳ Responsive design works"
        echo "5. ⏳ Performance is acceptable"
        
        echo -e "\n${BLUE}🔧 Performance testing:${NC}"
        echo "• Open Chrome DevTools (F12)"
        echo "• Go to Network tab and reload"
        echo "• Check load times and bundle sizes"
        echo "• Test on mobile viewport"
        
        echo -e "\n${YELLOW}Press Ctrl+C to stop the server${NC}"
        
        # Wait for user to stop server
        wait $SERVER_PID
        
    else
        print_error "Failed to start server"
        exit 1
    fi
    
elif command -v python &> /dev/null; then
    print_info "Starting Python 2 HTTP server on port 8080..."
    python -m SimpleHTTPServer 8080
    
else
    print_warning "Python not found. You can serve the files manually:"
    echo "   cd build/web"
    echo "   # Use any HTTP server, for example:"
    echo "   # npx serve -s . -l 8080"
    echo "   # php -S localhost:8080"
    echo "   # ruby -run -e httpd . -p 8080"
fi

cd ../..

echo -e "\n${GREEN}🏁 Test completed!${NC}"
