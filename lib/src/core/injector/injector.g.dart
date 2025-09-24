// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'injector.dart';

// **************************************************************************
// KiwiInjectorGenerator
// **************************************************************************

class _$InjectorApp extends InjectorApp {
  @override
  void _configureCoreFactories() {
    final KiwiContainer container = KiwiContainer();
    container
      ..registerFactory<EmailVerificationRepository>((c) =>
          EmailVerificationRepositoryImpl(
              remoteDataSource: c.resolve<EmailVerificationRemoteDataSource>()))
      ..registerFactory<EmailVerificationRemoteDataSource>(
          (c) => EmailVerificationRemoteDataSourceImpl())
      ..registerFactory((c) => VerifyEmailUseCase(
          repository: c.resolve<EmailVerificationRepository>()));
  }

  @override
  void _configureAuthFactories() {
    final KiwiContainer container = KiwiContainer();
    container
      ..registerFactory<RegisterPersonRepository>((c) =>
          RegisterPersonRepositoryImp(c.resolve<RegisterPersonDataSource>()))
      ..registerFactory(
          (c) => RegisterPersonUseCase(c.resolve<RegisterPersonRepository>()))
      ..registerFactory((c) => RegisterPersonDataSource())
      ..registerFactory<LoginRepository>(
          (c) => LoginRepositoryImpl(c.resolve<LoginDataSource>()))
      ..registerFactory((c) => LoginUseCase(c.resolve<LoginRepository>()))
      ..registerFactory((c) => LoginDataSource())
      ..registerFactory<EditProfileRepository>((c) =>
          EditProfileRepositoryImpl(c.resolve<EditProfileRemoteDataSource>()))
      ..registerFactory(
          (c) => GetPersonUsecase(c.resolve<EditProfileRepository>()))
      ..registerFactory(
          (c) => UpdatePersonUsecase(c.resolve<EditProfileRepository>()))
      ..registerSingleton((c) => Client())
      ..registerFactory<EditProfileRemoteDataSource>(
          (c) => EditProfileRemoteDataSourceImpl(c.resolve<Client>()))
      ..registerFactory<CodeValidationRepository>((c) =>
          CodeValidationRepositoryImpl(c.resolve<CodeValidationDataSource>()))
      ..registerFactory(
          (c) => ValidateCodeUseCase(c.resolve<CodeValidationRepository>()))
      ..registerFactory((c) => CodeValidationDataSource(c.resolve<Client>()))
      ..registerFactory<EmailRecoveryVerificationRepository>((c) =>
          EmailRecoveryVerificationRepositoryImpl(
              c.resolve<EmailRecoveryVerificationDataSource>()))
      ..registerFactory((c) => VerifyRecoveryEmailUseCase(
          c.resolve<EmailRecoveryVerificationRepository>()))
      ..registerFactory(
          (c) => EmailRecoveryVerificationDataSource(c.resolve<Client>()))
      ..registerFactory<PasswordResetRepository>((c) =>
          PasswordResetRepositoryImpl(c.resolve<PasswordResetDataSource>()))
      ..registerFactory(
          (c) => PasswordResetUseCase(c.resolve<PasswordResetRepository>()))
      ..registerFactory((c) => PasswordResetDataSource(c.resolve<Client>()));
  }
}
