import 'package:flutter/material.dart';

class MissingScreens {
  static Widget buildWelcomeScreen() => _placeholder('Welcome');
  static Widget buildFICAVerificationScreen() => _placeholder('FICA Verification');
  static Widget buildSubscriptionOnboardingScreen() => _placeholder('Subscription Onboarding');

  static Widget buildPaymentMethodScreen() => _placeholder('Payment Methods');
  static Widget buildSubscriptionManagementScreen() => _placeholder('Manage Subscription');
  static Widget buildPaymentHistoryScreen() => _placeholder('Payment History');

  static Widget buildNotificationSettingsScreen() => _placeholder('Notifications');
  static Widget buildPrivacySettingsScreen() => _placeholder('Privacy & Security');
  static Widget buildResponsibleGamblingScreen() => _placeholder('Responsible Gambling');

  static Widget buildHelpCenterScreen() => _placeholder('Help Center');
  static Widget buildContactSupportScreen() => _placeholder('Contact Support');
  static Widget buildFAQScreen() => _placeholder('FAQ');

  static Widget _placeholder(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.build, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text('$title – coming soon'),
          ],
        ),
      ),
    );
  }
}
