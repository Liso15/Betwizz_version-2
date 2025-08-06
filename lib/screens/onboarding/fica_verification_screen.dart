import 'package:flutter/material.dart';
import '../../design_system/app_components.dart';

class FICAVerificationScreen extends StatelessWidget {
  const FICAVerificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FICA Verification'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Verify your identity',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Please upload a copy of your ID and proof of residence.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Upload Documents',
              onPressed: () {
                // TODO: Implement document upload functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
