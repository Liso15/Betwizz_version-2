import 'package:flutter/material.dart';
import '../../core/services/receipt_scanner_service.dart';
import '../../models/bet_receipt.dart';
import '../../design_system/app_components.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({Key? key}) : super(key: key);

  @override
  _ReceiptScannerScreenState createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  final ReceiptScannerService _scannerService = ReceiptScannerService();
  late Future<List<BetReceipt>> _receiptsFuture;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = _scannerService.getReceipts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<BetReceipt>>(
              future: _receiptsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator();
                } else if (snapshot.hasError) {
                  return ErrorState(
                    message: 'Error fetching receipts.',
                    onRetry: () {
                      setState(() {
                        _receiptsFuture = _scannerService.getReceipts();
                      });
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
    final newReceipt = await _scannerService.scanReceipt();
    setState(() {
      _receiptsFuture.then((receipts) => receipts.add(newReceipt));
    });
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
