import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:motogo_frontend/src/core/injector/injector.dart';
import 'package:motogo_frontend/src/features/manage_franchise/domain/usecases/franchise_usecases.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_event.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_state.dart';
import 'package:motogo_frontend/src/features/my_branches/domain/usecases/get_branches_usecase.dart';
import 'package:motogo_frontend/src/features/register_franchise/domain/entities/franchise_entity.dart';

/// BLoC for managing franchise details.
class ManageFranchiseBloc
    extends Bloc<ManageFranchiseEvent, ManageFranchiseState> {
  final GetFranchiseUseCase _getFranchiseUseCase;
  final UpdateFranchiseUseCase _updateFranchiseUseCase;
  final DeleteFranchiseUseCase _deleteFranchiseUseCase;
  final LinkBranchToFranchiseUseCase _linkBranchUseCase;
  final UnlinkBranchFromFranchiseUseCase _unlinkBranchUseCase;
  final GetBranchesUseCase _getBranchesUseCase;

  String? _currentFranchiseId;

  ManageFranchiseBloc({
    GetFranchiseUseCase? getFranchiseUseCase,
    UpdateFranchiseUseCase? updateFranchiseUseCase,
    DeleteFranchiseUseCase? deleteFranchiseUseCase,
    LinkBranchToFranchiseUseCase? linkBranchUseCase,
    UnlinkBranchFromFranchiseUseCase? unlinkBranchUseCase,
    GetBranchesUseCase? getBranchesUseCase,
  }) : _getFranchiseUseCase =
           getFranchiseUseCase ?? InjectorApp.resolve<GetFranchiseUseCase>(),
       _updateFranchiseUseCase =
           updateFranchiseUseCase ??
           InjectorApp.resolve<UpdateFranchiseUseCase>(),
       _deleteFranchiseUseCase =
           deleteFranchiseUseCase ??
           InjectorApp.resolve<DeleteFranchiseUseCase>(),
       _linkBranchUseCase =
           linkBranchUseCase ??
           InjectorApp.resolve<LinkBranchToFranchiseUseCase>(),
       _unlinkBranchUseCase =
           unlinkBranchUseCase ??
           InjectorApp.resolve<UnlinkBranchFromFranchiseUseCase>(),
       _getBranchesUseCase =
           getBranchesUseCase ?? InjectorApp.resolve<GetBranchesUseCase>(),
       super(const ManageFranchiseLoading()) {
    on<LoadFranchise>(_onLoadFranchise);
    on<UnlinkBranchEvent>(_onUnlinkBranch);
    on<LinkBranchEvent>(_onLinkBranch);
    on<UpdateFranchiseEvent>(_onUpdateFranchise);
    on<DeleteFranchiseEvent>(_onDeleteFranchise);
  }

  Future<void> _onLoadFranchise(
    LoadFranchise event,
    Emitter<ManageFranchiseState> emit,
  ) async {
    emit(const ManageFranchiseLoading());
    _currentFranchiseId = event.franchiseId;

    // Get franchise details
    final franchiseResult = await _getFranchiseUseCase(event.franchiseId);

    await franchiseResult.fold(
      (error) async => emit(ManageFranchiseError(error.message)),
      (franchise) async {
        // Get all branches to filter by franchise
        final branchesResult = await _getBranchesUseCase();

        branchesResult.fold(
          (error) => emit(ManageFranchiseError(error.message)),
          (allBranches) {
            // Split branches into linked and available
            final linkedBranches = allBranches
                .where((b) => b.franchiseId == event.franchiseId)
                .toList();
            final availableBranches = allBranches
                .where((b) => b.franchiseId == null)
                .toList();

            emit(
              ManageFranchiseLoaded(
                franchise: franchise,
                linkedBranches: linkedBranches,
                availableBranches: availableBranches,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onUnlinkBranch(
    UnlinkBranchEvent event,
    Emitter<ManageFranchiseState> emit,
  ) async {
    if (_currentFranchiseId == null) return;

    final result = await _unlinkBranchUseCase(
      event.branchId,
      _currentFranchiseId!,
    );

    result.fold((error) => emit(ManageFranchiseError(error.message)), (_) {
      // Reload franchise data
      if (_currentFranchiseId != null) {
        add(LoadFranchise(_currentFranchiseId!));
      }
    });
  }

  Future<void> _onLinkBranch(
    LinkBranchEvent event,
    Emitter<ManageFranchiseState> emit,
  ) async {
    if (_currentFranchiseId == null) return;

    final result = await _linkBranchUseCase(
      event.branchId,
      _currentFranchiseId!,
    );

    result.fold((error) => emit(ManageFranchiseError(error.message)), (_) {
      // Reload franchise data
      add(LoadFranchise(_currentFranchiseId!));
    });
  }

  Future<void> _onUpdateFranchise(
    UpdateFranchiseEvent event,
    Emitter<ManageFranchiseState> emit,
  ) async {
    if (_currentFranchiseId == null) return;

    final franchise = FranchiseEntity(
      id: _currentFranchiseId,
      name: event.name,
      description: event.description,
    );

    final result = await _updateFranchiseUseCase(
      _currentFranchiseId!,
      franchise,
    );

    result.fold((error) => emit(ManageFranchiseError(error.message)), (
      updated,
    ) {
      emit(
        ManageFranchiseUpdated(
          franchise: updated,
          message: 'Franquicia actualizada',
        ),
      );
      // Reload franchise data
      add(LoadFranchise(_currentFranchiseId!));
    });
  }

  Future<void> _onDeleteFranchise(
    DeleteFranchiseEvent event,
    Emitter<ManageFranchiseState> emit,
  ) async {
    if (_currentFranchiseId == null) return;

    final result = await _deleteFranchiseUseCase(_currentFranchiseId!);

    result.fold(
      (error) => emit(ManageFranchiseError(error.message)),
      (message) => emit(ManageFranchiseDeleted(message)),
    );
  }
}
