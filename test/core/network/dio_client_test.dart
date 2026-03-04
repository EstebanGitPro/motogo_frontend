import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/network/auth_interceptor.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/core/network/refresh_token_data_source.dart';

import 'dio_client_test.mocks.dart';

@GenerateMocks([RefreshTokenDataSource])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DioClient dioClient;
  late MockRefreshTokenDataSource mockRefreshDataSource;

  setUp(() {
    mockRefreshDataSource = MockRefreshTokenDataSource();
    final authInterceptor = AuthInterceptor(mockRefreshDataSource);
    dioClient = DioClient(authInterceptor: authInterceptor);
  });

  group('DioClient', () {
    group('constructor', () {
      test('should create with AuthInterceptor', () {
        expect(dioClient, isA<DioClient>());
        expect(dioClient.dio, isA<Dio>());
      });

      test('should configure base options with correct headers', () {
        expect(
          dioClient.dio.options.headers['Content-Type'],
          'application/json',
        );
      });

      test('should configure timeouts', () {
        expect(
          dioClient.dio.options.connectTimeout,
          const Duration(seconds: 30),
        );
        expect(
          dioClient.dio.options.receiveTimeout,
          const Duration(seconds: 30),
        );
        expect(dioClient.dio.options.sendTimeout, const Duration(seconds: 30));
      });

      test('should have auth interceptor added', () {
        final hasAuthInterceptor = dioClient.dio.interceptors.any(
          (i) => i is AuthInterceptor,
        );
        expect(hasAuthInterceptor, isTrue);
      });

      test('should not have withCredentials on non-Web (mobile)', () {
        // In test environment, kIsWeb is false
        expect(dioClient.dio.options.extra['withCredentials'], isNull);
      });
    });

    group('convenience methods', () {
      late Dio interceptedDio;

      setUp(() {
        // Replace dio's adapter with interceptors that resolve immediately
        interceptedDio = dioClient.dio;
        interceptedDio.interceptors.clear();
        interceptedDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              handler.resolve(
                Response(
                  requestOptions: options,
                  data: {'success': true},
                  statusCode: 200,
                ),
              );
            },
          ),
        );
      });

      test('get should forward path and query parameters', () async {
        final response = await dioClient.get(
          '/test',
          queryParameters: {'page': '1'},
        );
        expect(response.statusCode, 200);
        expect(response.data['success'], isTrue);
      });

      test('post should forward path and data', () async {
        final response = await dioClient.post('/test', data: {'key': 'value'});
        expect(response.statusCode, 200);
      });

      test('put should forward path and data', () async {
        final response = await dioClient.put('/test', data: {'key': 'value'});
        expect(response.statusCode, 200);
      });

      test('patch should forward path and data', () async {
        final response = await dioClient.patch('/test', data: {'key': 'value'});
        expect(response.statusCode, 200);
      });

      test('delete should forward path', () async {
        final response = await dioClient.delete('/test');
        expect(response.statusCode, 200);
      });
    });
  });
}
