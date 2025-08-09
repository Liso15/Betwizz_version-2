import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bet_receipt.dart';
import '../../providers/receipt_provider.dart';

class ReceiptScannerScreen extends ConsumerStatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  ConsumerState<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends ConsumerState<ReceiptScannerScreen> {
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
  final receiptsAsync = ref.watch(receiptsProvider);
  debugPrint('ReceiptScannerScreen: receiptsAsync state = ' + receiptsAsync.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Show receipt history
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner area
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: _isScanning
                  ? _buildScanningView()
                  : _buildScannerPlaceholder(),
            ),
          ),
          // Recent receipts
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Scans',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: receiptsAsync.when(
                      data: (receipts) => _buildReceiptsList(receipts),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) {
                        debugPrint('ReceiptScannerScreen: error loading receipts: $error');
                        return Center(
                          child: Text('Error: $error'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startScanning,
        icon: Icon(_isScanning ? Icons.stop : Icons.camera_alt),
        label: Text(_isScanning ? 'Stop Scan' : 'Scan Receipt'),
      ),
    );
  }

  Widget _buildScannerPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Tap to scan your betting receipt',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Supports Betway, Hollywood Bets, and more',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningView() {
    return Stack(
      children: [
        // Camera preview placeholder
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black87,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera, size: 48, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Camera Preview',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  'Firebase ML Kit OCR integration',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        // Scanning overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Processing indicator
        const Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  CircularProgressIndicator(strokeWidth: 2),
                  SizedBox(width: 12),
                  Text('Processing receipt...'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptsList(List<BetReceipt> receipts) {
    if (receipts.isEmpty) {
      return const Center(
        child: Text(
          'No receipts scanned yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: receipts.length,
      itemBuilder: (context, index) {
        final receipt = receipts[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: receipt.isWin ? Colors.green : Colors.red,
              child: Icon(
                receipt.isWin ? Icons.check : Icons.close,
                color: Colors.white,
              ),
            ),
            title: Text(receipt.bookmaker),
            subtitle: Text(
              'R${receipt.stakeAmount.toStringAsFixed(2)} • ${receipt.betType}',
            ),
            trailing: Text(
              receipt.isWin 
                  ? '+R${receipt.winAmount?.toStringAsFixed(2) ?? '0.00'}'
                  : '-R${receipt.stakeAmount.toStringAsFixed(2)}',
              style: TextStyle(
                color: receipt.isWin ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showReceiptDetails(receipt),
          ),
        );
      },
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = !_isScanning;
    });

    if (_isScanning) {
      // Simulate scanning process
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isScanning) {
          setState(() {
            _isScanning = false;
          });
          _showScanResult();
        }
      });
    }
  }

  void _showScanResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Complete'),
        content: const Text('Receipt processed successfully!\n\nBetway slip detected:\nR50.00 stake on Manchester United vs Arsenal'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showReceiptDetails(BetReceipt receipt) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${receipt.bookmaker} Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bet Type: ${receipt.betType}'),
            Text('Stake: R${receipt.stakeAmount.toStringAsFixed(2)}'),
            Text('Odds: ${receipt.odds}'),
            if (receipt.isWin && receipt.winAmount != null)
              Text('Win Amount: R${receipt.winAmount!.toStringAsFixed(2)}'),
            Text('Date: ${receipt.dateTime.toString().split(' ')[0]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
