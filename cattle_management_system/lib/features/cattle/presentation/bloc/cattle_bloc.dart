import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cattle.dart';
import '../../domain/repositories/cattle_repository.dart';
import 'cattle_event.dart';
import 'cattle_state.dart';

/// Cattle BLoC
class CattleBloc extends Bloc<CattleEvent, CattleState> {
  final CattleRepository repository;
  List<Cattle> _currentCattleList = [];

  CattleBloc({required this.repository}) : super(CattleInitial()) {
    on<LoadCattleList>(_onLoadCattleList);
    on<LoadCowsList>(_onLoadCowsList);
    on<LoadBullsList>(_onLoadBullsList);
    on<LoadCattleById>(_onLoadCattleById);
    on<AddCattle>(_onAddCattle);
    on<UpdateCattle>(_onUpdateCattle);
    on<UpsertLocalCattle>(_onUpsertLocalCattle);
    on<DeleteCattle>(_onDeleteCattle);
    on<SearchCattle>(_onSearchCattle);
    on<FilterCattleByStatus>(_onFilterCattleByStatus);
  }

  Future<void> _onLoadCattleList(
    LoadCattleList event,
    Emitter<CattleState> emit,
  ) async {
    // If we have data, show it immediately
    if (_currentCattleList.isNotEmpty) {
      emit(CattleListLoaded(_currentCattleList, isFromCache: true));
      // Only hit the network if forced
      if (!event.forceRefresh) return;
    } else {
      emit(CattleLoading());
    }
    final result = await repository.getAllCattle();

    result.fold((failure) => emit(CattleError(failure.message)), (cattleList) {
      _currentCattleList = List.from(cattleList);
      if (_currentCattleList.isEmpty) {
        emit(const CattleEmpty('No cattle found. Add your first cattle!'));
      } else {
        emit(CattleListLoaded(_currentCattleList));
      }
    });
  }

  Future<void> _onLoadCowsList(
    LoadCowsList event,
    Emitter<CattleState> emit,
  ) async {
    final cachedCows = _currentCattleList
        .where((c) => c.gender.toUpperCase().startsWith('F') && c.isActive)
        .toList();
    if (!event.forceRefresh && cachedCows.isNotEmpty) {
      emit(CattleListLoaded(cachedCows, isFromCache: true));
      return;
    }

    if (cachedCows.isNotEmpty) {
      emit(CattleListLoaded(cachedCows, isFromCache: true));
    } else {
      emit(CattleLoading());
    }

    final result = await repository.getAllCattle();
    result.fold((failure) => emit(CattleError(failure.message)), (cattleList) {
      _currentCattleList = List.from(cattleList);
      final cowsList = _currentCattleList
          .where((c) => c.gender.toUpperCase().startsWith('F') && c.isActive)
          .toList();
      if (cowsList.isEmpty) {
        emit(const CattleEmpty('No cows found'));
      } else {
        emit(CattleListLoaded(cowsList));
      }
    });
  }

  Future<void> _onLoadBullsList(
    LoadBullsList event,
    Emitter<CattleState> emit,
  ) async {
    final cachedBulls = _currentCattleList
        .where((c) => c.gender.toUpperCase().startsWith('M'))
        .toList();

    if (!event.forceRefresh && cachedBulls.isNotEmpty) {
      emit(CattleListLoaded(cachedBulls, isFromCache: true));
      return;
    }

    if (cachedBulls.isNotEmpty) {
      emit(CattleListLoaded(cachedBulls, isFromCache: true));
    } else {
      emit(CattleLoading());
    }

    final result = await repository.getBulls(bullType: event.bullType);
    result.fold((failure) => emit(CattleError(failure.message)), (cattleList) {
      _currentCattleList = List.from(cattleList);
      final bullsList = _currentCattleList
          .where((c) => c.gender.toUpperCase().startsWith('M') && c.isActive)
          .toList();
      if (bullsList.isEmpty) {
        emit(const CattleEmpty('No bulls found'));
      } else {
        emit(CattleListLoaded(bullsList));
      }
    });
  }

Future<void> _onLoadCattleById(
    LoadCattleById event,
    Emitter<CattleState> emit,
  ) async {
    // Check cache first
    final cached = _currentCattleList.where((c) => c.id == event.id).toList();
    if (cached.isNotEmpty) {
      emit(CattleDetailLoaded(cached.first));
    }

    emit(CattleLoading());
    final result = await repository.getCattleById(event.id);
    result.fold(
      (failure) => emit(CattleError(failure.message)),
      (cattle) => emit(CattleDetailLoaded(cattle)),
    );
  }

  Future<void> _onAddCattle(AddCattle event, Emitter<CattleState> emit) async {
    emit(CattleLoading());
    final result = await repository.addCattle(event.cattle);
    result.fold((failure) {
      emit(CattleActionError(failure.message));
      if (_currentCattleList.isNotEmpty) {
        emit(CattleListLoaded(List.from(_currentCattleList), isFromCache: true));
      }
    }, (cattle) {
      _currentCattleList.add(cattle);
      emit(CattleAdded(cattle));
      // Emit updated list immediately
      emit(CattleListLoaded(List.from(_currentCattleList)));
    });
  }

  Future<void> _onUpdateCattle(
    UpdateCattle event,
    Emitter<CattleState> emit,
  ) async {
    emit(CattleLoading());
    final result = await repository.updateCattle(event.cattle);
    result.fold((failure) {
      emit(CattleActionError(failure.message));
      if (_currentCattleList.isNotEmpty) {
        emit(CattleListLoaded(List.from(_currentCattleList), isFromCache: true));
      }
    }, (cattle) {
      final index = _currentCattleList.indexWhere((c) => c.id == cattle.id);
      if (index != -1) {
        _currentCattleList[index] = cattle;
      }
      emit(CattleUpdated(cattle));
      emit(CattleListLoaded(List.from(_currentCattleList)));
    });
  }

  Future<void> _onDeleteCattle(
    DeleteCattle event,
    Emitter<CattleState> emit,
  ) async {
    final removedIndex = _currentCattleList.indexWhere((c) => c.id == event.id);
    Cattle? removedCattle;
    if (removedIndex != -1) {
      removedCattle = _currentCattleList.removeAt(removedIndex);
      emit(CattleListLoaded(List.from(_currentCattleList), isFromCache: true));
    }

    final result = await repository.deleteCattle(event.id);
    result.fold((failure) {
      if (removedCattle != null) {
        _currentCattleList.insert(removedIndex, removedCattle);
        emit(CattleListLoaded(List.from(_currentCattleList), isFromCache: true));
      }
      emit(CattleActionError(failure.message));
      if (_currentCattleList.isNotEmpty) {
        emit(CattleListLoaded(List.from(_currentCattleList), isFromCache: true));
      }
    }, (_) {
      emit(CattleDeleted(event.id));
      emit(CattleListLoaded(List.from(_currentCattleList)));
    });
  }

  Future<void> _onUpsertLocalCattle(
    UpsertLocalCattle event,
    Emitter<CattleState> emit,
  ) async {
    final index = _currentCattleList.indexWhere((c) => c.id == event.cattle.id);
    if (index != -1) {
      _currentCattleList[index] = event.cattle;
    } else {
      _currentCattleList.add(event.cattle);
    }

    emit(CattleUpdated(event.cattle));
    emit(CattleListLoaded(List.from(_currentCattleList), isFromCache: true));
  }

  Future<void> _onSearchCattle(
    SearchCattle event,
    Emitter<CattleState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(CattleListLoaded(List.from(_currentCattleList)));
      return;
    }

    final results = _currentCattleList.where((c) {
      return c.name.toLowerCase().contains(event.query.toLowerCase()) ||
          c.tagNumber.toLowerCase().contains(event.query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      emit(const CattleEmpty('No results found'));
    } else {
      emit(CattleListLoaded(results));
    }
  }

  Future<void> _onFilterCattleByStatus(
    FilterCattleByStatus event,
    Emitter<CattleState> emit,
  ) async {
    final results = _currentCattleList.where((c) {
      return c.status == event.status;
    }).toList();

    if (results.isEmpty) {
      emit(const CattleEmpty('No cattle with this status found'));
    } else {
      emit(CattleListLoaded(results));
    }
  }
}
