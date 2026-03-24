import 'package:equatable/equatable.dart';
import '../../domain/entities/cow_group.dart';

abstract class CowGroupState extends Equatable {
  const CowGroupState();

  @override
  List<Object?> get props => [];
}

class CowGroupInitial extends CowGroupState {}

class CowGroupLoading extends CowGroupState {}

class CowGroupLoaded extends CowGroupState {
  final List<CowGroup> groups;
  const CowGroupLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class CowGroupError extends CowGroupState {
  final String message;
  const CowGroupError(this.message);

  @override
  List<Object?> get props => [message];
}
