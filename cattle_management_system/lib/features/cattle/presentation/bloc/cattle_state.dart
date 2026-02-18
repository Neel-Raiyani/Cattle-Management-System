import 'package:equatable/equatable.dart';
import '../../domain/entities/cattle.dart';

/// Cattle States
abstract class CattleState extends Equatable {
  const CattleState();
  
  @override
  List<Object?> get props => [];
}

/// Initial State
class CattleInitial extends CattleState {}

/// Loading State
class CattleLoading extends CattleState {}

/// Cattle List Loaded
class CattleListLoaded extends CattleState {
  final List<Cattle> cattleList;
  final bool isFromCache;
  
  const CattleListLoaded(this.cattleList, {this.isFromCache = false});
  
  @override
  List<Object?> get props => [cattleList, isFromCache];
}

/// Single Cattle Loaded
class CattleDetailLoaded extends CattleState {
  final Cattle cattle;
  
  const CattleDetailLoaded(this.cattle);
  
  @override
  List<Object?> get props => [cattle];
}

/// Cattle Added Successfully
class CattleAdded extends CattleState {
  final Cattle cattle;
  
  const CattleAdded(this.cattle);
  
  @override
  List<Object?> get props => [cattle];
}

/// Cattle Updated Successfully
class CattleUpdated extends CattleState {
  final Cattle cattle;
  
  const CattleUpdated(this.cattle);
  
  @override
  List<Object?> get props => [cattle];
}

/// Cattle Deleted Successfully
class CattleDeleted extends CattleState {
  final String id;
  
  const CattleDeleted(this.id);
  
  @override
  List<Object?> get props => [id];
}

/// Error State
class CattleError extends CattleState {
  final String message;
  
  const CattleError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Empty State
class CattleEmpty extends CattleState {
  final String message;
  
  const CattleEmpty(this.message);
  
  @override
  List<Object?> get props => [message];
}
