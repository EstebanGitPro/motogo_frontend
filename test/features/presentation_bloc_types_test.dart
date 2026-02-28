import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_event.dart';
import 'package:motogo_frontend/src/features/branch_schedules/presentation/bloc/branch_schedule_state.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_event.dart';
import 'package:motogo_frontend/src/features/admin_services/presentation/bloc/admin_services_state.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_event.dart';
import 'package:motogo_frontend/src/features/manage_franchise/presentation/bloc/manage_franchise_state.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_event.dart';
import 'package:motogo_frontend/src/features/edit_branch/presentation/bloc/edit_branch_state.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_event.dart';
import 'package:motogo_frontend/src/features/my_branches/presentation/bloc/my_branches_state.dart';

/// Tests for cross-feature event/state type hierarchy verification.
void main() {
  group('Event type hierarchy', () {
    test('BranchScheduleEvent subtypes are correct', () {
      expect(const LoadSchedule('b1'), isA<BranchScheduleEvent>());
      expect(const CreateSchedule('b1'), isA<BranchScheduleEvent>());
      expect(const DeleteSchedule('b1'), isA<BranchScheduleEvent>());
      expect(
        const ToggleScheduleStatus(branchId: 'b1', activate: true),
        isA<BranchScheduleEvent>(),
      );
      expect(const UpdateSchedule(branchId: 'b1'), isA<BranchScheduleEvent>());
      expect(ClearMessage(), isA<BranchScheduleEvent>());
      expect(const LoadScheduleDetails('b1'), isA<BranchScheduleEvent>());
      expect(const LoadScheduleExceptions('b1'), isA<BranchScheduleEvent>());
    });

    test('AdminServicesEvent subtypes are correct', () {
      expect(LoadServices(), isA<AdminServicesEvent>());
      expect(RefreshServices(), isA<AdminServicesEvent>());
      expect(const SearchServices(query: 'q'), isA<AdminServicesEvent>());
      expect(
        const UpdateService(serviceId: 's', name: 'n', serviceType: 't'),
        isA<AdminServicesEvent>(),
      );
      expect(
        const ToggleServiceStatus(serviceId: 's', activate: true),
        isA<AdminServicesEvent>(),
      );
    });

    test('ManageFranchiseEvent subtypes are correct', () {
      expect(const LoadFranchise('f1'), isA<ManageFranchiseEvent>());
      expect(const UnlinkBranchEvent('b1'), isA<ManageFranchiseEvent>());
      expect(const LinkBranchEvent('b1'), isA<ManageFranchiseEvent>());
      expect(
        const UpdateFranchiseEvent(name: 'n'),
        isA<ManageFranchiseEvent>(),
      );
      expect(const DeleteFranchiseEvent(), isA<ManageFranchiseEvent>());
    });

    test('EditBranchEvent subtypes are correct', () {
      expect(EditBranchReset(), isA<EditBranchEvent>());
    });

    test('MyBranchesEvent subtypes are correct', () {
      expect(LoadBranches(), isA<MyBranchesEvent>());
      expect(SearchBranches(query: 'q'), isA<MyBranchesEvent>());
      expect(RefreshBranches(), isA<MyBranchesEvent>());
    });
  });

  group('State type hierarchy', () {
    test('BranchScheduleState subtypes are correct', () {
      expect(BranchScheduleInitial(), isA<BranchScheduleState>());
      expect(BranchScheduleLoading(), isA<BranchScheduleState>());
      expect(const BranchScheduleError('e'), isA<BranchScheduleState>());
      expect(const BranchScheduleOperating('op'), isA<BranchScheduleState>());
      expect(const BranchScheduleNotFound(), isA<BranchScheduleState>());
    });

    test('AdminServicesState subtypes are correct', () {
      expect(AdminServicesInitial(), isA<AdminServicesState>());
      expect(AdminServicesLoading(), isA<AdminServicesState>());
    });

    test('ManageFranchiseState subtypes are correct', () {
      expect(const ManageFranchiseLoading(), isA<ManageFranchiseState>());
      expect(const ManageFranchiseError('e'), isA<ManageFranchiseState>());
      expect(const ManageFranchiseDeleted('d'), isA<ManageFranchiseState>());
    });

    test('EditBranchState subtypes are correct', () {
      expect(EditBranchInitial(), isA<EditBranchState>());
      expect(EditBranchLoading(), isA<EditBranchState>());
    });

    test('MyBranchesState subtypes are correct', () {
      expect(MyBranchesInitial(), isA<MyBranchesState>());
      expect(MyBranchesLoading(), isA<MyBranchesState>());
    });
  });
}
