import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy.'),
            onTap: () {
              // TODO: Implement navigation to privacy policy
            },
          ),
          ListTile(
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms of service.'),
            onTap: () {
              // TODO: Implement navigation to terms of service
            },
          ),
        ],
      ),
    );
  }
}
