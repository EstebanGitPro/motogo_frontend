import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_exception_entity.dart';

/// Entity representing the complete detail of a branch/store.
///
/// Contains all information needed for the branch detail screen.
class BranchDetailEntity extends Equatable {
  /// Unique identifier for the branch.
  final String id;

  /// Name of the branch/store.
  final String name;

  /// Type of establishment (taller, tienda).
  final String type;

  /// Localized type label (Taller, Tienda).
  final String? typeLabel;

  /// URL of the profile image.
  final String? profileImageUrl;

  /// Street address.
  final String? address;

  /// City name.
  final String? cityName;

  /// Department name.
  final String? departmentName;

  /// Representative phone number (when available).
  final String? phoneNumber;

  /// Latitude for maps.
  final double latitude;

  /// Longitude for maps.
  final double longitude;

  /// Displacement ranges the branch works with.
  final List<String> displacementRanges;

  const BranchDetailEntity({
    required this.id,
    required this.name,
    required this.type,
    this.typeLabel,
    this.profileImageUrl,
    this.address,
    this.cityName,
    this.departmentName,
    this.phoneNumber,
    required this.latitude,
    required this.longitude,
    this.displacementRanges = const [],
  });

  /// Returns true if this is a workshop.
  bool get isWorkshop => type == 'taller';

  /// Returns true if this is a store.
  bool get isStore => type == 'tienda';

  /// Returns true if this is a workshop and store.
  bool get isWorkshopStore => type == 'taller_tienda';

  /// Returns the display type label.
  String get displayTypeLabel {
    if (typeLabel != null) return typeLabel!;
    if (isWorkshop) return 'Taller';
    if (isWorkshopStore) return 'Taller y Tienda';
    return 'Tienda';
  }

  /// Returns the full address with city.
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (cityName != null && cityName!.isNotEmpty) parts.add(cityName!);
    return parts.join(', ');
  }

  /// Checks if the branch is currently open based on the schedule.
  ///
  /// First checks if there is an active exception for today that overrides
  /// the regular schedule. If an active closed exception covers today,
  /// returns false immediately.
  ///
  /// [schedules] - List of regular schedule details for each day.
  /// [exceptions] - List of schedule exceptions (holidays, special days).
  /// Returns true if currently within opening hours.
  bool isOpenNow(
    List<ScheduleDetailEntity> schedules, [
    List<ScheduleExceptionEntity> exceptions = const [],
  ]) {
    final now = DateTime.now();

    // Check exceptions first — they override the regular schedule
    final exception = _findOverridingException(exceptions, now);
    if (exception != null) {
      if (exception.isClosed) return false;
      return _isWithinTimeRange(
        now,
        exception.openingTime,
        exception.closingTime,
      );
    }

    // No applicable exception — check regular schedule
    final todaySchedules = schedules
        .where((s) => s.dayOfWeek == now.weekday)
        .toList();

    if (todaySchedules.isEmpty) return false;

    for (final schedule in todaySchedules) {
      if (schedule.isClosed) continue;
      if (_isWithinTimeRange(now, schedule.openingTime, schedule.closingTime)) {
        return true;
      }
    }

    return false;
  }

  /// Finds an active exception that covers today's date.
  ScheduleExceptionEntity? _findOverridingException(
    List<ScheduleExceptionEntity> exceptions,
    DateTime now,
  ) {
    final todayOnly = DateTime(now.year, now.month, now.day);

    for (final exception in exceptions) {
      if (!exception.active) continue;

      final startDate = DateTime.tryParse(exception.exceptionStartDate);
      if (startDate == null) continue;

      final endDate =
          DateTime.tryParse(exception.exceptionEndDate) ?? startDate;
      final startOnly = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final endOnly = DateTime(endDate.year, endDate.month, endDate.day);

      if (!todayOnly.isBefore(startOnly) && !todayOnly.isAfter(endOnly)) {
        return exception;
      }
    }

    return null;
  }

  /// Checks if [now] falls within the given opening/closing time range.
  ///
  /// Times are expected in HH:mm format (e.g., "08:00", "18:00").
  bool _isWithinTimeRange(
    DateTime now,
    String openingTime,
    String closingTime,
  ) {
    final openParts = openingTime.split(':');
    final closeParts = closingTime.split(':');

    if (openParts.length < 2 || closeParts.length < 2) return false;

    final openTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(openParts[0]) ?? 0,
      int.tryParse(openParts[1]) ?? 0,
    );
    final closeTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.tryParse(closeParts[0]) ?? 0,
      int.tryParse(closeParts[1]) ?? 0,
    );

    return now.isAfter(openTime) && now.isBefore(closeTime);
  }

  /// Gets today's schedule formatted as a string.
  String getTodaySchedule(List<ScheduleDetailEntity> schedules) {
    final now = DateTime.now();
    final todaySchedules = schedules
        .where((s) => s.dayOfWeek == now.weekday)
        .toList();

    if (todaySchedules.isEmpty) return 'No disponible';

    final activeSchedule = todaySchedules.firstWhere(
      (s) => !s.isClosed,
      orElse: () => todaySchedules.first,
    );

    return activeSchedule.displayTimeRange;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    typeLabel,
    profileImageUrl,
    address,
    cityName,
    departmentName,
    phoneNumber,
    latitude,
    longitude,
    displacementRanges,
  ];
}
