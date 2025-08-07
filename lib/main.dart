import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/auth_service.dart';
import 'screens/auth_wrapper.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<AuthService>(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Betwizz',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}
