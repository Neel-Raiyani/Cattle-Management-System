import 'package:equatable/equatable.dart';
import '../../domain/entities/cattle.dart';

/// Cattle Events
abstract class CattleEvent extends Equatable {
  const CattleEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load All Cattle
class LoadCattleList extends CattleEvent {
  final bool forceRefresh;
  
  const LoadCattleList({this.forceRefresh = false});
  
  @override
  List<Object?> get props => [forceRefresh];
}

/// Load Cattle by ID
class LoadCattleById extends CattleEvent {
  final String id;
  
  const LoadCattleById(this.id);
  
  @override
  List<Object?> get props => [id];
}

/// Add New Cattle
class AddCattle extends CattleEvent {
  final Cattle cattle;
  
  const AddCattle(this.cattle);
  
  @override
  List<Object?> get props => [cattle];
}

/// Update Cattle
class UpdateCattle extends CattleEvent {
  final Cattle cattle;
  
  const UpdateCattle(this.cattle);
  
  @override
  List<Object?> get props => [cattle];
}

/// Delete Cattle
class DeleteCattle extends CattleEvent {
  final String id;
  
  const DeleteCattle(this.id);
  
  @override
  List<Object?> get props => [id];
}

/// Search Cattle
class SearchCattle extends CattleEvent {
  final String query;
  
  const SearchCattle(this.query);
  
  @override
  List<Object?> get props => [query];
}

/// Filter Cattle by Status
class FilterCattleByStatus extends CattleEvent {
  final String status;
  
  const FilterCattleByStatus(this.status);
  
  @override
  List<Object?> get props => [status];
}
