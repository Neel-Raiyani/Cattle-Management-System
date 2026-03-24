import 'package:equatable/equatable.dart';

import '../../../cattle/domain/entities/cattle.dart';

abstract class MilkProductionEvent extends Equatable {
  const MilkProductionEvent();

  @override
  List<Object?> get props => [];
}

class LoadMilkProductionList extends MilkProductionEvent {
  final DateTime date;
  final List<Cattle>? cattleList;

  const LoadMilkProductionList({required this.date,required this.cattleList});

  @override
  List<Object?> get props => [date,cattleList];
}

class LoadAnimalMilkHistory extends MilkProductionEvent {
  final String animalId;
  final int month;
  final int year;

  const LoadAnimalMilkHistory({
    required this.animalId,
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [animalId, month, year];
}
