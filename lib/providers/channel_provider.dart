import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/channel.dart';
import '../core/constants/app_constants.dart';

final channelsProvider = FutureProvider<List<Channel>>((ref) async {
  // Simulate API call delay
  await Future.delayed(const Duration(seconds: 1));
  
  // Mock data for demonstration
  return [
    Channel(
      id: '1',
      name: 'Premier League Predictions',
      description: 'Expert analysis and predictions for Premier League matches',
      creatorName: 'BettingPro SA',
      creatorId: 'creator1',
      thumbnailUrl: '/placeholder.svg?height=200&width=300',
      category: 'Football',
      isLive: true,
      viewerCount: 1247,
      subscriptionTier: SubscriptionTier.premium,
      price: AppConstants.premiumTierPrice,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      tags: ['football', 'premier-league', 'predictions'],
    ),
    Channel(
      id: '2',
      name: 'Rugby World Cup Analysis',
      description: 'In-depth analysis of Rugby World Cup matches and betting opportunities',
      creatorName: 'RugbyExpert',
      creatorId: 'creator2',
      thumbnailUrl: '/placeholder.svg?height=200&width=300',
      category: 'Rugby',
      isLive: false,
      viewerCount: 892,
      subscriptionTier: SubscriptionTier.basic,
      price: AppConstants.basicTierPrice,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      tags: ['rugby', 'world-cup', 'analysis'],
    ),
    Channel(
      id: '3',
      name: 'Cricket Betting Strategies',
      description: 'Advanced cricket betting strategies and live match analysis',
      creatorName: 'CricketGuru',
      creatorId: 'creator3',
      thumbnailUrl: '/placeholder.svg?height=200&width=300',
      category: 'Cricket',
      isLive: true,
      viewerCount: 634,
      subscriptionTier: SubscriptionTier.elite,
      price: AppConstants.eliteTierPrice,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      tags: ['cricket', 'strategies', 'live-analysis'],
    ),
  ];
});

final channelProvider = FutureProvider.family<Channel?, String>((ref, channelId) async {
  final channels = await ref.watch(channelsProvider.future);
  return channels.firstWhere((channel) => channel.id == channelId);
});
