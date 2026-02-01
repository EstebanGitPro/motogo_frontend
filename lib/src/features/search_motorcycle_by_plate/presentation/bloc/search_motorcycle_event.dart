part of 'search_motorcycle_bloc.dart';

/// Events for the SearchMotorcycle BLoC.
abstract class SearchMotorcycleEvent extends Equatable {
  const SearchMotorcycleEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when user submits a plate search.
class SearchByPlate extends SearchMotorcycleEvent {
  final String plate;

  const SearchByPlate(this.plate);

  @override
  List<Object?> get props => [plate];
}

/// Event to clear search results and return to initial state.
class ClearSearch extends SearchMotorcycleEvent {
  const ClearSearch();
}
