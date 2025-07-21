import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
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
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Hive
    await Hive.initFlutter();
    
    // Register Hive adapters
    Hive.registerAdapter(ChannelAdapter());
    Hive.registerAdapter(ChatMessageAdapter());
    Hive.registerAdapter(BetReceiptAdapter());
    
    // Open Hive boxes
    await Hive.openBox<Channel>('channels');
    await Hive.openBox<ChatMessage>('chat_messages');
    await Hive.openBox<BetReceipt>('bet_receipts');
    
    runApp(const BetwizzApp());
  } catch (e) {
    if (kDebugMode) {
      print('Initialization error: $e');
    }
    // Run app with limited functionality if initialization fails
    runApp(const BetwizzApp());
  }
}

class BetwizzApp extends StatelessWidget {
  const BetwizzApp({super.key});

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
