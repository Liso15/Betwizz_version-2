import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/web/web_config.dart';
import 'core/web/firebase_web.dart';
import 'core/theme/app_theme.dart';
import 'providers/channel_provider.dart';
import 'providers/receipt_provider.dart';
import 'providers/ai_chat_provider.dart';
import 'screens/main_navigation.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize web-specific configurations
  await WebConfig.initialize();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize Firebase for web
  if (kIsWeb) {
    try {
      await FirebaseWeb.initialize();
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization failed: $e');
      }
    }
  }
  
  runApp(const BetwizzWebApp());
}

class BetwizzWebApp extends StatelessWidget {
  const BetwizzWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChannelProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptProvider()),
        ChangeNotifierProvider(create: (_) => AiChatProvider()),
      ],
      child: MaterialApp(
        title: WebConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const MainNavigation(),
          '/channels': (context) => const MainNavigation(initialIndex: 0),
          '/scanner': (context) => const MainNavigation(initialIndex: 1),
          '/chat': (context) => const MainNavigation(initialIndex: 2),
          '/profile': (context) => const MainNavigation(initialIndex: 3),
        },
        builder: (context, child) {
          // Web-specific error handling
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            return WebErrorWidget(error: errorDetails.exception.toString());
          };
          
          return child!;
        },
      ),
    );
  }
}

class WebErrorWidget extends StatelessWidget {
  final String error;
  
  const WebErrorWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (kDebugMode) ...[
              Text(
                error,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: () {
                // Reload the app
                if (kIsWeb) {
                  // In web, we can reload the page
                  // window.location.reload();
                }
              },
              child: const Text('Reload App'),
            ),
          ],
        ),
      ),
    );
  }
}
