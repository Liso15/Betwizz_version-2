import '../../models/bet_receipt.dart';
import '../../models/channel.dart';
import '../../models/chat_message.dart';
import '../../models/payment.dart';

class MockData {
  static final List<Channel> channels = [
    Channel(
      id: '1',
      name: 'Soccer Central',
      description: 'Your daily dose of soccer news, analysis, and highlights.',
      thumbnailUrl: 'assets/images/channel_1.jpg',
      streamUrl: 'https://example.com/stream1',
      isLive: true,
      viewerCount: 1200,
      category: 'Sports',
      creatorId: 'user1',
      creatorName: 'John Doe',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      lastActiveAt: DateTime.now().subtract(const Duration(minutes: 10)),
      tags: ['soccer', 'sports', 'live'],
      isPremium: false,
    ),
    Channel(
      id: '2',
      name: 'Gaming Universe',
      description: 'Live streams of the latest and greatest video games.',
      thumbnailUrl: 'assets/images/channel_2.jpg',
      streamUrl: 'https://example.com/stream2',
      isLive: false,
      viewerCount: 500,
      category: 'Gaming',
      creatorId: 'user2',
      creatorName: 'Jane Smith',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
      tags: ['gaming', 'esports', 'live'],
      isPremium: true,
      subscriptionPrice: 4.99,
    ),
    Channel(
      id: '3',
      name: 'Cooking with Chef',
      description: 'Learn to cook delicious meals with a professional chef.',
      thumbnailUrl: 'assets/images/channel_3.jpg',
      streamUrl: 'https://example.com/stream3',
      isLive: true,
      viewerCount: 800,
      category: 'Cooking',
      creatorId: 'user3',
      creatorName: 'Chef Antoine',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      lastActiveAt: DateTime.now().subtract(const Duration(minutes: 5)),
      tags: ['cooking', 'food', 'live'],
      isPremium: false,
    ),
  ];

  static final List<ChatMessage> chatMessages = [
    ChatMessage(
      id: '1',
      content: 'Hello, how can I help you today?',
      senderId: 'ai',
      senderName: 'Betwizz AI',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isUser: false,
    ),
    ChatMessage(
      id: '2',
      content: 'I want to place a bet on the next soccer match.',
      senderId: 'user1',
      senderName: 'John Doe',
      timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      isUser: true,
    ),
    ChatMessage(
      id: '3',
      content: 'Sure, which match are you interested in?',
      senderId: 'ai',
      senderName: 'Betwizz AI',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      isUser: false,
    ),
  ];

  static final List<BetReceipt> receipts = [
    BetReceipt(
      id: '1',
      bookmaker: 'Betway',
      betType: 'Single',
      stakeAmount: 50.0,
      odds: 2.5,
      isWin: true,
      winAmount: 125.0,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      selections: [
        BetSelection(
          id: '1',
          event: 'Manchester United vs Arsenal',
          selection: 'Manchester United to win',
          odds: 2.5,
          isWin: true,
        ),
      ],
    ),
    BetReceipt(
      id: '2',
      bookmaker: 'Hollywood Bets',
      betType: 'Multiple',
      stakeAmount: 100.0,
      odds: 5.0,
      isWin: false,
      dateTime: DateTime.now().subtract(const Duration(days: 2)),
      selections: [
        BetSelection(
          id: '1',
          event: 'Kaizer Chiefs vs Orlando Pirates',
          selection: 'Kaizer Chiefs to win',
          odds: 2.0,
          isWin: false,
        ),
        BetSelection(
          id: '2',
          event: 'Liverpool vs Chelsea',
          selection: 'Liverpool to win',
          odds: 2.5,
          isWin: true,
        ),
      ],
    ),
  ];

  static final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'Visa',
      last4: '4242',
      expiryDate: '12/25',
    ),
    PaymentMethod(
      id: '2',
      type: 'Mastercard',
      last4: '5555',
      expiryDate: '08/24',
    ),
  ];

  static final List<Subscription> subscriptions = [
    Subscription(
      id: '1',
      name: 'Betwizz Premium',
      price: 99.99,
      interval: 'monthly',
    ),
  ];

  static final List<Payment> payments = [
    Payment(
      id: '1',
      amount: 99.99,
      date: DateTime.now().subtract(const Duration(days: 30)),
      description: 'Betwizz Premium Subscription',
    ),
    Payment(
      id: '2',
      amount: 99.99,
      date: DateTime.now().subtract(const Duration(days: 60)),
      description: 'Betwizz Premium Subscription',
    ),
  ];
}
