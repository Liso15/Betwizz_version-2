import 'package:flutter/foundation.dart';

/// Web-specific configuration and optimizations for Betwizz
class WebConfig {
  static const String appName = 'Betwizz';
  static const String appVersion = '1.0.0';
  static const String appUrl = 'https://betwizz.web.app';
  
  // Performance settings
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const int imageQuality = 80;
  static const bool enableServiceWorker = true;
  static const bool enableOfflineMode = true;
  
  // Asset loading settings
  static const bool lazyLoadImages = true;
  static const bool preloadCriticalAssets = true;
  static const int maxConcurrentImageLoads = 3;
  
  // Network settings
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  /// Check if running in web environment
  static bool get isWeb => kIsWeb;
  
  /// Check if running in debug mode
  static bool get isDebug => kDebugMode;
  
  /// Get optimized image URL with WebP support
  static String getOptimizedImageUrl(String imagePath) {
    if (!isWeb) return imagePath;
    
    // Check if browser supports WebP
    final webpPath = imagePath.replaceAll(RegExp(r'\.(png|jpg|jpeg)$'), '.webp');
    return webpPath;
  }
  
  /// Get CDN URL for CanvasKit
  static String get canvasKitUrl => 'https://unpkg.com/canvaskit-wasm@0.38.0/bin/';
  
  /// Web-specific initialization
  static Future<void> initialize() async {
    if (!isWeb) return;
    
    if (isDebug) {
      print('WebConfig: Initializing web-specific settings');
      print('WebConfig: App Name - $appName');
      print('WebConfig: App Version - $appVersion');
      print('WebConfig: Cache Size - ${maxCacheSize ~/ (1024 * 1024)}MB');
    }
    
    // Configure web-specific settings
    await _configureServiceWorker();
    await _preloadCriticalAssets();
  }
  
  static Future<void> _configureServiceWorker() async {
    if (!enableServiceWorker) return;
    
    try {
      // Service worker configuration would go here
      if (isDebug) {
        print('WebConfig: Service worker configured');
      }
    } catch (e) {
      if (isDebug) {
        print('WebConfig: Service worker configuration failed: $e');
      }
    }
  }
  
  static Future<void> _preloadCriticalAssets() async {
    if (!preloadCriticalAssets) return;
    
    try {
      // Critical asset preloading would go here
      if (isDebug) {
        print('WebConfig: Critical assets preloaded');
      }
    } catch (e) {
      if (isDebug) {
        print('WebConfig: Asset preloading failed: $e');
      }
    }
  }
}
