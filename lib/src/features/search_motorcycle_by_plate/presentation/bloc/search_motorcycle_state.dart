part of 'search_motorcycle_bloc.dart';

/// States for the SearchMotorcycle BLoC.
abstract class SearchMotorcycleState extends Equatable {
  const SearchMotorcycleState();

  @override
  List<Object?> get props => [];
}

/// Initial state - search form ready.
class SearchMotorcycleInitial extends SearchMotorcycleState {
  const SearchMotorcycleInitial();
}

/// Loading state - search in progress.
class SearchMotorcycleLoading extends SearchMotorcycleState {
  const SearchMotorcycleLoading();
}

/// Success state - motorcycle found.
class SearchMotorcycleLoaded extends SearchMotorcycleState {
  final MotorcycleDetailEntity motorcycle;
  final String? solutionMessage;
  final String? solutionError;

  const SearchMotorcycleLoaded(
    this.motorcycle, {
    this.solutionMessage,
    this.solutionError,
  });

  SearchMotorcycleLoaded copyWith({
    MotorcycleDetailEntity? motorcycle,
    String? solutionMessage,
    String? solutionError,
  }) {
    return SearchMotorcycleLoaded(
      motorcycle ?? this.motorcycle,
      solutionMessage: solutionMessage,
      solutionError: solutionError,
    );
  }

  @override
  List<Object?> get props => [motorcycle, solutionMessage, solutionError];
}

/// Error state - search failed.
class SearchMotorcycleError extends SearchMotorcycleState {
  final String message;

  const SearchMotorcycleError(this.message);

  @override
  List<Object?> get props => [message];
}
