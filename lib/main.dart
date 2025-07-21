import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'models/channel.dart';
import 'models/chat_message.dart';
import 'models/bet_receipt.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register Hive adapters (check if not already registered)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ChannelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MessageTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(BetReceiptAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(BetSelectionAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ReceiptStatusAdapter());
    }
    
    // Open Hive boxes
    await Hive.openBox<Channel>('channels');
    await Hive.openBox<ChatMessage>('messages');
    await Hive.openBox<BetReceipt>('receipts');
    await Hive.openBox('settings');
    
    runApp(const ProviderScope(child: BetwizzApp()));
  } catch (e, stackTrace) {
    if (kDebugMode) {
      print('Error during app initialization: $e');
      print('Stack trace: $stackTrace');
    }
    
    // Run a minimal error app
    runApp(ProviderScope(child: BetwizzErrorApp(error: e.toString())));
  }
}

class BetwizzApp extends StatelessWidget {
  const BetwizzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betwizz',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class BetwizzErrorApp extends StatelessWidget {
  final String error;
  
  const BetwizzErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Betwizz - Error',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We encountered an error while starting the app. Please try again later.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Debug Info: $error',
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // Restart the app
                    main();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
