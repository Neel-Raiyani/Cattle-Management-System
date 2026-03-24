import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import 'cow_group_event.dart';
import 'cow_group_state.dart';
import '../../domain/entities/cow_group.dart';

class CowGroupBloc extends Bloc<CowGroupEvent, CowGroupState> {
  final ApiService _apiService;
  List<CowGroup> _currentGroups = [];

  CowGroupBloc(this._apiService) : super(CowGroupInitial()) {
    on<LoadCowGroups>((event, emit) async {
      emit(CowGroupLoading());
      try {
        final data = await _apiService.getCowGroups();
        _currentGroups = data
            .map(
              (group) => CowGroup(
                id: group['_id']?.toString() ?? group['id']?.toString() ?? '',
                name: group['name']?.toString() ?? 'Group',
                cowCount: group['animalCount'] ?? group['cowCount'] ?? 0,
              ),
            )
            .toList();
        emit(CowGroupLoaded(List.from(_currentGroups)));
      } catch (e) {
        emit(CowGroupError(e.toString()));
      }
    });

    on<AddCowGroup>((event, emit) async {
      emit(CowGroupLoading());  
      try {
        await _apiService.addCowGroup(event.name);
        add(LoadCowGroups()); // Reload list
      } catch (e) {
        emit(CowGroupError(e.toString()));
        emit(CowGroupLoaded(List.from(_currentGroups))); // Restore previous state
      }
    });

    on<UpdateCowGroup>((event, emit) async {
      emit(CowGroupLoading());
      try {
        await _apiService.updateCowGroup(event.group.id, event.group.name);
        add(LoadCowGroups()); // Reload list
      } catch (e) {
        emit(CowGroupError(e.toString()));
        emit(CowGroupLoaded(List.from(_currentGroups))); // Restore previous state
      }
    });

    on<DeleteCowGroup>((event, emit) async {
      emit(CowGroupLoading());
      try {
        await _apiService.deleteCowGroup(event.id);
        add(LoadCowGroups()); // Reload list
      } catch (e) {
        emit(CowGroupError(e.toString()));
        emit(CowGroupLoaded(List.from(_currentGroups))); // Restore previous state
      }
    });
  }
}
