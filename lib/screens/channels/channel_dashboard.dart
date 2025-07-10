import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/channel.dart';
import '../../providers/channel_provider.dart';
import 'widgets/channel_card.dart';
import 'widgets/live_indicator.dart';

class ChannelDashboard extends ConsumerStatefulWidget {
  const ChannelDashboard({super.key});

  @override
  ConsumerState<ChannelDashboard> createState() => _ChannelDashboardState();
}

class _ChannelDashboardState extends ConsumerState<ChannelDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channelsAsync = ref.watch(channelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Implement notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.live_tv), text: 'Live'),
            Tab(icon: Icon(Icons.library_books), text: 'Strategies'),
            Tab(icon: Icon(Icons.forum), text: 'Community'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveChannels(channelsAsync),
          _buildStrategyVault(),
          _buildCommunityChat(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create channel or start stream
          _showCreateChannelDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLiveChannels(AsyncValue<List<Channel>> channelsAsync) {
    return channelsAsync.when(
      data: (channels) {
        final liveChannels = channels.where((c) => c.isLive).toList();
        
        if (liveChannels.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.live_tv_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No live channels at the moment'),
                Text('Check back later for live streams!'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(channelsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: liveChannels.length,
            itemBuilder: (context, index) {
              final channel = liveChannels[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ChannelCard(
                  channel: channel,
                  onTap: () => _navigateToStream(channel),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading channels: $error'),
            ElevatedButton(
              onPressed: () => ref.invalidate(channelsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyVault() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.library_books, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Strategy Vault'),
          Text('Encrypted betting strategies coming soon'),
        ],
      ),
    );
  }

  Widget _buildCommunityChat() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Community Chat'),
          Text('Connect with other bettors'),
        ],
      ),
    );
  }

  void _navigateToStream(Channel channel) {
    // Navigate to stream view
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreamViewScreen(channel: channel),
      ),
    );
  }

  void _showCreateChannelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Channel'),
        content: const Text('Channel creation feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Placeholder for StreamViewScreen
class StreamViewScreen extends StatelessWidget {
  final Channel channel;

  const StreamViewScreen({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(channel.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Video player area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle, size: 80, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Stream Player',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      'Agora RTC integration coming soon',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Chat and betting overlay
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[900],
              child: const Center(
                child: Text(
                  'Live Chat & Betting Overlay',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
