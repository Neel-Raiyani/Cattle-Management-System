class ConceptionRecord {
  final String id;
  final String? cowId;
  final String cowName;
  final String cowTagNumber;
  final String cowSerialNumber;
  final String? cowImageUrl;
  final String pregnancyType; // 'Natural' or 'AI'
  final String? bullName;
  final String? bullTagNumber;
  final String? bullNumber;
  final String? serialNumber; // AI only
  final String? companyName; // AI only
  final int parity;
  final DateTime conceiveDate;
  final String pregnancyStatus; // 'Pregnant', 'Pregnancy Check Pending'
  final bool isPregnant;
  final bool isDryOff;
  final bool isDelivered;

  const ConceptionRecord({
    required this.id,
    this.cowId,
    required this.cowName,
    required this.cowTagNumber,
    required this.cowSerialNumber,
    this.cowImageUrl,
    required this.pregnancyType,
    this.bullName,
    this.bullTagNumber,
    this.bullNumber,
    this.serialNumber,
    this.companyName,
    required this.parity,
    required this.conceiveDate,
    required this.pregnancyStatus,
    required this.isPregnant,
    required this.isDryOff,
    required this.isDelivered,
  });

  // Computed dates
  DateTime get pregnantDate => conceiveDate.add(const Duration(days: 32));
  DateTime get dryOffDate => conceiveDate.add(const Duration(days: 195));
  DateTime get deliveryDate => conceiveDate.add(const Duration(days: 270));

  int get daysSinceConception => DateTime.now().difference(conceiveDate).inDays;

  ConceptionRecord copyWith({
    String? id,
    String? cowId,
    String? cowName,
    String? cowTagNumber,
    String? cowSerialNumber,
    String? cowImageUrl,
    String? pregnancyType,
    String? bullName,
    String? bullTagNumber,
    String? bullNumber,
    String? serialNumber,
    String? companyName,
    int? parity,
    DateTime? conceiveDate,
    String? pregnancyStatus,
    bool? isPregnant,
    bool? isDryOff,
    bool? isDelivered,
  }) {
    return ConceptionRecord(
      id: id ?? this.id,
      cowId: cowId ?? this.cowId,
      cowName: cowName ?? this.cowName,
      cowTagNumber: cowTagNumber ?? this.cowTagNumber,
      cowSerialNumber: cowSerialNumber ?? this.cowSerialNumber,
      cowImageUrl: cowImageUrl ?? this.cowImageUrl,
      pregnancyType: pregnancyType ?? this.pregnancyType,
      bullName: bullName ?? this.bullName,
      bullTagNumber: bullTagNumber ?? this.bullTagNumber,
      bullNumber: bullNumber ?? this.bullNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      companyName: companyName ?? this.companyName,
      parity: parity ?? this.parity,
      conceiveDate: conceiveDate ?? this.conceiveDate,
      pregnancyStatus: pregnancyStatus ?? this.pregnancyStatus,
      isPregnant: isPregnant ?? this.isPregnant,
      isDryOff: isDryOff ?? this.isDryOff,
      isDelivered: isDelivered ?? this.isDelivered,
    );
  }

  factory ConceptionRecord.fromJson(Map<String, dynamic> json) {
    final animal = _readMap(
      json['animal'],
    ) ??
        _readMap(json['animalId']) ??
        _readMap(json['cow']) ??
        <String, dynamic>{};
    final bull = _readMap(json['bull']) ?? _readMap(json['bullId']) ?? <String, dynamic>{};
    final stage = json['currentStage']?.toString().toUpperCase();
    final status = json['status']?.toString();
    final statusUpper = status?.toUpperCase();
    final hasDeliveryMarkers =
        json['deliveryDate'] != null ||
        json['deliveredAt'] != null ||
        json['actualDeliveryDate'] != null ||
        json['calfStatus'] != null;
    final delivered = json['isDelivered'] == true ||
        stage == 'DELIVERED' ||
        stage == 'COMPLETED' ||
        stage == 'CLOSED' ||
        statusUpper == 'DELIVERED' ||
        statusUpper == 'COMPLETED' ||
        statusUpper == 'CLOSED' ||
        hasDeliveryMarkers;

    return ConceptionRecord(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      cowId: (animal['_id'] ?? animal['id'] ?? json['animalId'])?.toString(),
      cowName: (animal['name'] ?? animal['animalName'] ?? 'Unknown Cow').toString(),
      cowTagNumber: (animal['tagNumber'] ?? '-').toString(),
      cowSerialNumber: (animal['serialNumber'] ?? animal['animalNumber'] ?? '-').toString(),
      cowImageUrl: (animal['viewUrl'] ?? animal['photoUrl'])?.toString(),
      pregnancyType: _normalizePregnancyType(json['pregnancyType']?.toString()),
      bullName: bull['name']?.toString(),
      bullTagNumber: bull['tagNumber']?.toString(),
      bullNumber: (bull['serialNumber'] ?? bull['animalNumber'])?.toString(),
      serialNumber: json['serialNumber'],
      companyName: json['companyName'],
      parity: json['parity'] is int
          ? json['parity'] as int
          : int.tryParse(json['parity']?.toString() ?? '') ?? 0,
      conceiveDate: json['conceiveDate'] != null
          ? DateTime.parse(json['conceiveDate'])
          : DateTime.now(),
      pregnancyStatus: status ??
          (stage == 'PD_CONFIRMED'
              ? 'Pregnant'
              : 'Pregnancy Check Pending'),
      isPregnant:
          !delivered &&
          (json['isPregnant'] == true || stage == 'PD_CONFIRMED'),
      isDryOff: json['isDryOff'] == true || stage == 'DRY_OFF',
      isDelivered: delivered,
    );
  }

  static Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String _normalizePregnancyType(String? value) {
    final normalized = value?.toUpperCase();
    if (normalized == 'AI') return 'AI';
    if (normalized == 'NATURAL' || normalized == 'GAUSHALA') return 'Natural';
    return value == null || value.isEmpty ? 'Natural' : value;
  }
}
