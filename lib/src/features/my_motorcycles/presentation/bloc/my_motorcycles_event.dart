part of 'my_motorcycles_bloc.dart';

/// Events for MyMotorcyclesBloc.
abstract class MyMotorcyclesEvent extends Equatable {
  const MyMotorcyclesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load motorcycles.
class LoadMyMotorcycles extends MyMotorcyclesEvent {
  const LoadMyMotorcycles();
}

/// Event to delete a motorcycle.
class DeleteMotorcycle extends MyMotorcyclesEvent {
  final String motorcycleId;

  const DeleteMotorcycle(this.motorcycleId);

  @override
  List<Object?> get props => [motorcycleId];
}
