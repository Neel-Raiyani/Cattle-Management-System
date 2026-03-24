import 'package:flutter_bloc/flutter_bloc.dart';
import 'milk_production_event.dart';
import 'milk_production_state.dart';
import '../../domain/entities/milk_production_entry.dart';
import '../../domain/repositories/milk_production_repository.dart';
import '../../../cattle/presentation/bloc/cattle_bloc.dart';
import '../../../cattle/presentation/bloc/cattle_state.dart';

class MilkProductionBloc
    extends Bloc<MilkProductionEvent, MilkProductionState> {
  final MilkProductionRepository repository;
  final CattleBloc cattleBloc; // Add cattleBloc dependency

  MilkProductionBloc({
    required this.repository,
    required this.cattleBloc,
  }) : super(MilkProductionInitial()) {
    on<LoadMilkProductionList>(_onLoadMilkProductionList);
    on<LoadAnimalMilkHistory>(_onLoadAnimalMilkHistory);
  }
  Future<void> _onLoadMilkProductionList(
      LoadMilkProductionList event,
      Emitter<MilkProductionState> emit,
      ) async {
    emit(MilkProductionLoading());
    try {
      final List<MilkProductionEntry> entries = await repository.getMilkProductionByDate(event.date);

      // Match names if the list was provided
      List<MilkProductionEntry> enrichedEntries = entries;
      if (event.cattleList != null && event.cattleList!.isNotEmpty) {
        enrichedEntries = entries.map((entry) {
          try {
            final matched = event.cattleList!.firstWhere((c) => c.id == entry.cattleId);
            return entry.copyWith(cattleName: matched.name);
          } catch (_) {
            return entry;
          }
        }).toList();
      }

      emit(MilkProductionLoaded(entries: enrichedEntries, date: event.date));
    } catch (e) {
      emit(MilkProductionError(e.toString()));
    }
  }


  Future<void> _onLoadAnimalMilkHistory(
      LoadAnimalMilkHistory event,
      Emitter<MilkProductionState> emit,
      ) async {
    emit(MilkProductionLoading());

    try {
      final List<dynamic> records = await repository.getMilkHistoryForAnimal(
        animalId: event.animalId,
        month: event.month,
        year: event.year,
      );
      emit(
        AnimalMilkHistoryLoaded(
          records: records,
          animalId: event.animalId,
          month: event.month,
          year: event.year,
        ),
      );
    } catch (e) {
      emit(MilkProductionError(e.toString()));
    }
  }
}