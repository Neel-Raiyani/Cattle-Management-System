import 'package:equatable/equatable.dart';

/// Cattle Entity (Domain Layer)
class Cattle extends Equatable {
  final String id;
  final String tagNumber;
  final String name;
  final String breed;
  final String gender;
  final DateTime dateOfBirth;
  final String? color;
  final double? weight;
  final String status; // ACTIVE, SOLD, DEAD, DONATED
  final String? imageUrl;
  final String? acquisitionType;
  // Boolean status flags from API
  final bool? isLactating;
  final bool? isHeifer;
  final bool? isPregnant;
  final bool? isDryOff;
  final bool? isRetired;
  final DateTime createdAt;
  final DateTime updatedAt;

  final int? parity;
  final DateTime? lastDeliveryDate;
  final double? dailyMilkProduction;
  final String? serialNumber;

  final String? motherId;
  final String? fatherId;
  final String? motherName;
  final String? fatherName;
  final DateTime? dateOfAdult;
  final String? deathReason;
  final DateTime? deathDate;

  final String? cowGroup;
  final bool? isHandicapped;
  final String? handicapReason;
  // Udder status
  final bool? isUdderClosedFL;
  final bool? isUdderClosedFR;
  final bool? isUdderClosedBL;
  final bool? isUdderClosedBR;
  // Purchase info
  final DateTime? purchaseDate;
  final String? purchasedFrom;
  final double? purchasePrice;
  final String? ownerName;
  final String? ownerMobile;
  // Others
  final DateTime? retiredDate;
  final String? bullView; // For Bulls
  final double? motherMilk;
  final double? grandmotherMilk;

  const Cattle({
    required this.id,
    required this.tagNumber,
    required this.name,
    required this.breed,
    required this.gender,
    required this.dateOfBirth,
    this.color,
    this.weight,
    required this.status,
    this.imageUrl,
    this.acquisitionType,
    this.isLactating,
    this.isHeifer,
    this.isPregnant,
    this.isDryOff,
    this.isRetired,
    required this.createdAt,
    required this.updatedAt,
    this.parity,
    this.lastDeliveryDate,
    this.dailyMilkProduction,
    this.serialNumber,
    this.motherId,
    this.fatherId,
    this.motherName,
    this.fatherName,
    this.dateOfAdult,
    this.deathReason,
    this.deathDate,
    this.cowGroup,
    this.isHandicapped,
    this.handicapReason,
    this.isUdderClosedFL,
    this.isUdderClosedFR,
    this.isUdderClosedBL,
    this.isUdderClosedBR,
    this.purchaseDate,
    this.purchasedFrom,
    this.purchasePrice,
    this.ownerName,
    this.ownerMobile,
    this.retiredDate,
    this.bullView,
    this.motherMilk,
    this.grandmotherMilk,
  });

  int get ageInMonths {
    final now = DateTime.now();
    int months = (now.year - dateOfBirth.year) * 12;
    months += now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) {
      months--;
    }
    return months;
  }

  int get ageInYears {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  bool get isTerminalStatus {
    final normalized = status.toUpperCase();
    return normalized == 'SOLD' ||
        normalized == 'DEAD' ||
        normalized == 'DONATED';
  }

  bool get isActive => !isTerminalStatus && isRetired != true;

  String get displayAge {
    final years = ageInYears;
    final months = ageInMonths % 12;

    if (years > 0) {
      return months > 0 ? '$years yr $months mo' : '$years yr';
    } else {
      return '$months mo';
    }
  }

  Cattle copyWith({
    String? id,
    String? tagNumber,
    String? name,
    String? breed,
    String? gender,
    DateTime? dateOfBirth,
    String? color,
    double? weight,
    String? status,
    String? imageUrl,
    String? acquisitionType,
    bool? isLactating,
    bool? isHeifer,
    bool? isPregnant,
    bool? isDryOff,
    bool? isRetired,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? parity,
    DateTime? lastDeliveryDate,
    double? dailyMilkProduction,
    String? serialNumber,
    String? motherId,
    String? fatherId,
    String? motherName,
    String? fatherName,
    DateTime? dateOfAdult,
    String? deathReason,
    DateTime? deathDate,
    String? cowGroup,
    bool? isHandicapped,
    String? handicapReason,
    bool? isUdderClosedFL,
    bool? isUdderClosedFR,
    bool? isUdderClosedBL,
    bool? isUdderClosedBR,
    DateTime? purchaseDate,
    String? purchasedFrom,
    double? purchasePrice,
    String? ownerName,
    String? ownerMobile,
    DateTime? retiredDate,
    String? bullView,
    double? motherMilk,
    double? grandmotherMilk,
  }) {
    return Cattle(
      id: id ?? this.id,
      tagNumber: tagNumber ?? this.tagNumber,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      acquisitionType: acquisitionType ?? this.acquisitionType,
      isLactating: isLactating ?? this.isLactating,
      isHeifer: isHeifer ?? this.isHeifer,
      isPregnant: isPregnant ?? this.isPregnant,
      isDryOff: isDryOff ?? this.isDryOff,
      isRetired: isRetired ?? this.isRetired,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      parity: parity ?? this.parity,
      lastDeliveryDate: lastDeliveryDate ?? this.lastDeliveryDate,
      dailyMilkProduction: dailyMilkProduction ?? this.dailyMilkProduction,
      serialNumber: serialNumber ?? this.serialNumber,
      motherId: motherId ?? this.motherId,
      fatherId: fatherId ?? this.fatherId,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      dateOfAdult: dateOfAdult ?? this.dateOfAdult,
      deathReason: deathReason ?? this.deathReason,
      deathDate: deathDate ?? this.deathDate,
      cowGroup: cowGroup ?? this.cowGroup,
      isHandicapped: isHandicapped ?? this.isHandicapped,
      handicapReason: handicapReason ?? this.handicapReason,
      isUdderClosedFL: isUdderClosedFL ?? this.isUdderClosedFL,
      isUdderClosedFR: isUdderClosedFR ?? this.isUdderClosedFR,
      isUdderClosedBL: isUdderClosedBL ?? this.isUdderClosedBL,
      isUdderClosedBR: isUdderClosedBR ?? this.isUdderClosedBR,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasedFrom: purchasedFrom ?? this.purchasedFrom,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      ownerName: ownerName ?? this.ownerName,
      ownerMobile: ownerMobile ?? this.ownerMobile,
      retiredDate: retiredDate ?? this.retiredDate,
      bullView: bullView ?? this.bullView,
      motherMilk: motherMilk ?? this.motherMilk,
      grandmotherMilk: grandmotherMilk ?? this.grandmotherMilk,
    );
  }

  @override
  List<Object?> get props => [
    id,
    tagNumber,
    name,
    breed,
    gender,
    dateOfBirth,
    color,
    weight,
    status,
    imageUrl,
    acquisitionType,
    isLactating,
    isHeifer,
    isPregnant,
    isDryOff,
    isRetired,
    createdAt,
    updatedAt,
    parity,
    lastDeliveryDate,
    dailyMilkProduction,
    serialNumber,
    motherId,
    fatherId,
    motherName,
    fatherName,
    dateOfAdult,
    deathReason,
    deathDate,
    cowGroup,
    isHandicapped,
    handicapReason,
    isUdderClosedFL,
    isUdderClosedFR,
    isUdderClosedBL,
    isUdderClosedBR,
    purchaseDate,
    purchasedFrom,
    purchasePrice,
    ownerName,
    ownerMobile,
    retiredDate,
    bullView,
    motherMilk,
    grandmotherMilk,
  ];
}
