import 'package:equatable/equatable.dart';

class MilkProductionEntry extends Equatable {
  final String id;
  final String cattleId; // Changed to match your screenshot error requirement
  final String cattleName;
  final String? cattleGroup;
  final double morningMilk;
  final double eveningMilk;
  final double morningFeed;
  final double eveningFeed;
  final DateTime date;

  const MilkProductionEntry({
    required this.id,
    required this.cattleId,
    required this.cattleName,
    this.cattleGroup,
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
    String? cattleGroup,
  }) {
    return MilkProductionEntry(
      id: id,
      cattleId: cattleId,
      cattleName: cattleName ?? this.cattleName,
      cattleGroup: cattleGroup ?? this.cattleGroup,
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
    cattleGroup,
    morningMilk,
    eveningMilk,
    morningFeed,
    eveningFeed,
    date,
  ];
}
