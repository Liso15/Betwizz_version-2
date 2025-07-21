import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class MobileConfig {
  static const String _tag = 'MobileConfig';
  
  // Platform detection
  static bool get isAndroid => Platform.isAndroid;
  static bool get isIOS => Platform.isIOS;
  static bool get isMobile => isAndroid || isIOS;
  
  // Device capabilities
  static bool _hasCamera = false;
  static bool _hasMicrophone = false;
  static bool _hasNetwork = false;
  static String _deviceModel = '';
  static String _osVersion = '';
  
  // Performance thresholds
  static const int minRamMB = 2048; // 2GB minimum
  static const int recommendedRamMB = 4096; // 4GB recommended
  static const double minScreenSize = 4.0; // 4 inch minimum
  
  /// Initialize mobile configuration
  static Future<void> initialize() async {
    try {
      await _checkDeviceInfo();
      await _checkPermissions();
      await _checkCapabilities();
      _configureSystemUI();
      
      if (kDebugMode) {
        print('$_tag: Mobile configuration initialized');
        print('$_tag: Device: $_deviceModel, OS: $_osVersion');
        print('$_tag: Camera: $_hasCamera, Mic: $_hasMicrophone');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Initialization error: $e');
      }
    }
  }
  
  /// Check device information
  static Future<void> _checkDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    
    if (isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      _deviceModel = '${androidInfo.manufacturer} ${androidInfo.model}';
      _osVersion = 'Android ${androidInfo.version.release}';
    } else if (isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      _deviceModel = iosInfo.model;
      _osVersion = 'iOS ${iosInfo.systemVersion}';
    }
  }
  
  /// Check and request permissions
  static Future<void> _checkPermissions() async {
    // Camera permission
    final cameraStatus = await Permission.camera.status;
    if (cameraStatus.isDenied) {
      await Permission.camera.request();
    }
    _hasCamera = await Permission.camera.isGranted;
    
    // Microphone permission
    final micStatus = await Permission.microphone.status;
    if (micStatus.isDenied) {
      await Permission.microphone.request();
    }
    _hasMicrophone = await Permission.microphone.isGranted;
    
    // Storage permission (Android)
    if (isAndroid) {
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isDenied) {
        await Permission.storage.request();
      }
    }
  }
  
  /// Check device capabilities
  static Future<void> _checkCapabilities() async {
    // Network capability is assumed for mobile devices
    _hasNetwork = true;
  }
  
  /// Configure system UI for mobile
  static void _configureSystemUI() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }
  
  /// Get device performance tier
  static DevicePerformanceTier getPerformanceTier() {
    // This is a simplified implementation
    // In production, you'd check actual device specs
    if (isIOS) {
      return DevicePerformanceTier.high; // iOS devices generally perform well
    }
    
    // Android performance estimation based on model
    if (_deviceModel.toLowerCase().contains('pixel') ||
        _deviceModel.toLowerCase().contains('samsung galaxy s') ||
        _deviceModel.toLowerCase().contains('oneplus')) {
      return DevicePerformanceTier.high;
    } else if (_deviceModel.toLowerCase().contains('samsung galaxy a') ||
               _deviceModel.toLowerCase().contains('xiaomi')) {
      return DevicePerformanceTier.medium;
    }
    
    return DevicePerformanceTier.low;
  }
  
  /// Check if device meets minimum requirements
  static bool meetsMinimumRequirements() {
    return _hasCamera && _hasNetwork;
  }
  
  /// Get recommended settings based on device
  static MobileSettings getRecommendedSettings() {
    final performanceTier = getPerformanceTier();
    
    return MobileSettings(
      enableVideoStreaming: performanceTier != DevicePerformanceTier.low,
      maxVideoQuality: performanceTier == DevicePerformanceTier.high 
          ? VideoQuality.hd 
          : VideoQuality.sd,
      enableAdvancedFeatures: performanceTier == DevicePerformanceTier.high,
      cacheSize: performanceTier == DevicePerformanceTier.high ? 100 : 50,
      enableBackgroundSync: true,
    );
  }
  
  // Getters
  static bool get hasCamera => _hasCamera;
  static bool get hasMicrophone => _hasMicrophone;
  static bool get hasNetwork => _hasNetwork;
  static String get deviceModel => _deviceModel;
  static String get osVersion => _osVersion;
}

enum DevicePerformanceTier { low, medium, high }

enum VideoQuality { sd, hd, fullHd }

class MobileSettings {
  final bool enableVideoStreaming;
  final VideoQuality maxVideoQuality;
  final bool enableAdvancedFeatures;
  final int cacheSize;
  final bool enableBackgroundSync;
  
  const MobileSettings({
    required this.enableVideoStreaming,
    required this.maxVideoQuality,
    required this.enableAdvancedFeatures,
    required this.cacheSize,
    required this.enableBackgroundSync,
  });
}
