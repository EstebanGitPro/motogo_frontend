import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:motogo_frontend/src/core/errors/error_model.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/repositories/email_verification_repository.dart';
import 'package:motogo_frontend/src/features/password_recovery/domain/usecases/verify_email_usecase.dart';

import 'verify_email_usecase_test.mocks.dart';

@GenerateMocks([EmailRecoveryVerificationRepository])
void main() {
  late VerifyRecoveryEmailUseCase useCase;
  late MockEmailRecoveryVerificationRepository mockRepository;

  setUpAll(() {
    provideDummy<Either<ErrorModel, bool>>(const Right(true));
  });

  setUp(() {
    mockRepository = MockEmailRecoveryVerificationRepository();
    useCase = VerifyRecoveryEmailUseCase(mockRepository);
  });

  group('VerifyRecoveryEmailUseCase', () {
    test('should return true when email exists', () async {
      when(
        mockRepository.verifyEmail('test@email.com'),
      ).thenAnswer((_) async => const Right(true));

      final result = await useCase.call('test@email.com');

      expect(result.isRight, isTrue);
      expect(result.right, isTrue);
      verify(mockRepository.verifyEmail('test@email.com')).called(1);
    });

    test('should return false when email does not exist', () async {
      when(
        mockRepository.verifyEmail('unknown@email.com'),
      ).thenAnswer((_) async => const Right(false));

      final result = await useCase.call('unknown@email.com');

      expect(result.isRight, isTrue);
      expect(result.right, isFalse);
    });

    test('should return ErrorModel on failure', () async {
      final error = ErrorModel(message: 'Error', errorCode: 'ERR');
      when(
        mockRepository.verifyEmail('test@email.com'),
      ).thenAnswer((_) async => Left(error));

      final result = await useCase.call('test@email.com');

      expect(result.isLeft, isTrue);
      expect(result.left, error);
    });
  });
}
