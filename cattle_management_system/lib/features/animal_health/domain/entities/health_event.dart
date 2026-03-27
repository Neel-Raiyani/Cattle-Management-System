class HealthEvent {
  final String id;
  final String cowName;
  final String cowTagNumber;
  final String cowSerialNumber;
  final String? cowImageUrl;
  final String
  eventType; // 'Medical' | 'Vaccination' | 'Deworming' | 'Lab Testing'
  final String? diagnosis; // Medical
  final String? vaccineName; // Vaccination
  final String? dewormingDrug; // Deworming
  final String? testName; // Lab Testing
  final String? doctorName;
  final DateTime eventDate;
  final DateTime? lastDoseDate;
  final DateTime? nextDueDate;
  final String? note;
  final String status; // 'Healthy', 'Under Treatment', 'Recovered'
  final String? visitType; // 'Illness' | 'General Check-up'
  final String? visitNo;
  final String? disease;
  final String? medicalStatus; // 'Sick' | 'Healthy'
  final String? symptoms;
  final String? treatment;
  final String? rescueProcedure;
  final String?
  doseType; // Vaccination: 'First Dose' | 'Booster Dose' | 'Repeat Dose'
  final String? remark; // General remark field
  final DateTime createdAt;

  const HealthEvent({
    required this.id,
    required this.cowName,
    required this.cowTagNumber,
    required this.cowSerialNumber,
    this.cowImageUrl,
    required this.eventType,
    this.diagnosis,
    this.vaccineName,
    this.dewormingDrug,
    this.testName,
    this.doctorName,
    required this.eventDate,
    this.lastDoseDate,
    this.nextDueDate,
    this.note,
    required this.status,
    this.visitType,
    this.visitNo,
    this.disease,
    this.medicalStatus,
    this.symptoms,
    this.treatment,
    this.rescueProcedure,
    this.doseType,
    this.remark,
    required this.createdAt,
  });

  HealthEvent copyWith({
    String? id,
    String? cowName,
    String? cowTagNumber,
    String? cowSerialNumber,
    String? cowImageUrl,
    String? eventType,
    String? diagnosis,
    String? vaccineName,
    String? dewormingDrug,
    String? testName,
    String? doctorName,
    DateTime? eventDate,
    DateTime? lastDoseDate,
    DateTime? nextDueDate,
    String? note,
    String? status,
    String? visitType,
    String? visitNo,
    String? disease,
    String? medicalStatus,
    String? symptoms,
    String? treatment,
    String? rescueProcedure,
    String? doseType,
    String? remark,
    DateTime? createdAt,
  }) {
    return HealthEvent(
      id: id ?? this.id,
      cowName: cowName ?? this.cowName,
      cowTagNumber: cowTagNumber ?? this.cowTagNumber,
      cowSerialNumber: cowSerialNumber ?? this.cowSerialNumber,
      cowImageUrl: cowImageUrl ?? this.cowImageUrl,
      eventType: eventType ?? this.eventType,
      diagnosis: diagnosis ?? this.diagnosis,
      vaccineName: vaccineName ?? this.vaccineName,
      dewormingDrug: dewormingDrug ?? this.dewormingDrug,
      testName: testName ?? this.testName,
      doctorName: doctorName ?? this.doctorName,
      eventDate: eventDate ?? this.eventDate,
      lastDoseDate: lastDoseDate ?? this.lastDoseDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      note: note ?? this.note,
      status: status ?? this.status,
      visitType: visitType ?? this.visitType,
      visitNo: visitNo ?? this.visitNo,
      disease: disease ?? this.disease,
      medicalStatus: medicalStatus ?? this.medicalStatus,
      symptoms: symptoms ?? this.symptoms,
      treatment: treatment ?? this.treatment,
      rescueProcedure: rescueProcedure ?? this.rescueProcedure,
      doseType: doseType ?? this.doseType,
      remark: remark ?? this.remark,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory HealthEvent.fromJson(Map<String, dynamic> json, String type) {
    // Handle either flat structure or nested 'animal' object
    final animal = json['animal'] as Map<String, dynamic>?;

    String cowName = '-';
    String cowTag = '-';
    String cowSerial = '-';
    String? cowImage;

    if (animal != null) {
      cowName = animal['name'] ?? '-';
      cowTag = animal['tagNumber'] ?? animal['tagno'] ?? '-';
      cowSerial =
          animal['animalNumber'] ?? animal['serialNumber'] ?? animal['animalNo'] ?? '-';
      cowImage =
          animal['imageUrl'] ?? animal['viewUrl'] ?? animal['photoUrl'] ?? animal['photo'];
    } else {
      cowName = json['animalName'] ?? json['name'] ?? '-';
      cowTag = json['animalTagNumber'] ?? json['tagNumber'] ?? json['tagno'] ?? '-';
      cowSerial =
          json['animalNumber'] ??
          json['animalSerialNumber'] ??
          json['serialNumber'] ??
          json['animalNo'] ??
          '-';
      cowImage = json['animalImageUrl'] ??
          json['imageUrl'] ??
          json['viewUrl'] ??
          json['photoUrl'] ??
          json['photo'];
    }

    final rawMedicalStatus =
        (json['medicalStatus'] ?? json['status'] ?? '').toString().toUpperCase();
    final displayStatus = rawMedicalStatus == 'SICK'
        ? 'Sick'
        : rawMedicalStatus == 'HEALTHY'
            ? 'Healthy'
            : (json['status']?.toString() ?? rawMedicalStatus);
    final rawDoseType = json['doseType']?.toString();
    final quantity = json['quantity']?.toString().trim();
    final displayDoseType =
        rawDoseType == null || rawDoseType.trim().isEmpty
            ? null
            : (quantity == null || quantity.isEmpty
                ? rawDoseType
                : '$rawDoseType ($quantity)');

    return HealthEvent(
      id: json['id'] ?? json['_id'] ?? '',
      cowName: cowName,
      cowTagNumber: cowTag,
      cowSerialNumber: cowSerial,
      cowImageUrl: cowImage,
      eventType: type,
      eventDate: DateTime.parse(
        json['visitDate'] ??
            json['doseDate'] ??
            json['sampleDate'] ??
            json['date'] ??
            DateTime.now().toIso8601String(),
      ).toLocal(),
      lastDoseDate: json['lastDoseDate'] != null
          ? DateTime.tryParse(json['lastDoseDate'].toString())?.toLocal()
          : null,
      nextDueDate: (json['nextDoseDate'] ?? json['nextDueDate']) != null
          ? DateTime.tryParse(
              (json['nextDoseDate'] ?? json['nextDueDate']).toString(),
            )?.toLocal()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt']).toLocal()
          : DateTime.now(),
      status: displayStatus.isEmpty ? 'Healthy' : displayStatus,
      visitType: json['visitType'],
      disease: json['disease'] is Map
          ? json['disease']['name']
          : (json['diseaseName'] ?? json['disease']),
      doctorName: json['vet'] is Map
          ? json['vet']['name']
          : (json['vetName'] ?? json['doctorName'] ?? json['vetId']),
      medicalStatus: rawMedicalStatus.isEmpty ? null : rawMedicalStatus,
      symptoms: json['symptoms'],
      treatment: json['treatment'],
      remark: json['remark'] ?? json['remarks'],
      vaccineName: json['vaccine'] is Map
          ? json['vaccine']['name']
          : (json['vaccineName'] ?? json['vaccinationName']),
      doseType: displayDoseType,
      dewormingDrug:
          json['companyName'] ??
          json['medicineName'] ??
          json['medicineType'] ??
          json['drug'] ??
          json['drugName'],
      testName: json['labtest'] is Map
          ? json['labtest']['name']
          : json['labTest'] is Map
              ? json['labTest']['name']
              : json['labtestId'] is Map
                  ? json['labtestId']['name']
                  : json['labTestId'] is Map
                      ? json['labTestId']['name']
                      : (json['labTestName'] ?? json['testName']),
    );
  }
}
