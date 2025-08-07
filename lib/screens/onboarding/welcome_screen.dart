import 'package:flutter/material.dart';
import '../../design_system/app_components.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Betwizz!',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Your smart betting assistant.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Get Started',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
