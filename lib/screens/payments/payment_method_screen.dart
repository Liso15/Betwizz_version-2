import 'package:flutter/material.dart';
import '../../core/services/payment_service.dart';
import '../../models/payment.dart';
import '../../design_system/app_components.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<PaymentMethod>> _paymentMethodsFuture;

  @override
  void initState() {
    super.initState();
    _paymentMethodsFuture = _paymentService.getPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: FutureBuilder<List<PaymentMethod>>(
        future: _paymentMethodsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorState(
              message: 'Error fetching payment methods.',
              onRetry: () {
                setState(() {
                  _paymentMethodsFuture = _paymentService.getPaymentMethods();
                });
              },
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const EmptyState(message: 'No payment methods found.');
          } else {
            final paymentMethods = snapshot.data!;
            return ListView.builder(
              itemCount: paymentMethods.length,
              itemBuilder: (context, index) {
                final paymentMethod = paymentMethods[index];
                return PaymentMethodListItem(paymentMethod: payment_method);
              },
            );
          }
        },
      ),
    );
  }
}

class PaymentMethodListItem extends StatelessWidget {
  const PaymentMethodListItem({
    Key? key,
    required this.paymentMethod,
  }) : super(key: key);

  final PaymentMethod paymentMethod;

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
              paymentMethod.type,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '**** **** **** ${paymentMethod.last4}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Expires ${paymentMethod.expiryDate}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
