class AnimalLeftRecord {
  final String id;
  final String cowName;
  final String cowTagNumber;
  final String cowSerialNumber;
  final String? cowImageUrl;
  final String recordType; // 'Sell' | 'Death' | 'Donation'
  final DateTime date;
  final String? buyerOrDoneeName; // Sell / Donation
  final String? amount;           // Sell
  final String? cause;            // Death
  final String? note;
  final DateTime createdAt;

  const AnimalLeftRecord({
    required this.id,
    required this.cowName,
    required this.cowTagNumber,
    required this.cowSerialNumber,
    this.cowImageUrl,
    required this.recordType,
    required this.date,
    this.buyerOrDoneeName,
    this.amount,
    this.cause,
    this.note,
    required this.createdAt,
  });
}
