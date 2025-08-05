import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized asset loading and caching
class AssetOptimizer {
  static const String _tag = 'AssetOptimizer';
  
  // Asset cache configuration
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  static const Duration _cacheTimeout = Duration(days: 7);
  
  /// Get optimized image widget
  static Widget getOptimizedImage({
    required String imagePath,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    String? placeholder,
  }) {
    // For local assets
    if (!imagePath.startsWith('http')) {
      return Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: width?.toInt(),
        cacheHeight: height?.toInt(),
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget(width, height);
        },
      );
    }
    
    // For network images
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      placeholder: placeholder != null 
          ? (context, url) => Image.asset(placeholder, width: width, height: height, fit: fit)
          : (context, url) => _buildPlaceholder(width, height),
      errorWidget: (context, url, error) => _buildErrorWidget(width, height),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );
  }
  
  /// Build placeholder widget
  static Widget _buildPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
  
  /// Build error widget
  static Widget _buildErrorWidget(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: Icon(
        Icons.error_outline,
        color: Colors.grey[400],
        size: (width != null && height != null) 
            ? (width < height ? width : height) * 0.3 
            : 24,
      ),
    );
  }
  
  /// Preload critical images
  static Future<void> preloadCriticalImages(BuildContext context) async {
    final criticalImages = [
      'assets/images/betwizz_logo.png',
      'assets/images/betwizz_logo_white.png',
      // Add other critical images
    ];
    
    for (final imagePath in criticalImages) {
      try {
        await precacheImage(AssetImage(imagePath), context);
      } catch (e) {
        if (kDebugMode) {
          print('$_tag: Failed to preload $imagePath: $e');
        }
      }
    }
    
    if (kDebugMode) {
      print('$_tag: Critical images preloaded');
    }
  }
  
  /// Clear image cache
  static void clearImageCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    if (kDebugMode) {
      print('$_tag: Image cache cleared');
    }
  }
  
  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    return {
      'currentSize': imageCache.currentSize,
      'maximumSize': imageCache.maximumSize,
      'currentSizeBytes': imageCache.currentSizeBytes,
      'maximumSizeBytes': imageCache.maximumSizeBytes,
      'liveImageCount': imageCache.liveImageCount,
      'pendingImageCount': imageCache.pendingImageCount,
    };
  }
}
