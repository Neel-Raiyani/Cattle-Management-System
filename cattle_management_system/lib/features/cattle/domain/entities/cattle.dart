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
  final String status; // healthy, sick, pregnant, dry
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  
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
    required this.createdAt,
    required this.updatedAt,
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
  
  String get displayAge {
    final years = ageInYears;
    final months = ageInMonths % 12;
    
    if (years > 0) {
      return months > 0 ? '$years yr $months mo' : '$years yr';
    } else {
      return '$months mo';
    }
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
        createdAt,
        updatedAt,
      ];
}
