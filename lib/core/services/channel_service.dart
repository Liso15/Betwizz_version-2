import '../../models/channel.dart';
import '../mock/mock_data.dart';

class ChannelService {
  Future<List<Channel>> getChannels() async {
    // TODO: Replace with Firestore implementation
    await Future.delayed(const Duration(seconds: 1));
    return MockData.channels;
  }
}
