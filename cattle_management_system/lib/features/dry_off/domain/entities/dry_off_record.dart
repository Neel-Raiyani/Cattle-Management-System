class DryOffRecord {
  final String id;
  final String animalId;
  final String cowName;
  final String cowTagNumber;
  final String cowSerialNumber;
  final String? cowImageUrl;
  final DateTime dryOffDate;
  final String reason;
  final String? remarks;
  final bool isPregnant;

  const DryOffRecord({
    required this.id,
    required this.animalId,
    required this.cowName,
    required this.cowTagNumber,
    required this.cowSerialNumber,
    this.cowImageUrl,
    required this.dryOffDate,
    required this.reason,
    this.remarks,
    required this.isPregnant,
  });

  DryOffRecord copyWith({
    String? id,
    String? animalId,
    String? cowName,
    String? cowTagNumber,
    String? cowSerialNumber,
    String? cowImageUrl,
    DateTime? dryOffDate,
    String? reason,
    String? remarks,
    bool? isPregnant,
  }) {
    return DryOffRecord(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      cowName: cowName ?? this.cowName,
      cowTagNumber: cowTagNumber ?? this.cowTagNumber,
      cowSerialNumber: cowSerialNumber ?? this.cowSerialNumber,
      cowImageUrl: cowImageUrl ?? this.cowImageUrl,
      dryOffDate: dryOffDate ?? this.dryOffDate,
      reason: reason ?? this.reason,
      remarks: remarks ?? this.remarks,
      isPregnant: isPregnant ?? this.isPregnant,
    );
  }

  factory DryOffRecord.fromJson(Map<String, dynamic> json) {
    final animal = json['animal'] as Map<String, dynamic>?;
    return DryOffRecord(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      animalId:
          json['animalId']?.toString() ??
          animal?['id']?.toString() ??
          animal?['_id']?.toString() ??
          '',
      cowName:
          animal?['name']?.toString() ??
          json['animalName']?.toString() ??
          json['name']?.toString() ??
          'Unknown',
      cowTagNumber:
          animal?['tagNumber']?.toString() ??
          json['tagNumber']?.toString() ??
          json['tagNo']?.toString() ??
          '-',
      cowSerialNumber:
          animal?['serialNumber']?.toString() ??
          json['serialNumber']?.toString() ??
          json['animalNumber']?.toString() ??
          '-',
      cowImageUrl:
          animal?['photoUrl']?.toString() ??
          animal?['imageUrl']?.toString() ??
          json['photoUrl']?.toString() ??
          json['imageUrl']?.toString(),
      dryOffDate: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      reason: json['reason']?.toString() ?? 'OTHER',
      remarks: json['remarks']?.toString(),
      isPregnant:
          json['isPregnant'] == true ||
          animal?['isPregnant'] == true ||
          json['pregnancyStatus']?.toString().toLowerCase() == 'pregnant',
    );
  }
}
