import '../../models/chat_message.dart';
import '../mock/mock_data.dart';

class AiChatService {
  Future<List<ChatMessage>> getChatMessages() async {
    // TODO: Replace with backend implementation
    await Future.delayed(const Duration(seconds: 1));
    return MockData.chatMessages;
  }

  Future<ChatMessage> sendMessage(String message) async {
    // TODO: Replace with backend implementation
    await Future.delayed(const Duration(seconds: 1));
    final newMessage = ChatMessage(
      id: (MockData.chatMessages.length + 1).toString(),
      content: 'This is a mock response to "$message"',
      senderId: 'ai',
      senderName: 'Betwizz AI',
      timestamp: DateTime.now(),
      isUser: false,
    );
    MockData.chatMessages.add(newMessage);
    return newMessage;
  }
}
