import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/channel.dart';

class ChannelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Channel>> getChannels() {
    return _firestore.collection('channels').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Channel.fromJson(doc.data())).toList());
  }
}
