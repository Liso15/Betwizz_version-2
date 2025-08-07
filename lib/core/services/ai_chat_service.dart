import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_message.dart';

class AiChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<ChatMessage>> getChatMessages(String channelId) {
    return _firestore
        .collection('chats')
        .doc(channelId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromJson(doc.data()))
            .toList());
  }

  Future<void> sendMessage(String channelId, ChatMessage message) async {
    try {
      await _firestore
          .collection('chats')
          .doc(channelId)
          .collection('messages')
          .add(message.toJson());
    } catch (e) {
      print(e);
    }
  }
}
