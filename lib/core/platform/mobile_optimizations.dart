import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Mobile-specific optimizations for the Betwizz app
class MobileOptimizations {
  static const String _tag = 'MobileOptimizations';
  
  // Performance settings
  static bool _lowPowerMode = false;
  static bool _reducedAnimations = false;
  static int _maxCacheSize = 100 * 1024 * 1024; // 100MB default
  
  /// Initialize mobile optimizations
  static Future<void> initialize() async {
    try {
      await _detectDeviceCapabilities();
      _configurePerformanceSettings();
      _setupMemoryManagement();
      _configureNetworkOptimizations();
      
      if (kDebugMode) {
        print('$_tag: Mobile optimizations initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Initialization error: $e');
      }
    }
  }
  
  /// Detect device capabilities and adjust settings accordingly
  static Future<void> _detectDeviceCapabilities() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      
      // Check for low-end devices
      if (androidInfo.version.sdkInt < 26 || // Android 8.0
          androidInfo.totalMemory < 3 * 1024 * 1024 * 1024) { // Less than 3GB RAM
        _enableLowPowerMode();
      }
      
      // Adjust cache size based on available memory
      final totalMemory = androidInfo.totalMemory;
      _maxCacheSize = (totalMemory * 0.1).round(); // 10% of total memory
      _maxCacheSize = _maxCacheSize.clamp(25 * 1024 * 1024, 200 * 1024 * 1024);
      
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      
      // Check for older iOS devices
      final systemVersion = iosInfo.systemVersion;
      final majorVersion = int.tryParse(systemVersion.split('.').first) ?? 0;
      
      if (majorVersion < 14) { // iOS 14 and below
        _enableLowPowerMode();
      }
      
      // iOS devices generally have good memory management
      _maxCacheSize = 150 * 1024 * 1024; // 150MB for iOS
    }
  }
  
  /// Enable low power mode optimizations
  static void _enableLowPowerMode() {
    _lowPowerMode = true;
    _reducedAnimations = true;
    _maxCacheSize = 25 * 1024 * 1024; // Reduce to 25MB
    
    if (kDebugMode) {
      print('$_tag: Low power mode enabled');
    }
  }
  
  /// Configure performance settings based on device capabilities
  static void _configurePerformanceSettings() {
    // Reduce animation duration for low-end devices
    if (_reducedAnimations) {
      // This would typically be used in animation controllers
      // AnimationController.duration *= 0.5;
    }
    
    // Configure frame rate
    if (_lowPowerMode) {
      // Limit frame rate to 30fps for low-end devices
      // This is handled at the engine level
    }
  }
  
  /// Setup memory management
  static void _setupMemoryManagement() {
    // Monitor memory usage
    if (kDebugMode) {
      _startMemoryMonitoring();
    }
    
    // Configure garbage collection hints
    if (_lowPowerMode) {
      // More aggressive garbage collection for low-end devices
      // This is handled by the Dart VM
    }
  }
  
  /// Configure network optimizations
  static void _configureNetworkOptimizations() {
    // Configure HTTP client settings
    HttpOverrides.global = MobileHttpOverrides();
  }
  
  /// Start memory monitoring (debug mode only)
  static void _startMemoryMonitoring() {
    if (!kDebugMode) return;
    
    // Monitor memory usage periodically
    Stream.periodic(const Duration(seconds: 30)).listen((_) {
      final rss = ProcessInfo.currentRss;
      final maxRss = ProcessInfo.maxRss;
      
      print('$_tag: Memory usage - Current: ${rss ~/ 1024 ~/ 1024}MB, '
            'Max: ${maxRss ~/ 1024 ~/ 1024}MB');
      
      // Trigger cleanup if memory usage is high
      if (rss > _maxCacheSize * 1.5) {
        _triggerMemoryCleanup();
      }
    });
  }
  
  /// Trigger memory cleanup
  static void _triggerMemoryCleanup() {
    if (kDebugMode) {
      print('$_tag: Triggering memory cleanup');
    }
    
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Suggest garbage collection
    // Note: This is just a hint to the VM
    // System.gc() is not available in Dart
  }
  
  /// Get optimized image cache configuration
  static ImageCacheConfig getImageCacheConfig() {
    final baseConfig = ImageCacheConfig();
    
    if (_lowPowerMode) {
      return baseConfig.copyWith(
        maximumSize: 50, // Reduce from default 1000
        maximumSizeBytes: _maxCacheSize ~/ 4, // 25% of max cache for images
      );
    }
    
    return baseConfig.copyWith(
      maximumSizeBytes: _maxCacheSize ~/ 2, // 50% of max cache for images
    );
  }
  
  /// Get optimized animation duration
  static Duration getAnimationDuration(Duration baseDuration) {
    if (_reducedAnimations) {
      return Duration(milliseconds: (baseDuration.inMilliseconds * 0.5).round());
    }
    return baseDuration;
  }
  
  /// Check if device is in low power mode
  static bool get isLowPowerMode => _lowPowerMode;
  
  /// Check if animations should be reduced
  static bool get shouldReduceAnimations => _reducedAnimations;
  
  /// Get maximum cache size
  static int get maxCacheSize => _maxCacheSize;
  
  /// Configure system UI for mobile
  static void configureSystemUI() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    // Configure status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    // Enable edge-to-edge display
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }
  
  /// Get recommended video quality based on device performance
  static VideoQuality getRecommendedVideoQuality() {
    if (_lowPowerMode) {
      return VideoQuality.low;
    } else if (Platform.isAndroid) {
      return VideoQuality.medium;
    } else {
      return VideoQuality.high; // iOS devices generally handle video well
    }
  }
  
  /// Get recommended frame rate for video
  static int getRecommendedFrameRate() {
    if (_lowPowerMode) {
      return 15; // 15fps for low-end devices
    } else if (Platform.isAndroid) {
      return 24; // 24fps for Android
    } else {
      return 30; // 30fps for iOS
    }
  }
}

/// Custom HTTP overrides for mobile optimization
class MobileHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    
    // Configure timeouts
    client.connectionTimeout = const Duration(seconds: 10);
    client.idleTimeout = const Duration(seconds: 15);
    
    // Configure connection pooling
    client.maxConnectionsPerHost = 6;
    
    return client;
  }
}

/// Video quality enumeration
enum VideoQuality {
  low(240),
  medium(480),
  high(720),
  ultraHigh(1080);
  
  const VideoQuality(this.height);
  final int height;
}

/// Process information helper
class ProcessInfo {
  /// Get current resident set size (RSS) in bytes
  static int get currentRss {
    // This would need to be implemented using platform channels
    // For now, return a placeholder value
    return 100 * 1024 * 1024; // 100MB placeholder
  }
  
  /// Get maximum resident set size (RSS) in bytes
  static int get maxRss {
    // This would need to be implemented using platform channels
    // For now, return a placeholder value
    return 200 * 1024 * 1024; // 200MB placeholder
  }
}
