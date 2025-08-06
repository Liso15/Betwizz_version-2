import '../../models/bet_receipt.dart';
import '../mock/mock_data.dart';

class ReceiptScannerService {
  Future<List<BetReceipt>> getReceipts() async {
    // TODO: Replace with backend implementation
    await Future.delayed(const Duration(seconds: 1));
    return MockData.receipts;
  }

  Future<BetReceipt> scanReceipt() async {
    // TODO: Replace with real OCR implementation
    await Future.delayed(const Duration(seconds: 2));
    final newReceipt = BetReceipt(
      id: (MockData.receipts.length + 1).toString(),
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
    MockData.receipts.add(newReceipt);
    return newReceipt;
  }
}
