enum SubscriptionTier { free, basic, premium, elite }

class Channel {
  final String id;
  final String name;
  final String description;
  final String creatorName;
  final String creatorId;
  final String thumbnailUrl;
  final String category;
  final bool isLive;
  final int viewerCount;
  final SubscriptionTier subscriptionTier;
  final double price;
  final DateTime createdAt;
  final List<String> tags;

  Channel({
    required this.id,
    required this.name,
    required this.description,
    required this.creatorName,
    required this.creatorId,
    required this.thumbnailUrl,
    required this.category,
    required this.isLive,
    required this.viewerCount,
    required this.subscriptionTier,
    required this.price,
    required this.createdAt,
    required this.tags,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      creatorName: json['creatorName'],
      creatorId: json['creatorId'],
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      category: json['category'],
      isLive: json['isLive'] ?? false,
      viewerCount: json['viewerCount'] ?? 0,
      subscriptionTier: SubscriptionTier.values.firstWhere(
        (tier) => tier.name == json['subscriptionTier'],
        orElse: () => SubscriptionTier.free,
      ),
      price: (json['price'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorName': creatorName,
      'creatorId': creatorId,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'isLive': isLive,
      'viewerCount': viewerCount,
      'subscriptionTier': subscriptionTier.name,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }
}
