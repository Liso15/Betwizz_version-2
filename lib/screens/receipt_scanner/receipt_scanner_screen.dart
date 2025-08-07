import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/receipt_scanner_service.dart';
import '../../models/bet_receipt.dart';
import '../../design_system/app_components.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({Key? key, required this.userId}) : super(key: key);

  final String userId;

  @override
  _ReceiptScannerScreenState createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ReceiptScannerService _scannerService = ReceiptScannerService();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<BetReceipt>>(
              stream: _scannerService.getReceipts(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Error fetching receipts.',
                    onRetry: () {
                      setState(() {});
                    },
                  );
                } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                  return const EmptyState(message: 'No receipts found.');
                } else {
                  final receipts = snapshot.data!;
                  return ListView.builder(
                    itemCount: receipts.length,
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      return BetReceiptListItem(receipt: receipt);
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PrimaryButton(
              text: 'Scan Receipt',
              onPressed: _scanReceipt,
            ),
          ),
        ],
      ),
    );
  }

  void _scanReceipt() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final newReceipt = BetReceipt(
      id: '', // Firestore will generate this
      bookmaker: 'New Bet',
      betType: 'Single',
      stakeAmount: 20.0,
      odds: 3.0,
      isWin: false,
      dateTime: DateTime.now(),
      selections: [
        BetSelection(
          id: '1',
          event: 'New Event',
          selection: 'New Selection',
          odds: 3.0,
          isWin: false,
        ),
      ],
    );

    await _scannerService.saveReceipt(widget.userId, newReceipt, File(image.path));
  }
}

class BetReceiptListItem extends StatelessWidget {
  const BetReceiptListItem({
    Key? key,
    required this.receipt,
  }) : super(key: key);

  final BetReceipt receipt;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (receipt.imageUrl != null)
              Image.network(receipt.imageUrl!),
            const SizedBox(height: 8),
            Text(
              receipt.bookmaker,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${receipt.betType} - R${receipt.stakeAmount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              receipt.isWin ? 'Won' : 'Lost',
              style: TextStyle(
                color: receipt.isWin ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
