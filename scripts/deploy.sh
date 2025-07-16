#!/bin/bash

# Betwizz Deployment Script
echo "🚀 Starting Betwizz deployment..."

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first."
    exit 1
fi

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build for web
echo "🔨 Building web application..."
flutter build web --release --web-renderer html --base-href /

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo "📁 Build files are in: build/web/"
    echo "🌐 Ready for deployment to Vercel"
else
    echo "❌ Build failed!"
    exit 1
fi

# Optional: Deploy to Vercel (if Vercel CLI is installed)
if command -v vercel &> /dev/null; then
    echo "🚀 Deploying to Vercel..."
    cd build/web
    vercel --prod
else
    echo "💡 Install Vercel CLI to deploy automatically: npm i -g vercel"
fi

echo "🎉 Deployment process completed!"
