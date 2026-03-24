import 'package:equatable/equatable.dart';

class CowGroup extends Equatable {
  final String id;
  final String name;
  final int cowCount;

  const CowGroup({required this.id, required this.name, this.cowCount = 0});

  CowGroup copyWith({String? id, String? name, int? cowCount}) {
    return CowGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      cowCount: cowCount ?? this.cowCount,
    );
  }

  @override
  List<Object?> get props => [id, name, cowCount];
}
