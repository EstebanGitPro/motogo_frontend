import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/change_password/data/datasources/change_password_data_source.dart';
import 'package:motogo_frontend/src/features/change_password/data/repositories/change_password_repository_impl.dart';

import 'change_password_repository_impl_test.mocks.dart';

@GenerateMocks([ChangePasswordDataSource])
void main() {
  late ChangePasswordRepositoryImpl repository;
  late MockChangePasswordDataSource mockDataSource;

  setUpAll(() {
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockDataSource = MockChangePasswordDataSource();
    repository = ChangePasswordRepositoryImpl(mockDataSource);
  });

  group('ChangePasswordRepositoryImpl', () {
    const currentPassword = 'oldPassword123';
    const newPassword = 'newPassword456';

    group('changePassword', () {
      // Note: Testing the actual token retrieval from UserSessionManager
      // would require integration testing. These tests focus on the
      // repository's behavior when a session exists.

      test('should return ErrorModel when no session is active', () async {
        // Act
        // UserSessionManager.instance.accessToken will be null in test
        final result = await repository.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );

        // Assert
        expect(result.isLeft, isTrue);
        expect(result.left.message, 'No hay sesión activa');
        // DataSource should not be called when no session - use verifyZeroInteractions
        verifyZeroInteractions(mockDataSource);
      });
    });
  });
}
