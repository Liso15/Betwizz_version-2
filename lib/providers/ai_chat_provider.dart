import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';

final chatMessagesProvider = StateNotifierProvider<ChatNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  return ChatNotifier();
});

class ChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  ChatNotifier() : super(const AsyncValue.data([]));

  void sendMessage(String content) async {
    final currentMessages = state.value ?? [];
    
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    state = AsyncValue.data([...currentMessages, userMessage]);
    
    // Simulate AI response delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate AI response based on user input
    final aiResponse = _generateAiResponse(content);
    final aiMessage = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    final updatedMessages = state.value ?? [];
    state = AsyncValue.data([...updatedMessages, aiMessage]);
  }

  String _generateAiResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('strategy') || message.contains('strategies')) {
      return "Here are some proven betting strategies I recommend:\n\n"
          "1. **Bankroll Management**: Never bet more than 2-5% of your total bankroll on a single bet.\n\n"
          "2. **Value Betting**: Look for odds that are higher than the true probability of an outcome.\n\n"
          "3. **Research First**: Always analyze team form, injuries, and head-to-head records before betting.\n\n"
          "4. **Specialize**: Focus on leagues and sports you know well rather than betting on everything.\n\n"
          "Would you like me to explain any of these strategies in more detail?";
    }
    
    if (message.contains('odds') || message.contains('analyze')) {
      return "I can help you analyze odds! Here's what to look for:\n\n"
          "📊 **Odds Comparison**: Always compare odds across different bookmakers\n"
          "📈 **Market Movement**: Watch how odds change leading up to the match\n"
          "🎯 **Value Spots**: Look for odds that seem too high based on your analysis\n"
          "⚖️ **Implied Probability**: Convert odds to percentages to understand true chances\n\n"
          "Share specific odds with me and I'll help you analyze them!";
    }
    
    if (message.contains('bankroll') || message.contains('money') || message.contains('manage')) {
      return "Smart bankroll management is crucial! Here's my advice:\n\n"
          "💰 **Set a Budget**: Only use money you can afford to lose\n"
          "📊 **Unit System**: Bet in units (1 unit = 1-2% of bankroll)\n"
          "📉 **Loss Limits**: Set daily/weekly loss limits and stick to them\n"
          "📈 **Track Everything**: Keep detailed records of all bets\n"
          "🚫 **Never Chase**: Don't increase bet sizes to recover losses\n\n"
          "Remember: Discipline beats luck every time!";
    }
    
    if (message.contains('match') || message.contains('game') || message.contains('predict')) {
      return "I'd love to help with match predictions! For the best analysis, I need:\n\n"
          "⚽ **Teams Playing**: Which teams are you interested in?\n"
          "📅 **Match Date**: When is the game?\n"
          "🏆 **Competition**: What league/tournament?\n"
          "📊 **Bet Type**: What kind of bet are you considering?\n\n"
          "With this info, I can provide detailed analysis including form, injuries, and betting recommendations!";
    }
    
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      return "Sawubona! 👋 I'm Mfethu, your AI betting assistant!\n\n"
          "I'm here to help you with:\n"
          "🎯 Betting strategies and tips\n"
          "📊 Odds analysis and value betting\n"
          "💰 Bankroll management advice\n"
          "⚽ Match predictions and insights\n"
          "📈 Performance tracking\n\n"
          "What would you like to know about betting today?";
    }
    
    // Default response
    return "That's an interesting question! As your betting assistant, I can help you with:\n\n"
        "• Betting strategies and bankroll management\n"
        "• Odds analysis and value identification\n"
        "• Match predictions and insights\n"
        "• Risk management tips\n\n"
        "Could you be more specific about what you'd like help with? I'm here to make you a smarter bettor! 🎯";
  }

  void clearMessages() {
    state = const AsyncValue.data([]);
  }
}
