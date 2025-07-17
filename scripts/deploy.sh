#!/bin/bash

# Betwizz Flutter Web Deployment Script
# Handles deployment to Vercel with proper error handling

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PRODUCTION_FLAG=""
VERCEL_ENV="preview"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --production|-p)
      PRODUCTION_FLAG="--prod"
      VERCEL_ENV="production"
      shift
      ;;
    --help|-h)
      echo "Usage: $0 [--production|-p]"
      echo "  --production, -p    Deploy to production"
      exit 0
      ;;
    *)
      echo "Unknown option $1"
      exit 1
      ;;
  esac
done

echo -e "${BLUE}🚀 Starting Betwizz deployment to ${VERCEL_ENV}...${NC}"

# Check prerequisites
echo -e "${BLUE}🔍 Checking prerequisites...${NC}"

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js is not installed or not in PATH${NC}"
    exit 1
fi

if ! command -v vercel &> /dev/null; then
    echo -e "${YELLOW}⚠️  Vercel CLI not found, installing...${NC}"
    npm install -g vercel@latest
fi

# Check Flutter doctor
echo -e "${BLUE}🏥 Running Flutter doctor...${NC}"
flutter doctor || {
    echo -e "${YELLOW}⚠️  Flutter doctor found issues, but continuing...${NC}"
}

# Clean previous builds
echo -e "${BLUE}🧹 Cleaning previous builds...${NC}"
flutter clean
rm -rf build/
rm -rf .dart_tool/build/

# Install dependencies
echo -e "${BLUE}📦 Installing dependencies...${NC}"
flutter pub get || {
    echo -e "${RED}❌ Failed to install Flutter dependencies${NC}"
    exit 1
}

npm install || {
    echo -e "${RED}❌ Failed to install Node.js dependencies${NC}"
    exit 1
}

# Enable web support
echo -e "${BLUE}🌐 Enabling Flutter web support...${NC}"
flutter config --enable-web

# Build the application
echo -e "${BLUE}🔨 Building Flutter web application...${NC}"
flutter build web \
    --release \
    --web-renderer html \
    --base-href / \
    --dart-define=FLUTTER_WEB_USE_SKIA=false \
    --dart-define=FLUTTER_WEB_AUTO_DETECT=false || {
    echo -e "${RED}❌ Flutter build failed${NC}"
    exit 1
}

# Verify build output
echo -e "${BLUE}✅ Verifying build output...${NC}"
if [ ! -f "build/web/index.html" ]; then
    echo -e "${RED}❌ Build verification failed: index.html not found${NC}"
    exit 1
fi

if [ ! -f "build/web/main.dart.js" ]; then
    echo -e "${RED}❌ Build verification failed: main.dart.js not found${NC}"
    exit 1
fi

# Optimize assets
echo -e "${BLUE}🎨 Optimizing assets...${NC}"
npm run optimize:assets || {
    echo -e "${YELLOW}⚠️  Asset optimization failed, but continuing...${NC}"
}

# Generate sitemap
echo -e "${BLUE}🗺️  Generating sitemap...${NC}"
npm run generate:sitemap || {
    echo -e "${YELLOW}⚠️  Sitemap generation failed, but continuing...${NC}"
}

# Deploy to Vercel
echo -e "${BLUE}🚀 Deploying to Vercel (${VERCEL_ENV})...${NC}"

if [ -z "$VERCEL_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  VERCEL_TOKEN not set, using interactive login${NC}"
    vercel login
fi

# Set environment variables for deployment
export VERCEL_ORG_ID="${VERCEL_ORG_ID}"
export VERCEL_PROJECT_ID="${VERCEL_PROJECT_ID}"

# Deploy
vercel \
    --token "${VERCEL_TOKEN}" \
    --scope "${VERCEL_ORG_ID}" \
    ${PRODUCTION_FLAG} \
    --confirm \
    --yes || {
    echo -e "${RED}❌ Vercel deployment failed${NC}"
    exit 1
}

# Verify deployment
if [ "$VERCEL_ENV" = "production" ]; then
    echo -e "${BLUE}🔍 Verifying production deployment...${NC}"
    sleep 30  # Wait for deployment to propagate
    
    if curl -f -s "https://betwizz.vercel.app/" > /dev/null; then
        echo -e "${GREEN}✅ Production deployment verified successfully!${NC}"
    else
        echo -e "${YELLOW}⚠️  Could not verify production deployment${NC}"
    fi
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"

# Show deployment info
echo -e "${BLUE}📊 Deployment Summary:${NC}"
echo -e "   Environment: ${VERCEL_ENV}"
echo -e "   Build size: $(du -sh build/web | cut -f1)"
echo -e "   Files: $(find build/web -type f | wc -l)"

if [ "$VERCEL_ENV" = "production" ]; then
    echo -e "   URL: ${GREEN}https://betwizz.vercel.app/${NC}"
else
    echo -e "   Preview URL will be shown above"
fi
