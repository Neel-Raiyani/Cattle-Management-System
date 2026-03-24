
class HeatRecord {
  final String id;
  final String cowName;
  final String cowTagNumber;
  final String cowSerialNumber;
  final String? cowImageUrl;
  final int parity;
  final bool isConceived; // true = Conceived, false = Not Conceived
  final DateTime heatDate;
  final String? note;
  final String? animalId;
  final DateTime createdAt;

  const HeatRecord({
    required this.id,
    required this.cowName,
    required this.cowTagNumber,
    required this.cowSerialNumber,
    this.cowImageUrl,
    required this.parity,
    required this.isConceived,
    required this.heatDate,
    this.note,
    this.animalId,
    required this.createdAt,
  });

  HeatRecord copyWith({
    String? id,
    String? cowName,
    String? cowTagNumber,
    String? cowSerialNumber,
    String? cowImageUrl,
    int? parity,
    bool? isConceived,
    DateTime? heatDate,
    String? note,
    String? animalId,
    DateTime? createdAt,
  }) {
    return HeatRecord(
      id: id ?? this.id,
      cowName: cowName ?? this.cowName,
      cowTagNumber: cowTagNumber ?? this.cowTagNumber,
      cowSerialNumber: cowSerialNumber ?? this.cowSerialNumber,
      cowImageUrl: cowImageUrl ?? this.cowImageUrl,
      parity: parity ?? this.parity,
      isConceived: isConceived ?? this.isConceived,
      heatDate: heatDate ?? this.heatDate,
      note: note ?? this.note,
      animalId: animalId ?? this.animalId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HeatRecord.fromJson(Map<String, dynamic> json) {
    // Handle nested animal object if it exists
    final animal = json['animalId'] is Map ? json['animalId'] : json['animal'];

    // Try root level fields first (common in report endpoints), then nested
    final String name = json['name'] ??
        json['animalName'] ??
        (animal is Map ? animal['name'] : null) ??
        'Unknown';
    final String tag = json['tagno'] ??
        json['tagNumber'] ??
        (animal is Map ? animal['tagNumber'] : null) ??
        'N/A';
    final String serial = json['cowNo'] ??
        json['animalNumber'] ??
        json['serialNumber'] ??
        (animal is Map ? (animal['animalNumber'] ?? animal['serialNumber']) : null) ??
        'N/A';
    final String? img = json['photo'] ??
        json['imageUrl'] ??
        json['photoUrl'] ??
        (animal is Map ? (animal['imageUrl'] ?? animal['photoUrl']) : null);

    // Some endpoints return 'pregnancyType' or 'breedingType' instead of 'isBreed'
    bool conceived = json['isBreed'] ?? false;
    if (json.containsKey('pregnancyType') || json.containsKey('breedingType')) {
      conceived = true; // If a type is specified, it was bred
    }

    // Try every possible ID field the backend might use.
    // The debug log will show the first item keys so we can confirm which one is correct.
    final String recordId = json['_id']?.toString() ??
        json['id']?.toString() ??
        json['heatId']?.toString() ??
        json['recordId']?.toString() ??
        json['breedingId']?.toString() ??
        (json['heat'] is Map
            ? (json['heat']['_id'] ?? json['heat']['id'])?.toString()
            : null) ??
        (json['record'] is Map
            ? (json['record']['_id'] ?? json['record']['id'])?.toString()
            : null) ??
        '';

    // Extract animalId — try many possible structures
    final String? animalIdValue = (json['animalId'] is String ? json['animalId'] as String : null)
        ?? (animal is Map ? (animal['_id'] ?? animal['id'])?.toString() : null)
        ?? json['cowId']?.toString()
        ?? json['animal_id']?.toString();

    return HeatRecord(
      id: recordId,
      cowName: name,
      cowTagNumber: tag,
      cowSerialNumber: serial,
      cowImageUrl: img,
      parity: json['parity'] ?? 0,
      isConceived: conceived,
      heatDate: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      note: json['notes'] ?? json['note'],
      animalId: animalIdValue,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
