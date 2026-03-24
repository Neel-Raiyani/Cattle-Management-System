import 'package:equatable/equatable.dart';
import '../../domain/entities/cow_group.dart';

abstract class CowGroupEvent extends Equatable {
  const CowGroupEvent();

  @override
  List<Object?> get props => [];
}

class LoadCowGroups extends CowGroupEvent {}

class AddCowGroup extends CowGroupEvent {
  final String name;
  const AddCowGroup(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateCowGroup extends CowGroupEvent {
  final CowGroup group;
  const UpdateCowGroup(this.group);

  @override
  List<Object?> get props => [group];
}

class DeleteCowGroup extends CowGroupEvent {
  final String id;
  const DeleteCowGroup(this.id);

  @override
  List<Object?> get props => [id];
}
