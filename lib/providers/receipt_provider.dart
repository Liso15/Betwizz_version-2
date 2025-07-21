import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bet_receipt.dart';

final receiptsProvider = FutureProvider<List<BetReceipt>>((ref) async {
  // Simulate API call delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Mock data for demonstration
  return [
    BetReceipt(
      id: '1',
      bookmaker: 'Betway',
      betType: 'Single Bet',
      stakeAmount: 50.0,
      odds: 2.5,
      isWin: true,
      winAmount: 125.0,
      dateTime: DateTime.now().subtract(const Duration(hours: 2)),
      rawData: {'match': 'Manchester United vs Arsenal'},
    ),
    BetReceipt(
      id: '2',
      bookmaker: 'Hollywood Bets',
      betType: 'Accumulator',
      stakeAmount: 25.0,
      odds: 4.2,
      isWin: false,
      dateTime: DateTime.now().subtract(const Duration(days: 1)),
      rawData: {'matches': ['Chelsea vs Liverpool', 'City vs Spurs']},
    ),
    BetReceipt(
      id: '3',
      bookmaker: 'Supabets',
      betType: 'Over/Under',
      stakeAmount: 100.0,
      odds: 1.8,
      isWin: true,
      winAmount: 180.0,
      dateTime: DateTime.now().subtract(const Duration(days: 3)),
      rawData: {'match': 'Kaizer Chiefs vs Orlando Pirates', 'total_goals': 'Over 2.5'},
    ),
  ];
});

class ReceiptNotifier extends StateNotifier<List<BetReceipt>> {
  ReceiptNotifier() : super([]);

  void addReceipt(BetReceipt receipt) {
    state = [receipt, ...state];
  }

  void removeReceipt(String receiptId) {
    state = state.where((receipt) => receipt.id != receiptId).toList();
  }
}

final receiptNotifierProvider = StateNotifierProvider<ReceiptNotifier, List<BetReceipt>>((ref) {
  return ReceiptNotifier();
});
