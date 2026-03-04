import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Configura el BrowserHttpClientAdapter para enviar cookies
/// HttpOnly cross-origin en Flutter Web.
///
/// El `extra: {'withCredentials': true}` en BaseOptions NO siempre
/// propaga correctamente al XMLHttpRequest subyacente.
/// Esta configuración directa del adapter es la forma confiable.
void configureWebCredentials(Dio dio) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
