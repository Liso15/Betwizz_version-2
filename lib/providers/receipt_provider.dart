import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/bet_receipt.dart';

final receiptsProvider = AsyncNotifierProvider<ReceiptsNotifier, List<BetReceipt>>(
  () => ReceiptsNotifier(),
);

class ReceiptsNotifier extends AsyncNotifier<List<BetReceipt>> {
  final List<BetReceipt> _receipts = [];
  final Uuid _uuid = const Uuid();

  @override
  Future<List<BetReceipt>> build() async {
    // Initialize with mock data
    _receipts.addAll(_getMockReceipts());
    return _receipts;
  }

  Future<void> addReceipt(BetReceipt receipt) async {
    _receipts.insert(0, receipt);
    state = AsyncValue.data(List.from(_receipts));
  }

  Future<void> updateReceipt(BetReceipt updatedReceipt) async {
    final index = _receipts.indexWhere((r) => r.id == updatedReceipt.id);
    if (index != -1) {
      _receipts[index] = updatedReceipt;
      state = AsyncValue.data(List.from(_receipts));
    }
  }

  Future<void> deleteReceipt(String receiptId) async {
    _receipts.removeWhere((r) => r.id == receiptId);
    state = AsyncValue.data(List.from(_receipts));
  }

  Future<BetReceipt> scanReceipt(String imagePath) async {
    // Simulate OCR processing
    await Future.delayed(const Duration(seconds: 2));
    
    // Create mock receipt from "scanned" image
    final receipt = BetReceipt(
      id: _uuid.v4(),
      bookmaker: 'Betway',
      betType: 'Single',
      stakeAmount: 50.0,
      odds: 2.5,
      winAmount: null,
      isWin: false,
      dateTime: DateTime.now(),
      imageUrl: imagePath,
      description: 'Manchester United vs Arsenal - Manchester United to Win',
      selections: [
        BetSelection(
          id: _uuid.v4(),
          event: 'Manchester United vs Arsenal',
          selection: 'Manchester United to Win',
          odds: 2.5,
        ),
      ],
      status: ReceiptStatus.pending,
      referenceNumber: 'BW${DateTime.now().millisecondsSinceEpoch}',
    );

    await addReceipt(receipt);
    return receipt;
  }

  List<BetReceipt> _getMockReceipts() {
    return [
      BetReceipt(
        id: '1',
        bookmaker: 'Betway',
        betType: 'Accumulator',
        stakeAmount: 100.0,
        odds: 4.5,
        winAmount: 450.0,
        isWin: true,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        description: '4-fold accumulator - Premier League matches',
        selections: [
          BetSelection(
            id: '1a',
            event: 'Chelsea vs Liverpool',
            selection: 'Over 2.5 Goals',
            odds: 1.8,
            result: 'Won',
            isWin: true,
          ),
          BetSelection(
            id: '1b',
            event: 'Manchester City vs Arsenal',
            selection: 'Manchester City to Win',
            odds: 1.5,
            result: 'Won',
            isWin: true,
          ),
        ],
        status: ReceiptStatus.settled,
        referenceNumber: 'BW123456789',
      ),
      BetReceipt(
        id: '2',
        bookmaker: 'Hollywood Bets',
        betType: 'Single',
        stakeAmount: 25.0,
        odds: 3.2,
        winAmount: null,
        isWin: false,
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        description: 'Tottenham vs Newcastle - Tottenham to Win',
        selections: [
          BetSelection(
            id: '2a',
            event: 'Tottenham vs Newcastle',
            selection: 'Tottenham to Win',
            odds: 3.2,
            result: 'Lost',
            isWin: false,
          ),
        ],
        status: ReceiptStatus.settled,
        referenceNumber: 'HB987654321',
      ),
      BetReceipt(
        id: '3',
        bookmaker: 'Supabets',
        betType: 'Double',
        stakeAmount: 75.0,
        odds: 6.0,
        winAmount: null,
        isWin: false,
        dateTime: DateTime.now().subtract(const Duration(hours: 6)),
        description: 'Double bet - La Liga matches',
        selections: [
          BetSelection(
            id: '3a',
            event: 'Real Madrid vs Barcelona',
            selection: 'Real Madrid to Win',
            odds: 2.0,
            result: 'Won',
            isWin: true,
          ),
          BetSelection(
            id: '3b',
            event: 'Atletico Madrid vs Valencia',
            selection: 'Under 2.5 Goals',
            odds: 3.0,
            result: 'Lost',
            isWin: false,
          ),
        ],
        status: ReceiptStatus.settled,
        referenceNumber: 'SB456789123',
      ),
    ];
  }

  double get totalStaked {
    return _receipts.fold(0.0, (sum, receipt) => sum + receipt.stakeAmount);
  }

  double get totalWinnings {
    return _receipts.fold(0.0, (sum, receipt) => sum + (receipt.winAmount ?? 0.0));
  }

  double get totalProfit {
    return totalWinnings - totalStaked;
  }

  int get totalBets => _receipts.length;

  int get winningBets => _receipts.where((r) => r.isWin).length;

  double get winRate => totalBets > 0 ? (winningBets / totalBets) * 100 : 0.0;
}

// Legacy provider for backward compatibility
class ReceiptProvider extends ChangeNotifier {
  final List<BetReceipt> _receipts = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  List<BetReceipt> get receipts => _receipts;
  bool get isLoading => _isLoading;

  ReceiptProvider() {
    _loadMockReceipts();
  }

  void _loadMockReceipts() {
    _receipts.addAll([
      BetReceipt(
        id: '1',
        bookmaker: 'Betway',
        betType: 'Single',
        stakeAmount: 50.0,
        odds: 2.5,
        winAmount: 125.0,
        isWin: true,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        description: 'Manchester United to Win',
        selections: [],
        status: ReceiptStatus.settled,
      ),
    ]);
    notifyListeners();
  }

  Future<void> scanReceipt() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    final receipt = BetReceipt(
      id: _uuid.v4(),
      bookmaker: 'Betway',
      betType: 'Single',
      stakeAmount: 50.0,
      odds: 2.5,
      winAmount: null,
      isWin: false,
      dateTime: DateTime.now(),
      description: 'Scanned receipt',
      selections: [],
      status: ReceiptStatus.pending,
    );

    _receipts.insert(0, receipt);
    _isLoading = false;
    notifyListeners();
  }
}
