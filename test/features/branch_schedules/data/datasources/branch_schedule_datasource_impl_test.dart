import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/branch_schedules/data/datasources/branch_schedule_datasource_impl.dart';

import 'branch_schedule_datasource_impl_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late BranchScheduleDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  dynamic createResponse(dynamic data) {
    return Response(
      data: data,
      requestOptions: RequestOptions(path: ''),
    );
  }

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = BranchScheduleDataSourceImpl(mockDioClient);
  });

  const testBranchId = 'branch-123';

  group('BranchScheduleDataSourceImpl', () {
    // ─── getSchedule ──────────────────────────────────────────────

    group('getSchedule', () {
      test('should return ScheduleModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'id': 'sched-1',
            'branch_id': testBranchId,
            'active': true,
            'start_date': '2026-01-01',
            'end_date': '2026-12-31',
          },
        };

        when(
          mockDioClient.get('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isNotNull);
        expect(result.right!.id, 'sched-1');
        expect(result.right!.active, isTrue);
      });

      test('should return null when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isNull);
      });

      test('should return null on 404', () async {
        when(mockDioClient.get('/branches/$testBranchId/schedules')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isNull);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on non-404 DioException', () async {
        when(mockDioClient.get('/branches/$testBranchId/schedules')).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/schedules'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return null when response is not Map', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isNull);
      });
    });

    // ─── createSchedule ───────────────────────────────────────────

    group('createSchedule', () {
      test('should return schedule and message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Horario creado exitosamente',
          'data': {'id': 'sched-1', 'branch_id': testBranchId, 'active': true},
        };

        when(
          mockDioClient.post('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.$1.id, 'sched-1');
        expect(result.right.$2, 'Horario creado exitosamente');
      });

      test('should return fallback when data is null', () async {
        final responseData = {
          'success': true,
          'message': 'Horario creado exitosamente',
        };

        when(
          mockDioClient.post('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.$1.branchId, testBranchId);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.post('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.createSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.post('/branches/$testBranchId/schedules')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.createSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── updateSchedule ───────────────────────────────────────────

    group('updateSchedule', () {
      test('should return schedule and message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Horario actualizado exitosamente',
          'data': {'id': 'sched-1', 'branch_id': testBranchId, 'active': true},
        };

        when(
          mockDioClient.put(
            '/branches/$testBranchId/schedules',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateSchedule(
          testBranchId,
          active: true,
          startDate: DateTime(2026, 1, 1),
        );

        expect(result.isRight, isTrue);
        expect(result.right.$2, 'Horario actualizado exitosamente');
      });

      test('should return fallback when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.put(
            '/branches/$testBranchId/schedules',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateSchedule(testBranchId);

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put(
            '/branches/$testBranchId/schedules',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.put(
            '/branches/$testBranchId/schedules',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.updateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put(
            '/branches/$testBranchId/schedules',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.updateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deleteSchedule ───────────────────────────────────────────

    group('deleteSchedule', () {
      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Horario eliminado exitosamente',
        };

        when(
          mockDioClient.delete('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, 'Horario eliminado exitosamente');
      });

      test(
        'should return default message when no message in response',
        () async {
          when(
            mockDioClient.delete('/branches/$testBranchId/schedules'),
          ).thenAnswer((_) async => createResponse({'success': true}));

          final result = await dataSource.deleteSchedule(testBranchId);

          expect(result.isRight, isTrue);
        },
      );

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.delete('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.deleteSchedule(testBranchId);

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete('/branches/$testBranchId/schedules'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete('/branches/$testBranchId/schedules'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deleteSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── activateSchedule ─────────────────────────────────────────

    group('activateSchedule', () {
      test('should return schedule and message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Horario activado exitosamente',
          'data': {'id': 'sched-1', 'branch_id': testBranchId, 'active': true},
        };

        when(
          mockDioClient.put('/branches/$testBranchId/schedules/activate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.activateSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.$1.active, isTrue);
      });

      test('should return fallback when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.put('/branches/$testBranchId/schedules/activate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.activateSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.$1.active, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put('/branches/$testBranchId/schedules/activate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.activateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.put('/branches/$testBranchId/schedules/activate'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.activateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put('/branches/$testBranchId/schedules/activate'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.activateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deactivateSchedule ───────────────────────────────────────

    group('deactivateSchedule', () {
      test('should return schedule and message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Horario desactivado exitosamente',
          'data': {'id': 'sched-1', 'branch_id': testBranchId, 'active': false},
        };

        when(
          mockDioClient.put('/branches/$testBranchId/schedules/deactivate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deactivateSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.$1.active, isFalse);
      });

      test('should return fallback when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.put('/branches/$testBranchId/schedules/deactivate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deactivateSchedule(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.$1.active, isFalse);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put('/branches/$testBranchId/schedules/deactivate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deactivateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put('/branches/$testBranchId/schedules/deactivate'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deactivateSchedule(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── getDaysCatalog ───────────────────────────────────────────

    group('getDaysCatalog', () {
      test('should return list of DayModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'days': [
              {'id': 1, 'name': 'Lunes'},
              {'id': 2, 'name': 'Martes'},
            ],
          },
        };

        when(
          mockDioClient.get('/schedules/days'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDaysCatalog();

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(2));
      });

      test('should return empty list when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/schedules/days'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDaysCatalog();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when days is null', () async {
        final responseData = {'success': true, 'data': <String, dynamic>{}};

        when(
          mockDioClient.get('/schedules/days'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDaysCatalog();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get('/schedules/days'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getDaysCatalog();

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/schedules/days')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getDaysCatalog();

        expect(result.isLeft, isTrue);
      });

      test('should return empty list when response is not Map', () async {
        when(
          mockDioClient.get('/schedules/days'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getDaysCatalog();

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });
    });

    // ─── getScheduleDetails ───────────────────────────────────────

    group('getScheduleDetails', () {
      test('should return list of ScheduleDetailModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'details': [
              {
                'id': 'detail-1',
                'schedule_id': 'sched-1',
                'day_of_week': 1,
                'day_name': 'Lunes',
                'opening_time': '08:00',
                'closing_time': '17:00',
                'is_closed': false,
                'active': true,
              },
            ],
          },
        };

        when(
          mockDioClient.get('/branches/$testBranchId/schedules/details'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getScheduleDetails(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
        expect(result.right[0].dayName, 'Lunes');
      });

      test('should return empty list when data is not Map', () async {
        final responseData = {'success': true, 'data': 'not a map'};

        when(
          mockDioClient.get('/branches/$testBranchId/schedules/details'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getScheduleDetails(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list on 404', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/schedules/details'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getScheduleDetails(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get('/branches/$testBranchId/schedules/details'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getScheduleDetails(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on non-404 DioException', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/schedules/details'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getScheduleDetails(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── createScheduleDetail ─────────────────────────────────────

    group('createScheduleDetail', () {
      test('should return detail and message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Franja horaria creada exitosamente',
          'data': {
            'id': 'detail-1',
            'schedule_id': 'sched-1',
            'day_of_week': 1,
            'day_name': 'Lunes',
            'opening_time': '08:00',
            'closing_time': '17:00',
            'is_closed': false,
            'active': true,
          },
        };

        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/details',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createScheduleDetail(
          testBranchId,
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '17:00',
          isClosed: false,
        );

        expect(result.isRight, isTrue);
        expect(result.right.$2, 'Franja horaria creada exitosamente');
      });

      test('should return ErrorModel when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/details',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createScheduleDetail(
          testBranchId,
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '17:00',
          isClosed: false,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/details',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createScheduleDetail(
          testBranchId,
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '17:00',
          isClosed: false,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/details',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.createScheduleDetail(
          testBranchId,
          dayOfWeek: 1,
          openingTime: '08:00',
          closingTime: '17:00',
          isClosed: false,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── updateScheduleDetail ─────────────────────────────────────

    group('updateScheduleDetail', () {
      const testDetailId = 'detail-123';

      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Franja horaria actualizada exitosamente',
        };

        when(
          mockDioClient.put(
            '/schedule-details/$testDetailId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateScheduleDetail(
          testDetailId,
          openingTime: '09:00',
          closingTime: '18:00',
          isClosed: false,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Franja horaria actualizada exitosamente');
      });

      test(
        'should return default message when no message in response',
        () async {
          when(
            mockDioClient.put(
              '/schedule-details/$testDetailId',
              data: anyNamed('data'),
            ),
          ).thenAnswer((_) async => createResponse({'success': true}));

          final result = await dataSource.updateScheduleDetail(
            testDetailId,
            openingTime: '09:00',
            closingTime: '18:00',
            isClosed: false,
          );

          expect(result.isRight, isTrue);
        },
      );

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.put(
            '/schedule-details/$testDetailId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.updateScheduleDetail(
          testDetailId,
          openingTime: '09:00',
          closingTime: '18:00',
          isClosed: false,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put(
            '/schedule-details/$testDetailId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateScheduleDetail(
          testDetailId,
          openingTime: '09:00',
          closingTime: '18:00',
          isClosed: false,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put(
            '/schedule-details/$testDetailId',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.updateScheduleDetail(
          testDetailId,
          openingTime: '09:00',
          closingTime: '18:00',
          isClosed: false,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deleteScheduleDetail ─────────────────────────────────────

    group('deleteScheduleDetail', () {
      const testDetailId = 'detail-123';

      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Franja horaria eliminada exitosamente',
        };

        when(
          mockDioClient.delete('/schedule-details/$testDetailId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteScheduleDetail(testDetailId);

        expect(result.isRight, isTrue);
        expect(result.right, 'Franja horaria eliminada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.delete('/schedule-details/$testDetailId'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.deleteScheduleDetail(testDetailId);

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete('/schedule-details/$testDetailId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteScheduleDetail(testDetailId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.delete('/schedule-details/$testDetailId')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deleteScheduleDetail(testDetailId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── getScheduleExceptions ────────────────────────────────────

    group('getScheduleExceptions', () {
      test('should return list of exceptions on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'exceptions': [
              {
                'id': 'exc-1',
                'schedule_id': 'sched-1',
                'exception_start_date': '2026-03-01',
                'exception_end_date': '2026-03-02',
                'exception_start_date_formatted': '1 de marzo de 2026',
                'day_name': 'Domingo',
                'opening_time': '00:00',
                'closing_time': '00:00',
                'is_closed': true,
                'active': true,
              },
            ],
          },
        };

        when(
          mockDioClient.get('/branches/$testBranchId/schedules/exceptions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getScheduleExceptions(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, hasLength(1));
      });

      test('should return empty list on 404', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/schedules/exceptions'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ),
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getScheduleExceptions(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return empty list when data is not Map', () async {
        final responseData = {'success': true, 'data': 'not a map'};

        when(
          mockDioClient.get('/branches/$testBranchId/schedules/exceptions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getScheduleExceptions(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right, isEmpty);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get('/branches/$testBranchId/schedules/exceptions'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getScheduleExceptions(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on non-404 DioException', () async {
        when(
          mockDioClient.get('/branches/$testBranchId/schedules/exceptions'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getScheduleExceptions(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });

    // ─── createScheduleException ──────────────────────────────────

    group('createScheduleException', () {
      test('should return exception and message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Excepción creada exitosamente',
          'data': {
            'id': 'exc-1',
            'schedule_id': 'sched-1',
            'exception_start_date': '2026-03-01',
            'exception_end_date': '',
            'exception_start_date_formatted': '1 de marzo',
            'day_name': 'Domingo',
            'opening_time': '00:00',
            'closing_time': '00:00',
            'is_closed': true,
            'active': true,
          },
        };

        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/exceptions',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createScheduleException(
          testBranchId,
          exceptionStartDate: '2026-03-01',
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
        );

        expect(result.isRight, isTrue);
        expect(result.right.$2, 'Excepción creada exitosamente');
      });

      test('should return ErrorModel when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/exceptions',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createScheduleException(
          testBranchId,
          exceptionStartDate: '2026-03-01',
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/exceptions',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.createScheduleException(
          testBranchId,
          exceptionStartDate: '2026-03-01',
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.post(
            '/branches/$testBranchId/schedules/exceptions',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.createScheduleException(
          testBranchId,
          exceptionStartDate: '2026-03-01',
          openingTime: '00:00',
          closingTime: '00:00',
          isClosed: true,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── updateScheduleException ──────────────────────────────────

    group('updateScheduleException', () {
      const testExceptionId = 'exc-123';

      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Excepción actualizada exitosamente',
        };

        when(
          mockDioClient.put(
            '/schedule-exceptions/$testExceptionId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateScheduleException(
          testExceptionId,
          openingTime: '09:00',
          closingTime: '13:00',
          isClosed: false,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Excepción actualizada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.put(
            '/schedule-exceptions/$testExceptionId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.updateScheduleException(
          testExceptionId,
          openingTime: '09:00',
          closingTime: '13:00',
          isClosed: false,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put(
            '/schedule-exceptions/$testExceptionId',
            data: anyNamed('data'),
          ),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.updateScheduleException(
          testExceptionId,
          openingTime: '09:00',
          closingTime: '13:00',
          isClosed: false,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put(
            '/schedule-exceptions/$testExceptionId',
            data: anyNamed('data'),
          ),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.updateScheduleException(
          testExceptionId,
          openingTime: '09:00',
          closingTime: '13:00',
          isClosed: false,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deleteScheduleException ──────────────────────────────────

    group('deleteScheduleException', () {
      const testExceptionId = 'exc-123';

      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Excepción eliminada exitosamente',
        };

        when(
          mockDioClient.delete('/schedule-exceptions/$testExceptionId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteScheduleException(
          testExceptionId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Excepción eliminada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.delete('/schedule-exceptions/$testExceptionId'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.deleteScheduleException(
          testExceptionId,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.delete('/schedule-exceptions/$testExceptionId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deleteScheduleException(
          testExceptionId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.delete('/schedule-exceptions/$testExceptionId'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deleteScheduleException(
          testExceptionId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── activateScheduleException ────────────────────────────────

    group('activateScheduleException', () {
      const testExceptionId = 'exc-123';

      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Excepción activada exitosamente',
        };

        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/activate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.activateScheduleException(
          testExceptionId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Excepción activada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/activate'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.activateScheduleException(
          testExceptionId,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/activate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.activateScheduleException(
          testExceptionId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/activate'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.activateScheduleException(
          testExceptionId,
        );

        expect(result.isLeft, isTrue);
      });
    });

    // ─── deactivateScheduleException ──────────────────────────────

    group('deactivateScheduleException', () {
      const testExceptionId = 'exc-123';

      test('should return message on success', () async {
        final responseData = {
          'success': true,
          'message': 'Excepción desactivada exitosamente',
        };

        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/deactivate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deactivateScheduleException(
          testExceptionId,
        );

        expect(result.isRight, isTrue);
        expect(result.right, 'Excepción desactivada exitosamente');
      });

      test('should return default when response is not Map', () async {
        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/deactivate'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.deactivateScheduleException(
          testExceptionId,
        );

        expect(result.isRight, isTrue);
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/deactivate'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.deactivateScheduleException(
          testExceptionId,
        );

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(
          mockDioClient.put('/schedule-exceptions/$testExceptionId/deactivate'),
        ).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.deactivateScheduleException(
          testExceptionId,
        );

        expect(result.isLeft, isTrue);
      });
    });
  });
}
