part of 'edit_motorcycle_bloc.dart';

/// Events for EditMotorcycleBloc.
abstract class EditMotorcycleEvent extends Equatable {
  const EditMotorcycleEvent();

  @override
  List<Object?> get props => [];
}

/// Event to update an existing motorcycle.
class UpdateMotorcycle extends EditMotorcycleEvent {
  final String id;
  final MotorcycleEntity motorcycle;

  const UpdateMotorcycle({required this.id, required this.motorcycle});

  @override
  List<Object?> get props => [id, motorcycle];
}
