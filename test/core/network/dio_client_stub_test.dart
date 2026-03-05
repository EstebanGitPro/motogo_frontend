import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:motogo_frontend/src/core/network/dio_client_stub.dart';

void main() {
  group('configureWebCredentials (stub)', () {
    test('should be a no-op on non-Web platforms', () {
      final dio = Dio();
      final originalAdapter = dio.httpClientAdapter;

      // Should not throw and should not change the adapter
      configureWebCredentials(dio);

      expect(dio.httpClientAdapter, same(originalAdapter));
    });

    test('should accept any Dio instance without errors', () {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost'));

      // Should complete without throwing
      expect(() => configureWebCredentials(dio), returnsNormally);
    });
  });
}
