import 'package:hive/hive.dart';

part 'channel.g.dart';

@HiveType(typeId: 0)
class Channel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String thumbnailUrl;

  @HiveField(4)
  final String streamUrl;

  @HiveField(5)
  final bool isLive;

  @HiveField(6)
  final int viewerCount;

  @HiveField(7)
  final String category;

  @HiveField(8)
  final String creatorId;

  @HiveField(9)
  final String creatorName;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime? lastActiveAt;

  @HiveField(12)
  final List<String> tags;

  @HiveField(13)
  final bool isPremium;

  @HiveField(14)
  final double? subscriptionPrice;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.thumbnailUrl,
    required this.streamUrl,
    required this.isLive,
    required this.viewerCount,
    required this.category,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    this.lastActiveAt,
    required this.tags,
    this.isPremium = false,
    this.subscriptionPrice,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      streamUrl: json['streamUrl'] as String,
      isLive: json['isLive'] as bool,
      viewerCount: json['viewerCount'] as int,
      category: json['category'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.parse(json['lastActiveAt'] as String)
          : null,
      tags: List<String>.from(json['tags'] as List),
      isPremium: json['isPremium'] as bool? ?? false,
      subscriptionPrice: json['subscriptionPrice'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'streamUrl': streamUrl,
      'isLive': isLive,
      'viewerCount': viewerCount,
      'category': category,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'tags': tags,
      'isPremium': isPremium,
      'subscriptionPrice': subscriptionPrice,
    };
  }

  Channel copyWith({
    String? id,
    String? name,
    String? description,
    String? thumbnailUrl,
    String? streamUrl,
    bool? isLive,
    int? viewerCount,
    String? category,
    String? creatorId,
    String? creatorName,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    List<String>? tags,
    bool? isPremium,
    double? subscriptionPrice,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      isLive: isLive ?? this.isLive,
      viewerCount: viewerCount ?? this.viewerCount,
      category: category ?? this.category,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      tags: tags ?? this.tags,
      isPremium: isPremium ?? this.isPremium,
      subscriptionPrice: subscriptionPrice ?? this.subscriptionPrice,
    );
  }

  @override
  String toString() {
    return 'Channel(id: $id, name: $name, isLive: $isLive, viewerCount: $viewerCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Channel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
