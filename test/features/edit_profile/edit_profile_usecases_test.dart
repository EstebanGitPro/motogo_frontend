import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/core/user/domain/entities/user_entity.dart';
import 'package:motogo_frontend/src/core/user/domain/repositories/user_session_repository.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/get_person_usecase.dart';
import 'package:motogo_frontend/src/features/edit_profile/domain/usecases/update_person_usecase.dart';

import 'edit_profile_usecases_test.mocks.dart';

@GenerateMocks([UserSessionRepository])
void main() {
  late MockUserSessionRepository mockRepository;

  final testUser = UserEntity(
    id: 'user-1',
    identityNumber: '1234567890',
    firstName: 'Juan',
    lastName: 'Pérez',
    email: 'juan@test.com',
    phoneNumber: '3001234567',
    role: 'USER',
  );
  final errorModel = ErrorModel(message: 'Error', errorCode: 'ERR');

  setUpAll(() {
    provideDummy<Either<ErrorModel, UserEntity>>(Right(testUser));
    provideDummy<Either<ErrorModel, String>>(const Right(''));
  });

  setUp(() {
    mockRepository = MockUserSessionRepository();
  });

  group('GetPersonUsecase', () {
    late GetPersonUsecase useCase;

    setUp(() {
      useCase = GetPersonUsecase(mockRepository);
    });

    test('should return UserEntity on success', () async {
      when(
        mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => Right(testUser));

      final result = await useCase.call();

      expect(result.isRight, isTrue);
      expect(result.right.firstName, 'Juan');
      verify(mockRepository.getCurrentUser()).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call();

      expect(result.isLeft, isTrue);
      expect(result.left, errorModel);
    });
  });

  group('UpdatePersonUsecase', () {
    late UpdatePersonUsecase useCase;

    setUp(() {
      useCase = UpdatePersonUsecase(mockRepository);
    });

    test('should return success message on success', () async {
      when(
        mockRepository.updateCurrentUser(testUser),
      ).thenAnswer((_) async => const Right('Perfil actualizado'));

      final result = await useCase.call(testUser);

      expect(result.isRight, isTrue);
      expect(result.right, 'Perfil actualizado');
      verify(mockRepository.updateCurrentUser(testUser)).called(1);
    });

    test('should return ErrorModel on failure', () async {
      when(
        mockRepository.updateCurrentUser(testUser),
      ).thenAnswer((_) async => Left(errorModel));

      final result = await useCase.call(testUser);

      expect(result.isLeft, isTrue);
    });
  });
}
