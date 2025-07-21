import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/channel.dart';
import '../core/constants/app_constants.dart';

final channelsProvider = AsyncNotifierProvider<ChannelsNotifier, List<Channel>>(
  () => ChannelsNotifier(),
);

class ChannelsNotifier extends AsyncNotifier<List<Channel>> {
  @override
  Future<List<Channel>> build() async {
    return await fetchChannels();
  }

  Future<List<Channel>> fetchChannels() async {
    try {
      // Simulate API call with mock data for development
      await Future.delayed(const Duration(seconds: 1));
      
      return _getMockChannels();
    } catch (e) {
      debugPrint('Error fetching channels: $e');
      throw Exception('Failed to load channels');
    }
  }

  Future<void> refreshChannels() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => fetchChannels());
  }

  Future<void> toggleChannelLive(String channelId) async {
    final currentChannels = state.value ?? [];
    final updatedChannels = currentChannels.map((channel) {
      if (channel.id == channelId) {
        return channel.copyWith(isLive: !channel.isLive);
      }
      return channel;
    }).toList();
    
    state = AsyncValue.data(updatedChannels);
  }

  List<Channel> _getMockChannels() {
    return [
      Channel(
        id: '1',
        name: 'Premier League Analysis',
        description: 'Live analysis of Premier League matches with expert predictions',
        thumbnailUrl: '/placeholder.svg?height=200&width=300&text=Premier+League',
        streamUrl: 'https://example.com/stream1',
        isLive: true,
        viewerCount: 1250,
        category: 'Football',
        creatorId: 'creator1',
        creatorName: 'John Smith',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        lastActiveAt: DateTime.now(),
        tags: ['football', 'premier-league', 'analysis'],
        isPremium: false,
      ),
      Channel(
        id: '2',
        name: 'Cricket World Cup',
        description: 'Comprehensive coverage of Cricket World Cup matches',
        thumbnailUrl: '/placeholder.svg?height=200&width=300&text=Cricket+World+Cup',
        streamUrl: 'https://example.com/stream2',
        isLive: true,
        viewerCount: 890,
        category: 'Cricket',
        creatorId: 'creator2',
        creatorName: 'Sarah Johnson',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        lastActiveAt: DateTime.now(),
        tags: ['cricket', 'world-cup', 'live'],
        isPremium: true,
        subscriptionPrice: 29.99,
      ),
      Channel(
        id: '3',
        name: 'Rugby Championship',
        description: 'Expert analysis and predictions for Rugby Championship',
        thumbnailUrl: '/placeholder.svg?height=200&width=300&text=Rugby+Championship',
        streamUrl: 'https://example.com/stream3',
        isLive: false,
        viewerCount: 0,
        category: 'Rugby',
        creatorId: 'creator3',
        creatorName: 'Mike Williams',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 3)),
        tags: ['rugby', 'championship', 'analysis'],
        isPremium: false,
      ),
      Channel(
        id: '4',
        name: 'Tennis Grand Slam',
        description: 'Live coverage of Grand Slam tennis tournaments',
        thumbnailUrl: '/placeholder.svg?height=200&width=300&text=Tennis+Grand+Slam',
        streamUrl: 'https://example.com/stream4',
        isLive: true,
        viewerCount: 567,
        category: 'Tennis',
        creatorId: 'creator4',
        creatorName: 'Emma Davis',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        lastActiveAt: DateTime.now(),
        tags: ['tennis', 'grand-slam', 'live'],
        isPremium: true,
        subscriptionPrice: 19.99,
      ),
      Channel(
        id: '5',
        name: 'Basketball NBA',
        description: 'NBA game analysis and betting insights',
        thumbnailUrl: '/placeholder.svg?height=200&width=300&text=Basketball+NBA',
        streamUrl: 'https://example.com/stream5',
        isLive: false,
        viewerCount: 0,
        category: 'Basketball',
        creatorId: 'creator5',
        creatorName: 'Chris Brown',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 8)),
        tags: ['basketball', 'nba', 'betting'],
        isPremium: false,
      ),
    ];
  }
}

// Legacy provider for backward compatibility
class ChannelProvider extends ChangeNotifier {
  List<Channel> _channels = [];
  bool _isLoading = false;
  String? _error;

  List<Channel> get channels => _channels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChannelProvider() {
    loadChannels();
  }

  Future<void> loadChannels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      _channels = _getMockChannels();
    } catch (e) {
      _error = 'Failed to load channels';
      debugPrint('Error loading channels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshChannels() async {
    await loadChannels();
  }

  List<Channel> _getMockChannels() {
    return [
      Channel(
        id: '1',
        name: 'Premier League Analysis',
        description: 'Live analysis of Premier League matches',
        thumbnailUrl: '/placeholder.svg?height=200&width=300&text=Premier+League',
        streamUrl: 'https://example.com/stream1',
        isLive: true,
        viewerCount: 1250,
        category: 'Football',
        creatorId: 'creator1',
        creatorName: 'John Smith',
        createdAt: DateTime.now(),
        tags: ['football', 'premier-league'],
      ),
    ];
  }
}
