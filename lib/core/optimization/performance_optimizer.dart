import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Centralized performance optimization for the Betwizz app
class PerformanceOptimizer {
  static const String _tag = 'PerformanceOptimizer';
  
  // Optimization flags
  static bool _isInitialized = false;
  static bool _webOptimizationsEnabled = false;
  static bool _mobileOptimizationsEnabled = false;
  
  /// Initialize performance optimizations based on platform
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      if (kIsWeb) {
        await _initializeWebOptimizations();
        _webOptimizationsEnabled = true;
      } else {
        await _initializeMobileOptimizations();
        _mobileOptimizationsEnabled = true;
      }
      
      _configureGlobalOptimizations();
      _isInitialized = true;
      
      if (kDebugMode) {
        print('$_tag: Performance optimizations initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Initialization error: $e');
      }
    }
  }
  
  /// Web-specific optimizations
  static Future<void> _initializeWebOptimizations() async {
    // Configure image cache for web
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB
    
    // Disable unnecessary features for web
    if (kDebugMode) {
      print('$_tag: Web optimizations applied');
    }
  }
  
  /// Mobile-specific optimizations
  static Future<void> _initializeMobileOptimizations() async {
    // Configure system UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Configure image cache for mobile
    PaintingBinding.instance.imageCache.maximumSize = 200;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB
    
    if (kDebugMode) {
      print('$_tag: Mobile optimizations applied');
    }
  }
  
  /// Global optimizations for all platforms
  static void _configureGlobalOptimizations() {
    // Add memory pressure observer
    WidgetsBinding.instance.addObserver(_MemoryPressureObserver());
    
    // Configure text scaling limits
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _configureTextScaling();
    });
  }
  
  /// Configure text scaling limits
  static void _configureTextScaling() {
    // This will be handled in the app's builder
  }
  
  /// Get optimized image cache configuration
  static void configureImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    
    if (kIsWeb) {
      imageCache.maximumSize = 100;
      imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50MB for web
    } else {
      imageCache.maximumSize = 200;
      imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB for mobile
    }
  }
  
  /// Trigger memory cleanup
  static void triggerMemoryCleanup() {
    if (kDebugMode) {
      print('$_tag: Triggering memory cleanup');
    }
    
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
  
  /// Get optimized animation duration
  static Duration getOptimizedAnimationDuration(Duration baseDuration) {
    // Reduce animations on web for better performance
    if (kIsWeb) {
      return Duration(milliseconds: (baseDuration.inMilliseconds * 0.7).round());
    }
    return baseDuration;
  }
  
  /// Check if optimizations are enabled
  static bool get isWebOptimized => _webOptimizationsEnabled;
  static bool get isMobileOptimized => _mobileOptimizationsEnabled;
  static bool get isInitialized => _isInitialized;
}

/// Memory pressure observer for automatic cleanup
class _MemoryPressureObserver extends WidgetsBindingObserver {
  @override
  void didHaveMemoryPressure() {
    super.didHaveMemoryPressure();
    PerformanceOptimizer.triggerMemoryCleanup();
  }
}
