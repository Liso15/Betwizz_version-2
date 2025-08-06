import '../../models/payment.dart';
import '../mock/mock_data.dart';

class PaymentService {
  Future<List<PaymentMethod>> getPaymentMethods() async {
    // TODO: Replace with backend implementation
    await Future.delayed(const Duration(seconds: 1));
    return MockData.paymentMethods;
  }

  Future<List<Subscription>> getSubscriptions() async {
    // TODO: Replace with backend implementation
    await Future.delayed(const Duration(seconds: 1));
    return MockData.subscriptions;
  }

  Future<List<Payment>> getPaymentHistory() async {
    // TODO: Replace with backend implementation
    await Future.delayed(const Duration(seconds: 1));
    return MockData.payments;
  }
}
