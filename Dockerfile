# Use the official Flutter image as base
FROM cirrusci/flutter:stable AS build-stage

# Set working directory
WORKDIR /app

# Copy dependency files
COPY pubspec.yaml pubspec.lock ./
COPY package.json package-lock.json* ./

# Install Node.js dependencies
RUN apt-get update && apt-get install -y nodejs npm
RUN npm install

# Install Flutter dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Enable web support
RUN flutter config --enable-web

# Build the application
RUN flutter build web --release --web-renderer html --base-href /

# Optimize assets
RUN npm run optimize:assets || true
RUN npm run generate:sitemap || true

# Production stage
FROM nginx:alpine AS production-stage

# Copy built application
COPY --from=build-stage /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
