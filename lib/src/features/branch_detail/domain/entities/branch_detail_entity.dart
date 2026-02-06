import 'package:equatable/equatable.dart';
import 'package:motogo_frontend/src/features/branch_schedules/domain/entities/schedule_detail_entity.dart';

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
  });

  /// Returns true if this is a workshop.
  bool get isWorkshop => type == 'taller';

  /// Returns true if this is a store.
  bool get isStore => type == 'tienda';

  /// Returns the display type label.
  String get displayTypeLabel =>
      typeLabel ?? (isWorkshop ? 'Taller' : 'Tienda');

  /// Returns the full address with city.
  String get fullAddress {
    final parts = <String>[];
    if (address != null && address!.isNotEmpty) parts.add(address!);
    if (cityName != null && cityName!.isNotEmpty) parts.add(cityName!);
    return parts.join(', ');
  }

  /// Checks if the branch is currently open based on the schedule.
  ///
  /// [schedules] - List of schedule details for each day.
  /// Returns true if currently within opening hours.
  bool isOpenNow(List<ScheduleDetailEntity> schedules) {
    final now = DateTime.now();
    // weekday: 1 = Monday, 7 = Sunday (same as backend)
    final todaySchedules = schedules
        .where((s) => s.dayOfWeek == now.weekday)
        .toList();

    if (todaySchedules.isEmpty) return false;

    for (final schedule in todaySchedules) {
      if (schedule.isClosed) continue;

      final openParts = schedule.openingTime.split(':');
      final closeParts = schedule.closingTime.split(':');

      if (openParts.length >= 2 && closeParts.length >= 2) {
        final openHour = int.tryParse(openParts[0]) ?? 0;
        final openMinute = int.tryParse(openParts[1]) ?? 0;
        final closeHour = int.tryParse(closeParts[0]) ?? 0;
        final closeMinute = int.tryParse(closeParts[1]) ?? 0;

        final openTime = DateTime(
          now.year,
          now.month,
          now.day,
          openHour,
          openMinute,
        );
        final closeTime = DateTime(
          now.year,
          now.month,
          now.day,
          closeHour,
          closeMinute,
        );

        if (now.isAfter(openTime) && now.isBefore(closeTime)) {
          return true;
        }
      }
    }

    return false;
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
  ];
}
