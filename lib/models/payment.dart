class PaymentMethod {
  final String id;
  final String type;
  final String last4;
  final String expiryDate;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.last4,
    required this.expiryDate,
  });
}

class Subscription {
  final String id;
  final String name;
  final double price;
  final String interval;

  Subscription({
    required this.id,
    required this.name,
    required this.price,
    required this.interval,
  });
}

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String description;

  Payment({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
  });
}
