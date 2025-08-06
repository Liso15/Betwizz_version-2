class ChatMessage {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final DateTime timestamp;
  final bool isUser;
  final MessageType type;
  final String? channelId;
  final Map<String, dynamic>? metadata;
  final bool isEdited;
  final DateTime? editedAt;
  final List<String> reactions;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.timestamp,
    required this.isUser,
    this.type = MessageType.text,
    this.channelId,
    this.metadata,
    this.isEdited = false,
    this.editedAt,
    this.reactions = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatarUrl: json['senderAvatarUrl'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isUser: json['isUser'] as bool,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.text,
      ),
      channelId: json['channelId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isEdited: json['isEdited'] as bool? ?? false,
      editedAt: json['editedAt'] != null 
          ? DateTime.parse(json['editedAt'] as String)
          : null,
      reactions: List<String>.from(json['reactions'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatarUrl': senderAvatarUrl,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
      'type': type.toString().split('.').last,
      'channelId': channelId,
      'metadata': metadata,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'reactions': reactions,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? content,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    DateTime? timestamp,
    bool? isUser,
    MessageType? type,
    String? channelId,
    Map<String, dynamic>? metadata,
    bool? isEdited,
    DateTime? editedAt,
    List<String>? reactions,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      timestamp: timestamp ?? this.timestamp,
      isUser: isUser ?? this.isUser,
      type: type ?? this.type,
      channelId: channelId ?? this.channelId,
      metadata: metadata ?? this.metadata,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, content: $content, isUser: $isUser, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum MessageType {
  text,
  image,
  video,
  audio,
  file,
  system,
  betting,
  prediction,
}
