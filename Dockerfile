# Use the official Flutter image as base
FROM cirrusci/flutter:stable

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Install dependencies
RUN flutter pub get

# Copy the entire project
COPY . .

# Enable web support
RUN flutter config --enable-web

# Build the web app
RUN flutter build web --release --web-renderer html

# Use nginx to serve the web app
FROM nginx:alpine

# Copy the built web app to nginx
COPY --from=0 /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
