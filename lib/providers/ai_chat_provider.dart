import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';

final chatMessagesProvider = AsyncNotifierProvider<ChatMessagesNotifier, List<ChatMessage>>(
  () => ChatMessagesNotifier(),
);

class ChatMessagesNotifier extends AsyncNotifier<List<ChatMessage>> {
  final List<ChatMessage> _messages = [];
  final Uuid _uuid = const Uuid();

  @override
  Future<List<ChatMessage>> build() async {
    // Initialize with welcome message
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: "Sawubona! I'm Mfethu, your AI betting assistant. How can I help you today?",
      senderId: 'mfethu_ai',
      senderName: 'Mfethu AI',
      timestamp: DateTime.now(),
      isUser: false,
      type: MessageType.text,
    ));
    
    return _messages;
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content.trim(),
      senderId: 'current_user',
      senderName: 'You',
      timestamp: DateTime.now(),
      isUser: true,
      type: MessageType.text,
    );

    _messages.add(userMessage);
    state = AsyncValue.data(List.from(_messages));

    // Simulate AI response
    await Future.delayed(const Duration(milliseconds: 1500));

    final aiResponse = _generateAIResponse(content);
    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      content: aiResponse,
      senderId: 'mfethu_ai',
      senderName: 'Mfethu AI',
      timestamp: DateTime.now(),
      isUser: false,
      type: MessageType.text,
    );

    _messages.add(aiMessage);
    state = AsyncValue.data(List.from(_messages));
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi') || message.contains('sawubona')) {
      return "Hello! I'm here to help you with your betting strategies and analysis. What would you like to know?";
    } else if (message.contains('strategy') || message.contains('strategies')) {
      return "Here are some key betting strategies:\n\n1. Bankroll Management - Never bet more than 5% of your total bankroll\n2. Value Betting - Look for odds that offer better value than the actual probability\n3. Research - Always analyze team form, injuries, and head-to-head records\n4. Emotional Control - Don't chase losses or bet impulsively\n\nWould you like me to elaborate on any of these?";
    } else if (message.contains('odds') || message.contains('analysis')) {
      return "For odds analysis, I recommend:\n\n• Compare odds across multiple bookmakers\n• Look for line movements that indicate sharp money\n• Consider implied probability vs actual probability\n• Factor in recent team performance and injuries\n\nWhat specific match or sport would you like me to analyze?";
    } else if (message.contains('bankroll') || message.contains('money')) {
      return "Bankroll management is crucial for long-term success:\n\n• Set a dedicated betting budget\n• Use the 1-5% rule per bet\n• Track all your bets\n• Never chase losses\n• Take breaks when on losing streaks\n\nRemember: Only bet what you can afford to lose!";
    } else if (message.contains('prediction') || message.contains('predict')) {
      return "I can help with match predictions based on:\n\n• Team form and statistics\n• Head-to-head records\n• Player injuries and suspensions\n• Weather conditions\n• Home/away advantage\n\nWhich match would you like me to analyze for you?";
    } else if (message.contains('help') || message.contains('assist')) {
      return "I can assist you with:\n\n🎯 Betting strategies and tips\n📊 Odds analysis and comparisons\n💰 Bankroll management advice\n🔍 Match predictions and insights\n📈 Performance tracking\n⚠️ Responsible gambling guidance\n\nWhat specific area would you like help with?";
    } else {
      return "That's an interesting question! I'm here to help with betting strategies, odds analysis, and match predictions. Could you be more specific about what you'd like to know? I can provide insights on bankroll management, value betting, or analyze specific matches for you.";
    }
  }

  Future<void> clearMessages() async {
    _messages.clear();
    // Add welcome message back
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: "Sawubona! I'm Mfethu, your AI betting assistant. How can I help you today?",
      senderId: 'mfethu_ai',
      senderName: 'Mfethu AI',
      timestamp: DateTime.now(),
      isUser: false,
      type: MessageType.text,
    ));
    
    state = AsyncValue.data(List.from(_messages));
  }
}

// Legacy provider for backward compatibility
class AiChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  AiChatProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: "Sawubona! I'm Mfethu, your AI betting assistant. How can I help you today?",
      senderId: 'mfethu_ai',
      senderName: 'Mfethu AI',
      timestamp: DateTime.now(),
      isUser: false,
      type: MessageType.text,
    ));
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content.trim(),
      senderId: 'current_user',
      senderName: 'You',
      timestamp: DateTime.now(),
      isUser: true,
      type: MessageType.text,
    );

    _messages.add(userMessage);
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    // Simulate AI response delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final aiResponse = _generateAIResponse(content);
    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      content: aiResponse,
      senderId: 'mfethu_ai',
      senderName: 'Mfethu AI',
      timestamp: DateTime.now(),
      isUser: false,
      type: MessageType.text,
    );

    _messages.add(aiMessage);
    _isLoading = false;
    notifyListeners();
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi')) {
      return "Hello! I'm here to help you with your betting strategies. What would you like to know?";
    } else if (message.contains('strategy')) {
      return "Here are some key betting strategies: bankroll management, value betting, and research-based decisions. Would you like me to elaborate on any of these?";
    } else {
      return "That's an interesting question! I can help with betting strategies, odds analysis, and match predictions. What specific area would you like to explore?";
    }
  }

  void clearMessages() {
    _messages.clear();
    _initializeChat();
  }
}
