import 'package:equatable/equatable.dart';

/// Entity representing a branch schedule configuration.
class ScheduleEntity extends Equatable {
  final String id;
  final String branchId;
  final bool active;

  /// Start date of schedule validity (YYYY-MM-DD from API)
  final DateTime? startDate;

  /// End date of schedule validity (null = indefinite)
  final DateTime? endDate;

  const ScheduleEntity({
    required this.id,
    required this.branchId,
    required this.active,
    this.startDate,
    this.endDate,
  });

  /// Creates a copy with specified values overridden.
  ScheduleEntity copyWith({
    String? id,
    String? branchId,
    bool? active,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return ScheduleEntity(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      active: active ?? this.active,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  /// Checks if the schedule is currently within its validity period.
  bool get isWithinValidityPeriod {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (startDate != null && today.isBefore(startDate!)) {
      return false; // Schedule hasn't started yet
    }
    if (endDate != null && today.isAfter(endDate!)) {
      return false; // Schedule has expired
    }
    return true;
  }

  @override
  List<Object?> get props => [id, branchId, active, startDate, endDate];
}
