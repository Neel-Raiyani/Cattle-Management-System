import 'package:equatable/equatable.dart';

class MilkProductionEntry extends Equatable {
  final String id;
  final String cattleId; // Changed to match your screenshot error requirement
  final String cattleName;
  final double morningMilk;
  final double eveningMilk;
  final double morningFeed;
  final double eveningFeed;
  final DateTime date;

  const MilkProductionEntry({
    required this.id,
    required this.cattleId,
    required this.cattleName,
    required this.morningMilk,
    required this.eveningMilk,
    required this.morningFeed,
    required this.eveningFeed,
    required this.date,
  });

  double get totalMilk => morningMilk + eveningMilk;

  // Added copyWith to allow the Bloc to attach the names found in CattleBloc
  MilkProductionEntry copyWith({
    String? cattleName,
  }) {
    return MilkProductionEntry(
      id: id,
      cattleId: cattleId,
      cattleName: cattleName ?? this.cattleName,
      morningMilk: morningMilk,
      eveningMilk: eveningMilk,
      morningFeed: morningFeed,
      eveningFeed: eveningFeed,
      date: date,
    );
  }

  @override
  List<Object?> get props => [
    id,
    cattleId,
    cattleName,
    morningMilk,
    eveningMilk,
    morningFeed,
    eveningFeed,
    date,
  ];
}