import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/features/register_person/data/datasources/register_person_data_source.dart';
import 'package:motogo_frontend/src/features/register_person/domain/entities/register_person_params.dart';

import 'register_person_data_source_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  late RegisterPersonDataSource dataSource;
  late MockDio mockDio;

  const testParams = RegisterPersonParams(
    identityNumber: '1234567890',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    password: 'Password123!',
    role: 'USER',
  );

  const testParamsWithSecondLastName = RegisterPersonParams(
    identityNumber: '1234567890',
    firstName: 'Juan',
    lastName: 'Pérez',
    secondLastName: 'García',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    password: 'Password123!',
    role: 'USER',
  );

  setUp(() {
    mockDio = MockDio();
    dataSource = RegisterPersonDataSource(dio: mockDio);
  });

  group('RegisterPersonDataSource', () {
    group('registerPerson', () {
      test(
        'should return PersonModel when response is 201 with full data',
        () async {
          // Arrange
          final responseData = {
            'data': {
              'id': 'person-1',
              'identity_number': '1234567890',
              'first_name': 'Juan',
              'last_name': 'Pérez',
              'email': 'juan@test.com',
              'phone_number': '3001234567',
              'email_verified': false,
              'phone_number_verified': false,
              'role': 'USER',
            },
          };

          when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
            (_) async => Response(
              data: responseData,
              statusCode: 201,
              requestOptions: RequestOptions(path: '/persons'),
            ),
          );

          // Act
          final result = await dataSource.registerPerson(testParams);

          // Assert
          expect(result.isRight, isTrue);
          expect(result.right.firstName, 'Juan');
          expect(result.right.email, 'juan@test.com');
          verify(mockDio.post('/persons', data: anyNamed('data'))).called(1);
        },
      );

      test('should return PersonModel when response is 200', () async {
        final responseData = {
          'id': 'person-1',
          'identity_number': '1234567890',
          'first_name': 'Juan',
          'last_name': 'Pérez',
          'email': 'juan@test.com',
          'phone_number': '3001234567',
          'email_verified': false,
          'phone_number_verified': false,
          'role': 'USER',
        };

        when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/persons'),
          ),
        );

        final result = await dataSource.registerPerson(testParams);

        expect(result.isRight, isTrue);
        expect(result.right.identityNumber, '1234567890');
      });

      test('should build fallback PersonModel from Location header '
          'when response has no full person data', () async {
        when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: {'success': true},
            statusCode: 201,
            headers: Headers.fromMap({
              'location': ['/persons/derived-id-123'],
            }),
            requestOptions: RequestOptions(path: '/persons'),
          ),
        );

        final result = await dataSource.registerPerson(testParams);

        expect(result.isRight, isTrue);
        expect(result.right.id, 'derived-id-123');
        expect(result.right.firstName, 'Juan');
      });

      test(
        'should derive id from _links when Location header is absent',
        () async {
          final responseData = {
            '_links': [
              {'rel': 'self', 'href': '/api/persons/link-derived-id'},
            ],
          };

          when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
            (_) async => Response(
              data: responseData,
              statusCode: 201,
              requestOptions: RequestOptions(path: '/persons'),
            ),
          );

          final result = await dataSource.registerPerson(testParams);

          expect(result.isRight, isTrue);
          expect(result.right.id, 'link-derived-id');
        },
      );

      test(
        'should return empty id when no Location header and no _links',
        () async {
          when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
            (_) async => Response(
              data: {'success': true},
              statusCode: 201,
              requestOptions: RequestOptions(path: '/persons'),
            ),
          );

          final result = await dataSource.registerPerson(testParams);

          expect(result.isRight, isTrue);
          expect(result.right.id, '');
        },
      );

      test(
        'should include secondLastName in request body when provided',
        () async {
          Map<String, dynamic>? capturedBody;
          when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer((
            invocation,
          ) async {
            capturedBody =
                invocation.namedArguments[const Symbol('data')]
                    as Map<String, dynamic>;
            return Response(
              data: {
                'id': 'person-1',
                'identity_number': '1234567890',
                'first_name': 'Juan',
                'last_name': 'Pérez',
                'second_last_name': 'García',
                'email': 'juan@test.com',
                'phone_number': '3001234567',
                'email_verified': false,
                'phone_number_verified': false,
                'role': 'USER',
              },
              statusCode: 201,
              requestOptions: RequestOptions(path: '/persons'),
            );
          });

          await dataSource.registerPerson(testParamsWithSecondLastName);

          expect(capturedBody, isNotNull);
          expect(capturedBody!['second_last_name'], 'García');
        },
      );

      test('should return ErrorModel on non-success status code', () async {
        when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: {'message': 'Email ya registrado'},
            statusCode: 409,
            requestOptions: RequestOptions(path: '/persons'),
          ),
        );

        final result = await dataSource.registerPerson(testParams);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on non-map error response', () async {
        when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: 'Internal Server Error',
            statusCode: 500,
            requestOptions: RequestOptions(path: '/persons'),
          ),
        );

        final result = await dataSource.registerPerson(testParams);

        expect(result.isLeft, isTrue);
      });

      test('should handle DioException', () async {
        when(mockDio.post('/persons', data: anyNamed('data'))).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/persons'),
          ),
        );

        final result = await dataSource.registerPerson(testParams);

        expect(result.isLeft, isTrue);
      });

      test('should handle generic exceptions', () async {
        when(
          mockDio.post('/persons', data: anyNamed('data')),
        ).thenThrow(Exception('Unexpected error'));

        final result = await dataSource.registerPerson(testParams);

        expect(result.isLeft, isTrue);
      });

      test('should return empty id when _links has no self rel', () async {
        final responseData = {
          '_links': [
            {'rel': 'other', 'href': '/api/other/123'},
          ],
        };

        when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/persons'),
          ),
        );

        final result = await dataSource.registerPerson(testParams);

        expect(result.isRight, isTrue);
        // self link not found, falls back to empty
        expect(result.right.id, '');
      });

      test('should return empty id when _links self href is empty', () async {
        final responseData = {
          '_links': [
            {'rel': 'self', 'href': ''},
          ],
        };

        when(mockDio.post('/persons', data: anyNamed('data'))).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: '/persons'),
          ),
        );

        final result = await dataSource.registerPerson(testParams);

        expect(result.isRight, isTrue);
        expect(result.right.id, '');
      });
    });
  });
}
