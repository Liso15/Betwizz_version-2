import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/optimization/performance_optimizer.dart';
import 'core/optimization/asset_optimizer.dart';
import 'screens/splash_screen.dart';
import 'providers/channel_provider.dart';
import 'providers/ai_chat_provider.dart';
import 'providers/receipt_provider.dart';
import 'models/channel.dart';
import 'models/chat_message.dart';
import 'models/bet_receipt.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize performance optimizations first
    await PerformanceOptimizer.initialize();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Hive with optimizations
    await _initializeHiveOptimized();
    
    runApp(const BetwizzOptimizedApp());
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
    // Run app with limited functionality if initialization fails
    runApp(const BetwizzOptimizedApp());
  }
}

/// Optimized Hive initialization
Future<void> _initializeHiveOptimized() async {
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(ChannelAdapter());
  Hive.registerAdapter(ChatMessageAdapter());
  Hive.registerAdapter(BetReceiptAdapter());
  
  // Open boxes with optimized settings
  await Hive.openBox<Channel>(
    'channels',
    compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > entries * 0.2;
    },
  );
  
  await Hive.openBox<ChatMessage>(
    'chat_messages',
    compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > entries * 0.3;
    },
  );
  
  await Hive.openBox<BetReceipt>(
    'bet_receipts',
    compactionStrategy: (entries, deletedEntries) {
      return deletedEntries > entries * 0.2;
    },
  );
}

class BetwizzOptimizedApp extends StatefulWidget {
  const BetwizzOptimizedApp({super.key});

  @override
  State<BetwizzOptimizedApp> createState() => _BetwizzOptimizedAppState();
}

class _BetwizzOptimizedAppState extends State<BetwizzOptimizedApp> 
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Preload critical assets after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AssetOptimizer.preloadCriticalImages(context);
    });
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Trigger cleanup when app goes to background
    if (state == AppLifecycleState.paused) {
      PerformanceOptimizer.triggerMemoryCleanup();
    }
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
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Configure optimized image cache
          PerformanceOptimizer.configureImageCache();
          
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
