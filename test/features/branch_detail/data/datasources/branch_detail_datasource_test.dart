import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/network/dio_client.dart';
import 'package:motogo_frontend/src/features/branch_detail/data/datasources/branch_detail_datasource.dart';

import 'branch_detail_datasource_test.mocks.dart';

@GenerateMocks([DioClient])
void main() {
  late BranchDetailDataSourceImpl dataSource;
  late MockDioClient mockDioClient;

  dynamic createResponse(dynamic data) {
    return Response(
      data: data,
      requestOptions: RequestOptions(path: ''),
    );
  }

  setUp(() {
    mockDioClient = MockDioClient();
    dataSource = BranchDetailDataSourceImpl(mockDioClient);
  });

  const testBranchId = 'branch-123';

  group('BranchDetailDataSourceImpl', () {
    group('getBranchDetail', () {
      test('should return BranchDetailModel on success', () async {
        final responseData = {
          'success': true,
          'data': {
            'id': testBranchId,
            'name': 'Taller Central',
            'type': 'taller',
            'address': 'Calle 1',
            'latitude': 4.6,
            'longitude': -74.0,
          },
        };

        when(
          mockDioClient.get('/branches/$testBranchId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getBranchDetail(testBranchId);

        expect(result.isRight, isTrue);
        expect(result.right.name, 'Taller Central');
      });

      test('should return ErrorModel when success is false', () async {
        final responseData = {
          'success': false,
          'code': 'ERR',
          'message': 'Error',
        };

        when(
          mockDioClient.get('/branches/$testBranchId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getBranchDetail(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when data is null', () async {
        final responseData = {'success': true};

        when(
          mockDioClient.get('/branches/$testBranchId'),
        ).thenAnswer((_) async => createResponse(responseData));

        final result = await dataSource.getBranchDetail(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel when response is not Map', () async {
        when(
          mockDioClient.get('/branches/$testBranchId'),
        ).thenAnswer((_) async => createResponse('not a map'));

        final result = await dataSource.getBranchDetail(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on DioException', () async {
        when(mockDioClient.get('/branches/$testBranchId')).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            requestOptions: RequestOptions(path: ''),
          ),
        );

        final result = await dataSource.getBranchDetail(testBranchId);

        expect(result.isLeft, isTrue);
      });

      test('should return ErrorModel on generic exception', () async {
        when(
          mockDioClient.get('/branches/$testBranchId'),
        ).thenThrow(Exception('Network error'));

        final result = await dataSource.getBranchDetail(testBranchId);

        expect(result.isLeft, isTrue);
      });
    });
  });
}
