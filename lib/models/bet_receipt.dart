class BetReceipt {
  final String id;
  final String bookmaker;
  final String betType;
  final double stakeAmount;
  final double odds;
  final bool isWin;
  final double? winAmount;
  final DateTime dateTime;
  final String? imageUrl;
  final Map<String, dynamic> rawData;

  BetReceipt({
    required this.id,
    required this.bookmaker,
    required this.betType,
    required this.stakeAmount,
    required this.odds,
    required this.isWin,
    this.winAmount,
    required this.dateTime,
    this.imageUrl,
    required this.rawData,
  });

  factory BetReceipt.fromJson(Map<String, dynamic> json) {
    return BetReceipt(
      id: json['id'],
      bookmaker: json['bookmaker'],
      betType: json['betType'],
      stakeAmount: (json['stakeAmount']).toDouble(),
      odds: (json['odds']).toDouble(),
      isWin: json['isWin'],
      winAmount: json['winAmount']?.toDouble(),
      dateTime: DateTime.parse(json['dateTime']),
      imageUrl: json['imageUrl'],
      rawData: json['rawData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookmaker': bookmaker,
      'betType': betType,
      'stakeAmount': stakeAmount,
      'odds': odds,
      'isWin': isWin,
      'winAmount': winAmount,
      'dateTime': dateTime.toIso8601String(),
      'imageUrl': imageUrl,
      'rawData': rawData,
    };
  }
}
