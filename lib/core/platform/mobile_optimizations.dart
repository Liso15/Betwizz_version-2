import 'dart:io';
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

      // Check for low-end devices (using SDK version only)
      if (androidInfo.version.sdkInt < 26) { // Android 8.0
        _enableLowPowerMode();
      }

      // Set a reasonable default cache size for Android
      _maxCacheSize = 100 * 1024 * 1024; // 100MB

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
    // You can use MobileOptimizations.getAnimationDuration in your animation controllers
  }

  /// Setup memory management
  static void _setupMemoryManagement() {
    // You can add memory monitoring here if needed
  }

  /// Configure network optimizations
  static void _configureNetworkOptimizations() {
    HttpOverrides.global = MobileHttpOverrides();
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

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

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

    client.connectionTimeout = const Duration(seconds: 10);
    client.idleTimeout = const Duration(seconds: 15);
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