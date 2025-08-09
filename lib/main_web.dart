import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/web/web_config.dart';
import 'core/web/firebase_web.dart';
import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  try {
    debugPrint('App starting...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('Flutter binding initialized');
    
    // Initialize web-specific configurations
    debugPrint('Initializing WebConfig...');
    await WebConfig.initialize();
    debugPrint('WebConfig initialized');
    
    // Initialize Hive for local storage
    debugPrint('Initializing Hive...');
    await Hive.initFlutter();
    debugPrint('Hive initialized');
    
    // Initialize Firebase for web
    if (kIsWeb) {
      try {
        debugPrint('Initializing Firebase for web...');
        await Firebase.initializeApp(options: FirebaseConfig.current);
        await FirebaseWeb.initialize();
        debugPrint('Firebase initialized');
      } catch (e) {
        debugPrint('Firebase initialization failed: $e');
        // Continue without Firebase for now
      }
    }
    
    debugPrint('Starting app...');
    runApp(const ProviderScope(child: BetwizzWebApp()));
  } catch (e, stack) {
    debugPrint('Error during app initialization: $e');
    debugPrint('Stack trace: $stack');
    rethrow;
  }
}

class BetwizzWebApp extends StatelessWidget {
  const BetwizzWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('BetwizzWebApp build called');
    return MaterialApp(
      title: WebConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      builder: (context, child) {
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return WebErrorWidget(error: errorDetails.exception.toString());
        };
        return child ?? const SizedBox.shrink();
      },
    );
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
