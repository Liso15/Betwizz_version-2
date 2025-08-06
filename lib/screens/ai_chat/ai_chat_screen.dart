import 'package:flutter/material.dart';
import '../../core/services/ai_chat_service.dart';
import '../../models/chat_message.dart';
import '../../design_system/app_components.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({Key? key}) : super(key: key);

  @override
  _AiChatScreenState createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiChatService _chatService = AiChatService();
  late Future<List<ChatMessage>> _messagesFuture;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _messagesFuture = _chatService.getChatMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<ChatMessage>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Error fetching messages.',
                    onRetry: () {
                      setState(() {
                        _messagesFuture = _chatService.getChatMessages();
                      });
                    },
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const EmptyState(message: 'No messages yet.');
                } else {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ChatMessageListItem(message: message);
                    },
                  );
                }
              },
            ),
          ),
          MessageInput(
            textController: _textController,
            onSendMessage: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    _textController.clear();

    final newMessage = await _chatService.sendMessage(message);
    setState(() {
      _messagesFuture.then((messages) => messages.add(newMessage));
    });
  }
}

class ChatMessageListItem extends StatelessWidget {
  const ChatMessageListItem({
    Key? key,
    required this.message,
  }) : super(key: key);

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

class MessageInput extends StatelessWidget {
  const MessageInput({
    Key? key,
    required this.textController,
    required this.onSendMessage,
  }) : super(key: key);

  final TextEditingController textController;
  final VoidCallback onSendMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: onSendMessage,
          ),
        ],
      ),
    );
  }
}
