import 'mock_models.dart';

class MockData {
  static final List<MockCattle> allCattle = [
    MockCattle(
      id: '1',
      name: 'ક્રિષ્ના',
      tagNo: '106',
      no: '0005',
      type: 'Cow',
      gender: 'Female',
      breed: 'Gir',
      dob: DateTime(2020, 5, 10),
      imagePath: 'assets/icons/cow_and_calf.png',
      status: 'Healthy',
      medicalRecords: [
        MockMedicalRecord(
          date: DateTime(2025, 10, 16),
          status: 'Healthy',
          visitType: 'General Check-up',
          disease: 'BACTERIAL DISEASES (બેક્ટેરિયલ સંબંધિત બીમારીઓ)',
          doctorName: 'Dr. Dhrupal',
        ),
      ],
      labTests: [
        MockLabTestRecord(
          sampleDate: DateTime(2025, 10, 16),
          resultDate: DateTime(2025, 10, 18),
          testName: 'Hematology (CBC) — હેમેટોલોજી - રક્ત તપાસ',
          reportDescription: 'રક્તમાં હિમોગ્લોબિનનું પ્રમાણ સામાન્ય છે. શ્વેત કણોની સંખ્યામાં થોડો વધારો જોવા મળ્યો છે.',
        ),
      ],
      dewormingRecords: [
        MockDewormingRecord(
          date: DateTime(2025, 10, 04),
          medicine: 'Panacure 3gm (MSD)',
          doctor: 'Dr. uday',
          nextDose: DateTime(2026, 01, 04),
        ),
      ],
      vaccinationRecords: [
        MockVaccinationRecord(
          date: DateTime(2025, 10, 04),
          vaccine: 'Foot and Mouth Disease (FMD)',
          dose: 'First Dose',
          remarks: 'ત્રિમાસિક રસીકરણ અભિયાન',
        ),
      ],
    ),
    MockCattle(
      id: '2',
      name: 'મેઘા',
      tagNo: '101',
      no: '0001',
      type: 'Cow',
      gender: 'Female',
      breed: 'Gir',
      dob: DateTime(2019, 8, 15),
      imagePath: 'assets/icons/cow_and_calf.png',
      status: 'Pregnant',
      heatRecords: [
        MockHeatRecord(
          date: DateTime(2025, 9, 9),
          parity: 1,
          isBreed: true,
          days: 0,
          note: 'raz ni milto nathi noto',
        ),
      ],
      pregnancyRecords: [
        MockPregnancyRecord(
          date: DateTime(2025, 10, 10),
          parity: 1,
          status: 'Pregnant',
          inseminationType: 'AI',
          bullName: 'બલી',
          doctorName: 'Dr. Uday',
        ),
      ],
    ),
    MockCattle(
      id: '3',
      name: 'બલી',
      tagNo: '205',
      no: '0205',
      type: 'Bull',
      gender: 'Male',
      breed: 'Gir',
      dob: DateTime(2018, 3, 20),
      imagePath: 'assets/icons/father_cow.png',
      status: 'Healthy',
      medicalRecords: [
        MockMedicalRecord(
          date: DateTime(2025, 12, 18),
          status: 'Sick',
          visitType: 'Illness',
          disease: 'RESPIRATORY DISEASES (શ્વસનતંત્રના રોગો)',
          doctorName: 'Dr. Uday',
          symptoms: ['ઉધરસ', 'શ્વાસ લેવામાં તકલીફ'],
          treatment: ['સીરપ', 'એન્ટીબાયોટીક'],
        ),
      ],
    ),
    MockCattle(
      id: '4',
      name: 'ઢિભા',
      tagNo: '706',
      no: '6006',
      type: 'Cow',
      gender: 'Female',
      breed: 'Gir',
      dob: DateTime(2021, 1, 5),
      imagePath: 'assets/icons/cow_and_calf.png',
      status: 'Healthy',
      heatRecords: [
        MockHeatRecord(
          date: DateTime(2025, 9, 28),
          parity: 1,
          isBreed: false,
          days: 0,
          note: 'ઓવ્યુ લઈ ૧-૨ ડોઝ થઈ ગઈ',
        ),
      ],
      labTests: [
        MockLabTestRecord(
          sampleDate: DateTime(2025, 10, 16),
          resultDate: DateTime(2025, 10, 20),
          testName: 'Urine Examination — મૂત્ર તપાસ',
          reportDescription: 'મૂત્રના નમૂનામાં પ્રોટીનનું પ્રમાણ સામાન્ય છે. ક્ષારોની હાજરી જોવા મળી નથી.',
        ),
      ],
    ),
  ];

  static List<MockCattle> get cows => allCattle.where((c) => c.type == 'Cow').toList();
  static List<MockCattle> get bulls => allCattle.where((c) => c.type == 'Bull').toList();
}
