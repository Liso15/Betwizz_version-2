import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/platform/mobile_config.dart';
import 'core/platform/mobile_optimizations.dart';
import 'core/mobile/mobile_performance_monitor.dart';
import 'screens/splash_screen.dart';
import 'screens/main_navigation.dart';
import 'providers/channel_provider.dart';
import 'providers/ai_chat_provider.dart';
import 'providers/receipt_provider.dart';
import 'models/channel.dart';
import 'models/chat_message.dart';
import 'models/bet_receipt.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await _initializeMobileEnvironment();
    
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    await _initializeHive();
    
    await MobileOptimizations.initialize();
    
    await MobilePerformanceMonitor().initialize();
    
    MobileOptimizations.configureSystemUI();
    
    runApp(const BetwizzMobileApp());
    
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize mobile app: $e');
    debugPrint('Stack trace: $stackTrace');
    
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('Restart App'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

Future<void> _initializeMobileEnvironment() async {
  await MobileConfig.initialize();
  
  if (!MobileConfig.meetsMinimumRequirements()) {
    throw Exception('Device does not meet minimum requirements');
  }
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();
  
  Hive.registerAdapter(ChannelAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(BetReceiptAdapter());
  
  await Hive.openBox<Channel>('channels');
  await Hive.openBox<ChatMessage>('chat_messages');
  await Hive.openBox<BetReceipt>('bet_receipts');
  // Box already opened above; remove duplicate open to avoid runtime error
}

class BetwizzMobileApp extends StatefulWidget {
  const BetwizzMobileApp({super.key});

  @override
  State<BetwizzMobileApp> createState() => _BetwizzMobileAppState();
}

class _BetwizzMobileAppState extends State<BetwizzMobileApp> with WidgetsBindingObserver {
  late final MobilePerformanceMonitor _performanceMonitor;
  
  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addObserver(this);
    
    _performanceMonitor = MobilePerformanceMonitor();
    _performanceMonitor.addCallback(_handlePerformanceIssue);
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    
    _performanceMonitor.removeCallback(_handlePerformanceIssue);
    _performanceMonitor.dispose();
    
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        if (!_performanceMonitor.isMonitoring) {
          _performanceMonitor.initialize();
        }
        break;
        
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
        
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
        
      case AppLifecycleState.inactive:
        break;
        
      case AppLifecycleState.hidden:
        break;
    }
  }
  
  void _handlePerformanceIssue(PerformanceIssue issue) {
    if (issue.severity == IssueSeverity.critical) {
      switch (issue.type) {
        case PerformanceIssueType.highMemoryUsage:
          _handleHighMemoryUsage();
          break;
        case PerformanceIssueType.lowFPS:
          _handleLowFPS();
          break;
        default:
          break;
      }
    }
  }
  
  void _handleHighMemoryUsage() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    if (kDebugMode) {
      debugPrint('Cleared image cache due to high memory usage');
    }
  }
  
  void _handleLowFPS() {
    if (kDebugMode) {
      debugPrint('Low FPS detected - consider reducing animation complexity');
    }
  }
  
  void _handleAppPaused() {
  }
  
  void _handleAppDetached() {
  }
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
        ChangeNotifierProvider(create: (_) => AiChatProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptProvider()),
      ],
      child: MaterialApp(
        title: 'Betwizz - Smart Betting Assistant',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final imageCache = PaintingBinding.instance.imageCache;
          imageCache.maximumSizeBytes = MobileOptimizations.maxCacheSize ~/ 2;
          
          return child!;
        },
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/main': (context) => const MainNavigation(),
        },
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Page Not Found')),
              body: const Center(
                child: Text('The requested page was not found.'),
              ),
            ),
          );
        },
      ),
    );
  }
}
