import 'package:flutter/material.dart';
import '../../core/services/payment_service.dart';
import '../../models/payment.dart';
import '../../design_system/app_components.dart';

class SubscriptionManagementScreen extends StatefulWidget {
  const SubscriptionManagementScreen({Key? key}) : super(key: key);

  @override
  _SubscriptionManagementScreenState createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<Subscription>> _subscriptionsFuture;

  @override
  void initState() {
    super.initState();
    _subscriptionsFuture = _paymentService.getSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Management'),
      ),
      body: FutureBuilder<List<Subscription>>(
        future: _subscriptionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorState(
              message: 'Error fetching subscriptions.',
              onRetry: () {
                setState(() {
                  _subscriptionsFuture = _paymentService.getSubscriptions();
                });
              },
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const EmptyState(message: 'No subscriptions found.');
          } else {
            final subscriptions = snapshot.data!;
            return ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return SubscriptionListItem(subscription: subscription);
              },
            );
          }
        },
      ),
    );
  }
}

class SubscriptionListItem extends StatelessWidget {
  const SubscriptionListItem({
    Key? key,
    required this.subscription,
  }) : super(key: key);

  final Subscription subscription;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subscription.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'R${subscription.price.toStringAsFixed(2)} / ${subscription.interval}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
