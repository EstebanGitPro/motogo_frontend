import 'package:dio/dio.dart';

/// Stub para plataformas no-Web (Android, iOS).
/// No hace nada — withCredentials solo aplica en Web.
void configureWebCredentials(Dio dio) {
  // No-op en plataformas no-Web
}
