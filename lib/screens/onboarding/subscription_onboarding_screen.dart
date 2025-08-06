import 'package:flutter/material.dart';
import '../../design_system/app_components.dart';

class SubscriptionOnboardingScreen extends StatelessWidget {
  const SubscriptionOnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Plan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Unlock Premium Features',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Choose a subscription plan to get the most out of Betwizz.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Subscribe Now',
              onPressed: () {
                // TODO: Implement subscription flow
              },
            ),
          ],
        ),
      ),
    );
  }
}
