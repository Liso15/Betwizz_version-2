import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../models/bet_receipt.dart';

class ReceiptScannerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<BetReceipt>> getReceipts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('receipts')
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BetReceipt.fromJson(doc.data()))
            .toList());
  }

  Future<void> saveReceipt(String userId, BetReceipt receipt, File image) async {
    try {
      final imageUrl = await _uploadImage(userId, image);
      final newReceipt = receipt.copyWith(imageUrl: imageUrl);
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('receipts')
          .add(newReceipt.toJson());
    } catch (e) {
      print(e);
    }
  }

  Future<String> _uploadImage(String userId, File image) async {
    final storageRef = _storage.ref().child('receipts/$userId/${DateTime.now()}.png');
    final uploadTask = storageRef.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => null);
    return await snapshot.ref.getDownloadURL();
  }
}
