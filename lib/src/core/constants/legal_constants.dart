/// Constants for the Legal module.
///
/// Contains strings for legal information, privacy policy, terms of service,
/// and the full Terms & Conditions document adapted for MotoGo.
class LegalConstants {
  // ── App identity ───────────────────────────────────────────────────────
  static const String appName = 'MotosGo';
  static const String appSlogan = 'Tu compañero de ruta';
  static const String documentVersion = '1.0';
  static const String lastUpdated = 'Última actualización: febrero de 2026';
  static const String effectiveDate =
      'Fecha de entrada en vigor: febrero de 2026';
  static const String contactEmail = 'estebanpoly.e.a@gmail.com';
  static const String jurisdiction = 'Pereira, Risaralda, Colombia';

  // ── Page title ─────────────────────────────────────────────────────────
  static const String pageTitle = 'Acerca de y Legal';
  static const String termsPageTitle = 'Términos y Condiciones de Uso';

  // ── Section titles ─────────────────────────────────────────────────────
  static const String sectionAbout = 'Acerca de';
  static const String sectionTermsAndConditions =
      'Términos y condiciones de uso';
  static const String sectionPrivacyPolicy = 'Política de privacidad';
  static const String sectionDataTreatment = 'Tratamiento de datos personales';
  static const String sectionSecurity = 'Seguridad de la información';
  static const String sectionLicenses = 'Licencias y créditos';

  // ── Section bodies ─────────────────────────────────────────────────────
  static const String aboutBody =
      'MotosGo es una plataforma digital que conecta motociclistas con '
      'talleres de servicio, permitiendo localizar sedes cercanas, '
      'consultar servicios disponibles, calificar experiencias y '
      'gestionar el historial de sus motocicletas.';

  static const String licensesBody =
      'Motorcycle icons created by sonnycandra - Flaticon. '
      'Fuente: https://www.flaticon.com/free-icons/motorcycle';

  // ── MinTIC external link ───────────────────────────────────────────────
  static const String minticTermsUrl =
      'https://www.mintic.gov.co/portal/inicio/Secciones-auxiliares/'
      'Politicas/2627:Politicas-de-Privacidad-y-Condiciones-de-Uso';

  // ── T&C sections ───────────────────────────────────────────────────────

  static const String tcDefiniciones = '''
Para efectos de estos Términos y Condiciones, se entiende por:

• "Aplicación" o "App": El software móvil MotosGo disponible para dispositivos Android/iOS.
• "Usuario" o "Titular": Persona natural que se registra y utiliza la Aplicación.
• "Taller" o "Prestador": Establecimiento de servicios para motocicletas afiliado a la plataforma.
• "Contenido": Calificaciones, reseñas, comentarios, fotos y cualquier información publicada por el Usuario.
• "Datos Personales": Información vinculada o asociable a una persona natural.
• "Datos Sensibles": Datos que afectan la intimidad o cuyo uso indebido puede generar discriminación, incluyendo: documento de identidad, datos biométricos y ubicación geográfica precisa.
• "Responsable del Tratamiento": El equipo de desarrollo de MotosGo, quien decide sobre el tratamiento de los datos.
• "Encargado del Tratamiento": Terceros que realizan tratamiento de datos por cuenta del Responsable.''';

  static const String tcObjeto = '''
La Aplicación es una plataforma digital que permite a los usuarios motociclistas:

1. Localizar talleres de servicio cercanos a su posición geográfica.
2. Filtrar talleres por tipo de servicio, calificación, distancia y disponibilidad.
3. Visualizar rutas de acceso a los talleres seleccionados.
4. Calificar y reseñar los servicios recibidos.
5. Registrar información de sus motocicletas para historial de servicios.

El Usuario reconoce que la Aplicación funciona como intermediaria entre el usuario y los talleres, no siendo responsable directa de los servicios prestados por estos últimos.''';

  static const String tcRegistro = '''
Requisitos de registro:
• Ser mayor de 18 años de edad.
• Poseer una motocicleta (propia o bajo su responsabilidad).
• Proporcionar información veraz, exacta y actualizada.
• Aceptar expresamente estos Términos y Condiciones y la Política de Tratamiento de Datos Personales.

Prohibición para menores de edad:
La Aplicación no está dirigida a menores de 18 años. Al registrarse, el Usuario declara y garantiza contar con la mayoría de edad legal. Si se detecta el uso por parte de menores, la cuenta será desactivada sin previo aviso.

Veracidad de la información:
El Usuario es responsable de la veracidad de los datos proporcionados, incluyendo:
• Nombre completo y documento de identidad.
• Información de contacto (correo electrónico y teléfono).
• Datos de la motocicleta, incluyendo placa del vehículo.''';

  static const String tcDatosPersonales = '''
Datos recolectados:

• Identificación: Nombre completo, número de cédula, foto de perfil (Sensibles: cédula y foto).
• Contacto: Correo electrónico, número de celular (Personales).
• Vehículo: Placa, marca, modelo, cilindraje, fotos (Sensibles: placa).
• Ubicación: Coordenadas GPS en tiempo real, historial de búsquedas (Sensibles).
• Uso de la app: Talleres consultados, filtros aplicados, favoritos (Semiprivados).
• Contenido generado: Calificaciones, reseñas, comentarios, fotos de servicios (Personales).

Finalidades del tratamiento:
1. Creación y gestión de la cuenta de usuario.
2. Prestación del servicio principal: geolocalización de talleres, cálculo de rutas, filtrado de información.
3. Registro del vehículo para mantener historial de servicios y garantías.
4. Sistema de calificaciones: publicación y visualización de reseñas.
5. Comunicaciones: notificaciones sobre el servicio, actualizaciones de la app, confirmaciones.
6. Seguridad: verificación de identidad, prevención de fraudes.
7. Mejora continua: análisis estadístico de uso (datos anonimizados).
8. Cumplimiento legal: respuesta a requerimientos de autoridades competentes.

Base legal del tratamiento:
• Ejecución de contrato: Para la prestación de los servicios descritos.
• Consentimiento expreso: Para datos sensibles (cédula, placa, ubicación GPS).
• Interés legítimo: Para seguridad de la plataforma y mejora del servicio.
• Obligación legal: Para cumplimiento de requerimientos judiciales o administrativos.''';

  static const String tcDatosSensibles = '''
El tratamiento de los siguientes datos sensibles requiere autorización explícita e informada adicional:

• Documento de identidad: Verificación de identidad, prevención de cuentas falsas, respuesta a requerimientos legales.
• Placa de la motocicleta: Identificación del vehículo para historial de servicios, garantías y trazabilidad.
• Ubicación geográfica precisa: Funcionalidad esencial de geolocalización de talleres cercanos y cálculo de rutas.
• Fotografía de perfil: Identificación visual en el sistema de calificaciones.''';

  static const String tcCalificaciones = '''
El Usuario puede publicar calificaciones y reseñas sobre los servicios recibidos, comprometiéndose a que dicho contenido:
• Sea veraz y basado en experiencias reales.
• No contenga información falsa, engañosa o difamatoria.
• No infrinja derechos de propiedad intelectual de terceros.
• No incluya datos personales de terceros sin autorización.

Filtro de contenido automático:
• Detección automática: Filtro que identifica palabras obscenas, insultos, lenguaje discriminatorio o violento.
• Bloqueo preventivo: Contenido detectado no se publica automáticamente.
• Notificación al usuario: Informe de rechazo con indicación de modificación.
• Moderación posterior: Revisión de reportes de la comunidad sobre contenido inapropiado.

Contenido prohibido:
Queda estrictamente prohibido publicar contenido que:
• Contenga lenguaje obsceno, ofensivo, discriminatorio o que promueva violencia.
• Sea publicitario no autorizado o spam.
• Viole la privacidad de terceros.
• Sea ilegal o contrario a la moral y buenas costumbres.

Sanciones:
• Eliminación del contenido sin previo aviso.
• Suspensión temporal de la capacidad de publicar reseñas.
• Cancelación definitiva de la cuenta en casos reiterados o graves.''';

  static const String tcServiciosTerceros = '''
Para el funcionamiento de la Aplicación, se utilizan los siguientes tipos de servicios externos que actúan como encargados del tratamiento:

• Servicios de mapas y geolocalización: Visualización cartográfica, cálculo de rutas, geocodificación. Datos compartidos: Coordenadas GPS, direcciones de búsqueda.
• Servicios de envío de correos electrónicos: Notificaciones transaccionales y alertas. Datos compartidos: Dirección de correo, nombre del destinatario, contenido del mensaje.
• Servicios de filtrado de contenido: Detección de lenguaje inapropiado en reseñas. Datos compartidos: Texto de comentarios (procesamiento temporal).
• Servicios de almacenamiento en la nube: Respaldo de imágenes de perfil, vehículos y evidencias. Datos compartidos: Archivos de imagen, metadatos asociados.

Garantías:
• Los servicios externos operan bajo acuerdos que incluyen cláusulas de protección de datos personales.
• Se seleccionan proveedores que cumplan con estándares internacionales de seguridad de la información.
• Los datos solo se comparten para las finalidades específicas descritas, no para fines comerciales propios de los terceros.
• El Responsable mantiene el control sobre los datos en todo momento.''';

  static const String tcDerechosUsuarios = '''
De conformidad con la Ley 1581 de 2012, el Usuario tiene derecho a:

• Conocer: Saber qué datos personales se tienen.
• Acceder: Obtener copia de los datos personales.
• Actualizar: Modificar datos desactualizados.
• Rectificar: Corregir datos inexactos.
• Suprimir: Solicitar eliminación de datos y cuenta.
• Revocar: Retirar la autorización otorgada.
• Oponerse: Negarse al tratamiento para fines específicos.

Procedimiento:
Para ejercer estos derechos, el Usuario debe enviar solicitud a: estebanpoly.e.a@gmail.com

Incluyendo:
• Nombres y apellidos completos
• Número de identificación
• Descripción clara del derecho a ejercer
• Documentos soporte (si aplica)

Tiempos de respuesta:
• Consultas: 10 días hábiles
• Reclamos (actualización, rectificación, supresión): 15 días hábiles (prorrogables 8 días hábiles adicionales)''';

  static const String tcSeguridad = '''
Se implementan las siguientes medidas de seguridad:

• Encriptación SSL/TLS: Para datos en tránsito entre la app y servidores.
• Encriptación de datos sensibles: Para almacenamiento de contraseñas y datos de identificación.
• Control de acceso: Restricción de acceso a datos personales solo para personal autorizado.
• Validación de entradas: Prevención de inyección de código en formularios.
• Filtro de contenido: Moderación automática de reseñas y comentarios.

Limitaciones: Como proyecto en etapa de desarrollo/validación, algunas medidas avanzadas como autenticación de doble factor, backups automatizados formales o planes de respuesta a incidentes certificados se implementarán en fases posteriores de maduración del producto.''';

  static const String tcPropiedadIntelectual = '''
Derechos de la Aplicación:
Todos los derechos de propiedad intelectual sobre la Aplicación, su código fuente, diseño, logos, marcas y contenido propio son de exclusiva propiedad del Responsable.

Licencia de uso:
Se otorga al Usuario una licencia limitada, no exclusiva, intransferible y revocable para usar la Aplicación en sus dispositivos personales, exclusivamente para los fines previstos en estos Términos.

Contenido del Usuario:
Al publicar calificaciones, reseñas o fotos, el Usuario:
• Otorga una licencia no exclusiva para que la Aplicación use, reproduzca y muestre dicho contenido.
• Garantiza tener los derechos sobre el contenido publicado.
• Acepta que las reseñas publicadas puedan permanecer anonimizadas ("Usuario eliminado") si cancela su cuenta.''';

  static const String tcLimitacionResponsabilidad = '''
Intermediación:
La Aplicación actúa como plataforma de intermediación. No es responsable por:
• La calidad de los servicios prestados por los talleres.
• Incumplimientos, daños o perjuicios causados por los prestadores de servicios.
• Contenido publicado por otros usuarios (salvo por moderación diligente).

Disponibilidad del servicio:
No se garantiza disponibilidad ininterrumpida de la Aplicación. Pueden producirse suspensiones por mantenimiento, fallos técnicos o fuerza mayor.

Precisión de la información:
La información de talleres (ubicaciones, horarios, precios) es proporcionada por los mismos prestadores o fuentes públicas. No se garantiza exactitud absoluta.''';

  static const String tcDuracionTerminacion = '''
Duración:
Estos Términos rigen desde el momento del registro hasta la cancelación de la cuenta por cualquiera de las partes.

Terminación por el Usuario:
El Usuario puede eliminar su cuenta en cualquier momento mediante:
• Opción "Eliminar cuenta" en configuración de la app, o
• Solicitud formal por correo electrónico.

Terminación por el Responsable:
Se podrá suspender o cancelar la cuenta por:
• Incumplimiento de estos Términos.
• Uso fraudulento o doloso de la plataforma.
• Publicación de contenido prohibido.
• Inactividad prolongada (más de 2 años).

Efectos de la terminación:
• Se eliminarán los datos personales en un plazo máximo de 10 días hábiles.
• Las reseñas publicadas se anonimizarán (quedarán como "Usuario eliminado").
• Podrán conservarse datos mínimos si existe obligación legal (ej: registros tributarios).''';

  static const String tcModificaciones = '''
El Responsable podrá modificar estos Términos en cualquier momento. Los cambios serán notificados mediante:

• Publicación de la nueva versión en la Aplicación.
• Envío de correo electrónico a los usuarios registrados.
• Notificación push en la app (si está habilitada).

Entrada en vigor: Los cambios surtirán efecto 15 días después de la notificación. El uso continuado de la Aplicación después de ese plazo implica aceptación de los nuevos términos.''';

  static const String tcLegislacion = '''
Estos Términos se rigen por las leyes de la República de Colombia, en especial:

• Ley 1581 de 2012 (Régimen General de Protección de Datos Personales)
• Decreto 1377 de 2013 (Reglamentación parcial de la Ley 1581 de 2012)
• Decreto 1074 de 2015 (Sector Comercio, Industria y Turismo)
• Ley 2301 de 2024 (Ley de Ciberseguridad)
• Resolución 2238 de 2024 del Ministerio de Tecnologías de la Información y las Comunicaciones (como referencia para políticas públicas)

Para efectos de estos Términos, el Responsable tiene domicilio en Pereira, Risaralda, Colombia.''';

  // ── Checkbox labels ────────────────────────────────────────────────────
  static const String checkboxTerms =
      'Acepto los Términos y Condiciones de Uso';
  static const String checkboxSensitiveData =
      'Acepto el tratamiento de mis datos sensibles '
      '(cédula, placa, GPS)';
  static const String checkboxCommercialComms =
      'Deseo recibir comunicaciones comerciales '
      'sobre promociones y novedades';

  // Terms page UI strings
  static const String platformDescription =
      'Plataforma de servicios para motociclistas';
  static const String sensitiveDataDeclaration =
      'Declaración de datos sensibles';
  static const String viewPrivacyPolicy =
      'Ver Políticas de Privacidad y Condiciones de Uso (MinTIC)';
  static const String readAndAccept = 'He leído y acepto';
  static const String contactPrefix = 'Contacto: ';

  // ── Sensitive data consent declaration ──────────────────────────────────
  static const String sensitiveDataConsent =
      'He sido informado de que mi número de cédula, placa de vehículo, '
      'ubicación GPS y fotografía de perfil son datos sensibles según '
      'la Ley 1581 de 2012. Autorizo de forma explícita, previa e '
      'informada su tratamiento para las finalidades descritas en estos '
      'Términos y Condiciones, entendiendo que son necesarios para el '
      'funcionamiento de la aplicación.';

  // ── T&C section titles and content map ─────────────────────────────────
  static const List<Map<String, String>> tcSections = [
    {'title': '1. Definiciones', 'content': tcDefiniciones},
    {'title': '2. Objeto y Descripción del Servicio', 'content': tcObjeto},
    {'title': '3. Registro y Elegibilidad', 'content': tcRegistro},
    {
      'title': '4. Tratamiento de Datos Personales',
      'content': tcDatosPersonales,
    },
    {'title': '5. Tratamiento de Datos Sensibles', 'content': tcDatosSensibles},
    {
      'title': '6. Sistema de Calificaciones y Moderación',
      'content': tcCalificaciones,
    },
    {'title': '7. Servicios de Terceros', 'content': tcServiciosTerceros},
    {'title': '8. Derechos de los Usuarios', 'content': tcDerechosUsuarios},
    {'title': '9. Seguridad de la Información', 'content': tcSeguridad},
    {'title': '10. Propiedad Intelectual', 'content': tcPropiedadIntelectual},
    {
      'title': '11. Limitación de Responsabilidad',
      'content': tcLimitacionResponsabilidad,
    },
    {'title': '12. Duración y Terminación', 'content': tcDuracionTerminacion},
    {'title': '13. Modificaciones', 'content': tcModificaciones},
    {
      'title': '14. Legislación Aplicable y Jurisdicción',
      'content': tcLegislacion,
    },
  ];
}
