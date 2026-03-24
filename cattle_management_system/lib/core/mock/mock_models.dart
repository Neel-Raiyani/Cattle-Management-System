import 'package:equatable/equatable.dart';

class MockMedicalRecord {
  final DateTime date;
  final String status;      // 'Healthy' or 'Sick'
  final String visitType;   // e.g. 'General Check-up', 'Illness'
  final String disease;     
  final String doctorName;  
  final List<String> symptoms;
  final List<String> treatment;
  final List<String> rescueProcedure;

  const MockMedicalRecord({
    required this.date,
    required this.status,
    required this.visitType,
    required this.disease,
    required this.doctorName,
    this.symptoms = const [],
    this.treatment = const [],
    this.rescueProcedure = const [],
  });
}

class MockLabTestRecord {
  final DateTime sampleDate;
  final DateTime resultDate;
  final String testName;
  final String reportDescription;

  const MockLabTestRecord({
    required this.sampleDate,
    required this.resultDate,
    required this.testName,
    required this.reportDescription,
  });
}

class MockHeatRecord {
  final DateTime date;
  final int parity;
  final bool isBreed;
  final int days;
  final String note;

  const MockHeatRecord({
    required this.date,
    required this.parity,
    required this.isBreed,
    required this.days,
    required this.note,
  });
}

class MockPregnancyRecord {
  final DateTime date;
  final int parity;
  final String status; // 'Pregnant', 'Empty'
  final String inseminationType; // 'AI', 'Natural'
  final String bullName;
  final String doctorName;

  const MockPregnancyRecord({
    required this.date,
    required this.parity,
    required this.status,
    required this.inseminationType,
    required this.bullName,
    required this.doctorName,
  });
}

class MockDeliveryRecord {
  final DateTime date;
  final int parity;
  final String gender; // 'Male', 'Female'
  final String weight;
  final String status; // 'Live', 'Stillborn'
  final String note;

  const MockDeliveryRecord({
    required this.date,
    required this.parity,
    required this.gender,
    required this.weight,
    required this.status,
    required this.note,
  });
}

class MockDewormingRecord {
  final DateTime date;
  final String medicine;
  final String doctor;
  final String age;
  final String lastDose;
  final DateTime nextDose;
  final String dosage;

  const MockDewormingRecord({
    required this.date,
    required this.medicine,
    required this.doctor,
    this.age = '-',
    this.lastDose = '-',
    required this.nextDose,
    this.dosage = 'Tablet (1 Qty.)',
  });
}

class MockVaccinationRecord {
  final DateTime date;
  final String vaccine;
  final String dose;
  final String remarks;

  const MockVaccinationRecord({
    required this.date,
    required this.vaccine,
    required this.dose,
    required this.remarks,
  });
}

class MockMilkRecord {
  final DateTime date;
  final double morningMilk;
  final double eveningMilk;
  final double morningFeed;
  final double eveningFeed;

  const MockMilkRecord({
    required this.date,
    required this.morningMilk,
    required this.eveningMilk,
    required this.morningFeed,
    required this.eveningFeed,
  });
}

class MockCattle extends Equatable {
  final String id;
  final String name;
  final String tagNo;
  final String no;
  final String type; // 'Cow', 'Bull', 'Calf'
  final String gender;
  final String breed;
  final DateTime dob;
  final String imagePath;
  final String status; // 'Healthy', 'Sick', 'Pregnant', 'Dry'
  
  final List<MockMedicalRecord> medicalRecords;
  final List<MockLabTestRecord> labTests;
  final List<MockHeatRecord> heatRecords;
  final List<MockPregnancyRecord> pregnancyRecords;
  final List<MockDeliveryRecord> deliveryRecords;
  final List<MockDewormingRecord> dewormingRecords;
  final List<MockVaccinationRecord> vaccinationRecords;
  final List<MockMilkRecord> milkRecords;

  const MockCattle({
    required this.id,
    required this.name,
    required this.tagNo,
    required this.no,
    required this.type,
    required this.gender,
    required this.breed,
    required this.dob,
    required this.imagePath,
    this.status = 'Healthy',
    this.medicalRecords = const [],
    this.labTests = const [],
    this.heatRecords = const [],
    this.pregnancyRecords = const [],
    this.deliveryRecords = const [],
    this.dewormingRecords = const [],
    this.vaccinationRecords = const [],
    this.milkRecords = const [],
  });

  @override
  List<Object?> get props => [id, tagNo, name, type];
}
