import 'package:equatable/equatable.dart';
import '../../domain/entities/milk_production_entry.dart';

abstract class MilkProductionState extends Equatable {
  const MilkProductionState();

  @override
  List<Object?> get props => [];
}

class MilkProductionInitial extends MilkProductionState {}

class MilkProductionLoading extends MilkProductionState {}

class MilkProductionLoaded extends MilkProductionState {
  final List<MilkProductionEntry> entries;
  final DateTime date;

  const MilkProductionLoaded({required this.entries, required this.date});

  @override
  List<Object?> get props => [entries, date];
}

class MilkProductionError extends MilkProductionState {
  final String message;

  const MilkProductionError(this.message);

  @override
  List<Object?> get props => [message];
}

class AnimalMilkHistoryLoaded extends MilkProductionState {
  final List<dynamic> records;
  final String animalId;
  final int month;
  final int year;

  const AnimalMilkHistoryLoaded({
    required this.records,
    required this.animalId,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [records, animalId, month, year];
}
