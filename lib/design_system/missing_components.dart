import 'package:flutter/material.dart';

enum LoadingType { inline, fullscreen }
enum ErrorType { generic, network }
enum EmptyStateType { generic }

class BetwizzDesignSystem {
  static Widget buildLoadingState(LoadingType type) {
    switch (type) {
      case LoadingType.inline:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case LoadingType.fullscreen:
        return const Center(
          child: CircularProgressIndicator(),
        );
    }
  }

  static Widget buildErrorState(ErrorType error, {VoidCallback? onRetry}) {
    final String message = switch (error) {
      ErrorType.network => 'Network error. Please check your connection.',
      ErrorType.generic => 'Something went wrong. Please try again.',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }

  static Widget buildEmptyState(EmptyStateType type, {String? title, String? subtitle}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox, size: 48, color: Colors.grey),
          const SizedBox(height: 8),
          Text(title ?? 'Nothing here yet'),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  static Widget buildOfflineIndicator() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.orange[50],
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(child: Text('You are offline. Some features may be unavailable.')),
        ],
      ),
    );
  }

  static List<Widget> buildOnboardingScreens() {
    return const [
      _OnboardingSlide(title: 'Welcome to Betwizz', subtitle: 'Smart betting assistant'),
      _OnboardingSlide(title: 'Scan Receipts', subtitle: 'Track your bets easily'),
      _OnboardingSlide(title: 'Chat with Mfethu AI', subtitle: 'Get insights and strategies'),
    ];
  }
}

class _OnboardingSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  const _OnboardingSlide({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
