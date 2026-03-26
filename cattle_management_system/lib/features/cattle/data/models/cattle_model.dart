import '../../domain/entities/cattle.dart';

class CattleModel extends Cattle {
  const CattleModel({
    required super.id,
    required super.tagNumber,
    required super.name,
    required super.breed,
    required super.gender,
    required super.dateOfBirth,
    super.color,
    super.weight,
    required super.status,
    super.imageUrl,
    super.acquisitionType,
    super.isLactating,
    super.isHeifer,
    super.isPregnant,
    super.isDryOff,
    super.isRetired,
    required super.createdAt,
    required super.updatedAt,
    super.parity,
    super.lastDeliveryDate,
    super.dailyMilkProduction,
    super.serialNumber,
    super.motherId,
    super.fatherId,
    super.motherName,
    super.fatherName,
    super.dateOfAdult,
    super.deathReason,
    super.deathDate,
    super.cowGroup,
    super.isHandicapped,
    super.handicapReason,
    super.isUdderClosedFL,
    super.isUdderClosedFR,
    super.isUdderClosedBL,
    super.isUdderClosedBR,
    super.purchaseDate,
    super.purchasedFrom,
    super.purchasePrice,
    super.ownerName,
    super.ownerMobile,
    super.retiredDate,
    super.bullType,
    super.bullView,
    super.motherMilk,
    super.grandmotherMilk,
  });

  factory CattleModel.fromJson(Map<String, dynamic> json) {
    final birthDateRaw = json['birthDate'] ??
        json['dateOfBirth'] ??
        json['dob'] ??
        json['birth_date'] ??
        json['date_of_birth'];
    final adultDateRaw = json['adultDate'] ?? json['dateOfAdult'];
    final imageUrlRaw = json['viewUrl'] ??
        json['imageUrl'] ??
        json['photoUrl'] ??
        json['photo'];
    DateTime _parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      final dateStr = val.toString();
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) return parsed;
      // Handle DD/MM/YYYY
      try {
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          return DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
      return DateTime.now();
    }

    return CattleModel(
      id: json['_id'] ?? json['id'] ?? '',
      tagNumber: json['tagNumber'] ?? json['tagno'] ?? json['tagNo'] ?? '',
      name: json['name'] ?? '',
      breed: json['cowBreed'] ?? json['breed'] ?? 'Unknown',
      gender: (json['gender']?.toString().toUpperCase() ?? 'FEMALE'),
      dateOfBirth: _parseDate(birthDateRaw),
      status: (json['status'] ?? json['animalStatus'] ?? 'ACTIVE')
          .toString()
          .toUpperCase(),
      imageUrl: imageUrlRaw?.toString(),
      acquisitionType: json['acquisitionType']?.toString().toUpperCase(),
      isLactating: json['isLactating'] as bool?,
      isHeifer: json['isHeifer'] as bool?,
      isPregnant: json['isPregnant'] as bool?,
      isDryOff: json['isDryOff'] as bool?,
      isRetired: json['isRetired'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
      parity: json['parity'] is int
          ? json['parity']
          : int.tryParse(json['parity']?.toString() ?? ''),
      serialNumber: json['animalNumber']?.toString() ??
          json['serialNumber']?.toString() ??
          json['animalNo']?.toString() ??
          json['number']?.toString(),
      motherId: json['motherId']?.toString(),
      fatherId: json['fatherId']?.toString(),
      motherName: json['motherName']?.toString(),
      fatherName: json['fatherName']?.toString(),
      dateOfAdult: adultDateRaw != null
          ? DateTime.tryParse(adultDateRaw.toString())
          : null,
      deathReason: json['deathReason']?.toString(),
      deathDate: json['deathDate'] != null
          ? DateTime.tryParse(json['deathDate'])
          : null,
      cowGroup: json['cowGroup']?.toString(),
      isHandicapped: json['isHandicapped'] as bool?,
      handicapReason: json['handicapReason'],
      isUdderClosedFL: json['isUdderClosedFL'] as bool?,
      isUdderClosedFR: json['isUdderClosedFR'] as bool?,
      isUdderClosedBL: json['isUdderClosedBL'] as bool?,
      isUdderClosedBR: json['isUdderClosedBR'] as bool?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.tryParse(json['purchaseDate'])
          : null,
      purchasedFrom: json['purchasedFrom'],
      purchasePrice: json['purchasePrice'] != null
          ? double.tryParse(json['purchasePrice'].toString())
          : null,
      ownerName: json['ownerName'],
      ownerMobile: json['ownerMobile'],
      retiredDate: json['retiredDate'] != null
          ? DateTime.tryParse(json['retiredDate'])
          : null,
      bullType: json['bullType']?.toString(),
      bullView: json['bullView']?.toString(),
      motherMilk: json['motherMilk'] != null
          ? double.tryParse(json['motherMilk'].toString())
          : null,
      grandmotherMilk: json['grandmotherMilk'] != null
          ? double.tryParse(json['grandmotherMilk'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty && id != 'NEW_TAG' && id != 'NEW-TAG') 'id': id,
      'tagNumber': tagNumber,
      'name': name,
      'cowBreed': breed,
      'gender': gender.toUpperCase(),
      'birthDate': dateOfBirth.toIso8601String().split('T')[0],
      if (dateOfAdult != null)
        'adultDate': dateOfAdult!.toIso8601String().split('T')[0],
      'status': normalizedStatus, // Enum: ACTIVE, SOLD, DEAD, DONATED
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (serialNumber != null && serialNumber!.isNotEmpty)
        'animalNumber': serialNumber!.toString(),
      if (parity != null) 'parity': parity,
      'acquisitionType': normalizedAcquisitionType,
      if (motherId != null && motherId!.isNotEmpty && motherId != '')
        'motherId': motherId,
      if (fatherId != null && fatherId!.isNotEmpty && fatherId != '')
        'fatherId': fatherId,
      if (motherName != null && motherName!.isNotEmpty)
        'motherName': motherName,
      if (fatherName != null && fatherName!.isNotEmpty)
        'fatherName': fatherName,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'photoUrl': imageUrl,
      if (isLactating != null) 'isLactating': isLactating,
      if (isHeifer != null) 'isHeifer': isHeifer,
      if (isPregnant != null) 'isPregnant': isPregnant,
      if (isDryOff != null) 'isDryOff': isDryOff,
      if (isRetired != null) 'isRetired': isRetired,
      if (deathReason != null) 'deathReason': deathReason,
      if (deathDate != null)
        'deathDate': deathDate!.toIso8601String().split('T')[0],
      if (cowGroup != null) 'cowGroup': cowGroup,
      if (isHandicapped != null) 'isHandicapped': isHandicapped,
      if (handicapReason != null) 'handicapReason': handicapReason,
      if (isUdderClosedFL != null) 'isUdderClosedFL': isUdderClosedFL,
      if (isUdderClosedFR != null) 'isUdderClosedFR': isUdderClosedFR,
      if (isUdderClosedBL != null) 'isUdderClosedBL': isUdderClosedBL,
      if (isUdderClosedBR != null) 'isUdderClosedBR': isUdderClosedBR,
      if (purchaseDate != null)
        'purchaseDate': purchaseDate!.toIso8601String().split('T')[0],
      if (purchasedFrom != null) 'purchasedFrom': purchasedFrom,
      if (purchasePrice != null) 'purchasePrice': purchasePrice,
      if (ownerName != null) 'ownerName': ownerName,
      if (ownerMobile != null) 'ownerMobile': ownerMobile,
      if (retiredDate != null)
        'retiredDate': retiredDate!.toIso8601String().split('T')[0],
      if (normalizedBullType != null) 'bullType': normalizedBullType,
      if (normalizedBullView != null) 'bullView': normalizedBullView,
      if (motherMilk != null) 'motherMilk': motherMilk,
      if (grandmotherMilk != null) 'grandmotherMilk': grandmotherMilk,
    };
  }
}
