import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Uniquely identifies a state by its [type] and optional [key].
class StateId extends Equatable {
  const StateId({
    required this.key,
    required this.type,
  });

  final Key? key;
  final Type type;

  @override
  List<Object?> get props => [key, type];
}
