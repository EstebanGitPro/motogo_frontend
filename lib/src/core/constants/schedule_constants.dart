/// Constants for the branch schedules feature.
///
/// Use these constants instead of hardcoded strings for better maintainability.
class ScheduleConstants {
  // Page titles
  static const String schedulesTitle = 'Horarios';
  static const String schedulesManagementTitle = 'Gestión de Horarios';

  // Status labels
  static const String statusActive = 'Activo';
  static const String statusInactive = 'Inactivo';
  static const String noScheduleConfigured = 'Sin horario configurado';

  // Action buttons
  static const String createSchedule = 'Crear Horario';
  static const String deleteSchedule = 'Eliminar Horario';
  static const String activateSchedule = 'Activar';
  static const String deactivateSchedule = 'Desactivar';

  // Confirmation dialogs
  static const String deleteScheduleTitle = 'Eliminar Horario';
  static const String deleteScheduleMessage =
      '¿Estás seguro de que deseas eliminar la configuración de horario de esta sede?';
  static const String deleteScheduleConfirm = 'Eliminar';
  static const String cancel = 'Cancelar';

  // Success messages
  static const String scheduleCreated = 'Horario creado exitosamente';
  static const String scheduleDeleted = 'Horario eliminado exitosamente';
  static const String scheduleActivated = 'Horario activado exitosamente';
  static const String scheduleDeactivated = 'Horario desactivado exitosamente';
  static const String scheduleUpdated = 'Horario actualizado exitosamente';

  // Error messages
  static const String errorLoadingSchedule = 'Error al cargar el horario';
  static const String errorCreatingSchedule = 'Error al crear el horario';
  static const String errorDeletingSchedule = 'Error al eliminar el horario';
  static const String errorActivatingSchedule = 'Error al activar el horario';
  static const String errorDeactivatingSchedule =
      'Error al desactivar el horario';

  // Loading messages
  static const String loadingSchedule = 'Cargando horario...';

  // Empty state
  static const String emptyScheduleTitle = 'Sin Horario';
  static const String emptyScheduleDescription =
      'Esta sede aún no tiene un horario configurado. Crea uno para comenzar.';

  // Validity dates
  static const String validityPeriod = 'Vigencia';
  static const String validityFrom = 'Desde';
  static const String validityTo = 'Hasta';
  static const String validityIndefinite = 'Indefinido';
  static const String editValidity = 'Editar Vigencia';
  static const String editValidityTitle = 'Editar Fechas de Vigencia';
  static const String startDateLabel = 'Fecha de Inicio';
  static const String endDateLabel = 'Fecha de Fin (Opcional)';
  static const String save = 'Guardar';
  static const String clearEndDate = 'Sin fecha fin';

  // Days of the week
  static const String monday = 'Lunes';
  static const String tuesday = 'Martes';
  static const String wednesday = 'Miércoles';
  static const String thursday = 'Jueves';
  static const String friday = 'Viernes';
  static const String saturday = 'Sábado';
  static const String sunday = 'Domingo';

  // Day values (API)
  static const Map<String, String> dayLabels = {
    'monday': monday,
    'tuesday': tuesday,
    'wednesday': wednesday,
    'thursday': thursday,
    'friday': friday,
    'saturday': saturday,
    'sunday': sunday,
  };

  // === API Constants ===

  // Endpoints
  static const String schedulesEndpoint = '/branches/{branchId}/schedules';
  static const String activateEndpoint =
      '/branches/{branchId}/schedules/activate';
  static const String deactivateEndpoint =
      '/branches/{branchId}/schedules/deactivate';
  static const String daysCatalogEndpoint = '/schedules/days';

  // Error codes
  static const String parseErrorCode = 'PARSE_ERROR';

  // Default fallback messages
  static const String defaultDeleteMessage = 'Horario eliminado';
  static const String parseErrorMessage =
      'Error al procesar respuesta del servidor';

  /// Builds the schedules endpoint for a specific branch.
  static String getSchedulesPath(String branchId) =>
      '/branches/$branchId/schedules';

  /// Builds the activate endpoint for a specific branch.
  static String getActivatePath(String branchId) =>
      '/branches/$branchId/schedules/activate';

  /// Builds the deactivate endpoint for a specific branch.
  static String getDeactivatePath(String branchId) =>
      '/branches/$branchId/schedules/deactivate';
}
