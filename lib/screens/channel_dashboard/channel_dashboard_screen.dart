import 'package:flutter/material.dart';
import '../../core/services/channel_service.dart';
import '../../models/channel.dart';
import '../../design_system/app_components.dart';

class ChannelDashboardScreen extends StatefulWidget {
  const ChannelDashboardScreen({Key? key}) : super(key: key);

  @override
  _ChannelDashboardScreenState createState() => _ChannelDashboardScreenState();
}

class _ChannelDashboardScreenState extends State<ChannelDashboardScreen> {
  final ChannelService _channelService = ChannelService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Channels'),
      ),
      body: StreamBuilder<List<Channel>>(
        stream: _channelService.getChannels(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          } else if (snapshot.hasError) {
            return ErrorState(
              message: 'Error fetching channels.',
              onRetry: () {
                setState(() {});
              },
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const EmptyState(message: 'No channels found.');
          } else {
            final channels = snapshot.data!;
            return ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, index) {
                final channel = channels[index];
                return ChannelListItem(channel: channel);
              },
            );
          }
        },
      ),
    );
  }
}

class ChannelListItem extends StatelessWidget {
  const ChannelListItem({
    Key? key,
    required this.channel,
  }) : super(key: key);

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              channel.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              channel.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 4),
                Text(channel.creatorName),
                const SizedBox(width: 16),
                const Icon(Icons.visibility),
                const SizedBox(width: 4),
                Text('${channel.viewerCount}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
