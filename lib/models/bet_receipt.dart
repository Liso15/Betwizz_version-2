class BetReceipt {
  final String id;
  final String bookmaker;
  final String betType;
  final double stakeAmount;
  final double odds;
  final double? winAmount;
  final bool isWin;
  final DateTime dateTime;
  final String? imageUrl;
  final String? description;
  final List<BetSelection> selections;
  final ReceiptStatus status;
  final String? referenceNumber;
  final Map<String, dynamic>? metadata;

  BetReceipt({
    required this.id,
    required this.bookmaker,
    required this.betType,
    required this.stakeAmount,
    required this.odds,
    this.winAmount,
    required this.isWin,
    required this.dateTime,
    this.imageUrl,
    this.description,
    required this.selections,
    this.status = ReceiptStatus.pending,
    this.referenceNumber,
    this.metadata,
  });

  factory BetReceipt.fromJson(Map<String, dynamic> json) {
    return BetReceipt(
      id: json['id'] as String,
      bookmaker: json['bookmaker'] as String,
      betType: json['betType'] as String,
      stakeAmount: (json['stakeAmount'] as num).toDouble(),
      odds: (json['odds'] as num).toDouble(),
      winAmount: json['winAmount'] != null 
          ? (json['winAmount'] as num).toDouble()
          : null,
      isWin: json['isWin'] as bool,
      dateTime: DateTime.parse(json['dateTime'] as String),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      selections: (json['selections'] as List)
          .map((e) => BetSelection.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: ReceiptStatus.values.firstWhere(
        (e) => e.toString() == 'ReceiptStatus.${json['status']}',
        orElse: () => ReceiptStatus.pending,
      ),
      referenceNumber: json['referenceNumber'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookmaker': bookmaker,
      'betType': betType,
      'stakeAmount': stakeAmount,
      'odds': odds,
      'winAmount': winAmount,
      'isWin': isWin,
      'dateTime': dateTime.toIso8601String(),
      'imageUrl': imageUrl,
      'description': description,
      'selections': selections.map((e) => e.toJson()).toList(),
      'status': status.toString().split('.').last,
      'referenceNumber': referenceNumber,
      'metadata': metadata,
    };
  }

  double get potentialWin => stakeAmount * odds;

  double get profit => isWin ? (winAmount ?? 0) - stakeAmount : -stakeAmount;

  BetReceipt copyWith({
    String? id,
    String? bookmaker,
    String? betType,
    double? stakeAmount,
    double? odds,
    double? winAmount,
    bool? isWin,
    DateTime? dateTime,
    String? imageUrl,
    String? description,
    List<BetSelection>? selections,
    ReceiptStatus? status,
    String? referenceNumber,
    Map<String, dynamic>? metadata,
  }) {
    return BetReceipt(
      id: id ?? this.id,
      bookmaker: bookmaker ?? this.bookmaker,
      betType: betType ?? this.betType,
      stakeAmount: stakeAmount ?? this.stakeAmount,
      odds: odds ?? this.odds,
      winAmount: winAmount ?? this.winAmount,
      isWin: isWin ?? this.isWin,
      dateTime: dateTime ?? this.dateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      selections: selections ?? this.selections,
      status: status ?? this.status,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'BetReceipt(id: $id, bookmaker: $bookmaker, stakeAmount: $stakeAmount, isWin: $isWin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BetReceipt && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class BetSelection {
  final String id;
  final String event;
  final String selection;
  final double odds;
  final String? result;
  final bool? isWin;

  BetSelection({
    required this.id,
    required this.event,
    required this.selection,
    required this.odds,
    this.result,
    this.isWin,
  });

  factory BetSelection.fromJson(Map<String, dynamic> json) {
    return BetSelection(
      id: json['id'] as String,
      event: json['event'] as String,
      selection: json['selection'] as String,
      odds: (json['odds'] as num).toDouble(),
      result: json['result'] as String?,
      isWin: json['isWin'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event': event,
      'selection': selection,
      'odds': odds,
      'result': result,
      'isWin': isWin,
    };
  }

  @override
  String toString() {
    return 'BetSelection(event: $event, selection: $selection, odds: $odds)';
  }
}

enum ReceiptStatus {
  pending,
  verified,
  settled,
  cancelled,
  error,
}
