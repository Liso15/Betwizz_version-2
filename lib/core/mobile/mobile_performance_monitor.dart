import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Mobile performance monitoring and optimization system
class MobilePerformanceMonitor {
  static const String _tag = 'MobilePerformanceMonitor';
  
  // Singleton instance
  static final MobilePerformanceMonitor _instance = MobilePerformanceMonitor._internal();
  factory MobilePerformanceMonitor() => _instance;
  MobilePerformanceMonitor._internal();
  
  // Performance metrics
  final Map<String, PerformanceMetric> _metrics = {};
  Timer? _monitoringTimer;
  bool _isMonitoring = false;
  
  // Performance thresholds
  static const int _maxFrameTime = 16; // 60fps = 16.67ms per frame
  static const int _warningFrameTime = 20; // Warning at 50fps
  static const int _maxMemoryUsage = 200 * 1024 * 1024; // 200MB
  static const double _maxCpuUsage = 80.0; // 80%
  
  // Callbacks
  final List<PerformanceCallback> _callbacks = [];
  
  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (_isMonitoring) return;
    
    try {
      await _setupFrameCallbacks();
      _startPerformanceMonitoring();
      _isMonitoring = true;
      
      if (kDebugMode) {
        print('$_tag: Performance monitoring initialized');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Failed to initialize: $e');
      }
    }
  }
  
  /// Stop performance monitoring
  void dispose() {
    _monitoringTimer?.cancel();
    _callbacks.clear();
    _isMonitoring = false;
    
    if (kDebugMode) {
      print('$_tag: Performance monitoring stopped');
    }
  }
  
  /// Setup frame timing callbacks
  Future<void> _setupFrameCallbacks() async {
    // Monitor frame rendering performance
    WidgetsBinding.instance.addTimingsCallback(_onFrameTimings);
    
    // Monitor build performance
    WidgetsBinding.instance.addPersistentFrameCallback(_onFrameCallback);
  }
  
  /// Start continuous performance monitoring
  void _startPerformanceMonitoring() {
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _collectPerformanceMetrics(),
    );
  }
  
  /// Handle frame timing data
  void _onFrameTimings(List<FrameTiming> timings) {
    if (!_isMonitoring) return;
    
    for (final timing in timings) {
      final buildTime = timing.buildDuration.inMilliseconds;
      final rasterTime = timing.rasterDuration.inMilliseconds;
      final totalTime = timing.totalSpan.inMilliseconds;
      
      // Record frame metrics
      _recordMetric('frame_build_time', buildTime.toDouble());
      _recordMetric('frame_raster_time', rasterTime.toDouble());
      _recordMetric('frame_total_time', totalTime.toDouble());
      
      // Check for performance issues
      if (totalTime > _warningFrameTime) {
        _notifyPerformanceIssue(PerformanceIssue(
          type: PerformanceIssueType.slowFrame,
          severity: totalTime > _maxFrameTime ? IssueSeverity.critical : IssueSeverity.warning,
          message: 'Slow frame detected: ${totalTime}ms',
          metrics: {
            'build_time': buildTime,
            'raster_time': rasterTime,
            'total_time': totalTime,
          },
        ));
      }
    }
  }
  
  /// Handle frame callbacks
  void _onFrameCallback(Duration timestamp) {
    if (!_isMonitoring) return;
    
    // Record frame rate
    final now = DateTime.now().millisecondsSinceEpoch;
    _recordMetric('frame_timestamp', now.toDouble());
    
    // Calculate FPS
    _calculateFPS();
  }
  
  /// Collect various performance metrics
  void _collectPerformanceMetrics() {
    _collectMemoryMetrics();
    _collectCPUMetrics();
    _collectNetworkMetrics();
    _collectBatteryMetrics();
  }
  
  /// Collect memory usage metrics
  void _collectMemoryMetrics() {
    try {
      // Get image cache memory usage
      final imageCache = PaintingBinding.instance.imageCache;
      final imageCacheSize = imageCache.currentSizeBytes;
      
      _recordMetric('memory_image_cache', imageCacheSize.toDouble());
      
      // Check memory thresholds
      if (imageCacheSize > _maxMemoryUsage * 0.5) {
        _notifyPerformanceIssue(PerformanceIssue(
          type: PerformanceIssueType.highMemoryUsage,
          severity: imageCacheSize > _maxMemoryUsage ? IssueSeverity.critical : IssueSeverity.warning,
          message: 'High memory usage: ${imageCacheSize ~/ 1024 ~/ 1024}MB',
          metrics: {'memory_usage': imageCacheSize},
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag: Error collecting memory metrics: $e');
      }
    }
  }
  
  /// Collect CPU usage metrics (platform-specific implementation needed)
  void _collectCPUMetrics() {
    // This would require platform-specific implementation
    // For now, we'll use a placeholder
    _recordMetric('cpu_usage', 0.0);
  }
  
  /// Collect network performance metrics
  void _collectNetworkMetrics() {
    // This would track network request performance
    // Implementation depends on HTTP client used
    _recordMetric('network_latency', 0.0);
  }
  
  /// Collect battery usage metrics (platform-specific implementation needed)
  void _collectBatteryMetrics() {
    // This would require platform-specific implementation
    _recordMetric('battery_level', 100.0);
  }
  
  /// Calculate frames per second
  void _calculateFPS() {
    final timestamps = _getMetricValues('frame_timestamp');
    if (timestamps.length < 2) return;
    
    final recentTimestamps = timestamps.takeLast(60).toList(); // Last 60 frames
    if (recentTimestamps.length < 2) return;
    
    final timeSpan = recentTimestamps.last - recentTimestamps.first;
    final fps = (recentTimestamps.length - 1) * 1000 / timeSpan;
    
    _recordMetric('fps', fps);
    
    // Check FPS thresholds
    if (fps < 30) {
      _notifyPerformanceIssue(PerformanceIssue(
        type: PerformanceIssueType.lowFPS,
        severity: fps < 20 ? IssueSeverity.critical : IssueSeverity.warning,
        message: 'Low FPS detected: ${fps.toStringAsFixed(1)}',
        metrics: {'fps': fps},
      ));
    }
  }
  
  /// Record a performance metric
  void _recordMetric(String name, double value) {
    final metric = _metrics[name] ??= PerformanceMetric(name);
    metric.addValue(value);
  }
  
  /// Get metric values
  List<double> _getMetricValues(String name) {
    return _metrics[name]?.values ?? [];
  }
  
  /// Notify performance issue
  void _notifyPerformanceIssue(PerformanceIssue issue) {
    if (kDebugMode) {
      print('$_tag: ${issue.severity.name.toUpperCase()} - ${issue.message}');
    }
    
    for (final callback in _callbacks) {
      callback(issue);
    }
  }
  
  /// Add performance callback
  void addCallback(PerformanceCallback callback) {
    _callbacks.add(callback);
  }
  
  /// Remove performance callback
  void removeCallback(PerformanceCallback callback) {
    _callbacks.remove(callback);
  }
  
  /// Get current performance summary
  PerformanceSummary getPerformanceSummary() {
    final fps = _metrics['fps']?.average ?? 0.0;
    final frameTime = _metrics['frame_total_time']?.average ?? 0.0;
    final memoryUsage = _metrics['memory_image_cache']?.latest ?? 0.0;
    
    return PerformanceSummary(
      fps: fps,
      averageFrameTime: frameTime,
      memoryUsage: memoryUsage,
      isPerformanceGood: fps > 45 && frameTime < _warningFrameTime,
    );
  }
  
  /// Get detailed metrics
  Map<String, PerformanceMetric> getMetrics() {
    return Map.unmodifiable(_metrics);
  }
  
  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
  }
  
  /// Check if monitoring is active
  bool get isMonitoring => _isMonitoring;
}

/// Performance metric data structure
class PerformanceMetric {
  final String name;
  final List<double> _values = [];
  final int maxValues;
  
  PerformanceMetric(this.name, {this.maxValues = 100});
  
  void addValue(double value) {
    _values.add(value);
    if (_values.length > maxValues) {
      _values.removeAt(0);
    }
  }
  
  List<double> get values => List.unmodifiable(_values);
  double get latest => _values.isNotEmpty ? _values.last : 0.0;
  double get average => _values.isNotEmpty ? _values.reduce((a, b) => a + b) / _values.length : 0.0;
  double get min => _values.isNotEmpty ? _values.reduce((a, b) => a < b ? a : b) : 0.0;
  double get max => _values.isNotEmpty ? _values.reduce((a, b) => a > b ? a : b) : 0.0;
}

/// Performance issue data structure
class PerformanceIssue {
  final PerformanceIssueType type;
  final IssueSeverity severity;
  final String message;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;
  
  PerformanceIssue({
    required this.type,
    required this.severity,
    required this.message,
    required this.metrics,
  }) : timestamp = DateTime.now();
}

/// Performance summary
class PerformanceSummary {
  final double fps;
  final double averageFrameTime;
  final double memoryUsage;
  final bool isPerformanceGood;
  
  const PerformanceSummary({
    required this.fps,
    required this.averageFrameTime,
    required this.memoryUsage,
    required this.isPerformanceGood,
  });
}

/// Performance issue types
enum PerformanceIssueType {
  slowFrame,
  lowFPS,
  highMemoryUsage,
  highCPUUsage,
  networkLatency,
  batteryDrain,
}

/// Issue severity levels
enum IssueSeverity {
  info,
  warning,
  critical,
}

/// Performance callback type
typedef PerformanceCallback = void Function(PerformanceIssue issue);

/// Extension for list operations
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}
